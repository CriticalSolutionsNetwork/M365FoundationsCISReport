<#
    .SYNOPSIS
        Perform a CIS‑aligned security audit of a Microsoft 365 tenant.
    .DESCRIPTION
        Invoke-M365SecurityAudit runs a series of CIS benchmark tests (v3.0.0 or v4.0.0) against your
        Microsoft 365 environment.  You can filter by domain, license level (E3/E5), profile level (L1/L2),
        IG levels, include or skip specific recommendations, and supply app‑based credentials.
        Results are returned as an array of CISAuditResult objects.
    .PARAMETER TenantAdminUrl
        The SharePoint admin URL (e.g. https://contoso-admin.sharepoint.com).  If omitted, SPO tests are skipped.
    .PARAMETER DomainName
        Limit domain‐specific tests (1.3.1, 2.1.9) to this domain (e.g. “contoso.com”).
    .PARAMETER ELevel
        License audit level (“E3” or “E5”).  Requires -ProfileLevel to also be specified.
    .PARAMETER ProfileLevel
        CIS profile level (“L1” or “L2”).  Mandatory when -ELevel is used.
    .PARAMETER IncludeIG1
        Include IG1‐only tests in the audit.
    .PARAMETER IncludeIG2
        Include IG2‐only tests in the audit.
    .PARAMETER IncludeIG3
        Include IG3‐only tests in the audit.
    .PARAMETER IncludeRecommendation
        An array of specific recommendation IDs to include (e.g. '1.1.3','2.1.1').
    .PARAMETER SkipRecommendation
        An array of specific recommendation IDs to exclude.
    .PARAMETER ApprovedCloudStorageProviders
        For test 8.1.1, list allowed storage providers (‘GoogleDrive’,’Box’,’ShareFile’,’DropBox’,’Egnyte’).
    .PARAMETER ApprovedFederatedDomains
        For test 8.2.1, list allowed federated domains (e.g. 'microsoft.com').
    .PARAMETER DoNotConnect
        Skip connecting to Microsoft 365 services; you must have an existing session.
    .PARAMETER DoNotDisconnect
        Skip disconnecting from Microsoft 365 services at the end.
    .PARAMETER NoModuleCheck
        Skip installing/checking required PowerShell modules.
    .PARAMETER DoNotConfirmConnections
        When connecting, do not prompt for “Proceed?” before authenticating.
    .PARAMETER AuthParams
        A CISAuthenticationParameters object for certificate‑based app authentication.
    .PARAMETER Version
        CIS definitions version (“3.0.0” or “4.0.0”; default “4.0.0”).
    .INPUTS
        None; this cmdlet does not accept pipeline input.
    .OUTPUTS
        CISAuditResult[] — an array of PSCustomObjects representing each test’s outcome.
    .EXAMPLE
        # Quick audit with defaults (v4.0.0)
        Invoke-M365SecurityAudit
    .EXAMPLE
        # Audit E5, level L1, for a single domain:
        Invoke-M365SecurityAudit -TenantAdminUrl 'https://contoso-admin.sharepoint.com' `
            -DomainName 'contoso.com' -ELevel E5 -ProfileLevel L1
    .EXAMPLE
        # Only include specific recommendations:
        Invoke-M365SecurityAudit -IncludeRecommendation '1.1.3','2.1.1'
    .EXAMPLE
        # App‑only auth + skip confirmation:
        $auth = New-M365SecurityAuditAuthObject -ClientId ... -ClientCertThumbPrint ...
        Invoke-M365SecurityAudit -AuthParams $auth -DoNotConfirmConnections
    .LINK
        https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Invoke-M365SecurityAudit
#>

function Invoke-M365SecurityAudit {
    # Add confirm to high
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High' , DefaultParameterSetName = 'Default')]
    [OutputType([CISAuditResult[]])]
    param (
        [Parameter(Mandatory = $false, HelpMessage = "The SharePoint tenant admin URL, which should end with '-admin.sharepoint.com'. If not specified none of the Sharepoint Online tests will run.")]
        [ValidatePattern('^https://[a-zA-Z0-9-]+-admin\.sharepoint\.com$')]
        [string]
        $TenantAdminUrl,
        [Parameter(Mandatory = $false, HelpMessage = "Specify this to test only the default domain for password expiration and DKIM Config for tests '1.3.1' and 2.1.9. The domain name of your organization, e.g., 'example.com'.")]
        [ValidatePattern('^[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$')]
        [string]
        $DomainName,
        # E-Level with optional ProfileLevel selection
        [Parameter(Mandatory = $true, ParameterSetName = 'ELevelFilter', HelpMessage = 'Specifies the E-Level (E3 or E5) for the audit.')]
        [ValidateSet('E3', 'E5')]
        [string]
        $ELevel,
        [Parameter(Mandatory = $true, ParameterSetName = 'ELevelFilter', HelpMessage = 'Specifies the profile level (L1 or L2) for the audit.')]
        [ValidateSet('L1', 'L2')]
        [string]
        $ProfileLevel,
        # IG Filters, one at a time
        [Parameter(Mandatory = $true, ParameterSetName = 'IG1Filter', HelpMessage = 'Includes tests where IG1 is true.')]
        [switch]
        $IncludeIG1,
        [Parameter(Mandatory = $true, ParameterSetName = 'IG2Filter', HelpMessage = 'Includes tests where IG2 is true.')]
        [switch]
        $IncludeIG2,
        [Parameter(Mandatory = $true, ParameterSetName = 'IG3Filter', HelpMessage = 'Includes tests where IG3 is true.')]
        [switch]
        $IncludeIG3,
        # Inclusion of specific recommendation numbers
        [Parameter(Mandatory = $true, ParameterSetName = 'RecFilter', HelpMessage = 'Specifies specific recommendations to include in the audit. Accepts an array of recommendation numbers.')]
        [ValidateSet(
            '1.1.1', '1.1.3', '1.1.4', '1.2.1', '1.2.2', '1.3.1', '1.3.3', '1.3.6', '2.1.1', '2.1.2', `
                '2.1.3', '2.1.4', '2.1.5', '2.1.6', '2.1.7', '2.1.9', '2.1.11', '2.1.12', '2.1.13', `
                '2.1.14', '3.1.1', '5.1.2.3', '5.1.8.1', '6.1.1', '6.1.2', '6.1.3', '6.1.4', '6.2.1', `
                '6.2.2', '6.2.3', '6.3.1', '6.5.1', '6.5.2', '6.5.3', '7.2.1', '7.2.10', '7.2.2', `
                '7.2.3', '7.2.4', '7.2.5', '7.2.6', '7.2.7', '7.2.9', '7.3.1', '7.3.2', '7.3.4', `
                '8.1.1', '8.1.2', '8.2.1', '8.5.1', '8.5.2', '8.5.3', '8.5.4', '8.5.5', '8.5.6', `
                '8.5.7', '8.6.1'
        )]
        [string[]]
        $IncludeRecommendation,
        # Exclusion of specific recommendation numbers
        [Parameter(Mandatory = $true, ParameterSetName = 'SkipRecFilter', HelpMessage = 'Specifies specific recommendations to exclude from the audit. Accepts an array of recommendation numbers.')]
        [ValidateSet(
            '1.1.1', '1.1.3', '1.1.4', '1.2.1', '1.2.2', '1.3.1', '1.3.3', '1.3.6', '2.1.1', '2.1.2', `
                '2.1.3', '2.1.4', '2.1.5', '2.1.6', '2.1.7', '2.1.9', '2.1.11', '2.1.12', '2.1.13', `
                '2.1.14', '3.1.1', '5.1.2.3', '5.1.8.1', '6.1.1', '6.1.2', '6.1.3', '6.1.4', '6.2.1', `
                '6.2.2', '6.2.3', '6.3.1', '6.5.1', '6.5.2', '6.5.3', '7.2.1', '7.2.10', '7.2.2', `
                '7.2.3', '7.2.4', '7.2.5', '7.2.6', '7.2.7', '7.2.9', '7.3.1', '7.3.2', '7.3.4', `
                '8.1.1', '8.1.2', '8.2.1', '8.5.1', '8.5.2', '8.5.3', '8.5.4', '8.5.5', '8.5.6', `
                '8.5.7', '8.6.1'
        )]
        [string[]]
        $SkipRecommendation,
        # Common parameters for all parameter sets
        [Parameter(Mandatory = $false, HelpMessage = 'Specifies the approved cloud storage providers for the audit. Accepts an array of cloud storage provider names.')]
        [ValidateSet(
            'GoogleDrive', 'ShareFile', 'Box', 'DropBox', 'Egnyte'
        )]
        [string[]]
        $ApprovedCloudStorageProviders = @(),
        [Parameter(Mandatory = $false, HelpMessage = 'Specifies the approved federated domains for the audit test 8.2.1. Accepts an array of allowed domain names.')]
        [ValidatePattern('^[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$')]
        [string[]]
        $ApprovedFederatedDomains,
        [Parameter(Mandatory = $false, HelpMessage = 'Specifies that the cmdlet will not establish a connection to Microsoft 365 services.')]
        [switch]
        $DoNotConnect,
        [Parameter(Mandatory = $false, HelpMessage = 'Specifies that the cmdlet will not disconnect from Microsoft 365 services after execution.')]
        [switch]
        $DoNotDisconnect,
        [Parameter(Mandatory = $false, HelpMessage = 'Specifies that the cmdlet will not check for the presence of required modules.')]
        [switch]
        $NoModuleCheck,
        [Parameter(Mandatory = $false, HelpMessage = 'Specifies that the cmdlet will not prompt for confirmation before proceeding with established connections and will disconnect from all of them.')]
        [switch]
        $DoNotConfirmConnections,
        [Parameter(Mandatory = $false, HelpMessage = 'Specifies an authentication object containing parameters for application-based authentication.')]
        [CISAuthenticationParameters]
        $AuthParams,
        [Parameter(Mandatory = $false, HelpMessage = "Specifies the CIS benchmark definitions version to use. Default is 4.0.0. Valid values are '3.0.0' or '4.0.0'.")]
        [ValidateSet('3.0.0', '4.0.0')]
        [string]
        $Version = '4.0.0'
    )
    begin {
        if ($script:MaximumFunctionCount -lt 8192) {
            Write-Verbose "Setting the `$script:MaximumFunctionCount to 8192 for the test run."
            $script:MaximumFunctionCount = 8192
        }
        if ($AuthParams) {
            $script:PnpAuth = $true
            $defaultPNPUpdateCheck = $env:PNPPOWERSHELL_UPDATECHECK
            $env:PNPPOWERSHELL_UPDATECHECK = 'Off'
        }
        # Check for 4.0.0 specific tests when in 3.0.0 mode
        # Test variables for testing 3.0.0 specific tests for included 4.0.0 tests
        $recNumbersToCheck = @('1.1.4', '2.1.11', '2.1.12', '2.1.13', '2.1.14', '6.1.4')
        # $IncludeRecommendation = '1.1.1','1.1.4'
        # $Version = '3.0.0'
        if ($IncludeRecommendation) {
            if ($Version -ne '4.0.0') {
                $foundRecNumbers = @()
                foreach ($rec in $recNumbersToCheck) {
                    if ($IncludeRecommendation -contains $rec) {
                        $foundRecNumbers += $rec
                    }
                }
                if ($foundRecNumbers.Count -gt 0) {
                    throw "Check the '-IncludeRecommendation' parameter. The following test numbers are not available in the 3.0.0 version: $($foundRecNumbers -join ', ')"
                }
            }
        }
        # Ensure required modules are installed
        $requiredModules = Get-RequiredModule -AuditFunction
        # Format the required modules list
        $requiredModulesFormatted = Format-RequiredModuleList -RequiredModules $requiredModules
        # Check and install required modules if necessary
        if (!($NoModuleCheck) -and $PSCmdlet.ShouldProcess("Install Modules: $requiredModulesFormatted", 'Assert-ModuleAvailability')) {
            Write-Information 'Checking for and installing required modules...'
            foreach ($module in $requiredModules) {
                Assert-ModuleAvailability -ModuleName $module.ModuleName -RequiredVersion $module.RequiredVersion -SubModules $module.SubModules
            }
        }
        elseif ($script:PnpAuth = $true) {
            # Ensure MgGraph assemblies are loaded prior to running PnP cmdlets
            Get-MgGroup -Top 1 -ErrorAction SilentlyContinue | Out-Null
        }
        # Define a function to load and merge test definitions

        # Call the function to load and merge test definitions
        $testDefinitions = Get-TestDefinitions -Version $Version
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
                    throw 'No tests to run as no SharePoint Online tests are available.'
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
    process {
        $allAuditResults = [System.Collections.ArrayList]::new() # Initialize a collection to hold all results
        # Dynamically dot-source the test scripts
        $testsFolderPath = Join-Path -Path $PSScriptRoot -ChildPath 'tests'
        $testFiles = Get-ChildItem -Path $testsFolderPath -Filter 'Test-*.ps1' |
        Where-Object { $testsToLoad -contains $_.BaseName }
        $totalTests = $testFiles.Count
        $currentTestIndex = 0
        # Establishing connections if required
        try {
            $actualUniqueConnections = Get-UniqueConnection -Connections $requiredConnections
            if (!($DoNotConnect) -and $PSCmdlet.ShouldProcess("Establish connections to Microsoft 365 services: $($actualUniqueConnections -join ', ')", 'Connect')) {
                Write-Information "Establishing connections to Microsoft 365 services: $($actualUniqueConnections -join ', ')"
                Connect-M365Suite -TenantAdminUrl $TenantAdminUrl -RequiredConnections $requiredConnections -SkipConfirmation:$DoNotConfirmConnections -AuthParams $AuthParams
            }
        }
        catch {
            throw "Connection execution aborted: $_"
        }
    }
    end {
        try {
            if ($PSCmdlet.ShouldProcess("Measure and display audit results for $($totalTests) tests", 'Measure')) {
                Write-Information "A total of $($totalTests) tests were selected to run..."
                # Import the test functions
                $testFiles | ForEach-Object {
                    $currentTestIndex++
                    Write-Progress -Activity 'Loading Test Scripts' -Status "Loading $($currentTestIndex) of $($totalTests): $($_.Name)" -PercentComplete (($currentTestIndex / $totalTests) * 100)
                    try {
                        # Dot source the test function
                        . $_.FullName
                    }
                    catch {
                        # Log the error and add the test to the failed tests collection
                        Write-Verbose "Failed to load test function $($_.Name): $_"
                        $script:FailedTests.Add([PSCustomObject]@{ Test = $_.Name; Error = $_ })
                    }
                }
                $currentTestIndex = 0
                # Execute each test function from the prepared list
                foreach ($testFunction in $testFiles) {
                    $currentTestIndex++
                    Write-Progress -Activity 'Executing Tests' -Status "Executing $($currentTestIndex) of $($totalTests): $($testFunction.Name)" -PercentComplete (($currentTestIndex / $totalTests) * 100)
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
                $TestNumbersToCheck = '1.1.1', '1.3.1', '6.1.2', '6.1.3', '7.3.4'
                # Check for large details in the audit results
                $exceedingTests = Get-ExceededLengthResultDetail -AuditResults $allAuditResults -TestNumbersToCheck $TestNumbersToCheck -ReturnExceedingTestsOnly -DetailsLengthLimit 30000
                if ($exceedingTests.Count -gt 0) {
                    Write-Information "The following tests exceeded the details length limit: $($exceedingTests -join ', ')"
                    Write-Information "( Assuming the results were instantiated. Ex: `$object = invoke-M365SecurityAudit )`nUse the following command and adjust as necessary to view the full details of the test results:"
                    Write-Information "Export-M365SecurityAuditTable -ExportAllTests -AuditResults `$object -ExportPath `"C:\temp`" -ExportOriginalTests"
                }
                # return $allAuditResults.ToArray() | Sort-Object -Property Rec
                # TODO Check if this fixes export-table.
                return $allAuditResults | Sort-Object -Property Rec
            }
        }
        catch {
            # Log the error and add the test to the failed tests collection
            throw "Failed to execute test function $($testFunction.Name): $_"
            $script:FailedTests.Add([PSCustomObject]@{ Test = $_.Name; Error = $_ })
        }
        finally {
            $env:PNPPOWERSHELL_UPDATECHECK = $defaultPNPUpdateCheck
            if (!($DoNotDisconnect) -and $PSCmdlet.ShouldProcess("Disconnect from Microsoft 365 services: $($actualUniqueConnections -join ', ')", 'Disconnect')) {
                # Clean up sessions
                Disconnect-M365Suite -RequiredConnections $requiredConnections
            }
        }
    }
}