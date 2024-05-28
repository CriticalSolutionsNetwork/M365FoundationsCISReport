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
        $params = @{
            Rec            = "6.5.3"
            Result         = $allPoliciesRestricted
            Status         = if ($allPoliciesRestricted) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure additional storage providers are restricted in Outlook on the web"
            CISControl     = "3.3"
            CISDescription = "Configure Data Access Control Lists"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}

# Additional helper functions (if any)
