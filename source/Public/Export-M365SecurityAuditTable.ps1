function Export-M365SecurityAuditTable {
    [CmdletBinding()]
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
        [string]$ExportPath
    )

    function Initialize-CISAuditResult {
        [CmdletBinding()]
        [OutputType([CISAuditResult])]
        param (
            [Parameter(Mandatory = $true)]
            [string]$Rec,

            [Parameter(Mandatory = $true, ParameterSetName = 'Full')]
            [bool]$Result,

            [Parameter(Mandatory = $true, ParameterSetName = 'Full')]
            [string]$Status,

            [Parameter(Mandatory = $true, ParameterSetName = 'Full')]
            [string]$Details,

            [Parameter(Mandatory = $true, ParameterSetName = 'Full')]
            [string]$FailureReason,

            [Parameter(ParameterSetName = 'Error')]
            [switch]$Failure
        )

        # Import the test definitions CSV file
        $testDefinitions = $script:TestDefinitionsObject

        # Find the row that matches the provided recommendation (Rec)
        $testDefinition = $testDefinitions | Where-Object { $_.Rec -eq $Rec }

        if (-not $testDefinition) {
            throw "Test definition for recommendation '$Rec' not found."
        }

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.Rec = $Rec
        $auditResult.ELevel = $testDefinition.ELevel
        $auditResult.ProfileLevel = $testDefinition.ProfileLevel
        $auditResult.IG1 = [bool]::Parse($testDefinition.IG1)
        $auditResult.IG2 = [bool]::Parse($testDefinition.IG2)
        $auditResult.IG3 = [bool]::Parse($testDefinition.IG3)
        $auditResult.RecDescription = $testDefinition.RecDescription
        $auditResult.CISControl = $testDefinition.CISControl
        $auditResult.CISDescription = $testDefinition.CISDescription
        $auditResult.Automated = [bool]::Parse($testDefinition.Automated)
        $auditResult.Connection = $testDefinition.Connection
        $auditResult.CISControlVer = 'v8'

        if ($PSCmdlet.ParameterSetName -eq 'Full') {
            $auditResult.Result = $Result
            $auditResult.Status = $Status
            $auditResult.Details = $Details
            $auditResult.FailureReason = $FailureReason
        } elseif ($PSCmdlet.ParameterSetName -eq 'Error') {
            $auditResult.Result = $false
            $auditResult.Status = 'Fail'
            $auditResult.Details = "An error occurred while processing the test."
            $auditResult.FailureReason = "Initialization error: Failed to process the test."
        }

        return $auditResult
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

    foreach ($test in $testsToProcess) {
        $auditResult = $AuditResults | Where-Object { $_.Rec -eq $test }
        if (-not $auditResult) {
            Write-Error "No audit results found for the test number $test."
            continue
        }

        switch ($test) {
            "6.1.2" {
                $details = $auditResult.Details
                $csv = $details | ConvertFrom-Csv -Delimiter '|'

                foreach ($row in $csv) {
                    $row.AdminActionsMissing = (Get-Action -AbbreviatedActions $row.AdminActionsMissing.Split(',') -ReverseActionType Admin | Where-Object { $_ -notin @("MailItemsAccessed", "Send") }) -join ','
                    $row.DelegateActionsMissing = (Get-Action -AbbreviatedActions $row.DelegateActionsMissing.Split(',') -ReverseActionType Delegate | Where-Object { $_ -notin @("MailItemsAccessed") }) -join ','
                    $row.OwnerActionsMissing = (Get-Action -AbbreviatedActions $row.OwnerActionsMissing.Split(',') -ReverseActionType Owner | Where-Object { $_ -notin @("MailItemsAccessed", "Send") }) -join ','
                }

                $newObjectDetails = $csv
                $results += [PSCustomObject]@{ TestNumber = $test; Details = $newObjectDetails }
            }
            "6.1.3" {
                $details = $auditResult.Details
                $csv = $details | ConvertFrom-Csv -Delimiter '|'

                foreach ($row in $csv) {
                    $row.AdminActionsMissing = (Get-Action -AbbreviatedActions $row.AdminActionsMissing.Split(',') -ReverseActionType Admin) -join ','
                    $row.DelegateActionsMissing = (Get-Action -AbbreviatedActions $row.DelegateActionsMissing.Split(',') -ReverseActionType Delegate) -join ','
                    $row.OwnerActionsMissing = (Get-Action -AbbreviatedActions $row.OwnerActionsMissing.Split(',') -ReverseActionType Owner) -join ','
                }

                $newObjectDetails = $csv
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
        foreach ($result in $results) {
            $testDef = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $result.TestNumber }
            if ($testDef) {
                $fileName = "$ExportPath\$($timestamp)_$($result.TestNumber).$($testDef.TestFileName -replace '\.ps1$').csv"
                $result.Details | Export-Csv -Path $fileName -NoTypeInformation
            }
        }
    } elseif ($OutputTestNumber) {
        return $results[0].Details
    } else {
        Write-Error "No valid operation specified. Please provide valid parameters."
    }
}
