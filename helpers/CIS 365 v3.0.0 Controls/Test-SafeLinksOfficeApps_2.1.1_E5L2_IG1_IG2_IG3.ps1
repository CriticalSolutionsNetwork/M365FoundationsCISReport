function Test-SafeLinksOfficeApps_2.1.1_E5L2_IG1_IG2_IG3 {
    [CmdletBinding()]
    param (
        # Define your parameters here if needed
    )

    begin {
        # Initialization code
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResults = @()
    }

    process {
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

        # Create the audit result object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($result) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E5"
        $auditResult.Profile = "L2"
        $auditResult.Rec = "2.1.1"
        $auditResult.RecDescription = "Ensure Safe Links for Office Applications is Enabled"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "10.1"
        $auditResult.CISDescription = "Deploy and Maintain Anti-Malware Software"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $result
        $auditResult.Details = $details
        $auditResult.FailureReason = if ($result) { "N/A" } else { "The following Safe Links policies settings do not meet the recommended configuration: $($misconfiguredDetails -join ' | ')" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
