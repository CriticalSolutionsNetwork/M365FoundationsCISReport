# M365FoundationsCISReport Module
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
## Invoke-M365SecurityAudit
### Synopsis
Invokes a security audit for Microsoft 365 environments.
### Syntax
```powershell

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> -ELevel <String> -ProfileLevel <String> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> -IncludeIG1 [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> -IncludeIG2 [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> -IncludeIG3 [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> -IncludeRecommendation <String[]> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> -SkipRecommendation <String[]> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>TenantAdminUrl</nobr> |  | The URL of the tenant admin. This parameter is mandatory. | true | false |  |
| <nobr>DomainName</nobr> |  | The domain name of the Microsoft 365 environment. This parameter is mandatory. | true | false |  |
| <nobr>ELevel</nobr> |  | Specifies the E-Level \(E3 or E5\) for the audit. This parameter is optional and can be combined with the ProfileLevel parameter. | true | false |  |
| <nobr>ProfileLevel</nobr> |  | Specifies the profile level \(L1 or L2\) for the audit. This parameter is optional and can be combined with the ELevel parameter. | true | false |  |
| <nobr>IncludeIG1</nobr> |  | If specified, includes tests where IG1 is true. | true | false | False |
| <nobr>IncludeIG2</nobr> |  | If specified, includes tests where IG2 is true. | true | false | False |
| <nobr>IncludeIG3</nobr> |  | If specified, includes tests where IG3 is true. | true | false | False |
| <nobr>IncludeRecommendation</nobr> |  | Specifies specific recommendations to include in the audit. Accepts an array of recommendation numbers. | true | false |  |
| <nobr>SkipRecommendation</nobr> |  | Specifies specific recommendations to exclude from the audit. Accepts an array of recommendation numbers. | true | false |  |
| <nobr>DoNotConnect</nobr> |  | If specified, the cmdlet will not establish a connection to Microsoft 365 services. | false | false | False |
| <nobr>DoNotDisconnect</nobr> |  | If specified, the cmdlet will not disconnect from Microsoft 365 services after execution. | false | false | False |
| <nobr>NoModuleCheck</nobr> |  | If specified, the cmdlet will not check for the presence of required modules. | false | false | False |
| <nobr>WhatIf</nobr> | wi |  | false | false |  |
| <nobr>Confirm</nobr> | cf |  | false | false |  |
### Inputs
 - None. You cannot pipe objects to Invoke-M365SecurityAudit.

### Outputs
 - CISAuditResult\[\] The cmdlet returns an array of CISAuditResult objects representing the results of the security audit.

### Note
- This module is based on CIS benchmarks. - Governed by the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. - Commercial use is not permitted. This module cannot be sold or used for commercial purposes. - Modifications and sharing are allowed under the same license. - For full license details, visit: https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en - Register for CIS Benchmarks at: https://www.cisecurity.org/cis-benchmarks

### Examples
**EXAMPLE 1**
```powershell
Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -ELevel "E5" -ProfileLevel "L1"
```
Performs a security audit for the E5 level and L1 profile in the specified Microsoft 365 environment.

**EXAMPLE 2**
```powershell
Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -IncludeIG1
```
Performs an audit including all tests where IG1 is true.

**EXAMPLE 3**
```powershell
Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -SkipRecommendation '1.1.3', '2.1.1'
```
Performs an audit while excluding specific recommendations 1.1.3 and 2.1.1.

**EXAMPLE 4**
```powershell
$auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com"
```
PS\> $auditResults | Export-Csv -Path "auditResults.csv" -NoTypeInformation  
  
Captures the audit results into a variable and exports them to a CSV file.

### Links

 - [https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit)
## Sync-CISExcelAndCsvData
### Synopsis
Synchronizes data between an Excel file and either a CSV file or an output object from Invoke-M365SecurityAudit, and optionally updates the Excel worksheet.
### Syntax
```powershell

Sync-CISExcelAndCsvData -ExcelPath <String> -WorksheetName <String> -CsvPath <String> [-SkipUpdate] [<CommonParameters>]

Sync-CISExcelAndCsvData -ExcelPath <String> -WorksheetName <String> -AuditResults <CISAuditResult[]> [-SkipUpdate] [<CommonParameters>]

```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>ExcelPath</nobr> |  | The path to the Excel file that contains the original data. This parameter is mandatory. | true | false |  |
| <nobr>WorksheetName</nobr> |  | The name of the worksheet within the Excel file that contains the data to be synchronized. This parameter is mandatory. | true | false |  |
| <nobr>CsvPath</nobr> |  | The path to the CSV file containing data to be merged with the Excel data. This parameter is mandatory when using the CsvInput parameter set. | true | false |  |
| <nobr>AuditResults</nobr> |  | An array of CISAuditResult objects from Invoke-M365SecurityAudit to be merged with the Excel data. This parameter is mandatory when using the ObjectInput parameter set. | true | false |  |
| <nobr>SkipUpdate</nobr> |  | If specified, the function will return the merged data object without updating the Excel worksheet. This is useful for previewing the merged data. | false | false | False |
### Inputs
 - None. You cannot pipe objects to Sync-CISExcelAndCsvData.

### Outputs
 - Object\[\] If the SkipUpdate switch is used, the function returns an array of custom objects representing the merged data.

### Note
- Ensure that the 'ImportExcel' module is installed and up to date. - It is recommended to backup the Excel file before running this script to prevent accidental data loss. - This function is part of the CIS Excel and CSV Data Management Toolkit.

### Examples
**EXAMPLE 1**
```powershell
Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -WorksheetName "DataSheet" -CsvPath "path\to\data.csv"
```
Merges data from 'data.csv' into 'excel.xlsx' on the 'DataSheet' worksheet and updates the worksheet with the merged data.

**EXAMPLE 2**
```powershell
$mergedData = Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -WorksheetName "DataSheet" -CsvPath "path\to\data.csv" -SkipUpdate
```
Retrieves the merged data object for preview without updating the Excel worksheet.

**EXAMPLE 3**
```powershell
$auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://tenant-admin.url" -DomainName "example.com"
```
PS\> Sync-CISExcelAndCsvData -ExcelPath "path\\to\\excel.xlsx" -WorksheetName "DataSheet" -AuditResults $auditResults  
Merges data from the audit results into 'excel.xlsx' on the 'DataSheet' worksheet and updates the worksheet with the merged data.

**EXAMPLE 4**
```powershell
$auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://tenant-admin.url" -DomainName "example.com"
```
PS\> $mergedData = Sync-CISExcelAndCsvData -ExcelPath "path\\to\\excel.xlsx" -WorksheetName "DataSheet" -AuditResults $auditResults -SkipUpdate  
Retrieves the merged data object for preview without updating the Excel worksheet.

### Links

 - [https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData)
