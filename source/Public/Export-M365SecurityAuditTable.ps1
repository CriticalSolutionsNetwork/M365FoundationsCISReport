<#
    .SYNOPSIS
    Exports M365 security audit results to a CSV file or outputs a specific test result as an object.
    .DESCRIPTION
    This function exports M365 security audit results from either an array of CISAuditResult objects or a CSV file.
    It can export all results to a specified path or output a specific test result as an object.
    .PARAMETER AuditResults
    An array of CISAuditResult objects containing the audit results.
    .PARAMETER CsvPath
    The path to a CSV file containing the audit results.
    .PARAMETER OutputTestNumber
    The test number to output as an object. Valid values are "1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4".
    .PARAMETER ExportAllTests
    Switch to export all test results.
    .PARAMETER ExportPath
    The path where the CSV files will be exported.
    .PARAMETER ExportOriginalTests
    Switch to export the original audit results to a CSV file.
    .INPUTS
    [CISAuditResult[]], [string]
    .OUTPUTS
    [PSCustomObject]
    .EXAMPLE
    # Output object for a single test number from audit results
    Export-M365SecurityAuditTable -AuditResults $object -OutputTestNumber 6.1.2
    .EXAMPLE
    # Export all results from audit results to the specified path
    Export-M365SecurityAuditTable -ExportAllTests -AuditResults $object -ExportPath "C:\temp"
    .EXAMPLE
    # Output object for a single test number from CSV
    Export-M365SecurityAuditTable -CsvPath "C:\temp\auditresultstoday1.csv" -OutputTestNumber 6.1.2
    .EXAMPLE
    # Export all results from CSV to the specified path
    Export-M365SecurityAuditTable -ExportAllTests -CsvPath "C:\temp\auditresultstoday1.csv" -ExportPath "C:\temp"
    .EXAMPLE
    # Export all results from audit results to the specified path along with the original tests
    Export-M365SecurityAuditTable -ExportAllTests -AuditResults $object -ExportPath "C:\temp" -ExportOriginalTests
    .EXAMPLE
    # Export all results from CSV to the specified path along with the original tests
    Export-M365SecurityAuditTable -ExportAllTests -CsvPath "C:\temp\auditresultstoday1.csv" -ExportPath "C:\temp" -ExportOriginalTests
    .LINK
    https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Export-M365SecurityAuditTable
#>
function Export-M365SecurityAuditTable {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "ExportAllResultsFromAuditResults")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "OutputObjectFromAuditResultsSingle")]
        [CISAuditResult[]]$AuditResults,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "ExportAllResultsFromCsv")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "OutputObjectFromCsvSingle")]
        [ValidateScript({ (Test-Path $_) -and ((Get-Item $_).PSIsContainer -eq $false) })]
        [string]$CsvPath,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "OutputObjectFromAuditResultsSingle")]
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "OutputObjectFromCsvSingle")]
        [ValidateSet("1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4")]
        [string]$OutputTestNumber,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "ExportAllResultsFromAuditResults")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "ExportAllResultsFromCsv")]
        [switch]$ExportAllTests,

        [Parameter(Mandatory = $true, ParameterSetName = "ExportAllResultsFromAuditResults")]
        [Parameter(Mandatory = $true, ParameterSetName = "ExportAllResultsFromCsv")]
        [string]$ExportPath,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportAllResultsFromAuditResults")]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportAllResultsFromCsv")]
        [switch]$ExportOriginalTests
    )

    if ($PSCmdlet.ParameterSetName -like "ExportAllResultsFromCsv" -or $PSCmdlet.ParameterSetName -eq "OutputObjectFromCsvSingle") {
        $AuditResults = Import-Csv -Path $CsvPath | ForEach-Object {
            $params = @{
                Rec           = $_.Rec
                Result        = [bool]$_.Result
                Status        = $_.Status
                Details       = $_.Details
                FailureReason = $_.FailureReason
            }
            Initialize-CISAuditResult @params
        }
    }

    if ($ExportAllTests) {
        $TestNumbers = "1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4"
    }

    $results = @()

    $testsToProcess = if ($OutputTestNumber) { @($OutputTestNumber) } else { $TestNumbers }

    foreach ($test in $testsToProcess) {
        $auditResult = $AuditResults | Where-Object { $_.Rec -eq $test }
        if (-not $auditResult) {
            Write-Information "No audit results found for the test number $test."
            continue
        }

        switch ($test) {
            "6.1.2" {
                $details = $auditResult.Details
                $csv = $details | ConvertFrom-Csv -Delimiter '|'

                if ($null -ne $csv) {
                    foreach ($row in $csv) {
                        $row.AdminActionsMissing = (Get-Action -AbbreviatedActions $row.AdminActionsMissing.Split(',') -ReverseActionType Admin | Where-Object { $_ -notin @("MailItemsAccessed", "Send") }) -join ','
                        $row.DelegateActionsMissing = (Get-Action -AbbreviatedActions $row.DelegateActionsMissing.Split(',') -ReverseActionType Delegate | Where-Object { $_ -notin @("MailItemsAccessed") }) -join ','
                        $row.OwnerActionsMissing = (Get-Action -AbbreviatedActions $row.OwnerActionsMissing.Split(',') -ReverseActionType Owner | Where-Object { $_ -notin @("MailItemsAccessed", "Send") }) -join ','
                    }
                    $newObjectDetails = $csv
                }
                else {
                    $newObjectDetails = $details
                }
                $results += [PSCustomObject]@{ TestNumber = $test; Details = $newObjectDetails }
            }
            "6.1.3" {
                $details = $auditResult.Details
                $csv = $details | ConvertFrom-Csv -Delimiter '|'

                if ($null -ne $csv) {
                    foreach ($row in $csv) {
                        $row.AdminActionsMissing = (Get-Action -AbbreviatedActions $row.AdminActionsMissing.Split(',') -ReverseActionType Admin) -join ','
                        $row.DelegateActionsMissing = (Get-Action -AbbreviatedActions $row.DelegateActionsMissing.Split(',') -ReverseActionType Delegate) -join ','
                        $row.OwnerActionsMissing = (Get-Action -AbbreviatedActions $row.OwnerActionsMissing.Split(',') -ReverseActionType Owner) -join ','
                    }
                    $newObjectDetails = $csv
                }
                else {
                    $newObjectDetails = $details
                }
                $results += [PSCustomObject]@{ TestNumber = $test; Details = $newObjectDetails }
            }
            Default {
                $details = $auditResult.Details
                $csv = $details | ConvertFrom-Csv -Delimiter '|'
                $results += [PSCustomObject]@{ TestNumber = $test; Details = $csv }
            }
        }
    }

    if ($ExportPath) {
        $timestamp = (Get-Date).ToString("yyyy.MM.dd_HH.mm.ss")
        $exportedTests = @()

        foreach ($result in $results) {
            $testDef = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $result.TestNumber }
            if ($testDef) {
                $fileName = "$ExportPath\$($timestamp)_$($result.TestNumber).$($testDef.TestFileName -replace '\.ps1$').csv"
                if ($result.Details.Count -eq 0) {
                    Write-Information "No results found for test number $($result.TestNumber)." -InformationAction Continue
                }
                else {
                    $result.Details | Export-Csv -Path $fileName -NoTypeInformation
                    $exportedTests += $result.TestNumber
                }
            }
        }
        if ($exportedTests.Count -gt 0) {
            Write-Information "The following tests were exported: $($exportedTests -join ', ')" -InformationAction Continue
        }
        else {
            if ($ExportOriginalTests) {
                Write-Information "No specified tests were included in the export other than the full audit results." -InformationAction Continue
            }
            else {
                Write-Information "No specified tests were included in the export." -InformationAction Continue
            }
        }

        if ($ExportOriginalTests) {
            # Define the test numbers to check
            $TestNumbersToCheck = "1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4"

            # Check for large details and update the AuditResults array
            $updatedAuditResults = Get-ExceededLengthResultDetail -AuditResults $AuditResults -TestNumbersToCheck $TestNumbersToCheck -ExportedTests $exportedTests -DetailsLengthLimit 30000 -PreviewLineCount 25
            $originalFileName = "$ExportPath\$timestamp`_M365FoundationsAudit.csv"
            $updatedAuditResults | Export-Csv -Path $originalFileName -NoTypeInformation
        }
    }
    elseif ($OutputTestNumber) {
        if ($results[0].Details) {
            return $results[0].Details
        }
        else {
            Write-Information "No results found for test number $($OutputTestNumber)." -InformationAction Continue
        }
    }
    else {
        Write-Error "No valid operation specified. Please provide valid parameters."
    }
}
