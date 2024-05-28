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
        $params = @{
            Rec            = "7.2.6"
            Result         = $isDomainRestrictionConfigured
            Status         = if ($isDomainRestrictionConfigured) { "Pass" } else { "Fail" }
            Details        = "SharingDomainRestrictionMode: $($SPOTenant.SharingDomainRestrictionMode); SharingAllowedDomainList: $($SPOTenant.SharingAllowedDomainList)"
            FailureReason  = if (-not $isDomainRestrictionConfigured) { "Domain restrictions for SharePoint external sharing are not configured to 'AllowList'. Current setting: $($SPOTenant.SharingDomainRestrictionMode)" } else { "N/A" }
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
