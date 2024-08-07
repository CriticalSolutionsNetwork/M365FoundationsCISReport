<#
    .SYNOPSIS
        Invokes a security audit for Microsoft 365 environments.
    .DESCRIPTION
        The Invoke-M365SecurityAudit cmdlet performs a comprehensive security audit based on the specified parameters.
        It allows auditing of various configurations and settings within a Microsoft 365 environment in alignment with CIS benchmarks designated "Automatic".
    .PARAMETER TenantAdminUrl
        The URL of the tenant admin. If not specified, none of the SharePoint Online tests will run.
    .PARAMETER DomainName
        The domain name of the Microsoft 365 environment to test. It is optional and will trigger various tests to run only for the specified domain.
            Tests Affected: 2.1.9/Test-EnableDKIM, 1.3.1/Test-PasswordNeverExpirePolicy, 2.1.4/Test-SafeAttachmentsPolicy
    .PARAMETER ELevel
        Specifies the E-Level (E3 or E5) for the audit. This parameter is optional and can be combined with the ProfileLevel parameter.
    .PARAMETER ProfileLevel
        Specifies the profile level (L1 or L2) for the audit. This parameter is mandatory, but only when ELevel is selected. Otherwise it is not required.
    .PARAMETER IncludeIG1
        If specified, includes tests where IG1 is true.
    .PARAMETER IncludeIG2
        If specified, includes tests where IG2 is true.
    .PARAMETER IncludeIG3
        If specified, includes tests where IG3 is true.
    .PARAMETER IncludeRecommendation
        Specifies specific recommendations to include in the audit. Accepts an array of recommendation numbers.
    .PARAMETER SkipRecommendation
        Specifies specific recommendations to exclude from the audit. Accepts an array of recommendation numbers.
    .PARAMETER ApprovedCloudStorageProviders
        Specifies the approved cloud storage providers for the audit. Accepts an array of cloud storage provider names for test 8.1.1/Test-TeamsExternalFileSharing.
            Acceptable values: 'GoogleDrive', 'ShareFile', 'Box', 'DropBox', 'Egnyte'
    .PARAMETER ApprovedFederatedDomains
        Specifies the approved federated domains for the audit test 8.2.1/Test-TeamsExternalAccess. Accepts an array of allowed domain names.
            Additional Tests may include this parameter in the future.
    .PARAMETER DoNotConnect
        If specified, the cmdlet will not establish a connection to Microsoft 365 services.
    .PARAMETER DoNotDisconnect
        If specified, the cmdlet will not disconnect from Microsoft 365 services after execution.
    .PARAMETER NoModuleCheck
        If specified, the cmdlet will not check for the presence of required modules.
    .PARAMETER DoNotConfirmConnections
        If specified, the cmdlet will not prompt for confirmation before proceeding with established connections and will disconnect from all of them.
    .PARAMETER AuthParams
        Specifies an authentication object containing parameters for application-based authentication. If provided, this will be used for connecting to services.
    .EXAMPLE
        PS> Invoke-M365SecurityAudit
            # Performs a security audit using default parameters.
    .EXAMPLE
        PS> Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -ELevel "E5" -ProfileLevel "L1"
            # Performs a security audit for the E5 level and L1 profile in the specified Microsoft 365 environment.
    .EXAMPLE
        PS> Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -IncludeIG1
            # Performs a security audit while including tests where IG1 is true.
    .EXAMPLE
        PS> Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -SkipRecommendation '1.1.3', '2.1.1'
            # Performs an audit while excluding specific recommendations 1.1.3 and 2.1.1.
    .EXAMPLE
        PS> $auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com"
        PS> Export-M365SecurityAuditTable -AuditResults $auditResults -ExportPath "C:\temp" -ExportOriginalTests -ExportAllTests
    .EXAMPLE
        # (PowerShell 7.x Only) Creating a new authentication object for the security audit for app-based authentication.
        PS> $authParams = New-M365SecurityAuditAuthObject `
                -ClientCertThumbPrint "ABCDEF1234567890ABCDEF1234567890ABCDEF12" `
                -ClientId "12345678-1234-1234-1234-123456789012" `
                -TenantId "12345678-1234-1234-1234-123456789012" `
                -OnMicrosoftUrl "yourcompany.onmicrosoft.com" `
                -SpAdminUrl "https://yourcompany-admin.sharepoint.com"
            Invoke-M365SecurityAudit -AuthParams $authParams -TenantAdminUrl "https://yourcompany-admin.sharepoint.com"
        # Or:
        PS> $auditResults | Export-Csv -Path "auditResults.csv" -NoTypeInformation
            # Captures the audit results into a variable and exports them to a CSV file (Nested tables will be truncated).
                Output:
                    CISAuditResult[]
                    auditResults.csv
    .EXAMPLE
        PS> Invoke-M365SecurityAudit -WhatIf
            Displays what would happen if the cmdlet is run without actually performing the audit.
                Output:
                    What if: Performing the operation "Invoke-M365SecurityAudit" on target "Microsoft 365 environment".
    .INPUTS
        None. You cannot pipe objects to Invoke-M365SecurityAudit.
    .OUTPUTS
        CISAuditResult[]
            The cmdlet returns an array of CISAuditResult objects representing the results of the security audit.
    .NOTES
        - This module is based on CIS benchmarks.
        - Governed by the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
        - Commercial use is not permitted. This module cannot be sold or used for commercial purposes.
        - Modifications and sharing are allowed under the same license.
        - For full license details, visit: https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en
        - Register for CIS Benchmarks at: https://www.cisecurity.org/cis-benchmarks
    .LINK
        https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit
#>
function Invoke-M365SecurityAudit {
    # Add confirm to high
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High" , DefaultParameterSetName = 'Default')]
    [OutputType([CISAuditResult[]])]
    param (
        [Parameter(Mandatory = $false, HelpMessage = "The SharePoint tenant admin URL, which should end with '-admin.sharepoint.com'. If not specified none of the Sharepoint Online tests will run.")]
        [ValidatePattern('^https://[a-zA-Z0-9-]+-admin\.sharepoint\.com$')]
        [string]$TenantAdminUrl,
        [Parameter(Mandatory = $false, HelpMessage = "Specify this to test only the default domain for password expiration and DKIM Config for tests '1.3.1' and 2.1.9. The domain name of your organization, e.g., 'example.com'.")]
        [ValidatePattern('^[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$')]
        [string]$DomainName,
        # E-Level with optional ProfileLevel selection
        [Parameter(Mandatory = $true, ParameterSetName = 'ELevelFilter', HelpMessage = "Specifies the E-Level (E3 or E5) for the audit.")]
        [ValidateSet('E3', 'E5')]
        [string]$ELevel,
        [Parameter(Mandatory = $true, ParameterSetName = 'ELevelFilter', HelpMessage = "Specifies the profile level (L1 or L2) for the audit.")]
        [ValidateSet('L1', 'L2')]
        [string]$ProfileLevel,
        # IG Filters, one at a time
        [Parameter(Mandatory = $true, ParameterSetName = 'IG1Filter', HelpMessage = "Includes tests where IG1 is true.")]
        [switch]$IncludeIG1,
        [Parameter(Mandatory = $true, ParameterSetName = 'IG2Filter', HelpMessage = "Includes tests where IG2 is true.")]
        [switch]$IncludeIG2,
        [Parameter(Mandatory = $true, ParameterSetName = 'IG3Filter', HelpMessage = "Includes tests where IG3 is true.")]
        [switch]$IncludeIG3,
        # Inclusion of specific recommendation numbers
        [Parameter(Mandatory = $true, ParameterSetName = 'RecFilter', HelpMessage = "Specifies specific recommendations to include in the audit. Accepts an array of recommendation numbers.")]
        [ValidateSet(
            '1.1.1', '1.1.3', '1.2.1', '1.2.2', '1.3.1', '1.3.3', '1.3.6', '2.1.1', '2.1.2', `
                '2.1.3', '2.1.4', '2.1.5', '2.1.6', '2.1.7', '2.1.9', '3.1.1', '5.1.2.3', `
                '5.1.8.1', '6.1.1', '6.1.2', '6.1.3', '6.2.1', '6.2.2', '6.2.3', '6.3.1', `
                '6.5.1', '6.5.2', '6.5.3', '7.2.1', '7.2.10', '7.2.2', '7.2.3', '7.2.4', `
                '7.2.5', '7.2.6', '7.2.7', '7.2.9', '7.3.1', '7.3.2', '7.3.4', '8.1.1', `
                '8.1.2', '8.2.1', '8.5.1', '8.5.2', '8.5.3', '8.5.4', '8.5.5', '8.5.6', `
                '8.5.7', '8.6.1'
        )]
        [string[]]$IncludeRecommendation,
        # Exclusion of specific recommendation numbers
        [Parameter(Mandatory = $true, ParameterSetName = 'SkipRecFilter', HelpMessage = "Specifies specific recommendations to exclude from the audit. Accepts an array of recommendation numbers.")]
        [ValidateSet(
            '1.1.1', '1.1.3', '1.2.1', '1.2.2', '1.3.1', '1.3.3', '1.3.6', '2.1.1', '2.1.2', `
                '2.1.3', '2.1.4', '2.1.5', '2.1.6', '2.1.7', '2.1.9', '3.1.1', '5.1.2.3', `
                '5.1.8.1', '6.1.1', '6.1.2', '6.1.3', '6.2.1', '6.2.2', '6.2.3', '6.3.1', `
                '6.5.1', '6.5.2', '6.5.3', '7.2.1', '7.2.10', '7.2.2', '7.2.3', '7.2.4', `
                '7.2.5', '7.2.6', '7.2.7', '7.2.9', '7.3.1', '7.3.2', '7.3.4', '8.1.1', `
                '8.1.2', '8.2.1', '8.5.1', '8.5.2', '8.5.3', '8.5.4', '8.5.5', '8.5.6', `
                '8.5.7', '8.6.1'
        )]
        [string[]]$SkipRecommendation,
        # Common parameters for all parameter sets
        [Parameter(Mandatory = $false, HelpMessage = "Specifies the approved cloud storage providers for the audit. Accepts an array of cloud storage provider names.")]
        [ValidateSet(
            'GoogleDrive', 'ShareFile', 'Box', 'DropBox', 'Egnyte'
        )]
        [string[]]$ApprovedCloudStorageProviders = @(),
        [Parameter(Mandatory = $false, HelpMessage = "Specifies the approved federated domains for the audit test 8.2.1. Accepts an array of allowed domain names.")]
        [ValidatePattern('^[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$')]
        [string[]]$ApprovedFederatedDomains,
        [Parameter(Mandatory = $false, HelpMessage = "Specifies that the cmdlet will not establish a connection to Microsoft 365 services.")]
        [switch]$DoNotConnect,
        [Parameter(Mandatory = $false, HelpMessage = "Specifies that the cmdlet will not disconnect from Microsoft 365 services after execution.")]
        [switch]$DoNotDisconnect,
        [Parameter(Mandatory = $false, HelpMessage = "Specifies that the cmdlet will not check for the presence of required modules.")]
        [switch]$NoModuleCheck,
        [Parameter(Mandatory = $false, HelpMessage = "Specifies that the cmdlet will not prompt for confirmation before proceeding with established connections and will disconnect from all of them.")]
        [switch]$DoNotConfirmConnections,
        [Parameter(Mandatory = $false, HelpMessage = "Specifies an authentication object containing parameters for application-based authentication.")]
        [CISAuthenticationParameters]$AuthParams
    )
    Begin {
        if ($script:MaximumFunctionCount -lt 8192) {
            Write-Verbose "Setting the `$script:MaximumFunctionCount to 8192 for the test run."
            $script:MaximumFunctionCount = 8192
        }
        if ($AuthParams) {
            $script:PnpAuth = $true
        }
        # Ensure required modules are installed
        $requiredModules = Get-RequiredModule -AuditFunction
        # Format the required modules list
        $requiredModulesFormatted = Format-RequiredModuleList -RequiredModules $requiredModules
        # Check and install required modules if necessary
        if (!($NoModuleCheck) -and $PSCmdlet.ShouldProcess("Modules: $requiredModulesFormatted", "Assert-ModuleAvailability")) {
            Write-Information "Checking for and installing required modules..."
            foreach ($module in $requiredModules) {
                Assert-ModuleAvailability -ModuleName $module.ModuleName -RequiredVersion $module.RequiredVersion -SubModules $module.SubModules
            }
        }
        # Load test definitions from CSV
        $testDefinitionsPath = Join-Path -Path $PSScriptRoot -ChildPath "helper\TestDefinitions.csv"
        $testDefinitions = Import-Csv -Path $testDefinitionsPath
        # Load the Test Definitions into the script scope for use in other functions
        $script:TestDefinitionsObject = $testDefinitions
        # Apply filters based on parameter sets
        $params = @{
            TestDefinitions       = $testDefinitions
            ParameterSetName      = $PSCmdlet.ParameterSetName
            ELevel                = $ELevel
            ProfileLevel          = $ProfileLevel
            IncludeRecommendation = $IncludeRecommendation
            SkipRecommendation    = $SkipRecommendation
        }
        $testDefinitions = Get-TestDefinitionsObject @params
        # Extract unique connections needed
        $requiredConnections = $testDefinitions.Connection | Sort-Object -Unique
        if ($requiredConnections -contains 'SPO') {
            if (-not $TenantAdminUrl) {
                $requiredConnections = $requiredConnections | Where-Object { $_ -ne 'SPO' }
                $testDefinitions = $testDefinitions | Where-Object { $_.Connection -ne 'SPO' }
                if ($null -eq $testDefinitions) {
                    throw "No tests to run as no SharePoint Online tests are available."
                }
            }
        }
        # Determine which test files to load based on filtering
        $testsToLoad = $testDefinitions.TestFileName | ForEach-Object { $_ -replace '.ps1$', '' }
        Write-Verbose "The $(($testsToLoad).count) test/s that would be loaded based on filter criteria:"
        $testsToLoad | ForEach-Object { Write-Verbose " $_" }
        # Initialize a collection to hold failed test details
        $script:FailedTests = [System.Collections.ArrayList]::new()
    } # End Begin
    Process {
        $allAuditResults = [System.Collections.ArrayList]::new() # Initialize a collection to hold all results
        # Dynamically dot-source the test scripts
        $testsFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "tests"
        $testFiles = Get-ChildItem -Path $testsFolderPath -Filter "Test-*.ps1" |
        Where-Object { $testsToLoad -contains $_.BaseName }
        $totalTests = $testFiles.Count
        $currentTestIndex = 0
        # Establishing connections if required
        try {
            $actualUniqueConnections = Get-UniqueConnection -Connections $requiredConnections
            if (!($DoNotConnect) -and $PSCmdlet.ShouldProcess("Establish connections to Microsoft 365 services: $($actualUniqueConnections -join ', ')", "Connect")) {
                Write-Information "Establishing connections to Microsoft 365 services: $($actualUniqueConnections -join ', ')"
                Connect-M365Suite -TenantAdminUrl $TenantAdminUrl -RequiredConnections $requiredConnections -SkipConfirmation:$DoNotConfirmConnections -AuthParams $AuthParams
            }
        }
        catch {
            Throw "Connection execution aborted: $_"
        }
        try {
            if ($PSCmdlet.ShouldProcess("Measure and display audit results for $($totalTests) tests", "Measure")) {
                Write-Information "A total of $($totalTests) tests were selected to run..."
                # Import the test functions
                $testFiles | ForEach-Object {
                    $currentTestIndex++
                    Write-Progress -Activity "Loading Test Scripts" -Status "Loading $($currentTestIndex) of $($totalTests): $($_.Name)" -PercentComplete (($currentTestIndex / $totalTests) * 100)
                    Try {
                        # Dot source the test function
                        . $_.FullName
                    }
                    Catch {
                        # Log the error and add the test to the failed tests collection
                        Write-Verbose "Failed to load test function $($_.Name): $_"
                        $script:FailedTests.Add([PSCustomObject]@{ Test = $_.Name; Error = $_ })
                    }
                }
                $currentTestIndex = 0
                # Execute each test function from the prepared list
                foreach ($testFunction in $testFiles) {
                    $currentTestIndex++
                    Write-Progress -Activity "Executing Tests" -Status "Executing $($currentTestIndex) of $($totalTests): $($testFunction.Name)" -PercentComplete (($currentTestIndex / $totalTests) * 100)
                    $functionName = $testFunction.BaseName
                    Write-Information "Executing test function: $functionName"
                    $auditResult = Invoke-TestFunction -FunctionFile $testFunction -DomainName $DomainName -ApprovedCloudStorageProviders $ApprovedCloudStorageProviders -ApprovedFederatedDomains $ApprovedFederatedDomains
                    # Add the result to the collection
                    [void]$allAuditResults.Add($auditResult)
                }
                # Call the private function to calculate and display results
                Measure-AuditResult -AllAuditResults $allAuditResults -FailedTests $script:FailedTests
                # Return all collected audit results
                # Define the test numbers to check
                $TestNumbersToCheck = "1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4"
                # Check for large details in the audit results
                $exceedingTests = Get-ExceededLengthResultDetail -AuditResults $allAuditResults -TestNumbersToCheck $TestNumbersToCheck -ReturnExceedingTestsOnly -DetailsLengthLimit 30000
                if ($exceedingTests.Count -gt 0) {
                    Write-Information "The following tests exceeded the details length limit: $($exceedingTests -join ', ')"
                    Write-Information "( Assuming the results were instantiated. Ex: `$object = invoke-M365SecurityAudit )`nUse the following command and adjust as necessary to view the full details of the test results:"
                    Write-Information "Export-M365SecurityAuditTable -ExportAllTests -AuditResults `$object -ExportPath `"C:\temp`" -ExportOriginalTests"
                }
                return $allAuditResults.ToArray() | Sort-Object -Property Rec
            }
        }
        catch {
            # Log the error and add the test to the failed tests collection
            throw "Failed to execute test function $($testFunction.Name): $_"
            $script:FailedTests.Add([PSCustomObject]@{ Test = $_.Name; Error = $_ })
        }
        finally {
            if (!($DoNotDisconnect) -and $PSCmdlet.ShouldProcess("Disconnect from Microsoft 365 services: $($actualUniqueConnections -join ', ')", "Disconnect")) {
                # Clean up sessions
                Disconnect-M365Suite -RequiredConnections $requiredConnections
            }
        }
    }
    End {

    }
}
