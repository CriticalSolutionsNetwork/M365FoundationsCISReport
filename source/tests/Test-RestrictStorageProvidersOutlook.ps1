function Test-RestrictStorageProvidersOutlook {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 6.5.3 (L2) Ensure additional storage providers are restricted in Outlook on the web

        # Retrieve all OwaMailbox policies
        $owaPolicies = Get-OwaMailboxPolicy
        $nonCompliantPolicies = $owaPolicies | Where-Object { $_.AdditionalStorageProvidersAvailable }

        # Determine compliance
        $allPoliciesRestricted = $nonCompliantPolicies.Count -eq 0

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($allPoliciesRestricted) {
            "N/A"
        }
        else {
            "One or more OwaMailbox policies allow AdditionalStorageProvidersAvailable."
        }

        $details = if ($allPoliciesRestricted) {
            "All OwaMailbox policies restrict AdditionalStorageProvidersAvailable"
        }
        else {
            "Non-compliant OwaMailbox policies: $($nonCompliantPolicies.Name -join ', ')"
        }

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($allPoliciesRestricted) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3" # Based on your environment
        $auditResult.ProfileLevel = "L2"
        $auditResult.Rec = "6.5.3"
        $auditResult.RecDescription = "Ensure additional storage providers are restricted in Outlook on the web"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $allPoliciesRestricted
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}

# Additional helper functions (if any)
