function Test-RestrictTenantCreation {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 5.1.2.3 (L1) Ensure 'Restrict non-admin users from creating tenants' is set to 'Yes'

        # Retrieve the tenant creation policy
        $tenantCreationPolicy = (Get-MgPolicyAuthorizationPolicy).DefaultUserRolePermissions | Select-Object AllowedToCreateTenants
        $tenantCreationResult = -not $tenantCreationPolicy.AllowedToCreateTenants

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($tenantCreationResult) {
            "N/A"
        }
        else {
            "Non-admin users can create tenants"
        }

        $details = "AllowedToCreateTenants: $($tenantCreationPolicy.AllowedToCreateTenants)"

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "5.1.2.3"
            Result         = $tenantCreationResult
            Status         = if ($tenantCreationResult) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
            RecDescription = "Ensure 'Restrict non-admin users from creating tenants' is set to 'Yes'"
            CISControl     = "0.0"
            CISDescription = "Explicitly Not Mapped"
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}

# Additional helper functions (if any)
