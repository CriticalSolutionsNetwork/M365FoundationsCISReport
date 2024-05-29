function Test-ManagedApprovedPublicGroups {
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
        # 1.2.1 (L2) Ensure that only organizationally managed/approved public groups exist (Automated)

        # Retrieve all public groups
        $allGroups = Get-MgGroup -All | Where-Object { $_.Visibility -eq "Public" } | Select-Object DisplayName, Visibility

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($null -ne $allGroups -and $allGroups.Count -gt 0) {
            "There are public groups present that are not organizationally managed/approved."
        }
        else {
            "N/A"
        }

        $details = if ($null -eq $allGroups -or $allGroups.Count -eq 0) {
            "No public groups found."
        }
        else {
            $groupDetails = $allGroups | ForEach-Object { $_.DisplayName + " (" + $_.Visibility + ")" }
            "Public groups found: $($groupDetails -join ', ')"
        }

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "1.2.1"
            Result         = $null -eq $allGroups -or $allGroups.Count -eq 0
            Status         = if ($null -eq $allGroups -or $allGroups.Count -eq 0) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return auditResults
        return $auditResult
    }
}
