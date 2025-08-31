#!/usr/bin/env bash
set -euo pipefail

# Write a clean command set
cat >/etc/nagios/nrpe.d/10-basic.cfg <<'EOF'
# Standard checks
command[check_load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[check_procs]=/usr/lib64/nagios/plugins/check_procs -w 300 -c 350

# Disk checks – provide BOTH names so Nagios 'disk' or 'rootspace' work
command[disk]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
command[rootspace]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
EOF

# Make sure the include_dir is present in nrpe.cfg
if ! grep -qE '^\s*include_dir\s*=\s*/etc/nagios/nrpe\.d\s*$' /etc/nagios/nrpe.cfg; then
  echo 'include_dir=/etc/nagios/nrpe.d' >> /etc/nagios/nrpe.cfg
fi

# Kill any old conflicting command lines so ours are authoritative
grep -RlE '^\s*command\[(rootspace|disk)\]=' /etc/nagios/nrpe.d \
  | grep -v '/10-basic.cfg$' | xargs -r sed -i '/^\s*command\[(rootspace|disk)\]=/d'

# Permissions + SELinux
chmod 0644 /etc/nagios/nrpe.d/10-basic.cfg
chown root:root /etc/nagios/nrpe.d/10-basic.cfg
restorecon -Rv /etc/nagios/nrpe.d >/dev/null || true

# Restart + quick sanity in logs
systemctl restart nrpe
journalctl -u nrpe -n 20 --no-pager | egrep -i 'open|denied|error|cfg' || true

