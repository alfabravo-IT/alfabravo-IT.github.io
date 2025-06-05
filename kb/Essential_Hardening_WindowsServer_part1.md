# Essential Security Settings to Harden Windows Machines (part 1)
Update: 19 novembre 2024

## 1 - Disable IP source routing :
The use of IP source routing in Windows machines presents several significant security risks. This feature allows the sender of a packet to specify the path the packet should take through the network, which can be exploited by attackers to bypass security mechanisms based on source IP address analysis. By manipulating the route, malicious packets can appear to originate from trusted hosts or be directed to sensitive areas of the network normally protected from external access. This opens the door to spoofing attacks and unauthorized intrusions, compromising overall network security. For these reasons, it is strongly recommended to disable IP source routing to enhance system security.

### A - Can be applied on :

-   Windows 10 (All versions)
-   Windows 11
-   Windows Server 2012, 2016, 2019, 2022

### B - Detect if IP source routing is disabled :

$key = "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters"
$valueName = "DisableIPSourceRouting"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    switch ($value) {
        0 { Write-Host "IP source routing is enabled."}
        1 { Write-Host "IP source routing is partially disabled (only Strict Source Route packets are allowed)." }
        2 { Write-Host "IP source routing is completely disabled (recommended setting)." -ForegroundColor Green}
        default { Write-Output "Unknown setting value." }
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShell Configuration :

Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" -Name DisableIPSourceRouting -Value 2 -Type DWORD

### D - GPO Configuration :

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQGAB_NBHxih2Q/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731078759584?e=1751500800&v=beta&t=ExrQQoCG35VPt9Rolk4-fjq5kwaz0rUf8XkvPbsoQIk)

-   **Action**: Update
-   **Hive**: HKEY\_LOCAL\_MACHINE
-   **Key Path**: _HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters_
-   **Value name**: _DisableIPSourceRouting_
-   **Value type**: REG\_DWORD
-   **Value data**: 2

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQG1bK17WOkLxQ/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731078790163?e=1751500800&v=beta&t=vCVFwzHi3Sjs9j74z2GZHfhoFFpfAWWbTqElhmh3Prk)

gpupdate /force

* * *

## 2 - Disable LLMNR :

  

LLMNR is used to resolve names on a local network by sending multicast requests. However, this protocol presents security vulnerabilities, including the risk of man-in-the-middle (MitM) and poisoning attacks.

By disabling LLMNR, you reduce these risks by forcing machines to use more secure name resolution methods, such as DNS. This is particularly recommended in environments where security is a priority.

### A - Can be applied on :

-   Windows 10 (All versions)
-   Windows 11
-   Windows Server 2012, 2016, 2019, 2022

### B - Detect if LLMNR is disabled :

$key = "HKLM:\\Software\\Policies\\Microsoft\\Windows NT\\DNSClient"
$valueName = "EnableMulticast"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 0) {
        Write-Host "LLMNR is disabled." -ForegroundColor Green
    }
    else {
        Write-Host "LLMNR is enabled." -ForegroundColor Red
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShell Configuration :

\# Create New Key
New-Item -Path "HKLM:\\Software\\policies\\Microsoft\\Windows NT" -Name "DNSClient"
# Add DWORD Property and value
Set-ItemProperty -Path "HKLM:\\Software\\policies\\Microsoft\\Windows NT\\DNSClient" -Name "EnableMulticast" -Value 0 -Type DWORD

### D - GPO Configuration :

**Computer Configuration -> Administrative Templates -> Network -> DNS ClientEnable Turn Off Multicast Name Resolution** policy by changing its value to **Enabled**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQGqefxYB-BodA/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731090932500?e=1751500800&v=beta&t=KRsWTpLhSD0H651SNEz0nQkCxZ8HDyyJPSF35WpQucU)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQE24m934VKK7Q/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731091176981?e=1751500800&v=beta&t=msJbfcjyz5oiRlL4-3NzWUxuV2M1B3ePEs-gCTIMhc8)

gpupdate /force

* * *

## 3 - Prohibit connection to non-domain networks when connected to domain authenticated network :

  

The “Prohibit connection to non-domain networks when connected to domain authenticated network” policy prevents computers from simultaneously connecting to a domain-based network and a non-domain network.

Here's how it works:

-   **Automatic connection attempts** : If the computer is already connected to a domain network, all automatic connection attempts to non-domain networks are blocked, and vice versa.
-   **Manual connection attempts** : If the computer is connected to a non-domain or domain network via a medium other than Ethernet, and a user attempts to manually connect to another network in violation of this policy, the existing connection is disconnected and the manual connection is allowed. If the existing connection is via Ethernet, it is maintained and the manual connection attempt is blocked.

This policy is useful for reinforcing security by avoiding simultaneous connections to potentially insecure networks when the computer is already connected to an authenticated domain network.

### A - Can be applied on :

-   Windows 10 (All versions)
-   Windows 11
-   Windows Server 2016, 2019, 2022

### B - Detect :

$key = "HKLM:\\Software\\Policies\\Microsoft\\Windows\\WcmSvc\\GroupPolicy"
$valueName = "fBlockNonDomain"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 2) {
        Write-Host "Prohibit connection to non-domain networks when connected to domain authenticated network is enabled." -ForegroundColor Green
    }
    else {
        Write-Host "Prohibit connection to non-domain networks when connected to domain authenticated network is disabled." -ForegroundColor Red
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

-   **2** : Policy configured
-   **Error** : Policy not configured

### C - PowerShell Configuration :

Set-ItemProperty "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WcmSvc\\GroupPolicy" -Name "fBlockNonDomain" -Value "2" -Type DWORD

### D - GPO Configuration 1 :

**Computer Configuration\\Policies\\Administrative Templates\\Network\\Windows Connection Manager**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQHvNFKMNXvN4g/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731092853383?e=1751500800&v=beta&t=lNSlDDhwT166eVhg65_SsSP7IMhkUZqB88TkPe-GBAA)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQESEPAS9WWS6w/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731092905031?e=1751500800&v=beta&t=YlU8g2GxjfPKpBSxQqzq63R9UH9Qjt-XDnDbee6iTIY)

### E - GPO Configuration 2 :

Create New Policy, then Edit it :

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQEJ_fcILJNsqw/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731092465010?e=1751500800&v=beta&t=kLP0MFQ3-u4LiZZtpw1Wzda-b6vNHLFy7v68WSwysPg)

-   **Action** : Create
-   **Hive** : HKEY\_LOCAL\_MACHINE
-   **Key Path** : Software\\Policies\\Microsoft\\Windows\\WcmSvc\\GroupPolicy
-   **Value name** : fBlockNonDomain
-   **Value type** : REG\_DWORD
-   **Value data** : 2

gpupdate /force

* * *

## 4 - Send NTLMv2 response only. Refuse LM & NTLM :

  

The importance of using “**Send NTLMv2 response only. Refuse LM & NTLM**” in Windows machines is to reinforce network authentication security.

Here's what it does :

✅ **Use NTLMv2 only** : This policy configures client devices to use only NTLMv2 for authentication. NTLMv2 is a more secure version of the NTLM protocol, offering better protection against replay and man-in-the-middle attacks.

✅ **Refuse older versions** : Refuses authentication using less secure versions of LM (LAN Manager) and NTLM (NTLMv1). This prevents devices and services that do not support NTLMv2 from authenticating, thus increasing overall network security.

In short, this policy helps ensure that only the most secure authentication methods are used, reducing the risk of credentials being compromised.

  

### A - Can be applied on :

-   Windows 10 (all versions)
-   Windows 11
-   Windows Server 2008 R2, 2012, 2016, 2019, 2022, and later versions

### B - Detect :

$key = "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa"
$valueName = "LmCompatibilityLevel"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 5) {
        Write-Host "Send NTLMv2 response only. Refuse LM & NTLM is enabled." -ForegroundColor Green
    }
    else {
        Write-Host "Prohibit connection to non-domain networks when connected to domain authenticated network is disabled." -ForegroundColor Red
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShell Configuration :

This script must be executed as **Administrator** :

 $RegistryPath = 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa' 
$Name  = 'LmCompatibilityLevel'
$Value   = '5'

Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Type DWORD

### D - GPO Configuration :

Computer Configuration\\Policies\\Windows Settings\\Security Settings\\Local Policies\\Security Options\\Network security\\LAN Manager authentication level

To the following value : **Send NTLMv2 response only. Refuse LM & NTLM**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQGgmahxRiETbA/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731094972943?e=1751500800&v=beta&t=yGxV46piyiBihrNiS1YeLMtNSyGzii_APhIRjeKYcAg)

gpupdate /force

* * *

## 5 - Disable 'Enumerate administrator accounts on elevation' :

  

The **"List administrator accounts on elevation ”** feature in Windows controls whether administrator accounts are displayed when standard users attempt to run an application with elevated privileges.

Purpose of this feature:

-   **Enhanced security** : When disabled, users must enter both the username and password of an administrator account to elevate an application. This prevents unauthorized users from viewing available administrator accounts, reducing the risk of brute-force attacks.
-   **Access control** : By requiring full credentials, this feature enhances security by ensuring that only authorized people can perform actions requiring elevated privileges.

In short, this policy prevents the enumeration of administrator accounts during privilege elevation, reducing the attack surface by hiding privileged account information.

### A - Can be applied on :

-   Windows 10 (all versions)
-   Windows 11
-   Windows Server 2012, 2016, 2019, 2022, and later versions

### B - Detect :

$key = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\CredUI"
$valueName = "EnumerateAdministrators"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 0) {
        Write-Host "Enumerate administrator accounts on elevation is disabled ." -ForegroundColor Green
    }
    else {
        Write-Host "Enumerate administrator accounts on elevation is enabled." -ForegroundColor Red
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShell Configuration :

\# Create New Key
New-Item -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies" -Name "CredUI"
# Add DWORD Property and value
New-Item -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\CredUI" -Name "EnumerateAdministrators" -Value 0 -Type DWORD

### D - GPO Configuration :

**Path** : Computer configuration\\Policies\\Windows Components\\Credantial User Interface

**Policy** : "Enumerate administrator accounts on elevation"

**Value** : **Disabled**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQFBSdJN386EEA/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731124505889?e=1751500800&v=beta&t=H-DGlwK-SQocClDf-K9GUEro2NeDKo5xxt8Zn3PwKkk)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQF5_WifdRcbPA/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731124628425?e=1751500800&v=beta&t=RaeVNzKjvTCtwKXGsiPWgKUw_gGcNlIX7iCXeMOvDdA)

gpupdate /force

* * *

## 6 - Set controlled folder access to enabled or audit mode :

  

Windows' **Controlled Folder Access** feature is designed to protect your important files from unauthorized modification by malware, such as ransomware. When activated, this feature prevents suspicious applications from modifying or deleting files in protected folders.

You can activate controlled folder access in either **Activated** or **Audit** mode.

-   In **Activated** mode, unauthorized modifications are blocked and recorded in Windows event logs.
-   In **Audit** mode, modifications are authorized, but saved so that you can examine them without affecting the normal use of your device.

This feature is particularly useful for protecting against ransomware attacks that attempt to encrypt your files and hold them hostage.

### A - Can be applied on :

-   Windows 10 (version 1709 and later)
-   Windows 11
-   Windows Server 2019 and later versions

### B - Detect :

get-MpPreference | select EnableControlledFolderAccess 

-   **1** : Policy configured with Enabled mode
-   **2 :** Policy configured with Audit mode
-   **Error** : Policy not configured

### C - PowerShell configuration :

\# To enable
Set-MpPreference -EnableControlledFolderAccess Enabled

\# To audit
Set-MpPreference -EnableControlledFolderAccess AuditMode

### D - GPO Configuration :

**Path** : Computer Configuration\\Policies\\Administrative Templates\\Windows Components\\Windows Defender Antivirus\\Windows Exploit Guard\\Controlled Folder Access

Policy : "**Configure Controlled folder access**"

Value : **Enabled** or **Audit Mode**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQHKT2fBg9aiCw/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731168197035?e=1751500800&v=beta&t=Dv9zv-VOqhTeAXOT4qyDqidfwiOb-Nyeh_V6_hRCh7M)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQG2vx2fofW15g/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731168445411?e=1751500800&v=beta&t=dO8Ht2ThH0TMP0RxgJWRVxOaav4Cy1-s0aN6Yeyg4GI)

gpupdate /force

* * *

## 7 - Disable 'Autoplay' for all drives :

  

Windows' **AutoPlay** feature lets you choose a default action for different types of media or peripherals when you connect them to your computer. For example, AutoPlay can automatically open photos, play music or run videos as soon as you insert a removable disk, CD, DVD, memory card, or connect a camera or phone.

Benefits of disabling AutoPlay :

-   **Increased security** : By disabling AutoPlay, you reduce the risk of malware automatically executing on external devices.
-   **User control** : You have more control over what happens when you connect a new device, avoiding unwanted interruptions.

### A - Can be applied on :

-   Windows 10 (all versions)
-   Windows 11
-   Windows Server 2008, 2012, 2016, 2019, 2022, and later versions

### B - Detect :

$key = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer"
$valueName = "NoDriveTypeAutoRun"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 255) {
        Write-Host "Autoplay is disabled ." -ForegroundColor Green
    }
    else {
        Write-Host "Autoplay is enabled." -ForegroundColor Red
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShell Configuration :

Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer" -Name "NoDriveTypeAutoRun" -Value 255 -Type DWORD

### D - GPO Configuration :

Path : **Computer Configuration\\Policies\\Administrative Templates\\Windows Components\\AutoPlay Policies**

Policy: "**Turn off AutoPlay**"

Value : **Enabled (All Drives)**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQH3al--LowRlw/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731192038974?e=1751500800&v=beta&t=0SDn0aYpakML7pQvMLZyauTq2zd-RKur6smJYW_hlEs)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQHMdEDt4v6jpQ/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1731192085282?e=1751500800&v=beta&t=uaJGx5u_7kkb8kt937M12hxrZQf8b91LQ4x2vae4SYs)

gpupdate /force

* * *

## 8 - Disable 'Allow Basic authentication' for WinRM Client :

  

The **"Allow basic authentication”** feature for the Windows Remote Management (WinRM) client enables WinRM to use basic authentication, which sends credentials in clear text.

Benefits of disabling this feature:

-   **Enhanced security** : Disabling basic authentication prevents passwords from being sent in clear text, reducing the risk of credentials being compromised.
-   **Compliance** : For organizations subject to strict security standards, disabling this feature may be a requirement for regulatory compliance.

### A - Can be applied on :

-   Windows 10 (all versions)
-   Windows 11
-   Windows Server 2012, 2016, 2019, 2022, and later versions

### B - Detect :

$key = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WSMAN\\Client"
$valueName = "AllowBasic"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 0) {
        Write-Host "Basic authentication for WinRM Client is disabled." -ForegroundColor Green
    }
    else {
        Write-Host "Basic authentication for WinRM Client is enabled." -ForegroundColor Red
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShell configuration :

Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WSMAN\\Client" -Name "AllowBasic" -Value 0 -Type DWord

### D - GPO Configuration :

Path : **Computer Configuration\\Policies\\Administrative Templates\\Windows Components\\Windows Remote Management (WinRM)\\WinRM Client**

Policy : "**Allow Basic authenication**"

Value : **Disabled**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQHWrsCjM1l6CQ/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731194555976?e=1751500800&v=beta&t=PI9YoPAyc-9TkkugwKmVA-Ti32eoJWivHv80z_BLeho)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQEC1BpUlisq3A/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1731194580727?e=1751500800&v=beta&t=qnrRijwH_KpbjDk9VgrUpm3FnM7MycTvCbDlXnVt-GE)

gpupdate /force

* * *

## 9 - Disable 'Allow Basic authentication' for WinRM Service

  

Disables basic authentication for the WinRM service, enhancing security by preventing passwords from being sent in the clear.

### A - Can be applied on :

-   Windows 10 (all versions)
-   Windows 11
-   Windows Server 2012, 2016, 2019, 2022, and later versions

### B - Detect :

$key = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WSMAN\\Service"
$valueName = "AllowBasic"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 0) {
        Write-Host "Basic authentication for WinRM Service is disabled." -ForegroundColor Green
    }
    else {
        Write-Host "Basic authentication for WinRM Service is enabled." -ForegroundColor Red
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShell configuration :

Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WSMAN\\Service" -Name "AllowBasic" -Value 0 -Type DWord

### D - GPO Configuration :

Path : **Computer Configuration\\Policies\\Administrative Templates\\Windows Components\\Windows Remote Management (WinRM)\\WinRM Service**

Policy : "**Allow Basic authenication**"

Value : **Disabled**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQH37QauxMomXg/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731196093278?e=1751500800&v=beta&t=M8U0b8Iz0kbd7MPsGjvev9xJaCXsSdNriU-xh-n9T7Q)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQErnLjzcH3rUw/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1731196113707?e=1751500800&v=beta&t=j1sa8iUv6Eg7YPny0KwQmWFgawChJ6rqKNQZr8ZgmXE)

gpupdate /force

* * *

## 10 - Remove SMBv1 :

  

The use of SMBv1 (Server Message Block version 1) in Windows machines presents several major security risks. This protocol is obsolete and contains numerous vulnerabilities that can be exploited by malware to propagate from one machine to another. For example, notorious attacks such as WannaCry and NotPetya have used SMBv1 to spread rapidly across networks. What's more, SMBv1 doesn't support modern security features such as encryption and data integrity, making it particularly vulnerable to man-in-the-middle attacks and remote code execution. Because of these risks, we strongly recommend disabling SMBv1 and using more recent versions of the SMB protocol, such as SMBv2 or SMBv3, which offer significant security enhancements.

### A - Can be applied on :

-   Windows 10 (from version 1709) ,
-   Windows 11
-   Windows Server 2012 R2, 2016, 2019, 2022

### B - Detect :

Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQFUebxUvEw2XA/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731199390721?e=1751500800&v=beta&t=TBKjC5lXOwKkvm4fpKFEHugLkzdEG9lcuoJzFAAvoWI)

### C - PowerShell Configuration:

Here are the steps to detect, disable and enable SMBv1 client and server by using PowerShell commands with elevation.

**Note :**

The computer will restart after you run the PowerShell commands to disable SMBv1.

Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

### D - GPO Configuration :

Create New Policy, then Edit it :

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQF9zmMQfL99HQ/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731199390872?e=1751500800&v=beta&t=5Wjo9aIzB2mH4z5Fzk_BE8j_Sug0I1a8m9rZZ2m1mwA)

-   **Action**: Create
-   **Hive**: HKEY\_LOCAL\_MACHINE
-   **Key Path**: SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters
-   **Value name**: SMB1
-   **Value type**: REG\_DWORD
-   **Value data**: 0

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQFkmVUIO4pHmQ/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731199390737?e=1751500800&v=beta&t=16IHLokPHvw3gKlW9_U_cdSUi1_sD4cfSW05Jv8hK-M)

gpupdate /force

* * *

