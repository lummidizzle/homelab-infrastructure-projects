# 🧱 Homelab Infrastructure – Ansible Automation Roadmap

**Project Lead:** Olumide Familusi  
**Controller:** `ansible.corp.local`  
**Domain:** `corp.local`  

---

## ✅ Completed Phases

### Phase 1 – User & SSH Setup
- Created `oluadmin` user across all systems
- Configured sudo privileges (`NOPASSWD`)
- Exchanged SSH keys from controller to targets
- Removed root’s `authorized_keys` entries

---

### Phase 2 – Inventory & Config Foundation
- Created `ansible.cfg` (no `-i` required)
- Structured inventory with IPs, FQDN, shortnames
- Populated `/etc/hosts` on **all nodes**
- Validated hostname resolution and access
- Documented everything and pushed to GitHub ✅

---

## 🔄 Phase 3 – Role-Based Automation & Master Playbook (In Progress)

**🎯 Goal:** Build modular, scalable configuration using Ansible Roles

### ✅ Completed
- ✅ Created working `site.yml` master playbook
- ✅ Scaffolded `roles/common` baseline
- ✅ Populated `main.yml` with:
  - Hostname sync to inventory
  - Timezone set to `America/Chicago`
  - `chrony` service installed & enabled
  - Core packages installed (`vim`, `wget`, `curl`, optional `htop`)
  - `/etc/hosts` file deployed across all systems
- ✅ Resolved hostname failures via updated `/etc/hosts`
- ✅ Added fallback logic for chrony service name
- ✅ Handled missing `htop` gracefully
- ✅ Committed and pushed changes to GitHub

---

### 📌 Next Tasks (Upcoming)

- [ ] Create and test `users` role
- [ ] Manage `oluadmin` and any secondary admin users
- [ ] Copy SSH public keys via role
- [ ] Create `/etc/sudoers.d/` drop-ins (e.g. `oluadmin ALL=(ALL) NOPASSWD:ALL`)
- [ ] Document all changes to `README.md` and `error-log.md`
- [ ] Commit and push once stable

---

## 🧱 Future Phases

### 🔐 Phase 4 – Security Hardening
- SELinux status
- Auditd
- SSH config hardening
- File permissions check
- CIS Benchmark alignment

### 🌐 Phase 5 – Networking & Services
- FirewallD/UFW config
- Port whitelisting by role
- DNS resolution testing
- NTP server redirection
- Log forwarding config

### 📊 Phase 6 – Monitoring & Validation
- Nagios integration
- Log forwarding check
- Service status validation
- Cron-based Ansible drift check

---

## 🗂 Target Project Structure

```bash
ansible/
├── ansible.cfg
├── inventory
├── site.yml
├── group_vars/
├── host_vars/
├── files/
│   └── hosts
├── roles/
│   └── common/
│       ├── tasks/
│       ├── handlers/
│       ├── defaults/
│       ├── templates/
│       └── README.md
├── error-log.md
└── roadmap.md

