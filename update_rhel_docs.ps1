# Define README content for RHEL 9
$rhel9Content = @"
# RHEL 9 Server Build

**Hostname**: `rhel9.corp.local`  
**IP Address**: `192.168.1.11`  
**Build Date**: July 24, 2025

## Key Tasks Completed
- Installed latest RHEL 9 ISO on VM
- Set static IP: `192.168.1.11`
- Configured hostname: `rhel9.corp.local`
- Added host to local DNS
- Performed `dnf update` and installed essential packages
- Enabled OpenSSH and verified SSH access
- Set up user accounts and applied basic hardening
- Captured initial snapshots
"@

# Define README content for RHEL 10
$rhel10Content = @"
# RHEL 10 Server Build

**Hostname**: `rhel10.corp.local`  
**IP Address**: `192.168.1.12`  
**Build Date**: July 24, 2025

## Key Tasks Completed
- Installed RHEL 10 pre-release ISO
- Set static IP: `192.168.1.12`
- Configured hostname: `rhel10.corp.local`
- Performed full system update with `dnf`
- Enabled OpenSSH and verified remote login
- Created service accounts for future automation
- Applied custom hardening policies
- Snapshots taken for rollback baseline
"@

# Paths
$rhel9Path = "D:\GitHub\homelab-infrastructure-projects\rhel9\README.md"
$rhel10Path = "D:\GitHub\homelab-infrastructure-projects\rhel10\README.md"

# Overwrite content
$rhel9Content | Set-Content -Path $rhel9Path -Encoding UTF8
$rhel10Content | Set-Content -Path $rhel10Path -Encoding UTF8

# Git commands to stage, commit, and push
Set-Location -Path "D:\GitHub\homelab-infrastructure-projects"
git add rhel9/README.md rhel10/README.md
git commit -m "Updated README.md for RHEL 9 and RHEL 10 builds with detailed documentation"
git push origin main
