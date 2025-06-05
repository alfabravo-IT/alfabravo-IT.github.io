---
layout: default
title: Manual Domain Controller Removal – Step-by-Step Guide
---

(# 🛠️ Manual Domain Controller Removal – Step-by-Step Guide

This procedure is intended for situations where the Domain Controller (DC) is **offline** or **cannot be demoted** using Server Manager or `dcpromo`.

---

## 1. Remove the DC from Active Directory Users and Computers

1. Open **Active Directory Users and Computers** (`dsa.msc`) on another **working DC**.
2. Navigate to the **Domain Controllers** organizational unit (OU).
3. Right-click the offline DC and select **Delete**.
4. In the confirmation dialog, select:  
   **"This Domain Controller is permanently offline and can no longer be demoted using the Active Directory Domain Services Installation Wizard (DCPROMO)"**,  
   then click **Delete**.
5. If the DC was a **Global Catalog**, confirm removal when prompted.
6. If the DC held any **FSMO roles**, make sure they are transferred to another DC.

---

## 2. Remove the DC from Active Directory Sites and Services

1. Open **Active Directory Sites and Services** (`dssite.msc`).
2. Expand:
   ```
   Sites > [SiteName] > Servers
   ```
3. Right-click the server corresponding to the removed DC and select **Delete**.
4. Confirm when prompted.

---

## 3. Clean Up Metadata via `ntdsutil`

1. Open **Command Prompt as Administrator**.
2. Launch `ntdsutil`:
   ```
   ntdsutil
   ```
3. Enter metadata cleanup mode:
   ```
   metadata cleanup
   ```
4. Connect to another DC:
   ```
   connections
   connect to server <AnotherWorkingDC>
   quit
   ```
5. Select operation target:
   ```
   select operation target
   list domains
   select domain <number>
   list sites
   select site <number>
   list servers in site
   select server <number>
   remove selected server
   quit
   quit
   ```

---

## 4. Clean Up DNS Records

1. Open **DNS Manager** (`dnsmgmt.msc`).
2. Expand the **Forward Lookup Zone** of your domain.
3. Delete any **A** or **CNAME** records pointing to the removed DC.
4. In the folders `_msdcs`, `_sites`, `_tcp`, and `_udp`, delete any **SRV** records related to the removed DC.

---

## 🔍 Final Checks

- Run:
  ```powershell
  dcdiag
  ```
  To ensure there are no replication or service errors.

- Run:
  ```powershell
  repadmin /replsummary
  ```
  To verify the health of AD replication.

- Confirm FSMO roles are correctly assigned:
  ```powershell
  netdom query fsmo
  ```

---

## 📺 Useful Resources

- [🧾 Microsoft Docs – Demoting Domain Controllers and Domains](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/demoting-domain-controllers-and-domains--level-200-)
)