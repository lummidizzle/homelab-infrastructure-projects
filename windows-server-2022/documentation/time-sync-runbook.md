# Runbook: AD DNS Records & Time Synchronization

## Overview

This runbook documents the process of:

1. Registering Linux/Windows servers in AD DNS with their canonical names.
2. Configuring and validating time synchronization across the fleet (Windows DC as the reference source).

---

## Part A — AD DNS Registration

### Intent

Ensure all homelab servers are resolvable via DNS using their canonical names, enabling consistent AD and cross-system authentication.

### Steps

1. **Validate forward/reverse DNS zones exist in AD DS.**

   * Confirm primary DNS suffix matches AD domain.
   * Ensure reverse zones (PTRs) exist for each subnet.

2. **Register hostnames:**

   * From Windows DC, ensure `dnscmd` or PowerShell `Add-DnsServerResourceRecordA` used.
   * Example:

     ```powershell
     Add-DnsServerResourceRecordA -Name "syslog" -ZoneName "corp.local" -AllowUpdateAny -IPv4Address 192.168.1.10
     ```

3. **Verify resolution:**

   * Forward lookup:

     ```bash
     nslookup syslog.corp.local
     ```
   * Reverse lookup:

     ```bash
     nslookup 192.168.1.10
     ```

4. **Repeat** for all 10 servers (Linux + Windows).

---

## Part B — Time Synchronization

### Intent

Ensure all systems sync with the Windows Server 2022 Domain Controller (authoritative NTP source).

### Windows Configuration

1. Configure DC with external NTP peers:

   ```powershell
   w32tm /config /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org" /syncfromflags:manual /reliable:yes /update
   net stop w32time && net start w32time
   w32tm /resync
   ```

2. Verify status:

   ```powershell
   w32tm /query /status
   w32tm /query /peers
   ```

   ✅ Peers should show **State: Active** with `Stratum` ≥ 2.

### Linux Configuration (via Ansible)

1. Detect client:

   * Check for `chronyd`, `ntpd`, or `systemd-timesyncd`.
2. Configure `chrony` clients to sync with DC:

   * Example `/etc/chrony.conf`:

     ```
     server ws2022-dc.corp.local iburst
     driftfile /var/lib/chrony/drift
     makestep 1.0 3
     rtcsync
     ```
3. Restart chrony:

   ```bash
   systemctl restart chronyd
   chronyc sources -v
   ```

---

## Part C — Ansible Playbooks

### 1. Check Time Sync

File: `ansible/playbooks/check-timesync.yml`

```yaml
---
- name: Check time synchronization across fleet
  hosts: all
  gather_facts: yes
  tasks:
    - name: Check for chronyc binary
      command: which chronyc
      register: chronyc_bin
      ignore_errors: yes

    - name: Run chronyc tracking if available
      command: chronyc tracking
      when: chronyc_bin.rc == 0
      register: chronyc_tracking
      ignore_errors: yes

    - name: Show chrony output
      debug:
        var: chronyc_tracking.stdout_lines
      when: chronyc_tracking is defined
```

### 2. Fix Time Sync

File: `ansible/playbooks/fix-timesync.yml`

```yaml
---
- name: Configure chrony to sync with WS2022-DC
  hosts: all
  become: yes
  tasks:
    - name: Ensure chrony is installed
      package:
        name: chrony
        state: present

    - name: Backup existing chrony.conf
      copy:
        src: /etc/chrony.conf
        dest: /etc/chrony.conf.bak
        remote_src: yes
        force: yes
      ignore_errors: yes

    - name: Configure chrony.conf
      copy:
        dest: /etc/chrony.conf
        content: |
          server ws2022-dc.corp.local iburst
          driftfile /var/lib/chrony/drift
          makestep 1.0 3
          rtcsync

    - name: Restart chrony
      service:
        name: chronyd
        state: restarted

    - name: Verify chrony sources
      command: chronyc sources -v
      register: chrony_sources

    - debug:
        var: chrony_sources.stdout_lines
```

---

## Verification Checklist

* [x] Windows DC peers active with pool.ntp.org.
* [x] Linux servers registered in DNS forward/reverse zones.
* [x] `chronyc sources -v` shows WS2022-DC as reference.
* [x] `w32tm /query /status` shows sync without error.

---

## Notes

* If `chrony` install fails on RHEL/CentOS, confirm local repo server is online.
* For Ubuntu/Debian, disable `systemd-timesyncd` before enabling `chrony`.
* Keep one **authoritative clock** only — the Windows DC.

---

📌 **Storage Location Suggestion**
Commit this file as:

```
windows-server-2022/documentation/time-sync-runbook.md
```

