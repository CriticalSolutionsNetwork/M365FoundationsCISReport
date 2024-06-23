<#
    .SYNOPSIS
        Removes rows from an Excel worksheet where the 'CSV_Status' column is empty and saves the result to a new file.
    .DESCRIPTION
        The Remove-RowsWithEmptyCSVStatus function imports data from a specified worksheet in an Excel file, checks for the presence of the 'CSV_Status' column, and filters out rows where the 'CSV_Status' column is empty. The filtered data is then exported to a new Excel file with a '-Filtered' suffix added to the original file name.
    .PARAMETER FilePath
        The path to the Excel file to be processed.
    .PARAMETER WorksheetName
        The name of the worksheet within the Excel file to be processed.
    .EXAMPLE
        PS C:\> Remove-RowsWithEmptyCSVStatus -FilePath "C:\Reports\Report.xlsx" -WorksheetName "Sheet1"
        This command imports data from the "Sheet1" worksheet in the "Report.xlsx" file, removes rows where the 'CSV_Status' column is empty, and saves the filtered data to a new file named "Report-Filtered.xlsx" in the same directory.
    .NOTES
        This function requires the ImportExcel module to be installed.
#>
function Remove-RowsWithEmptyCSVStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$WorksheetName
    )

    # Import the Excel file
    $ExcelData = Import-Excel -Path $FilePath -WorksheetName $WorksheetName

    # Check if CSV_Status column exists
    if (-not $ExcelData.PSObject.Properties.Match("CSV_Status")) {
        throw "CSV_Status column not found in the worksheet."
    }

    # Filter rows where CSV_Status is not empty
    $FilteredData = $ExcelData | Where-Object { $null -ne $_.CSV_Status -and $_.CSV_Status -ne '' }

    # Get the original file name and directory
    $OriginalFileName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $Directory = [System.IO.Path]::GetDirectoryName($FilePath)

    # Create a new file name for the filtered data
    $NewFileName = "$OriginalFileName-Filtered.xlsx"
    $NewFilePath = Join-Path -Path $Directory -ChildPath $NewFileName

    # Export the filtered data to a new Excel file
    $FilteredData | Export-Excel -Path $NewFilePath -WorksheetName $WorksheetName -Show

    Write-Output "Filtered Excel file created at $NewFilePath"
}