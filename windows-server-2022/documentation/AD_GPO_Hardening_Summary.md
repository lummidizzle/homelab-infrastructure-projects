# Windows Server 2022 AD + GPO Hardening Summary

**Dates:** July 22 – July 24, 2025  
**Domain:** corp.local  
**DC Hostname:** laptop3.corp.local

---

## ✅ What Was Completed

### 🗂️ Organizational Units Created:
- Servers
- Workstations
- Admins
- ServiceAccounts

### 📎 GPOs Created & Linked:
- GPO - Server Hardening
- GPO - Workstation Restrictions
- GPO - Admin Restrictions
- GPO - Service Account Policy
- GPO - Account Lockout Policy

### 🔐 Security Settings Implemented:
- Disabled RemoteRegistry, Xbox services, etc.
- Blocked Control Panel on servers/workstations
- Disabled USB on servers
- Denied logon to service accounts
- Enabled auditing (Logon, Account, Object Access)
- Set NTP sync using domain hierarchy
- Login banners for legal notice
- RDP enabled for Admins

### 💾 GPO Backup:
- GPOs backed up to `C:\GPO-Backups`
- Timestamped
- Done via PowerShell automation

---

## 🧰 Scripts Included:
All scripts are stored under `scripts\`:
- Harden-DC.ps1
- Set-AccountLockoutPolicy.ps1
- Deploy-GPOs.ps1
- Domain-Hardening.ps1
- Disable-Services.ps1

