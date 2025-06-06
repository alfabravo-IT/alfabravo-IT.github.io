<#
Uso:
.\Remove-StaleComputer.ps1 -ComputerName "NomeCortoDelComputer"
Esempio:
.\Remove-StaleComputer.ps1 -ComputerName "SRV-APP01"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName
)

function Remove-DnsRecords {
    param([string]$ComputerName)

    # Rimuove record A
    $zones = Get-DnsServerZone | Where-Object { -not $_.IsReverseLookupZone }
    foreach ($zone in $zones) {
        $fqdn = "$ComputerName.$($zone.ZoneName)"
        $records = Get-DnsServerResourceRecord -ZoneName $zone.ZoneName -ErrorAction SilentlyContinue | Where-Object {
            $_.RecordType -eq "A" -and $_.HostName -ieq $ComputerName
        }

        foreach ($rec in $records) {
            try {
                Remove-DnsServerResourceRecord -ZoneName $zone.ZoneName -InputObject $rec -Force
                Write-Host "✅ Record A rimosso da zona '$($zone.ZoneName)' per '$ComputerName'"
            } catch {
                Write-Warning "❌ Errore rimozione record A ($fqdn): $_"
            }
        }
    }

    # Rimuove record PTR (se possibile)
    $aRecord = $records | Select-Object -First 1
    if ($aRecord -and $aRecord.RecordData.IPv4Address) {
        $ip = $aRecord.RecordData.IPv4Address
        $ptrName = ($ip.GetAddressBytes() | ForEach-Object { $_ })[-1..0] -join '.'
        $reverseZones = Get-DnsServerZone | Where-Object { $_.IsReverseLookupZone }

        foreach ($zone in $reverseZones) {
            $ptrRecord = Get-DnsServerResourceRecord -ZoneName $zone.ZoneName -Name $ptrName -ErrorAction SilentlyContinue | Where-Object {
                $_.RecordType -eq "PTR"
            }

            foreach ($rec in $ptrRecord) {
                try {
                    Remove-DnsServerResourceRecord -ZoneName $zone.ZoneName -InputObject $rec -Force
                    Write-Host "✅ Record PTR rimosso da zona '$($zone.ZoneName)' per IP $ip"
                } catch {
                    Write-Warning "❌ Errore rimozione PTR ($ptrName): $_"
                }
            }
        }
    } else {
        Write-Host "ℹ️ Nessun record A trovato → salto rimozione PTR"
    }
}

# Main
Import-Module ActiveDirectory
Import-Module DnsServer

Write-Host "`n➡️ Rimozione oggetto AD '$ComputerName'..."
try {
    Remove-ADComputer -Identity $ComputerName -Confirm:$false -ErrorAction Stop
    Write-Host "✅ Oggetto computer AD rimosso."
} catch {
    Write-Warning "⚠️ Errore nella rimozione da AD: $_"
}

Write-Host "`n➡️ Rimozione record DNS..."
Remove-DnsRecords -ComputerName $ComputerName

Write-Host "`n🎯 Operazione completata." -ForegroundColor Green