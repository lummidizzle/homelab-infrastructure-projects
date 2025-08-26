# Logging Taxonomy & Folder Schema

## 1) Streams We Care About
| Category        | Stream (typical name) | Why it matters                                      | Notes |
|-----------------|-----------------------|------------------------------------------------------|-------|
| Security Core   | `auth`, `authpriv`    | Logins, SSH failures, PAM auth paths                 | High signal for intrusion attempts |
|                 | `sudo`                | Privilege elevation attempts and outcomes            | Track misuse/abuse patterns |
|                 | `audit`               | File access, policy events, AVCs, system calls       | Forensics + compliance trace |
| Ops Core        | `messages` / `syslog` | Kernel + system messages, service failures           | Broad health & crash clues |
|                 | `cron`                | Scheduled job successes/failures                     | Detect broken automation |
| Change/Patching | `dnf` / `apt`         | Package installs, updates, removals                  | Change history for RCA |

## 2) Facilities & Severities (mental map)
- **Facilities (examples):** `auth`, `authpriv`, `daemon`, `kern`, `cron`, `user`, `local0-7`
- **Severities (0–7):**
  0 Emergency · 1 Alert · 2 Critical · 3 Error · 4 Warning · 5 Notice · 6 Informational · 7 Debug

## 3) Folder Schema & Naming
**Root:** `/var/log/corp/`
**Pattern:** `/var/log/corp/<hostname>/<stream>.log`
**Rotated:** `/var/log/corp/<hostname>/<stream>.log-YYYYMMDD` and then `.gz` after 7 days

Examples:

/var/log/corp/ansible.corp.local/auth.log
/var/log/corp/monitoring.corp.local/messages.log
/var/log/corp/security.corp.local/audit.log-20250818.gz

## 4) Rotation & Retention
- **Rotation:** daily
- **Compression:** after day 7
- **Hot retention on hub:** 90 days (compressed beyond day 7)
- **Cold retention on backup:** 6–12 months compressed

## 5) Metadata We Preserve
- Original timestamp, hostname, program (tag), PID (if present), facility.severity

## 6) Host Identity Rules
- FQDN must be stable and resolvable both ways (A + PTR). If a hostname changes, document the date.

## 7) Size & Growth Guardrails (rough)
- Per host: ~30–80 MB/day (uncompressed) for core streams
- ~10 hosts ⇒ 0.3–0.8 GB/day hot; ~13–36 GB compressed for 90 days (very rough)
