# GLPI — Agent Rollout, Cleanup, and Verification (EL9 + Ubuntu)

This guide captures the exact steps we used in lab to **install**, **clean up**, and **verify** GLPI agent inventory on **EL9 (Rocky/Alma/RHEL)** and **Ubuntu** systems.  
It includes reusable scripts, sample configs, and screenshots for clarity.

---

## 📌 Scope
- **EL9 / Rocky / Alma / RHEL** → offline `dnf localinstall` from pre-built tgz bundle  
- **Ubuntu** → install from `.deb` package or official repo  
- **Cleanup** → undo repo chaos after failed experiments on `dns-nfs` and siblings  

---

## ⚙️ Prereqs & Assumptions
- GLPI server is running: `https://glpi.corp.local/`
- Inventory endpoint: `https://glpi.corp.local/front/inventory.php`
- You can SSH as a sudoer on each target
- Time is in sync (NTP) → otherwise GLPI timestamps will be misleading

---

## 🌍 Server URLs
- **Web UI**: `https://glpi.corp.local/`
- **Inventory endpoint**: `https://glpi.corp.local/front/inventory.php`

---

## 📦 EL9 Offline Install (Reusable Script)

**Location in repo:**
scripts/glpi/install_glpi_agent_el9.sh
srv/repo/glpi-agent-offline.el9.tgz


**Usage**
```bash
# Run from control box
sudo bash scripts/glpi/install_glpi_agent_el9.sh \
  /srv/repo/glpi-agent-offline.el9.tgz <host1> [host2 ...]

Script workflow

Copies tarball → /tmp/glpi-agent-offline.el9.tgz

Extracts to /tmp/glpi-offline

Removes stray RPMs

Runs dnf -y localinstall ./*.rpm

Writes /etc/glpi-agent/agent.cfg

Enables + starts glpi-agent

Forces an inventory (--debug)

🐧 Ubuntu Install

Option A — Local .deb

sudo apt update
sudo apt -y install curl ca-certificates
sudo dpkg -i glpi-agent_*_amd64.deb || sudo apt -f -y install
sudo systemctl enable --now glpi-agent


Option B — Official repo

curl -fsSL https://packages.glpi-project.org/glpi-agent/deb/glpi-agent-repo.gpg \
 | sudo gpg --dearmor -o /usr/share/keyrings/glpi-agent-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/glpi-agent-archive-keyring.gpg] \
https://packages.glpi-project.org/glpi-agent/deb/ stable main" \
| sudo tee /etc/apt/sources.list.d/glpi-agent.list

sudo apt update
sudo apt -y install glpi-agent
sudo systemctl enable --now glpi-agent

📝 Agent Config

File: /etc/glpi-agent/agent.cfg

[http]
server = https://glpi.corp.local/front/inventory.php
# deviceid = <short-hostname>

[logger]
logger = file
logfile = /var/log/glpi-agent.log

[ssl]
# For lab self-signed certs:
# ca_cert_file = /etc/pki/ca-trust/source/anchors/corp-rootCA.pem
# verify_mode = 0

🚀 Forcing Inventory + Checking Logs

EL9

sudo dnf clean all
sudo rm -rf /var/cache/dnf
sudo dnf --disablerepo='*' \
  --enablerepo=baseos-local,appstream-local,crb-local,epel-local \
  makecache

Ubuntu
sudo apt update
sudo apt -y --fix-broken install

🛠 Troubleshooting

Agent missing in GLPI

Check /var/log/glpi-agent.log

Verify URL in config

Ensure hostname uniqueness (GLPI merges duplicates)

RPM dependency loops (EL9)

Bundle missing deps → rebuild tgz with all needed RPMs

dpkg errors (Ubuntu)

Run sudo apt -f -y install

SSL issues

Import CA or temporarily set verify_mode = 0 in agent.cfg
