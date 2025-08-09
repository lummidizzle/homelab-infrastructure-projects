# CRB Reposync Battle-Scar Log

This document captures the troubleshooting journey of setting up and running a CRB reposync on `reposync.corp.local`.  
It includes the commands used, issues faced, fixes applied, and lessons learned.  
Yes — the struggle was real.  

---

## 📅 Timeline & Mission Log

### **2025-08-08 — 7:00 PM CST — First Attempt**
- **Objective:** Sync the CRB repository to `/var/repos/CRB` with full metadata and comps.
- **Initial Command:**
```bash
sudo reposync \
  --repoid=crb \
  --download-path=/var/repos/CRB \
  --downloadcomps \
  --download-metadata \
  --arch=x86_64 \
  --setopt=keepcache=1

