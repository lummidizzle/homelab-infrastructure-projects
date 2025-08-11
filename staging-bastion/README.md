# ubuntu-lite
Documentation for ubuntu-lite component.

# Staging Server (Bastion / Jump Host)

The single-entry SSH bastion for the lab.  
Ubuntu-based.  
Logs every admin session, keystroke, and command for audit purposes.  
Protects the fleet by rate-limiting brute force attempts and forwarding all logs to the central syslog server.

---

## Architecture

**Flow:**  
Admins → **staging.corp.local** → all internal servers  

- Session/keystroke logging via `auditd` + `pam_tty_audit`
- Logs forwarded to `syslog.corp.local` (buffers locally if syslog is offline)
- Only port **22/tcp** allowed inbound (UFW)
- Everything else denied by default

---

## Requirements

- **OS:** Ubuntu LTS
- **vCPU:** 1–2
- **RAM:** 2 GB
- **Disk:** 40 GB
- **Network:**  
  - Accessible from admin subnets  
  - Outbound SSH to internal servers  
- DNS/Hosts entry for `syslog.corp.local` (or static IP in `/etc/hosts`)

---

## Installed & Configured

- `fail2ban` → brute force defense
- `auditd` → session/command logging
- `rsyslog` → log forwarding (disk-backed queue)
- `ufw` → firewall (default deny)
- `pam_tty_audit` → keystroke capture
- Journald size limit via `/etc/systemd/journald.conf.d/size.conf`
- Durable queue config in `/etc/rsyslog.d/99-forward.conf`

---

## Deployment (Ansible)

```bash
# From repo root
ansible-playbook playbooks/bastion.yml -l staging --check --diff
ansible-playbook playbooks/bastion.yml -l staging -vv   # add -K if prompted for sudo

