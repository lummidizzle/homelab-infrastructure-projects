# Central Logging Architecture (rsyslog + Nginx + Nagios + Backup)

## 1) Purpose (why this exists)
Make `syslog.corp.local` the single, reliable source of truth for operational and security logs across the fleet. Off-box evidence, fast triage, predictable retention, and simple restore—without a heavyweight SIEM.

## 2) Roles & Hosts
- **syslog.corp.local** — rsyslog hub + Nginx (read-only log browser)
- **monitoring.corp.local** — Nagios Core (alerts from log freshness, rsyslog health, disk, auth anomalies)
- **backup.corp.local** — long-term, compressed log archives (cold storage)

> Design constraint: limited CPU/RAM across the lab. Keep it lean, durable, and auditable.

## 3) High-Level Flow
1. **Producers (all servers)** write logs locally (journald/rsyslog) and **forward selected streams** to the hub.
2. **Hub (syslog)** receives, tags (host/app/severity), and **stores per-host/per-stream** under a consistent folder schema; rotates and compresses on schedule.
3. **Monitoring** reads health signals and log freshness to raise alerts.
4. **Backup** regularly copies **compressed** logs (7+ days old) for long-term retention.
5. **Nginx** provides a **read-only web view** (auth-protected) over the hub’s log tree for quick, frictionless triage.

## 4) What Nginx Does (and doesn’t)
- **Does:** Serve a read-only directory listing of `/var/log/corp/...` behind basic auth; optionally host a minimal “Ops Home” page linking common views and docs.
- **Doesn’t:** Load balance, terminate syslog ingestion, or sit in the logging data path. Syslog uses its own TCP/TLS ports directly.

## 5) Data Taxonomy (what we collect)
See `docs/logging/taxonomy.md` for full details. In short:
- **Security core:** auth/authpriv, sudo, audit
- **Ops core:** messages/syslog, cron
- **Change/patching:** package manager activity (dnf/apt)
- **Optional app logs**: only when they matter and won’t blow up storage

## 6) Storage & Retention
- **Hub (hot):** 90 days of logs, **compressed after day 7**
- **Backup (cold):** 6–12 months compressed, mirrored folder structure
- **Folder schema:** `/var/log/corp/<hostname>/<stream>.log` (with rotated `.gz`)

> Rule: prefer structure and predictability over “we’ll remember later.” Future you is busy; help them.

## 7) Transport & Security (conceptual)
- **Transport:** Reliable TCP/RELP; prefer TLS where feasible
- **Access:** Allow-list clients to rsyslog ingest port(s)
- **Identity:** Stable hostnames + working forward & reverse DNS
- **Permissions:** Logs readable by operators, writable by rsyslog; protect archives
- **Time:** All hosts synced (NTP/Chrony). Bad clocks = ghost logs.

## 8) Monitoring Signals (what we care about)
- rsyslog service up (clients + hub)
- rsyslog **queue/backlog** within thresholds (no drops)
- **Log freshness** per host/stream (no stale files)
- **Disk usage** on hub (warn/crit)
- **Security patterns:** SSH failure bursts, sudo failures
- **Noisy talkers:** unexpected volume spikes

## 9) Backup Strategy (conceptual)
- Copy **only compressed** (`*.gz`) logs ≥7 days old from hub to `backup.corp.local`
- Maintain mirrored paths by host/stream/date
- Monthly **cold restore drill**: pick a random host/day; verify integrity and readability

## 10) Resource Guardrails (lean is life)
- **syslog.corp.local:** 2 vCPU, 4–6 GB RAM, ≥200 GB disk (growable)
- **monitoring.corp.local:** 2 vCPU, 2–4 GB RAM, small disk
- **backup.corp.local:** 2 vCPU, 2–4 GB RAM, big cheap disk
- If starved: give **disk** to syslog, **RAM** to monitoring, **capacity** to backup

## 11) Acceptance Criteria (end-to-end)
- Every host’s `auth/messages/audit/cron/package` appears on the hub within ~2 minutes during normal ops
- Nginx shows the tree read-only behind auth
- Nagios alerts on: rsyslog down, stale logs, queue backlog, disk thresholds, SSH bursts, sudo failures
- Nightly archives land on backup; monthly restore passes
- Docs match reality (update when anything changes)

## 12) Future Options (when resources allow)
- **Loki/Grafana** (lighter search, still wants RAM)
- **Graylog / OpenSearch** (heavier; save for later)
- **SaaS** (offload compute/storage entirely)
