# 🛠️ Ansible Automation - homelab-infrastructure-projects

Welcome to the **Ansible** section of the Homelab Infrastructure Projects repository!

This folder contains all automation playbooks, inventories, roles, templates, and configuration files used to manage, configure, and orchestrate the Linux and Windows servers across our hybrid lab environment.

---

## 🎯 Purpose

To automate every single server configuration in the lab – from **hostname assignments, SSH setups, sudoers updates, inventory generation, and hosts file management**, all the way to package installations, repo management, and service enablement.

Think: *One command. Full server setup.*  
Because real sysadmins automate the boring stuff and sip coffee while it runs ☕😎

---

## 📂 Folder Structure


---

## ✅ Day 1–2 Automation Tasks Completed

- 🔑 SSH key distribution to all servers
- 👑 Sudo privileges configured for automation user
- 🗂 Static inventory and dynamic inventory draft
- 📝 Hosts file automated via Jinja2 template
- 📜 `site.yml` configured to tie everything together
- ⚙️ `ansible.cfg` tuned for control machine
- 🗄 Logs and errors recorded in `error-log.md`
- 📦 Created `playbooks/update-rhel-repo.yml` for RHEL repo sync automation
- 📦 Created `playbooks/update-ubuntu-repo.yml` for Ubuntu repo sync automation
- 🛠 Added helper scripts in `scripts/` for status checks, cleanup, and system info gathering
- 🧹 `.gitignore` configured to keep junk, local secrets, and cache files out of GitHub

---

## 🚀 Upcoming Tasks (To Be Automated)

- 🖥 Hostname configuration  
- 🌐 Network configuration (static IPs, gateways)  
- 🔒 Firewall and SELinux automation  
- 🕒 NTP/time sync  
- 📦 App installations  
- 📜 RBAC & ACL configuration  
- 🔗 Integration with Nagios and Satellite  
- 🔄 Full repo sync automation across multiple systems when resources allow

---

## 🐞 Error Logging

See [error-log.md](/ansible/docs/error-log.md) for a running list of:  
- Bugs encountered during playbook runs  
- Fixes, workarounds, and reasons  
- Any odd system behavior worth tracking  

---

## 📚 Documentation

- [Ansible Local Repository Setup Guide](./docs/ansible-local-repo-setup.md) – How to configure a local YUM/DNF repo with Apache, fix SELinux issues, and verify using Ansible.

---

## 📝 Notes

This is built as part of a world-class hybrid lab for **Red Hat-focused, enterprise-level automation**.  
If it ain’t documented and repeatable, it didn’t happen. That’s the mantra.

---

## 🔗 Links

- 📁 GitHub Repo Root: [homelab-infrastructure-projects](https://github.com/lummidizzle/homelab-infrastructure-projects)  
- 📄 [error-log.md](./error-log.md)  

---

> "Automation is to sysadmins what spellbooks are to wizards." 🪄✨

