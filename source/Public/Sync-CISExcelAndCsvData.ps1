<#
    .SYNOPSIS
    Synchronizes and updates data in an Excel worksheet with new information from a CSV file, including audit dates.
    .DESCRIPTION
    The Sync-CISExcelAndCsvData function merges and updates data in a specified Excel worksheet from a CSV file. This includes adding or updating fields for connection status, details, failure reasons, and the date of the update. It's designed to ensure that the Excel document maintains a running log of changes over time, ideal for tracking remediation status and audit history.
    .PARAMETER ExcelPath
    Specifies the path to the Excel file to be updated. This parameter is mandatory.
    .PARAMETER CsvPath
    Specifies the path to the CSV file containing new data. This parameter is mandatory.
    .PARAMETER SheetName
    Specifies the name of the worksheet in the Excel file where data will be merged and updated. This parameter is mandatory.
    .EXAMPLE
    PS> Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -CsvPath "path\to\data.csv" -SheetName "AuditData"
    Updates the 'AuditData' worksheet in 'excel.xlsx' with data from 'data.csv', adding new information and the date of the update.
    .INPUTS
    System.String
    The function accepts strings for file paths and worksheet names.
    .OUTPUTS
    None
    The function directly updates the Excel file and does not output any objects.
    .NOTES
    - Ensure that the 'ImportExcel' module is installed and up to date to handle Excel file manipulations.
    - It is recommended to back up the Excel file before running this function to avoid accidental data loss.
    - The CSV file should have columns that match expected headers like 'Connection', 'Details', 'FailureReason', and 'Status' for correct data mapping.
    .LINK
    https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData
#>

function Sync-CISExcelAndCsvData {
    [OutputType([void])]
    [CmdletBinding()]
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