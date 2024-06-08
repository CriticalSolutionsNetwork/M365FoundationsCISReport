function Merge-CISExcelAndCsvData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ExcelPath,

        [Parameter(Mandatory = $true)]
        [string]$WorksheetName,

        [Parameter(Mandatory = $true)]
        [string]$CsvPath
    )

    process {
        # Import data from Excel and CSV
        $import = Import-Excel -Path $ExcelPath -WorksheetName $WorksheetName
        $csvData = Import-Csv -Path $CsvPath

        # Iterate over each item in the imported Excel object and merge with CSV data
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
