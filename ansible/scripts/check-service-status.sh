#!/usr/bin/env bash
# Quick status for repo HTTP and cron timers.

set -euo pipefail

SERVICES=(
  "firewalld"
  "crond"
)

TIMERS=(
  "reposync.timer"
)

SOCKETS=(
  "cockpit.socket"
)

echo "== Services =="
for s in "${SERVICES[@]}"; do
  systemctl is-active --quiet "$s" && state=active || state=inactive
  printf "%-20s %s\n" "$s" "$state"
done

echo -e "\n== Timers =="
for t in "${TIMERS[@]}"; do
  systemctl list-timers --all | grep -E "^\s*.*\s$ t" || echo "$t not found"
done

echo -e "\n== Sockets =="
for so in "${SOCKETS[@]}"; do
  systemctl is-active --quiet "$so" && state=active || state=inactive
  printf "%-20s %s\n" "$so" "$state"
done

echo -e "\n== Firewalld 8080 =="
if firewall-cmd --quiet --list-ports | grep -q '\<8080/tcp\>'; then
  echo "8080/tcp open"
else
  echo "8080/tcp CLOSED"
fi

