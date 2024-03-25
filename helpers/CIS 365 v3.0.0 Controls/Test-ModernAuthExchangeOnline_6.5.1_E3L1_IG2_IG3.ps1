function Test-ModernAuthExchangeOnline_6.5.1_E3L1_IG2_IG3 {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {
        . ".\source\Classes\CISAuditResult.ps1"
        $CISAuditResult = [CISAuditResult]::new()
        # Initialization code
    }

    process {
        try {
            # Ensuring the ExchangeOnlineManagement module is available


            # 6.5.1 (L1) Ensure modern authentication for Exchange Online is enabled
            $orgConfig = Get-OrganizationConfig | Select-Object -Property Name, OAuth2ClientProfileEnabled

            # Create an instance of CISAuditResult and populate it

            $CISAuditResult.CISControlVer = "v8"
            $CISAuditResult.CISControl = "3.10"
            $CISAuditResult.CISDescription = "Encrypt Sensitive Data in Transit"
            $CISAuditResult.IG1 = $false # As per CIS Control v8 mapping for IG1
            $CISAuditResult.IG2 = $true # As per CIS Control v8 mapping for IG2
            $CISAuditResult.IG3 = $true # As per CIS Control v8 mapping for IG3
            $CISAuditResult.ELevel = "E3" # Based on your environment (E3, E5, etc.)
            $CISAuditResult.Profile = "L1"
            $CISAuditResult.Rec = "6.5.1"
            $CISAuditResult.RecDescription = "Ensure modern authentication for Exchange Online is enabled (Automated)"
            $CISAuditResult.Result = $orgConfig.OAuth2ClientProfileEnabled
            $CISAuditResult.Details = $orgConfig | Out-String
            $CISAuditResult.FailureReason = if (-not $orgConfig.OAuth2ClientProfileEnabled) { "Modern authentication is disabled" } else { "N/A" }
            $CISAuditResult.Status = if ($orgConfig.OAuth2ClientProfileEnabled) { "Pass" } else { "Fail" }


        }
        catch {
            Write-Error "An error occurred while testing modern authentication for Exchange Online: $_"
        }
    }

    end {
        # Return auditResults
        return $CISAuditResult
    }
}





