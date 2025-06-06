<#
Advanced diagnostic script for checking RDP, NLA, and Kerberos connectivity on Domain Controllers.

Description:
This script performs a series of diagnostic checks on Domain Controllers, including the following activities:
1. Checks the server's operating system version and build.
2. Verifies connectivity on critical ports required for RDP, NLA, and Kerberos functionality.
3. Analyzes the number of groups of the current user to detect potential issues with the Kerberos token (too large size).
4. Retrieves and displays recent SSL events (IDs 36871, 36888) that may indicate issues with encryption or the RDP certificate.
5. Checks the presence and status of the active RDP certificate on the server, essential for establishing secure RDP connections.
6. Provides a final report of the checks, including any errors or anomalies encountered during the tests.

Requirements:
- The text file "dc-list.txt" must contain the list of Domain Controllers to be tested, one per line. The file path can be specified in the `$dcFile` variable.
- The script must be run with administrative privileges.

Author   : Andrea Balconi (Cegeka)
Date     : 29/04/2025
Version  : 2.0

#>

# Set the path of the text file containing the list of Domain Controllers
$dcFile = "$PSScriptRoot\dc-list.txt"

# Check if the file exists
if (-Not (Test-Path $dcFile)) {
    Write-Host "The file '$dcFile' does not exist. Ensure the path is correct." -ForegroundColor Red
    exit
}

# Read the Domain Controllers from the file
$domainControllers = Get-Content -Path $dcFile

# Final report
$report = @()

Write-Host "== START OF ADVANCED RDP/NLA/KERBEROS DIAGNOSTICS ==`n"

### [1] OS build check
$os = Get-CimInstance Win32_OperatingSystem
$buildInfo = "{0} - Build {1}" -f $os.Caption, $os.BuildNumber
Write-Host "[1] Operating System: $buildInfo" -ForegroundColor Cyan

### [2] Verify critical ports to DCs
$ports = @(88, 135, 389, 445, 464, 636, 3268)

foreach ($dc in $domainControllers) {
    foreach ($port in $ports) {
        $result = Test-NetConnection -ComputerName $dc -Port $port -InformationLevel Quiet
        $status = if ($result) { 'OK' } else { 'FAIL' }
        $report += [pscustomobject]@{
            Target = $dc
            Port   = $port
            Status = $status
        }
    }
}

### [3] Count groups of the current user (Kerberos token size)
$groupCount = (whoami /groups | Measure-Object).Count
Write-Host "[3] Number of groups for the current user: $groupCount" -ForegroundColor Cyan

if ($groupCount -gt 100) {
    Write-Warning "The user belongs to more than 100 groups: possible Kerberos token too large."
}

### [4] Check recent SSL events (36871, 36888)
$sslEvents = Get-WinEvent -LogName System -MaxEvents 50 | Where-Object { $_.Id -in 36871, 36888 }
Write-Host "[4] Recent SSL events:" -ForegroundColor Cyan
$sslEvents | Format-Table TimeCreated, Id, Message -AutoSize

### [5] Check active RDP certificate
$key = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$thumbprint = (Get-ItemProperty -Path $key -Name SSLCertificateSHA1Hash -ErrorAction SilentlyContinue).SSLCertificateSHA1Hash

if ($thumbprint) {
    try {
        $cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $thumbprint }
        if ($cert) {
            Write-Host "[5] RDP certificate found: $($cert.Subject), expiration: $($cert.NotAfter)" -ForegroundColor Cyan
        } else {
            Write-Warning "RDP certificate not found in the store." 
        }
    } catch {
        Write-Warning "Error retrieving the RDP certificate: $_"
    }
} else {
    Write-Warning "SSLCertificateSHA1Hash key not present."
}

### [6] Port test results
Write-Host "[6] Port status to DCs:" -ForegroundColor Cyan
$report | Format-Table -AutoSize

Write-Host "== END OF DIAGNOSTICS ==" -ForegroundColor Green
Write-Host "Check the report for any errors or anomalies." -ForegroundColor Yellow

# Create the HTML report
$reportHtmlPath = "$PSScriptRoot\RDP-NLA-Kerberos_report.html"
$report | ConvertTo-Html -Property Target, Port, Status -Head "<style>table {width: 100%; border-collapse: collapse;} th, td {padding: 8px; text-align: left; border: 1px solid #ddd;} tr:nth-child(even) {background-color: #f2f2f2;} th {background-color: #4CAF50; color: white;}</style>" -Title "RDP/NLA/Kerberos Diagnostic Report" | Out-File -FilePath $reportHtmlPath
Write-Host "HTML report created: $reportHtmlPath"

# Create the CSV report
$reportCsvPath = "$PSScriptRoot\RDP-NLA-Kerberos_report.csv"
$report | Export-Csv -Path $reportCsvPath -NoTypeInformation
Write-Host "CSV report created: $reportCsvPath"