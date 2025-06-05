# RDS - Troubleshooting License Server Connectivity Issues

**_The system cannot determine if the license server is member of TSLS Group on Active Directory Domain Services (AD DS)_**

This error indicates that the license server cannot verify its membership in the Terminal Services License Servers (TSLS) group due to connectivity issues with Active Directory Domain Services (AD DS). Here are a few steps to troubleshoot and resolve the issue:

## 1. Verify Network Connectivity
- Ensure that the license server has a stable network connection to the domain controller (DC).
- Run `ping <domain_controller_name>` from the license server to check if the DC is reachable.

## 2. Check DNS Configuration
- Ensure the license server is using the correct DNS servers that can resolve the Active Directory domain.
- Run `nslookup <domain_name>` and `nslookup <domain_controller_name>` to verify DNS resolution.

## 3. Verify Active Directory Membership
- Ensure that the license server is joined to the domain by running: `nltest /dsgetdc:<your_domain_name>` If this fails, the server may need to be rejoined to the domain.

## 4. Check AD DS and Group Membership
- Open Active Directory Users and Computers (ADUC) on a DC.
- Navigate to Builtin > Terminal Server License Servers.
- Ensure that the license server is listed as a member of this group.
- If it is missing, manually add the license server and restart the Licensing service.

## 5. Restart Licensing Services
- Open Services (`services.msc`).
- Restart the Remote Desktop Licensing service.

## 6. Verify Group Policy Settings
- Open Group Policy Management (`gpedit.msc`) and check if any policies are preventing the license server from communicating with AD DS.
- Run `gpupdate /force` to refresh Group Policy.

## 7. Check Event Logs
- Open Event Viewer (`eventvwr.msc`).
- Navigate to Windows Logs > System & Application to look for related errors.

## 8. Ensure Required Ports Are Open
- Verify that the following ports are open between the license server and the domain controller:
  - TCP 389 (LDAP)
  - TCP 636 (LDAPS)
  - TCP 3268 (Global Catalog)
  - TCP 3269 (Global Catalog over SSL)
  - TCP/UDP 88 (Kerberos)

If the issue persists, try re-registering the license server in AD using `lsdiag.exe` or `lsreport.exe`, or consider rejoining the server to the domain.
