# Alerting & Reporting — Monitoring Integration

## Philosophy
Alert on human-actionable items. Everything else is a report.

## Core Alert Groups
### Availability & Health
- rsyslog down (clients + hub)
- Hub queue/backlog high
- Disk usage high on hub
- Log freshness stale per host/stream

### Security Signal (SIEM-lite)
- SSH failure burst (N in M minutes)
- Repeated sudo failures (K in T minutes)
- Audit denial spikes

### Hygiene
- Time sync drift
- Unexpected volume spikes (top talkers)

## Starting Thresholds (tune later)
- Freshness: WARN 10m, CRIT 30m
- Queue backlog: WARN >5m sustained, CRIT >15m
- Disk: WARN 75%, CRIT 85%
- SSH failures: WARN ≥10/3m, CRIT ≥25/5m
- Sudo failures: WARN ≥3/10m, CRIT ≥6/15m
- Time drift: WARN >60s, CRIT >180s

## Notifications
- SMTP via 192.168.1.18
- Routing: ops@ for availability; secops@ for auth/audit
- Escalation: WARN email; CRIT page (if/when paging exists)

## Reports (not alerts)
- Weekly security digest (SSH/sudo/audit)
- Weekly ops digest (top talkers, recurring errors, disk trend)
- Monthly compliance (retention, restore drill, access audit)

## Tuning Notes (living)
- Record where noise was reduced and why (include before/after)
## Maintenance Windows
- Suppress non-critical alerts during planned work
