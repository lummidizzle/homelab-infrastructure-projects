#!/usr/bin/env bash
set -euo pipefail

# 1) include dir + basic commands file
install -d -m 0755 /etc/nagios/nrpe.d
cat >/etc/nagios/nrpe.d/10-basic.cfg <<'EOF'
# load
command[check_load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
command[load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
# root fs space
command[check_disk]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
command[rootspace]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
# processes + users
command[check_procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300
command[procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300
command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
EOF

# 2) belt-and-braces: also append to nrpe.cfg if not already present
if ! grep -q 'NRPE_BASIC_COMMANDS_BEGIN' /etc/nagios/nrpe.cfg ; then
  cat >>/etc/nagios/nrpe.cfg <<'EOF'

# NRPE_BASIC_COMMANDS_BEGIN (managed)
command[check_load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
command[load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
command[check_disk]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
command[rootspace]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
command[check_procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300
command[procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300
command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
# NRPE_BASIC_COMMANDS_END
EOF
fi

# 3) make sure nrpe.cfg references both dir and file
grep -qE '^include_dir=/etc/nagios/nrpe.d$' /etc/nagios/nrpe.cfg || echo 'include_dir=/etc/nagios/nrpe.d' >>/etc/nagios/nrpe.cfg
grep -qE '^include=/etc/nagios/nrpe.d/10-basic.cfg$' /etc/nagios/nrpe.cfg || echo 'include=/etc/nagios/nrpe.d/10-basic.cfg' >>/etc/nagios/nrpe.cfg

# 4) EL9 plugin path quirk: expose monitoring-plugins as nagios/plugins if needed
if [ -x /usr/lib64/monitoring-plugins/check_load ] && [ ! -e /usr/lib64/nagios/plugins/check_load ]; then
  install -d -m 0755 /usr/lib64/nagios/plugins
  ln -sf /usr/lib64/monitoring-plugins/check_* /usr/lib64/nagios/plugins/
fi

# 5) perms + SELinux
chown -R root:root /etc/nagios/nrpe.d
chmod 0755 /etc/nagios/nrpe.d
chmod 0644 /etc/nagios/nrpe.d/*.cfg
restorecon -Rv /etc/nagios /etc/nagios/nrpe.d >/dev/null || true

# 6) restart + quick sanity
systemctl restart nrpe
ss -ltpn | grep -E ":5666" || true
journalctl -u nrpe -n 30 --no-pager | egrep -i "open|denied|error|cfg" || true

