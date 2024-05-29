<#
    .SYNOPSIS
    Invokes a security audit for Microsoft 365 environments.
    .DESCRIPTION
    The Invoke-M365SecurityAudit cmdlet performs a comprehensive security audit based on the specified parameters. It allows auditing of various configurations and settings within a Microsoft 365 environment, such as compliance with CIS benchmarks.
    .PARAMETER TenantAdminUrl
    The URL of the tenant admin. This parameter is mandatory.
    .PARAMETER DomainName
    The domain name of the Microsoft 365 environment. This parameter is mandatory.
    .PARAMETER ELevel
    Specifies the E-Level (E3 or E5) for the audit. This parameter is optional and can be combined with the ProfileLevel parameter.
    .PARAMETER ProfileLevel
    Specifies the profile level (L1 or L2) for the audit. This parameter is optional and can be combined with the ELevel parameter.
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
    .PARAMETER DoNotConnect
    If specified, the cmdlet will not establish a connection to Microsoft 365 services.
    .PARAMETER DoNotDisconnect
    If specified, the cmdlet will not disconnect from Microsoft 365 services after execution.
    .PARAMETER NoModuleCheck
    If specified, the cmdlet will not check for the presence of required modules.
    .EXAMPLE
    PS> Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -ELevel "E5" -ProfileLevel "L1"

    Performs a security audit for the E5 level and L1 profile in the specified Microsoft 365 environment.
    .EXAMPLE
    PS> Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -IncludeIG1

    Performs an audit including all tests where IG1 is true.
    .EXAMPLE
    PS> Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com" -SkipRecommendation '1.1.3', '2.1.1'

    Performs an audit while excluding specific recommendations 1.1.3 and 2.1.1.
    .EXAMPLE
    PS> $auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://contoso-admin.sharepoint.com" -DomainName "contoso.com"
    PS> $auditResults | Export-Csv -Path "auditResults.csv" -NoTypeInformation

    Captures the audit results into a variable and exports them to a CSV file.
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
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Default')]
    [OutputType([CISAuditResult[]])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TenantAdminUrl,

        [Parameter(Mandatory = $true)]
        [string]$DomainName,

        # E-Level with optional ProfileLevel selection
        [Parameter(ParameterSetName = 'ELevelFilter')]
        [ValidateSet('E3', 'E5')]
        [string]$ELevel,

        [Parameter(ParameterSetName = 'ELevelFilter')]
        [ValidateSet('L1', 'L2')]
        [string]$ProfileLevel,

        # IG Filters, one at a time
        [Parameter(ParameterSetName = 'IG1Filter')]
        [switch]$IncludeIG1,

        [Parameter(ParameterSetName = 'IG2Filter')]
        [switch]$IncludeIG2,

        [Parameter(ParameterSetName = 'IG3Filter')]
        [switch]$IncludeIG3,

        # Inclusion of specific recommendation numbers
        [Parameter(ParameterSetName = 'RecFilter')]
        [ValidateSet(
            '1.1.1','1.1.3', '1.2.1', '1.2.2', '1.3.1', '1.3.3', '1.3.6', '2.1.1', '2.1.2', `
                '2.1.3', '2.1.4', '2.1.5', '2.1.6', '2.1.7', '2.1.9', '3.1.1', '5.1.2.3', `
                '5.1.8.1', '6.1.1', '6.1.2', '6.1.3', '6.2.1', '6.2.2', '6.2.3', '6.3.1', `
                '6.5.1', '6.5.2', '6.5.3', '7.2.1', '7.2.10', '7.2.2', '7.2.3', '7.2.4', `
                '7.2.5', '7.2.6', '7.2.7', '7.2.9', '7.3.1', '7.3.2', '7.3.4', '8.1.1', `
                '8.1.2', '8.2.1', '8.5.1', '8.5.2', '8.5.3', '8.5.4', '8.5.5', '8.5.6', `
                '8.5.7', '8.6.1'
        )]
        [string[]]$IncludeRecommendation,

        # Exclusion of specific recommendation numbers
        [Parameter(ParameterSetName = 'SkipRecFilter')]
        [ValidateSet(
            '1.1.1','1.1.3', '1.2.1', '1.2.2', '1.3.1', '1.3.3', '1.3.6', '2.1.1', '2.1.2', `
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
        # Define the required modules and versions in a hashtable
        if (!($NoModuleCheck)) {
            $requiredModules = @(
                @{ ModuleName = "ExchangeOnlineManagement"; RequiredVersion = "3.3.0" },
                @{ ModuleName = "AzureAD"; RequiredVersion = "2.0.2.182" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Authentication" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Users" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Groups" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "DirectoryObjects" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Domains" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Reports" },
                @{ ModuleName = "Microsoft.Graph"; RequiredVersion = "2.4.0"; SubModuleName = "Mail" },
                @{ ModuleName = "Microsoft.Online.SharePoint.PowerShell"; RequiredVersion = "16.0.24009.12000" },
                @{ ModuleName = "MicrosoftTeams"; RequiredVersion = "5.5.0" }
            )
            foreach ($module in $requiredModules) {
                Assert-ModuleAvailability -ModuleName $module.ModuleName -RequiredVersion $module.RequiredVersion -SubModuleName $module.SubModuleName
            }
        }


        # Loop through each required module and assert its availability

        # Establishing connections
        #if (!($DoNotConnect -or $DoNotTest)) {
        # Establishing connections
        if (!($DoNotConnect)) {
            Connect-M365Suite -TenantAdminUrl $TenantAdminUrl
        }

        # Load test definitions from CSV
        $testDefinitionsPath = Join-Path -Path $PSScriptRoot -ChildPath "helper\TestDefinitions.csv"
        $testDefinitions = Import-Csv -Path $testDefinitionsPath
        # Load the Test Definitions into the script scope for use in other functions
        $script:TestDefinitionsObject = $testDefinitions
        # Apply filters based on parameter sets
        switch ($PSCmdlet.ParameterSetName) {
            'ELevelFilter' {
                if ($null -ne $ELevel -and $null -ne $ProfileLevel) {
                    $testDefinitions = $testDefinitions | Where-Object {
                        $_.ELevel -eq $ELevel -and $_.ProfileLevel -eq $ProfileLevel
                    }
                }
                elseif ($null -ne $ELevel) {
                    $testDefinitions = $testDefinitions | Where-Object {
                        $_.ELevel -eq $ELevel
                    }
                }
                elseif ($null -ne $ProfileLevel) {
                    $testDefinitions = $testDefinitions | Where-Object {
                        $_.ProfileLevel -eq $ProfileLevel
                    }
                }
            }
            'IG1Filter' {
                $testDefinitions = $testDefinitions | Where-Object { $_.IG1 -eq 'TRUE' }
            }
            'IG2Filter' {
                $testDefinitions = $testDefinitions | Where-Object { $_.IG2 -eq 'TRUE' }
            }
            'IG3Filter' {
                $testDefinitions = $testDefinitions | Where-Object { $_.IG3 -eq 'TRUE' }
            }
            'RecFilter' {
                $testDefinitions = $testDefinitions | Where-Object { $IncludeRecommendation -contains $_.Rec }
            }
            'SkipRecFilter' {
                $testDefinitions = $testDefinitions | Where-Object { $SkipRecommendation -notcontains $_.Rec }
            }
        }
        # End switch ($PSCmdlet.ParameterSetName)

        # Determine which test files to load based on filtering
        $testsToLoad = $testDefinitions.TestFileName | ForEach-Object { $_ -replace '.ps1$', '' }

        # Display the tests that would be loaded if the function is called with -WhatIf

        Write-Verbose "The $(($testsToLoad).count) test/s that would be loaded based on filter criteria:"
        $testsToLoad | ForEach-Object { Write-Verbose " $_" }
    } # End Begin

    Process {
        $allAuditResults = [System.Collections.ArrayList]::new() #@()  # Initialize a collection to hold all results

        # Dynamically dot-source the test scripts
        $testsFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "tests"
        $testFiles = Get-ChildItem -Path $testsFolderPath -Filter "Test-*.ps1" |
        Where-Object { $testsToLoad -contains $_.BaseName }

        # Import the test functions
        $testFiles | ForEach-Object {
            Try {
                . $_.FullName
            }
            Catch {
                Write-Error "Failed to load test function $($_.Name): $_"
            }
        }

        # Execute each test function from the prepared list
        foreach ($testFunction in $testFiles) {
            $functionName = $testFunction.BaseName
            $functionCmd = Get-Command -Name $functionName

            # Check if the test function needs DomainName parameter
            $paramList = @{}
            if ('DomainName' -in $functionCmd.Parameters.Keys) {
                $paramList.DomainName = $DomainName
            }

            # Use splatting to pass parameters
            if ($PSCmdlet.ShouldProcess($functionName, "Execute test")) {
                Write-Host "Running $functionName..."
                $result = & $functionName @paramList
                # Assuming each function returns an array of CISAuditResult or a single CISAuditResult
                [void]($allAuditResults.add($Result))
            }
        }
    }

    End {
        if (!($DoNotDisconnect)) {
            # Clean up sessions
            Disconnect-M365Suite
        }
        # Return all collected audit results
        return $allAuditResults.ToArray()
        # Check if the Disconnect switch is present
    }
}