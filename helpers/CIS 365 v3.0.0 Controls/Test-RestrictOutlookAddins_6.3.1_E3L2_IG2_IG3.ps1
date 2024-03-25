function Test-RestrictOutlookAddins_6.3.1_E3L2_IG2_IG3 {
    [CmdletBinding()]
    param (
        # Parameters could include credentials or other necessary data
    )

    begin {
        # Initialization code
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResult = [CISAuditResult]::new()
        $customPolicyFailures = @()
        $defaultPolicyFailureDetails = @()
        $relevantRoles = @('My Custom Apps', 'My Marketplace Apps', 'My ReadWriteMailbox Apps')
    }

    process {
        # Main functionality
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
    }

    end {
        # Prepare result object
        $auditResult.Rec = "6.3.1"
        $auditResult.CISControl = "9.4"
        $auditResult.CISDescription = "Restrict Unnecessary or Unauthorized Browser and Email Client Extensions"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L2"
        $auditResult.IG1 = $false
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Ensure users installing Outlook add-ins is not allowed"

        $detailsString = ""
        if ($customPolicyFailures) {
            $detailsString += "Custom Policy Failures: `n"
            foreach ($failure in $customPolicyFailures) {
                $detailsString += "`t$failure`n"
            }
        }
        else {
            $detailsString += "Custom Policy Failures: None`n"
        }

        $detailsString += "Default Role Assignment Policy: "
        if ($defaultPolicyFailureDetails) {
            $detailsString += "$($defaultPolicyFailureDetails -join ', ')"
        }
        else {
            $detailsString += "Compliant"
        }

        if ($customPolicyFailures -or $defaultPolicyFailureDetails) {
            $auditResult.Result = $false
            $auditResult.Status = "Fail"
            $auditResult.Details = $detailsString
            $auditResult.FailureReason = "Unauthorized Outlook add-ins found in custom or default policies."
        }
        else {
            $auditResult.Result = $true
            $auditResult.Status = "Pass"
            $auditResult.Details = "No unauthorized Outlook add-ins found in custom or default policies."
            $auditResult.FailureReason = "N/A"
        }

        # Return auditResult
        return $auditResult
    }
}