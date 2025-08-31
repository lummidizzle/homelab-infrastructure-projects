#!/usr/bin/env bash
set -euo pipefail

# Make sure the EL9 plugin path is visible as nagios/plugins
if [ -x /usr/lib64/monitoring-plugins/check_disk ] && [ ! -e /usr/lib64/nagios/plugins/check_disk ]; then
  install -d -m 0755 /usr/lib64/nagios/plugins
  ln -sf /usr/lib64/monitoring-plugins/check_* /usr/lib64/nagios/plugins/
fi

# Remove any old/incorrect rootspace definitions (in nrpe.cfg or any *.cfg)
sed -i -E '/^command\[rootspace\]=/d' /etc/nagios/nrpe.cfg /etc/nagios/nrpe.d/*.cfg 2>/dev/null || true

# Write the correct one (tweak thresholds if you like)
install -d -m 0755 /etc/nagios/nrpe.d
grep -qE '^command\[rootspace\]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%$' /etc/nagios/nrpe.d/10-basic.cfg || \
  echo 'command[rootspace]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%' >> /etc/nagios/nrpe.d/10-basic.cfg

# Ensure the file is actually included
grep -q '^include=/etc/nagios/nrpe.d/10-basic.cfg$' /etc/nagios/nrpe.cfg || \
  echo 'include=/etc/nagios/nrpe.d/10-basic.cfg' >> /etc/nagios/nrpe.cfg

# Permissions/labels and restart
chown -R root:root /etc/nagios/nrpe.d
chmod 0644 /etc/nagios/nrpe.d/*.cfg
restorecon -Rv /etc/nagios /etc/nagios/nrpe.d >/dev/null || true
systemctl restart nrpe

