function Test-PasswordNeverExpirePolicy {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        [Parameter(Mandatory = $false)]
        [string]$DomainName
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "1.3.1"
        $overallResult = $true
        $detailsList = @()
        $failureReasonsList = @()

        # Add headers for the details
        $detailsList += "Domain|Validity Period|IsDefault"
    }

    process {
        try {
            # Retrieve all domains or a specific domain
            $domains = if ($DomainName) {
                Get-MgDomain -DomainId $DomainName
            } else {
                Get-MgDomain
            }

            foreach ($domain in $domains) {
                $domainName = $domain.Id
                $isDefault = $domain.IsDefault
                # Retrieve password expiration policy
                $passwordPolicy = $domain.PasswordValidityPeriodInDays

                # Determine if the policy is compliant
                $isCompliant = $passwordPolicy -eq 0
                $overallResult = $overallResult -and $isCompliant

                # Prepare failure reasons and details based on compliance
                $failureReasons = if ($isCompliant) {
                    "N/A"
                } else {
                    "Password expiration is not set to never expire for domain $domainName. Run the following command to remediate: `nUpdate-MgDomain -DomainId $domainName -PasswordValidityPeriodInDays 2147483647 -PasswordNotificationWindowInDays 30"
                }

                $details = "$domainName|$passwordPolicy days|$isDefault"

                # Add details and failure reasons to the lists
                $detailsList += $details
                $failureReasonsList += $failureReasons
            }

            # Prepare the final failure reason and details
            $finalFailureReason = $failureReasonsList -join "`n"
            $finalDetails = $detailsList -join "`n"

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $overallResult
                Status        = if ($overallResult) { "Pass" } else { "Fail" }
                Details       = $finalDetails
                FailureReason = $finalFailureReason
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            Write-Error "An error occurred during the test: $_"

            # Retrieve the description from the test definitions
            $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
            $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }

            $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
