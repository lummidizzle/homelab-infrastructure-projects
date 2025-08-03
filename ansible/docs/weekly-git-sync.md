# 🗓️ Weekly GitHub Auto Sync Setup

This document explains how to create a scheduled Git sync process that automatically commits and pushes local changes from your Ansible infrastructure project to your GitHub repository once a week.

> 📍 **Location of Script:** `/usr/local/bin/weekly-git-sync.sh`

---

## ✅ Objective

Ensure that project changes are regularly committed and pushed to GitHub to maintain up-to-date documentation and Ansible configurations without manual effort.

---

## 📦 Step-by-Step Setup

### 1. Create the Git Sync Script

```bash
sudo vi /usr/local/bin/weekly-git-sync.sh
```

### 2. Paste the Script Below

```bash
#!/bin/bash

# =============================
# Weekly GitHub Sync Script
# Author: Olumide ✨
# =============================

PROJECT_DIR="$HOME/homelab-infrastructure-projects"
cd "$PROJECT_DIR" || { echo "❌ Project directory not found!"; exit 1; }

echo "🔍 Checking for changes in $PROJECT_DIR..."

git add .
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
git commit -m "🗓️ Weekly sync: auto-commit on $timestamp"
git push origin main

echo "✅ Weekly sync complete at $timestamp."
```

### 3. Make it Executable

```bash
sudo chmod +x /usr/local/bin/weekly-git-sync.sh
```

---

## 🧪 Manual Test (Optional)

Run it manually to verify:
```bash
/usr/local/bin/weekly-git-sync.sh
```

If changes exist, they will be committed and pushed. You’ll be prompted for your GitHub credentials unless you're using a PAT (Personal Access Token) or SSH.

---

## 📅 Automate with Cron

### 1. Open the Cron Tab
```bash
crontab -e
```

> ⚠️ If you get `No such file or directory`, create the `.cache` directory:
```bash
mkdir -p /home/oluadmin/.cache/cron
```
Then retry `crontab -e`.

---

### 2. Add the Cron Schedule

```cron
0 9 * * 5 /usr/local/bin/weekly-git-sync.sh >> ~/git-sync.log 2>&1
```

📌 This means:
- Runs **every Friday at 9:00 AM**
- Logs output to `~/git-sync.log`

---

## 🐛 Common Issues & Fixes

| Issue | Fix |
|------|-----|
| `fatal: Authentication failed` | Use a GitHub **PAT** instead of password. Set up credential caching or use SSH. |
| `No such file or directory: .cache/cron` | Run: `mkdir -p /home/oluadmin/.cache/cron` |
| Script doesn't run | Confirm path is correct and script is executable with `chmod +x` |

---

## 🔒 GitHub Authentication Note

GitHub **no longer supports passwords** for Git. You must use:

1. A **Personal Access Token (PAT)** OR  
2. Configure **SSH keys** for authentication

Use `git config --global credential.helper store` to save credentials **once**.

---

## 🧼 Logs

Check the sync log anytime:
```bash
cat ~/git-sync.log
```

---

## ✅ Status Check (Recommended)

Before pushing manually, you can always check:
```bash
git status
```

---

## ✅ Outcome

You now have a reliable method to:
- Auto-commit any weekly changes
- Push them to GitHub
- Keep all documentation and playbooks version-controlled

---

