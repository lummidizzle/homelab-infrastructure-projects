# Centralized Linux Logging with **rsyslog** (Hub + Clients)
**Version:** 1.0  
**Author:** homelab-infrastructure-projects  
**Audience:** Linux administrators running an Ubuntu rsyslog hub and mixed Linux clients (Ubuntu/RHEL/Rocky/Stream).  
**Goal:** Collect system logs from every server on a single host **syslog.corp.local** over **TCP/514**, store them under `/var/log/corp/<hostname>/`, and keep the setup simple, secure, and observable.

---

## 0) Quick Map of the Environment
- **Hub (collector):** `syslog.corp.local` (Ubuntu)  
- **Clients (forwarders):** all Linux fleet (Ubuntu + RHEL-like)  
- **Network:** 192.168.1.0/24  
- **Protocol:** TCP/514 (reliable). UDP is optional and disabled by default.  
- **On-disk layout (hub):**
  ```
  /var/log/corp/
    <hostname>/
      auth.log
      cron.log
      sudo.log
      audit.log
      package.log
      messages.log
  ```
- **Web browsing (already in your lab):** `http://syslog.corp.local/` lists `/var/log/corp/` per-host folders.

---

## 1) Why rsyslog, and why TCP?
- **rsyslog** is the default syslog daemon on most Linux distros; fast, extensible, and well‑supported.
- **TCP** ensures delivery (retries/queues) unlike UDP which can drop packets. That’s ideal on small LANs.

---

## 2) Prerequisites
- DNS or `/etc/hosts` entries for `syslog.corp.local`.
- The hub has enough disk for `/var/log/corp/` (and backups/archives).
- Clients can reach hub on `TCP/514`.
- On the hub, `rsyslog` and `ufw` are installed (Ubuntu).

---

## 3) Hub Setup (Ubuntu) — **syslog.corp.local**

> All commands assume sudo-capable user.

### 3.1 Create the listener (TCP/514)
**File:** `/etc/rsyslog.d/00-remote-listener.conf`
```rsyslog
# Load TCP input
module(load="imtcp")

# Listen on TCP/514 and route to the 'perhost' ruleset
input(type="imtcp" port="514" ruleset="perhost")
```

> Optional (not recommended by default): enable UDP as well.
> ```rsyslog
> # module(load="imudp")
> # input(type="imudp" port="514" ruleset="perhost")
> ```

### 3.2 Route incoming events into per-host files
**File:** `/etc/rsyslog.d/01-remote-listener.conf`
```rsyslog
# Put files under /var/log/corp/<hostname>/
global(preserveFQDN="on")

# File templates
template(name="PerHostAuth"   type="string" string="/var/log/corp/%hostname%/auth.log")
template(name="PerHostCron"   type="string" string="/var/log/corp/%hostname%/cron.log")
template(name="PerHostSudo"   type="string" string="/var/log/corp/%hostname%/sudo.log")
template(name="PerHostAudit"  type="string" string="/var/log/corp/%hostname%/audit.log")
template(name="PerHostPkg"    type="string" string="/var/log/corp/%hostname%/package.log")
template(name="PerHostMsgs"   type="string" string="/var/log/corp/%hostname%/messages.log")

# One ruleset to keep files separated and permissions sane
ruleset(name="perhost") {

  # auth / authpriv -> auth.log
  if ($syslogfacility-text == "auth" or $syslogfacility-text == "authpriv") then {
    action(type="omfile" dynaFile="PerHostAuth"  createDirs="on"
           dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640") stop
  }

  # cron -> cron.log
  if ($syslogfacility-text == "cron") then {
    action(type="omfile" dynaFile="PerHostCron"  createDirs="on"
           dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640") stop
  }

  # sudo -> sudo.log
  if ($programname == "sudo") then {
    action(type="omfile" dynaFile="PerHostSudo"  createDirs="on"
           dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640") stop
  }

  # auditd -> audit.log
  if ($programname == "auditd" or $programname == "audit") then {
    action(type="omfile" dynaFile="PerHostAudit" createDirs="on"
           dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640") stop
  }

  # package managers -> package.log
  if ($programname == "dnf" or $programname == "yum" or $programname == "apt" or $programname == "apt-get") then {
    action(type="omfile" dynaFile="PerHostPkg" createDirs="on"
           dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640") stop
  }

  # everything else -> messages.log
  action(type="omfile" dynaFile="PerHostMsgs" createDirs="on"
         dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640")
}
```

### 3.3 Restrict the firewall to LAN only
```bash
# Allow LAN to TCP/514
sudo ufw insert 1 allow from 192.168.1.0/24 to any port 514 proto tcp
# Remove any broad 514 rule if present (ignored if missing)
sudo ufw delete allow 514/tcp 2>/dev/null || true
sudo ufw reload
sudo ufw status numbered | sed -n '1,150p' | grep -E '514/tcp|80/tcp|443/tcp|OpenSSH'
```

### 3.4 Validate and start
```bash
# Validate config
sudo rsyslogd -N1

# Restart rsyslog
sudo systemctl restart rsyslog
sudo systemctl status rsyslog --no-pager -l

# Verify listening socket
sudo ss -lntp | grep ':514'
```

### 3.5 See new arrivals
```bash
# View files written in the last 3 minutes
sudo find /var/log/corp -mmin -3 -type f | sort
```

### 3.6 Log rotation on the hub
**File:** `/etc/logrotate.d/corp-logs`
```conf
/var/log/corp/*/*.log {
  daily
  rotate 14
  compress
  delaycompress
  missingok
  notifempty
  create 0640 syslog adm
  sharedscripts
  postrotate
    /bin/systemctl kill -s HUP rsyslog.service >/dev/null 2>&1 || true
  endscript
}
```

### 3.7 (Optional) Archiving job on the hub
```cron
*/10 * * * * rsync -a --prune-empty-dirs --include="*/" --include="*.gz" --exclude="*" /var/log/corp/ /mnt/hp2-archives/
```

---

## 4) Client Setup (Ubuntu, RHEL, Rocky, Stream)

### 4.1 One tiny forwarder file
**File (all clients):** `/etc/rsyslog.d/99-send-to-syslog.conf`
```rsyslog
# Forward everything to the hub over TCP/514 with a memory queue
action(type="omfwd"
       target="syslog.corp.local" port="514" protocol="tcp"
       action.resumeRetryCount="-1"
       queue.type="linkedList" queue.size="10000")
```

### 4.2 Apply & test
```bash
sudo systemctl restart rsyslog
logger -p authpriv.notice -t rsyslog_test "hello from $(hostname -s)"
```

### 4.3 Verify on the hub
```bash
sudo find /var/log/corp -mmin -3 -type f | sort
# Expect: /var/log/corp/<client-hostname>/auth.log (with your test line)
```

> **Note on SELinux (RHEL-like):** rsyslog forwarding is allowed by default. If your distro has a custom policy blocking outbound 514/tcp, audit logs will show `AVC` denials—rare in default installs.

---

## 5) Optional Ansible Automation

### 5.1 Inventory (example snippet)
Your repo already groups hosts logically. Ensure all Linux boxes are part of `linux_fleet` for a one-shot push.

### 5.2 Playbook to push the forwarder
**File:** `playbooks/syslog-forward.yml`
```yaml
- hosts: linux_fleet
  become: yes
  tasks:
    - copy:
        dest: /etc/rsyslog.d/99-send-to-syslog.conf
        owner: root
        group: root
        mode: '0644'
        content: |
          action(type="omfwd"
                 target="syslog.corp.local" port="514" protocol="tcp"
                 action.resumeRetryCount="-1"
                 queue.type="linkedList" queue.size="10000")
    - service:
        name: rsyslog
        state: restarted
        enabled: yes
    - shell: logger -p authpriv.notice -t rsyslog_test "hello from {{ inventory_hostname }}"
      changed_when: false
```

**Run it:**
```bash
ansible-playbook -i inventory.ini playbooks/syslog-forward.yml
```

---

## 6) Day‑2 Operations

### 6.1 Where to look
- **New files:** `sudo find /var/log/corp -mmin -3 -type f | sort`
- **Hub service:** `sudo systemctl status rsyslog --no-pager -l`
- **Listener:** `sudo ss -lntp | grep ':514'`
- **Firewall:** `sudo ufw status numbered | sed -n '1,150p' | grep 514/tcp`

### 6.2 Capacity & retention
- Tweak `/etc/logrotate.d/corp-logs` (frequency/retention).
- Compress old logs; rsync copies to `/mnt/hp2-archives/` per cron, if enabled.

### 6.3 Browsing
- `http://syslog.corp.local/` lists per-host dirs (as you already have via nginx/lighttpd/Apache).

---

## 7) Troubleshooting Checklist

### 7.1 Hub not listening
```bash
sudo rsyslogd -N1               # syntax check
sudo journalctl -u rsyslog -e   # runtime errors
sudo ss -lntp | grep ':514'     # socket bound to 0.0.0.0:514 or 192.168.1.17:514
```

### 7.2 Firewall blocking
```bash
sudo ufw status numbered | sed -n '1,150p' | grep 514/tcp
sudo tcpdump -i any port 514 -n -c 20  # do we see client SYNs?
```

### 7.3 Nothing under `/var/log/corp`
- Confirm both hub files exist and ruleset names match:
  - `/etc/rsyslog.d/00-remote-listener.conf` (ruleset="perhost")
  - `/etc/rsyslog.d/01-remote-listener.conf` (ruleset **perhost** defined)
- Restart: `sudo systemctl restart rsyslog`
- Test again from a client: `logger -p authpriv.notice -t rsyslog_test "hello"`

### 7.4 Client not forwarding
```bash
sudo systemctl restart rsyslog
logger -p authpriv.notice -t rsyslog_test "hello from $(hostname -s)"
sudo journalctl -u rsyslog -e --no-pager   # look for 'omfwd' errors
```

### 7.5 Port already in use on hub
- Another service bound to 514? Find it:
  ```bash
  sudo ss -lntp | grep ':514' -n
  # If conflicting, stop/disable the other service or move rsyslog to a different port (not recommended).
  ```

---

## 8) Security Notes
- TCP only; limited to LAN (UFW rule). If you must cross networks, use VPN or TLS (rsyslog RELP/TLS).
- Files are owned `syslog:adm` and created as `0640`. Directories `02770`. Adjust as needed.

---

## 9) Change Log
- **v1.0** – First consolidated guide for homelab (Ubuntu hub + mixed Linux clients).

---

## 10) Copy/Paste Block (Hub)
> Create both files, open firewall, validate, restart, and verify.
```bash
sudo tee /etc/rsyslog.d/00-remote-listener.conf >/dev/null <<'EOF'
module(load="imtcp")
input(type="imtcp" port="514" ruleset="perhost")
EOF

sudo tee /etc/rsyslog.d/01-remote-listener.conf >/dev/null <<'EOF'
global(preserveFQDN="on")
template(name="PerHostAuth"   type="string" string="/var/log/corp/%hostname%/auth.log")
template(name="PerHostCron"   type="string" string="/var/log/corp/%hostname%/cron.log")
template(name="PerHostSudo"   type="string" string="/var/log/corp/%hostname%/sudo.log")
template(name="PerHostAudit"  type="string" string="/var/log/corp/%hostname%/audit.log")
template(name="PerHostPkg"    type="string" string="/var/log/corp/%hostname%/package.log")
template(name="PerHostMsgs"   type="string" string="/var/log/corp/%hostname%/messages.log")
ruleset(name="perhost") {
  if ($syslogfacility-text == "auth" or $syslogfacility-text == "authpriv") then {
    action(type="omfile" dynaFile="PerHostAuth" createDirs="on"
      dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640") stop
  }
  if ($syslogfacility-text == "cron") then {
    action(type="omfile" dynaFile="PerHostCron" createDirs="on"
      dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640") stop
  }
  if ($programname == "sudo") then {
    action(type="omfile" dynaFile="PerHostSudo" createDirs="on"
      dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640") stop
  }
  if ($programname == "auditd" or $programname == "audit") then {
    action(type="omfile" dynaFile="PerHostAudit" createDirs="on"
      dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640") stop
  }
  if ($programname == "dnf" or $programname == "yum" or $programname == "apt" or $programname == "apt-get") then {
    action(type="omfile" dynaFile="PerHostPkg" createDirs="on"
      dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640") stop
  }
  action(type="omfile" dynaFile="PerHostMsgs" createDirs="on"
    dirCreateMode="02770" fileOwner="syslog" fileGroup="adm" fileCreateMode="0640")
}
EOF

sudo ufw insert 1 allow from 192.168.1.0/24 to any port 514 proto tcp
sudo ufw delete allow 514/tcp 2>/dev/null || true
sudo ufw reload

sudo rsyslogd -N1
sudo systemctl restart rsyslog
sudo ss -lntp | grep ':514'
```

## 11) Copy/Paste Block (Client)
```bash
sudo tee /etc/rsyslog.d/99-send-to-syslog.conf >/dev/null <<'EOF'
action(type="omfwd"
       target="syslog.corp.local" port="514" protocol="tcp"
       action.resumeRetryCount="-1"
       queue.type="linkedList" queue.size="10000")
EOF
sudo systemctl restart rsyslog
logger -p authpriv.notice -t rsyslog_test "hello from $(hostname -s)"
```

---

### Appendix A — Useful One‑liners

- **Show just-created files on hub:**  
  `sudo find /var/log/corp -mmin -3 -type f | sort`
- **Tail specific host:**  
  `sudo tail -f /var/log/corp/<host>/messages.log`
- **Count total log size:**  
  `sudo du -sh /var/log/corp`
- **Force rotate:**  
  `sudo logrotate -f /etc/logrotate.d/corp-logs && sudo systemctl kill -s HUP rsyslog`

---

### Appendix B — Rollback (hub)
```bash
sudo rm -f /etc/rsyslog.d/00-remote-listener.conf /etc/rsyslog.d/01-remote-listener.conf
sudo systemctl restart rsyslog
sudo ufw delete allow from 192.168.1.0/24 to any port 514 proto tcp 2>/dev/null || true
sudo ufw reload
```

> This removes the remote listener. Logs already written in `/var/log/corp/` remain on disk.
