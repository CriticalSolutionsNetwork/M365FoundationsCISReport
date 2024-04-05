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

        # Define a function to create a merged object
        function CreateMergedObject($excelItem, $csvRow) {
            $newObject = New-Object PSObject

            foreach ($property in $excelItem.PSObject.Properties) {
                $newObject | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value
            }

            $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_Status' -Value $csvRow.Status
            $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_Details' -Value $csvRow.Details
            $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_FailureReason' -Value $csvRow.FailureReason

            return $newObject
        }

        # Iterate over each item in the imported Excel object and merge with CSV data
        $mergedData = foreach ($item in $import) {
            $csvRow = $csvData | Where-Object { $_.Rec -eq $item.'recommendation #' }
            if ($csvRow) {
                CreateMergedObject -excelItem $item -csvRow $csvRow
            } else {
                CreateMergedObject -excelItem $item -csvRow ([PSCustomObject]@{Status=$null; Details=$null; FailureReason=$null})
            }
        }

        # Return the merged data
        return $mergedData
    }
}
