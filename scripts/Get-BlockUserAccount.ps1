<#
.SYNOPSIS
    Script to check locked-out users in Active Directory, determine on which Domain Controller the lockout was detected, and generate a report.

.DESCRIPTION
    This script retrieves account lockout events (ID 4740) from Active Directory Domain Controllers.
    For each event, the script checks which Domain Controller recorded the lockout and which user was locked out.
    Finally, a detailed report is exported to a CSV file.

.PARAMETER UserName
    Name of the user for whom you want to check lockout events.

.EXAMPLE
    .\Check-ADLockout.ps1 -UserName "user123"
    This command checks if the user "user123" was locked out and generates a report of the Domain Controllers that detected the lockout.

.NOTES
    Script created by: Andrea Balconi
    Creation date: 2025-04-29
#>

param (
    [string]$UserName  # Name of the user to check
)

# Get the PDC emulator (Primary Domain Controller)
$pdc = (Get-ADDomain).PDCEmulator

# Filter for event 4740 (account lockout) from the last day
$filterHash = @{
    LogName   = "Security"
    Id        = 4740
    StartTime = (Get-Date).AddDays(-1)  # Last 24 hours
}

# Get account lockout events from the PDC emulator
$lockoutEvents = Get-WinEvent -ComputerName $pdc -FilterHashTable $filterHash -ErrorAction SilentlyContinue

# List for results
$report = @()

foreach ($event in $lockoutEvents) {
    $lockedUser = $event.Properties[0].Value
    $sourceComputer = $event.Properties[1].Value
    $domainController = $event.Properties[4].Value
    $timeCreated = $event.TimeCreated

    # Add details only if the locked-out user matches the one we're looking for
    if ($lockedUser -eq $UserName) {
        $report += [PSCustomObject]@{
            LockedUser      = $lockedUser
            SourceComputer  = $sourceComputer
            DomainController = $domainController
            TimeCreated     = $timeCreated
        }
    }
}

# If there are events, export the report to CSV
if ($report.Count -gt 0) {
    $reportPath = "${PSScriptRoot}\AD_Lockout_Report.csv"  # Use ${} for the file path
    $report | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8
    Write-Host "Process completed. Details saved in the file: $reportPath"
} else {
    Write-Host "No lockouts detected for user $UserName or on any Domain Controller."
}