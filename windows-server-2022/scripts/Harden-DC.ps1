# Disable Unnecessary Services
$servicesToDisable = @(
    "Fax",             # Fax Service
    "XblGameSave",     # Xbox services (if any)
    "RemoteRegistry",  # Security risk
    "WerSvc",          # Windows Error Reporting
    "DiagTrack"        # Diagnostics Tracking
)

foreach ($svc in $servicesToDisable) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -ne 'Stopped') {
            Stop-Service -Name $svc -Force
        }
        Set-Service -Name $svc -StartupType Disabled
    }
}

Write-Output "✔ Unnecessary services disabled."

# Registry Hardening for LDAP + SMB Signing
$registrySettings = @(
    @{ Path = "HKLM\SYSTEM\CurrentControlSet\Services\LDAP"; Name = "LDAPClientIntegrity"; Type = "DWord"; Value = 2 },
    @{ Path = "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"; Name = "RequireSecuritySignature"; Type = "DWord"; Value = 1 },
    @{ Path = "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"; Name = "RequireSecuritySignature"; Type = "DWord"; Value = 1 }
)

foreach ($setting in $registrySettings) {
    New-Item -Path $setting.Path -Force | Out-Null
    New-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -PropertyType $setting.Type -Force
}

Write-Output "✔ LDAP and SMB Signing enforced."

# Done
Write-Output "✅ Domain Controller hardened successfully."
