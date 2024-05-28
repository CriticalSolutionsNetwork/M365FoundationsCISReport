function Test-SharePointGuestsItemSharing {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed

        $auditResult = [CISAuditResult]::new()
    }

    process {
        # 7.2.5 (L2) Ensure that SharePoint guest users cannot share items they don't own
        $SPOTenant = Get-SPOTenant | Select-Object PreventExternalUsersFromResharing
        $isGuestResharingPrevented = $SPOTenant.PreventExternalUsersFromResharing

        # Populate the auditResult object with the required properties
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"
        $auditResult.Rec = "7.2.5"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L2"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Ensure that SharePoint guest users cannot share items they don't own"
        $auditResult.Result = $isGuestResharingPrevented
        $auditResult.Details = "PreventExternalUsersFromResharing: $isGuestResharingPrevented"
        $auditResult.FailureReason = if (-not $isGuestResharingPrevented) { "Guest users can reshare items they don't own." } else { "N/A" }
        $auditResult.Status = if ($isGuestResharingPrevented) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
