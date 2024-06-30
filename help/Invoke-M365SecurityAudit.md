---
external help file: M365FoundationsCISReport-help.xml
Module Name: M365FoundationsCISReport
online version: https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit
schema: 2.0.0
---

# Invoke-M365SecurityAudit

## SYNOPSIS
Invokes a security audit for Microsoft 365 environments.

## SYNTAX

### Default (Default)
```
Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>]
 [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect]
 [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ELevelFilter
```
Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] -ELevel <String>
 -ProfileLevel <String> [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>]
 [-DoNotConnect] [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### IG1Filter
```
Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] [-IncludeIG1]
 [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect]
 [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### IG2Filter
```
Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] [-IncludeIG2]
 [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect]
 [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### IG3Filter
```
Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] [-IncludeIG3]
 [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect]
 [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### RecFilter
```
Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] -IncludeRecommendation <String[]>
 [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect]
 [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SkipRecFilter
```
Invoke-M365SecurityAudit [-TenantAdminUrl <String>] [-DomainName <String>] -SkipRecommendation <String[]>
 [-ApprovedCloudStorageProviders <String[]>] [-ApprovedFederatedDomains <String[]>] [-DoNotConnect]
 [-DoNotDisconnect] [-NoModuleCheck] [-DoNotConfirmConnections] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Invoke-M365SecurityAudit cmdlet performs a comprehensive security audit based on the specified parameters.
It allows auditing of various configurations and settings within a Microsoft 365 environment, such as compliance with CIS benchmarks.

## EXAMPLES

### EXAMPLE 1
```
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
                user1@domain.com| Global Administrator   | Cloud-Only   | AAD_PREMIUM
                user2@domain.com| Global Administrator   | Hybrid       | AAD_PREMIUM, AAD_PREMIUM_P2
FailureReason: Non-Compliant Accounts: 2

### EXAMPLE 2
```
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
                user1@domain.com| Global Administrator   | Cloud-Only   | AAD_PREMIUM
                user2@domain.com| Global Administrator   | Hybrid       | AAD_PREMIUM, AAD_PREMIUM_P2
FailureReason: Non-Compliant Accounts: 2

### EXAMPLE 3
```
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
                user1@domain.com| Global Administrator   | Cloud-Only   | AAD_PREMIUM
                user2@domain.com| Global Administrator   | Hybrid       | AAD_PREMIUM, AAD_PREMIUM_P2
FailureReason: Non-Compliant Accounts: 2

### EXAMPLE 4
```
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

### EXAMPLE 5
```
$auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -M365DomainForPWPolicyTest "contoso.com"
PS> $auditResults | Export-Csv -Path "auditResults.csv" -NoTypeInformation
```

Captures the audit results into a variable and exports them to a CSV file.
Output:
CISAuditResult\[\]
auditResults.csv

### EXAMPLE 6
```
Invoke-M365SecurityAudit -WhatIf
```

Displays what would happen if the cmdlet is run without actually performing the audit.
Output:
What if: Performing the operation "Invoke-M365SecurityAudit" on target "Microsoft 365 environment".

## PARAMETERS

### -TenantAdminUrl
The URL of the tenant admin.
If not specified, none of the SharePoint Online tests will run.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DomainName
The domain name of the Microsoft 365 environment to test. This parameter is not mandatory and by default it will pass/fail all found domains as a group if a specific domain is not specified.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ELevel
Specifies the E-Level (E3 or E5) for the audit.
This parameter is optional and can be combined with the ProfileLevel parameter.

```yaml
Type: String
Parameter Sets: ELevelFilter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileLevel
Specifies the profile level (L1 or L2) for the audit.
This parameter is optional and can be combined with the ELevel parameter.

```yaml
Type: String
Parameter Sets: ELevelFilter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeIG1
If specified, includes tests where IG1 is true.

```yaml
Type: SwitchParameter
Parameter Sets: IG1Filter
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeIG2
If specified, includes tests where IG2 is true.

```yaml
Type: SwitchParameter
Parameter Sets: IG2Filter
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeIG3
If specified, includes tests where IG3 is true.

```yaml
Type: SwitchParameter
Parameter Sets: IG3Filter
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeRecommendation
Specifies specific recommendations to include in the audit.
Accepts an array of recommendation numbers.

```yaml
Type: String[]
Parameter Sets: RecFilter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipRecommendation
Specifies specific recommendations to exclude from the audit.
Accepts an array of recommendation numbers.

```yaml
Type: String[]
Parameter Sets: SkipRecFilter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApprovedCloudStorageProviders
Specifies the approved cloud storage providers for the audit. Accepts an array of cloud storage provider names.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApprovedFederatedDomains
Specifies the approved federated domains for the audit test 8.2.1. Accepts an array of allowed domain names.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DoNotConnect
If specified, the cmdlet will not establish a connection to Microsoft 365 services.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DoNotDisconnect
If specified, the cmdlet will not disconnect from Microsoft 365 services after execution.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoModuleCheck
If specified, the cmdlet will not check for the presence of required modules.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DoNotConfirmConnections
If specified, the cmdlet will not prompt for confirmation before proceeding with established connections and will disconnect from all of them.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Invoke-M365SecurityAudit.
## OUTPUTS

### CISAuditResult[]
### The cmdlet returns an array of CISAuditResult objects representing the results of the security audit.
## NOTES
- This module is based on CIS benchmarks.
- Governed by the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
- Commercial use is not permitted. This module cannot be sold or used for commercial purposes.
- Modifications and sharing are allowed under the same license.
- For full license details, visit: https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en
- Register for CIS Benchmarks at: https://www.cisecurity.org/cis-benchmarks

## RELATED LINKS

[https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit](https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit)

