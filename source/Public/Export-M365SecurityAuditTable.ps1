<#
    .SYNOPSIS
        Export Microsoft 365 CIS audit results into CSV/Excel and package with hashes.
    .DESCRIPTION
        Export-M365SecurityAuditTable processes an array of CISAuditResult objects, exporting per-test nested tables
        and/or a full audit summary (with oversized fields truncated) to CSV or Excel.  All output files are
        hashed (SHA256) and bundled into a ZIP archive whose filename includes a short hash for integrity.
    .PARAMETER AuditResults
        An array of PSCustomObject (CISAuditResult) objects containing the audit results to export or query.
    .PARAMETER ExportPath
        Path to the directory where CSV/Excel files and the final ZIP archive will be placed. Required for
        any file-based export (DefaultExport or OnlyExportNestedTables).
    .PARAMETER ExportToExcel
        Switch to export files in Excel (.xlsx) format instead of CSV. Requires the ImportExcel module.
    .PARAMETER Prefix
        A short prefix (0–5 characters, default 'Corp') appended to the summary audit filename and hashes.
    .PARAMETER OnlyExportNestedTables
        Switch to export only the per-test nested tables to files, skipping the full audit summary.
    .PARAMETER OutputTestNumber
        Specify one test number (valid values: '1.1.1','1.3.1','6.1.2','6.1.3','7.3.4') to return that test’s
        details in-memory as objects without writing any files.
    .INPUTS
        System.Object[] (array of CISAuditResult PSCustomObjects)
    .OUTPUTS
        PSCustomObject with property ZipFilePath indicating the final ZIP archive location, or raw test details
        when using -OutputTestNumber.
    .EXAMPLE
        # Return details for test 6.1.2
        Export-M365SecurityAuditTable -AuditResults $audits -OutputTestNumber 6.1.2
    .EXAMPLE
        # Full export (nested tables + summary) to CSV
        Export-M365SecurityAuditTable -AuditResults $audits -ExportPath "C:\temp"
    .EXAMPLE
        # Only export nested tables to Excel
        Export-M365SecurityAuditTable -AuditResults $audits -ExportPath "C:\temp" -OnlyExportNestedTables -ExportToExcel
    .EXAMPLE
        # Custom prefix for filenames
        Export-M365SecurityAuditTable -AuditResults $audits -ExportPath "C:\temp" -Prefix Dev
    .LINK
        https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Export-M365SecurityAuditTable
#>
function Export-M365SecurityAuditTable {
    [CmdletBinding(
        DefaultParameterSetName = 'DefaultExport',
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    [OutputType([PSCustomObject])]
    param(
        #───────────────────────────────────────────────────────────────────────────
        # 1) DefaultExport: full audit export (nested tables + summary) into ZIP
        #    -AuditResults, -ExportPath, [-ExportToExcel], [-Prefix]
        #───────────────────────────────────────────────────────────────────────────
        [Parameter(Mandatory, ParameterSetName = 'DefaultExport')]
        [Parameter(Mandatory, ParameterSetName = 'OnlyExportNestedTables')]
        [Parameter(Mandatory, ParameterSetName = 'SingleObject')]
        [psobject[]]
        $AuditResults,
        [Parameter(Mandatory, ParameterSetName = 'DefaultExport')]
        [Parameter(Mandatory, ParameterSetName = 'OnlyExportNestedTables')]
        [string]
        $ExportPath,
        [Parameter(ParameterSetName = 'DefaultExport')]
        [Parameter(ParameterSetName = 'OnlyExportNestedTables')]
        [switch]
        $ExportToExcel,
        [Parameter(ParameterSetName = 'DefaultExport')]
        [Parameter(ParameterSetName = 'OnlyExportNestedTables')]
        [ValidateLength(0,5)]
        [string]
        $Prefix = 'Corp',
        #───────────────────────────────────────────────────────────────────────────
        # 2) OnlyExportNestedTables: nested tables only into ZIP
        #    -AuditResults, -ExportPath, -OnlyExportNestedTables
        #───────────────────────────────────────────────────────────────────────────
        [Parameter(Mandatory, ParameterSetName = 'OnlyExportNestedTables')]
        [switch]
        $OnlyExportNestedTables,
        #───────────────────────────────────────────────────────────────────────────
        # 3) SingleObject: in-memory output of one test’s details
        #    -AuditResults, -OutputTestNumber
        #───────────────────────────────────────────────────────────────────────────
        [Parameter(Mandatory, ParameterSetName = 'SingleObject')]
        [ValidateSet('1.1.1','1.3.1','6.1.2','6.1.3','7.3.4')]
        [string]
        $OutputTestNumber
    )
    Begin {
        # Load v4.0 definitions
        $Version = '4.0.0'
        $script:TestDefinitionsObject = Get-TestDefinition -Version $Version
        # Ensure Excel support if requested
        if ($ExportToExcel) {
            Assert-ModuleAvailability -ModuleName ImportExcel -RequiredVersion '7.8.9'
        }
        # Tests producing nested tables
        $nestedTests = '1.1.1','1.3.1','6.1.2','6.1.3','7.3.4'
        # Initialize collections
        $results      = @()
        $createdFiles = [System.Collections.Generic.List[string]]::new()
        # Determine which tests to process
        if ($PSCmdlet.ParameterSetName -eq 'SingleObject') {
            $testsToProcess = @($OutputTestNumber)
        } else {
            $testsToProcess = $nestedTests
        }
    }
    Process {
        foreach ($test in $testsToProcess) {
            $item = $AuditResults | Where-Object Rec -EQ $test
            if (-not $item) { continue }
            switch ($test) {
                '6.1.2' { $parsed = Get-AuditMailboxDetail -Details $item.Details -Version '6.1.2' }
                '6.1.3' { $parsed = Get-AuditMailboxDetail -Details $item.Details -Version '6.1.3' }
                Default { $parsed = $item.Details | ConvertFrom-Csv -Delimiter '|' }
            }
            $results += [PSCustomObject]@{ TestNumber = $test; Details = $parsed }
        }
    }
    End {
        #--- SingleObject: return in-memory details ---
        if ($PSCmdlet.ParameterSetName -eq 'SingleObject') {
            if ($results.Count -and $results[0].Details) {
                return $results[0].Details
            }
            throw "No results found for test $OutputTestNumber."
        }
        #--- File export: DefaultExport or OnlyExportNestedTables ---
        if (-not $ExportPath) {
            throw 'ExportPath is required for file export.'
        }
        if ($PSCmdlet.ShouldProcess($ExportPath, 'Export and archive audit results')) {
            # Ensure directory
            if (-not (Test-Path $ExportPath)) { New-Item -Path $ExportPath -ItemType Directory -Force | Out-Null }
            $timestamp     = (Get-Date).ToString('yyyy.MM.dd_HH.mm.ss')
            $exportedTests = @()
            # Always truncate large details before writing files
            Write-Verbose 'Truncating oversized details...'
            $truncatedAudit = Get-ExceededLengthResultDetail `
                -AuditResults       $AuditResults `
                -TestNumbersToCheck $nestedTests `
                -ExportedTests      $exportedTests `
                -DetailsLengthLimit 30000 `
                -PreviewLineCount   25
            #--- Export nested tables ---
            Write-Verbose "[$($PSCmdlet.ParameterSetName)] exporting nested table CSV/XLSX..."
            foreach ($entry in $results) {
                if (-not $entry.Details) { continue }
                $name = "$timestamp`_$($entry.TestNumber)"
                $csv  = Join-Path $ExportPath "$name.csv"
                if ($ExportToExcel) {
                    $xlsx = [IO.Path]::ChangeExtension($csv, '.xlsx')
                    $entry.Details | Export-Excel -Path $xlsx -WorksheetName Table -TableName Table -AutoSize -TableStyle Medium2
                    $createdFiles.Add($xlsx)
                } else {
                    $entry.Details | Export-Csv -Path $csv -NoTypeInformation
                    $createdFiles.Add($csv)
                }
                $exportedTests += $entry.TestNumber
            }
            if ($exportedTests.Count) {
                Write-Information "Exported nested tables: $($exportedTests -join ', ')"
            } elseif ($OnlyExportNestedTables) {
                Write-Warning 'No nested data to export.'
            }
            #--- Summary export (DefaultExport only) ---
            if ($PSCmdlet.ParameterSetName -eq 'DefaultExport') {
                Write-Verbose 'Exporting full summary with truncated details...'
                $base = "${timestamp}_${Prefix}-M365FoundationsAudit"
                $out  = Join-Path $ExportPath "$base.csv"
                if ($ExportToExcel) {
                    $xlsx = [IO.Path]::ChangeExtension($out, '.xlsx')
                    $truncatedAudit | select-object * | Export-Excel -Path $xlsx -WorksheetName Table -TableName Table -AutoSize -TableStyle Medium2
                    $createdFiles.Add($xlsx)
                } else {
                    Write-Verbose "Exporting to Path: $out"
                    $truncatedAudit | select-object * | Export-Csv -Path $out -NoTypeInformation
                    $createdFiles.Add($out)
                }
                Write-Information 'Exported summary of all audit results.'
            }
            #--- Hash & ZIP ---
            Write-Verbose 'Computing file hashes...'
            $hashFile = Join-Path $ExportPath "$timestamp`_${Prefix}-Hashes.txt"
            $createdFiles | ForEach-Object {
                $h = Get-FileHash -Path $_ -Algorithm SHA256
                "$([IO.Path]::GetFileName($_)): $($h.Hash)"
            } | Set-Content -Path $hashFile
            $createdFiles.Add($hashFile)
            Write-Verbose 'Creating ZIP archive...'
            $zip = Join-Path $ExportPath "$timestamp`_${Prefix}-M365FoundationsAudit.zip"
            Compress-Archive -Path $createdFiles -DestinationPath $zip -Force
            $createdFiles | Remove-Item -Force
            # Rename to include short hash
            $zHash  = Get-FileHash -Path $zip -Algorithm SHA256
            $final  = Join-Path $ExportPath ("$timestamp`_${Prefix}-M365FoundationsAudit_$($zHash.Hash.Substring(0,8)).zip")
            Rename-Item -Path $zip -NewName (Split-Path $final -Leaf)
            return [PSCustomObject]@{ ZipFilePath = $final }
        }
    }
}