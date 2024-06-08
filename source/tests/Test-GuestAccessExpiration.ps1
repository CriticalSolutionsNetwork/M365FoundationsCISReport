function Test-GuestAccessExpiration {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "7.2.9"
    }

    process {

        try {
        # 7.2.9 (L1) Ensure guest access to a site or OneDrive will expire automatically

        # Retrieve SharePoint tenant settings related to guest access expiration
        $SPOTenantGuestAccess = Get-SPOTenant | Select-Object ExternalUserExpirationRequired, ExternalUserExpireInDays
        $isGuestAccessExpirationConfiguredCorrectly = $SPOTenantGuestAccess.ExternalUserExpirationRequired -and $SPOTenantGuestAccess.ExternalUserExpireInDays -le 30

        # Prepare failure reasons and details based on compliance
        $failureReasons = if (-not $isGuestAccessExpirationConfiguredCorrectly) {
            "Guest access expiration is not configured to automatically expire within 30 days or less."
        }
        else {
            "N/A"
        }

        $details = "ExternalUserExpirationRequired: $($SPOTenantGuestAccess.ExternalUserExpirationRequired); ExternalUserExpireInDays: $($SPOTenantGuestAccess.ExternalUserExpireInDays)"

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = $recnum
            Result         = $isGuestAccessExpirationConfiguredCorrectly
            Status         = if ($isGuestAccessExpirationConfiguredCorrectly) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
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
