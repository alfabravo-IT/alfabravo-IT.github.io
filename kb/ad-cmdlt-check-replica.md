
# Commands to Check the Status of Active Directory Replication

## 1. Check Replication Status with `repadmin`
```powershell
repadmin /replsummary
```
This command provides a summary of replication between domain controllers, including errors and delays.

## 2. Details on a Specific Replica with `repadmin`
```powershell
repadmin /showrepl <controller_name> /verbose
```
Displays detailed information about the replication of a specific domain controller.

## 3. Synchronization Check with `repadmin`
```powershell
repadmin /syncall /A /e /P
```
Starts the synchronization of all replicas, including checking the replication counters for each domain controller.

## 4. Check Domain Controller Status with `dcdiag`
```powershell
dcdiag /test:replications
```
Performs a replication test and provides an overview of the replication health between domain controllers.

## 5. FSMO Synchronization Check
```powershell
netdom query fsmo
```
Displays the domain controllers holding the FSMO (Flexible Single Master Operation) roles and verifies their availability.

## 6. Check Replication Events with `Get-EventLog`
```powershell
Get-EventLog -LogName Directory_Service -EntryType Error,Warning -After (Get-Date).AddDays(-1)
```
Filters Active Directory replication events for errors and warnings, limited to the last 30 days.

## 7. Check NTP Server and Clock Synchronization Settings
```powershell
w32tm /query /status
```
Checks the clock synchronization status on a domain controller, ensuring it is properly synchronized with the NTP server.

## 8. Check AD Services Status
```powershell
Get-Service -Name NTDS, KDC, DNS, Netlogon | Format-Table -Property Name, Status
```
Verifies the status of critical Active Directory services, such as NTDS (Directory Services), KDC (Key Distribution Center), DNS, and Netlogon.

## 9. Check SYSVOL and DFS-R Status
```powershell
dfsrdiag ReplicationState
```
Checks the status of SYSVOL replication through DFS-R (Distributed File System Replication).

## 10. Test Connectivity Between Domain Controllers with `ping`
```powershell
ping <ip_address_or_controller_name>
```
Performs a simple connectivity test to verify that the domain controller is reachable on the network.

