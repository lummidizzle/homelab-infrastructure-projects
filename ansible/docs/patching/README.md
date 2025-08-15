# Automated Patching (RHEL/Rocky + Ubuntu/Debian + Controller)

This document covers the standardized patching process for all servers in the homelab, including RHEL/Rocky systems, Ubuntu/Debian systems, and the Ansible controller.  
It aligns with conventional IT standards for security, reliability, and compliance.

---

## 1. Patch Frequency & Schedule

- **Weekly Security Patching**
  - Runs every **Saturday at 02:00 AM**
  - Only applies **security updates**
  - Triggered via scheduled Ansible playbook

- **Monthly Full Patching**
  - Runs on the **first Saturday of each month at 02:00 AM**
  - Applies all available updates
  - Includes kernel and non-security packages

---

## 2. Patching Scope

- **RHEL/Rocky Linux Servers** → Standard patch role
- **Ubuntu/Debian Servers** → Equivalent apt-based patch role
- **Ansible Controller (RHEL 10)** → Patched via CDN to ensure it stays in sync with the latest Ansible packages and dependencies

---

## 3. Pre-Patching Verification

Before applying updates, run a **dry-run** check:

**For RHEL/Rocky:**
```bash
sudo dnf check-update
ansible-playbook patch.yml --check

## 4. Running the Playbooks

**Weekly Security Patch (RHEL/Rocky):**
```bash
ansible-playbook patch.yml --tags security

Monthly Full Patch (RHEL/Rocky):

ansible-playbook patch.yml --tags full


Weekly Security Patch (Ubuntu/Debian):

ansible-playbook patch_ubuntu.yml --tags security


Monthly Full Patch (Ubuntu/Debian):

ansible-playbook patch_ubuntu.yml --tags full

## 5. Post-Patching Verification

Confirm updates installed:

sudo dnf history list
sudo apt list --upgradable

Check for pending reboots:

# RHEL/Rocky
if [ -f /var/run/reboot-required.pkgs ]; then echo "Reboot required"; fi

# Ubuntu/Debian
if [ -f /var/run/reboot-required ]; then echo "Reboot required"; fi

## 6. Rollback Procedure

Kernel Rollback:

Keep last 2 kernels.

At boot, select previous kernel from GRUB menu.

DNF Transaction Rollback (RHEL/Rocky):

sudo dnf history
sudo dnf history rollback <transaction-id>

APT Rollback (Ubuntu/Debian):

Rollback handled by re-installing previous versions from apt cache or backups.

## 7. Logging & Tracking

All Ansible patching runs log to:

ansible/logs/ansible-patching/

Weekly logs follow:

weekly_security_YYYY-MM-DD_HH-MM.log

Monthly logs follow:

monthly_full_YYYY-MM-DD_HH-MM.log

## 8. Files/Playbooks Reference

Inventory groups:

[rhel9_fleet] → RHEL/Rocky boxes on local mirror

[controller] → ansible.corp.local (RHEL10, CDN)

RHEL/Rocky playbooks:

patch-weekly-security.yml → mode=security, runs role patch_std

patch-monthly.yml → mode=full, runs role patch_std

Ubuntu playbook:

patch_ubuntu.yml → security/full via tags; uses apt tasks

Roles:

roles/patch_std/ → generic patch role for RHEL-like OS

Ubuntu version mirrors it but uses apt commands.

## 9. Troubleshooting (Greatest Hits)

404 on RHEL fleet → Verify /etc/yum.repos.d/yum-local.repo points to your mirror; check repodata/repomd.xml URLs.

Controller using local repo by mistake → Remove /etc/yum.repos.d/yum-local.repo; ensure RHSM plugin enabled=1; re-enable rhel-10-for-x86_64-{baseos,appstream}-rpms.

Ansible ad-hoc with pipes fails → Use -m shell instead of default command when piping (e.g., | head -n 60).

Host didn’t reboot → Check console/hypervisor networking; re-run the play — it’s idempotent.

## 10. References

Red Hat Patch Management Documentation (RHSM, DNF)

Ubuntu Server Package Management Documentation

Last Updated: 2025-08-15

