#!/usr/bin/env bash
set -euo pipefail
TS=$(date +%F_%H-%M)
LOG="/var/log/ansible-patching/weekly_security_${TS}.log"
ansible-playbook -i inventories/hosts.ini patch-weekly-security.yml | tee -a "$LOG"
