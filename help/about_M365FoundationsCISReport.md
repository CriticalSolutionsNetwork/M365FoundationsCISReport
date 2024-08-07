﻿# M365FoundationsCISReport
## about_M365FoundationsCISReport

# SHORT DESCRIPTION
The `M365FoundationsCISReport` module provides cmdlets for auditing and reporting on the security compliance of Microsoft 365 environments based on CIS benchmarks.

# LONG DESCRIPTION
The `M365FoundationsCISReport` module is designed to help administrators ensure that their Microsoft 365 environments adhere to the security best practices outlined by the Center for Internet Security (CIS). The module includes cmdlets for performing comprehensive security audits, generating detailed reports, and synchronizing audit results with CIS benchmark Excel sheets. It aims to streamline the process of maintaining security compliance and improving the overall security posture of Microsoft 365 environments.

## Optional Subtopics
### Auditing and Reporting
The module provides cmdlets that allow for the auditing of various security aspects of Microsoft 365 environments, including user MFA status, administrative role licenses, and more. The results can be exported and analyzed to ensure compliance with CIS benchmarks.

### Data Synchronization
The module includes functionality to synchronize audit results with CIS benchmark data stored in Excel sheets. This ensures that the documentation is always up-to-date with the latest audit findings.

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

# KEYWORDS
- Microsoft 365
- Security Audit
- CIS Benchmarks
- Compliance
- MFA
- User Licenses
- Security Reporting
