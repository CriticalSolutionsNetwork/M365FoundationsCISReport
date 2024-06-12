function Test-RestrictTenantCreation {
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
        $recnum = "5.1.2.3"

        <#
        Conditions for 5.1.2.3 (L1) Ensure 'Restrict non-admin users from creating tenants' is set to 'Yes'

        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
          - Condition A: Restrict non-admin users from creating tenants is set to 'Yes' in the Azure AD and Entra administration portal.
          - Condition B: Using PowerShell, the setting for restricting non-admin users from creating tenants is set to 'Yes'.

        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
          - Condition A: Restrict non-admin users from creating tenants is not set to 'Yes' in the Azure AD and Entra administration portal.
          - Condition B: Using PowerShell, the setting for restricting non-admin users from creating tenants is not set to 'Yes'.
        #>
    }

    process {
        try {
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
                Rec           = $recnum
                Result        = $tenantCreationResult
                Status        = if ($tenantCreationResult) { "Pass" } else { "Fail" }
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
