# Services, Ports, and Protocols for Active Directory

This table lists the services, ports, and protocols used in an Active Directory environment. The listed ports are critical for the proper operation of core services such as DNS, LDAP, Kerberos, and Replication.

> **Note:** Some NetBIOS services are no longer required starting with **Windows Server 2012** Domain Controllers.

## Core Ports

| **Service**                                               | **Port**         | **Protocol** | **Usage**                                                                                 |
|-----------------------------------------------------------|------------------|--------------|-------------------------------------------------------------------------------------------|
| DFSN, NetBIOS Session Service, NetLogon                   | 139              | TCP          | NetBIOS session service *(not required with DC WS2012 and later)*.                       |
| DFSN, NetLogon, NetBIOS Datagram Service                  | 138              | UDP          | NetBIOS datagram service *(not required with DC WS2012 and later)*.                      |
| DNS                                                       | 53               | TCP/UDP      | Domain name resolution between clients and DCs, and between DCs.                         |
| Kerberos                                                  | 88               | TCP/UDP      | Kerberos authentication, forest-level trust.                                             |
| Kerberos change/set password                              | 464              | TCP/UDP      | Replication, user and computer authentication, trusts.                                   |
| LDAP                                                      | 389              | TCP/UDP      | Standard LDAP communication for directory service queries and updates.                   |
| LDAP GC                                                   | 3268             | TCP          | Queries to the Global Catalog.                                                           |
| LDAP GC SSL                                               | 3269             | TCP          | Queries to the Global Catalog with SSL encryption.                                       |
| LDAP SSL                                                  | 636              | TCP          | LDAP communication over SSL for secure queries and updates.                              |
| NetLogon, NetBIOS Name Resolution                         | 137              | UDP          | NetBIOS name resolution *(not required with DC WS2012 and later)*.                       |
| RPC, DCOM, EPM, DRSUAPI, NetLogonR, SamR, FRS             | 49152–65535      | TCP          | Dynamic RPC communication using ports assigned by the endpoint mapper (TCP 135).         |
| RPC, EPM                                                  | 135              | TCP          | Remote Procedure Calls, Endpoint Mapper for dynamic RPC services.                        |
| SMB, CIFS, SMB2, DFSN, LSARPC, NbtSS, NetLogonR, SamR, SrvSvc | 445           | TCP/UDP      | File and printer sharing, shared file access, printing, and AD replication.              |
| Windows Time                                              | 123              | UDP          | Time synchronization between clients and DCs, and between DCs.                           |

## Optional Services / External Trusts

| **Service**                          | **Port**           | **Protocol** | **Usage**                                                                 |
|--------------------------------------|--------------------|--------------|----------------------------------------------------------------------------|
| WINS (optional)                      | 42                 | TCP/UDP      | Legacy NetBIOS name resolution.                                           |
| Global Catalog Trusts (Forest Trust) | 3268               | TCP          | Used for forest trusts requiring access to the Global Catalog.            |
| RPC for ADMT                         | 135, 445, 1024–65535 | TCP        | Migration Tool, trusts, and SIDHistory synchronization.                   |
| IPsec (optional)                     | 500, 4500          | UDP          | IPsec for VPN tunnels or IPsec-authenticated trusts.                      |
| RADIUS (optional)                   | 1812, 1813         | UDP          | Used by NPS for centralized authentication via Active Directory.          |

---

**Protocol Legend:**
- **TCP**: Transmission Control Protocol
- **UDP**: User Datagram Protocol
- **TCP/UDP**: Uses both protocols depending on the service or configuration

---

**Tip:** For firewall scenarios, ensure these ports are open bidirectionally between Domain Controllers, clients, and other necessary servers (e.g., domain members, DNS servers, etc.).
