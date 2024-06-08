function New-MergedObject {
    param (
        [Parameter(Mandatory = $true)]
        [psobject]$ExcelItem,

        [Parameter(Mandatory = $true)]
        [psobject]$CsvRow
    )

    $newObject = New-Object PSObject

    foreach ($property in $ExcelItem.PSObject.Properties) {
        $newObject | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value
    }
    $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_Connection' -Value $CsvRow.Connection
    $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_Status' -Value $CsvRow.Status
    $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_Details' -Value $CsvRow.Details
    $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_FailureReason' -Value $CsvRow.FailureReason
    return $newObject
}
