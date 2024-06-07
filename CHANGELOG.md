# Changelog for M365FoundationsCISReport

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Updated test definitions for CIS Microsoft 365 Foundations Benchmark for better error handling and object output when errors occur.
- Added a parameter to the `Initialize-CISAuditResult` function to allow for a static failed object to be created when an error occurs.
- Refactored `Invoke-M365SecurityAudit` to include a new private function `Invoke-TestFunction` for executing test functions and handling errors.
- Added a new private function `Measure-AuditResult` to calculate and display audit results.
- Enhanced error logging to capture failed test details and display them at the end of the audit.
- Added a private function `Get-RequiredModule` to initialize the `$requiredModules` variable for better code organization in the main script.
- Updated `Test-MailboxAuditingE3` and `Test-MailboxAuditingE5` functions to use `Format-MissingActions` for structuring missing actions into a pipe-separated table format.
- Added more verbose logging to `Test-BlockMailForwarding` and improved error handling for better troubleshooting.

### Fixed

- Ensured the `Invoke-TestFunction` returns a `CISAuditResult` object, which is then managed in the `Invoke-M365SecurityAudit` function.
- Corrected the usage of the join operation within `$details` in `Test-BlockMailForwarding` to handle arrays properly.

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
