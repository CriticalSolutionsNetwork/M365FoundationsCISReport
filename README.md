# M365FoundationsCISReport Module

## License

This PowerShell module is based on CIS benchmarks and is distributed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. This means:

- **Non-commercial**: You may not use the material for commercial purposes.
- **ShareAlike**: If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
- **Attribution**: Appropriate credit must be given, provide a link to the license, and indicate if changes were made.

For full license details, please visit [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en).

## Invoke-M365SecurityAudit
### Synopsis
Invokes a security audit for Microsoft 365 environments.
### Syntax
```powershell

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> [-ELevel <String>] [-ProfileLevel <String>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> [-IncludeIG1] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> [-IncludeIG2] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> [-IncludeIG3] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> [-IncludeRecommendation <String[]>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]

Invoke-M365SecurityAudit -TenantAdminUrl <String> -DomainName <String> [-SkipRecommendation <String[]>] [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-WhatIf] [-Confirm] [<CommonParameters>]




```
### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>TenantAdminUrl</nobr> |  | The URL of the tenant admin. This parameter is mandatory. | true | false |  |
| <nobr>DomainName</nobr> |  | The domain name of the Microsoft 365 environment. This parameter is mandatory. | true | false |  |
| <nobr>ELevel</nobr> |  | Specifies the E-Level \(E3 or E5\) for the audit. This parameter is optional and can be combined with the ProfileLevel parameter. | false | false |  |
| <nobr>ProfileLevel</nobr> |  | Specifies the profile level \(L1 or L2\) for the audit. This parameter is optional and can be combined with the ELevel parameter. | false | false |  |
| <nobr>IncludeIG1</nobr> |  | If specified, includes tests where IG1 is true. | false | false | False |
| <nobr>IncludeIG2</nobr> |  | If specified, includes tests where IG2 is true. | false | false | False |
| <nobr>IncludeIG3</nobr> |  | If specified, includes tests where IG3 is true. | false | false | False |
| <nobr>IncludeRecommendation</nobr> |  | Specifies specific recommendations to include in the audit. Accepts an array of recommendation numbers. | false | false |  |
| <nobr>SkipRecommendation</nobr> |  | Specifies specific recommendations to exclude from the audit. Accepts an array of recommendation numbers. | false | false |  |
| <nobr>DoNotConnect</nobr> |  | If specified, the cmdlet will not establish a connection to Microsoft 365 services. | false | false | False |
| <nobr>DoNotDisconnect</nobr> |  | If specified, the cmdlet will not disconnect from Microsoft 365 services after execution. | false | false | False |
| <nobr>NoModuleCheck</nobr> |  | If specified, the cmdlet will not check for the presence of required modules. | false | false | False |
| <nobr>WhatIf</nobr> | wi |  | false | false |  |
| <nobr>Confirm</nobr> | cf |  | false | false |  |
### Inputs
 - None. You cannot pipe objects to Invoke-M365SecurityAudit.

### Outputs
 - CISAuditResult\\[\] The cmdlet returns an array of CISAuditResult objects representing the results of the security audit.

### Note
This module is based on CIS benchmarks and is governed by the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. For more details, visit: https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en

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
PS> $auditResults | Export-Csv -Path "auditResults.csv" -NoTypeInformation
```
Captures the audit results into a variable and exports them to a CSV file.

### Links

 - [Online Version: [GitHub Repository URL]](#Online Version: [GitHub Repository URL])
