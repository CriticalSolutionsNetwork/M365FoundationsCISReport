function Test-SharePointExternalSharingDomains {
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
        $recnum = "7.2.6"

        # Conditions for 7.2.6 (L2) Ensure SharePoint external sharing is managed through domain whitelist/blacklists
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: The "Limit external sharing by domain" option is enabled in the SharePoint admin center.
        #   - Condition B: The "SharingDomainRestrictionMode" is set to "AllowList" using PowerShell.
        #   - Condition C: The "SharingAllowedDomainList" contains the domains trusted by the organization for external sharing.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: The "Limit external sharing by domain" option is not enabled in the SharePoint admin center.
        #   - Condition B: The "SharingDomainRestrictionMode" is not set to "AllowList" using PowerShell.
        #   - Condition C: The "SharingAllowedDomainList" does not contain the domains trusted by the organization for external sharing.
    }

    process {
        try {
            # 7.2.6 (L2) Ensure SharePoint external sharing is managed through domain whitelist/blacklists
            $SPOTenant = Get-CISSpoOutput -Rec $recnum
            $isDomainRestrictionConfigured = $SPOTenant.SharingDomainRestrictionMode -eq 'AllowList'

            # Populate the auditResult object with the required properties
            $params = @{
                Rec           = $recnum
                Result        = $isDomainRestrictionConfigured
                Status        = if ($isDomainRestrictionConfigured) { "Pass" } else { "Fail" }
                Details       = "SharingDomainRestrictionMode: $($SPOTenant.SharingDomainRestrictionMode); SharingAllowedDomainList: $($SPOTenant.SharingAllowedDomainList)"
                FailureReason = if (-not $isDomainRestrictionConfigured) { "Domain restrictions for SharePoint external sharing are not configured to 'AllowList'. Current setting: $($SPOTenant.SharingDomainRestrictionMode)" } else { "N/A" }
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
