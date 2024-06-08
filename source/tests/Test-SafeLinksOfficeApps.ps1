function Test-SafeLinksOfficeApps {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "2.1.1"
    }

    process {
        try {
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
                Rec           = $recnum
                Result        = $result
                Status        = if ($result) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
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
