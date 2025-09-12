#!/usr/bin/env bash
set -euo pipefail

PKG_TGZ="${1:-/srv/repo/glpi-agent-offline.el9.tgz}"
shift || true

if [[ ! -f "$PKG_TGZ" ]]; then
  echo "ERR: package tarball not found: $PKG_TGZ" >&2
  exit 1
fi

if [[ "$#" -lt 1 ]]; then
  echo "Usage: $0 /path/to/glpi-agent-offline.el9.tgz host1 [host2 ...]" >&2
  exit 2
fi

for HOST in "$@"; do
  echo "==> Deploying to ${HOST}"
  scp -q "$PKG_TGZ" "${HOST}:/tmp/glpi-agent-offline.el9.tgz"

  ssh "$HOST" 'set -e
    sudo rm -rf /tmp/glpi-offline; mkdir -p /tmp/glpi-offline
    tar xzf /tmp/glpi-agent-offline.el9.tgz -C /tmp/glpi-offline
    cd /tmp/glpi-offline

    # belt & suspenders: strip any stray toolchain junk if present
    sudo rm -f gcc-* cpp-* annobin-* glibc-headers-* glibc-devel-* libxcrypt-devel-* \
               pkgconf-* perl-devel-* perl-ExtUtils-* redhat-rpm-config-* llvm-* clang-* \
               ncurses-*.el9_* 2>/dev/null || true

    sudo dnf -y localinstall ./*.rpm

    sudo install -d -m 0755 /etc/glpi-agent
    sudo tee /etc/glpi-agent/agent.cfg >/dev/null <<EOF
server = http://glpi.corp.local/front/inventory.php
tag = $(hostname -s)
logger = file
logfile = /var/log/glpi-agent.log
EOF

    sudo systemctl enable --now glpi-agent
    # first-shot forced inventory with verbose logs
    sudo glpi-agent --server http://glpi.corp.local/front/inventory.php --force --debug || true
  '

  echo "==> ${HOST}: done"
done

echo "All targets processed."

