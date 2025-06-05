# Essantial Security Settings to Harden Windows Machines : (part 2)

Update: 26 novembre 2024

## 1 - Disable Solicited Remote Assistance :
The **"Disable Solicited Remote Assistance"** policy controls whether users can request remote assistance on a computer. When enabled, it **prevents users from sending invitations** for remote assistance, reducing the risk of unauthorized remote access or misuse of the feature.

Remote Assistance allows a user to share their desktop session with a helper (another user) who can view or control the desktop remotely. Disabling solicited remote assistance helps to enhance security by blocking this feature, especially in environments where remote desktop control is not required or is considered a security risk.

### A - Can be applied on :

This policy can be applied to the following operating systems:

-   Windows 10 (all editions)
-   Windows 11 (all editions)
-   Windows Server (2016, 2019, 2022, and later versions)

### B - Detect :

To check if this policy is configured on your computer :

$key = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services"
$valueName = "fAllowToGetHelp"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 0) {
        Write-Host "Solicited Remote Assistance is disabled." -ForegroundColor Green
    } else {
        Write-Host "Solicited Remote Assistance is enabled." -ForegroundColor Yellow
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShel Configuration :

Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services" -Name "fAllowToGetHelp" -Value 0 -Type DWORD

### D - GPO Configuration :

Path : **Computer Configuration\\Policies\\Administrative Templates\\System\\Remote Assistance**

Policy : **Configure Solicited Remote Assistance**.

Value : **Disabled**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQEe5itg9V8ZMA/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731249951931?e=1751500800&v=beta&t=85OG7zROUuLOCMf-s-sB8mxsKAt0VOyyKdYmtB8rjwo)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQFoP65iEU090g/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1731250086124?e=1751500800&v=beta&t=xjfuv2NHn8uxmbRQOD2PQEJ0ZklG6c6Kwgfhijg9J8U)

gpupdate /force

* * *

## 2 - Disable Anonymous Enumeration of Shares :

  

The **"Disable Anonymous Enumeration of Shares"** policy prevents unauthorized users (anonymous users) from viewing shared folders on a Windows computer or server. If this setting is not configured, attackers could potentially enumerate shared resources without providing valid credentials, increasing the risk of information leakage and unauthorized access.

By disabling anonymous enumeration of shares, only authenticated users can list shared folders, which is crucial for securing your environment and reducing the attack surface.

### A - Can be applied on :

This policy can be applied to the following operating systems:

-   Windows 10 (all editions)
-   Windows 11 (all editions)
-   Windows Server (2016, 2019, 2022, and later versions)

### B - Detect :

To check if this policy is configured on your computer :

$key = "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters"
$valueName = "RestrictAnonymous"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 1) {
        Write-Host "Anonymous enumeration of shares is disabled." -ForegroundColor Green
    } elseif ($value -eq 0) {
        Write-Host "Anonymous enumeration of shares is enabled." -ForegroundColor Red
    } else {
        Write-Host "Policy is configured with an unexpected value." -ForegroundColor Yellow
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShel Configuration :

Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters" -Name "RestrictAnonymous" -Value 1 -Type DWord

### D - GPO Configuration :

Path : **Computer Configuration\\Policies\\Windows Settings\\Local Policies\\Security Options**

Policy : **Network access: Do not allow anonymous enumeration of SAM accounts and shares**

Value : **Enabled**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQHQDqtH3-iJ3Q/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731252129708?e=1751500800&v=beta&t=f0uuQMlSJ3VEq11_NmSnDRyNlPM3JmBbbIKm5h2K_8s)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQFq6hBjfVTa8A/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731252217711?e=1751500800&v=beta&t=bqiBnGoZeYRvZ-2B5Q7noFgkfwC93vzSgfYUhtiz5gI)

gpupdate /force

* * *

## 3 - Set folder access-based enumeration for shares :

  

The **"Set Folder Access-Based Enumeration (ABE) for Shares"** policy controls whether users can see only the files and folders they have permission to access in a shared network folder. With **Access-Based Enumeration (ABE)** enabled:

-   Users **cannot see** files or folders they do not have permission to access.
-   It **enhances security** by hiding content from unauthorized users.
-   It reduces **information disclosure risks**, preventing users from discovering the existence of files or folders they should not know about.

This feature is particularly useful in shared environments where multiple users have different levels of access to the same shared folder.

### A - Can be applied on :

This policy can be applied to:

-   Windows Server (2008 R2, 2012 R2, 2016, 2019, 2022, and later versions)

**Note**: The ABE feature is primarily used on Windows Server operating systems where shared folders are configured.

### B - Detect :

To check if this policy is configured on your computer :

Get-SmbShare | Select-Object Name, FolderEnumerationMode

### C - PowerShel Configuration :

Set-SmbShare -Name "ShareName" -FolderEnumerationMode AccessBased
Write-Output "Access-Based Enumeration has been enabled for the shared folder 'ShareName'."

### D - Server Configuration :

Following the following steps and guidelines:

-   Launch **SERVER MANAGER** (Server 2012 and above)
-   Click on **FILE AND STORAGE SERVICES**
-   Click on **SHARES**
-   Right click on each share you want to set Access-Based-Enumeration, select **PROPERTIES**
-   Click **SETTINGS**
-   Click **ENABLE ACCESS BASED ENUMERATION**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQEq6euha744gQ/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731293954016?e=1751500800&v=beta&t=_AJD5KvZJIKMBh_P9jW_3OPd_STOuqyT3VdXXXrBgeY)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQE5nQRCACdaBw/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731293978551?e=1751500800&v=beta&t=dpuHesprSZA4Mx0AzTNFmSxIZI6rNBRFsi3oeLmUdwA)

gpupdate /force

* * *

## 4 - Set user authentication for remote connections using Network Level Authentication :

  

The **"Set User Authentication for Remote Connections Using Network Level Authentication (NLA)"** policy ensures that users authenticate before establishing a Remote Desktop Protocol (RDP) session. With NLA enabled, the client must authenticate first, before the Remote Desktop session is created.

This improves security by :

-   Reducing the risk of **unauthorized access**.
-   Preventing **Denial of Service (DoS)** attacks against the RDP service.
-   Requiring **stronger authentication methods** like NTLM or Kerberos.

Enabling NLA significantly reduces the attack surface for Remote Desktop Services by blocking unauthenticated users from connecting.

### A - Can be applied on :

This policy can be applied to:

-   Windows 10 (all editions)
-   Windows 11 (all editions)
-   Windows Server (2012 R2, 2016, 2019, 2022, and later versions)

### B - Detect :

To check if this policy is configured on your computer :

$key = "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp"
$valueName = "UserAuthentication"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 1) {
        Write-Host "Network Level Authentication (NLA) is enabled." -ForegroundColor Green
    } else {
        Write-Host "Network Level Authentication (NLA) is disabled." -ForegroundColor Red
    }
} else {
    Write-Output "Policy not configured."
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShel Configuration :

Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp" -Name "UserAuthentication" -Value 1 -Type DWord

### D - GPO Configuration :

Path : **Computer Configuration\\Policies\\Administrative Templates\\Windows Components\\Remote Desktop Services\\Remote Desktop Session Host\\Security**

Policy : **Require user authentication for remote connections by using Network Level Authentication**

Value : **Enabled**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQGQi1v_S8qjaA/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731267024668?e=1751500800&v=beta&t=VPR2c6kF8emRmMG77akOVLnmD-2jd4s_YsdEccfl_j0)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQGPjGJCDeFcow/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1731267070949?e=1751500800&v=beta&t=RCr_KbFzlnisv3E6aY2mMIaLj4w4oW-AaowQ60KNeYA)

gpupdate /force

* * *

## 5 - Disable 'Installation and configuration of Network Bridge'

  

The **"Disable 'Installation and Configuration of Network Bridge'"** policy prevents users from creating or configuring a network bridge on their device. A **network bridge** is a feature that allows two or more network connections to act as a single network. While useful in some scenarios, allowing users to create a network bridge can pose security risks, such as:

-   **Bypassing network controls** and firewall rules.
-   Enabling unauthorized **network access** or creating unintended connections.
-   **Inadvertently exposing internal networks** to external threats.

By disabling this capability, you can reduce the attack surface and maintain better control over network configuration.

### A - Can be applied on :

This policy can be applied to:

-   **Windows 10** (all editions)
-   **Windows 11** (all editions)
-   **Windows Server** (2012 R2, 2016, 2019, 2022, and later versions)

### B - Detect :

To check if this policy is configured on your computer :

$key = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Network Connections"
$valueName = "NC\_AllowNetBridge\_NLA"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 0) {
        Write-Host "Installation and configuration of Network Bridge is disabled." -ForegroundColor Green
    } else {
        Write-Host "Installation and configuration of Network Bridge is enabled." -ForegroundColor Red
    }
} else {
    Write-Output "Policy not configured."
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShel Configuration :

Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Network Connections" -Name "NC\_AllowNetBridge\_NLA" -Value 0 -Type DWord

### D - GPO Configuration :

Path : **Computer Configuration\\Policies\\Administrative Templates\\Network\\Network Connections**

Policy : **Prohibit installation and configuration of Network Bridge on your DNS domain network**

Value : **Enabled**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQHqdYhu1CVvuA/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731267929800?e=1751500800&v=beta&t=KHJS5XRGkci5mPZYTWbP6OWHeppGFNk0v2ynV5cPHFw)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQHWX_JZgvIBqg/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1731267998753?e=1751500800&v=beta&t=m0IHYlRfD1OATI4ifi2fvApyFRyxAkiDppHA2ajyh0w)

gpupdate /force

* * *

## 6 - Disable the local storage of passwords and credentials :

  

The **"Disable the local storage of passwords and credentials"** policy prevents Windows from caching user credentials locally. By default, Windows can store credentials (e.g., usernames and passwords) for later use, allowing features like automatic login to shared resources. However, storing credentials locally can present security risks, including:

-   Exposure of cached credentials if the system is compromised.
-   Increased risk of **credential theft** attacks (e.g., pass-the-hash or pass-the-ticket attacks).
-   Potential unauthorized access, especially on shared or multi-user systems.

Disabling local storage of passwords and credentials helps protect against these risks by ensuring that credentials are not stored on the device.

### A - Can be applied on :

This policy can be applied to:

-   **Windows 10** (all editions)
-   **Windows 11** (all editions)
-   **Windows Server** (2012 R2, 2016, 2019, 2022, and later versions)

### B - Detect :

To check if this policy is configured on your computer :

$key = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\CredentialsDelegation"
$valueName = "DisablePasswordSaving"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 1) {
        Write-Host "Local storage of passwords and credentials is disabled." -ForegroundColor Green
    } else {
        Write-Output "Local storage of passwords and credentials is enabled."
        Write-Host "Local storage of passwords and credentials is enabled." -ForegroundColor Red
    }
} else {
    Write-Output "Policy not configured."
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShel Configuration :

New-Item -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\CredentialsDelegation" -Force
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\CredentialsDelegation" -Name "DisablePasswordSaving" -Value 1 -Type DWORD

### D - GPO Configuration :

Path : **Computer Configuration\\Policies\\Windows Settings\\Local Policies\\Security Options**

Policy : **Network access: Do not allow storage of passwords and credentials for network authentication**

Value : **Enabled**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQEBvE7YwuPacw/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731268630023?e=1751500800&v=beta&t=DkAMnbC9NFuTBsD1B4vIIA51R0AcoUQG65ySb1lCZBU)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQEvSZmqEPwB3Q/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731268714522?e=1751500800&v=beta&t=AM42LXo8Rs-H_samWWIUZYFnqUHZ6cWuFmsJ_Se2xsg)

gpupdate /force

* * *

## 7 - Enable 'Microsoft network client: Digitally sign communications (always)' :

  

The **"Microsoft network client: Digitally sign communications (always)"** policy enforces the use of **digital signatures** for all SMB (Server Message Block) communications from the client. When this policy is enabled, the client must digitally sign all SMB packets sent to the server. This ensures:

-   **Integrity**: Protects against man-in-the-middle attacks by verifying that the data has not been tampered with during transit.
-   **Authentication**: Confirms that the data was sent by a legitimate client.
-   **Security**: Prevents unauthorized modifications of SMB packets.

Enabling this policy enhances the security of network communications, especially in environments where sensitive data is transmitted.

### A - Can be applied on :

This policy can be applied to:

-   **Windows 10** (all editions)
-   **Windows 11** (all editions)
-   **Windows Server** (2012 R2, 2016, 2019, 2022, and later versions)

### B - Detect :

To check if this policy is configured on your computer :

$key = "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanmanWorkstation\\Parameters"
$valueName = "RequireSecuritySignature"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 1) {
        Write-Host "Microsoft network client: Digitally sign communications (always) is enabled." -ForegroundColor Green
    } else {
        Write-Host "Microsoft network client: Digitally sign communications (always) is disabled." -ForegroundColor Red
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShel Configuration :

Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanmanWorkstation\\Parameters" -Name "RequireSecuritySignature" -Value 1 -Type DWord

### D - GPO Configuration :

Path : **Computer Configuration\\Policies\\Windows Settings\\Security Settings\\Local Policies\\Security Options**

Policy : **Microsoft network client: Digitally sign communications (always)**

Value : **Enabled**

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQG6qCrPmSHPlQ/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731270403130?e=1751500800&v=beta&t=hEjXaqZu6jV5uAx3bkAgl7fI9OD-zqecy2aTmv6M4zg)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQE7LEG7yyh4SA/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731270449395?e=1751500800&v=beta&t=neDU_YMVC5j4v2iXTMBz4eOxLjK6I9J_ptxg3vI7540)

gpupdate /force

* * *

## 8 - Account Lockout Policies :

  

The **Account Lockout Policies** are designed to help prevent unauthorized access to user accounts by temporarily locking an account after a specified number of failed login attempts. These policies include three key settings:

-   **Account Lockout Threshold**: Defines the number of failed login attempts that trigger the account lockout.
-   **Account Lockout Duration**: Specifies the amount of time (in minutes) the account remains locked.
-   **Reset Account Lockout Counter After**: Determines the time period (in minutes) after which the counter for failed login attempts is reset.

These settings help mitigate **brute-force attacks**, where an attacker attempts to guess a password by repeatedly trying different combinations.

### A - Can be applied on :

Account Lockout Policies can be applied to:

-   Windows 10 (all editions)
-   Windows 11 (all editions)
-   Windows Server (2008 R2, 2012 R2, 2016, 2019, 2022, and later versions)

### B - Detect :

To check if this policy is configured on your computer :

-   Domain Envirement :

Get-ADDefaultDomainPasswordPolicy | Select-Object LockoutThreshold, LockoutDuration, LockoutObservationWindow

-   Local Machine :

secedit /export /cfg C:\\account\_lockout\_policies.txt
Select-String -Path C:\\account\_lockout\_policies.txt -Pattern "LockoutBadCount|LockoutDuration|ResetLockoutCount"

### C - PowerShel Configuration :

$Threshold = 3
$Duration = 15
$ResetTime = 15

# Set the account lockout threshold (number of invalid login attempts)
net accounts /lockoutthreshold:$Threshold

# Set the account lockout duration (in minutes)
net accounts /lockoutduration:$Duration

# Set the time to reset the lockout counter (in minutes)
net accounts /lockoutwindow:$ResetTime

Write-Output "Account Lockout Policies have been configured: Threshold= $($Threshold), Duration= $($Duration) minutes, Reset Time= $($ResetTime) minutes."

### D - GPO Configuration :

Path : **Computer Configuration\\Policies\\Windows Settings\\Security Settings\\Account Policies\\Account Lockout Policy**

Configure the following settings:

-   **Account Lockout Threshold** : Set the number of failed login attempts (e.g., 3).
-   **Account Lockout Duration** : Set the lockout duration (e.g., 15 minutes).
-   **Reset Account Lockout Counter After** : Set the time to reset the lockout counter (e.g., 15 minutes).

Click **Apply** and **OK**.

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQFuJO9ajgPviQ/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731294778680?e=1751500800&v=beta&t=hwTdFZR7ranlxMyXN7YPP5Z8LuWuZVUV55mjpex8eR0)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQErEnO4oY0fSw/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731294908833?e=1751500800&v=beta&t=2HYuglYTzjekTw31c9PBSSANLPcG8z2K9Dg8lyqXYGY)

gpupdate /force

* * *

## 9 - Disable 'Continue running background apps when Google Chrome is closed' :

  

The **"Disable 'Continue running background apps when Google Chrome is closed'"** policy controls whether Google Chrome can continue running background processes after the browser is closed. These background processes may include extensions, notifications, or other tasks. Disabling this feature has several benefits:

-   **Improved Performance**: Frees up system resources by stopping Chrome processes when the browser is closed.
-   **Enhanced Security**: Reduces the risk of malicious extensions running in the background.
-   **Battery Optimization**: Saves battery life on laptops by reducing CPU usage when Chrome is closed.

This policy is particularly useful in enterprise environments to prevent unnecessary resource consumption.

### A - Can be applied on :

This policy can be applied to:

-   Windows 10 (all editions)
-   Windows 11 (all editions)
-   Windows Server (2012 R2, 2016, 2019, 2022, and later versions)

### B - Detect :

To check if this policy is configured on your computer :

$key = "HKLM:\\SOFTWARE\\Policies\\Google\\Chrome"
$valueName = "BackgroundModeEnabled"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 0) {
        Write-Host "Chrome background apps are disabled when the browser is closed." -ForegroundColor Green
    } else {
        Write-Host "Chrome background apps are enabled when the browser is closed." -ForegroundColor Red
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShel Configuration :

New-Item -Path "HKLM:\\SOFTWARE\\Policies\\Google\\Chrome" -Force
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Google\\Chrome" -Name "BackgroundModeEnabled" -Value 0 -Type DWord

### D - GPO Configuration :

To configure this policy using Group Policy, you need the **Google Chrome ADMX templates**:

1.  Download the **Google Chrome ADMX templates** from the Google Chrome Enterprise Help Center.
2.  Copy the ADMX file (chrome.admx) and the language file (chrome.adml) to your Group Policy Central Store (C:\\Windows\\PolicyDefinitions).
3.  Open the **Group Policy Management Console (GPMC)**.
4.  Navigate to : **Computer Configuration\\Administrative Templates\\Google\\Google Chrome**
5.  Locate the policy **"Continue running background apps when Google Chrome is closed"**.
6.  Set the policy to **"Disabled"**.
7.  Click **Apply** and **OK**.

gpupdate /force

* * *

## 10 - Enable 'Require domain users to elevate when setting a network's location' :

  

The **"Require domain users to elevate when setting a network's location"** policy controls whether standard domain users are required to provide administrative credentials when changing the network location type (e.g., Public, Private, or Domain) on their machine. The network location type impacts the firewall settings and the level of network sharing, which can affect security:

-   **Public Network**: Most restrictive, used in public places like coffee shops. Limited sharing and stricter firewall rules.
-   **Private Network**: Used for trusted networks like home or office. Allows sharing and more relaxed firewall rules.
-   **Domain Network**: Automatically detected when connected to a domain. Uses domain policies.

This policy prevents standard domain users from accidentally or maliciously changing the network location type, which could weaken the security settings. It helps ensure that only authorized administrators can change the network location, maintaining a consistent security posture.

### 2\. Supported Operating Systems

This policy can be applied to:

-   **Windows 10** (Professional, Enterprise, and Education editions)
-   **Windows 11** (Professional, Enterprise, and Education editions)
-   **Windows Server** (2012 R2, 2016, 2019, 2022, and later versions)

### A - Can be applied on :

This policy can be applied to:

-   Windows 10 (all editions)
-   Windows 11 (all editions)
-   Windows Server (2012 R2, 2016, 2019, 2022, and later versions)

### B - Detect :

To check if this policy is configured on your computer :

$key = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Network Connections"
$valueName = "NC\_StdDomainUserSetLocation"

if (Get-ItemProperty -Path $key -Name $valueName -ErrorAction SilentlyContinue) {
    $value = (Get-ItemProperty -Path $key).$valueName
    if ($value -eq 1) {
        Write-Host "Policy is enabled: Domain users must elevate to change the network location." -ForegroundColor Green
    } else {
        Write-Host "Policy is disabled: Domain users can change the network location without elevation." -ForegroundColor Red
    }
} else {
    Write-Host "Policy not configured." -ForegroundColor Red
}

### C - PowerShel Configuration :

New-Item -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Network Connections" -Force
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Network Connections" -Name "NC\_StdDomainUserSetLocation" -Value 1 -Type DWord

### D - GPO Configuration :

-   Path : Computer Configuration\\Policies\\Administrative Templates\\Network\\Network Connections
-   Policy **"Require domain users to elevate when setting a network's location"**.
-   Value : **"Enabled"**.

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQHv1Mdp8DESDA/article-inline_image-shrink_1500_2232/article-inline_image-shrink_1500_2232/0/1731296457901?e=1751500800&v=beta&t=uxWPC7gCYg_LTd6AKGLh6t0vWPJTInSRQMrDGbXQsuc)

![Contenuto dell’articolo](https://media.licdn.com/dms/image/v2/D4E12AQEEFZN1mdi41Q/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1731296484103?e=1751500800&v=beta&t=7k75-3cGvg3MYplv4uFlBOOj9tA4bgFNaYd776611lk)

gpupdate /force

* * *

