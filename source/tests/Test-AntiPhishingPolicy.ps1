function Test-AntiPhishingPolicy {
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
        #$auditResults = @()
        $recnum = "2.1.7"

        <#
        Conditions for 2.1.7 (L1) Ensure that an anti-phishing policy has been created

        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
          - Condition A: Verify that an anti-phishing policy exists in the Microsoft 365 Security Center.
          - Condition B: Using PowerShell, ensure the anti-phishing policy is configured with appropriate settings such as enabling impersonation protection and spoof intelligence.

        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
          - Condition A: No anti-phishing policy exists in the Microsoft 365 Security Center.
          - Condition B: Using PowerShell, the anti-phishing policy is not configured with the required settings.
        #>
    }

    process {

        try {
            # Condition A: Ensure that an anti-phishing policy has been created
            $antiPhishPolicies = Get-CISExoOutput -Rec $recnum

            # Condition B: Verify the anti-phishing policy settings using PowerShell
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
            }
            else {
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

            # Parameter splat for Initialize-CISAuditResult function
            $params = @{
                Rec           = $recnum
                Result        = $nonCompliantItems.Count -eq 0
                Status        = if ($isCompliant) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }

            # Create and populate the CISAuditResult object
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
