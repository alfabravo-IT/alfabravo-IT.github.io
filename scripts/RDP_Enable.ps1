<#
.SYNOPSIS
    Enables Remote Desktop Protocol (RDP) on the local Windows machine.

.DESCRIPTION
    This script automates the process of enabling Remote Desktop by:
      1. Modifying the registry to allow RDP connections.
      2. Setting the Remote Desktop service (TermService) to start automatically and starting it.
      3. Enabling all Windows Firewall rules related to Remote Desktop.
      4. Reading the RDP port from the registry (defaults to 3389 if not found).
      5. Checking if the RDP port is listening for incoming connections.
      6. Displaying status messages and instructions to the user.

.NOTES
    Author      : Andrea Balconi
    Date        : 2024-06-07
    Version     : 1.0

    - Administrator privileges are required to run this script.
    - A system restart may be required for all changes to take effect.

.EXAMPLE
    .\RDP_Enable.ps1
    Runs the script to enable RDP and configure the firewall and service settings.

#>
Write-Host "`n🔧 Enabling Remote Desktop..." -ForegroundColor Cyan

# 1. Enable RDP in the registry
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

# 2. Set RDP service to automatic and start it
Set-Service -Name TermService -StartupType Automatic
Start-Service -Name TermService

# 3. Enable all Firewall rules for RDP
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# 4. Check RDP port status from the registry
try {
    $rdpPort = (Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp").PortNumber
    if (-not $rdpPort) {
        Write-Host "⚠️  Unable to determine RDP port from registry. Using default port 3389." -ForegroundColor Yellow
        $rdpPort = 3389
    }
} catch {
    Write-Host "❌ Error reading RDP port from registry. Using default port 3389." -ForegroundColor Red
    $rdpPort = 3389
}

Write-Host "`n✅ Remote Desktop enabled on port: $rdpPort" -ForegroundColor Green
Write-Host "🔐 Firewall rules configured successfully." -ForegroundColor Green

# 5. Check if the port is listening
try {
    $rdpStatus = (Get-NetTCPConnection -LocalPort $rdpPort -ErrorAction SilentlyContinue).State
} catch {
    $rdpStatus = $null
}

if ($rdpStatus -eq "Listen") {
    Write-Host "🟢 RDP is ready to accept connections." -ForegroundColor Green
} else {
    Write-Host "⚠️  The RDP port is not listening. A reboot may be required." -ForegroundColor Yellow
}

# 6. Final message
Write-Host "`n✅ DONE. You can now connect via RDP!" -ForegroundColor Cyan
Write-Host "🖥️  Restart the system to apply all changes." -ForegroundColor Yellow
