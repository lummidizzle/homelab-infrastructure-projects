# 🧭 Homelab Infrastructure – Ansible Automation Roadmap

**Project Lead:** Olumide Familusi  
**Controller:** `ansible.corp.local`  
**Domain:** `corp.local`

---

## ✅ Completed Phases

### Phase 1 – User & SSH Setup
- Created `oluadmin` user across all systems
- Configured sudo privileges (`NOPASSWD`)
- Exchanged SSH keys from controller
- Removed root’s authorized_keys entries

### Phase 2 – Inventory & Config Foundation
- Created `ansible.cfg` (no `-i` required)
- Structured inventory with IPs, FQDN, shortnames
- Populated `/etc/hosts` on all nodes
- Validated hostname resolution & access
- Documented everything and pushed to GitHub

---

## 🧰 Phase 3 – Role-Based Automation & Master Playbook (In Progress)

> Goal: Build modular, scalable configuration using Ansible Roles

### 🔧 Tasks for Today
- [ ] Create `site.yml` master playbook
- [ ] Scaffold roles: `hostname`, `network`, `firewall`, `ntp`, `packages`, `audit`
- [ ] Setup group_vars and host_vars
- [ ] Populate `main.yml` in each role
- [ ] Write and test first working role (hostname config)
- [ ] Log all output/errors to `error-log.md`
- [ ] Automate daily GitHub commits for tracking

### 🗂️ Target Structure

```bash
ansible/
├── ansible.cfg
├── hosts
├── site.yml
├── group_vars/
├── host_vars/
├── roles/
│   └── hostname/
│       ├── tasks/
│       ├── handlers/
│       ├── defaults/
│       ├── vars/
│       └── templates/
├── error-log.md
└── roadmap.md

