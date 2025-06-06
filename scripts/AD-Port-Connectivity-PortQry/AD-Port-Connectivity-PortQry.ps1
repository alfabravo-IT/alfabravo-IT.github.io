<#
Author   : Andrea Balconi
Date     : 29/04/2025
Version  : 1.0   

PowerShell script to test the connectivity of TCP and UDP ports on Active Directory Domain Controllers using PortQry.

How to run the script:

1. Prepare the necessary files:
    - `server-list.txt`: Contains the IP addresses or fully qualified domain names of the Domain Controllers. One server per line.
    - `portqry.exe`: Download PortQry from Microsoft (https://www.microsoft.com/en-us/download/details.aspx?id=17148) and place it in the same folder as the script (it is a tool used to test ports).
    - `Test-ADPorts-PortQry.ps1`: The PowerShell script that will perform the port tests.

2. Run the script:
    - Open PowerShell as Administrator.
    - Navigate to the folder where the files are located.
    - Run the command:
      .\Test-ADPorts-PortQry.ps1

3. Export the results:
    - The script will generate two reports in the following formats:
      - CSV: Report in CSV format, saved as `AD_Port_Test_Report_PortQry.csv`
      - HTML: Report in HTML format, saved as `AD_Port_Test_Report_PortQry.html`
    - Results Legend:
      - Open: The port is open and listening.
      - Closed: The port is not open.
      - Filtered: The port is filtered, likely due to a firewall.

Warning:
    This script uses PortQry, a Microsoft tool. Ensure that PortQry is compatible with your platform (x86/x64).
#>

# Script path
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# PortQry path
$portqryPath = Join-Path -Path $scriptDir -ChildPath "portqry.exe"

# Input file for servers
$serverList = Get-Content -Path "$scriptDir\server-list.txt"

# TCP Ports
$tcpPorts = @("53","88","135","139","389","445","464","636","3268","3269")

# UDP Ports
$udpPorts = @("53","88","123","137","138","389","445","464")

# Function to test TCP ports
function Test-PortQryTCP {
    param ($Server, $Port)
    $output = & $portqryPath -n $Server -p tcp -e $Port 2>&1
    if ($output -match "LISTENING") { return "Open" }
    elseif ($output -match "NOT LISTENING") { return "Closed" }
    elseif ($output -match "FILTERED") { return "Filtered" }
    else { return "Unknown" }
}

# Function to test UDP ports
function Test-PortQryUDP {
    param ($Server, $Port)
    $output = & $portqryPath -n $Server -p udp -e $Port 2>&1
    if ($output -match "LISTENING or FILTERED") { return "Filtered" }
    elseif ($output -match "LISTENING") { return "Open" }
    elseif ($output -match "NOT LISTENING") { return "Closed" }
    elseif ($output -match "FILTERED") { return "Filtered" }
    else { return "Unknown" }
}

# Collecting results
$results = @()
foreach ($server in $serverList) {
    foreach ($port in $tcpPorts) {
        $status = Test-PortQryTCP -Server $server -Port $port
        $results += [PSCustomObject]@{Server=$server;Port=$port;Protocol="TCP";Status=$status}
    }
    foreach ($port in $udpPorts) {
        $status = Test-PortQryUDP -Server $server -Port $port
        $results += [PSCustomObject]@{Server=$server;Port=$port;Protocol="UDP";Status=$status}
    }
}

# Exporting CSV
$results | Export-Csv -Path "$scriptDir\AD_Port_Test_Report_PortQry.csv" -NoTypeInformation -Encoding UTF8

# Exporting HTML
$html = @"
<!DOCTYPE html>
<html>
<head>
<title>TCP/UDP Ports Report</title>
<style>
    body { font-family: Arial; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid black; padding: 6px; text-align: left; }
    th { background-color: #f2f2f2; }
    .Closed { background-color: #f8d7da; }
    .Filtered { background-color: #f8d7da; }
    .Open { background-color: #d4edda; }
</style>
</head>
<body>
<h2>TCP and UDP Ports Report</h2>
<table>
<tr><th>Server</th><th>Port</th><th>Protocol</th><th>Status</th></tr>
$($results | ForEach-Object {
    "<tr class='$($_.Status)'><td>$($_.Server)</td><td>$($_.Port)</td><td>$($_.Protocol)</td><td>$($_.Status)</td></tr>"
})
</table>
<h3>Legend:</h3>
<ul>
<li><strong>Open:</strong> Response received, service active</li>
<li><strong>Closed:</strong> Port not listening</li>
<li><strong>Filtered:</strong> No response, likely due to a firewall (UDP is "stateless", so the result will often be "Filtered", even if the port is technically listening.)</li>
</ul>
</body>
</html>
"@
$html | Out-File -Encoding UTF8 -FilePath "$scriptDir\AD_Port_Test_Report_PortQry.html"

Write-Output "Reports generated in: $scriptDir"
Write-Output "CSV: AD_Port_Test_Report_PortQry.csv"
Write-Output "HTML: AD_Port_Test_Report_PortQry.html"