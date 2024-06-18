function New-MergedObject {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true)]
        [psobject]$ExcelItem,

        [Parameter(Mandatory = $true)]
        [psobject]$CsvRow
    )

    $newObject = New-Object PSObject
    $currentDate = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

    foreach ($property in $ExcelItem.PSObject.Properties) {
        $newObject | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value -Force
    }

    $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_Connection' -Value $CsvRow.Connection -Force
    $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_Status' -Value $CsvRow.Status -Force
    if ($CsvRow.Status -ne $null) {
        $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_Date' -Value $currentDate -Force
    } else {
        $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_Date' -Value $null -Force
    }
    $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_Details' -Value $CsvRow.Details -Force
    $newObject | Add-Member -MemberType NoteProperty -Name 'CSV_FailureReason' -Value $CsvRow.FailureReason -Force

    return $newObject
}
