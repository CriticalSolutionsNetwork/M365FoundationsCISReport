function Test-SharePointExternalSharingDomains {
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
        # 7.2.6 (L2) Ensure SharePoint external sharing is managed through domain whitelist/blacklists
        $SPOTenant = Get-SPOTenant | Select-Object SharingDomainRestrictionMode, SharingAllowedDomainList
        $isDomainRestrictionConfigured = $SPOTenant.SharingDomainRestrictionMode -eq 'AllowList'

        # Populate the auditResult object with the required properties
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"
        $auditResult.Rec = "7.2.6"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L2"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.RecDescription = "Ensure SharePoint external sharing is managed through domain whitelist/blacklists"
        $auditResult.Result = $isDomainRestrictionConfigured
        $auditResult.Details = "SharingDomainRestrictionMode: $($SPOTenant.SharingDomainRestrictionMode); SharingAllowedDomainList: $($SPOTenant.SharingAllowedDomainList)"
        $auditResult.FailureReason = if (-not $isDomainRestrictionConfigured) { "Domain restrictions for SharePoint external sharing are not configured to 'AllowList'. Current setting: $($SPOTenant.SharingDomainRestrictionMode)" } else { "N/A" }
        $auditResult.Status = if ($isDomainRestrictionConfigured) { "Pass" } else { "Fail" }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
