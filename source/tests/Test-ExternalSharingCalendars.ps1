function Test-ExternalSharingCalendars {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "1.3.3"
        Write-Verbose "Running Test-ExternalSharingCalendars for $recnum..."
        # Conditions for 1.3.3 (L2) Ensure 'External sharing' of calendars is not available (Automated)
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: In the Microsoft 365 admin center, external calendar sharing is disabled.
        #   - Condition B: Using the Exchange Online PowerShell Module, the `OrganizationConfig` property `ExternalSharingEnabled` is set to `False`.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: In the Microsoft 365 admin center, external calendar sharing is enabled.
        #   - Condition B: Using the Exchange Online PowerShell Module, the `OrganizationConfig` property `ExternalSharingEnabled` is set to `True`.
    }

    process {
        try {
            # Step: Retrieve sharing policies related to calendar sharing
            # $sharingPolicies Mock Object
            <#
                $sharingPolicies = [PSCustomObject]@{
                    Name = "Default Sharing Policy"
                    Domains = @("Anonymous:CalendarSharingFreeBusySimple")
                    Enabled = $true
                    Default = $true
                }
            #>
            $sharingPolicies = Get-CISExoOutput -Rec $recnum
            # Step (Condition A & B: Pass/Fail): Check if calendar sharing is disabled in all applicable policies
            $isExternalSharingDisabled = $true
            $sharingPolicyDetails = @()
            foreach ($policy in $sharingPolicies) {
                if ($policy.Enabled -eq $true) {
                    $isExternalSharingDisabled = $false
                    $sharingPolicyDetails += "$($policy.Name): Enabled"
                }
            }
            # Retrieve calendars with publishing enabled (from 1.3.3b)
            # $calendarDetails Mock Object
            <#
                $calendarDetails = @(
                    [PSCustomObject]@{
                        Calendar = "SMBuser1@domain.com"
                        URL = "https://example.com/calendar/smbuser1"
                    },
                    [PSCustomObject]@{
                        Calendar = "SMBuser2@domain.com"
                        URL = "https://example.com/calendar/smbuser2"
                    },
                    [PSCustomObject]@{
                        Calendar = "SMBuser4@domain.com"
                        URL = "https://example.com/calendar/smbuser3"
                    }
                )
            #>
            $calendarDetails = Get-CISExoOutput -Rec "$("$recnum" + "b")"
            # Build the failure reason string
            $failureReasons = if (-not $isExternalSharingDisabled) {
                $baseMessage = "Calendar sharing with external users is enabled in one or more policies."
                if ($calendarDetails.Count -gt 0) {
                    $baseMessage += "`nPrior to remediating, check the following mailboxes that have calendar publishing enabled: `n$($calendarDetails -join '`n')"
                }
                $baseMessage
            }
            else {
                "N/A"
            }
            # Step: Prepare details for the audit result (Condition A & B: Pass/Fail)
            $details = if ($isExternalSharingDisabled) {
                "Calendar sharing with external users is disabled."
            }
            else {
                "Enabled Sharing Policies:`n$($sharingPolicyDetails -join ', ')"
            }

            # Step: Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $isExternalSharingDisabled
                Status        = if ($isExternalSharingDisabled) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
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
