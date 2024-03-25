function Test-ManagedApprovedPublicGroups_1.2.1_E3L2_IG1_IG2_IG3 {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {
        # Dot source the class script
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResults = @()
    }

    process {
        # 1.2.1 (L2) Ensure that only organizationally managed/approved public groups exist (Automated)

        $allGroups = Get-MgGroup -All | Where-Object { $_.Visibility -eq "Public" } | Select-Object DisplayName, Visibility

        # Check if there are public groups and if they are organizationally managed/approved
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"
        $auditResult.Rec = "1.2.1"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L2"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true # Based on the provided CIS Control image, IG3 is not applicable
        $auditResult.RecDescription = "Ensure that only organizationally managed/approved public groups exist"

        if ($null -eq $allGroups -or $allGroups.Count -eq 0) {
            $auditResult.Result = $true
            $auditResult.Details = "No public groups found."
            $auditResult.FailureReason = "N/A"
            $auditResult.Status = "Pass"
        }
        else {
            $groupDetails = $allGroups | ForEach-Object { $_.DisplayName + " (" + $_.Visibility + ")" }
            $detailsString = $groupDetails -join ', '

            $auditResult.Result = $false
            $auditResult.Details = "Public groups found: $detailsString"
            $auditResult.FailureReason = "There are public groups present that are not organizationally managed/approved."
            $auditResult.Status = "Fail"
        }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
