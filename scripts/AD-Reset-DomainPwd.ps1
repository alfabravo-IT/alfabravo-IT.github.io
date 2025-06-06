<#
.SYNOPSIS
    Script for resetting user passwords in Active Directory.
    The script reads a list of users from a text file, resets their passwords, unlocks locked accounts, and generates a report.

.DESCRIPTION
    This script performs the following operations:
    1. Reads a list of users (one per line) from the specified file.
    2. For each user, generates a random complex password of 20 characters.
    3. Resets the password for the user in Active Directory.
    4. Unlocks the account, if necessary.
    5. Logs the details of each operation, including the user, the new password, and the operation status, in a report file.
    
    The report contains:
    - The username
    - The new password (to be saved separately for security reasons)
    - The operation status (Success, Failed, UserNotFound)

.PARAMETER UsersFile
    The text file containing the list of users whose passwords need to be reset. Each line should contain a username.

.PARAMETER ReportFile
    The output text file that will contain the results of the password reset, including any errors.

.EXAMPLE
    Reset-DomainPwd.ps1
    Run the script to reset the passwords of users defined in the file "reset-domain-pwd-elenco.txt"
    and generate a report "reset-domain-pwd-report.txt".

.NOTES
    Script created by: Andrea Balconi
    Creation date: 2025-04-29
    Version: 2.0
    Changes: Added error handling, improved reporting.
#>

# Define the path of the file containing the list of users (one per line)
$UsersFile = "$PSScriptRoot\Reset-DomainPwd_list.txt"

# Define the path of the report file
$ReportFile = "$PSScriptRoot\Reset-DomainPwd_report.txt"

# Function to generate a random complex password of 20 characters
function New-PasswordCasuale {
    $length = 20
    $characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%&?"
    $password = -join (1..$length | ForEach-Object { $characters[(Get-Random -Minimum 0 -Maximum $characters.Length)] })
    return $password
}

# Read the list of users from the file
$Users = Get-Content -Path $UsersFile

# Initialize the array for the report
$Report = @()

foreach ($User in $Users) {
    # Trim to avoid unwanted whitespace
    $User = $User.Trim()

    # Check if the user exists in Active Directory
    $userExists = Get-ADUser -Identity $User -ErrorAction SilentlyContinue
    if ($userExists) {
        # Generate a new random password
        $NewPassword = New-PasswordCasuale

        # Perform the password reset for the user
        try {
            Set-ADAccountPassword -Identity $User -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force) -Reset
            Unlock-ADAccount -Identity $User

            # Add to the report
            $Report += [PSCustomObject]@{
                User         = $User
                NewPassword  = $NewPassword
                Status       = "Success"
            }
            Write-Output "Password reset successful for user: $User"
        } catch {
            # Handle errors and write to the report
            $Report += [PSCustomObject]@{
                User         = $User
                NewPassword  = "N/A"
                Status       = "Failed - $($_.Exception.Message)"
            }
            Write-Output "Password reset failed for user: $User. Error: $_"
        }
    } else {
        # Write the user not found to the report
        $Report += [PSCustomObject]@{
            User         = $User
            NewPassword  = "N/A"
            Status       = "UserNotFound"
        }
        Write-Output "User not found: $User"
    }
}

# Export the results to the report file
$Report | Export-Csv -Path $ReportFile -NoTypeInformation -Encoding UTF8

Write-Output "Password reset process completed. Report saved in: $ReportFile"
# End of script