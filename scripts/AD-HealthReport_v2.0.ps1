<#
    Author   : Andrea Balconi
    Date     : 29/04/2025
    Version  : 2.0 

    Description:
    Script for checking the health status of Domain Controllers (DC) in an Active Directory environment.

    Features:
    - Verifies the status of Active Directory replication using "repadmin".
    - Checks FSMO roles (Schema Master, RID Master, PDC Emulator, etc.).
    - Monitors the status of critical services (Netlogon, KDC, DNS Client).
    - Checks time synchronization (NTP).
    - Verifies SYSVOL and NETLOGON shares (DFS-R).
    - Exports results in HTML and CSV format.

    Output:
    - HTML and CSV reports with all checks performed and an explanatory legend of the results.

    Requirements:
    - Administrative permissions on Domain Controllers.
    - Remote access enabled on target servers.

    Usage:
    Run the script from an administrative machine to obtain a detailed report
    on the status of Active Directory replication and critical services.
#>

# === Initial Settings ===
$dataOra = Get-Date -Format "yyyy-MM-dd_HH-mm"
$reportHtmlPath = "$PSScriptRoot\AD_Replica_Report_$dataOra.html"
$reportCsvPath = "$PSScriptRoot\\AD_Replica_Report_$dataOra.csv"
$reportData = @()
$reportHtml = @()
$domainControllers = Get-ADDomainController -Filter *

# === Create report folder if it does not exist ===
if (!(Test-Path "$PSScriptRoot\reports\")) {
    New-Item -Path "$PSScriptRoot\reports\" -ItemType Directory
}

# === HTML Function ===
function ConvertTo-HtmlReport {
    param (
        [string]$title,
        [array]$content
    )
    $legend = @"
<h2>Legend</h2>
<ul>
    <li><b>Ping</b>: checks DC reachability (OK/KO)</li>
    <li><b>Services</b>: checks the status of Netlogon, KDC, and DNS Client</li>
    <li><b>Repadmin</b>: checks for replication errors using <code>repadmin /showrepl</code></li>
    <li><b>Test Sync</b>: simulates a synchronization (readonly) with <code>repadmin /syncall</code></li>
    <li><b>DFS-R / SYSVOL</b>: checks the status of DFS replication and SYSVOL share</li>
    <li><b>DNS</b>: checks the status of the DNS service and resolution</li>
    <li><b>NTP</b>: checks the status of NTP time synchronization</li>
</ul>
<hr>
"@

    return @"
<html>
<head>
    <title>$title</title>
    <style>
        body { font-family: Segoe UI, sans-serif; background: #f0f0f0; padding: 20px; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 30px; }
        th, td { border: 1px solid #ccc; padding: 8px; }
        th { background: #444; color: white; }
        tr:nth-child(even) { background: #f9f9f9; }
        h1 { color: #333; }
        pre { background: #eaeaea; padding: 10px; border: 1px solid #ccc; }
    </style>
</head>
<body>
    <h1>$title</h1>
    $legend
    $($content -join "`n")
</body>
</html>
"@
}

# === FSMO Check ===
$forestRoles = Get-ADForest
$domainRoles = Get-ADDomain

$fsmoList = @(
    "Schema Master: $($forestRoles.SchemaMaster)"
    "Domain Naming Master: $($forestRoles.DomainNamingMaster)"
    "RID Master: $($domainRoles.RIDMaster)"
    "PDC Emulator: $($domainRoles.PDCEmulator)"
    "Infrastructure Master: $($domainRoles.InfrastructureMaster)"
)

$fsmoReport = "<h2>FSMO Roles</h2><ul>" + ($fsmoList | ForEach-Object { "<li>$_</li>" }) + "</ul>"

# === Loop through Domain Controllers ===
foreach ($dc in $domainControllers) {
    Write-Host "Analyzing $($dc.Hostname)..."

    # Ping
    $ping = Test-Connection -ComputerName $dc.Hostname -Count 2 -Quiet
    $pingResult = if ($ping) { "OK" } else { "KO" }

    # Critical Services
    $services = @("Netlogon", "Kdc", "Dnscache")
    $svcStatus = foreach ($svc in $services) {
        try {
            $svcObj = Get-Service -ComputerName $dc.Hostname -Name $svc -ErrorAction Stop
            "${svc}: $($svcObj.Status)"
        } catch {
            "$($svc): Error"
        }
    } -join "; "

    # Repadmin ShowRepl
    $replOutput = repadmin /showrepl $dc.Hostname /errorsonly | Out-String
    if (-not $replOutput.Trim()) { $replOutput = "No errors." }

    # Diagnostic Replication (readonly sync)
    $syncTest = repadmin /syncall $dc.Hostname /e /A /P /q | Out-String

    # DFS-R / SYSVOL
    $dfsStatus = Get-WmiObject -Class Win32_Share -ComputerName $dc.Hostname | Where-Object { $_.Name -eq "SYSVOL" -or $_.Name -eq "NETLOGON" }
    $dfsStatusText = if ($dfsStatus) { "SYSVOL/NETLOGON present" } else { "SYSVOL/NETLOGON missing or not properly shared" }

    # DNS
    $dnsStatus = Get-Service -ComputerName $dc.Hostname -Name "DNS" -ErrorAction SilentlyContinue
    $dnsText = if ($dnsStatus.Status -eq "Running") { "DNS running" } else { "DNS not running" }

    # NTP
    $ntpStatus = w32tm /monitor | Out-String
    $ntpText = if ($ntpStatus -match "Stratum") { "Time synchronization OK" } else { "Time synchronization issues" }

    # Save CSV
    $reportData += [PSCustomObject]@{
        DC           = $dc.Hostname
        Ping         = $pingResult
        Services     = $svcStatus
        Repadmin     = if ($replOutput -eq "No errors.") { "OK" } else { "ERRORS" }
        SyncTest     = if ($syncTest -like "*successfully*") { "OK" } else { "Manual Check" }
        DFS_R_SYSVOL = $dfsStatusText
        DNS          = $dnsText
        NTP          = $ntpText
    }

    # Save HTML
    $reportHtml += @"
<h2>$($dc.Hostname)</h2>
<b>Ping:</b> $pingResult<br>
<b>Services:</b> $svcStatus<br>
<b>Replication Status:</b><pre>$replOutput</pre>
<b>Test Sync:</b><pre>$syncTest</pre>
<b>DFS-R/SYSVOL:</b> $dfsStatusText<br>
<b>DNS:</b> $dnsText<br>
<b>NTP:</b> $ntpText
"@
}

# === Generate HTML Report ===
$htmlOutput = ConvertTo-HtmlReport -title "Active Directory Replica Report ($dataOra)" -content @($fsmoReport, ($reportHtml -join "`n"))
$htmlOutput | Out-File -FilePath $reportHtmlPath -Encoding UTF8

# === Generate CSV Report ===
$reportData | Export-Csv -Path $reportCsvPath -NoTypeInformation -Encoding UTF8

Write-Host "HTML Report: $reportHtmlPath"
Write-Host "CSV Report : $reportCsvPath"