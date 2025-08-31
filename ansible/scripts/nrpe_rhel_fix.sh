#!/usr/bin/env bash
set -euo pipefail

# 1) ensure include dir + allow our monitoring IPs
sed -ri 's|^#?\s*include_dir=.*||g' /etc/nagios/nrpe.cfg
grep -q '^include_dir=/etc/nagios/nrpe.d$' /etc/nagios/nrpe.cfg || \
  echo 'include_dir=/etc/nagios/nrpe.d' >>/etc/nagios/nrpe.cfg

# (adjust IPs if yours differ)
sed -ri 's|^allowed_hosts=.*|allowed_hosts=127.0.0.1,::1,192.168.1.5,192.168.1.15|' /etc/nagios/nrpe.cfg

# 2) make the include dir and write one clean drop-in
install -d -m 0755 /etc/nagios/nrpe.d

cat >/etc/nagios/nrpe.d/10-basic.cfg <<'EOF'
# Basic NRPE commands (work on RHEL 9/10)
command[load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
command[users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300

# Disk checks (two names to satisfy old/new service defs)
# 'disk' – simple / filesystem
command[disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /
# 'rootspace' – legacy alias (kept for Nagios services still using it)
command[rootspace]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /
EOF

chown root:root /etc/nagios/nrpe.d/10-basic.cfg
chmod 0644 /etc/nagios/nrpe.d/10-basic.cfg

# 3) handle plugin path differences (EL sometimes uses monitoring-plugins)
if [[ ! -x /usr/lib64/nagios/plugins/check_load && -x /usr/lib64/monitoring-plugins/check_load ]]; then
  install -d -m 0755 /usr/lib64/nagios/plugins
  ln -sf /usr/lib64/monitoring-plugins/check_* /usr/lib64/nagios/plugins/
fi

# 4) SELinux context + restart
restorecon -Rv /etc/nagios/nrpe.d >/dev/null || true
systemctl restart nrpe

