#!/usr/bin/env bash
# Cleanup old repo metadata and caches safely.

set -euo pipefail

LOG_DIR="/var/log/homelab"
LOG_FILE="${LOG_DIR}/cleanup-repo.log"
TS="$(date -Is)"

mkdir -p "${LOG_DIR}"

echo "[$TS] starting cleanup-repo" | tee -a "${LOG_FILE}"

# Detect dnf vs yum
if command -v dnf >/dev/null 2>&1; then
  PKG="dnf"
elif command -v yum >/dev/null 2>&1; then
  PKG="yum"
else
  echo "No dnf/yum found" | tee -a "${LOG_FILE}"
  exit 1
fi

# Clean metadata & caches
sudo "${PKG}" clean all | tee -a "${LOG_FILE}"

# Optionally prune old reposync temp dirs (conservative)
find /var/tmp -maxdepth 1 -type d -name "reposync-*" -mtime +7 -print0 | xargs -0r rm -rf

echo "[$TS] cleanup-repo complete" | tee -a "${LOG_FILE}"

