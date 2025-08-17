# Error Log

Use this to capture issues during playbook runs.

## 2025-08-08
- **Host:** reposync.corp.local  
- **Play:** site.yml → role: security  
- **Error:** package `auditd` missing on Ubuntu  
- **Fix/Reason:** added conditional install for Debian family  
- **Status:** resolved

### 2025-08-15 — Weekly security patch

- Controller (RHEL 10) rebooted mid-run due to kernel update.
- Ansible resumed after reconnect; play completed successfully.
- Evidence: `/var/log/ansible-patching/weekly_security_2025-08-15_12-17.log`

