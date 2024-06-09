function Initialize-CISAuditResult {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Rec,

        [Parameter(Mandatory = $true, ParameterSetName = 'Full')]
        [bool]$Result,

        [Parameter(Mandatory = $true, ParameterSetName = 'Full')]
        [string]$Status,

        [Parameter(Mandatory = $true, ParameterSetName = 'Full')]
        [string]$Details,

        [Parameter(Mandatory = $true, ParameterSetName = 'Full')]
        [string]$FailureReason,

        [Parameter(ParameterSetName = 'Error')]
        [switch]$Failure
    )

    # Import the test definitions CSV file
    $testDefinitions = $script:TestDefinitionsObject

    # Find the row that matches the provided recommendation (Rec)
    $testDefinition = $testDefinitions | Where-Object { $_.Rec -eq $Rec }

    if (-not $testDefinition) {
        throw "Test definition for recommendation '$Rec' not found."
    }

    # Create an instance of CISAuditResult and populate it
    $auditResult = [CISAuditResult]::new()
    $auditResult.Rec = $Rec
    $auditResult.ELevel = $testDefinition.ELevel
    $auditResult.ProfileLevel = $testDefinition.ProfileLevel
    $auditResult.IG1 = [bool]::Parse($testDefinition.IG1)
    $auditResult.IG2 = [bool]::Parse($testDefinition.IG2)
    $auditResult.IG3 = [bool]::Parse($testDefinition.IG3)
    $auditResult.RecDescription = $testDefinition.RecDescription
    $auditResult.CISControl = $testDefinition.CISControl
    $auditResult.CISDescription = $testDefinition.CISDescription
    $auditResult.Automated = [bool]::Parse($testDefinition.Automated)
    $auditResult.Connection = $testDefinition.Connection
    $auditResult.CISControlVer = 'v8'

    if ($PSCmdlet.ParameterSetName -eq 'Full') {
        $auditResult.Result = $Result
        $auditResult.Status = $Status
        $auditResult.Details = $Details
        $auditResult.FailureReason = $FailureReason
    } elseif ($PSCmdlet.ParameterSetName -eq 'Error') {
        $auditResult.Result = $false
        $auditResult.Status = 'Fail'
        $auditResult.Details = "An error occurred while processing the test."
        $auditResult.FailureReason = "Initialization error: Failed to process the test."
    }

    return $auditResult
}
