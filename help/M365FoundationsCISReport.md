﻿---
Module Name: M365FoundationsCISReport
Module Guid: 0d064bfb-d1ce-484b-a173-993b55984dc9
Download Help Link: {{Please enter Link manually}}
Help Version: 1.0.0.0
Locale: en-US
---

# M365FoundationsCISReport Module
## Description
The `M365FoundationsCISReport` module provides a set of cmdlets to audit and report on the security compliance of Microsoft 365 environments based on CIS (Center for Internet Security) benchmarks. It enables administrators to generate detailed reports, sync data with CIS Excel sheets, and perform security audits to ensure compliance.

## M365FoundationsCISReport Cmdlets
### [Export-M365SecurityAuditTable](Export-M365SecurityAuditTable)
Exports M365 security audit results to a CSV file or outputs a specific test result as an object.

### [Get-AdminRoleUserLicense](Get-AdminRoleUserLicense)
Retrieves user licenses and roles for administrative accounts from Microsoft 365 via the Graph API.

### [Get-MFAStatus](Get-MFAStatus)
Retrieves the MFA (Multi-Factor Authentication) status for Azure Active Directory users.

### [Grant-M365SecurityAuditConsent](Grant-M365SecurityAuditConsent)
Grants Microsoft Graph permissions for an auditor.

### [Invoke-M365SecurityAudit](Invoke-M365SecurityAudit)
Invokes a security audit for Microsoft 365 environments.

### [New-M365SecurityAuditAuthObject](New-M365SecurityAuditAuthObject)
Creates a new CISAuthenticationParameters object for Microsoft 365 authentication.

### [Remove-RowsWithEmptyCSVStatus](Remove-RowsWithEmptyCSVStatus)
Removes rows from an Excel worksheet where the 'CSV_Status' column is empty and saves the result to a new file.

### [Sync-CISExcelAndCsvData](Sync-CISExcelAndCsvData)
Synchronizes and updates data in an Excel worksheet with new information from a CSV file, including audit dates.

