# Standard Patching Role (RHEL/Rocky/CentOS)

**Role:** `roles/patch_std`  
**Purpose:** Apply OS updates on RHEL-like systems with a conditional reboot and predictable logs.  
**Cadence:** Monthly full patch + weekly security-only (see `patching_schedule.md`).

---

## What this role does
1. Ensures helper tools are present (`dnf-plugins-core`, `yum-utils`).
2. Refreshes metadata (`dnf makecache`).
3. Applies updates:
   - `mode=full`  → `dnf -y update`
   - `mode=security` → `dnf -y update --security`
4. Checks if a reboot is required (`dnf needs-restarting -r`).
5. Reboots only when needed (and waits for the node to return).

> Logging is handled by the wrapper scripts:
> `/var/log/ansible-patching/monthly_<timestamp>.log`  
> `/var/log/ansible-patching/weekly_security_<timestamp>.log`

---

## Requirements
- Ansible controller with connectivity + privilege escalation to targets.
- For RHEL: controller/targets must be registered and have proper RHSM entitlements **or** point to your local mirror.
- Fleet repo config:
  - RHEL/Rocky 9 nodes use **local mirror** via your `repo_reset` role.
  - Controller (RHEL 10) uses **Red Hat CDN** until RHEL 10 is mirrored.

---

## Variables
| Var   | Default | Values            | Notes |
|------|---------|-------------------|------|
| `mode` | `full`  | `full` / `security` | Controls update scope. |

Pass per play:
```yaml
vars:
  mode: "security"

## Example: weekly security run (fleet)
- name: Weekly security patch | RHEL9 fleet
  hosts: rhel9_fleet
  become: true
  vars: { mode: "security" }
  roles:
    - patch_std

## Example: monthly full patch (controller, via CDN)
- name: Monthly full patch | Controller via CDN
  hosts: controller
  become: true
  vars: { mode: "full" }
  pre_tasks:
    - lineinfile:
        path: /etc/dnf/plugins/subscription-manager.conf
        regexp: '^enabled='
        line: 'enabled=1'
        create: true
    - file:
        path: /etc/yum.repos.d/yum-local.repo
        state: absent
    - shell: |
        subscription-manager refresh || true
        subscription-manager repos --enable=rhel-10-for-x86_64-baseos-rpms || true
        subscription-manager repos --enable=rhel-10-for-x86_64-appstream-rpms || true
      args: { executable: /bin/bash }
  roles:
    - patch_std

## Verification

On the controller:
ansible -i inventories/hosts.ini rhel9_fleet -b -m command -a 'dnf repolist'
ansible -i inventories/hosts.ini controller -b -m command -a 'dnf repolist'
ls -lh /var/log/ansible-patching/

## Rollback / gotchas
If a host can’t reach repo sources: check /etc/yum.repos.d/yum-local.repo and your mirror URLs.

If RHSM repo IDs differ: run subscription-manager repos --list and adjust pre_tasks accordingly.

If a kernel lands and you don’t want automatic reboot: set a maintenance window or remove the reboot task temporarily.

