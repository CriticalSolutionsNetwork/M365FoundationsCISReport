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
        # Update headers if they don't exist or if explicitly needed
        if ($Worksheet.Cells[1, $colIndex].Value -ne $property.Name) {
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
