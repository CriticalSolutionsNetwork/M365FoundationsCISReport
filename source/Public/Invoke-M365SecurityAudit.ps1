function Invoke-M365SecurityAudit {
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Default')]
    [OutputType([CISAuditResult[]])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TenantAdminUrl,

        [Parameter(Mandatory = $true)]
        [string]$DomainName,

        # E-Level with optional ProfileLevel selection
        [Parameter(Mandatory = $true, ParameterSetName = 'ELevelFilter')]
        [ValidateSet('E3', 'E5')]
        [string]$ELevel,

        [Parameter(Mandatory = $true, ParameterSetName = 'ELevelFilter')]
        [ValidateSet('L1', 'L2')]
        [string]$ProfileLevel,

        # IG Filters, one at a time
        [Parameter(Mandatory = $true, ParameterSetName = 'IG1Filter')]
        [switch]$IncludeIG1,

        [Parameter(Mandatory = $true, ParameterSetName = 'IG2Filter')]
        [switch]$IncludeIG2,

        [Parameter(Mandatory = $true, ParameterSetName = 'IG3Filter')]
        [switch]$IncludeIG3,

        # Inclusion of specific recommendation numbers
        [Parameter(Mandatory = $true, ParameterSetName = 'RecFilter')]
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
        [Parameter(Mandatory = $true, ParameterSetName = 'SkipRecFilter')]
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
        [switch]$DoNotConnect,
        [switch]$DoNotDisconnect,
        [switch]$NoModuleCheck
    )

    Begin {
        if ($script:MaximumFunctionCount -lt 8192) {
            $script:MaximumFunctionCount = 8192
        }
        # Ensure required modules are installed
        if (!($NoModuleCheck)) {
            $requiredModules = Get-RequiredModule
            foreach ($module in $requiredModules) {
                Assert-ModuleAvailability -ModuleName $module.ModuleName -RequiredVersion $module.RequiredVersion -SubModuleName $module.SubModuleName
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
        # Establishing connections if required
        if (!($DoNotConnect)) {
            Connect-M365Suite -TenantAdminUrl $TenantAdminUrl -RequiredConnections $requiredConnections
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
        # Import the test functions
        $testFiles | ForEach-Object {
            Try {
                # Dot source the test function
                . $_.FullName
            }
            Catch {
                # Log the error and add the test to the failed tests collection
                Write-Error "Failed to load test function $($_.Name): $_"
                $script:FailedTests.Add([PSCustomObject]@{ Test = $_.Name; Error = $_ })
            }
        }

        # Execute each test function from the prepared list
        foreach ($testFunction in $testFiles) {
            $functionName = $testFunction.BaseName
            if ($PSCmdlet.ShouldProcess($functionName, "Execute test")) {
                $auditResult = Invoke-TestFunction -FunctionFile $testFunction -DomainName $DomainName
                # Add the result to the collection
                [void]$allAuditResults.Add($auditResult)
            }
        }
    }

    End {
        if (!($DoNotDisconnect)) {
            # Clean up sessions
            Disconnect-M365Suite -RequiredConnections $requiredConnections
        }
        # Call the private function to calculate and display results
        Measure-AuditResult -AllAuditResults $allAuditResults -FailedTests $script:FailedTests
        # Return all collected audit results
        return $allAuditResults.ToArray()
    }
}
