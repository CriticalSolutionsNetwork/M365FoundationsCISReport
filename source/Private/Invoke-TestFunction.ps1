function Invoke-TestFunction {
    [OutputType([CISAuditResult[]])]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$FunctionFile,
        [Parameter(Mandatory = $false)]
        [string]$DomainName,
        [Parameter(Mandatory = $false)]
        [string[]]$ApprovedCloudStorageProvider
    )

    $functionName = $FunctionFile.BaseName
    $functionCmd = Get-Command -Name $functionName

    # Check if the test function needs DomainName parameter
    $paramList = @{}
    if ('DomainName' -in $functionCmd.Parameters.Keys) {
        $paramList.DomainName = $DomainName
    }
    if ('ApprovedCloudStorageProvider' -in $functionCmd.Parameters.Keys) {
        $paramList.ApprovedCloudStorageProvider = $ApprovedCloudStorageProvider
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
