# DOMAIN HARDENING MEGA SCRIPT v2.0 (Plaintext version)

Import-Module GroupPolicy

# Get Domain DN
$domain = (Get-ADDomain).DistinguishedName

# LOGIN BANNER
Write-Output "Setting login banner..."
Set-GPRegistryValue -Name "GPO - Server Hardening" `
-Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
-ValueName "legalnoticecaption" -Type String -Value "AUTHORIZED ACCESS ONLY"

Set-GPRegistryValue -Name "GPO - Server Hardening" `
-Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
-ValueName "legalnoticetext" -Type String -Value "This system is for authorized users only. Activity may be monitored."

# AUDITING POLICIES
Write-Output "Enabling audit policies..."
Set-GPRegistryValue -Name "GPO - Admin Restrictions" `
-Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" `
-ValueName "SCENoApplyLegacyAuditPolicy" -Type DWord -Value 0

AuditPol /set /category:"Logon/Logoff" /success:enable /failure:enable
AuditPol /set /category:"Account Logon" /success:enable /failure:enable
AuditPol /set /category:"Object Access" /success:enable /failure:enable

# NTP SYNC
Write-Output "Configuring time synchronization..."
w32tm /config /syncfromflags:domhier /update
net stop w32time
net start w32time
w32tm /resync

# GPO BACKUP
Write-Output "Backing up all GPOs..."
$backupPath = "C:\GPO-Backups"
New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

Get-GPO -All | ForEach-Object {
    Backup-GPO -Name $_.DisplayName -Path $backupPath -Comment "Backup on $(Get-Date -Format yyyy-MM-dd_HH-mm-ss)"
}

Write-Output "All tasks complete. GPOs backed up to $backupPath"
