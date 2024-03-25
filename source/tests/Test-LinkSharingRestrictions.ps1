function Test-LinkSharingRestrictions {
    [CmdletBinding()]
    param (
        # Define your parameters here
        # Test behavior in prod
    )

    begin {
        # Initialization code

        $auditResult = [CISAuditResult]::new()
    }

    process {
        # 7.2.7 (L1) Ensure link sharing is restricted in SharePoint and OneDrive
        $SPOTenantLinkSharing = Get-SPOTenant | Select-Object DefaultSharingLinkType
        $isLinkSharingRestricted = $SPOTenantLinkSharing.DefaultSharingLinkType -eq 'Direct' # Or 'SpecificPeople' as per the recommendation

        # Populate the auditResult object with the required properties
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"

        $auditResult.Rec = "7.2.7"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Ensure link sharing is restricted in SharePoint and OneDrive"

        $auditResult.Result = $isLinkSharingRestricted
        $auditResult.Details = "DefaultSharingLinkType: $($SPOTenantLinkSharing.DefaultSharingLinkType)"
        $auditResult.FailureReason = if (-not $isLinkSharingRestricted) { "Link sharing is not restricted to 'Specific people'. Current setting: $($SPOTenantLinkSharing.DefaultSharingLinkType)" } else { "N/A" }
        $auditResult.Status = if ($isLinkSharingRestricted) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
