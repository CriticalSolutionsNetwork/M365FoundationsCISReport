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
        $recnum = "2.1.7"
    }

    process {

        try {
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
        # Return auditResult
        return $auditResult
    }
}
