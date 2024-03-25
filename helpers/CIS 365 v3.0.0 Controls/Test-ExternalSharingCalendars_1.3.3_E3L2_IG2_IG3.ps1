function Test-ExternalSharingCalendars_1.3.3_E3L2_IG2_IG3 {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResults = @()
    }

    process {
        # 1.3.3 (L2) Ensure 'External sharing' of calendars is not available (Automated)
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

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.Rec = "1.3.3"
        $auditResult.RecDescription = "Ensure 'External sharing' of calendars is not available"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L2"
        # The following IG values are placeholders. Replace with actual values when known.
        $auditResult.IG1 = $false
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.CISControlVer = "v8"
        # Placeholder for CIS Control, to be replaced with the actual value when available
        $auditResult.CISControl = "4.8"
        $auditResult.CISDescription = "Uninstall or Disable Unnecessary Services on Enterprise Assets and Software"
        $auditResult.Result = $isExternalSharingDisabled
        $auditResult.Details = if ($isExternalSharingDisabled) { "Calendar sharing with external users is disabled." } else { "Enabled Sharing Policies: $($sharingPolicyDetails -join ', ')" }
        $auditResult.FailureReason = if ($isExternalSharingDisabled) { "N/A" } else { "Calendar sharing with external users is enabled in one or more policies." }
        $auditResult.Status = if ($isExternalSharingDisabled) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
