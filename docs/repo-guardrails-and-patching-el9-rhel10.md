Repo Guardrails & Patching (EL9 Fleet + RHEL10 Controller)

Owner: Olumide
Version: v0.2.2-repo-guardrails
Dates covered: the last 3–4 days of work (mirror wiring, canary, verify, monthly automation, CI, and RHEL10 patching)

Table of Contents

Executive Summary

Scope & Out-of-Scope

Architecture

Repo Policy (Allowlists)

What We Deployed

How Patching Works Here (Step-by-Step)

Playbooks & Roles (Deep Dive)

Automation: Cron & CI

Operational Runbook

Troubleshooting & Known Failure Modes

Security & Compliance Notes

Metrics, Logs & Observability

Decisions & Rationale

Known Limitations & Next Steps

Appendix A — Reference Paths & IDs

Appendix B — Glossary

Executive Summary

We implemented conservative repo guardrails and monthly patch automation for the EL9 fleet (RHEL 9, CentOS Stream/Rocky 9) with a separate, simple RHSM-only patch flow for the RHEL10 controller. Every EL9 host now:

Uses only approved repositories (allowlist per OS).

Pulls EPEL from our internal mirror via epel-local; upstream EPEL is disabled.

Must pass a canary (mirror health test) and a verify (policy compliance) before patching.

Gets patched monthly via Ansible, serially, with logs and CI guarding the code.

The RHEL10 controller is patched monthly via RHSM only (no mirror dependency) on a separate schedule to avoid overlap with EL9.

Scope & Out-of-Scope

In scope (live now):

EL9 fleet: RHEL 9, CentOS Stream 9, Rocky 9

Local mirror for Stream 9 base repos (BaseOS/AppStream/CRB) and EPEL 9

RHEL 9 uses RHSM for base, epel-local for EPEL

Canary & verify gating before patches

Monthly patch cron (EL9) + weekly verify dry-run

CI: lint + syntax checks on push/PR

Separate RHEL10 (controller) monthly patch via RHSM

Out of scope (as of this version):

EL8 support (no EL8 hosts present)

EL10 guardrails & EPEL-10 mirror (controller is RHSM-only for now)

Fancy notifications (Slack/email) — can be added later

Architecture
               ┌───────────────────────────┐
               │  Ansible Controller       │   RHEL 10
               │  (orchestrates only)      │
               └───────────┬───────────────┘
                           │ SSH + Ansible
                           │
        ┌──────────────────┴──────────────────┐
        │                                     │
┌───────▼────────┐                    ┌───────▼────────┐
│ EL9 Hosts       │                    │ EL9 Hosts       │
│ RHEL 9          │                    │ Stream/Rocky 9  │
│ Base: RHSM      │                    │ Base: LOCAL     │
│ EPEL: epel-local│                    │ EPEL: LOCAL     │
└───────┬────────┘                    └───────┬────────┘
        │ HTTP                                   │ HTTP
        │                                         │
        └───────────────┬─────────────────────────┘
                        │
               ┌────────▼─────────┐
               │ RepoServer (CS9) │
               │ BaseOS/AppStream/│
               │ CRB (Stream 9)   │
               │ EPEL 9 mirror    │
               └──────────────────┘


Key point: The controller never proxies packages. It tells each host to patch; hosts fetch directly from their configured repos (RepoServer and/or RHSM).

Repo Policy (Allowlists)

We enforce an explicit allowlist of repository IDs per OS family.

RHEL 9 (via RHSM + local EPEL)

rhel-9-baseos-rpms

rhel-9-appstream-rpms

codeready-builder-for-rhel-9-x86_64-rpms

epel-local

RHSM sometimes presents the first two as rhel-9-for-x86_64-baseos-rpms / rhel-9-for-x86_64-appstream-rpms. Our verify normalizes those.

CentOS Stream / Rocky 9 (via RepoServer mirror)

local-baseos

local-appstream

local-crb

epel-local

epel-next-local (if mirrored/needed)

RHEL 10 controller (separate, RHSM-only)

rhel-10-for-x86_64-baseos-rpms

rhel-10-for-x86_64-appstream-rpms

codeready-builder-for-rhel-10-x86_64-rpms

(No EPEL used on the controller at this time.)

What We Deployed

Mirror wiring: Confirmed EPEL 9 RPMs present; validated Stream 9 BaseOS/AppStream/CRB paths; health-checked with HTTP HEAD.

EPEL-local: Delivered epel-local.repo on EL9; disabled upstream EPEL; shipped GPG key.

Canary (install-canary-epel.yml): Uses dnf repoquery against epel-local to confirm packages exist, then installs exactly one (from mirror only).

Verify (repo-verify.yml): Reads enabled repos, normalizes RHSM names and upstream vs. local naming, then fails if enabled repos differ from the allowlist.

Patch orchestration:

EL9 monthly at 02:00 via patch-guarded.yml (serial).

RHEL10 controller monthly at 03:30 via patch-rhel10.yml (RHSM-only).

CI: GitHub Actions running yamllint, ansible-lint, and syntax checks on every push/PR; weekly schedule.

How Patching Works Here (Step-by-Step)

Guardrails ensure each host can only see repos from its allowlist.

Canary validates the mirror (EL9 EPEL) by repoquerying and installing a tiny, non-invasive package (e.g., ripgrep) from epel-local only.

Verify asserts the host’s enabled repos match the allowlist (with normalization).

Patch: the monthly job runs dnf upgrade (EL9) or RHSM upgrade (RHEL10), per-host, serially, and logs output.

Reboot policy: if needs-restarting -r signals a reboot, Ansible will reboot the host safely.

Post-run: cron logs live in /var/log/ansible/ for audit.

Playbooks & Roles (Deep Dive)
ansible/playbooks/install-canary-epel.yml (EL9)

Purpose: Prove epel-local is healthy before we patch.

Mechanics:

Installs dnf-plugins-core (for repoquery).

Probes a candidate set (ripgrep, fzf, bat, htop, ncdu) using:

dnf repoquery --qf "%{name}" --disablerepo='*' --enablerepo=epel-local <pkg>


Non-zero RC means “not found,” so it’s safe to decide truthfully.

Picks the first available package and installs it with:

dnf name=<pkg> state=present disablerepo='*' enablerepo='epel-local'


Result: if canary fails, we don’t patch.

ansible/playbooks/repo-verify.yml

Purpose: Ensure each host’s enabled repos equal the allowlist (policy compliance).

Mechanics:

Extracts enabled IDs from dnf -q repolist --enabled -v.

Normalizes:

epel → epel-local

crb/powertools → local-crb

baseos → local-baseos

appstream → local-appstream

rhel-<N>-for-x86_64-baseos-rpms → rhel-<N>-baseos-rpms

rhel-<N>-for-x86_64-appstream-rpms → rhel-<N>-appstream-rpms

Computes extras (unexpected) and missing (not enabled but required).

Fails fast if either list is non-empty.

ansible/playbooks/patch-guarded.yml (EL9 fleet)

Purpose: Patch EL9 machines only after canary & verify pass.

Mechanics:

Updates metadata; runs upgrades from the allowlisted repos.

Uses serial strategy to reduce blast radius.

Checks needs-restarting -r; reboots if required.

ansible/playbooks/patch-rhel10.yml (controller)

Purpose: Patch the RHEL10 controller via RHSM only.

Mechanics:

Best-effort enables RHSM repos.

Disables any EPEL/EPEL-local.

Runs upgrade; reboots if required.

Role: repo_guardrails

Drops epel-local.repo for EL9.

Ensures EPEL GPG key is present.

Disables upstream EPEL.

Evaluates “stream vs. rhel” and builds allowlist accordingly.

Automation: Cron & CI
Cron

EL9 monthly patch (controller): 02:00 on the 1st → /usr/local/sbin/monthly-patch.sh → runs patch-guarded.yml and logs to /var/log/ansible/patch-YYYYmmdd-HHMM.log.

Weekly verify dry-run: 02:00 Sundays → runs repo-verify.yml --check and logs to /var/log/ansible/repo-verify-YYYYmmdd.log.

RHEL10 controller monthly patch: 03:30 on the 1st → /usr/local/sbin/monthly-patch-rhel10.sh → runs patch-rhel10.yml.

CI (GitHub Actions)

.github/workflows/ci-ansible.yml runs on push/PR:

yamllint

ansible-lint

Ansible --syntax-check for all playbooks

Weekly scheduled run included for drift detection at the code level.

Operational Runbook
Before Patch Window

Check last weekly verify log for any drift.

Ensure mirror host health (disk, httpd, free space).

Confirm no pending infrastructure changes (e.g., repo renames).

During Patch

Canary (EL9): must pass.

Verify (EL9): must pass.

Patch (EL9): patch-guarded.yml runs serially.

Patch (RHEL10): runs later via its own cron (RHSM-only).

Reboots handled automatically if required.

After Patch

Spot-check a few hosts: kernel version, dnf history, service health.

Review /var/log/ansible/ for failures/warnings.

Tag the repo if we made code changes for the run.

Troubleshooting & Known Failure Modes
1) Canary fails (“no candidate in epel-local”)

Likely causes: mirror stale, wrong baseurl, missing GPG key, repo file absent.

Check:

dnf repoquery --disablerepo='*' --enablerepo=epel-local ripgrep on the target.

curl -I http://reposync.corp.local/repos/el9/epel/repodata/repomd.xml from the host.

/etc/yum.repos.d/epel-local.repo content and GPG key path.

2) Verify fails (drift)

Likely causes: extra repos enabled, RHSM arch-suffixed names not normalized, upstream EPEL still enabled.

Fix: disable extras, ensure normalization rules in repo-verify.yml are up to date, keep epel-local only for EPEL.

3) RHSM oddities on RHEL 9

Sometimes hosts show rhel-10-* repos accidentally enabled. Disable them and clear metadata.

4) GPG failures

Ensure /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9 is present on EL9 hosts.

Security & Compliance Notes

Principle of Least Repository: hosts only see the exact repos they need.

Local EPEL removes Internet dependency and allows curation.

Unsigned or unexpected repos are treated as drift and block patching.

Reboots are controlled and logged.

Metrics, Logs & Observability

Cron logs: /var/log/ansible/patch-*.log, /var/log/ansible/repo-verify-*.log, /var/log/ansible/patch-rhel10-*.log

Ansible output includes changed, failed, and chosen canary package.

Optional next: wire log tail + summaries to Slack/email.

Decisions & Rationale

EPEL via local mirror: reduces external risk, stabilizes content.

Repoquery (not dnf list): accurate presence detection (non-zero RC when missing).

Normalization in verify: RHSM repo ID variations shouldn’t break policy checks.

RHEL10 separate flow: keeps EL9 policy tight, patches the controller safely via RHSM while EL10 guardrails mature.

Known Limitations & Next Steps

EL10 guardrails: not yet implemented. If we want parity for the controller, add allowlist rules and (optionally) mirror EPEL 10.

Notifications: add Slack/email hooks for patch success/failure.

Post-patch smoke: add a small health checklist (e.g., critical service status, free space, kernel pinned).

Snapshotting: optional LVM/VM snapshot pre-patch for quick rollback.

Appendix A — Reference Paths & IDs

RepoServer example paths

Stream 9 (mirror):

http://reposync.corp.local/centos-stream/9/baseos/

http://reposync.corp.local/centos-stream/9/appstream/

http://reposync.corp.local/centos-stream/9/crb/

EPEL 9 (mirror):

http://reposync.corp.local/repos/el9/epel/

EPEL-local repo file (EL9)

[epel-local]
name=EPEL 9 (local mirror)
baseurl=http://reposync.corp.local/repos/el9/epel
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
priority=5
skip_if_unavailable=True
metadata_expire=6h


Canary package candidates

ripgrep, fzf, bat, htop, ncdu

Repo IDs (canonical)

RHEL 9: rhel-9-baseos-rpms, rhel-9-appstream-rpms, codeready-builder-for-rhel-9-x86_64-rpms, epel-local

Stream/Rocky 9: local-baseos, local-appstream, local-crb, epel-local, epel-next-local

RHEL 10 controller: rhel-10-for-x86_64-baseos-rpms, rhel-10-for-x86_64-appstream-rpms, codeready-builder-for-rhel-10-x86_64-rpms

Appendix B — Glossary

RHSM: Red Hat Subscription Management (cdn.redhat.com content).

EPEL: Extra Packages for Enterprise Linux (Fedora-driven repository).

Mirror/RepoServer: Internal HTTP server hosting mirrored repositories.

Guardrails: Code and policy enforcing an allowlisted set of repos per host.

Canary: A small package fetch/install that proves a repo is reachable and healthy.

Verify: A strict check that enabled repos equal the allowlist (after normalization).

Serial patching: patch a few hosts at a time to limit blast radius.
