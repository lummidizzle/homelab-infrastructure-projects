# Ansible Documentation Hub (Homelab Infrastructure Project)

Welcome to the centralized documentation hub for the `homelab-infrastructure-projects` Ansible configuration. This directory is where **all** role-specific and project-wide documentation lives for future reference, reproducibility, and collaboration.

---

## 📜 Documentation Structure

Each major Ansible role or component in our infrastructure has its own subdirectory and a detailed `README.md` file. Use this index to quickly navigate to any part of the configuration and see what was done, why it was done, and how to replicate it.

---

### 📦 Ansible Roles

| Role              | Description                                                                 | Documentation Link |
|-------------------|-----------------------------------------------------------------------------|--------------------|
| Common            | Base configuration for all servers                                         | [common/README.md](common/README.md) |
| User Management   | Manages local users, groups, and sudo permissions                          | [user-management/README.md](user-management/README.md) |
| Monitoring        | Nagios Core setup and configuration                                        | [monitoring/README.md](monitoring/README.md) |
| Security          | Installs AIDE, auditd, UFW, and rootkit detection                          | [security/README.md](security/README.md) |
| Backup            | rsync-based backup and log rotation tasks                                  | [backup/README.md](backup/README.md) |
| DNS-NFS           | DNS server and NFS shares configuration                                    | [dns-nfs/README.md](dns-nfs/README.md) |
| Reposync          | Local YUM repo mirroring and management                                    | [reposync/README.md](reposync/README.md) |
| GLPI              | IT asset and ticketing system deployment                                   | [glpi/README.md](glpi/README.md) |
| Staging           | Dev/staging server setup and configurations                                | [staging/README.md](staging/README.md) |
| DevOps            | Automation tools and version control integrations                         | [devops/README.md](devops/README.md) |
| Syslog            | Centralized log collection using rsyslog                                   | [syslog/README.md](syslog/README.md) |
| Security          | Hardening, compliance, and monitoring integrations                        | [security/README.md](security/README.md) |

---

## 🛠 Automated Patching (RHEL/Rocky + Controller)

We standardized patching across the environment to align with conventional IT standards for reliability, security, and compliance.

- **Patch Frequency:**
  - **Weekly Security Patching:** Every Saturday at 02:00 AM (low activity window).
  - **Monthly Full Patching:** First Saturday of each month at 02:00 AM.
- **Verification:**
  - Patches verified via `dnf check-update` and post-patch `dnf history`.
  - Controller runs `ansible-playbook patch.yml --check` (dry run) midweek before production patching.
- **Rollback:**
  - Last 2 kernel versions retained for emergency boot.
  - `dnf history rollback` documented in `patching/README.md`.
- **Scope:**
  - Applies to all RHEL/Rocky servers and the Ansible controller itself.
  - Ubuntu/Debian systems follow a parallel process documented in `patching/README.md`.
- **Documentation:**
  - Detailed runbook: [patching/README.md](patching/README.md)
  - Error tracking: [error-log.md](error-log.md)

---

## 🗺 How to Use This Hub

- Each role has its **own folder** under `ansible/roles/` and an associated **docs folder** under `ansible/docs/`.
- All changes made via Ansible should be reflected in both code and documentation.
- When updating or creating a new role, remember to:
  1. Add/update the corresponding `README.md`.
  2. List it here in the table with a link.
  3. Commit the changes to GitHub.

---

## 🔗 Other References

- [Project Goals & Blueprint](../README.md)
- [Troubleshooting Logs](../troubleshooting.md)
- [Server IP Map](../assets/ip-map.md)
- [Playbook Directory](../playbooks/)

---

## 📅 Last Updated

`2025-08-15` – Added automated patching standards and documentation. Patching schedule now active in production and live inventory.

---

This index is the map to our Ansible-powered kingdom. Keep it up to date or be lost in YAML forever.

