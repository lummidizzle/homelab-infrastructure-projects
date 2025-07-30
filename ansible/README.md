# Ansible Automation - SSH, Sudo, Inventory, Hosts File

This folder contains automation playbooks for setting up:

- ✅ SSH key-based access across all managed nodes
- ✅ Passwordless `sudo` configuration for the `oluadmin` user
- ✅ Centralized Ansible inventory file
- ✅ Automated distribution of `/etc/hosts` file to all nodes

## 📁 Structure

```bash
ansible/
├── ansible.cfg
├── inventory
├── site.yml
└── roles/
    └── hostfile/
        ├── tasks/
        │   └── main.yml
        └── templates/
            └── hosts.j2
```

## 🚀 Playbook Execution

Run this command from your Ansible controller:

```bash
ansible-playbook site.yml
```

## 🔐 SSH & Sudo Setup

The following script was used to configure passwordless `sudo`:

```bash
servers=(
  glpi.corp.local
  ansible.corp.local
  reposync.corp.local
  dns-nfs.corp.local
  monitoring.corp.local
  backup.corp.local
  syslog.corp.local
  staging.corp.local
  devops.corp.local
  security.corp.local
)

for i in "${servers[@]}"
do
  ssh oluadmin@$i "echo 'oluadmin ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/99_oluadmin && sudo chmod 440 /etc/sudoers.d/99_oluadmin"
done
```

---

## ✅ Status: Completed and Pushed to GitHub

