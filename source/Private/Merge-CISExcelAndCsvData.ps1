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
        # Import data from Excel
        $import = Import-Excel -Path $ExcelPath -WorksheetName $WorksheetName

        # Import data from CSV or use provided object
        $csvData = if ($PSCmdlet.ParameterSetName -eq 'CsvInput') {
            Import-Csv -Path $CsvPath
        } else {
            $AuditResults
        }

        # Extract recommendation numbers from the CSV
        $csvRecs = $csvData | Select-Object -ExpandProperty Rec

        # Ensure headers are included in the merged data
        $headers = @()
        $firstItem = $import[0]
        foreach ($property in $firstItem.PSObject.Properties) {
            $headers += $property.Name
        }
        $headers += 'CSV_Connection', 'CSV_Status', 'CSV_Date', 'CSV_Details', 'CSV_FailureReason'

        $mergedData = @()
        foreach ($item in $import) {
            # Check if the recommendation number exists in the CSV
            $recNum = $item.'recommendation #'
            if ($csvRecs -contains $recNum) {
                $csvRow = $csvData | Where-Object { $_.Rec -eq $recNum }
                $mergedData += New-MergedObject -ExcelItem $item -CsvRow $csvRow
            } else {
                $mergedData += $item
            }
        }

        # Create a new PSObject array with headers included
        $result = @()
        foreach ($item in $mergedData) {
            $newItem = New-Object PSObject
            foreach ($header in $headers) {
                $newItem | Add-Member -MemberType NoteProperty -Name $header -Value $item.$header -Force
            }
            $result += $newItem
        }

        return $result
    }
}
