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
            $auditResult = [CISAuditResult]::new()
            $auditResult.CISControlVer = "v8"
            $auditResult.CISControl = "3.10"
            $auditResult.CISDescription = "Encrypt Sensitive Data in Transit"
            $auditResult.IG1 = $false # As per CIS Control v8 mapping for IG1
            $auditResult.IG2 = $true # As per CIS Control v8 mapping for IG2
            $auditResult.IG3 = $true # As per CIS Control v8 mapping for IG3
            $auditResult.ELevel = "E3" # Based on your environment (E3, E5, etc.)
            $auditResult.ProfileLevel = "L1"
            $auditResult.Rec = "6.5.1"
            $auditResult.RecDescription = "Ensure modern authentication for Exchange Online is enabled (Automated)"
            $auditResult.Result = $orgConfig.OAuth2ClientProfileEnabled
            $auditResult.Details = $details
            $auditResult.FailureReason = $failureReasons
            $auditResult.Status = if ($orgConfig.OAuth2ClientProfileEnabled) { "Pass" } else { "Fail" }

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
