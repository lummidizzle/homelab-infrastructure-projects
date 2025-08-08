# Homelab Repo Server Sync – Three Days of Pain, Growth & Automation (2025-08-06 → 2025-08-08)

## **Context**
The goal of this phase was to:
1. Set up a **central repo server** (`reposync.corp.local`) that syncs package repositories to a mounted storage location on **HP2**.
2. Automate the sync process with a **bash script** and cron jobs.
3. Ensure **RHEL and Ubuntu servers** can pull updates from this repo.
4. Integrate automation via **Ansible playbooks** for Ubuntu update scheduling.

---

## **🗓 Timeline**

### **Day 1 – 2025-08-06: Initial Sync Attempts**
**Objective:** Mount the HP2 network share and run the rsync script.

**Mount Command Used (initial attempt):**
```bash
sudo mount -t cifs //192.168.1.236/repo-server-rhel9 /mnt/hp2-repo \
-o username=oluadmin,password=xxxx,vers=3.0,rw,dir_mode=0777,file_mode=0777

