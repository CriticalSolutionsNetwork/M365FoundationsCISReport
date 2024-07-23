# Changelog for M365FoundationsCISReport

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Fixed test 1.3.1 as notification window for password expiration is no longer required.

## [0.1.24] - 2024-07-07

### Added

- New private function `Get-AuditMailboxDetail` for 6.1.2 and 6.1.3 tests to get the action details for the test.

### Changed

- Changed `Get-Action` function to include both dictionaries.

### Fixed

- Fixed Test 1.3.3 to be the simpler version of the test while including output to check for current users sharing calendars.
- Safe Attachments logic and added `$DomainName` as input to 2.1.4 to test main policy.

### Docs

- Updated `about_M365FoundationsCISReport` help file with new functions and changes.
- Updated `Invoke-M365SecurityAudit` help file with examples.
- Updated `Export-M365SecurityAudit` help file with examples.

## [0.1.23] - 2024-07-02

# Fixed

- SPO tests formatting and output.

## [0.1.22] - 2024-07-01

### Added

- Added hash and compress steps to `Export-M365SecurityAuditTable` function.

## [0.1.21] - 2024-07-01

### Fixed

- SPO tests formatting and output.

## [0.1.22] - 2024-07-01

### Added

- Added hash and compress steps to `Export-M365SecurityAuditTable` function.

## [0.1.21] - 2024-07-01

### Fixed

- Formatting for MgGraph tests.

## [0.1.20] - 2024-06-30

### Fixed

- Fixed parameter validation for new parameters in `Invoke-M365SecurityAudit` function

## [0.1.19] - 2024-06-30

### Added

- Added `ApprovedCloudStorageProviders` parameter to `Invoke-M365SecurityAudit` to allow for testing of approved cloud storage providers for 8.1.1.
- Added `ApprovedFederatedDomains` parameter to `Invoke-M365SecurityAudit` to allow for testing of approved federated domains for 8.5.1.

### Fixed

- Fixed various MSTeams tests to be more accurate and include more properties in the output.

## [0.1.18] - 2024-06-29

### Added

- Added `Get-PhishPolicyDetail` and `Test-PhishPolicyCompliance` private functions to help test for phishing policy compliance.

### Fixed

- Fixed various EXO test to be more accurate and include more properties in the output.

#### Changed

- Changed main function parameter for Domain to `DomainName`.

## [0.1.17] - 2024-06-28

### Fixed

- Fixed `Get-ExceededLengthResultDetail` function paramter validation for Exported Tests to allow for Null.

## [0.1.16] - 2024-06-26

### Added

- Added `Grant-M365SecurityAuditConsent` function to consent to the Microsoft Graph Powershell API for a user.

## [0.1.15] - 2024-06-26

### Fixed

- Fixed test 8.6.1 to include all of the following properties in it's checks and output: `ReportJunkToCustomizedAddress`, `ReportNotJunkToCustomizedAddress`, `ReportPhishToCustomizedAddress`,`ReportJunkAddresses`,`ReportNotJunkAddresses`,`ReportPhishAddresses`,`ReportChatMessageEnabled`,`ReportChatMessageToCustomizedAddressEnabled`
- Fixed help `about_M365FoundationsCISReport` examples.
- Fixed `Export-M365SecurityAuditTable` to properly export when nested table tests are not included.

### Changed

- Changed output of failure reason and details for 8.5.3 and 8.6.1 to be in line with other tests.

## [0.1.14] - 2024-06-23

### Fixed

- Fixed test 1.3.1 to include notification window for password expiration.
- Fixed 6.1.1 test definition to include the correct connection.
- Removed banner and warning from EXO and AzureAD connection step.
- Fixed missing CommentBlock for `Remove-RowsWithEmptyCSVStatus` function.
- Fixed formatting and color for various Write-Host messages.

### Added

- Added export to excel to `Export-M365SecurityAuditTable` function.
- `Get-AdminRoleUserLicense` function to get the license of a user with admin roles for 1.1.1.
- Skip MSOL connection confirmation to `Get-MFAStatus` function.
- Added `Get-CISMgOutput` function to get the output of the Microsoft Graph API per test.
- Added `Get-CISExoOutput` function to get the output of the Exchange Online API per test.
- Added `Get-CISMSTeamsOutput` function to get the output of the Microsoft Teams API per test.
- Added `Get-CISSPOOutput` function to get the output of the SharePoint Online API per test.
- Added `Get-TestError` function to get the error output of a test.
- Updated Microsoft Graph tests to utilize the new output functions ('1.1.1', '1.1.3', '1.2.1', '1.3.1', '5.1.2.3', '5.1.8.1', '6.1.2', '6.1.3')
- Updated EXO tests to utilize the new output functions ('1.2.2', '1.3.3', '1.3.6', '2.1.1', '2.1.2', '2.1.3', '2.1.4', '2.1.5', '2.1.6', '2.1.7', '2.1.9', '3.1.1', '6.1.1', '6.1.2', '6.1.3', '6.2.1', '6.2.2', '6.2.3', '6.3.1', '6.5.1', '6.5.2', '6.5.3', '8.6.1').
- Updated MSTeams tests to utilize the new output functions ('8.1.1', '8.1.2', '8.2.1', '8.5.1', '8.5.2', '8.5.3', '8.5.4', '8.5.5', '8.5.6', '8.5.7', '8.6.1')
- Updated SPO tests to utilize the new output functions ('7.2.1', '7.2.2', '7.2.3', '7.2.4', '7.2.5', '7.2.6', '7.2.7', '7.2.9', '7.2.10', '7.3.1', '7.3.2', '7.3.4')

## [0.1.13] - 2024-06-18

### Added

- Added tenant output to connect function.
- Added skip tenant connection confirmation to main function.

### Fixed

- Fixed comment examples for `Export-M365SecurityAuditTable`.

### Changed

- Updated `Sync-CISExcelAndCsvData` to be one function.

## [0.1.12] - 2024-06-17

### Added

- Added `Export-M365SecurityAuditTable` public function to export applicable audit results to a table format.
- Added paramter to `Export-M365SecurityAuditTable` to specify output of the original audit results.
- Added `Remove-RowsWithEmptyCSVStatus` public function to remove rows with empty status from the CSV file.
- Added `Get-Action` private function to retrieve the action for the test 6.1.2 and 6.1.3 tests.
- Added output modifications to tests that produce tables to ensure they can be exported with the new `Export-M365SecurityAuditTable` function.

## [0.1.11] - 2024-06-14

### Added

- Added Get-MFAStatus function to help with auditing mfa for conditional access controls.

### Fixed

- Fixed 6.1.2/6.1.3 tests to minimize calls to the Graph API.
- Fixed 2.1.1,2.1.4,2.1.5 to suppress error messages and create a standard object when no e5"

## [0.1.10] - 2024-06-12

### Added

- Added condition comments to each test.

### Fixed

- Fixed csv CIS controls that were not matched correctly.

## [0.1.9] - 2024-06-10

### Fixed

- Fixed bug in 1.1.1 that caused the test to fail/pass incorrectly. Added verbose output.

### Docs

- Updated helper csv formatting for one cis control.


## [0.1.8] - 2024-06-09

### Added

- Added output type to functions.

### Fixed

- Whatif support for `Invoke-M365SecurityAudit`.
- Whatif module output and module install process.

## [0.1.7] - 2024-06-08

### Added

- Added pipeline support to `Sync-CISExcelAndCsvData` function for `[CISAuditResult[]]` input.

### Changed

- Updated `Connect-M365Suite` to make `TenantAdminUrl` an optional parameter.
- Updated `Invoke-M365SecurityAudit` to make `TenantAdminUrl` an optional parameter.
- Improved connection handling and error messaging in `Connect-M365Suite`.
- Enhanced `Invoke-M365SecurityAudit` to allow flexible inclusion and exclusion of specific recommendations, IG filters, and profile levels.
- SupportsShoudProcess to also bypass connection checks in `Invoke-M365SecurityAudit` as well as Disconnect-M365Suite.

## [0.1.6] - 2024-06-08

### Added

- Added pipeline support to `Sync-CISExcelAndCsvData` function for `[CISAuditResult[]]` input.

## [0.1.5] - 2024-06-08

### Added

- Updated test definitions for CIS Microsoft 365 Foundations Benchmark for better error handling and object output when errors occur.
- Added a parameter to the `Initialize-CISAuditResult` function to allow for a static failed object to be created when an error occurs.
- Refactored `Invoke-M365SecurityAudit` to include a new private function `Invoke-TestFunction` for executing test functions and handling errors.
- Added a new private function `Measure-AuditResult` to calculate and display audit results.
- Enhanced error logging to capture failed test details and display them at the end of the audit.
- Added a private function `Get-RequiredModule` to initialize the `$requiredModules` variable for better code organization in the main script.
- Updated `Test-MailboxAuditingE3` and `Test-MailboxAuditingE5` functions to use `Format-MissingAction` for structuring missing actions into a pipe-separated table format.
- Added more verbose logging to `Test-BlockMailForwarding` and improved error handling for better troubleshooting.
- Improved `Test-RestrictCustomScripts` to handle long URL lengths better by extracting and replacing common hostnames, and provided detailed output.
- Added sorting to output.
- Created new functions for improved modularity.
- Parameter validation for Excel and CSV path in sync function.
- Added Output type to tests.
- Added `M365DomainForPWPolicyTest` parameter to `Invoke-M365SecurityAudit` to specify testing only the default domain for password expiration policy when '1.3.1' is included in the tests.

### Fixed

- Ensured the `Invoke-TestFunction` returns a `CISAuditResult` object, which is then managed in the `Invoke-M365SecurityAudit` function.
- Corrected the usage of the join operation within `$details` in `Test-BlockMailForwarding` to handle arrays properly.
- Fixed the logic in `Test-RestrictCustomScripts` to accurately replace and manage URLs, ensuring compliance checks are correctly performed.
- Updated the `Test-MailboxAuditingE3` and `Test-MailboxAuditingE5` functions to handle the `$allFailures` variable correctly, ensuring accurate pass/fail results.
- Fixed the connections in helper CSV and connect function.
- Removed verbose preference from `Test-RestrictCustomScripts`.
- Ensured that the output in `Test-BlockMailForwarding` does not include extra spaces between table headers and data.
- Fixed output in `Test-MailboxAuditingE3` and `Test-MailboxAuditingE5` to correctly align with the new table format.
- Added step 1 and step 2 in `Test-BlockMailForwarding` details to ensure comprehensive compliance checks.
- Fixed the issue with the output in `Test-RestrictCustomScripts` to ensure no extra spaces between table headers and data.

## [0.1.4] - 2024-05-30

### Added

- Test definitions filter function.
- Logging function for future use.
- Test grade written to console.

### Changed

- Updated sync function to include connection info.
- Refactored connect/disconnect functions to evaluate needed connections.

## [0.1.3] - 2024-05-28

### Added

- Array list to store the results of the audit.
- Arraylist tests and helper template.
- New testing function.
- Missing properties to CSV.

### Changed

- Refactored object initialization to source `RecDescription`, `CISControl`, and `CISDescription` properties from the CSV.
- Added `Automated` and `Connection` properties to the output object.
- All test functions aligned with the test-template.
- Initialize-CISAuditResult refactored to use global test definitions.

### Fixed

- Corrected test-template.
- Details added to pass.

### Docs

- Updated comments and documentation for new functions.

## [0.1.2] - 2024-04-29

### Added

- Automated and organized CSV testing and added test 1.1.1.
- Functions to merge tests into an Excel benchmark.
- Public function for merging tests.
- Testing for guest users under test 1.1.4.
- Error handling for `Get-AdminRoleUserLicense`.
- Project URI and icon added to manifest.

### Fixed

- Format for `TestDefinitions.csv`.
- Filename for `Test-AdministrativeAccountCompliance`.
- Error handling in test 1.1.1.
- Properties for skipping and including tests.

### Docs

- Updated comments for new functions.
- Updated help documentation.
- Updated online link in public function.

## [0.1.1] - 2024-04-02

### Fixed

- Fixed Test-ModernAuthExchangeOnline Profile Level in object.

### Added

- CIS Download Notes to Comment-Help Block.
- Notes to README.md for CIS Download.

## [0.1.0-preview0001] - 2024-03-25

### Added

- Initial release of the M365FoundationsCISReport PowerShell module v0.0.1.
- Function `Invoke-M365SecurityAudit` for conducting a comprehensive security audit in Microsoft 365 environments.
- Support for multiple parameter sets including ELevelFilter, IGFilters, RecFilter, and SkipRecFilter to cater to diverse audit requirements.
- Implementation of `-NoModuleCheck`, `-DoNotConnect`, and `-DoNotDisconnect` switches for enhanced control over module behavior.
- Integration with required modules like ExchangeOnlineManagement, AzureAD, Microsoft.Graph, Microsoft.Online.SharePoint.PowerShell, and MicrosoftTeams.
- A dynamic test loading system based on CSV input for flexibility in defining audit tests.
- Comprehensive verbose logging to detail the steps being performed during an audit.
- Comment-help documentation for the `Invoke-M365SecurityAudit` function with examples and usage details.
- Attribution to CIS and licensing information under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License in the README.
