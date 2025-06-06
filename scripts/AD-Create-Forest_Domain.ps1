<#
.SYNOPSIS
    Script for creating a new Active Directory forest and domain on Windows Server.

.DESCRIPTION
    This PowerShell script automates the installation of required roles (Active Directory Domain Services, DNS, RSAT-AD-PowerShell),
    checks for the presence of required modules, collects domain parameters via interactive input, and promotes the server to Domain Controller
    by creating a new forest and domain. It also securely prompts for the DSRM password.

.PARAMETER domainName
    Full name of the domain to create (e.g., lab.local). Prompted interactively.

.PARAMETER netbiosName
    NetBIOS name of the domain (e.g., LAB). Prompted interactively.

.PARAMETER dsrmPassword
    Password for Directory Services Restore Mode (DSRM). Prompted securely.

.NOTES
    - The script must be run as administrator.
    - If required roles are not installed, the script will install them and prompt for a reboot.
    - After promotion to Domain Controller, the machine will automatically reboot.
    - Compatible with Windows Server supporting ADDSDeployment cmdlets.

.AUTHOR
    Andrea Balconi

.EXAMPLE
    Run the script as administrator:
        .\AD-Create-Forest_Domain.ps1

    Follow the on-screen instructions to enter the required parameters.
#>
function Info($msg)  { Write-Host "🔹 $msg" -ForegroundColor Cyan }
function Ok($msg)    { Write-Host "✅ $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "⚠️ $msg" -ForegroundColor Yellow }
function Fail($msg)  { Write-Host "❌ $msg" -ForegroundColor Red }

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrator")) {
    Fail "You must run this script as administrator!"
    exit 1
}

# Step 1: Install required roles and modules
$features = @("AD-Domain-Services", "DNS", "RSAT-AD-PowerShell")
$missing = $features | Where-Object { -not (Get-WindowsFeature $_).Installed }

if ($missing.Count -gt 0) {
    Info "Installing the following components: $($missing -join ', ')"
    Install-WindowsFeature -Name $missing -IncludeManagementTools -Verbose

    Warn "Restart the machine to complete the installation of the modules. Then re-run the script."
    pause
    exit
} else {
    Ok "All required roles and modules are already present."
}

# Step 2: Check if the module is available
if (-not (Get-Command Install-ADDSForest -ErrorAction SilentlyContinue)) {
    Fail "ADDSDeployment module not found. Close and reopen PowerShell as Admin after installing the roles."
    exit 1
}

# Step 3: Domain parameters (interactive input)
$domainName = Read-Host "🌐 Enter the domain name (e.g.: lab.local)"
$netbiosName = Read-Host "🖥️  Enter the NetBIOS name (e.g.: LAB)"

# Step 4: Prompt for DSRM password securely
$dsrmPassword = Read-Host "🔐 Enter the DSRM password (Directory Services Restore Mode)" -AsSecureString

# Step 5: Promote to Domain Controller
Info "Promoting the server to Domain Controller for domain $domainName..."

Install-ADDSForest `
    -DomainName $domainName `
    -DomainNetbiosName $netbiosName `
    -SafeModeAdministratorPassword $dsrmPassword `
    -InstallDNS `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true

# The machine will automatically reboot at the end.