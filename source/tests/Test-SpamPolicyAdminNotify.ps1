function Test-SpamPolicyAdminNotify {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param ()
    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        <#
            Conditions for 2.1.6 (L1) Ensure Exchange Online Spam Policies are set to notify administrators:
            Description:
                - This test ensures that Exchange Online Spam Policies are configured to notify administrators when a sender in the organization has been blocked for sending spam. It checks for the proper setup of both Bcc and Notify properties and the inclusion of valid email addresses.
            Validate test for a pass:
                - Checks that the 'BccSuspiciousOutboundMail' and 'NotifyOutboundSpam' properties are enabled for the default policy.
                - Ensures that valid email addresses are provided for 'NotifyOutboundSpamRecipients' and 'BccSuspiciousOutboundAdditionalRecipients'.
            Validate test for a fail:
            - If the default policy is not found, this is flagged as a critical compliance issue.
            - The test fails if any of the following settings are incorrect:
                - 'BccSuspiciousOutboundMail' is not enabled.
                - 'NotifyOutboundSpam' is not enabled.
                - 'NotifyOutboundSpamRecipients' does not contain at least one valid email address.
                - 'BccSuspiciousOutboundAdditionalRecipients' does not contain at least one valid email address.
            Note:
            - While the primary focus is on the default policy, the function also retrieves and displays settings from additional policies that are not default, providing comprehensive insight into the organization's configuration. These additional policies are not used to determine the test's pass/fail status but are included in the details for informational purposes.
        #>
        $RecNum = "2.1.6"
        Write-Verbose "Running Test-SpamPolicyAdminNotify for $RecNum..."
    }
    process {
        try {
            # Mock data representing multiple spam filter policies
            <#
                $spamPolicies = @(
                    [PSCustomObject]@{
                        Name                                       = "Default"
                        IsDefault                                  = $true
                        NotifyOutboundSpam                         = $false
                        BccSuspiciousOutboundMail                  = $true
                        NotifyOutboundSpamRecipients               = "admin@example.com"
                        BccSuspiciousOutboundAdditionalRecipients  = "bccadmin@example.com"
                    },
                    [PSCustomObject]@{
                        Name                                       = "Custom Policy 1"
                        IsDefault                                  = $false
                        NotifyOutboundSpam                         = $false
                        BccSuspiciousOutboundMail                  = $true
                        NotifyOutboundSpamRecipients               = ""
                        BccSuspiciousOutboundAdditionalRecipients  = ""
                    },
                    [PSCustomObject]@{
                        Name                                       = "Custom Policy 2"
                        IsDefault                                  = $false
                        NotifyOutboundSpam                         = $true
                        BccSuspiciousOutboundMail                  = $false
                        NotifyOutboundSpamRecipients               = "notify@example.com"
                        BccSuspiciousOutboundAdditionalRecipients  = "bccnotify@example.com"
                    }
                )
            #>
            $spamPolicies = Get-CISExoOutput -Rec $RecNum
            $defaultPolicy = $spamPolicies | Where-Object { $_.IsDefault -eq $true }
            $additionalPolicies = $spamPolicies | Where-Object { $_.IsDefault -eq $false }
            $details = @()
            $failureReasons = @()
            # Check the default policy settings and format details
            # Build the details string for the default policy
            if ($defaultPolicy) {
                $details += "Default Policy: $($defaultPolicy.Name)`n`n" +
                "Bcc Suspicious Outbound Mail: $($defaultPolicy.BccSuspiciousOutboundMail)`n" +
                "Notify Outbound Spam: $($defaultPolicy.NotifyOutboundSpam)`n" +
                "Notify Emails: $($defaultPolicy.NotifyOutboundSpamRecipients -join ', ')`n" +
                "Bcc Emails: $($defaultPolicy.BccSuspiciousOutboundAdditionalRecipients -join ', ')"
                if (-not $defaultPolicy.BccSuspiciousOutboundMail) {
                    $failureReasons += "BccSuspiciousOutboundMail should be enabled."
                }
                if (-not $defaultPolicy.NotifyOutboundSpam) {
                    $failureReasons += "NotifyOutboundSpam should be enabled."
                }
                if (-not $defaultPolicy.NotifyOutboundSpamRecipients) {
                    $failureReasons += "NotifyOutboundSpamRecipients should have at least one valid email."
                }
                if (-not $defaultPolicy.BccSuspiciousOutboundAdditionalRecipients) {
                    $failureReasons += "BccSuspiciousOutboundAdditionalRecipients should have at least one valid email."
                }
            }
            else {
                $failureReasons += "No default policy found. This is critical for compliance."
            }
            # Format additional policy details
            foreach ($policy in $additionalPolicies) {
                $details += "`n`nAdditional Policy: $($policy.Name)`n`n" +
                "Bcc Suspicious Outbound Mail: $($policy.BccSuspiciousOutboundMail)`n" +
                "Notify Outbound Spam: $($policy.NotifyOutboundSpam)`n" +
                "Notify Emails: $($policy.NotifyOutboundSpamRecipients -join ', ')`n" +
                "Bcc Emails: $($policy.BccSuspiciousOutboundAdditionalRecipients -join ', ')"
            }
            $result = $failureReasons.Count -eq 0
            $detailsString = $details -join "`n"
            $failureReasonsString = $failureReasons -join "`n"
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $RecNum
                Result        = $result
                Status        = if ($result) { "Pass" } else { "Fail" }
                Details       = $detailsString
                FailureReason = if (-not $result) { $failureReasonsString } else { "All settings are correct based on the default policy." }
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            Write-Error "An error occurred during the test $RecNum`:: $_"
            $auditResult = Get-TestError -LastError $_ -RecNum $RecNum
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}