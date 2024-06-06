function Test-SharePointExternalSharingDomains {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed

        $auditResult = [CISAuditResult]::new()
        $recnum = "7.2.6"
    }

    process {
        try {
            # 7.2.6 (L2) Ensure SharePoint external sharing is managed through domain whitelist/blacklists
            $SPOTenant = Get-SPOTenant | Select-Object SharingDomainRestrictionMode, SharingAllowedDomainList
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
