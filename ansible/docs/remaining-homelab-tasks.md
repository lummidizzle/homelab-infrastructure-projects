# 🧭 What’s Still Left To Do (Remaining Homelab Infrastructure Tasks)

## 🔒 1. Active Directory Integration
- Join all Linux servers (RHEL/CentOS/Ubuntu) to the Windows AD domain (`corp.local`)
- Configure SSSD or realmd for centralized authentication
- Apply Kerberos authentication (`krb5.conf`)
- Enable sudo/group policies for domain users (e.g. `corp\sysadmins`)
- Test login from Linux terminals using domain accounts

## 🎯 2. GPO & Security Policy Mapping
- Use Group Policy Objects (GPO) to enforce security baselines
- Set up password policies, account lockout, and session timeout across systems
- Document mapping of AD groups → Linux system roles/permissions
- Create sample OU structures and nested groups for role-based access

## 📦 3. Ubuntu Patch Automation via Ansible
- Update `site.yml` or a dedicated `patching.yml` to target Ubuntu-based servers
- Use `apt` instead of `yum`/`dnf` in Ansible tasks
- Add conditionals (`when: ansible_os_family == "Debian"`)
- Include security updates, `autoremove`, and reboot logic

## 📋 4. Nagios Alert Scripts & Auto-Healing
- Add custom event handlers to Nagios services (e.g. restart Apache/Nginx if down)
- Write shell scripts to trigger automated remediation
- Test and log results under `/usr/local/nagios/libexec/handlers`

## 📈 5. VM Resource Monitoring & Snapshot Alerts
- Implement basic cron scripts to monitor CPU/RAM/disk thresholds
- Auto-create or suggest VM snapshots before major updates
- Alert if a VM is running low on space or hasn’t been backed up in X days

## 📁 6. Documentation Automation Expansion
- Create GitHub Actions or cron jobs to:
  - Auto-update `README.md` files across project folders
  - Regenerate markdown indexes weekly
  - Clean up unused markdown drafts
- Link your `index.md` as a hub for every `docs/*.md` in the repo

## 🧪 7. Security Hardening Phase II
- Apply ACLs (Access Control Lists) to sensitive files
- Implement RBAC (Role-Based Access Control) via groups
- Add logrotate rules for custom apps
- Set up audit rules in `/etc/audit/rules.d` for specific file access
- Possibly integrate AIDE alerts via mail or cron jobs

## 🔄 8. Weekly Snapshot & Git Auto-Commit Sync
- Ensure all systems:
  - Auto-pull Git changes weekly from centralized repo
  - Auto-push inventory/state changes back to GitHub
  - Create an “Offline GitOps” model for disconnected VMs

## 🧠 9. Knowledgebase & Troubleshooting Wiki
- Create a dedicated `docs/troubleshooting.md`
- Log errors and solutions (e.g., `.lck` VM issues, SSH permission denied, etc.)
- Bonus: convert this into a GLPI knowledge article later

## 🧪 10. Final Testing + Failover Scenarios
- Test disaster recovery: shutdown critical servers and verify alerting/recovery
- Test patch rollbacks and system restores from backups
- Simulate system compromise: verify auditing/logs

