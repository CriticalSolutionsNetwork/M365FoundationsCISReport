function Test-OneDriveContentRestrictions {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here
    )
    begin {
        # 7.2.4 (L2) Ensure OneDrive content sharing is restricted
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: The OneDriveSharingCapability setting is configured to "Disabled" using the PowerShell cmdlet `Get-SPOTenant | fl OneDriveSharingCapability`.
        #   - Condition B: The OneDriveSharingCapability is set to "Only people in your organization" in the SharePoint admin center under Policies > Sharing > OneDrive.
        #   - Condition C: OneDrive content sharing is not more permissive than SharePoint content sharing.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: The OneDriveSharingCapability setting is not configured to "Disabled" using the PowerShell cmdlet `Get-SPOTenant | fl OneDriveSharingCapability`.
        #   - Condition B: The OneDriveSharingCapability is not set to "Only people in your organization" in the SharePoint admin center under Policies > Sharing > OneDrive.
        #   - Condition C: OneDrive content sharing is more permissive than SharePoint content sharing.
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $RecNum = "7.2.4"
        Write-Verbose "Running Test-OneDriveContentRestrictions for $RecNum..."
    }
    process {
        try {
            # 7.2.4 (L2) Ensure OneDrive content sharing is restricted
            # Retrieve OneDrive sharing capability settings
            # $SPOTenant Mock Object
            <#
                $SPOTenant = [PSCustomObject]@{
                    OneDriveSharingCapability           = "ExternalUserAndGuestSharing"
                }
            #>
            $SPOTenant = Get-CISSpoOutput -Rec $RecNum
            $isOneDriveSharingRestricted = $SPOTenant.OneDriveSharingCapability -eq 'Disabled'
            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $isOneDriveSharingRestricted) {
                "OneDrive content sharing is not restricted to 'Disabled'. To remediate this setting, use the Set-SPOTenant command.`n`n" + `
                "Set-SPOTenant -OneDriveSharingCapability Disabled"
            }
            else {
                "N/A"
            }
            $details = if ($isOneDriveSharingRestricted) {
                "OneDrive content sharing is restricted."
            }
            else {
                "OneDriveSharingCapability: $($SPOTenant.OneDriveSharingCapability)"
            }
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $RecNum
                Result        = $isOneDriveSharingRestricted
                Status        = if ($isOneDriveSharingRestricted) { "Pass" } else { "Fail" }
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
        # Return auditResult
        return $auditResult
    }
}
