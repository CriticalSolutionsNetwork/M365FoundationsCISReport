function Test-AntiPhishingPolicy {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        #$auditResults = @()
    }

    process {
        # 2.1.7 Ensure that an anti-phishing policy has been created

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
        $nonCompliantItems = $antiPhishPolicies | Where-Object {
            $_.Enabled -ne $true -or
            $_.PhishThresholdLevel -lt 2 -or
            $_.EnableMailboxIntelligenceProtection -ne $true -or
            $_.EnableMailboxIntelligence -ne $true -or
            $_.EnableSpoofIntelligence -ne $true
        }
        $compliantItems = $validatedPolicies
        $isCompliant = $compliantItems.Count -gt 0

        # Prepare failure reasons for non-compliant items
        $nonCompliantNames = $nonCompliantItems | ForEach-Object { $_.Name }
        $failureReasons = if ($nonCompliantNames.Count -gt 0) {
            "Reason: Does not meet one or more compliance criteria.`nNon-compliant Policies:`n" + ($nonCompliantNames -join "`n")
        } else {
            "N/A"
        }

        # Prepare details for non-compliant items
        $nonCompliantDetails = $nonCompliantItems | ForEach-Object {
            "Policy: $($_.Name)"
        }
        $nonCompliantDetails = $nonCompliantDetails -join "`n"

        # Prepare details based on compliance
        $details = if ($nonCompliantItems) {
            "Non-Compliant Items: $($nonCompliantItems.Count)`nDetails:`n$nonCompliantDetails"
        }
        else {
            "Compliant Items: $($compliantItems.Count)"
        }

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($isCompliant) { "Pass" } else { "Fail" }
        $auditResult.ELevel = 'E5'  # Modify as needed
        $auditResult.ProfileLevel = 'L1'  # Modify as needed
        $auditResult.Rec = '2.1.7'  # Modify as needed
        $auditResult.RecDescription = "Ensure that an anti-phishing policy has been created"  # Modify as needed
        $auditResult.CISControlVer = 'v8'  # Modify as needed
        $auditResult.CISControl = "9.7"  # Modify as needed
        $auditResult.CISDescription = "Deploy and Maintain Email Server Anti-Malware Protections"  # Modify as needed
        $auditResult.IG1 = $false  # Modify as needed
        $auditResult.IG2 = $false  # Modify as needed
        $auditResult.IG3 = $true  # Modify as needed
        $auditResult.Result = $nonCompliantItems.Count -eq 0
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons

    }

    end {
        # Return auditResults
        return $auditResult
    }
}
