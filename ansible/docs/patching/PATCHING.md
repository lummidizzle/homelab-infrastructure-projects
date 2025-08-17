# 🩹 Patching Framework — Homelab Ansible

This section documents how patching is managed across the lab environment using Ansible.  
The goal: **automated, repeatable, and scheduled OS patching with clear visibility.**

---

## 📑 Documentation
- [Patch Standards](./patch_std_rhel.md) – rules & compliance for RHEL patching  
- [Patching Schedule](./patching_schedule.md) – cadence and rollout strategy  

---

## 📂 Playbooks
- `ansible/patch-monthly.yml` – monthly patch run (all servers)  
- `ansible/patch-weekly-security.yml` – weekly security-only patch run  
- `ansible/controller-update.yml` – update controller node itself  

---

## ⚙️ Repo & Mirror Playbooks
- `ansible/playbooks/fix-repos-and-wire-rhel.yml` – ensure repos are wired correctly  
- `ansible/playbooks/health-check-rhel-repos.yml` – validate repo health  
- `ansible/playbooks/mirror-rocky.yml` – create Rocky Linux mirrors  
- `ansible/playbooks/patch-from-mirror.yml` – patch servers from internal mirror  
- `ansible/playbooks/repo-alias-publish.yml` – publish repo aliases  
- `ansible/playbooks/test-rocky-mirror.yml` – test Rocky mirror functionality  
- `ansible/repo-reset.yml` – reset repo configuration  

---

## 🎭 Roles
- `roles/patch_std/` – encapsulates patching logic  
- `roles/repo_reset/` – encapsulates repo reset logic  

---

## 📜 Helper Scripts
- `scripts-run-monthly.sh` – wrapper for monthly patch runs  
- `scripts-run-weekly-security.sh` – wrapper for weekly security patch runs  

---

## 🚀 Usage
- Trigger a patch run manually:  
  ```bash
  ansible-playbook ansible/patch-monthly.yml

