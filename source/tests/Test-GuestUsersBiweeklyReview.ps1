function Test-GuestUsersBiweeklyReview {
    [CmdletBinding()]
    param ()

    begin {
        #. .\source\Classes\CISAuditResult.ps1
        $auditResults = @()
    }

    process {
        # 1.1.4 (L1) Ensure Guest Users are reviewed at least biweekly
        # The function will fail if guest users are found since they should be reviewed manually biweekly.

        try {
            # Connect to Microsoft Graph - placeholder for connection command
            # Connect-MgGraph -Scopes "User.Read.All"
            $guestUsers = Get-MgUser -All -Filter "UserType eq 'Guest'"

            # Create an instance of CISAuditResult and populate it
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

            if ($guestUsers) {
                $auditCommand = "Get-MgUser -All -Property UserType,UserPrincipalName | Where {`$_.UserType -ne 'Member'} | Format-Table UserPrincipalName, UserType"
                $auditResult.Status = "Fail"
                $auditResult.Result = $false
                $auditResult.Details = "Manual review required. To list guest users, run: `"$auditCommand`"."
                $auditResult.FailureReason = "Guest users present: $($guestUsers.Count)"
            } else {
                $auditResult.Status = "Pass"
                $auditResult.Result = $true
                $auditResult.Details = "No guest users found."
                $auditResult.FailureReason = "N/A"
            }
        }
        catch {
            $auditResult.Status = "Error"
            $auditResult.Result = $false
            $auditResult.Details = "Error while attempting to check guest users. Error message: $($_.Exception.Message)"
            $auditResult.FailureReason = "An error occurred during the audit check."
        }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}


