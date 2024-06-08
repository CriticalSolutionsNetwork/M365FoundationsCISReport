function Test-ModernAuthExchangeOnline {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "6.5.1"
    }

    process {
        try {
            # Ensuring the ExchangeOnlineManagement module is available

            # 6.5.1 (L1) Ensure modern authentication for Exchange Online is enabled
            $orgConfig = Get-OrganizationConfig | Select-Object -Property Name, OAuth2ClientProfileEnabled

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $orgConfig.OAuth2ClientProfileEnabled) {
                "Modern authentication is disabled"
            }
            else {
                "N/A"
            }

            $details = "OAuth2ClientProfileEnabled: $($orgConfig.OAuth2ClientProfileEnabled) for Organization: $($orgConfig.Name)"

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $orgConfig.OAuth2ClientProfileEnabled
                Status        = if ($orgConfig.OAuth2ClientProfileEnabled) { "Pass" } else { "Fail" }
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
