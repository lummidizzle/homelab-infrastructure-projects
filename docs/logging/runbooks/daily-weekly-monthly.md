# Logging Runbooks — Daily / Weekly / Monthly

## Daily (5–10 min)
- Nagios clean for rsyslog (clients + hub)
- Freshness: today's `auth` and `messages` updating across all hosts
- Hub disk in green; no noisy outliers
- Quick scan for repeated SSH failures / sudo denials

## Weekly (15–30 min)
- Trends: top SSH failure sources; repeated sudo failures; chatty hosts by stream
- Queue health: no sustained backlogs/drops
- Rotation sanity: new `.gz` appeared for last week as expected
- Note anomalies in `docs/logging/alerts.md` (Tuning Notes)

## Monthly (30–45 min)
- Cold restore drill: random host/day; verify readability
- Retention audit: hot (90d), cold (6–12m)
- Access audit: who can read the shares?
- Time sync audit; cert hygiene (if TLS)
- Update runbook with lessons

## Incident Quick-Play
1. Scope: host/stream/time window
2. Time sanity (NTP/Chrony)
3. Network path (ACL/VLAN)
4. Identity (hostname/PTR)
5. Queues (backlog vs smooth)
6. Disk & rotation
7. Filters too tight?
8. Policy blocks (SELinux/AppArmor)
9. Change history

## Maintenance Windows
- Batch changes; pause noisy alerts; verify after
## Backups & Restore — “Good”
- Nightly job captured last week’s `.gz` to backup
- Monthly restore succeeded
- Investigate checksum/size drift
## SMTP & Notifications
- Relay: 192.168.1.18
- WARN = email; CRIT = escalate
## Living Docs
- Update when streams, retention, thresholds, or hostnames change
