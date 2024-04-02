function Test-ModernAuthExchangeOnline {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {

        $auditResults = [CISAuditResult]::new()
        # Initialization code
    }

    process {
        try {
            # Ensuring the ExchangeOnlineManagement module is available


            # 6.5.1 (L1) Ensure modern authentication for Exchange Online is enabled
            $orgConfig = Get-OrganizationConfig | Select-Object -Property Name, OAuth2ClientProfileEnabled

            # Create an instance of CISAuditResult and populate it

            $auditResults.CISControlVer = "v8"
            $auditResults.CISControl = "3.10"
            $auditResults.CISDescription = "Encrypt Sensitive Data in Transit"
            $auditResults.IG1 = $false # As per CIS Control v8 mapping for IG1
            $auditResults.IG2 = $true # As per CIS Control v8 mapping for IG2
            $auditResults.IG3 = $true # As per CIS Control v8 mapping for IG3
            $auditResults.ELevel = "E3" # Based on your environment (E3, E5, etc.)
            $auditResults.ProfileLevel = "L1"
            $auditResults.Rec = "6.5.1"
            $auditResults.RecDescription = "Ensure modern authentication for Exchange Online is enabled (Automated)"
            $auditResults.Result = $orgConfig.OAuth2ClientProfileEnabled
            $auditResults.Details = $auditResults.Details = $orgConfig.Name + " OAuth2ClientProfileEnabled: " + $orgConfig.OAuth2ClientProfileEnabled
            $auditResults.FailureReason = if (-not $orgConfig.OAuth2ClientProfileEnabled) { "Modern authentication is disabled" } else { "N/A" }
            $auditResults.Status = if ($orgConfig.OAuth2ClientProfileEnabled) { "Pass" } else { "Fail" }


        }
        catch {
            Write-Error "An error occurred while testing modern authentication for Exchange Online: $_"
        }
    }

    end {
        # Return auditResults
        return $auditResults
    }
}





