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
                Rec            = "6.5.1"
                Result         = $orgConfig.OAuth2ClientProfileEnabled
                Status         = if ($orgConfig.OAuth2ClientProfileEnabled) { "Pass" } else { "Fail" }
                Details        = $details
                FailureReason  = $failureReasons
                RecDescription = "Ensure modern authentication for Exchange Online is enabled (Automated)"
                CISControl     = "3.10"
                CISDescription = "Encrypt Sensitive Data in Transit"
            }
            $auditResult = Initialize-CISAuditResult @params

        }
        catch {
            Write-Error "An error occurred while testing modern authentication for Exchange Online: $_"
        }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
