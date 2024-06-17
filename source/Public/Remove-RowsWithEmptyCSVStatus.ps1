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