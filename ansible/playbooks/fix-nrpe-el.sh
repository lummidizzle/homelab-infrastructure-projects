#!/usr/bin/env bash
set -euo pipefail

# 1) include dir + allowed_hosts
install -d -m 0755 /etc/nagios/nrpe.d
if grep -q '^[[:space:]]*#\?include_dir[[:space:]]*=' /etc/nagios/nrpe.cfg; then
  sed -ri 's|^[[:space:]]*#?[[:space:]]*include_dir=.*$|include_dir=/etc/nagios/nrpe.d|' /etc/nagios/nrpe.cfg
else
  echo 'include_dir=/etc/nagios/nrpe.d' >> /etc/nagios/nrpe.cfg
fi
sed -ri 's|^[[:space:]]*allowed_hosts=.*$|allowed_hosts=127.0.0.1,::1,192.168.1.5,192.168.1.15|' /etc/nagios/nrpe.cfg

# 2) commands file – provide both old and new names
cat >/etc/nagios/nrpe.d/10-basic.cfg <<'EOF'
# CPU load
command[check_load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
command[load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5

# Root filesystem space
command[check_disk]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
command[rootspace]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%

# Processes
command[check_procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300
command[procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300

# Logged-in users
command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
EOF
chmod 0644 /etc/nagios/nrpe.d/10-basic.cfg

# 3) EL9: expose plugins under the expected path
if [ ! -x /usr/lib64/nagios/plugins/check_load ] && [ -x /usr/lib64/monitoring-plugins/check_load ]; then
  install -d -m 0755 /usr/lib64/nagios/plugins
  ln -sf /usr/lib64/monitoring-plugins/check_* /usr/lib64/nagios/plugins/
fi

# 4) SELinux & restart
command -v restorecon >/dev/null 2>&1 && restorecon -Rv /etc/nagios/nrpe.d || true
systemctl restart nrpe

# 5) quick sanity
egrep -H '^(include_dir|allowed_hosts)=' /etc/nagios/nrpe.cfg || true
egrep -H 'command\[(check_load|load|rootspace|procs|users)\]' /etc/nagios/nrpe.d/10-basic.cfg || true
ss -ltnp | grep ':5666 ' || true
journalctl -u nrpe -n 5 --no-pager || true

