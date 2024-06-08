function Invoke-TestFunction {
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$FunctionFile,

        [Parameter(Mandatory = $true)]
        [string]$DomainName
    )

    $functionName = $FunctionFile.BaseName
    $functionCmd = Get-Command -Name $functionName

    # Check if the test function needs DomainName parameter
    $paramList = @{}
    if ('DomainName' -in $functionCmd.Parameters.Keys) {
        $paramList.DomainName = $DomainName
    }

    # Use splatting to pass parameters
    Write-Verbose "Running $functionName..."
    try {
        $result = & $functionName @paramList
        # Assuming each function returns an array of CISAuditResult or a single CISAuditResult
        return $result
    }
    catch {
        Write-Error "An error occurred during the test: $_"
        $script:FailedTests.Add([PSCustomObject]@{ Test = $functionName; Error = $_ })

        # Call Initialize-CISAuditResult with error parameters
        $auditResult = Initialize-CISAuditResult -Rec $functionName -Failure
        return $auditResult
    }
}
