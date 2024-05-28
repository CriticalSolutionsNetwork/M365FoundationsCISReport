function Test-RestrictOutlookAddins {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters could include credentials or other necessary data
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code
        $customPolicyFailures = @()
        $defaultPolicyFailureDetails = @()
        $relevantRoles = @('My Custom Apps', 'My Marketplace Apps', 'My ReadWriteMailbox Apps')
    }

    process {
        # 6.3.1 (L2) Ensure users installing Outlook add-ins is not allowed

        # Check all mailboxes for custom policies with unallowed add-ins
        $roleAssignmentPolicies = Get-EXOMailbox | Select-Object -Unique RoleAssignmentPolicy

        if ($roleAssignmentPolicies.RoleAssignmentPolicy) {
            foreach ($policy in $roleAssignmentPolicies) {
                if ($policy.RoleAssignmentPolicy) {
                    $rolePolicyDetails = Get-RoleAssignmentPolicy -Identity $policy.RoleAssignmentPolicy
                    $foundRoles = $rolePolicyDetails.AssignedRoles | Where-Object { $_ -in $relevantRoles }
                    if ($foundRoles) {
                        $customPolicyFailures += "Policy: $($policy.RoleAssignmentPolicy): Roles: $($foundRoles -join ', ')"
                    }
                }
            }
        }

        # Check Default Role Assignment Policy
        $defaultPolicy = Get-RoleAssignmentPolicy "Default Role Assignment Policy"
        $defaultPolicyRoles = $defaultPolicy.AssignedRoles | Where-Object { $_ -in $relevantRoles }
        if ($defaultPolicyRoles) {
            $defaultPolicyFailureDetails = $defaultPolicyRoles
        }

        # Prepare result details string
        $detailsString = ""
        if ($customPolicyFailures) {
            $detailsString += "Custom Policy Failures: | "
            $detailsString += ($customPolicyFailures -join " | ")
        }
        else {
            $detailsString += "Custom Policy Failures: None | "
        }

        $detailsString += "Default Role Assignment Policy: "
        if ($defaultPolicyFailureDetails) {
            $detailsString += ($defaultPolicyFailureDetails -join ', ')
        }
        else {
            $detailsString += "Compliant"
        }

        # Determine result based on findings
        $isCompliant = -not ($customPolicyFailures -or $defaultPolicyFailureDetails)

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($isCompliant) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L2"
        $auditResult.Rec = "6.3.1"
        $auditResult.RecDescription = "Ensure users installing Outlook add-ins is not allowed"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "9.4"
        $auditResult.CISDescription = "Restrict Unnecessary or Unauthorized Browser and Email Client Extensions"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $isCompliant
        $auditResult.Details = $detailsString
        $auditResult.FailureReason = if ($isCompliant) { "N/A" } else { "Unauthorized Outlook add-ins found in custom or default policies." }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}