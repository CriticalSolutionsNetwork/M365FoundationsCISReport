function Test-GuestUsersBiweeklyReview {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
    }

    process {
        # 1.1.4 (L1) Ensure Guest Users are reviewed at least biweekly


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
        $params = @{
            Rec            = "1.1.4"
            Result         = -not $guestUsers
            Status         = if ($guestUsers) { "Fail" } else { "Pass" }
            Details        = $details
            FailureReason  = $failureReasons
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
