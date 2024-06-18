function Merge-CISExcelAndCsvData {
    [CmdletBinding(DefaultParameterSetName = 'CsvInput')]
    [OutputType([PSCustomObject[]])]
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
        $import = Import-Excel -Path $ExcelPath -WorksheetName $WorksheetName

        $csvData = if ($PSCmdlet.ParameterSetName -eq 'CsvInput') {
            Import-Csv -Path $CsvPath
        } else {
            $AuditResults
        }

        $mergedData = foreach ($item in $import) {
            $csvRow = $csvData | Where-Object { $_.Rec -eq $item.'recommendation #' }
            if ($csvRow) {
                New-MergedObject -ExcelItem $item -CsvRow $csvRow
            } else {
                $item
            }
        }

        return $mergedData
    }
}
