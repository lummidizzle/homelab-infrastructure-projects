# GLPI Agent — Offline Rollout (EL9 + Ubuntu)

> WIP document. Screenshots go in `assets/screenshots/glpi/`. This guide captures the exact steps we used in lab to install, clean up, and verify GLPI agent inventory.

## Scope
- **EL9/Rocky/CentOS Stream 9**: Offline `dnf localinstall` from pre-built tgz bundle.
- **Ubuntu**: Install from `.deb` or official repo (notes below).
- **Cleanup**: Undo repo chaos on `dns-nfs` (and siblings) after experiments.

---

## EL9 Offline Install (Reusable Script)
We wrapped the one-liner block into a script:

scripts/glpi/install_glpi_agent_el9.sh /srv/repo/glpi-agent-offline.el9.tgz <host1> [host2 ...]


What it does:
- Copies the tarball to target: `/tmp/glpi-agent-offline.el9.tgz`
- Extracts to `/tmp/glpi-offline`
- Removes stray build tool RPMs if present
- `dnf -y localinstall ./*.rpm`
- Writes `/etc/glpi-agent/agent.cfg`
- Enables + starts `glpi-agent`
- Sends a forced inventory with `--debug`

**Agent config:**
```ini
server = http://glpi.corp.local/front/inventory.php
tag = <short-hostname>
logger = file
logfile = /var/log/glpi-agent.log

