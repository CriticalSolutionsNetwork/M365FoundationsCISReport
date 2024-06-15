function Export-M365SecurityAuditTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "FromAuditResultsSingle")]
        [Parameter(Mandatory = $true, ParameterSetName = "FromAuditResultsMultiple")]
        [CISAuditResult[]]$AuditResults,

        [Parameter(Mandatory = $true, ParameterSetName = "FromCsvSingle")]
        [Parameter(Mandatory = $true, ParameterSetName = "FromCsvMultiple")]
        [ValidateScript({ Test-Path $_ -and (Get-Item $_).PSIsContainer -eq $false })]
        [string]$CsvPath,

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "FromAuditResultsSingle")]
        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "FromCsvSingle")]
        [ValidateSet("1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4")]
        [string]$TestNumber,

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "FromAuditResultsMultiple")]
        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "FromCsvMultiple")]
        [ValidateSet("1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4")]
        [string[]]$TestNumbers,

        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "FromAuditResultsMultiple")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "FromCsvMultiple")]
        [Parameter(Mandatory = $false, Position = 2, ParameterSetName = "FromAuditResultsSingle")]
        [Parameter(Mandatory = $false, Position = 2, ParameterSetName = "FromCsvSingle")]
        [string]$ExportPath
    )

    if ($PSCmdlet.ParameterSetName -like "FromCsv*") {
        $AuditResults = Import-Csv -Path $CsvPath | ForEach-Object {
            [CISAuditResult]::new(
                $_.Status,
                $_.ELevel,
                $_.ProfileLevel,
                [bool]$_.Automated,
                $_.Connection,
                $_.Rec,
                $_.RecDescription,
                $_.CISControlVer,
                $_.CISControl,
                $_.CISDescription,
                [bool]$_.IG1,
                [bool]$_.IG2,
                [bool]$_.IG3,
                [bool]$_.Result,
                $_.Details,
                $_.FailureReason
            )
        }
    }

    if (-not $TestNumbers -and -not $TestNumber) {
        $TestNumbers = "1.1.1", "1.3.1", "6.1.2", "6.1.3", "7.3.4"
        if (-not $ExportPath) {
            Write-Error "ExportPath is required when exporting all test results."
            return
        }
    }

    $results = @()

    $testsToProcess = if ($TestNumber) { @($TestNumber) } else { $TestNumbers }

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
                $result.Details | Export-Csv -Path $fileName -NoTypeInformation -Delimiter '|'
            }
        }
    }
    else {
        return $results.Details
    }
}
