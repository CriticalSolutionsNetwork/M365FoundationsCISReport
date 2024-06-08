function Test-OneDriveContentRestrictions {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "7.2.4"
    }

    process {
        try {
            # 7.2.4 (L2) Ensure OneDrive content sharing is restricted

            # Retrieve OneDrive sharing capability settings
            $SPOTenant = Get-SPOTenant | Select-Object OneDriveSharingCapability
            $isOneDriveSharingRestricted = $SPOTenant.OneDriveSharingCapability -eq 'Disabled'

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $isOneDriveSharingRestricted) {
                "OneDrive content sharing is not restricted to 'Disabled'. Current setting: $($SPOTenant.OneDriveSharingCapability)"
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
                Rec           = $recnum
                Result        = $isOneDriveSharingRestricted
                Status        = if ($isOneDriveSharingRestricted) { "Pass" } else { "Fail" }
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
