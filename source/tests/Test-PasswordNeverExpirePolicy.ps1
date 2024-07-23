function Test-PasswordNeverExpirePolicy {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        [Parameter(Mandatory = $false)]
        [string]$DomainName
    )

    begin {
        # .TODO add supported services to output details. ({Email, OfficeCommunicationsOnline, Intune})
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "1.3.1"
        $overallResult = $true
        $detailsList = @()
        $failureReasonsList = @()

        # Add headers for the details
        $detailsList += "Domain|Validity Period|Notification Window|IsDefault"

        # Conditions for 1.3.1 (L1) Ensure the 'Password expiration policy' is set to 'Set passwords to never expire (recommended)'
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: Password expiration policy is set to "Set passwords to never expire" in the Microsoft 365 admin center.
        #   - Condition B: Using Microsoft Graph PowerShell, the `PasswordPolicies` property for all users is set to `DisablePasswordExpiration`.
        #   - Condition C: Notification window for password expiration is set to 30 days.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: Password expiration policy is not set to "Set passwords to never expire" in the Microsoft 365 admin center.
        #   - Condition B: Using Microsoft Graph PowerShell, the `PasswordPolicies` property for one or more users is not set to `DisablePasswordExpiration`.
        #   - Condition C: Notification window for password expiration is not set to 30 days.
    }

    process {
        try {
            # Step: Retrieve all domains or a specific domain
            $domains = Get-CISMgOutput -Rec $recnum -DomainName $DomainName
            foreach ($domain in $domains) {
                $domainName = $domain.Id
                $isDefault = $domain.IsDefault
                # Step (Condition C): Determine if the notification window is set to 30 days
                $notificationWindow = $domain.PasswordNotificationWindowInDays
                $notificationPolIsCompliant = $true # No longer a requirement
                # Step (Condition A): Retrieve password expiration policy
                $passwordPolicy = $domain.PasswordValidityPeriodInDays
                $pwPolIsCompliant = $passwordPolicy -eq 2147483647
                # Step (Condition A & B): Determine if the policy is compliant
                $overallResult = $overallResult -and $notificationPolIsCompliant -and $pwPolIsCompliant
                # Step (Condition A & B): Prepare failure reasons and details based on compliance
                $failureReasons = if ($notificationPolIsCompliant -and $pwPolIsCompliant) {
                    "N/A"
                }
                else {
                    "Password expiration is not set to never expire or notification window is not set to 30 days for domain $domainName. Run the following command to remediate: `nUpdate-MgDomain -DomainId $domainName -PasswordValidityPeriodInDays 2147483647 -PasswordNotificationWindowInDays 30`n"
                }
                $details = "$domainName|$passwordPolicy days|$notificationWindow days|$isDefault"
                # Add details and failure reasons to the lists
                $detailsList += $details
                $failureReasonsList += $failureReasons
            }
            # Prepare the final failure reason and details
            $finalFailureReason = $failureReasonsList -join "`n"
            $finalDetails = $detailsList -join "`n"
            # Step: Create and populate the CISAuditResult object
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
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}
