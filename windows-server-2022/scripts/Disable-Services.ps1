# Disable unnecessary services
$servicesToDisable = @(
    "Fax",
    "XblGameSave",
    "RemoteRegistry",
    "WerSvc",
    "DiagTrack"
)

foreach ($svc in $servicesToDisable) {
    Get-Service -Name $svc -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Status -ne 'Stopped') {
            Stop-Service $_.Name -Force
        }
        Set-Service $_.Name -StartupType Disabled
    }
}
