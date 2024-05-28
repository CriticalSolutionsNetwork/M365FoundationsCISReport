function Test-LinkSharingRestrictions {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here
        # Test behavior in prod
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 7.2.7 (L1) Ensure link sharing is restricted in SharePoint and OneDrive

        # Retrieve link sharing configuration for SharePoint and OneDrive
        $SPOTenantLinkSharing = Get-SPOTenant | Select-Object DefaultSharingLinkType
        $isLinkSharingRestricted = $SPOTenantLinkSharing.DefaultSharingLinkType -eq 'Direct'  # Or 'SpecificPeople' as per the recommendation

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $isLinkSharingRestricted) {
            "Link sharing is not restricted to 'Specific people'. Current setting: $($SPOTenantLinkSharing.DefaultSharingLinkType)"
        }
        else {
            "N/A"
        }

        $details = "DefaultSharingLinkType: $($SPOTenantLinkSharing.DefaultSharingLinkType)"

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($isLinkSharingRestricted) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "7.2.7"
        $auditResult.RecDescription = "Ensure link sharing is restricted in SharePoint and OneDrive"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "3.3"
        $auditResult.CISDescription = "Configure Data Access Control Lists"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $isLinkSharingRestricted
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}