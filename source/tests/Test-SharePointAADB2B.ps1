function Test-SharePointAADB2B {
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
        $recnum = "7.2.2"
    }

    process {
        try {
            # 7.2.2 (L1) Ensure SharePoint and OneDrive integration with Azure AD B2B is enabled
            $SPOTenantAzureADB2B = Get-SPOTenant | Select-Object EnableAzureADB2BIntegration

            # Populate the auditResult object with the required properties
            $params = @{
                Rec           = $recnum
                Result        = $SPOTenantAzureADB2B.EnableAzureADB2BIntegration
                Status        = if ($SPOTenantAzureADB2B.EnableAzureADB2BIntegration) { "Pass" } else { "Fail" }
                Details       = "EnableAzureADB2BIntegration: $($SPOTenantAzureADB2B.EnableAzureADB2BIntegration)"
                FailureReason = if (-not $SPOTenantAzureADB2B.EnableAzureADB2BIntegration) { "Azure AD B2B integration is not enabled" } else { "N/A" }
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
