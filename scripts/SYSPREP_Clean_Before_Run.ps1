<#
.SYNOPSIS
    Performs a pre-Sysprep cleanup on a Windows system to prepare it for imaging.

.DESCRIPTION
    This script automates several cleanup tasks to ensure a Windows system is ready for Sysprep. 
    It should be run with administrator privileges. The script performs the following actions:
      1. Runs Cleanmgr (if available) in verylowdisk mode to clean up system files.
      2. Stops the Windows Update service, removes the update cache, and restarts the service.
      3. Clears all event logs, skipping protected logs.
      4. Deletes temporary files from user and system temp directories.

.NOTES
    Author: Andrea Balconi
    Date: 2025/06/06
    Run as administrator for full effect.

.EXAMPLE
    .\SYSPREP_Clean_Before_Run.ps1

    Runs the cleanup script and prepares the system for Sysprep.

#>
# Run as administrator
Write-Host "🧽 Starting pre-Sysprep cleanup..." -ForegroundColor Cyan

# [1/4] Cleanmgr (only if present)
Write-Host "`n[1/4] Checking for Cleanmgr..."
if (Test-Path "$env:SystemRoot\System32\cleanmgr.exe") {
    Write-Host "[✓] Cleanmgr found. Starting in verylowdisk mode..."
    Start-Process -FilePath "$env:SystemRoot\System32\cleanmgr.exe" -ArgumentList "/verylowdisk" -Wait
} else {
    Write-Host "[!] Cleanmgr not found. GUI cleanup skipped." -ForegroundColor Yellow
}

# [2/4] Update cache cleanup
Write-Host "`n[2/4] Removing update cache..."
Try {
    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service wuauserv -ErrorAction SilentlyContinue
    Write-Host "[✓] Update cache removed."
} Catch {
    Write-Host "[X] Error while removing update cache." -ForegroundColor Red
}

# [3/4] Event log cleanup (skip protected logs)
Write-Host "`n[3/4] Cleaning event logs..."
$logs = wevtutil el
foreach ($log in $logs) {
    Try {
        wevtutil cl $log
    } Catch {
        Write-Host "⚠️ Log cannot be cleared: $log" -ForegroundColor DarkYellow
    }
}
Write-Host "[✓] Event log cleanup completed."

# [4/4] Temporary files
Write-Host "`n[4/4] Cleaning temporary files..."
Try {
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[✓] Temporary files removed."
} Catch {
    Write-Host "[X] Some temporary files could not be deleted." -ForegroundColor Red
}

Write-Host "`n✔️ Cleanup completed. System ready for Sysprep." -ForegroundColor Green