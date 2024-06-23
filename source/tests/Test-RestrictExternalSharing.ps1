function Test-RestrictExternalSharing {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
    <#
        Conditions for 7.2.3 (L1) Ensure external content sharing is restricted

        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
        - Condition A: The SharingCapability is set to "ExternalUserSharingOnly" or more restrictive in the SharePoint admin center.
        - Condition B: Using PowerShell, the SharingCapability property for the SharePoint tenant is set to "ExternalUserSharingOnly", "ExistingExternalUserSharingOnly", or "Disabled".
        - Condition C: The external sharing settings in SharePoint Online and OneDrive are set to the same or a more restrictive level than the organization’s sharing settings.

        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
        - Condition A: The SharingCapability is set to "Anyone" or "ExternalUserAndGuestSharing" in the SharePoint admin center.
        - Condition B: Using PowerShell, the SharingCapability property for the SharePoint tenant is set to "Anyone" or "ExternalUserAndGuestSharing".
        - Condition C: The external sharing settings in SharePoint Online and OneDrive are set to a more permissive level than the organization’s sharing settings.
    #>

        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "7.2.3"
    }

    process {
        try {
            # 7.2.3 (L1) Ensure external content sharing is restricted

            # Retrieve the SharingCapability setting for the SharePoint tenant
            $SPOTenantSharingCapability = Get-CISSpoOutput -Rec $recnum
            $isRestricted = $SPOTenantSharingCapability.SharingCapability -in @('ExternalUserSharingOnly', 'ExistingExternalUserSharingOnly', 'Disabled')

            # Prepare failure reasons and details based on compliance
            # Condition B: Using PowerShell, the SharingCapability property for the SharePoint tenant is set to "ExternalUserSharingOnly", "ExistingExternalUserSharingOnly", or "Disabled".
            $failureReasons = if (-not $isRestricted) {
                "External content sharing is not adequately restricted. Current setting: $($SPOTenantSharingCapability.SharingCapability)"
            }
            else {
                "N/A"
            }

            # Condition A: The SharingCapability is set to "ExternalUserSharingOnly" or more restrictive in the SharePoint admin center.
            # Condition C: The external sharing settings in SharePoint Online and OneDrive are set to the same or a more restrictive level than the organization’s sharing settings.
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

            # Retrieve the description from the test definitions
            $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
            $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }

            $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })

            # Call Initialize-CISAuditResult with error parameters
            $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
        }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
