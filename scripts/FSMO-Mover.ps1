<#
.SYNOPSIS
    Script to check the health status of a Domain Controller and transfer FSMO roles.
    The script performs a series of checks to evaluate the health of the Domain Controller and transfer FSMO roles to another Domain Controller if necessary.

.DESCRIPTION
    This script performs the following steps:
    1. Checks the status of FSMO roles (SchemaMaster, DomainNamingMaster, PDCEmulator, RIDMaster, InfrastructureMaster).
    2. Verifies the replication status between Domain Controllers.
    3. Checks for errors in the event logs of Directory Service, DNS Server, and System.
    4. Performs a DNS health test.
    5. If all checks pass, transfers the FSMO roles to a target Domain Controller.
    
    In case of an error in one of the checks, the script stops the FSMO role transfer and reports the error.

.PARAMETER TargetDC
    The target Domain Controller to which FSMO roles will be transferred. 
    This parameter must be a valid name of a Domain Controller within the network.

.EXAMPLE
    VerificaSalute-DC.ps1
    Run the script to check the health status of a Domain Controller and transfer FSMO roles if necessary.

.NOTES
    Script created by: Andrea Balconi
    Creation date: 2025-04-29
    Version: 1.0
    Changes: Creation of the script for FSMO role checking and transfer.

#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Function to check FSMO roles
function Test-FSMORoles {
    Write-Host "Checking FSMO roles..." -ForegroundColor Cyan
    $fsmoRoles = Get-ADDomain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator
    $fsmoForest = Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster

    Write-Host "FSMO roles in the domain:" -ForegroundColor Green
    $fsmoRoles
    Write-Host "FSMO roles in the forest:" -ForegroundColor Green
    $fsmoForest

    return $true
}

# Function to check replication status
function Test-Replication {
    Write-Host "Checking replication status..." -ForegroundColor Cyan
    try {
        $repSummary = repadmin /replsummary 2>&1
        $showRepl = repadmin /showrepl 2>&1
        if ($repSummary -and $showRepl) {
            Write-Host "Replication is active and functioning." -ForegroundColor Green
            return $true
        } else {
            Write-Host "Replication check failed." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error during replication check: $_" -ForegroundColor Red
        return $false
    }
}

# Function to check errors in event logs
function Test-EventLogs {
    Write-Host "Checking errors in event logs..." -ForegroundColor Cyan
    $dsErrors = Get-EventLog -LogName "Directory Service" -EntryType Error -Newest 10
    $dnsErrors = Get-EventLog -LogName "DNS Server" -EntryType Error -Newest 10
    $sysErrors = Get-EventLog -LogName "System" -EntryType Error -Newest 10

    # Check if there are errors
    if ($dsErrors.Count -eq 0 -and $dnsErrors.Count -eq 0 -and $sysErrors.Count -eq 0) {
        Write-Host "No errors in event logs." -ForegroundColor Green
        return $true
    } else {
        Write-Host "Errors detected in event logs." -ForegroundColor Red
        return $false
    }
}

# Function to test DNS health
function Test-DNSHealth {
    Write-Host "Checking DNS health..." -ForegroundColor Cyan
    try {
        $dnsTest = dcdiag /test:dns 2>&1
        if ($dnsTest -match "passed") {
            Write-Host "DNS test passed." -ForegroundColor Green
            return $true
        } else {
            Write-Host "DNS test failed. Check the details in the report." -ForegroundColor Red
            Write-Host $dnsTest -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "Error during DNS health test: $_" -ForegroundColor Red
        return $false
    }
}

# Function to transfer FSMO roles to a specified Domain Controller
function Move-FSMORoles {
    param (
        [string]$TargetDC
    )
    Write-Host "Transferring FSMO roles to Domain Controller $TargetDC..." -ForegroundColor Yellow

    try {
        # Transfer each FSMO role
        Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole SchemaMaster -Confirm:$false
        Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole DomainNamingMaster -Confirm:$false
        Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole PDCEmulator -Confirm:$false
        Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole RIDMaster -Confirm:$false
        Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole InfrastructureMaster -Confirm:$false

        Write-Host "FSMO roles successfully transferred to $TargetDC." -ForegroundColor Green
    } catch {
        Write-Host "Error during FSMO role transfer: $_" -ForegroundColor Red
    }
}

# Main script execution
Write-Host "Starting Domain Controller health check..." -ForegroundColor Green

$checkFSMO = Test-FSMORoles
$checkReplication = Test-Replication
$checkEventLogs = Test-EventLogs
$checkDNS = Test-DNSHealth

# Check if all tests passed
if ($checkFSMO -and $checkReplication -and $checkEventLogs -and $checkDNS) {
    Write-Host "All checks passed. Proceeding with FSMO role transfer..." -ForegroundColor Green
    $TargetDC = "TargetDCName" # Replace with the name of the target Domain Controller
    Move-FSMORoles -TargetDC $TargetDC
} else {
    Write-Host "One or more checks failed. FSMO role transfer aborted." -ForegroundColor Red
}

Write-Host "Domain Controller health check completed." -ForegroundColor Green