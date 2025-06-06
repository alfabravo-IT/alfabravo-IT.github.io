<#
    === Author: Andrea Balconi ===
    === Date: 29/04/2025 ===
    === Version: 2.0 ===    

    Description:
    Diagnostic script to check the health status of Domain Controllers (DC)
    in an Active Directory infrastructure.

    Features:
    - Analyzes event logs related to key AD services (Directory Service, DNS Server, etc.).
    - Runs "dcdiag" to check the integrity of the domain controller.
    - Generates an HTML report with detailed results.

    Output:
    - HTML file saved in the specified path or in the script folder.

    Requirements:
    - Execution with administrative privileges.
    - Remote access enabled on the Domain Controllers to be analyzed (if necessary).

    Parameters:
    - DaysBack   [int]        → Number of days to analyze in the logs (default: 7)
    - LogNames   [string[]]   → Names of the event logs to check (default: main AD logs)
    - ReportPath [string]     → Path of the output HTML file (default: ADHealth_Report.html in the script folder)

    Usage:
    .\DC-HealthReport_v2.0.ps1 -DaysBack 10 -LogNames "Directory Service","DNS Server" -ReportPath "C:\Reports\AD.html"
#>

Param(
    [int]$DaysBack = 7,
    [string[]]$LogNames = @("Directory Service", "DNS Server", "Active Directory Web Services", "DFS Replication", "Application"),
    [string]$ReportPath = "$PSScriptRoot\DCHealth_Report.html"
)

function Test-ADHealth {
    Write-Host "Starting checks on the Domain Controller for Active Directory..." -ForegroundColor Cyan

    $startTime = (Get-Date).AddDays(-$DaysBack)

    $htmlReport = @"
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        h1 { color: darkblue; }
        h2 { color: #007acc; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .warning { color: darkorange; font-weight: bold; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f9f9f9; }
    </style>
    <title>AD Health Report</title>
</head>
<body>
<h1>Domain Controllers Health Report</h1>
"@

    foreach ($log in $LogNames) {
        Write-Host "`nChecking errors in the log '$log'..." -ForegroundColor Cyan
        $htmlReport += "<h2>Log Check '$log'</h2>`n"

        $logObject = Get-WinEvent -ListLog $log -ErrorAction SilentlyContinue
        if (-not $logObject) {
            Write-Host "The log '$log' was not found on this system." -ForegroundColor DarkYellow
            $htmlReport += "<p class='warning'>The log '$log' was not found on this system.</p>`n"
            continue
        }

        $logErrors = Get-WinEvent -FilterHashtable @{
            LogName   = $log;
            Level     = 2;
            StartTime = $startTime
        } -ErrorAction SilentlyContinue

        if ($logErrors -and $logErrors.Count -gt 0) {
            Write-Host "Errors were found in the log '$log':" -ForegroundColor Red
            $htmlReport += "<p class='error'>Errors were found in the log '$log':</p>`n"
            $htmlReport += "<table><tr><th>Date</th><th>ID</th><th>Message</th></tr>`n"
            foreach ($event in $logErrors) {
                Write-Host ("Date: {0} | ID: {1}" -f $event.TimeCreated, $event.Id) -ForegroundColor Yellow
                Write-Host "Message:" -ForegroundColor Yellow
                Write-Host $event.Message
                Write-Host "----------------------------------------------" -ForegroundColor DarkGray
                $formattedMessage = $event.Message -replace "`r`n", "<br/>"
                $htmlReport += "<tr><td>$($event.TimeCreated)</td><td>$($event.Id)</td><td>$formattedMessage</td></tr>`n"
            }
            $htmlReport += "</table>`n"
        }
        else {
            Write-Host "No errors detected in the log '$log'." -ForegroundColor Green
            $htmlReport += "<p class='success'>No errors detected in the log '$log'.</p>`n"
        }
        Write-Host "Log check '$log' completed." -ForegroundColor Cyan
    }

    Write-Host "`nRunning dcdiag for additional checks..." -ForegroundColor Cyan
    $htmlReport += "<h2>Running dcdiag</h2>`n"

    $dcdiagOutput = dcdiag /q 2>&1
    $dcdiagErrors = $dcdiagOutput | Where-Object { $_ -match "(?i)(fail|error)" }

    if ($dcdiagErrors) {
        Write-Host "The dcdiag command highlighted the following errors:" -ForegroundColor Red
        $htmlReport += "<p class='error'>The dcdiag command highlighted the following errors:</p>`n<ul>`n"
        foreach ($line in $dcdiagErrors) {
            Write-Host $line -ForegroundColor Yellow
            $lineFormatted = $line -replace "`r`n", "<br/>"
            $htmlReport += "<li>$lineFormatted</li>`n"
        }
        $htmlReport += "</ul>`n"
    }
    else {
        Write-Host "dcdiag: All checks are OK. No errors detected." -ForegroundColor Green
        $htmlReport += "<p class='success'>dcdiag: All checks are OK. No errors detected.</p>`n"
    }
    Write-Host "dcdiag check completed." -ForegroundColor Cyan

    $htmlReport += "</body></html>"

    $htmlReport | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Host "`nHTML report generated at: $ReportPath" -ForegroundColor Cyan
}

Test-ADHealth
