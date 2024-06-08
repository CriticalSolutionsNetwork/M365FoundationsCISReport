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
        $recnum = "7.2.7"
    }

    process {
        try {
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
            $params = @{
                Rec           = $recnum
                Result        = $isLinkSharingRestricted
                Status        = if ($isLinkSharingRestricted) { "Pass" } else { "Fail" }
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
        # Return the audit result
        return $auditResult
    }
}
