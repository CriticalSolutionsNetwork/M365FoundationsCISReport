function Update-CISExcelWorksheet {
    [OutputType([void])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ExcelPath,

        [Parameter(Mandatory = $true)]
        [string]$WorksheetName,

        [Parameter(Mandatory = $true)]
        [psobject[]]$Data,

        [Parameter(Mandatory = $false)]
        [int]$StartingRowIndex = 2 # Default starting row index, assuming row 1 has headers
    )

    process {
        # Load the existing Excel sheet
        $excelPackage = Open-ExcelPackage -Path $ExcelPath
        $worksheet = $excelPackage.Workbook.Worksheets[$WorksheetName]

        if (-not $worksheet) {
            throw "Worksheet '$WorksheetName' not found in '$ExcelPath'"
        }

        # Ensure headers are set
        $firstItem = $Data[0]
        $colIndex = 1
        foreach ($property in $firstItem.PSObject.Properties) {
            if ($worksheet.Cells[1, $colIndex].Value -eq $null -or $worksheet.Cells[1, $colIndex].Value -ne $property.Name) {
                $worksheet.Cells[1, $colIndex].Value = $property.Name
            }
            $colIndex++
        }

        # Update the worksheet with the provided data
        Update-WorksheetCell -Worksheet $worksheet -Data $Data -StartingRowIndex $StartingRowIndex

        # Save and close the Excel package
        Close-ExcelPackage $excelPackage
    }
}
