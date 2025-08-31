#!/usr/bin/env bash
set -euo pipefail

# 1) include dir
install -d -m 0755 /etc/nagios/nrpe.d
if ! grep -qE '^[[:space:]]*include_dir=/etc/nagios/nrpe.d$' /etc/nagios/nrpe.cfg; then
  if grep -qE '^[[:space:]]*#?[[:space:]]*include_dir=' /etc/nagios/nrpe.cfg; then
    sed -i 's|^[[:space:]]*#\?[[:space:]]*include_dir=.*$|include_dir=/etc/nagios/nrpe.d|' /etc/nagios/nrpe.cfg
  else
    echo 'include_dir=/etc/nagios/nrpe.d' >> /etc/nagios/nrpe.cfg
  fi
fi

# 2) canonical NRPE commands (include legacy aliases)
cat >/etc/nagios/nrpe.d/10-basic.cfg <<'EOF'
# load
command[load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
command[check_load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5

# disk (root filesystem)
command[disk]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
command[rootspace]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%

# processes
command[procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300
command[check_procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300

# users
command[users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
EOF

# 3) remove CRLF (if any) so NRPE sees the command names exactly
sed -i 's/\r$//' /etc/nagios/nrpe.d/*.cfg

# 4) perms + SELinux, then restart
chown root:root /etc/nagios/nrpe.d /etc/nagios/nrpe.d/*.cfg
chmod 0644 /etc/nagios/nrpe.d/*.cfg
restorecon -Rv /etc/nagios/nrpe.d || true

systemctl restart nrpe
sleep 1
# quick sanity
ss -ltnp | grep ':5666' || true
journalctl -u nrpe -n 20 --no-pager | egrep -i 'error|denied|cfg' || true

