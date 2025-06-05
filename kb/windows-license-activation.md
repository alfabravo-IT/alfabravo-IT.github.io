# 🔐 Adding and Removing Product Key on Windows Server

This guide explains how to add, activate, or remove a product key on Windows Server systems using `slmgr.vbs` and `DISM`.

---

## 🆕 Adding a Product Key and Activating the License

1. **Add the new license key**  
    ```cmd
    slmgr.vbs /ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
    ```
    > Replace `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX` with your new product key.

2. **Activate the new license**  
    ```cmd
    slmgr.vbs /ato
    ```

3. **Check the activation status** *(optional)*  
    ```cmd
    slmgr.vbs /xpr
    ```

---

## 🧹 Removing the Product Key

1. Open **PowerShell** or **Command Prompt** as an administrator.

2. **Remove the current product key**  
    ```cmd
    slmgr.vbs /upk
    ```
    > This command removes the currently installed license key.

3. **Remove the key from the registry**  
    ```cmd
    slmgr.vbs /cpky
    ```
    > This command deletes the key from the registry to prevent it from being retrieved.

---

## 🛠️ Alternative: Setting Edition and Product Key with DISM

### Datacenter Edition
```cmd
DISM /online /Set-Edition:ServerDatacenter /ProductKey:XXXXX-XXXXX-XXXXX-XXXXX-XXXXX /AcceptEula
```

### Standard Edition
```cmd
DISM /online /Set-Edition:ServerStandard /ProductKey:XXXXX-XXXXX-XXXXX-XXXXX-XXXXX /AcceptEula
```

---

> ℹ️ **Note:** Some operations may require a system restart to complete successfully.
