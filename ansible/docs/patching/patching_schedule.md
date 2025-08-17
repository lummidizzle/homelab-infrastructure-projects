# Patching Schedule & Operations

We follow a conventional enterprise cadence: **monthly full patch** + **weekly security sweep**, with out-of-band updates for critical CVEs.

---

## Cadence

### Monthly Full Patch
- **When:** Second Wednesday @ 23:00 local time
- **Scope:** Full `dnf update` on the RHEL/Rocky fleet and controller
- **Reboot:** Automatic if required (kernel/glibc/openssl, etc.)
- **Trigger:** systemd timer → wrapper script → Ansible playbook

### Weekly Security Patch
- **When:** Every Sunday @ 02:15 local time
- **Scope:** Security-only updates (`dnf -y update --security`)
- **Reboot:** Automatic if required
- **Trigger:** systemd timer → wrapper script → Ansible playbook

### Out-of-Band (Emergency)
- **When:** Immediately for actively exploited or high-severity CVEs (7.0+)
- **Scope:** Targeted hosts or entire fleet as needed
- **Command:** run the monthly playbook on demand

---

## Implementation Summary

- **Playbooks**
  - `patch-monthly.yml` (full updates)
  - `patch-weekly-security.yml` (security-only)
- **Wrappers**
  - `scripts-run-monthly.sh`
  - `scripts-run-weekly-security.sh`
- **Timers**
  - `/etc/systemd/system/ansible-monthly-patch.timer` → `OnCalendar=Wed *-*-08..14 23:00`
  - `/etc/systemd/system/ansible-weekly-security.timer` → `OnCalendar=Sun 02:15`
- **Logs**
  - `/var/log/ansible-patching/monthly_<timestamp>.log`
  - `/var/log/ansible-patching/weekly_security_<timestamp>.log`

---

## Runbooks

### Manual Kick (now)
```bash
./scripts-run-weekly-security.sh
./scripts-run-monthly.sh

## Dry-run (compile check)
ansible-playbook -i inventories/hosts.ini patch-weekly-security.yml --check
ansible-playbook -i inventories/hosts.ini patch-monthly.yml --check

## See next scheduled times
systemctl list-timers | egrep 'ansible-(monthly|weekly-security)'

## Recovery Steps

- Play fails mid-run

Re-run the same script; Ansible is idempotent.

- Host reboots and doesn’t come back

Check hypervisor/console, ensure network is up, then re-run play.

- Repo errors (404/timeout)

For fleet: verify local mirror URLs in repo_reset defaults.

For controller: verify RHSM repo IDs via subscription-manager repos --list.

- Need to hold back a package

Use dnf versionlock on impacted host(s) and document the waiver.
