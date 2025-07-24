# Backup current security settings
Write-Output "📦 Backing up current security policy..."
secedit /export /cfg C:\Scripts\current-policy-backup.inf

# Create new Account Lockout INF file manually (no multi-line strings)
Write-Output "✍️ Writing AccountLockout.inf file..."
$infPath = "C:\Scripts\AccountLockout.inf"

# Clear any old file first
if (Test-Path $infPath) {
    Remove-Item $infPath -Force
}

Add-Content -Path $infPath -Value "[System Access]"
Add-Content -Path $infPath -Value "LockoutBadCount = 5"
Add-Content -Path $infPath -Value "ResetLockoutCount = 15"
Add-Content -Path $infPath -Value "LockoutDuration = 15"

# Apply the policy
Write-Output "🔐 Applying Account Lockout Policy..."
secedit /configure /db C:\Windows\Security\Database\AccountLockout.sdb /cfg $infPath /quiet

# Refresh policies
Write-Output "🔄 Refreshing Group Policy..."
gpupdate /force

# Export for verification
$verifyPath = "C:\Scripts\verify-lockout.inf"
secedit /export /cfg $verifyPath

Write-Output "✅ Account Lockout Policy applied successfully."
Write-Output "📁 Backup: $env:SystemDrive\Scripts\current-policy-backup.inf"
Write-Output "📁 Verification: $verifyPath"
