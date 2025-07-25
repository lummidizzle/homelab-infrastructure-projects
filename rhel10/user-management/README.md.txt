# 🧑‍💻 User & Group Management - RHEL 10

## ✅ What this phase covers:

- User creation (`useradd`)
- Shell assignment
- Home directory creation
- Sudo privileges (via `wheel`)
- File locations:
  - `/etc/passwd`: User info
  - `/etc/shadow`: Passwords
  - `/etc/group`: Group membership

---

## 📜 Script: `create_user_rhel10.sh`

Automates user creation with:

- `/bin/bash` shell
- Home directory
- Sudo group membership (`wheel`)
- Logging to `/var/log/user_create.log`

---

## 🧪 Manual Commands Tested

```bash
sudo useradd -m -s /bin/bash oluadmin
sudo passwd oluadmin
sudo usermod -aG wheel oluadmin
id oluadmin
getent passwd oluadmin
grep oluadmin /etc/passwd
sudo grep oluadmin /etc/shadow
grep oluadmin /etc/group
