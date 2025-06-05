# 🛠️ Creating a One-Way Trust Between Two Domains

## Goal
Allow **users from domain B** to access **resources in domain A**.

This is a **one-way incoming trust** on domain A:  
**Domain A trusts domain B** ➜ users from B can authenticate in A.

---

## ✅ Prerequisites

- Both domains must be **up and reachable via the network**.
- **DNS must be properly configured** (e.g., with conditional forwarders between the domains).
- Admin privileges on both domains.
- NetBIOS and FQDN names must be **resolvable** from both sides.

---

## 🗺️ Example

| Domain        | FQDN              | Role                      |
|---------------|-------------------|---------------------------|
| Domain A      | `domainA.local`   | Hosts the resources       |
| Domain B      | `domainB.local`   | Provides the users        |

---

## 1. 🧭 Configure DNS (on both domains)

On **domain A**:

```powershell
Add-DnsServerConditionalForwarderZone -Name "domainB.local" -MasterServers "DNS_IP_B"
```

On **domain B**:

```powershell
Add-DnsServerConditionalForwarderZone -Name "domainA.local" -MasterServers "DNS_IP_A"
```

---

## 2. 🔑 Create the trust on domain A (direction: incoming)

1. Open **Server Manager** > **Tools** > **Active Directory Domains and Trusts**
2. Right-click on **domainA.local** > **Properties**
3. Go to the **Trusts** tab > click **New Trust...**
4. In the wizard:

   - Enter the name of the domain to trust: `domainB.local`
   - Trust type: **External** (or **Forest** if both are forest-level)
   - Direction: **One-way: incoming** (users from B access A)
   - Authentication type: **Selective Authentication** or **Forest-wide**
   - Provide **domain B admin credentials** to validate the trust

5. Finish the wizard.

---

## 3. 🔁 Validate the trust

After creation:

- In **Active Directory Domains and Trusts**, go to the **Trusts** tab.
- Select the new trust and click **Validate**.

---

## 4. 👥 Grant access to users from domain B

1. On the server or resource in domain A, add domain B users/groups to local groups or ACLs.
2. Example: to allow RDP for users from domain B:

```powershell
net localgroup "Remote Desktop Users" domainB\username /add
```

---

## 🧪 Test Access

From a client in domain B, try accessing a resource in domain A:

```cmd
\serverA.domainA.local\share
```

Or use RDP to a server in domain A using domain B user credentials.

---

## 📌 Notes

- Make sure required ports (Kerberos, LDAP, RPC, SMB, etc.) are open between the domains.
- The trust **does not automatically grant access** — permissions must be **explicitly assigned**.
- For better control, consider using **Selective Authentication**.
