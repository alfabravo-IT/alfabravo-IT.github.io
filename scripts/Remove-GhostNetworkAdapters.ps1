# Remove-GhostNetworkAdapters.ps1
# This script lists and optionally removes ghost (non-present) network adapters.

# Define log path based on script location
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path -Path $PSScriptRoot -ChildPath "ghost_nic_cleanup_$timestamp.log"

# Create log directory if needed
if (-not (Test-Path -Path $PSScriptRoot)) {
    New-Item -ItemType Directory -Path $PSScriptRoot -Force | Out-Null
}

# Check if pnputil.exe is available
if (-not (Get-Command pnputil.exe -ErrorAction SilentlyContinue)) {
    Write-Host "❌ pnputil.exe not found. Cannot proceed with removal." -ForegroundColor Red
    Add-Content -Path $logPath -Value "ERROR: pnputil.exe not found on this system."
    return
}

Write-Host "\n🧹 Scanning for ghost (non-present) network adapters..." -ForegroundColor Cyan

# Get ghost network adapters using WMI
$ghostNics = Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.NetConnectionStatus -eq $null -and $_.PNPDeviceID }

# Log the detected ghost adapters
$ghostNics | Select-Object Name, PNPDeviceID | Tee-Object -FilePath $logPath -Encoding UTF8 | Out-Null
Write-Host "\n📄 Report saved to: $logPath" -ForegroundColor Yellow

if ($ghostNics.Count -eq 0) {
    Write-Host "✅ No ghost adapters found. System is clean." -ForegroundColor Green
    return
}

Write-Host "\nFound $($ghostNics.Count) ghost network adapter(s)."
$confirm = Read-Host "Do you want to remove them now? (y/n)"

if ($confirm -match "^[yY]") {
    foreach ($nic in $ghostNics) {
        Write-Host "🔧 Removing: $($nic.Name)" -ForegroundColor DarkYellow
        $id = $nic.PNPDeviceID
        try {
            $output = Start-Process -FilePath "pnputil.exe" -ArgumentList "/remove-device $id" -Wait -NoNewWindow -PassThru
            Add-Content -Path $logPath -Value "Removed: $($nic.Name) | DeviceID: $id | ExitCode: $($output.ExitCode)"
            Write-Host "✔️ Removed: $($nic.Name)" -ForegroundColor Green
        } catch {
            Add-Content -Path $logPath -Value "FAILED to remove: $($nic.Name) | DeviceID: $id | Error: $_"
            Write-Host "❌ Failed to remove $($nic.Name): $_" -ForegroundColor Red
        }
    }
    Write-Host "\n🎉 Cleanup complete!" -ForegroundColor Cyan
} else {
    Write-Host "\n❕ No changes made. Review the log file for details." -ForegroundColor Gray
}