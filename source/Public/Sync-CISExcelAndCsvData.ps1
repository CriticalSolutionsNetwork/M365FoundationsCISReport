<#
.SYNOPSIS
Synchronizes data between an Excel file and either a CSV file or an output object from Invoke-M365SecurityAudit, and optionally updates the Excel worksheet.
.DESCRIPTION
The Sync-CISExcelAndCsvData function merges data from a specified Excel file with data from either a CSV file or an output object from Invoke-M365SecurityAudit based on a common key. It can also update the Excel worksheet with the merged data. This function is particularly useful for updating Excel records with additional data from a CSV file or audit results while preserving the original formatting and structure of the Excel worksheet.
.PARAMETER ExcelPath
The path to the Excel file that contains the original data. This parameter is mandatory.
.PARAMETER WorksheetName
The name of the worksheet within the Excel file that contains the data to be synchronized. This parameter is mandatory.
.PARAMETER CsvPath
The path to the CSV file containing data to be merged with the Excel data. This parameter is mandatory when using the CsvInput parameter set.
.PARAMETER AuditResults
An array of CISAuditResult objects from Invoke-M365SecurityAudit to be merged with the Excel data. This parameter is mandatory when using the ObjectInput parameter set. It can also accept pipeline input.
.PARAMETER SkipUpdate
If specified, the function will return the merged data object without updating the Excel worksheet. This is useful for previewing the merged data.
.EXAMPLE
PS> Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -WorksheetName "DataSheet" -CsvPath "path\to\data.csv"
Merges data from 'data.csv' into 'excel.xlsx' on the 'DataSheet' worksheet and updates the worksheet with the merged data.
.EXAMPLE
PS> $mergedData = Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -WorksheetName "DataSheet" -CsvPath "path\to\data.csv" -SkipUpdate
Retrieves the merged data object for preview without updating the Excel worksheet.
.EXAMPLE
PS> $auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://tenant-admin.url" -DomainName "example.com"
PS> Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -WorksheetName "DataSheet" -AuditResults $auditResults
Merges data from the audit results into 'excel.xlsx' on the 'DataSheet' worksheet and updates the worksheet with the merged data.
.EXAMPLE
PS> $auditResults = Invoke-M365SecurityAudit -TenantAdminUrl "https://tenant-admin.url" -DomainName "example.com"
PS> $mergedData = Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -WorksheetName "DataSheet" -AuditResults $auditResults -SkipUpdate
Retrieves the merged data object for preview without updating the Excel worksheet.
.EXAMPLE
PS> Invoke-M365SecurityAudit -TenantAdminUrl "https://tenant-admin.url" -DomainName "example.com" | Sync-CISExcelAndCsvData -ExcelPath "path\to\excel.xlsx" -WorksheetName "DataSheet"
Pipes the audit results into Sync-CISExcelAndCsvData to merge data into 'excel.xlsx' on the 'DataSheet' worksheet and updates the worksheet with the merged data.
.INPUTS
System.String, CISAuditResult[]
You can pipe CISAuditResult objects to Sync-CISExcelAndCsvData.
.OUTPUTS
Object[]
If the SkipUpdate switch is used, the function returns an array of custom objects representing the merged data.
.NOTES
- Ensure that the 'ImportExcel' module is installed and up to date.
- It is recommended to backup the Excel file before running this script to prevent accidental data loss.
- This function is part of the CIS Excel and CSV Data Management Toolkit.
.LINK
https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Sync-CISExcelAndCsvData
#>
function Sync-CISExcelAndCsvData {
    [OutputType([void], [PSCustomObject[]])]
    [CmdletBinding(DefaultParameterSetName = 'CsvInput')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ })]
        [string]$ExcelPath,

        [Parameter(Mandatory = $true)]
        [string]$WorksheetName,

        [Parameter(Mandatory = $true, ParameterSetName = 'CsvInput')]
        [ValidateScript({ Test-Path $_ })]
        [string]$CsvPath,

        [Parameter(Mandatory = $true, ParameterSetName = 'ObjectInput', ValueFromPipeline = $true)]
        [CISAuditResult[]]$AuditResults,

        [Parameter(Mandatory = $false)]
        [switch]$SkipUpdate
    )

    process {
        $requiredModules = Get-RequiredModule -SyncFunction
        foreach ($module in $requiredModules) {
            Assert-ModuleAvailability -ModuleName $module.ModuleName -RequiredVersion $module.RequiredVersion -SubModuleName $module.SubModuleName
        }

        if ($PSCmdlet.ParameterSetName -eq 'CsvInput') {
            $mergedData = Merge-CISExcelAndCsvData -ExcelPath $ExcelPath -WorksheetName $WorksheetName -CsvPath $CsvPath
        } else {
            $mergedData = Merge-CISExcelAndCsvData -ExcelPath $ExcelPath -WorksheetName $WorksheetName -AuditResults $AuditResults
        }

        if ($SkipUpdate) {
            return $mergedData
        } else {
            Update-CISExcelWorksheet -ExcelPath $ExcelPath -WorksheetName $WorksheetName -Data $mergedData
        }
    }
}

