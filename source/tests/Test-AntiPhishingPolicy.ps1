function Test-AntiPhishingPolicy {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {

        # Retrieve and validate the anti-phishing policies
        $antiPhishPolicies = Get-AntiPhishPolicy
        $validatedPolicies = $antiPhishPolicies | Where-Object {
            $_.Enabled -eq $true -and
            $_.PhishThresholdLevel -ge 2 -and
            $_.EnableMailboxIntelligenceProtection -eq $true -and
            $_.EnableMailboxIntelligence -eq $true -and
            $_.EnableSpoofIntelligence -eq $true
        }

        # Check if there is at least one policy that meets the requirements
        $isCompliant = $validatedPolicies.Count -gt 0

        # Prepare failure details if policies are not compliant
        $failureDetails = if (-not $isCompliant) {
            "No anti-phishing policy is fully compliant with CIS benchmark requirements."
        } else {
            "Compliant Anti-Phish Policy Names: " + ($validatedPolicies.Name -join ', ')
        }

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($isCompliant) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E5"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "2.1.7"
        $auditResult.RecDescription = "Ensure that an anti-phishing policy has been created"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "9.7"
        $auditResult.CISDescription = "Deploy and Maintain Email Server Anti-Malware Protections"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $true
        $auditResult.Result = $isCompliant
        $auditResult.Details = $failureDetails
        $auditResult.FailureReason = if (-not $isCompliant) { "Anti-phishing policies do not meet CIS benchmark requirements." } else { "N/A" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
