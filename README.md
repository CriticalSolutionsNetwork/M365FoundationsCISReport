# M365FoundationsCISReport Module

## License

This PowerShell module is based on CIS benchmarks and is distributed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. This means:

- **Non-commercial**: You may not use the material for commercial purposes.
- **ShareAlike**: If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
- **Attribution**: Appropriate credit must be given, provide a link to the license, and indicate if changes were made.

For full license details, please visit [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en).

[Register for and download CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)

## Export-M365SecurityAuditTable
### Synopsis
Exports M365 security audit results to a CSV file or outputs a specific test result as an object.
### Syntax
```powershell

Export-M365SecurityAuditTable [-AuditResults] <CISAuditResult[]> [-OutputTestNumber] <String> [<CommonParameters>]

Export-M365SecurityAuditTable [-AuditResults] <CISAuditResult[]> [-ExportAllTests] -ExportPath <String> [-ExportOriginalTests] [-ExportToExcel] [<CommonParameters>]

Export-M365SecurityAuditTable [-CsvPath] <String> [-OutputTestNumber] <String> [<CommonParameters>]

Export-M365SecurityAuditTable [-CsvPath] <String> [-ExportAllTests] -ExportPath <String> [-ExportOriginalTests] [-ExportToExcel] [<CommonParameters>]

```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>AuditResults</nobr> |  | An array of CISAuditResult objects containing the audit results. | true | false |  |
| <nobr>CsvPath</nobr> |  | The path to a CSV file containing the audit results. | true | false |  |
| <nobr>OutputTestNumber</nobr> |  | The test number to output as an object. Valid values are "1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4". | true | false |  |
| <nobr>ExportAllTests</nobr> |  | Switch to export all test results. | true | false | False |
| <nobr>ExportPath</nobr> |  | The path where the CSV files will be exported. | true | false |  |
| <nobr>ExportOriginalTests</nobr> |  | Switch to export the original audit results to a CSV file. | false | false | False |
| <nobr>ExportToExcel</nobr> |  | Switch to export the results to an Excel file. | false | false | False |
### Inputs
 - \\[CISAuditResult\\[\\]\\], \\[string\\]

### Outputs
 - \\[PSCustomObject\\]

### Examples
**EXAMPLE 1**
```powershell
Export-M365SecurityAuditTable -AuditResults $object -OutputTestNumber 6.1.2
# Output object for a single test number from audit results
```


**EXAMPLE 2**
```powershell
Export-M365SecurityAuditTable -ExportAllTests -AuditResults $object -ExportPath "C:\temp"
# Export all results from audit results to the specified path
```


**EXAMPLE 3**
```powershell
Export-M365SecurityAuditTable -CsvPath "C:\temp\auditresultstoday1.csv" -OutputTestNumber 6.1.2
# Output object for a single test number from CSV
```


**EXAMPLE 4**
```powershell
Export-M365SecurityAuditTable -ExportAllTests -CsvPath "C:\temp\auditresultstoday1.csv" -ExportPath "C:\temp"
# Export all results from CSV to the specified path
```


**EXAMPLE 5**
```powershell
Export-M365SecurityAuditTable -ExportAllTests -AuditResults $object -ExportPath "C:\temp" -ExportOriginalTests
# Export all results from audit results to the specified path along with the original tests
```


**EXAMPLE 6**
```powershell
Export-M365SecurityAuditTable -ExportAllTests -CsvPath "C:\temp\auditresultstoday1.csv" -ExportPath "C:\temp" -ExportOriginalTests
# Export all results from CSV to the specified path along with the original tests
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
Retrieves the MFA \\(Multi-Factor Authentication\\) status for Azure Active Directory users.
### Syntax
```powershell

Get-MFAStatus [[-UserId] <String>] [-SkipMSOLConnectionChecks] [<CommonParameters>]

```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>UserId</nobr> |  | The User Principal Name \\(UPN\\) of a specific user to retrieve MFA status for. If not provided, the function retrieves MFA status for all users. | false | false |  |
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
| <nobr>UserPrincipalNameForConsent</nobr> |  |  | true | true \\(ByValue, ByPropertyName\\) |  |
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

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-M365DomainForPWPolicyTest <String>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-M365DomainForPWPolicyTest <String>] -ELevel <String> -ProfileLevel <String> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-M365DomainForPWPolicyTest <String>] -IncludeIG1 [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-M365DomainForPWPolicyTest <String>] -IncludeIG2 [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-M365DomainForPWPolicyTest <String>] -IncludeIG3 [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-M365DomainForPWPolicyTest <String>] -IncludeRecommendation <String[]> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-M365DomainForPWPolicyTest <String>] -SkipRecommendation <String[]> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]



```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>TenantAdminUrl</nobr> |  | The URL of the tenant admin. If not specified, none of the SharePoint Online tests will run. | false | false |  |
| <nobr>M365DomainForPWPolicyTest</nobr> |  | The domain name of the Microsoft 365 environment to test. This parameter is not mandatory and by default it will pass/fail all found domains as a group if a specific domain is not specified. | false | false |  |
| <nobr>ELevel</nobr> |  | Specifies the E-Level \\(E3 or E5\\) for the audit. This parameter is optional and can be combined with the ProfileLevel parameter. | true | false |  |
| <nobr>ProfileLevel</nobr> |  | Specifies the profile level \\(L1 or L2\\) for the audit. This parameter is optional and can be combined with the ELevel parameter. | true | false |  |
| <nobr>IncludeIG1</nobr> |  | If specified, includes tests where IG1 is true. | true | false | False |
| <nobr>IncludeIG2</nobr> |  | If specified, includes tests where IG2 is true. | true | false | False |
| <nobr>IncludeIG3</nobr> |  | If specified, includes tests where IG3 is true. | true | false | False |
| <nobr>IncludeRecommendation</nobr> |  | Specifies specific recommendations to include in the audit. Accepts an array of recommendation numbers. | true | false |  |
| <nobr>SkipRecommendation</nobr> |  | Specifies specific recommendations to exclude from the audit. Accepts an array of recommendation numbers. | true | false |  |
| <nobr>DoNotConnect</nobr> |  | If specified, the cmdlet will not establish a connection to Microsoft 365 services. | false | false | False |
| <nobr>DoNotDisconnect</nobr> |  | If specified, the cmdlet will not disconnect from Microsoft 365 services after execution. | false | false | False |
| <nobr>NoModuleCheck</nobr> |  | If specified, the cmdlet will not check for the presence of required modules. | false | false | False |
| <nobr>DoNotConfirmConnections</nobr> |  | If specified, the cmdlet will not prompt for confirmation before proceeding with established connections and will disconnect from all of them. | false | false | False |
| <nobr>WhatIf</nobr> | wi |  | false | false |  |
| <nobr>Confirm</nobr> | cf |  | false | false |  |
### Inputs
 - None. You cannot pipe objects to Invoke-M365SecurityAudit.

### Outputs
 - CISAuditResult\\[\\] The cmdlet returns an array of CISAuditResult objects representing the results of the security audit.

### Note
- This module is based on CIS benchmarks. - Governed by the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. - Commercial use is not permitted. This module cannot be sold or used for commercial purposes. - Modifications and sharing are allowed under the same license. - For full license details, visit: https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en - Register for CIS Benchmarks at: https://www.cisecurity.org/cis-benchmarks

### Examples
**EXAMPLE 1**
```powershell
Invoke-M365SecurityAudit
```
Performs a security audit using default parameters.  
Output:  
Status      : Fail  
ELevel      : E3  
ProfileLevel: L1  
Connection  : Microsoft Graph  
Rec         : 1.1.1  
Result      : False  
Details     : Non-compliant accounts:  
Username        | Roles                  | HybridStatus | Missing Licence  
user1@domain.com| Global Administrator   | Cloud-Only   | AAD\\_PREMIUM  
user2@domain.com| Global Administrator   | Hybrid       | AAD\\_PREMIUM, AAD\\_PREMIUM\\_P2  
FailureReason: Non-Compliant Accounts: 2

**EXAMPLE 2**
```powershell
Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -M365DomainForPWPolicyTest "contoso.com" -ELevel "E5" -ProfileLevel "L1"
```
Performs a security audit for the E5 level and L1 profile in the specified Microsoft 365 environment.  
Output:  
Status      : Fail  
ELevel      : E5  
ProfileLevel: L1  
Connection  : Microsoft Graph  
Rec         : 1.1.1  
Result      : False  
Details     : Non-compliant accounts:  
Username        | Roles                  | HybridStatus | Missing Licence  
user1@domain.com| Global Administrator   | Cloud-Only   | AAD\\_PREMIUM  
user2@domain.com| Global Administrator   | Hybrid       | AAD\\_PREMIUM, AAD\\_PREMIUM\\_P2  
FailureReason: Non-Compliant Accounts: 2

**EXAMPLE 3**
```powershell
Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -M365DomainForPWPolicyTest "contoso.com" -IncludeIG1
```
Performs an audit including all tests where IG1 is true.  
Output:  
Status      : Fail  
ELevel      : E3  
ProfileLevel: L1  
Connection  : Microsoft Graph  
Rec         : 1.1.1  
Result      : False  
Details     : Non-compliant accounts:  
Username        | Roles                  | HybridStatus | Missing Licence  
user1@domain.com| Global Administrator   | Cloud-Only   | AAD\\_PREMIUM  
user2@domain.com| Global Administrator   | Hybrid       | AAD\\_PREMIUM, AAD\\_PREMIUM\\_P2  
FailureReason: Non-Compliant Accounts: 2

**EXAMPLE 4**
```powershell
Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -M365DomainForPWPolicyTest "contoso.com" -SkipRecommendation '1.1.3', '2.1.1'
Performs an audit while excluding specific recommendations 1.1.3 and 2.1.1.
Output:
Status      : Fail
ELevel      : E3
ProfileLevel: L1
Connection  : Microsoft Graph
Rec         : 1.1.1
Result      : False
Details     : Non-compliant accounts:
Username        | Roles                  | HybridStatus | Missing Licence
user1@domain.com| Global Administrator   | Cloud-Only   | AAD_PREMIUM
user2@domain.com| Global Administrator   | Hybrid       | AAD_PREMIUM, AAD_PREMIUM_P2
FailureReason: Non-Compliant Accounts: 2
```


**EXAMPLE 5**
```powershell
$auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -M365DomainForPWPolicyTest "contoso.com"
PS> $auditResults | Export-Csv -Path "auditResults.csv" -NoTypeInformation
```
Captures the audit results into a variable and exports them to a CSV file.  
Output:  
CISAuditResult\\[\\]  
auditResults.csv

**EXAMPLE 6**
```powershell
Invoke-M365SecurityAudit -WhatIf
```
Displays what would happen if the cmdlet is run without actually performing the audit.  
Output:  
What if: Performing the operation "Invoke-M365SecurityAudit" on target "Microsoft 365 environment".

### Links

 - [https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit)
## Remove-RowsWithEmptyCSVStatus
### Synopsis
Removes rows from an Excel worksheet where the 'CSV\\_Status' column is empty and saves the result to a new file.
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
