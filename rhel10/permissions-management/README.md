# 🔐 Phase 2: Permissions & Ownership (RHEL10)

## 🧰 Topics Covered

- `chmod`, `chown`, `chgrp`
- Numeric vs symbolic permission modes
- Special bits: SUID, SGID, Sticky Bit

---

## 📜 Script: `permissions_test_setup.sh`

Creates:
- `/tmp/phase2test/`
- Files with various permission settings
- Applies:
  - SUID on `suidfile`
  - SGID on `sgidfile`
  - Sticky Bit on `stickyfile` and `testdir`

---

## 🧪 Commands Used

```bash
chmod 600 testfile.txt
chmod u=rwx,g=rx,o=r testfile.txt
chmod +x testfile.txt

chown oluadmin:wheel testfile.txt

chmod u+s suidfile
chmod g+s sgidfile
chmod +t stickyfile
chmod +t testdir
