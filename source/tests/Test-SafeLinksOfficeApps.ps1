function Test-SafeLinksOfficeApps {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 2.1.1 (L2) Ensure Safe Links for Office Applications is Enabled

        # Retrieve all Safe Links policies
        $policies = Get-SafeLinksPolicy

        # Initialize the details collection
        $misconfiguredDetails = @()

        foreach ($policy in $policies) {
            # Get the detailed configuration of each policy
            $policyDetails = Get-SafeLinksPolicy -Identity $policy.Name

            # Check each required property and record failures
            $failures = @()
            if ($policyDetails.EnableSafeLinksForEmail -ne $true) { $failures += "EnableSafeLinksForEmail: False" }
            if ($policyDetails.EnableSafeLinksForTeams -ne $true) { $failures += "EnableSafeLinksForTeams: False" }
            if ($policyDetails.EnableSafeLinksForOffice -ne $true) { $failures += "EnableSafeLinksForOffice: False" }
            if ($policyDetails.TrackClicks -ne $true) { $failures += "TrackClicks: False" }
            if ($policyDetails.AllowClickThrough -ne $false) { $failures += "AllowClickThrough: True" }
            if ($policyDetails.ScanUrls -ne $true) { $failures += "ScanUrls: False" }
            if ($policyDetails.EnableForInternalSenders -ne $true) { $failures += "EnableForInternalSenders: False" }
            if ($policyDetails.DeliverMessageAfterScan -ne $true) { $failures += "DeliverMessageAfterScan: False" }
            if ($policyDetails.DisableUrlRewrite -ne $false) { $failures += "DisableUrlRewrite: True" }

            # Only add details for policies that have misconfigurations
            if ($failures.Count -gt 0) {
                $misconfiguredDetails += "Policy: $($policy.Name); Failures: $($failures -join ', ')"
            }
        }

        # Prepare the final result
        $result = $misconfiguredDetails.Count -eq 0
        $details = if ($result) { "All Safe Links policies are correctly configured." } else { $misconfiguredDetails -join ' | ' }
        $failureReasons = if ($result) { "N/A" } else { "The following Safe Links policies settings do not meet the recommended configuration: $($misconfiguredDetails -join ' | ')" }

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "2.1.1"
            Result         = $result
            Status         = if ($result) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure Safe Links for Office Applications is Enabled"
            CISControl     = "10.1"
            CISDescription = "Deploy and Maintain Anti-Malware Software"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
