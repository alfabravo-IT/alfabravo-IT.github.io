<#
    Author   : Andrea Balconi
    Date     : 29/04/2025
    Version  : 1.0    

    Description:
    This script retrieves information about Group Policy Objects (GPO) in an Active Directory domain
    and analyzes the links of the GPOs to Organizational Units (OUs). The final result is a report that
    shows the name of the GPO and the OUs it is linked to, saved in HTML format.

    Main Features:
    - Retrieves all GPOs in the domain.
    - Generates XML reports for each GPO to analyze the links to OUs.
    - Saves the results in an HTML table with the GPO name and linked OUs.
    - Deletes temporary files generated during script execution.

    Requirements:
    - ActiveDirectory module installed and administrative access to the domain.

    Usage:
    Run the script on an administrative machine with access to the domain to obtain the report
    of GPOs and their Organizational Units, saved in an HTML file.
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Retrieve the domain name
$domainName = (Get-ADDomain).DNSRoot

# Create a list to save the results
$results = @()

# Get all GPOs in the domain
$gpos = Get-GPO -All

# Iterate through all GPOs and generate reports to get the links
foreach ($gpo in $gpos) {
    # Generate an XML report for the GPO
    $reportPath = "$PSScriptRoot\$($gpo.DisplayName).xml"
    Get-GPOReport -Name $gpo.DisplayName -Domain $domainName -ReportType XML -Path $reportPath

    # Load the XML content to analyze the links to OUs
    $reportXml = [xml](Get-Content -Path $reportPath)
    $links = $reportXml.GPO.LinksTo | Select-Object -ExpandProperty SOMPath

    # Add the link information to the results list
    foreach ($link in $links) {
        $results += [PSCustomObject]@{
            "GPO Name" = $gpo.DisplayName
            "Linked OU" = $link
        }
    }

    # Remove the temporary report file
    Remove-Item -Path $reportPath
}

# Save the results in an HTML file in the same directory as the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlReportPath = Join-Path -Path $scriptDirectory -ChildPath "AD_GPO_Link_Report.html"

# Create the HTML content
$htmlContent = @"
<html>
<head>
    <title>GPO Links Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { padding: 8px; border: 1px solid #ddd; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>GPO Links Report</h1>
    <table>
        <tr><th>GPO Name</th><th>Linked OU</th></tr>
        $($results | ForEach-Object { "<tr><td>$($_.'GPO Name')</td><td>$($_.'Linked OU')</td></tr>" } | Out-String)
    </table>
</body>
</html>
"@

# Save the HTML file
$htmlContent | Out-File -FilePath $htmlReportPath -Encoding UTF8

Write-Host "Report saved in: $htmlReportPath"
Write-Host "Execution completed."
# End of script