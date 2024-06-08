# M365FoundationsCISReport Module

## License

This PowerShell module is based on CIS benchmarks and is distributed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. This means:

- **Non-commercial**: You may not use the material for commercial purposes.
- **ShareAlike**: If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
- **Attribution**: Appropriate credit must be given, provide a link to the license, and indicate if changes were made.

For full license details, please visit [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en).

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
### Syntax
```powershell
Invoke-M365SecurityAudit -TenantAdminUrl <string> -DomainName <string> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <string> -DomainName <string> -ELevel <string> -ProfileLevel <string> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <string> -DomainName <string> -IncludeIG1 [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <string> -DomainName <string> -IncludeIG2 [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <string> -DomainName <string> -IncludeIG3 [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <string> -DomainName <string> -IncludeRecommendation <string[]> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <string> -DomainName <string> -SkipRecommendation <string[]> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]
```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>Confirm</nobr> | cf |  | false | false |  |
| <nobr>DoNotConnect</nobr> | None |  | false | false |  |
| <nobr>DoNotDisconnect</nobr> | None |  | false | false |  |
| <nobr>DomainName</nobr> | None |  | true | false |  |
| <nobr>ELevel</nobr> | None |  | true | false |  |
| <nobr>IncludeIG1</nobr> | None |  | true | false |  |
| <nobr>IncludeIG2</nobr> | None |  | true | false |  |
| <nobr>IncludeIG3</nobr> | None |  | true | false |  |
| <nobr>IncludeRecommendation</nobr> | None |  | true | false |  |
| <nobr>NoModuleCheck</nobr> | None |  | false | false |  |
| <nobr>ProfileLevel</nobr> | None |  | true | false |  |
| <nobr>SkipRecommendation</nobr> | None |  | true | false |  |
| <nobr>TenantAdminUrl</nobr> | None |  | true | false |  |
| <nobr>WhatIf</nobr> | wi |  | false | false |  |
## Sync-CISExcelAndCsvData
### Synopsis
Synchronizes data between an Excel file and a CSV file and optionally updates the Excel worksheet.
### Syntax
```powershell
Sync-CISExcelAndCsvData [-ExcelPath] <String> [-WorksheetName] <String> [-CsvPath] <String> [-SkipUpdate] [<CommonParameters>]
```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>ExcelPath</nobr> |  | The path to the Excel file that contains the original data. This parameter is mandatory. | true | false |  |
| <nobr>WorksheetName</nobr> |  | The name of the worksheet within the Excel file that contains the data to be synchronized. This parameter is mandatory. | true | false |  |
| <nobr>CsvPath</nobr> |  | The path to the CSV file containing data to be merged with the Excel data. This parameter is mandatory. | true | false |  |
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

### Links

 - [https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData)
