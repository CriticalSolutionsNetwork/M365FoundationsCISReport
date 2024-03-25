function Test-RestrictStorageProvidersOutlook {
    [CmdletBinding()]
    param (
        # Parameters can be added here if needed
    )

    begin {
        # Dot source the class script

        $auditResult = [CISAuditResult]::new()
    }

    process {
        # 6.5.3 (L2) Ensure additional storage providers are restricted in Outlook on the web
        $owaPolicies = Get-OwaMailboxPolicy
        $allPoliciesRestricted = $owaPolicies | ForEach-Object { $_.AdditionalStorageProvidersAvailable } | ForEach-Object { -not $_ }

        # Create an instance of CISAuditResult and populate it
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"
        $auditResult.Rec = "6.5.3"
        $auditResult.ELevel = "E3" # Based on your environment
        $auditResult.ProfileLevel = "L2"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Ensure additional storage providers are restricted in Outlook on the web"
        $auditResult.Result = $allPoliciesRestricted
        $auditResult.Details = if($allPoliciesRestricted) {
            "All OwaMailbox policies restrict AdditionalStorageProvidersAvailable"
        } else {
            $nonCompliantPolicies = $owaPolicies | Where-Object { $_.AdditionalStorageProvidersAvailable } | Select-Object -ExpandProperty Name
            "Non-compliant OwaMailbox policies: $($nonCompliantPolicies -join ', ')"
        }
        $auditResult.FailureReason = if(-not $allPoliciesRestricted) { "One or more OwaMailbox policies allow AdditionalStorageProvidersAvailable." } else { "N/A" }
        $auditResult.Status = if($allPoliciesRestricted) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}


# Additional helper functions (if any)

