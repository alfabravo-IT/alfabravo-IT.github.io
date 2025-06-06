<#
.SYNOPSIS
    Diagnostic script to check if a server can accept RDP connections with NLA enabled from domain users.

.DESCRIPTION
    This script performs a series of checks to diagnose the status of RDP connections with NLA (Network Level Authentication) enabled on a server. 
    The checks include:
    1. Time synchronization check between the server and the domain.
    2. Verification of the `CredSSP` registry key configuration (Client-side support for RDP authentication).
    3. Verification of the correct configuration of SPNs (Service Principal Names) for the RDP service.
    4. Verification of the groups the current user belongs to, such as "Remote Desktop Users".
    5. Status of the RDP service (TermService).
    6. Verification of the CredSSP version available on the server.

.NOTES
    Author     : Andrea Balconi (Cegeka)
    Date       : 29/04/2025
    Version    : 1.0
    Description: Script for advanced diagnostics of RDP/NLA/Kerberos on Windows servers.
#>

Write-Host "== RDP + NLA DIAGNOSTICS ==" -ForegroundColor Cyan

# 1. Time synchronization check
Write-Host "[1] Time synchronization check:" -ForegroundColor Yellow
try {
        $status = w32tm /query /status
        $status
} catch {
        Write-Warning "Error reading clock status."
}

# 2. CredSSP registry key check
Write-Host "[2] 'AllowEncryptionOracle' key status:" -ForegroundColor Yellow
$key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters"
if (Test-Path $key) {
        Get-ItemProperty -Path $key | Select-Object AllowEncryptionOracle
} else {
        Write-Host "Key not present (secure default)."
}

# 3. Computer SPN check (must be run from a domain controller or with AD permissions)
Write-Host "[3] Check SPNs associated with the computer:" -ForegroundColor Yellow
$computerName = $env:COMPUTERNAME
try {
        setspn -L $computerName
} catch {
        Write-Warning "Unable to execute setspn. RSAT AD or execution on a DC is required."
}

# 4. User group membership check
Write-Host "[4] Current user's groups:" -ForegroundColor Yellow
whoami /groups

# 5. RDP service status (TermService)
Write-Host "[5] Remote Desktop service status:" -ForegroundColor Yellow
Get-Service -Name TermService | Select-Object Status, StartType

# 6. CredSSP protocol version check
Write-Host "[6] CredSSP support check (DLL):" -ForegroundColor Yellow
Get-Item "C:\Windows\System32\credssp.dll" | Select-Object Name, VersionInfo

Write-Host "== DIAGNOSTICS COMPLETE ==" -ForegroundColor Cyan

# Create a list to collect results
$report = @()

# 1. Time synchronization check
$timeStatus = ""
try {
        $timeStatus = w32tm /query /status
} catch {
        $timeStatus = "Error reading clock status."
}
$report += [PSCustomObject]@{Test="Time Synchronization"; Status=$timeStatus}

# 2. CredSSP registry key check
$credSSPStatus = ""
$key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters"
if (Test-Path $key) {
        $credSSPStatus = (Get-ItemProperty -Path $key | Select-Object -ExpandProperty AllowEncryptionOracle)
} else {
        $credSSPStatus = "Key not present (secure default)."
}
$report += [PSCustomObject]@{Test="CredSSP"; Status=$credSSPStatus}

# 3. Computer SPN check
$spnStatus = ""
$computerName = $env:COMPUTERNAME
try {
        $spnStatus = (setspn -L $computerName) -join "`n"
} catch {
        $spnStatus = "Unable to execute setspn. RSAT AD or execution on a DC is required."
}
$report += [PSCustomObject]@{Test="Computer SPN"; Status=$spnStatus}

# 4. User group membership check
$groupStatus = (whoami /groups)
$report += [PSCustomObject]@{Test="User Groups"; Status=$groupStatus}

# 5. RDP service status
$rdpStatus = (Get-Service -Name TermService | Select-Object Status, StartType)
$report += [PSCustomObject]@{Test="RDP Service"; Status=$rdpStatus.Status}

# 6. CredSSP protocol version
$credSSPVersion = (Get-Item "C:\Windows\System32\credssp.dll" | Select-Object Name, VersionInfo)
$report += [PSCustomObject]@{Test="CredSSP Version"; Status=$credSSPVersion.VersionInfo}

# Export the report to CSV format
$csvPath = "$PSScriptRoot\RDP_NLA_Kerberos_Report.csv"
$report | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

# Export the report to HTML format
$htmlPath = "$PSScriptRoot\RDP_NLA_Kerberos_Report.html"
$report | ConvertTo-Html -Property Test, Status -Head "<style>body { font-family: Arial, sans-serif; } table { width: 100%; border-collapse: collapse; margin: 20px 0; } th, td { border: 1px solid #ddd; padding: 8px; text-align: left; } th { background-color: #f2f2f2; }</style>" -Title "RDP, NLA, Kerberos Diagnostic Report" | Out-File $htmlPath

Write-Host "== DIAGNOSTICS COMPLETE ==" -ForegroundColor Cyan
Write-Host "The report has been saved as 'RDP_NLA_Kerberos_Report.csv' at the path: $csvPath" -ForegroundColor Yellow
Write-Host "The report has been saved as 'RDP_NLA_Kerberos_Report.html' at the path: $htmlPath" -ForegroundColor Yellow