<#
.NOTES
    Author   : Andrea Balconi
    Date     : 29/04/2025
    Version  : 2.0
.SYNOPSIS
    Performs connectivity tests (TCP and UDP) on the servers listed in "server-list.txt"
    to verify the ports and essential services for Active Directory and generates an HTML report.
.DESCRIPTION
    The script reads the list of servers (FQDN or IP) from a text file named "server-list.txt".
    For each server, the following services are tested:
      - Kerberos (TCP and UDP on ports 88 and 464)
      - LDAP (TCP on port 389)
      - LDAPS (TCP on port 636)
      - Global Catalog (TCP on ports 3268 and 3269)
      - DNS (TCP and UDP on port 53, with specific UDP test)
      - RPC Endpoint Mapper (TCP on port 135)
      - SMB / Netlogon (TCP on port 445)
      - WSMAN (TCP on port 5985)
      - NTP (UDP on port 123)
      - NetBIOS Name Service (UDP on port 137)
      - NetBIOS Datagram Service (UDP on port 138)
      - NetBIOS Session Service (TCP on port 139)
      - AD Federation Services (TCP on port 443)
    At the end, an HTML report is generated summarizing the status of each port/service on each server.
.PARAMETER ServerListFile
    Specifies the text file containing the list of servers (default ".\server-list.txt").
.PARAMETER OutputFile
    Specifies the HTML file to save the report (default ".\AD_Port_Test_Report.html").
    Also specifies the CSV file to save the report (default ".\AD_Port_Test_Report.csv").
#>

[CmdletBinding()]
param(
    [string]$ServerListFile = "$PSScriptRoot\server-list.txt",
    [string]$OutputFile = "$PSScriptRoot\AD_Port_Test_Report.html"
)

# Check if the server list file exists
if (-not (Test-Path $ServerListFile)) {
    Write-Error "The file '$ServerListFile' was not found!"
    exit
}

# Read the list of servers (one per line)
$serverList = Get-Content -Path $ServerListFile

# Function to perform a generic UDP test (e.g., for Kerberos UDP)
function Test-UdpPort {
    param (
        [string]$ComputerName,
        [int]$Port,
        [int]$Timeout = 2000
    )
    $udpClient = $null
    try {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Client.ReceiveTimeout = $Timeout
        $udpClient.Connect($ComputerName, $Port)
        # Send a simple test message
        $data = [System.Text.Encoding]::ASCII.GetBytes("Ping")
        $udpClient.Send($data, $data.Length) | Out-Null
        $remoteEndpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
        $udpClient.Receive([ref] $remoteEndpoint) | Out-Null
        return "Open"
    }
    catch [System.Net.Sockets.SocketException] {
        if ($_.Exception.ErrorCode -eq 10060) {
            return "Filtered"
        }
        elseif ($_.Exception.ErrorCode -in 10061, 10054) {
            return "Closed"
        }
        else {
            return "Error: " + $_.Exception.Message
        }
    }
    catch {
        return "Error: " + $_.Exception.Message
    }
    finally {
        if ($udpClient) { $udpClient.Close() }
    }
}

# Function to perform a specific UDP test for DNS (sends a valid DNS query)
function Test-DnsUdpPort {
    param(
        [string]$ComputerName,
        [int]$Port,
        [string]$QueryDomain = "example.com",
        [int]$Timeout = 2000
    )
    $udpClient = $null
    try {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Client.ReceiveTimeout = $Timeout
        $udpClient.Connect($ComputerName, $Port)
        # Build a DNS query packet:
        # DNS Header (12 bytes): Transaction ID, Flags, QDCOUNT, ANCOUNT, NSCOUNT, ARCOUNT
        $transactionId = [byte[]](0x12,0x34)    # Fixed ID for the test
        $flags         = [byte[]](0x01,0x00)     # Standard query
        $questions     = [byte[]](0x00,0x01)     # 1 question
        $answerCount   = [byte[]](0x00,0x00)
        $authorityCount= [byte[]](0x00,0x00)
        $additionalCount=[byte[]](0x00,0x00)
    
        # Build the QNAME (example.com)
        $domainParts = $QueryDomain.Split(".")
        $qnameBytes = @()
        foreach ($part in $domainParts) {
            $qnameBytes += [byte]$part.Length
            $qnameBytes += [System.Text.Encoding]::ASCII.GetBytes($part)
        }
        $qnameBytes += 0  # Terminator
        
        # QTYPE = A (1) and QCLASS = IN (1)
        $qtype = [byte[]](0x00,0x01)
        $qclass = [byte[]](0x00,0x01)
    
        $queryPacket = $transactionId + $flags + $questions + $answerCount + $authorityCount + $additionalCount + $qnameBytes + $qtype + $qclass
    
        $udpClient.Send($queryPacket, $queryPacket.Length) | Out-Null
        $remoteEndpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
        $response = $udpClient.Receive([ref] $remoteEndpoint)
        if ($response.Length -ge 12) {
            # Verify the transaction ID of the response
            if ($response[0] -eq 0x12 -and $response[1] -eq 0x34) {
                return "Open"
            }
        }
        return "Unexpected Response"
    }
    catch [System.Net.Sockets.SocketException] {
        if ($_.Exception.ErrorCode -eq 10060) {
            return "Filtered"
        }
        elseif ($_.Exception.ErrorCode -in 10061,10054) {
            return "Closed"
        }
        else {
            return "Error: " + $_.Exception.Message
        }
    }
    catch {
        return "Error: " + $_.Exception.Message
    }
    finally {
        if ($udpClient) { $udpClient.Close() }
    }
}

# Wrapper function to perform the test on the port based on protocol and service
function Test-ADPort {
    param(
         [string]$ComputerName,
         [int]$Port,
         [string]$Protocol,
         [string]$Service,
         [int]$Timeout = 2000
    )

    $resultObject = [PSCustomObject]@{
         "ComputerName" = $ComputerName
         "Port"         = $Port
         "Protocol"     = $Protocol
         "Service"      = $Service
         "Status"       = ""
         "Error"        = ""
         "Timestamp"    = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    if ($Protocol -eq "TCP") {
       try {
            $testResult = Test-NetConnection -ComputerName $ComputerName -Port $Port -InformationLevel Detailed -WarningAction SilentlyContinue
            if ($testResult.TcpTestSucceeded) {
                 $resultObject.Status = "Open"
            }
            else {
                 $resultObject.Status = "Closed"
            }
       }
       catch {
            $resultObject.Status = "Error"
            $resultObject.Error  = $_.Exception.Message
       }
    }
    elseif ($Protocol -eq "UDP") {
         try {
             # If the service is "DNS (UDP)" use the specific test, otherwise the generic UDP test
             if ($Service -eq "DNS (UDP)") {
                 $status = Test-DnsUdpPort -ComputerName $ComputerName -Port $Port -Timeout $Timeout
                 $resultObject.Status = $status
             }
             else {
                 $status = Test-UdpPort -ComputerName $ComputerName -Port $Port -Timeout $Timeout
                 $resultObject.Status = $status
             }
         }
         catch {
            $resultObject.Status = "Error"
            $resultObject.Error = $_.Exception.Message
         }
    }
    else {
         $resultObject.Status = "Unknown Protocol"
    }
    return $resultObject
}

# Definition of port and service tests (final table)
$portTests = @(
    @{ Port = 88;    Protocol = "TCP"; Service = "Kerberos (TCP)" },
    @{ Port = 88;    Protocol = "UDP"; Service = "Kerberos (UDP)" },
    @{ Port = 464;   Protocol = "TCP"; Service = "Kerberos (TCP)" },
    @{ Port = 464;   Protocol = "UDP"; Service = "Kerberos (UDP)" },
    @{ Port = 389;   Protocol = "TCP"; Service = "LDAP" },
    @{ Port = 636;   Protocol = "TCP"; Service = "LDAPS" },
    @{ Port = 3268;  Protocol = "TCP"; Service = "Global Catalog" },
    @{ Port = 3269;  Protocol = "TCP"; Service = "Global Catalog (SSL)" },
    @{ Port = 53;    Protocol = "TCP"; Service = "DNS" },
    @{ Port = 53;    Protocol = "UDP"; Service = "DNS (UDP)" },
    @{ Port = 135;   Protocol = "TCP"; Service = "RPC Endpoint Mapper" },
    @{ Port = 445;   Protocol = "TCP"; Service = "SMB / Netlogon" },
    @{ Port = 5985;  Protocol = "TCP"; Service = "WSMAN" },
    @{ Port = 123;   Protocol = "UDP"; Service = "NTP" },
    @{ Port = 137;   Protocol = "UDP"; Service = "NetBIOS Name Service" },
    @{ Port = 138;   Protocol = "UDP"; Service = "NetBIOS Datagram Service" },
    @{ Port = 139;   Protocol = "TCP"; Service = "NetBIOS Session Service" },
    @{ Port = 443;   Protocol = "TCP"; Service = "AD Federation Services" }
)

# Create an empty list to store the results
$results = @()

# Loop through each server and port test combination
foreach ($server in $serverList) {
    foreach ($portTest in $portTests) {
        $result = Test-ADPort -ComputerName $server -Port $portTest.Port -Protocol $portTest.Protocol -Service $portTest.Service
        $results += $result
    }
}

# Generate the HTML report
$results | ConvertTo-Html -Property ComputerName, Port, Protocol, Service, Status, Error, Timestamp -Title "AD Port Test Report" | Set-Content -Path $OutputFile
Write-Host "The report has been saved to '$OutputFile'"

# Generate the CSV report
$csvOutputFile = $OutputFile.Replace(".html", ".csv")
$results | Export-Csv -Path $csvOutputFile -NoTypeInformation
Write-Host "The CSV report has been saved to '$csvOutputFile'"