function Update-WorksheetCell {
    [OutputType([void])]
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
            # Add header if it's not present
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
