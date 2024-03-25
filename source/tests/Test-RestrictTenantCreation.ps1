function Test-RestrictTenantCreation {
    [CmdletBinding()]
    param (
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 5.1.2.3 (L1) Ensure 'Restrict non-admin users from creating tenants' is set to 'Yes'
        # Pass if AllowedToCreateTenants is False. Fail otherwise.
        $tenantCreationPolicy = (Get-MgPolicyAuthorizationPolicy).DefaultUserRolePermissions | Select-Object AllowedToCreateTenants
        $tenantCreationResult = -not $tenantCreationPolicy.AllowedToCreateTenants

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($tenantCreationResult) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "5.1.2.3"
        $auditResult.RecDescription = "Ensure 'Restrict non-admin users from creating tenants' is set to 'Yes'"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0"
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $false
        $auditResult.IG3 = $false
        $auditResult.Result = $tenantCreationResult
        $auditResult.Details = "AllowedToCreateTenants: $($tenantCreationPolicy.AllowedToCreateTenants)"
        $auditResult.FailureReason = if (-not $tenantCreationResult) { "Non-admin users can create tenants" } else { "N/A" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
