

<#
    .SYNOPSIS
    This is a sample Private function only visible within the module.

    .DESCRIPTION
    This sample function is not exported to the module and only return the data passed as parameter.

    .EXAMPLE
    $null = Get-TestError -PrivateData 'NOTHING TO SEE HERE'

    .PARAMETER PrivateData
    The PrivateData parameter is what will be returned without transformation.

#>

function Get-TestError {
    [cmdletBinding()]
    param (
        $LastError,
        $recnum
    )
    # Retrieve the description from the test definitions
    $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
    $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }
    $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $LastError })
    # Call Initialize-CISAuditResult with error parameters
    $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
    Write-Verbose "An error occurred during the test $recnum`: `n$LastError" -Verbose
    return $auditResult
}

