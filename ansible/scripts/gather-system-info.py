#!/usr/bin/env python3
"""
Collect quick system info for troubleshooting.
Outputs a simple YAML-like block to stdout.
"""

import os, platform, shutil, subprocess, sys, time

def run(cmd):
    try:
        out = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, text=True, timeout=10)
        return out.strip()
    except Exception as e:
        return f"ERROR: {e}"

info = {
    "hostname": run("hostname -f || hostname"),
    "kernel": platform.release(),
    "os_release": run("cat /etc/os-release || true"),
    "ip_addr": run("ip -4 addr show | awk '/inet /{print $2,$7}' || true"),
    "routes": run("ip route || true"),
    "dnf_available": shutil.which("dnf") is not None,
    "yum_available": shutil.which("yum") is not None,
    "repos": run("ls -1 /etc/yum.repos.d || true"),
    "firewall_ports": run("firewall-cmd --list-ports || true"),
    "http_8080": run("ss -lntp | awk '$4 ~ /:8080$/' || true"),
    "time": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
}

print("---")
for k, v in info.items():
    print(f"{k}: |")
    for line in str(v).splitlines():
        print(f"  {line}")

