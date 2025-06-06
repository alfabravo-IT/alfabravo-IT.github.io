<#
.SYNOPSIS
    Creates or modifies a Group Policy to configure the registry parameter `LocalAccountTokenFilterPolicy`.

.DESCRIPTION
    The script checks if a GPO named "Disable-UAC-RemoteAccess" already exists.
    If it does not exist, it creates it. In both cases, it sets the necessary registry key to enable 
    remote access with local administrative accounts, useful in remote management scenarios.
    
    This is particularly relevant to avoid issues with UAC (User Account Control) 
    when using tools like PsExec or WMI with local accounts.

.AUTHOR
    Andrea Balconi

.DATE
    29/04/2025

.NOTES
    Remember to manually link the GPO to the necessary OUs after creation.
#>

# Import the GroupPolicy module
Import-Module GroupPolicy

# GPO Name
$GpoName = "Disable-UAC-RemoteAccess"

# Check if the GPO exists
if (-not (Get-GPO -Name $GpoName -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoName -Comment "Configures the registry value LocalAccountTokenFilterPolicy"
    Write-Host "GPO created: $GpoName"
} else {
    Write-Host "The GPO already exists: $GpoName"
}

# Set the registry value via the GPO
$RegKeyPath = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$RegValueName = "LocalAccountTokenFilterPolicy"
$RegValueType = "DWord"
$RegValueData = 1

Set-GPRegistryValue -Name $GpoName -Key $RegKeyPath -ValueName $RegValueName -Type $RegValueType -Value $RegValueData
Write-Host "Registry key configured in the GPO."

# Final message
Write-Host -ForegroundColor Green "The GPO '$GpoName' has been successfully configured. Remember to link it to the necessary OUs."
