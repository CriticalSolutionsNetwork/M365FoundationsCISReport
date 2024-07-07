<#
    .SYNOPSIS
        Exports Microsoft 365 security audit results to CSV or Excel files and supports outputting specific test results as objects.
    .DESCRIPTION
        The Export-M365SecurityAuditTable function exports Microsoft 365 security audit results from an array of CISAuditResult objects or a CSV file.
        It can export all results to a specified path, output a specific test result as an object, and includes options for exporting results to Excel.
        Additionally, it computes hashes for the exported files and includes them in the zip archive for verification purposes.
    .PARAMETER AuditResults
        An array of CISAuditResult objects containing the audit results. This parameter is mandatory when exporting from audit results.
    .PARAMETER CsvPath
        The path to a CSV file containing the audit results. This parameter is mandatory when exporting from a CSV file.
    .PARAMETER OutputTestNumber
        The test number to output as an object. Valid values are "1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4". This parameter is used to output a specific test result.
    .PARAMETER ExportAllTests
        Switch to export all test results. When specified, all test results are exported to the specified path.
    .PARAMETER ExportPath
        The path where the CSV or Excel files will be exported. This parameter is mandatory when exporting all tests.
    .PARAMETER ExportOriginalTests
        Switch to export the original audit results to a CSV file. When specified, the original test results are exported along with the processed results.
    .PARAMETER ExportToExcel
        Switch to export the results to an Excel file. When specified, results are exported in Excel format.
    .INPUTS
        [CISAuditResult[]] - An array of CISAuditResult objects.
        [string] - A path to a CSV file.
    .OUTPUTS
        [PSCustomObject] - A custom object containing the path to the zip file and its hash.
    .EXAMPLE
        Export-M365SecurityAuditTable -AuditResults $object -OutputTestNumber 6.1.2
        # Outputs the result of test number 6.1.2 from the provided audit results as an object.
    .EXAMPLE
        Export-M365SecurityAuditTable -ExportAllTests -AuditResults $object -ExportPath "C:\temp"
        # Exports all audit results to the specified path in CSV format.
    .EXAMPLE
        Export-M365SecurityAuditTable -CsvPath "C:\temp\auditresultstoday1.csv" -OutputTestNumber 6.1.2
        # Outputs the result of test number 6.1.2 from the CSV file as an object.
    .EXAMPLE
        Export-M365SecurityAuditTable -ExportAllTests -CsvPath "C:\temp\auditresultstoday1.csv" -ExportPath "C:\temp"
        # Exports all audit results from the CSV file to the specified path in CSV format.
    .EXAMPLE
        Export-M365SecurityAuditTable -ExportAllTests -AuditResults $object -ExportPath "C:\temp" -ExportOriginalTests
        # Exports all audit results along with the original test results to the specified path in CSV format.
    .EXAMPLE
        Export-M365SecurityAuditTable -ExportAllTests -CsvPath "C:\temp\auditresultstoday1.csv" -ExportPath "C:\temp" -ExportOriginalTests
        # Exports all audit results from the CSV file along with the original test results to the specified path in CSV format.
    .EXAMPLE
        Export-M365SecurityAuditTable -ExportAllTests -AuditResults $object -ExportPath "C:\temp" -ExportToExcel
        # Exports all audit results to the specified path in Excel format.
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
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "ExportAllResultsFromAuditResults")]
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "ExportAllResultsFromCsv")]
        [switch]$ExportAllTests,
        [Parameter(Mandatory = $true, ParameterSetName = "ExportAllResultsFromAuditResults")]
        [Parameter(Mandatory = $true, ParameterSetName = "ExportAllResultsFromCsv")]
        [string]$ExportPath,
        [Parameter(Mandatory = $true, ParameterSetName = "ExportAllResultsFromAuditResults")]
        [Parameter(Mandatory = $true, ParameterSetName = "ExportAllResultsFromCsv")]
        [switch]$ExportOriginalTests,
        [Parameter(Mandatory = $false, ParameterSetName = "ExportAllResultsFromAuditResults")]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportAllResultsFromCsv")]
        [switch]$ExportToExcel
    )
    Begin {
        $createdFiles = @() # Initialize an array to keep track of created files
        if ($ExportToExcel) {
            Assert-ModuleAvailability -ModuleName ImportExcel -RequiredVersion "7.8.9"
        }
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
    }
    Process {
        foreach ($test in $testsToProcess) {
            $auditResult = $AuditResults | Where-Object { $_.Rec -eq $test }
            if (-not $auditResult) {
                Write-Information "No audit results found for the test number $test."
                continue
            }
            switch ($test) {
                "6.1.2" {
                    $details = $auditResult.Details
                    $newObjectDetails = Get-AuditMailboxDetail -Details $details -Version '6.1.2'
                    $results += [PSCustomObject]@{ TestNumber = $test; Details = $newObjectDetails }
                }
                "6.1.3" {
                    $details = $auditResult.Details
                    $newObjectDetails = Get-AuditMailboxDetail -Details $details -Version '6.1.3'
                    $results += [PSCustomObject]@{ TestNumber = $test; Details = $newObjectDetails }
                }
                Default {
                    $details = $auditResult.Details
                    $csv = $details | ConvertFrom-Csv -Delimiter '|'
                    $results += [PSCustomObject]@{ TestNumber = $test; Details = $csv }
                }
            }
        }
    }
    End {
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
                        if (($result.Details -ne "No M365 E3 licenses found.") -and ($result.Details -ne "No M365 E5 licenses found.")) {
                            if ($ExportToExcel) {
                                $xlsxPath = [System.IO.Path]::ChangeExtension($fileName, '.xlsx')
                                $result.Details | Export-Excel -Path $xlsxPath -WorksheetName Table -TableName Table -AutoSize -TableStyle Medium2
                                $createdFiles += $xlsxPath # Add the created file to the array
                            }
                            else {
                                $result.Details | Export-Csv -Path $fileName -NoTypeInformation
                                $createdFiles += $fileName # Add the created file to the array
                            }
                            $exportedTests += $result.TestNumber
                        }
                    }
                }
            }
            if ($exportedTests.Count -gt 0) {
                Write-Information "The following tests were exported: $($exportedTests -join ', ')" -InformationAction Continue
            }
            else {
                if ($ExportOriginalTests) {
                    Write-Information "Full audit results exported however, none of the following tests had exports: `n1.1.1, 1.3.1, 6.1.2, 6.1.3, 7.3.4" -InformationAction Continue
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
                if ($ExportToExcel) {
                    $xlsxPath = [System.IO.Path]::ChangeExtension($originalFileName, '.xlsx')
                    $updatedAuditResults | Export-Excel -Path $xlsxPath -WorksheetName Table -TableName Table -AutoSize -TableStyle Medium2
                    $createdFiles += $xlsxPath # Add the created file to the array
                }
                else {
                    $updatedAuditResults | Export-Csv -Path $originalFileName -NoTypeInformation
                    $createdFiles += $originalFileName # Add the created file to the array
                }
            }
            # Hash each file and add it to a dictionary
            # Hash each file and save the hashes to a text file
            $hashFilePath = "$ExportPath\$timestamp`_Hashes.txt"
            $fileHashes = @()
            foreach ($file in $createdFiles) {
                $hash = Get-FileHash -Path $file -Algorithm SHA256
                $fileHashes += "$($file): $($hash.Hash)"
            }
            $fileHashes | Set-Content -Path $hashFilePath
            $createdFiles += $hashFilePath # Add the hash file to the array

            # Create a zip file and add all the created files
            $zipFilePath = "$ExportPath\$timestamp`_M365FoundationsAudit.zip"
            Compress-Archive -Path $createdFiles -DestinationPath $zipFilePath

            # Remove the original files after they have been added to the zip
            foreach ($file in $createdFiles) {
                Remove-Item -Path $file -Force
            }

            # Compute the hash for the zip file and rename it
            $zipHash = Get-FileHash -Path $zipFilePath -Algorithm SHA256
            $newZipFilePath = "$ExportPath\$timestamp`_M365FoundationsAudit_$($zipHash.Hash.Substring(0, 8)).zip"
            Rename-Item -Path $zipFilePath -NewName $newZipFilePath

            # Output the zip file path with hash
            [PSCustomObject]@{
                ZipFilePath = $newZipFilePath
            }
        } # End of ExportPath
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
        # Output the created files at the end
        #if ($createdFiles.Count -gt 0) {
        ###########    $createdFiles
        #}
    }
}