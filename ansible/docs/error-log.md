# Error Log

Use this to capture issues during playbook runs.

## 2025-08-08
- **Host:** reposync.corp.local  
- **Play:** site.yml → role: security  
- **Error:** package `auditd` missing on Ubuntu  
- **Fix/Reason:** added conditional install for Debian family  
- **Status:** resolved

