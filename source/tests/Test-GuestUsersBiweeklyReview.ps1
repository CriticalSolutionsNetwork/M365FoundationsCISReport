function Test-GuestUsersBiweeklyReview {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        . .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
    }

    process {
        # 1.1.4 (L1) Ensure Guest Users are reviewed at least biweekly

        try {
            # Retrieve guest users from Microsoft Graph
            # Connect-MgGraph -Scopes "User.Read.All"
            $guestUsers = Get-MgUser -All -Filter "UserType eq 'Guest'"

            # Prepare failure reasons and details based on compliance
            $failureReasons = if ($guestUsers) {
                "Guest users present: $($guestUsers.Count)"
            }
            else {
                "N/A"
            }

            $details = if ($guestUsers) {
                $auditCommand = "Get-MgUser -All -Property UserType,UserPrincipalName | Where {`$_.UserType -ne 'Member'} | Format-Table UserPrincipalName, UserType"
                "Manual review required. To list guest users, run: `"$auditCommand`"."
            }
            else {
                "No guest users found."
            }

            # Create and populate the CISAuditResult object
            $auditResult = [CISAuditResult]::new()
            $auditResult.CISControl = "5.1, 5.3"
            $auditResult.CISDescription = "Establish and Maintain an Inventory of Accounts, Disable Dormant Accounts"
            $auditResult.Rec = "1.1.4"
            $auditResult.RecDescription = "Ensure Guest Users are reviewed at least biweekly"
            $auditResult.ELevel = "E3"
            $auditResult.ProfileLevel = "L1"
            $auditResult.IG1 = $true
            $auditResult.IG2 = $true
            $auditResult.IG3 = $true
            $auditResult.CISControlVer = 'v8'
            $auditResult.Result = -not $guestUsers
            $auditResult.Details = $details
            $auditResult.FailureReason = $failureReasons
            $auditResult.Status = if ($guestUsers) { "Fail" } else { "Pass" }
        }
        catch {
            $auditResult = [CISAuditResult]::new()
            $auditResult.Status = "Error"
            $auditResult.Result = $false
            $auditResult.Details = "Error while attempting to check guest users. Error message: $($_.Exception.Message)"
            $auditResult.FailureReason = "An error occurred during the audit check."
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
