#!/usr/bin/env bash
set -euo pipefail

# 1) Make sure /etc/nagios/nrpe.d exists and is included
install -d -m 0755 /etc/nagios/nrpe.d
grep -qE '^\s*include_dir\s*=\s*/etc/nagios/nrpe\.d\s*$' /etc/nagios/nrpe.cfg \
  || echo 'include_dir=/etc/nagios/nrpe.d' >> /etc/nagios/nrpe.cfg

# 2) Provide the rootspace alias (Nagios service calls this name)
cat >/etc/nagios/nrpe.d/99-rootspace.cfg <<'CFG'
command[rootspace]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
CFG
chown root:root /etc/nagios/nrpe.d/99-rootspace.cfg
chmod 0644 /etc/nagios/nrpe.d/99-rootspace.cfg

# 3) SELinux label + restart
restorecon -Rv /etc/nagios/nrpe.d >/dev/null 2>&1 || true
systemctl restart nrpe

