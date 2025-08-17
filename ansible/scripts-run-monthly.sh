#!/usr/bin/env bash
set -euo pipefail
TS=$(date +%F_%H-%M)
LOG="/var/log/ansible-patching/monthly_${TS}.log"
ansible-playbook -i inventories/hosts.ini patch-monthly.yml | tee -a "$LOG"
