
# Disable Microsoft Defender

## GPO

### 1. Open the Group Policy Management Console (GPMC)
- Press `Windows + R` to open the "Run" dialog box.
- Type `gpmc.msc` and press Enter.

### 2. Create or edit a GPO
- Select the domain or Organizational Unit (OU) where the server is located.
- Create a new GPO or edit an existing one.

### 3. Configure Group Policy settings
- Right-click on the GPO and select **"Edit"**.
- Navigate to:  
    `Computer Configuration > Administrative Templates > Windows Components > Microsoft Defender Antivirus`

### 4. Disable Microsoft Defender
- Enable the policy **Turn off Microsoft Defender Antivirus**.
- Enable the policy **Turn off real-time protection**.
- Enable the policy **Turn off behavior monitoring**.

### 5. Apply and close
- Apply the changes and close the Group Policy Editor.
- Link the GPO to the appropriate server or OU.

### 6. Update group policies
- Open a command prompt as administrator.
- Run:  
    ```bash
    gpupdate /force
    ```

---

## PowerShell Script to Disable Defender

```powershell
# Disable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIntrusionPreventionSystem $true
Set-MpPreference -DisableBlockAtFirstSeen $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableTamperProtection $true

# Remove Windows Defender context menu associations
$ContextMenuKeys = @(
        'HKLM:\Software\Classes\*\shell\OpenWith_Defender\command',
        'HKLM:\Software\Classes\Directory\shell\OpenWith_Defender\command'
)
foreach ($Key in $ContextMenuKeys) {
        if (Test-Path $Key) {
                Remove-Item -Path $Key -Force
        }
}

# Stop and disable the Windows Defender service
Stop-Service -Name WinDefend -Force
Set-Service -Name WinDefend -StartupType Disabled

# Verify that Windows Defender is disabled
Get-Service -Name WinDefend
```

