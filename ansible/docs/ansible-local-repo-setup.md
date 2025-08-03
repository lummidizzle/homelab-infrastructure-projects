# Local Yum Repository Setup with Ansible (Offline Environment)

## 🚀 Project Overview

In this 2-day hands-on implementation, we set up and tested a fully offline-capable **local YUM repository server** using a centralized Red Hat system (`reposync.corp.local`). This repo server was configured to serve content from the BaseOS and AppStream repositories via HTTP to client systems in a closed lab environment. All configurations were automated or verified using Ansible.

---

## ⚙️ Server Role Assignments

* **reposync.corp.local** (192.168.1.13) ➔ Central repo server
* **Client systems** ➔ All RHEL-based systems requiring offline repo access

---

## 📁 Day 1 Summary (Initial Setup + Issues)

### ✔️ Initial Setup Steps:

1. **Created repo folders on reposync server**

   ```bash
   mkdir -p /var/repos/baseos /var/repos/appstream
   ```

2. **Synced the repositories**

   ```bash
   reposync -p /var/repos/baseos --repoid=baseos --download-metadata
   reposync -p /var/repos/appstream --repoid=appstream --download-metadata
   ```

3. **Installed and started Apache**

   ```bash
   sudo dnf install -y httpd
   systemctl enable --now httpd
   ```

4. **Set up Apache virtual host config**
   Created: `/etc/httpd/conf.d/reposync.conf`

   ```apache
   Alias /baseos "/var/repos/baseos"
   <Directory "/var/repos/baseos">
       Options Indexes FollowSymLinks
       AllowOverride None
       Require all granted
   </Directory>

   Alias /appstream "/var/repos/appstream"
   <Directory "/var/repos/appstream">
       Options Indexes FollowSymLinks
       AllowOverride None
       Require all granted
   </Directory>
   ```

5. **Restarted Apache**

   ```bash
   systemctl restart httpd
   ```

6. **SELinux error**: Apache was denied access due to SELinux restrictions.
   **Fix:**

   ```bash
   chcon -R -t httpd_sys_content_t /var/repos/
   setsebool -P httpd_read_user_content 1
   ```

---

### ⚠️ Issues Faced on Day 1:

* `Could not resolve host: reposync.corp.local`
* Blank or misconfigured `/etc/httpd/conf.d/reposync.conf`
* Apache returning `403 Forbidden`
* SELinux denying Apache access
* `dnf` errors about missing metadata or no repo found

---

## 📁 Day 2 Summary (Client Configuration + Validation)

### ✅ Step-by-Step Client Setup

1. **Updated /etc/hosts across all clients** (manually or via Ansible)

   ```bash
   echo "192.168.1.13 reposync.corp.local" >> /etc/hosts
   ```

   Or via Ansible:

   ```yaml
   - name: Add reposync host entry
     lineinfile:
       path: /etc/hosts
       line: "192.168.1.13 reposync.corp.local"
       state: present
   ```

2. **Created local repo files**:

   `/etc/yum.repos.d/local.repo`

   ```ini
   [local-baseos]
   name=Local BaseOS
   baseurl=http://reposync.corp.local/baseos
   enabled=1
   gpgcheck=0

   [local-appstream]
   name=Local AppStream
   baseurl=http://reposync.corp.local/appstream
   enabled=1
   gpgcheck=0
   ```

3. **Tested DNS resolution**

   ```bash
   getent hosts reposync.corp.local
   ```

   Or via Ansible:

   ```bash
   ansible all -m command -a "getent hosts reposync.corp.local"
   ```

4. **Tested HTTP access**

   ```bash
   curl http://reposync.corp.local/baseos/
   ```

   Or via Ansible:

   ```bash
   ansible all -m uri -a "url=http://reposync.corp.local/baseos return_content=no"
   ```

5. **Verified repo presence**

   ```bash
   dnf repolist
   ```

6. **Installed package using only local repos**

   ```bash
   dnf install tree --disablerepo='*' --enablerepo=local-baseos,local-appstream
   ```

   Or via Ansible:

   ```bash
   ansible all -m command -a "dnf install tree -y --disablerepo='*' --enablerepo=local-baseos,local-appstream"
   ```

---

## ✔️ Final Tests Conducted

| Test                | Command                                  | Result                         |
| ------------------- | ---------------------------------------- | ------------------------------ |
| Hostname resolution | `getent hosts reposync.corp.local`       | Passed                         |
| Repo HTTP access    | `curl http://reposync.corp.local/baseos` | 200 OK                         |
| Yum repo check      | `dnf repolist`                           | Shows local-baseos & appstream |
| Package install     | `dnf install tree`                       | Successful from local repo     |

---

## 🌟 Key Lessons Learned

* **SELinux** will block Apache until content is labeled correctly.
* Apache config under `/etc/httpd/conf.d/` is preferred over editing `httpd.conf` directly.
* Don’t forget `lineinfile` module in Ansible for modifying `/etc/hosts` entries.
* Always test with `--disablerepo='*'` to be 100% sure you're pulling from the correct source.

---

## 🔧 Next Steps

* Automate repo client config with Ansible roles.
* Sync latest packages using a cronjob on reposync server.
* Create a status dashboard using Nagios or simple HTML checks.
* Archive this documentation in GitHub under `reposync-setup.md` for future reuse.

---

## 🔍 Troubleshooting Reference

| Error                                         | Fix                                                        |
| --------------------------------------------- | ---------------------------------------------------------- |
| `Could not resolve host: reposync.corp.local` | Add correct line to `/etc/hosts`                           |
| `403 Forbidden` on Apache                     | Fix SELinux context with `chcon`                           |
| Repo missing metadata                         | Ensure `--download-metadata` was used in `reposync`        |
| Apache shows blank                            | Confirm `reposync.conf` is configured and Apache restarted |

---

## 📑 GitHub Commit Message Suggestion

```
docs: add full documentation for offline YUM repo setup
- SELinux issues and resolutions
- Apache config
- Ansible automation for client config
- Final repo validation and curl/http/uri tests
```

