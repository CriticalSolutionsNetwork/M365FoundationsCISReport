function Get-ExceededLengthResultDetail {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'UpdateArray')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ReturnExceedingTests')]
        [object[]]$AuditResults,

        [Parameter(Mandatory = $true, ParameterSetName = 'UpdateArray')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ReturnExceedingTests')]
        [string[]]$TestNumbersToCheck,

        [Parameter(Mandatory = $false, ParameterSetName = 'UpdateArray')]
        [string[]]$ExportedTests,

        [Parameter(Mandatory = $true, ParameterSetName = 'ReturnExceedingTests')]
        [switch]$ReturnExceedingTestsOnly,

        [int]$DetailsLengthLimit = 30000,

        [Parameter(Mandatory = $true, ParameterSetName = 'UpdateArray')]
        [int]$PreviewLineCount = 50
    )

    $exceedingTests = @()
    $updatedResults = @()

    for ($i = 0; $i -lt $AuditResults.Count; $i++) {
        $auditResult = $AuditResults[$i]
        if ($auditResult.Rec -in $TestNumbersToCheck) {
            if ($auditResult.Details.Length -gt $DetailsLengthLimit) {
                if ($ReturnExceedingTestsOnly) {
                    $exceedingTests += $auditResult.Rec
                } else {
                    $previewLines = ($auditResult.Details -split '\r?\n' | Select-Object -First $PreviewLineCount) -join "`n"
                    $message = "The test result is too large to be exported to CSV. Use the audit result and the export function for full output.`n`nPreview:`n$previewLines"

                    if ($ExportedTests -contains $auditResult.Rec) {
                        Write-Information "The test result for $($auditResult.Rec) is too large for CSV and was included in the export. Check the exported files."
                        $auditResult.Details = $message
                    } else {
                        $auditResult.Details = $message
                    }
                }
            }
        }
        $updatedResults += $auditResult
    }

    if ($ReturnExceedingTestsOnly) {
        return $exceedingTests
    } else {
        return $updatedResults
    }
}