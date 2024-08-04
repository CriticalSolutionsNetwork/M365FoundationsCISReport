# M365FoundationsCISReport Module
[![PSScriptAnalyzer](https://github.com/CriticalSolutionsNetwork/M365FoundationsCISReport/actions/workflows/powershell.yml/badge.svg)](https://github.com/CriticalSolutionsNetwork/M365FoundationsCISReport/actions/workflows/powershell.yml)
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

The `M365FoundationsCISReport` module relies on several other PowerShell modules to perform its operations. Ensure these modules are installed with the specified versions before using this module.

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

# Example 2: Exporting a security audit and it's nested tables to zipped CSV files
Export-M365SecurityAuditTable -AuditResults $auditResults -ExportPath "C:\temp" -ExportOriginalTests -ExportAllTests
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
