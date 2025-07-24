Import-Module GroupPolicy

# Get domain info
$domain = (Get-ADDomain).DistinguishedName

# Define GPOs and their target OUs
$gpos = @(
    @{ Name = "GPO - Server Hardening"; OU = "OU=Servers,$domain" },
    @{ Name = "GPO - Workstation Restrictions"; OU = "OU=Workstations,$domain" },
    @{ Name = "GPO - Admin Restrictions"; OU = "OU=Admins,$domain" },
    @{ Name = "GPO - Service Account Policy"; OU = "OU=ServiceAccounts,$domain" }
)

# Create and link GPOs
foreach ($gpo in $gpos) {
    if (-not (Get-GPO -Name $gpo.Name -ErrorAction SilentlyContinue)) {
        New-GPO -Name $gpo.Name
        Write-Output "Created GPO: $($gpo.Name)"
    }
    New-GPLink -Name $gpo.Name -Target $gpo.OU -Enforced $false
    Write-Output "Linked $($gpo.Name) to $($gpo.OU)"
}

# Configure GPO settings

# Server OU
Set-GPRegistryValue -Name "GPO - Server Hardening" `
 -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
 -ValueName "NoControlPanel" -Type DWord -Value 1

Set-GPRegistryValue -Name "GPO - Server Hardening" `
 -Key "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" `
 -ValueName "Start" -Type DWord -Value 4

# Workstation OU
Set-GPRegistryValue -Name "GPO - Workstation Restrictions" `
 -Key "HKCU\Software\Policies\Microsoft\Windows\System" `
 -ValueName "DisableCMD" -Type DWord -Value 1

Set-GPRegistryValue -Name "GPO - Workstation Restrictions" `
 -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
 -ValueName "NoControlPanel" -Type DWord -Value 1

# Admin OU
Set-GPRegistryValue -Name "GPO - Admin Restrictions" `
 -Key "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" `
 -ValueName "fDenyTSConnections" -Type DWord -Value 0

Set-GPRegistryValue -Name "GPO - Admin Restrictions" `
 -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" `
 -ValueName "LimitBlankPasswordUse" -Type DWord -Value 1

# Service Account OU
Set-GPRegistryValue -Name "GPO - Service Account Policy" `
 -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
 -ValueName "SeDenyInteractiveLogonRight" -Type MultiString -Value "SERVICEACCOUNTS"

Write-Output "`nGPOs deployed and configured successfully."
