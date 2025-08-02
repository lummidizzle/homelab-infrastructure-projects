# AIDE Playbook Troubleshooting Log

## Issue Summary
- Initially, the `aide.conf` file was being skipped or not copied to the correct location.
- Some servers received Debian configs even though they were Red Hat.
- Multiple versions of `aide.conf` existed, causing confusion and improper overwrites.

## Root Cause
- Misconfigured `main.yml` lacked proper `when:` conditionals for `ansible_os_family`.
- Incorrect or extra files in `roles/security/files/` led to ambiguous results.
- Manual edits caused inconsistent outcomes between test runs.

## Fix & Final Structure
- Split config files into `aide.conf.debian` and `aide.conf.redhat`
- Used precise Ansible `copy` tasks with `when:` conditions
- Cleaned up the role and recreated the `main.yml` from scratch

## Lessons Learned
- Always use conditionals when working with cross-OS automation
- Document the exact config paths (e.g., `/etc/aide/aide.conf` vs `/etc/aide.conf`)
- Use consistent naming and delete old/backup configs from `files/`

## Playbook Recap

| Host                | Status |
|---------------------|--------|
| ansible.corp.local  | ✅ OK |
| devops.corp.local   | ✅ OK |
| dns-nfs.corp.local  | ✅ OK |
| glpi.corp.local     | ✅ OK |
| monitoring.corp.local | ✅ OK |
| security.corp.local | ✅ OK |
| reposync.corp.local | ✅ OK |
| syslog.corp.local   | ✅ OK |
| staging.corp.local  | ✅ OK |
| backup.corp.local   | ✅ OK |


