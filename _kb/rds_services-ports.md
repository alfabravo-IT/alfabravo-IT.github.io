---
layout: default
title: Network Ports Required for Remote Desktop Services (RDS) on Windows Server
---

## Network Ports Required for Remote Desktop Services (RDS) on Windows Server

This table lists the main TCP/UDP ports that must be open for proper configuration of RDS services in a Windows Server infrastructure.

| Service                                    | TCP Port                | UDP Port         | Required on                          |
|-------------------------------------------|--------------------------|------------------|--------------------------------------|
| Remote Desktop Protocol (RDP)             | 3389                     | 3389             | Session Host, Client                 |
| HTTPS (RDWeb)                             | 443                      | -                | RD Web Access, Client                |
| Remote Desktop Gateway (RD Gateway)       | 443, 3391                | 3391             | RD Gateway                           |
| Kerberos                                  | 88                       | -                | Domain Controller                    |
| RPC Endpoint Mapper                       | 135                      | -                | All RDS roles                        |
| LDAP                                      | 389, 636                 | 389              | Domain Controller                    |
| DNS                                       | 53                       | 53               | DNS Server                           |
| HTTP                                      | 80                       | -                | RD Web Access                        |
| FTP                                       | 21                       | -                | (Optional - only if needed)          |
| Network Policy Server (NPS)               | -                        | 1812, 1813       | NPS / RADIUS Server                  |
| Windows Management Instrumentation (WMI)  | 5985                     | -                | Servers managed via remote PowerShell|
| Remote Desktop Licensing                  | 135, 445, 49152–65535    | -                | RD Licensing Server                  |
| Remote Desktop Web Access                 | 443, 5504                | -                | RD Web Access                        |
| Remote Desktop Connection Broker          | 3389, 5504               | -                | RD Connection Broker                 |
| Remote Desktop Virtualization Host        | 3389, 445                | -                | RD Virtualization Host              |
| Remote Desktop Session Host               | 3389, 445                | -                | RD Session Host                      |
| Remote Desktop Services (RDS)             | 3389, 443                | -                | All RDS roles                        |
| NetBIOS                                   | 139                      | 137, 138         | File Sharing / Legacy Services       |
| Microsoft Clearing House                  | 443                      | -                | Microsoft Services (activation)      |

> ℹ️ **Note:** Some ports are required only in environments with specific services. It is recommended to use restrictive firewall rules and hardening techniques.

---

### ℹ️ Legend and Operational Notes

- **Port 3389 (TCP/UDP):** Main port for RDP protocol. In Internet-facing environments, it is strongly advised **not to expose this port directly** but to use an RD Gateway.
- **Port 135 + Dynamic RPC (49152–65535):** These ports are used by services relying on RPC, such as the Connection Broker or Licensing Server. In environments with strict firewalls, consider **configuring a static RPC range**.
- **Port 443 (TCP):** Essential when using RD Gateway or RD Web Access. Provides secure SSL/TLS connections.
- **Port 445 (TCP):** Used for SMB, user profile shares, and RemoteApp folders. Make sure it is open toward file servers.
- **Port 139 (TCP):** Obsolete but sometimes still required by legacy components. Can be disabled if not used.

---

### ✅ Security Tips

- Use **NAT or VPN** to avoid exposing ports directly to the Internet.
- Enable **multi-factor authentication (MFA)** on the Gateway.
- Keep track of dynamic RPC ports if using strict firewall rules.
- Consider using **RD Gateway with SSL Bridging** to reduce exposure of port 3389.