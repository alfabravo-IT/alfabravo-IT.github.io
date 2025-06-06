<#
.SYNOPSIS
    PowerShell script to grant the "Logon as a service" privilege to required accounts
    and identify accounts already having this privilege.

.DESCRIPTION
    This script is used to:
    1. Identify accounts with the "Logon as a service" privilege on the system.
    2. Grant the "Logon as a service" privilege to new users or services.
    3. Export and modify security configurations using `secedit.exe`.
    4. Support integration with IIS (Internet Information Services) to add app pool accounts.

.NOTES
    Author: Andrea Balconi (Cegeka)
    Date: 29/04/2025
    Version: 1.0
    Requirements: PowerShell, administrative privileges, IIS (if necessary)
    Usage:
    - Run the script as an administrator.
    - It can be used to grant the "Logon as a service" privilege to specific accounts.

    Example usage:
    - Run the script with `-WhatIf` to simulate adding an account without actually applying the change.
    - Use `-Verbose` for additional details during execution.

#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Find-LogonAsService {
    [CmdletBinding()]
    param ()

    $ignoreAccounts = @("LocalSystem", "NT Authority\LocalService", "NT Authority\Local Service", "NT AUTHORITY\NetworkService", "NT AUTHORITY\Network Service")
    $accounts = @("NT SERVICE\ALL SERVICES")

    $accounts += Get-CimInstance -ClassName Win32_Service | Where-Object { $_.StartMode -ne "Disabled" } | Select-Object -ExpandProperty StartName

    $accounts += Get-CimInstance -ClassName Win32_Account -Namespace "root\cimv2" -Filter "LocalAccount=True" | Where-Object { ($_.SIDType -ne 1 -or !$_.Disabled) -and $_.Name -like "SQLServer*User$*" } | Select-Object -ExpandProperty Name

    try {
        if (-not (Get-Module -Name WebAdministration -ErrorAction SilentlyContinue)) {
            Import-Module WebAdministration
        }
        Get-ChildItem IIS:\AppPools | ForEach-Object {
            $accounts += "IIS APPPOOL\$($_.Name)"
        }
    } catch {
        Write-Warning "** No IIS, or PowerShell not running as Administrator: $_"
    }

    $accounts | Sort-Object -Unique | Where-Object { $ignoreAccounts -notcontains $_ }
}

function Grant-LogOnAsService {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$User
    )

    begin {
        $secedit = "C:\Windows\System32\secedit.exe"
        $seceditdb = "$($env:TEMP)\secedit.sdb"

        $oldSids = ""
        $newSids = ""
        $secfileInput = [System.IO.Path]::GetTempFileName()
        $secfileOutput = [System.IO.Path]::GetTempFileName()

        &$secedit /export /cfg $secfileInput | Write-Debug

        if (((Get-Content $secfileInput) -join [Environment]::NewLine) -match "SeServiceLogonRight = (.*)") {
            $oldSids = $Matches[1]
        }
    }

    process {
        try {
            $userAccount = New-Object System.Security.Principal.NTAccount($User)
            $userTranslated = "*$($userAccount.Translate([System.Security.Principal.SecurityIdentifier]))"
        } catch {
            $userTranslated = $User
        }

        if (!$oldSids.Contains($userTranslated) -and !$oldSids.Contains($User)) {
            $PSCmdlet.ShouldProcess($User) | Out-Null

            if ($newSids) {
                $newSids += ",$userTranslated"
            } else {
                $newSids += $userTranslated
            }
        }
    }

    end {
        if ($newSids) {
            if ($oldSids) {
                $allSids = $oldSids.Trim() + "," + $newSids
            } else {
                $allSids = $newSids
            }

            $secFileContent = Get-Content $secfileInput | ForEach-Object {
                if ($oldSids -and $_ -match "SeServiceLogonRight = (.*)") {
                    "SeServiceLogonRight = $allSids"
                } else {
                    $_

                    if ($_ -eq "[Privilege Rights]" -and !$oldSids) {
                        "SeServiceLogonRight = $allSids"
                    }
                }
            }

            Set-Content -Path $secfileOutput -Value $secFileContent -WhatIf:$false

            if (!$WhatIfPreference) {
                &$secedit /import /db $seceditdb /cfg $secfileOutput
                &$secedit /configure /db $seceditdb | Write-Debug
                Remove-Item $seceditdb
            }
        } else {
            Write-Verbose "No change"
        }

        Remove-Item $secfileInput -WhatIf:$false
        Remove-Item $secfileOutput -WhatIf:$false
    }
}

Find-LogonAsService | Grant-LogOnAsService -WhatIf
Find-LogonAsService | Grant-LogOnAsService -Verbose