function Test-OneDriveSyncRestrictions {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here
    )
    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "7.3.2"
        Write-Verbose "Running Test-OneDriveSyncRestrictions for $recnum..."
    }
    process {
        try {
            # 7.3.2 (L2) Ensure OneDrive sync is restricted for unmanaged devices
            #
            # Validate test for a pass:
            # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
            # - Specific conditions to check:
            #   - Condition A: Verify that "Allow syncing only on computers joined to specific domains" is enabled.
            #   - Condition B: Check that "TenantRestrictionEnabled" is set to True.
            #   - Condition C: Ensure that "AllowedDomainList" contains the trusted domain GUIDs from the on-premises environment.
            #
            # Validate test for a fail:
            # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
            # - Specific conditions to check:
            #   - Condition A: "Allow syncing only on computers joined to specific domains" is not enabled.
            #   - Condition B: "TenantRestrictionEnabled" is set to False.
            #   - Condition C: "AllowedDomainList" does not contain the trusted domain GUIDs from the on-premises environment.
            # Retrieve OneDrive sync client restriction settings
            $SPOTenantSyncClientRestriction = Get-CISSpoOutput -Rec $recnum
            $isSyncRestricted = $SPOTenantSyncClientRestriction.TenantRestrictionEnabled -and $SPOTenantSyncClientRestriction.AllowedDomainList
            # Condition A: Check if TenantRestrictionEnabled is True
            # Condition B: Ensure AllowedDomainList contains trusted domains GUIDs
            $failureReasons = if (-not $isSyncRestricted) {
                "OneDrive sync is not restricted to managed devices. For hybrid devices, TenantRestrictionEnabled should be True and AllowedDomainList should contain trusted domains GUIDs.`n" + `
                "To remediate this setting, edit and use the Set-SPOTenantSyncClientRestriction command below:`n" + `
                "Set-SPOTenantSyncClientRestriction -TenantRestrictionEnabled `$true -AllowedDomainList `"<GUID1>`",`"<GUID2>`"`n`n" + `
                "Note: Utilize the -BlockMacSync:`$true parameter if you are not using conditional access to ensure Macs cannot sync."
            }
            else {
                "N/A"
            }
            # Condition C: Prepare details based on whether sync is restricted
            $details = if ($isSyncRestricted) {
                "OneDrive sync is restricted for unmanaged devices."
            }
            else {
                "TenantRestrictionEnabled: $($SPOTenantSyncClientRestriction.TenantRestrictionEnabled); AllowedDomainList: $($SPOTenantSyncClientRestriction.AllowedDomainList -join ', ')"
            }
            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $isSyncRestricted
                Status        = if ($isSyncRestricted) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }
    end {
        # Return auditResult
        return $auditResult
    }
}
