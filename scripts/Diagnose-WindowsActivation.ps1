<#
.SYNOPSIS
    Diagnoses Windows activation issues and generates a detailed report in both TXT and HTML formats.

.DESCRIPTION
    This script collects diagnostic information relevant to Windows activation, including connectivity to Microsoft's activation servers, proxy configuration, DNS servers, critical service statuses, and license status. The results are saved as timestamped TXT and HTML reports in the script's directory.

.PARAMETER None
    This script does not accept parameters.

.OUTPUTS
    - TXT report: ActivationReport_<timestamp>.txt
    - HTML report: ActivationReport_<timestamp>.html

.FUNCTIONS
    Add-Report
        Appends a titled section with content to both the TXT and HTML report builders.

.NOTES
    Author: [Andrea Balconi]
    Date: [2025/06/06]
    Requires: PowerShell 5.1 or later, administrative privileges for some commands.

.EXAMPLE
    .\Diagnose-WindowsActivation.ps1

    Runs the script and generates diagnostic reports in the script's folder.

#>
# Get the path of the folder where the script is located
$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# Create file name with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$txtReport = "$scriptPath\ActivationReport_$timestamp.txt"
$htmlReport = "$scriptPath\ActivationReport_$timestamp.html"

# StringBuilder to accumulate output
$txtBuilder = New-Object System.Text.StringBuilder
$htmlBuilder = New-Object System.Text.StringBuilder

# Utility functions
function Add-Report {
    param (
        [string]$Title,
        [string[]]$Content
    )
    $txtBuilder.AppendLine("==== $Title ====") | Out-Null
    $Content | ForEach-Object { $txtBuilder.AppendLine($_) | Out-Null }

    $htmlBuilder.AppendLine("<h2>$Title</h2><pre>$($Content -join "`n")</pre>") | Out-Null
}

# Start data collection
Add-Report -Title "Connectivity to activation.microsoft.com" -Content (
    Test-NetConnection -ComputerName activation.microsoft.com -Port 443 | Out-String
)

Add-Report -Title "WinHTTP Proxy" -Content (
    netsh winhttp show proxy | Out-String
)

Add-Report -Title "Configured DNS Servers" -Content (
    Get-DnsClientServerAddress | Where-Object {$_.ServerAddresses} | Format-Table InterfaceAlias, ServerAddresses -AutoSize | Out-String
)

Add-Report -Title "Status of critical services (sppsvc, wuauserv, W32Time, NlaSvc)" -Content (
    Get-Service -Name sppsvc, wuauserv, W32Time, NlaSvc | Format-Table Name, Status, StartType | Out-String
)

Add-Report -Title "Windows License Status (slmgr /dlv)" -Content (
    cscript.exe //Nologo C:\Windows\System32\slmgr.vbs /dlv 2>&1
)

Add-Report -Title "Hostname and Domain" -Content (
    "Computer Name: $env:COMPUTERNAME",
    "Domain (USERDOMAIN): $env:USERDOMAIN"
)

# Save files
[System.IO.File]::WriteAllText($txtReport, $txtBuilder.ToString())
[System.IO.File]::WriteAllText($htmlReport, @"
<html>
<head>
    <title>Windows Activation Diagnostics</title>
    <style>
        body { font-family: Consolas, monospace; background-color: #f4f4f4; color: #333; padding: 20px; }
        h2 { color: #0066cc; border-bottom: 1px solid #ccc; }
        pre { background: #fff; padding: 10px; border: 1px solid #ccc; overflow-x: auto; }
    </style>
</head>
<body>
<h1>Windows Activation Diagnostics Report</h1>
$htmlBuilder
</body>
</html>
"@)

# Final output
Write-Host "`n== Diagnostics completed ==" -ForegroundColor Green
Write-Host "Reports saved in: $scriptPath" -ForegroundColor Cyan
