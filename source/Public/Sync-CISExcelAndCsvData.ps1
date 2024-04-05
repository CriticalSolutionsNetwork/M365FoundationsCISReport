<#
    .SYNOPSIS
    Synchronizes data between an Excel file and a CSV file and optionally updates the Excel worksheet.
    .DESCRIPTION
    The Sync-CISExcelAndCsvData function merges data from a specified Excel file and a CSV file based on a common key. It can also update the Excel worksheet with the merged data. This function is particularly useful for updating Excel records with additional data from a CSV file while preserving the original formatting and structure of the Excel worksheet.
    .PARAMETER ExcelPath
    The path to the Excel file that contains the original data. This parameter is mandatory.
    .PARAMETER WorksheetName
    The name of the worksheet within the Excel file that contains the data to be synchronized. This parameter is mandatory.
    .PARAMETER CsvPath
    The path to the CSV file containing data to be merged with the Excel data. This parameter is mandatory.
    .PARAMETER SkipUpdate
    If specified, the function will return the merged data object without updating the Excel worksheet. This is useful for previewing the merged data.
    .EXAMPLE
    PS> Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -WorksheetName "DataSheet" -CsvPath "path\to\data.csv"
    Merges data from 'data.csv' into 'excel.xlsx' on the 'DataSheet' worksheet and updates the worksheet with the merged data.
    .EXAMPLE
    PS> $mergedData = Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -WorksheetName "DataSheet" -CsvPath "path\to\data.csv" -SkipUpdate
    Retrieves the merged data object for preview without updating the Excel worksheet.
    .INPUTS
    None. You cannot pipe objects to Sync-CISExcelAndCsvData.
    .OUTPUTS
    Object[]
    If the SkipUpdate switch is used, the function returns an array of custom objects representing the merged data.
    .NOTES
    - Ensure that the 'ImportExcel' module is installed and up to date.
    - It is recommended to backup the Excel file before running this script to prevent accidental data loss.
    - This function is part of the CIS Excel and CSV Data Management Toolkit.
    .LINK
    Online documentation: [Your Documentation Link Here]
#>

function Sync-CISExcelAndCsvData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ExcelPath,

        [Parameter(Mandatory = $true)]
        [string]$WorksheetName,

        [Parameter(Mandatory = $true)]
        [string]$CsvPath,

        [Parameter(Mandatory = $false)]
        [switch]$SkipUpdate
    )

    process {
        # Merge Excel and CSV data
        $mergedData = Merge-CISExcelAndCsvData -ExcelPath $ExcelPath -WorksheetName $WorksheetName -CsvPath $CsvPath

        # Output the merged data if the user chooses to skip the update
        if ($SkipUpdate) {
            return $mergedData
        } else {
            # Update the Excel worksheet with the merged data
            Update-CISExcelWorksheet -ExcelPath $ExcelPath -WorksheetName $WorksheetName -Data $mergedData
        }
    }
}
