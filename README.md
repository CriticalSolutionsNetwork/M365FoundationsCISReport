# M365FoundationsCISReport Module
[![PSScriptAnalyzer](https://github.com/CriticalSolutionsNetwork/M365FoundationsCISReport/actions/workflows/powershell.yml/badge.svg)](https://github.com/CriticalSolutionsNetwork/M365FoundationsCISReport/actions/workflows/powershell.yml)
[![pages-build-deployment](https://github.com/CriticalSolutionsNetwork/M365FoundationsCISReport/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/CriticalSolutionsNetwork/M365FoundationsCISReport/actions/workflows/pages/pages-build-deployment)
## License

This PowerShell module is based on CIS benchmarks and is distributed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. This means:

- **Non-commercial**: You may not use the material for commercial purposes.
- **ShareAlike**: If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
- **Attribution**: Appropriate credit must be given, provide a link to the license, and indicate if changes were made.

For full license details, please visit [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en).

[Register for and download CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
# Table of Contents
1. [Invoke-M365SecurityAudit](#Invoke-M365SecurityAudit)
2. [Export-M365SecurityAuditTable](#Export-M365SecurityAuditTable)
3. [Get-AdminRoleUserLicense](#Get-AdminRoleUserLicense)
4. [Get-MFAStatus](#Get-MFAStatus)
5. [Grant-M365SecurityAuditConsent](#Grant-M365SecurityAuditConsent)
6. [New-M365SecurityAuditAuthObject](#New-M365SecurityAuditAuthObject)
7. [Remove-RowsWithEmptyCSVStatus](#Remove-RowsWithEmptyCSVStatus)
8. [Sync-CISExcelAndCsvData](#Sync-CISExcelAndCsvData)

## Module Dependencies

The `M365FoundationsCISReport` module relies on several other PowerShell modules to perform its operations. The default run ensures these modules are installed with the specified versions. Use -NoModuleCheck to skip this step if you have installed the required modules previously and would like to suppress any output for automated runs.

### Required Modules for Audit Functions

Default modules used for audit functions:

- **ExchangeOnlineManagement**
  - Required Version: `3.3.0`

- **Microsoft.Graph**
  - Required Version: `2.4.0`

- **PnP.PowerShell** (Optional, if PnP App authentication is used for SharePoint Online)
  - Required Version: `2.5.0`

- **Microsoft.Online.SharePoint.PowerShell** (If PnP authentication is not used (Default) )
  - Required Version: `16.0.24009.12000`

- **MicrosoftTeams**
  - Required Version: `5.5.0`

- **ImportExcel** (If importing or exporting Excel files)
  - Required Version: `7.8.9`

# EXAMPLES

```powershell
# Example 1: Performing a security audit based on CIS benchmarks
$auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com"
$auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -ApprovedCloudStorageProviders "DropBox" -ApprovedFederatedDomains "northwind.com"
# Suppressed output for automated runs
$auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -NoModuleCheck -NoModuleCheck -DoNotConfirmConnections -Confirm:$false

# Example 2: Exporting a security audit and it's nested tables to zipped CSV files
Export-M365SecurityAuditTable -AuditResults $auditResults -ExportPath "C:\temp" -ExportOriginalTests -ExportNestedTables
    # Output Ex: 2024.07.07_14.55.55_M365FoundationsAudit_368B2E2F.zip

# Example 3: Retrieving licenses for users in administrative roles
Get-AdminRoleUserLicense

# Example 4: Getting MFA status of users
Get-MFAStatus -UserId "user@domain.com"

# Example 5: Removing rows with empty status values from a CSV file
Remove-RowsWithEmptyCSVStatus -FilePath "C:\Reports\Report.xlsx" -WorksheetName "Sheet1"

# Example 6: Synchronizing CIS benchmark data with audit results
Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -CsvPath "path\to\data.csv" -SheetName "Combined Profiles"

# Example 7: Granting Microsoft Graph permissions to the auditor
Grant-M365SecurityAuditConsent -UserPrincipalNameForConsent 'user@example.com'

# Example 8: (PowerShell 7.x Only) Creating a new authentication object for the security audit for app-based authentication.
$authParams = New-M365SecurityAuditAuthObject -ClientCertThumbPrint "ABCDEF1234567890ABCDEF1234567890ABCDEF12" `
                                                            -ClientId "12345678-1234-1234-1234-123456789012" `
                                                            -TenantId "12345678-1234-1234-1234-123456789012" `
                                                            -OnMicrosoftUrl "yourcompany.onmicrosoft.com" `
                                                            -SpAdminUrl "https://yourcompany-admin.sharepoint.com"
Invoke-M365SecurityAudit -AuthParams $authParams -TenantAdminUrl "https://yourcompany-admin.sharepoint.com"
```

# NOTE
Ensure that you have the necessary permissions and administrative roles in your Microsoft 365 environment to run these cmdlets. Proper configuration and setup are required for accurate audit results.

# TROUBLESHOOTING NOTE
If you encounter any issues while using the cmdlets, ensure that your environment meets the module prerequisites. Check for any updates or patches that may address known bugs. For issues related to specific cmdlets, refer to the individual help files for troubleshooting tips.

# SEE ALSO
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [Microsoft 365 Security Documentation](https://docs.microsoft.com/en-us/microsoft-365/security/)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)

## Export-M365SecurityAuditTable
### Synopsis
Exports Microsoft 365 security audit results to CSV or Excel files and supports outputting specific test results as objects.
### Syntax
```powershell

Export-M365SecurityAuditTable [-AuditResults] <CISAuditResult[]> [-OutputTestNumber] <String> [-WhatIf] [-Confirm] [<CommonParameters>]

Export-M365SecurityAuditTable [-AuditResults] <CISAuditResult[]> [[-ExportNestedTables]] -ExportPath <String> [-ExportOriginalTests] [-ExportToExcel] [-Prefix <String>] [-WhatIf] [-Confirm] [<CommonParameters>]

Export-M365SecurityAuditTable [-CsvPath] <String> [-OutputTestNumber] <String> [-WhatIf] [-Confirm] [<CommonParameters>]

Export-M365SecurityAuditTable [-CsvPath] <String> [[-ExportNestedTables]] -ExportPath <String> [-ExportOriginalTests] [-ExportToExcel] [-Prefix <String>] [-WhatIf] [-Confirm] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>AuditResults</nobr> |  | An array of CISAuditResult objects containing the audit results. This parameter is mandatory when exporting from audit results. | true | false |  |
| <nobr>CsvPath</nobr> |  | The path to a CSV file containing the audit results. This parameter is mandatory when exporting from a CSV file. | true | false |  |
| <nobr>OutputTestNumber</nobr> |  | The test number to output as an object. Valid values are "1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4". This parameter is used to output a specific test result. | true | false |  |
| <nobr>ExportNestedTables</nobr> |  | Switch to export all test results. When specified, all test results are exported to the specified path. | false | false | False |
| <nobr>ExportPath</nobr> |  | The path where the CSV or Excel files will be exported. This parameter is mandatory when exporting all tests. | true | false |  |
| <nobr>ExportOriginalTests</nobr> |  | Switch to export the original audit results to a CSV file. When specified, the original test results are exported along with the processed results. | false | false | False |
| <nobr>ExportToExcel</nobr> |  | Switch to export the results to an Excel file. When specified, results are exported in Excel format. | false | false | False |
| <nobr>Prefix</nobr> |  | Add Prefix to filename after date when outputting to excel or csv. Validate that the count of letters in the prefix is less than 5. | false | false | Corp |
| <nobr>WhatIf</nobr> | wi |  | false | false |  |
| <nobr>Confirm</nobr> | cf |  | false | false |  |
### Inputs
 - \[CISAuditResult\[\\]\\] - An array of CISAuditResult objects. \[string\\] - A path to a CSV file.

### Outputs
 - \[PSCustomObject\\] - A custom object containing the path to the zip file and its hash.

### Examples
**EXAMPLE 1**
```powershell
Export-M365SecurityAuditTable -AuditResults $object -OutputTestNumber 6.1.2
# Outputs the result of test number 6.1.2 from the provided audit results as an object.
```


**EXAMPLE 2**
```powershell
Export-M365SecurityAuditTable -ExportNestedTables -AuditResults $object -ExportPath "C:\temp"
# Exports all audit results to the specified path in CSV format.
```


**EXAMPLE 3**
```powershell
Export-M365SecurityAuditTable -CsvPath "C:\temp\auditresultstoday1.csv" -OutputTestNumber 6.1.2
# Outputs the result of test number 6.1.2 from the CSV file as an object.
```


**EXAMPLE 4**
```powershell
Export-M365SecurityAuditTable -ExportNestedTables -CsvPath "C:\temp\auditresultstoday1.csv" -ExportPath "C:\temp"
# Exports all audit results from the CSV file to the specified path in CSV format.
```


**EXAMPLE 5**
```powershell
Export-M365SecurityAuditTable -ExportNestedTables -AuditResults $object -ExportPath "C:\temp" -ExportOriginalTests
# Exports all audit results along with the original test results to the specified path in CSV format.
```


**EXAMPLE 6**
```powershell
Export-M365SecurityAuditTable -ExportNestedTables -CsvPath "C:\temp\auditresultstoday1.csv" -ExportPath "C:\temp" -ExportOriginalTests
# Exports all audit results from the CSV file along with the original test results to the specified path in CSV format.
```


**EXAMPLE 7**
```powershell
Export-M365SecurityAuditTable -ExportNestedTables -AuditResults $object -ExportPath "C:\temp" -ExportToExcel
# Exports all audit results to the specified path in Excel format.
```


### Links

 - [https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Export-M365SecurityAuditTable](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Export-M365SecurityAuditTable)
## Get-AdminRoleUserLicense
### Synopsis
Retrieves user licenses and roles for administrative accounts from Microsoft 365 via the Graph API.
### Syntax
```powershell

Get-AdminRoleUserLicense [-SkipGraphConnection] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>SkipGraphConnection</nobr> |  | A switch parameter that, when set, skips the connection to Microsoft Graph if already established. This is useful for batch processing or when used within scripts where multiple calls are made and the connection is managed externally. | false | false | False |
### Inputs
 - None. You cannot pipe objects to Get-AdminRoleUserLicense.

### Outputs
 - PSCustomObject Returns a custom object for each user with administrative roles that includes the following properties: RoleName, UserName, UserPrincipalName, UserId, HybridUser, and Licenses.

### Note
Creation Date:  2024-04-15 Purpose/Change: Initial function development to support Microsoft 365 administrative role auditing.

### Examples
**EXAMPLE 1**
```powershell
Get-AdminRoleUserLicense
```
This example retrieves all administrative role users along with their licenses by connecting to Microsoft Graph using the default scopes.

**EXAMPLE 2**
```powershell
Get-AdminRoleUserLicense -SkipGraphConnection
```
This example retrieves all administrative role users along with their licenses without attempting to connect to Microsoft Graph, assuming that the connection is already established.

### Links

 - [https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-AdminRoleUserLicense](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-AdminRoleUserLicense)
## Get-MFAStatus
### Synopsis
Retrieves the MFA \(Multi-Factor Authentication\) status for Azure Active Directory users.
### Syntax
```powershell

Get-MFAStatus [[-UserId] <String>] [-SkipMSOLConnectionChecks] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>UserId</nobr> |  | The User Principal Name \(UPN\) of a specific user to retrieve MFA status for. If not provided, the function retrieves MFA status for all users. | false | false |  |
| <nobr>SkipMSOLConnectionChecks</nobr> |  |  | false | false | False |
### Outputs
 - System.Object Returns a sorted list of custom objects containing the following properties: - UserPrincipalName - DisplayName - MFAState - MFADefaultMethod - MFAPhoneNumber - PrimarySMTP - Aliases

### Note
The function requires the MSOL module to be installed and connected to your tenant. Ensure that you have the necessary permissions to read user and MFA status information.

### Examples
**EXAMPLE 1**
```powershell
Get-MFAStatus
Retrieves the MFA status for all Azure Active Directory users.
```


**EXAMPLE 2**
```powershell
Get-MFAStatus -UserId "example@domain.com"
Retrieves the MFA status for the specified user with the UPN "example@domain.com".
```


### Links

 - [https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-MFAStatus](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-MFAStatus)
## Grant-M365SecurityAuditConsent
### Synopsis
Grants Microsoft Graph permissions for an auditor.
### Syntax
```powershell

Grant-M365SecurityAuditConsent [-UserPrincipalNameForConsent] <String> [-SkipGraphConnection] [-SkipModuleCheck] [-SuppressRevertOutput] [-DoNotDisconnect] [-WhatIf] [-Confirm] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>UserPrincipalNameForConsent</nobr> |  | The UPN or ID of the user to grant consent for. | true | true \(ByValue, ByPropertyName\) |  |
| <nobr>SkipGraphConnection</nobr> |  | If specified, skips connecting to Microsoft Graph. | false | false | False |
| <nobr>SkipModuleCheck</nobr> |  | If specified, skips the check for the Microsoft.Graph module. | false | false | False |
| <nobr>SuppressRevertOutput</nobr> |  | If specified, suppresses the output of the revert commands. | false | false | False |
| <nobr>DoNotDisconnect</nobr> |  | If specified, does not disconnect from Microsoft Graph after granting consent. | false | false | False |
| <nobr>WhatIf</nobr> | wi |  | false | false |  |
| <nobr>Confirm</nobr> | cf |  | false | false |  |
### Outputs
 - System.Void

### Note
This function requires the Microsoft.Graph module version 2.4.0 or higher.

### Examples
**EXAMPLE 1**
```powershell
Grant-M365SecurityAuditConsent -UserPrincipalNameForConsent user@example.com
```
Grants Microsoft Graph permissions to user@example.com for the client application with the specified Application ID.

**EXAMPLE 2**
```powershell
Grant-M365SecurityAuditConsent -UserPrincipalNameForConsent user@example.com -SkipGraphConnection
```
Grants Microsoft Graph permissions to user@example.com, skipping the connection to Microsoft Graph.

### Links

 - [https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Grant-M365SecurityAuditConsent](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Grant-M365SecurityAuditConsent)
## Invoke-M365SecurityAudit
### Synopsis
Invokes a security audit for Microsoft 365 environments.
### Syntax
```powershell

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-AuthParams <CISAuthenticationParameters>] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] -ELevel <String> -ProfileLevel <String> [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-AuthParams <CISAuthenticationParameters>] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] -IncludeIG1 [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-AuthParams <CISAuthenticationParameters>] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] -IncludeIG2 [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-AuthParams <CISAuthenticationParameters>] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] -IncludeIG3 [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-AuthParams <CISAuthenticationParameters>] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] -IncludeRecommendation <String[]> [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-AuthParams <CISAuthenticationParameters>] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] -SkipRecommendation <String[]> [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-AuthParams <CISAuthenticationParameters>] [-WhatIf] [-Confirm] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>TenantAdminUrl</nobr> |  | The URL of the tenant admin. If not specified, none of the SharePoint Online tests will run. | false | false |  |
| <nobr>DomainName</nobr> |  | The domain name of the Microsoft 365 environment to test. It is optional and will trigger various tests to run only for the specified domain. Tests Affected: 2.1.9/Test-EnableDKIM, 1.3.1/Test-PasswordNeverExpirePolicy, 2.1.4/Test-SafeAttachmentsPolicy | false | false |  |
| <nobr>ELevel</nobr> |  | Specifies the E-Level \(E3 or E5\) for the audit. This parameter is optional and can be combined with the ProfileLevel parameter. | true | false |  |
| <nobr>ProfileLevel</nobr> |  | Specifies the profile level \(L1 or L2\) for the audit. This parameter is mandatory, but only when ELevel is selected. Otherwise it is not required. | true | false |  |
| <nobr>IncludeIG1</nobr> |  | If specified, includes tests where IG1 is true. | true | false | False |
| <nobr>IncludeIG2</nobr> |  | If specified, includes tests where IG2 is true. | true | false | False |
| <nobr>IncludeIG3</nobr> |  | If specified, includes tests where IG3 is true. | true | false | False |
| <nobr>IncludeRecommendation</nobr> |  | Specifies specific recommendations to include in the audit. Accepts an array of recommendation numbers. | true | false |  |
| <nobr>SkipRecommendation</nobr> |  | Specifies specific recommendations to exclude from the audit. Accepts an array of recommendation numbers. | true | false |  |
| <nobr>ApprovedCloudStorageProviders</nobr> |  | Specifies the approved cloud storage providers for the audit. Accepts an array of cloud storage provider names for test 8.1.1/Test-TeamsExternalFileSharing. Acceptable values: 'GoogleDrive', 'ShareFile', 'Box', 'DropBox', 'Egnyte' | false | false | @\(\) |
| <nobr>ApprovedFederatedDomains</nobr> |  | Specifies the approved federated domains for the audit test 8.2.1/Test-TeamsExternalAccess. Accepts an array of allowed domain names. Additional Tests may include this parameter in the future. | false | false |  |
| <nobr>DoNotConnect</nobr> |  | If specified, the cmdlet will not establish a connection to Microsoft 365 services. | false | false | False |
| <nobr>DoNotDisconnect</nobr> |  | If specified, the cmdlet will not disconnect from Microsoft 365 services after execution. | false | false | False |
| <nobr>NoModuleCheck</nobr> |  | If specified, the cmdlet will not check for the presence of required modules. | false | false | False |
| <nobr>DoNotConfirmConnections</nobr> |  | If specified, the cmdlet will not prompt for confirmation before proceeding with established connections and will disconnect from all of them. | false | false | False |
| <nobr>AuthParams</nobr> |  | Specifies an authentication object containing parameters for application-based authentication. If provided, this will be used for connecting to services. | false | false |  |
| <nobr>WhatIf</nobr> | wi |  | false | false |  |
| <nobr>Confirm</nobr> | cf |  | false | false |  |
### Inputs
 - None. You cannot pipe objects to Invoke-M365SecurityAudit.

### Outputs
 - CISAuditResult\[\\] The cmdlet returns an array of CISAuditResult objects representing the results of the security audit.

### Note
- This module is based on CIS benchmarks. - Governed by the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. - Commercial use is not permitted. This module cannot be sold or used for commercial purposes. - Modifications and sharing are allowed under the same license. - For full license details, visit: https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en - Register for CIS Benchmarks at: https://www.cisecurity.org/cis-benchmarks

### Examples
**EXAMPLE 1**
```powershell
Invoke-M365SecurityAudit
# Performs a security audit using default parameters.
```


**EXAMPLE 2**
```powershell
Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -ELevel "E5" -ProfileLevel "L1"
# Performs a security audit for the E5 level and L1 profile in the specified Microsoft 365 environment.
```


**EXAMPLE 3**
```powershell
Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -IncludeIG1
# Performs a security audit while including tests where IG1 is true.
```


**EXAMPLE 4**
```powershell
Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -SkipRecommendation '1.1.3', '2.1.1'
# Performs an audit while excluding specific recommendations 1.1.3 and 2.1.1.
```


**EXAMPLE 5**
```powershell
$auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com"
PS> Export-M365SecurityAuditTable -AuditResults $auditResults -ExportPath "C:\temp" -ExportOriginalTests -ExportAllTests
```


**EXAMPLE 6**
```powershell
# (PowerShell 7.x Only) Creating a new authentication object for the security audit for app-based authentication.
PS> $authParams = New-M365SecurityAuditAuthObject `
-ClientCertThumbPrint "ABCDEF1234567890ABCDEF1234567890ABCDEF12" `
-ClientId "12345678-1234-1234-1234-123456789012" `
-TenantId "12345678-1234-1234-1234-123456789012" `
-OnMicrosoftUrl "yourcompany.onmicrosoft.com" `
-SpAdminUrl "https://yourcompany-admin.sharepoint.com"
Invoke-M365SecurityAudit -AuthParams $authParams -TenantAdminUrl "https://yourcompany-admin.sharepoint.com"
# Or:
PS> $auditResults | Export-Csv -Path "auditResults.csv" -NoTypeInformation
# Captures the audit results into a variable and exports them to a CSV file (Nested tables will be truncated).
Output:
CISAuditResult[]
auditResults.csv
```


**EXAMPLE 7**
```powershell
Invoke-M365SecurityAudit -WhatIf
Displays what would happen if the cmdlet is run without actually performing the audit.
Output:
What if: Performing the operation "Invoke-M365SecurityAudit" on target "Microsoft 365 environment".
```


### Links

 - [https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit)
## New-M365SecurityAuditAuthObject
### Synopsis
Creates a new CISAuthenticationParameters object for Microsoft 365 authentication.
### Syntax
```powershell

New-M365SecurityAuditAuthObject [-ClientCertThumbPrint] <String> [-ClientId] <String> [-TenantId] <String> [-OnMicrosoftUrl] <String> [-SpAdminUrl] <String> [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>ClientCertThumbPrint</nobr> |  | The thumbprint of the client certificate used for authentication. It must be a 40-character hexadecimal string. This certificate is used to authenticate the application in Azure AD. | true | false |  |
| <nobr>ClientId</nobr> |  | The Client ID \(Application ID\) of the Azure AD application. It must be a valid GUID format. | true | false |  |
| <nobr>TenantId</nobr> |  | The Tenant ID of the Azure AD directory. It must be a valid GUID format representing your Microsoft 365 tenant. | true | false |  |
| <nobr>OnMicrosoftUrl</nobr> |  | The URL of your onmicrosoft.com domain. It should be in the format 'example.onmicrosoft.com'. | true | false |  |
| <nobr>SpAdminUrl</nobr> |  | The SharePoint admin URL, which should end with '-admin.sharepoint.com'. This URL is used for connecting to SharePoint Online. | true | false |  |
### Inputs
 - None. You cannot pipe objects to this function.

### Outputs
 - CISAuthenticationParameters The function returns an instance of the CISAuthenticationParameters class containing the authentication details.

### Note
Requires PowerShell 7.0 or later.

### Examples
**EXAMPLE 1**
```powershell
$authParams = New-M365SecurityAuditAuthObject -ClientCertThumbPrint "ABCDEF1234567890ABCDEF1234567890ABCDEF12" `
-ClientId "12345678-1234-1234-1234-123456789012" `
-TenantId "12345678-1234-1234-1234-123456789012" `
-OnMicrosoftUrl "yourcompany.onmicrosoft.com" `
-SpAdminUrl "https://yourcompany-admin.sharepoint.com"
Creates a new CISAuthenticationParameters object with the specified credentials and URLs, validating each parameter's format and length.
```


## Remove-RowsWithEmptyCSVStatus
### Synopsis
Removes rows from an Excel worksheet where the 'CSV\_Status' column is empty and saves the result to a new file.
### Syntax
```powershell

Remove-RowsWithEmptyCSVStatus [-FilePath] <String> [-WorksheetName] <String> [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>FilePath</nobr> |  | The path to the Excel file to be processed. | true | false |  |
| <nobr>WorksheetName</nobr> |  | The name of the worksheet within the Excel file to be processed. | true | false |  |
### Note
This function requires the ImportExcel module to be installed.

### Examples
**EXAMPLE 1**
```powershell
Remove-RowsWithEmptyCSVStatus -FilePath "C:\Reports\Report.xlsx" -WorksheetName "Sheet1"
This command imports data from the "Sheet1" worksheet in the "Report.xlsx" file, removes rows where the 'CSV_Status' column is empty, and saves the filtered data to a new file named "Report-Filtered.xlsx" in the same directory.
```


## Sync-CISExcelAndCsvData
### Synopsis
Synchronizes and updates data in an Excel worksheet with new information from a CSV file, including audit dates.
### Syntax
```powershell

Sync-CISExcelAndCsvData [[-ExcelPath] <String>] [[-CsvPath] <String>] [[-SheetName] <String>] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>ExcelPath</nobr> |  | Specifies the path to the Excel file to be updated. This parameter is mandatory. | false | false |  |
| <nobr>CsvPath</nobr> |  | Specifies the path to the CSV file containing new data. This parameter is mandatory. | false | false |  |
| <nobr>SheetName</nobr> |  | Specifies the name of the worksheet in the Excel file where data will be merged and updated. This parameter is mandatory. | false | false |  |
### Inputs
 - System.String The function accepts strings for file paths and worksheet names.

### Outputs
 - None The function directly updates the Excel file and does not output any objects.

### Note
- Ensure that the 'ImportExcel' module is installed and up to date to handle Excel file manipulations. - It is recommended to back up the Excel file before running this function to avoid accidental data loss. - The CSV file should have columns that match expected headers like 'Connection', 'Details', 'FailureReason', and 'Status' for correct data mapping.

### Examples
**EXAMPLE 1**
```powershell
Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -CsvPath "path\to\data.csv" -SheetName "AuditData"
Updates the 'AuditData' worksheet in 'excel.xlsx' with data from 'data.csv', adding new information and the date of the update.
```


### Links

 - [https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData)
