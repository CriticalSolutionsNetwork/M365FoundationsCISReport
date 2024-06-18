function Sync-CISExcelAndCsvData {
    param(
        [string]$ExcelPath,
        [string]$CsvPath,
        [string]$SheetName
    )

    # Import the CSV file
    $csvData = Import-Csv -Path $CsvPath

    # Get the current date in the specified format
    $currentDate = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    # Load the Excel workbook
    $excelPackage = Open-ExcelPackage -Path $ExcelPath
    $worksheet = $excelPackage.Workbook.Worksheets[$SheetName]

    # Define and check new headers, including the date header
    $lastCol = $worksheet.Dimension.End.Column
    $newHeaders = @("CSV_Connection", "CSV_Status", "CSV_Date", "CSV_Details", "CSV_FailureReason")
    $existingHeaders = $worksheet.Cells[1, 1, 1, $lastCol].Value

    # Add new headers if they do not exist
    foreach ($header in $newHeaders) {
        if ($header -notin $existingHeaders) {
            $lastCol++
            $worksheet.Cells[1, $lastCol].Value = $header
        }
    }

    # Save changes made to add headers
    $excelPackage.Save()

    # Update the worksheet variable to include possible new columns
    $worksheet = $excelPackage.Workbook.Worksheets[$SheetName]

    # Mapping the headers to their corresponding column numbers
    $headerMap = @{}
    for ($col = 1; $col -le $worksheet.Dimension.End.Column; $col++) {
        $headerMap[$worksheet.Cells[1, $col].Text] = $col
    }

    # For each record in CSV, find the matching row and update/add data
    foreach ($row in $csvData) {
        # Find the matching recommendation # row
        $matchRow = $null
        for ($i = 2; $i -le $worksheet.Dimension.End.Row; $i++) {
            if ($worksheet.Cells[$i, $headerMap['Recommendation #']].Text -eq $row.rec) {
                $matchRow = $i
                break
            }
        }

        # Update values if a matching row is found
        if ($matchRow) {
            foreach ($header in $newHeaders) {
                if ($header -eq 'CSV_Date') {
                    $columnIndex = $headerMap[$header]
                    $worksheet.Cells[$matchRow, $columnIndex].Value = $currentDate
                } else {
                    $csvKey = $header -replace 'CSV_', ''
                    $columnIndex = $headerMap[$header]
                    $worksheet.Cells[$matchRow, $columnIndex].Value = $row.$csvKey
                }
            }
        }
    }

    # Save the updated Excel file
    $excelPackage.Save()
    $excelPackage.Dispose()
}