function Update-CISExcelWorksheet {
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

        # Function to update cells in the worksheet
        function Update-WorksheetCells {
            param (
                $Worksheet,
                $Data,
                $StartingRowIndex
            )

            # Check and set headers
            $firstItem = $Data[0]
            $colIndex = 1
            foreach ($property in $firstItem.PSObject.Properties) {
                if ($StartingRowIndex -eq 2 -and $Worksheet.Cells[1, $colIndex].Value -eq $null) {
                    $Worksheet.Cells[1, $colIndex].Value = $property.Name
                }
                $colIndex++
            }

            # Iterate over each row in the data and update cells
            $rowIndex = $StartingRowIndex
            foreach ($item in $Data) {
                $colIndex = 1
                foreach ($property in $item.PSObject.Properties) {
                    $Worksheet.Cells[$rowIndex, $colIndex].Value = $property.Value
                    $colIndex++
                }
                $rowIndex++
            }
        }

        # Update the worksheet with the provided data
        Update-WorksheetCells -Worksheet $worksheet -Data $Data -StartingRowIndex $StartingRowIndex

        # Save and close the Excel package
        Close-ExcelPackage $excelPackage
    }
}