# Changelog for M365FoundationsCISReport

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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