#!/bin/bash
echo "=== $(hostname) ==="
hostnamectl
ip -br a
df -h --output=source,fstype,size,used,avail,pcent,target
free -h
cat /etc/redhat-release 2>/dev/null || cat /etc/os-release
sudo firewall-cmd --list-all || true

