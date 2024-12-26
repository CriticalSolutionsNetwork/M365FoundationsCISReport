function Test-LinkSharingRestrictions {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here
        # Test behavior in prod
    )
    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $RecNum = "7.2.7"
        Write-Verbose "Running Test-LinkSharingRestrictions for $RecNum..."
    }
    process {
        try {
            # 7.2.7 (L1) Ensure link sharing is restricted in SharePoint and OneDrive
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: The `DefaultSharingLinkType` setting in SharePoint and OneDrive is set to `Direct`.
            #   - Condition B: The setting `Choose the type of link that's selected by default when users share files and folders in SharePoint and OneDrive` is set to `Specific people (only the people the user specifies)`.
            #   - Condition C: Verification using the UI confirms that the link sharing settings are configured as recommended.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: The `DefaultSharingLinkType` setting in SharePoint and OneDrive is not set to `Direct`.
            #   - Condition B: The setting `Choose the type of link that's selected by default when users share files and folders in SharePoint and OneDrive` is not set to `Specific people (only the people the user specifies)`.
            #   - Condition C: Verification using the UI indicates that the link sharing settings are not configured as recommended.
            # Retrieve link sharing configuration for SharePoint and OneDrive
            # $SPOTenantLinkSharing Mock Object
            <#
                $$SPOTenantLinkSharing = [PSCustomObject]@{
                    DefaultSharingLinkType           = "Direct"
                }
            #>
            $SPOTenantLinkSharing = Get-CISSpoOutput -Rec $RecNum
            $isLinkSharingRestricted = $SPOTenantLinkSharing.DefaultSharingLinkType -eq 'Direct'  # Or 'SpecificPeople' as per the recommendation
            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $isLinkSharingRestricted) {
                "Link sharing is not restricted to 'Specific people'. Current setting: $($SPOTenantLinkSharing.DefaultSharingLinkType). To remediate this setting, use the Set-SPOTenant command:`n`n" + `
                "Set-SPOTenant -DefaultSharingLinkType Direct"
            }
            else {
                "N/A"
            }
            $details = "DefaultSharingLinkType: $($SPOTenantLinkSharing.DefaultSharingLinkType)"
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $RecNum
                Result        = $isLinkSharingRestricted
                Status        = if ($isLinkSharingRestricted) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -RecNum $RecNum
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}
