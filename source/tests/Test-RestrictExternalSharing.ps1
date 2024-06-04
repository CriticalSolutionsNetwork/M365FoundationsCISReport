function Test-RestrictExternalSharing {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "7.2.3"
    }

    process {
        try {
            # 7.2.3 (L1) Ensure external content sharing is restricted

            # Retrieve the SharingCapability setting for the SharePoint tenant
            $SPOTenantSharingCapability = Get-SPOTenant | Select-Object SharingCapability
            $isRestricted = $SPOTenantSharingCapability.SharingCapability -in @('ExternalUserSharingOnly', 'ExistingExternalUserSharingOnly', 'Disabled')

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $isRestricted) {
                "External content sharing is not adequately restricted. Current setting: $($SPOTenantSharingCapability.SharingCapability)"
            }
            else {
                "N/A"
            }

            $details = "SharingCapability: $($SPOTenantSharingCapability.SharingCapability)"

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $isRestricted
                Status        = if ($isRestricted) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            Write-Error "An error occurred during the test: $_"

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
