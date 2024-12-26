function Invoke-TestFunction {
    [OutputType([CISAuditResult[]])]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$FunctionFile,
        [Parameter(Mandatory = $false)]
        [string]$DomainName,
        [Parameter(Mandatory = $false)]
        [string[]]$ApprovedCloudStorageProviders,
        [Parameter(Mandatory = $false)]
        [string[]]$ApprovedFederatedDomains
    )

    $functionName = $FunctionFile.BaseName
    $functionCmd = Get-Command -Name $functionName

    # Check if the test function needs DomainName parameter
    $paramList = @{}
    if ('DomainName' -in $functionCmd.Parameters.Keys) {
        $paramList.DomainName = $DomainName
    }
    if ('ApprovedCloudStorageProviders' -in $functionCmd.Parameters.Keys) {
        $paramList.ApprovedCloudStorageProviders = $ApprovedCloudStorageProviders
    }
    if ('ApprovedFederatedDomains' -in $functionCmd.Parameters.Keys) {
        $paramList.ApprovedFederatedDomains = $ApprovedFederatedDomains
    }
        # Version-aware logging
    Write-Verbose "Running $functionName (Version: $($script:Version400 ? '4.0.0' : '3.0.0'))..."
    try {
        $result = & $functionName @paramList
        # Assuming each function returns an array of CISAuditResult or a single CISAuditResult
        return $result
    }
    catch {
        Write-Error "An error occurred during the test $RecNum`:: $_"
        $script:FailedTests.Add([PSCustomObject]@{ Test = $functionName; Error = $_ })

        # Call Initialize-CISAuditResult with error parameters
        $auditResult = Initialize-CISAuditResult -Rec $functionName -Failure
        return $auditResult
    }
}
