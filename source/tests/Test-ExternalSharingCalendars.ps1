function Test-ExternalSharingCalendars {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
    }

    process {
        # 1.3.3 (L2) Ensure 'External sharing' of calendars is not available (Automated)

        # Retrieve sharing policies related to calendar sharing
        $sharingPolicies = Get-SharingPolicy | Where-Object { $_.Domains -like '*CalendarSharing*' }

        # Check if calendar sharing is disabled in all applicable policies
        $isExternalSharingDisabled = $true
        $sharingPolicyDetails = @()
        foreach ($policy in $sharingPolicies) {
            if ($policy.Enabled -eq $true) {
                $isExternalSharingDisabled = $false
                $sharingPolicyDetails += "$($policy.Name): Enabled"
            }
        }

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $isExternalSharingDisabled) {
            "Calendar sharing with external users is enabled in one or more policies."
        }
        else {
            "N/A"
        }

        $details = if ($isExternalSharingDisabled) {
            "Calendar sharing with external users is disabled."
        }
        else {
            "Enabled Sharing Policies: $($sharingPolicyDetails -join ', ')"
        }

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "1.3.3"
            Result         = $isExternalSharingDisabled
            Status         = if ($isExternalSharingDisabled) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
