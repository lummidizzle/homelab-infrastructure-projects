
# 🖥️ RHEL Client Configuration for Local Repo Access

## 🧭 Overview
This guide documents how to configure RHEL clients to use the internal HTTP-based local repository hosted on `reposync.corp.local`.

---

## 🔧 Manual Method (Tested)

### 1. Create the repo file on each RHEL client
```bash
sudo vi /etc/yum.repos.d/local.repo
```

Paste the following:
```ini
[local-baseos]
name=Local BaseOS
baseurl=http://reposync.corp.local/baseos/
enabled=1
gpgcheck=0

[local-appstream]
name=Local AppStream
baseurl=http://reposync.corp.local/appstream/
enabled=1
gpgcheck=0
```

### 2. Clean up & refresh
```bash
sudo dnf clean all
sudo dnf makecache
```

---

## 🤖 Ansible Playbook Method

We used the following playbook task in `site.yml`:

```yaml
- name: Configure local.repo on RHEL clients
  ansible.builtin.template:
    src: local.repo.j2
    dest: /etc/yum.repos.d/local.repo
    mode: '0644'
  when: ansible_os_family == "RedHat" and inventory_hostname != "reposync.corp.local"
```

And created a Jinja2 template `local.repo.j2`:

```jinja2
[local-baseos]
name=Local BaseOS
baseurl=http://reposync.corp.local/baseos/
enabled=1
gpgcheck=0

[local-appstream]
name=Local AppStream
baseurl=http://reposync.corp.local/appstream/
enabled=1
gpgcheck=0
```

---

## ✅ Validation Commands

On each RHEL client, run:

```bash
dnf repolist
```

And confirm you see `local-baseos` and `local-appstream`.

Also try:
```bash
sudo dnf install tree -y
```

It should install without using Red Hat’s CDN.

---

## 🧱 Troubleshooting

| Issue | Fix |
|------|-----|
| `Cannot download repomd.xml` | Ensure Apache is running on reposync server and SELinux allows HTTP access. Use: `sudo setsebool -P httpd_read_user_content 1` |
| `Could not resolve host: reposync.corp.local` | Check that `/etc/hosts` has entry for `reposync.corp.local` pointing to the correct IP |
| Repo shows but doesn't install | Ensure the path on the server has correct permissions (`chmod -R 755 /var/www/html`) and Apache is serving files properly |

---

## 🧼 Notes

- We excluded `reposync.corp.local` from the playbook using:
```yaml
when: inventory_hostname != "reposync.corp.local"
```
- Used `--limit` in Ansible runs when targeting specific groups or hosts

---

## 📅 Last Updated
August 03, 2025

