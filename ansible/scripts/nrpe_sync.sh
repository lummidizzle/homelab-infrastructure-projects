#!/usr/bin/env bash
set -euo pipefail

# 0) Make sure the include dir exists
install -d -m 0755 /etc/nagios/nrpe.d

# 1) Ensure nrpe.cfg will read the dir and the file
grep -qE '^\s*include_dir\s*=\s*/etc/nagios/nrpe\.d\s*$' /etc/nagios/nrpe.cfg \
  || echo 'include_dir=/etc/nagios/nrpe.d' >> /etc/nagios/nrpe.cfg

# 2) Make sure the monitoring hosts are allowed
if ! grep -qE '^\s*allowed_hosts=' /etc/nagios/nrpe.cfg; then
  echo 'allowed_hosts=127.0.0.1,::1,192.168.1.5,192.168.1.15' >> /etc/nagios/nrpe.cfg
else
  sed -i -E 's|^\s*allowed_hosts=.*$|allowed_hosts=127.0.0.1,::1,192.168.1.5,192.168.1.15|' /etc/nagios/nrpe.cfg
fi

# 3) Export the commands NRPE must serve (both legacy & check_* names)
cat >/etc/nagios/nrpe.d/10-basic.cfg <<'EOF'
# CPU load (either name works)
command[load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
command[check_load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5

# Processes
command[procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300
command[check_procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300

# Logged in users
command[users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10

# Root filesystem free space (names used by different templates)
command[rootspace]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
command[disk]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
command[check_disk]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
EOF

# 4) Permissions & SELinux
chown root:root /etc/nagios/nrpe.d /etc/nagios/nrpe.d/10-basic.cfg
chmod 0644 /etc/nagios/nrpe.d/10-basic.cfg
restorecon -Rv /etc/nagios/nrpe.d >/dev/null 2>&1 || true

# 5) Restart and show any errors that would prevent includes being read
systemctl restart nrpe
echo "---- NRPE quick status ----"
ss -ltnp | awk '$4 ~ /:5666$/'
journalctl -u nrpe -n 40 --no-pager | egrep -i 'open|include|cfg|error|denied' || true

