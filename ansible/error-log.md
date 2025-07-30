# 🐞 Errors & Fixes - Ansible Setup Day 1–2

## ❌ Git Commit Failed: Author Identity Unknown

**Error:**
```bash
fatal: empty ident name (for <oluadmin@ansible.corp.local>) not allowed
```

**Fix:**
```bash
git config --global user.name "Olumide Familusi"
git config --global user.email "lummyfam@gmail.com"
```

---

## ❌ Git Push Failed: Authentication

**Error:**
```bash
remote: Invalid username or token. Password authentication is not supported
```

**Fix:**
- Use **Personal Access Token (PAT)** instead of your password.
- Username should be your **GitHub username**, e.g. `lummydizzle`

---

## ✅ Resolution
- Git push now successful to:  
  `https://github.com/lummydizzle/homelab-infrastructure-projects`

