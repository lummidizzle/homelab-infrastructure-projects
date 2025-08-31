#!/bin/bash
set -euo pipefail

# --- dirs ---------------------------------------------------------
install -d -m 0755 /etc/nagios/nrpe.d
install -d -m 0755 /usr/lib64/nagios/plugins || true

# --- include_dir in nrpe.cfg (idempotent) ------------------------
if ! grep -q '^include_dir=/etc/nagios/nrpe.d$' /etc/nagios/nrpe.cfg 2>/dev/null; then
  if grep -Eq '^[[:space:]]*#?[[:space:]]*include_dir=' /etc/nagios/nrpe.cfg 2>/dev/null; then
    sed -ri 's|^\s*#?\s*include_dir=.*$|include_dir=/etc/nagios/nrpe.d|' /etc/nagios/nrpe.cfg
  else
    echo 'include_dir=/etc/nagios/nrpe.d' >>/etc/nagios/nrpe.cfg
  fi
fi

# --- allowed_hosts (add both monitoring IPs) ---------------------
sed -ri 's|^\s*allowed_hosts\s*=.*$|allowed_hosts=127.0.0.1,::1,192.168.1.5,192.168.1.15|' /etc/nagios/nrpe.cfg

# --- commands: define both "check_*" and the short aliases -------
cat >/etc/nagios/nrpe.d/10-basic.cfg <<'EOF'
# CPU load
command[check_load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
command[load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5

# Disk: all mounts and root-only variants
command[check_disk]=/usr/lib64/nagios/plugins/check_disk -A -x tmpfs -x devtmpfs -X overlay -i /var/lib/containers -w 20% -c 10%
command[disk]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
command[rootspace]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%

# Processes
command[check_procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300
command[procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300

# Logged-in users
command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
EOF
chown root:root /etc/nagios/nrpe.d/10-basic.cfg
chmod 0644 /etc/nagios/nrpe.d/10-basic.cfg

# --- if only monitoring-plugins is present, expose it where NRPE expects
if [ -x /usr/lib64/monitoring-plugins/check_load ] && [ ! -x /usr/lib64/nagios/plugins/check_load ]; then
  ln -sf /usr/lib64/monitoring-plugins/check_* /usr/lib64/nagios/plugins/
fi

# --- SELinux contexts & restart ----------------------------------
restorecon -Rv /etc/nagios /usr/lib64/nagios || true
systemctl restart nrpe
sleep 1

# --- quick sanity -------------------------------------------------
egrep -H '^(include_dir|allowed_hosts)=' /etc/nagios/nrpe.cfg || true
egrep -H 'command\[(check_|load|disk|rootspace|procs|users)\]' /etc/nagios/nrpe.d/10-basic.cfg || true
ss -ltnp | awk '$4 ~ /:5666/ {print}'

