# 🎯 Restricting Access via Selective Authentication (One-Way Trust)

## Scenario
Domain A trusts Domain B (one-way trust). Only **specific users** from **Domain B** should access **certain servers** in **Domain A**.

---

## 🔐 What is Selective Authentication?

Selective Authentication allows you to **explicitly control** which users from Domain B are allowed to authenticate on **specific resources** in Domain A.

---

## ⚙️ Enable Selective Authentication

### During Trust Creation:
- Choose **"One-way: incoming"**
- Select **"Selective Authentication"**

### If the trust already exists:
1. Open **Active Directory Domains and Trusts**
2. Right-click your domain (Domain A) > **Properties**
3. Go to the **Trusts** tab
4. Select the trust to Domain B > **Properties**
5. Enable **“Selective Authentication”**

---

## 👮 Grant "Allowed to authenticate" on Specific Servers

### Steps:

1. Open **Active Directory Users and Computers** on Domain A
2. Navigate to the **Computers** container
3. Find and right-click the **target server**
4. Go to **Properties** > **Security** > **Advanced**
5. Click **Add** > then **Select a principal**
6. Enter the user or group from Domain B (e.g., `DOMAINB\jdoe`)
7. Set **Applies to**: *This object only*
8. In the permissions list, **check**: `Allow` on **"Allowed to authenticate"**
9. Confirm and apply the changes

> 🔐 Without this permission, Domain B users will be **denied authentication**, even if they are granted access rights elsewhere.

---

## 💡 Best Practice

Instead of adding individual users:
- Create a **global group** in Domain B (e.g., `G-DomainA-Access`)
- Add users to this group
- Grant “Allowed to authenticate” to the group on necessary servers in Domain A

This improves **scalability** and **ease of management**.

---

## 🧪 Testing

From a user in Domain B:

- Try to RDP to the allowed server in Domain A
- Try accessing a network share:
  ```cmd
  \serverA.domainA.local\share
  ```

Only the allowed users should succeed. All others will get **access denied** or **no logon servers available**.

---

## 📌 Notes

- Permissions can also be assigned via **PowerShell** or **Group Policy**, but manual assignment is most straightforward for selective authentication.
- Ensure **DNS and firewall ports** are correctly configured.
