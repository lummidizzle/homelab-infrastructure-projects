#!/bin/bash
set -euo pipefail

PLUG=/usr/lib64/nagios/plugins
DIR=/etc/nagios/nrpe.d
CFG=/etc/nagios/nrpe.cfg
BASIC=$DIR/10-basic.cfg

# 1) ensure include dir and file are loaded
install -d -m 0755 "$DIR"
grep -q '^include_dir=/etc/nagios/nrpe.d$' "$CFG" || echo 'include_dir=/etc/nagios/nrpe.d' >> "$CFG"
grep -qE '^\s*include\s*=\s*/etc/nagios/nrpe\.d/10-basic\.cfg$' "$CFG" || echo 'include=/etc/nagios/nrpe.d/10-basic.cfg' >> "$CFG"

# 2) write one canonical command file with both "modern" and "legacy" names
cat > "$BASIC" <<'EOF'
# All aliases resolve to the same plugins/thresholds
command[load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5
command[check_load]=/usr/lib64/nagios/plugins/check_load -r -w 5,4,3 -c 7,6,5

command[rootspace]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%
command[disk_free]=/usr/lib64/nagios/plugins/check_disk -p / -w 20% -c 10%

command[procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300
command[check_procs]=/usr/lib64/nagios/plugins/check_procs -w 250 -c 300

command[users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
command[check_users]=/usr/lib64/nagios/plugins/check_users -w 5 -c 10
EOF
chown root:root "$BASIC"; chmod 0644 "$BASIC"

# 3) if plugins live under monitoring-plugins, expose them under nagios/plugins
if [ ! -x "$PLUG/check_load" ] && [ -x /usr/lib64/monitoring-plugins/check_load ]; then
  install -d -m 0755 "$PLUG"
  ln -sf /usr/lib64/monitoring-plugins/check_* "$PLUG"/
fi

# 4) SELinux labels (quiet if setenforce=0)
restorecon -Rv /etc/nagios/nrpe.d || true

# 5) restart
systemctl restart nrpe
exit 0

