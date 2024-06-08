function Merge-CISExcelAndCsvData {
    [CmdletBinding(DefaultParameterSetName = 'CsvInput')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ExcelPath,

        [Parameter(Mandatory = $true)]
        [string]$WorksheetName,

        [Parameter(Mandatory = $true, ParameterSetName = 'CsvInput')]
        [string]$CsvPath,

        [Parameter(Mandatory = $true, ParameterSetName = 'ObjectInput')]
        [CISAuditResult[]]$AuditResults
    )

    process {
        # Import data from Excel
        $import = Import-Excel -Path $ExcelPath -WorksheetName $WorksheetName

        # Import data from CSV or use provided object
        $csvData = if ($PSCmdlet.ParameterSetName -eq 'CsvInput') {
            Import-Csv -Path $CsvPath
        } else {
            $AuditResults
        }

        # Iterate over each item in the imported Excel object and merge with CSV data or audit results
        $mergedData = foreach ($item in $import) {
            $csvRow = $csvData | Where-Object { $_.Rec -eq $item.'recommendation #' }
            if ($csvRow) {
                New-MergedObject -ExcelItem $item -CsvRow $csvRow
            } else {
                New-MergedObject -ExcelItem $item -CsvRow ([PSCustomObject]@{Connection=$null;Status=$null; Details=$null; FailureReason=$null })
            }
        }

        # Return the merged data
        return $mergedData
    }
}