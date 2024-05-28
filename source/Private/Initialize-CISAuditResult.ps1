function Initialize-CISAuditResult {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Rec,

        [Parameter(Mandatory = $true)]
        [bool]$Result,

        [Parameter(Mandatory = $true)]
        [string]$Status,

        [Parameter(Mandatory = $true)]
        [string]$Details,

        [Parameter(Mandatory = $true)]
        [string]$FailureReason,

        [Parameter(Mandatory = $true)]
        [string]$RecDescription,

        [Parameter(Mandatory = $true)]
        [string]$CISControl,

        [Parameter(Mandatory = $true)]
        [string]$CISDescription
    )

    # Import the test definitions CSV file
    $testDefinitionsPath = Join-Path -Path $PSScriptRoot -ChildPath "helper/TestDefinitions.csv"
    $testDefinitions = Import-Csv -Path $testDefinitionsPath

    # Find the row that matches the provided recommendation (Rec)
    $testDefinition = $testDefinitions | Where-Object { $_.Rec -eq $Rec }

    # Create an instance of CISAuditResult and populate it
    $auditResult = [CISAuditResult]::new()
    $auditResult.Rec = $Rec
    $auditResult.ELevel = $testDefinition.ELevel
    $auditResult.ProfileLevel = $testDefinition.ProfileLevel
    $auditResult.IG1 = [bool]::Parse($testDefinition.IG1)
    $auditResult.IG2 = [bool]::Parse($testDefinition.IG2)
    $auditResult.IG3 = [bool]::Parse($testDefinition.IG3)
    $auditResult.RecDescription = $RecDescription
    $auditResult.CISControl = $CISControl
    $auditResult.CISDescription = $CISDescription
    $auditResult.Automated = [bool]::Parse($testDefinition.Automated)
    $auditResult.Connection = $testDefinition.Connection
    $auditResult.CISControlVer = 'v8'
    $auditResult.Result = $Result
    $auditResult.Status = $Status
    $auditResult.Details = $Details
    $auditResult.FailureReason = $FailureReason

    return $auditResult
}
