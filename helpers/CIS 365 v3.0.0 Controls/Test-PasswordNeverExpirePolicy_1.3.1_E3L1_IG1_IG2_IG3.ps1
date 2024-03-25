function Test-PasswordNeverExpirePolicy_1.3.1_E3L1_IG1_IG2_IG3 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DomainName # DomainName parameter is now mandatory
    )

    begin {
        # Dot source the class script
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResults = @()
    }

    process {
        # 1.3.1 (L1) Ensure the 'Password expiration policy' is set to 'Set passwords to never expire'
        # Pass if PasswordValidityPeriodInDays is 0.
        # Fail otherwise.

        $passwordPolicy = Get-MgDomain -DomainId $DomainName | Select-Object PasswordValidityPeriodInDays

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.Rec = "1.3.1"
        $auditResult.RecDescription = "Ensure the 'Password expiration policy' is set to 'Set passwords to never expire'"
        $auditResult.ELevel = "E3"
        $auditResult.Profile = "L1"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "5.2"
        $auditResult.CISDescription = "Use Unique Passwords"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true # All are true
        $auditResult.Result = $passwordPolicy.PasswordValidityPeriodInDays -eq 0
        $auditResult.Details = "Validity Period: $($passwordPolicy.PasswordValidityPeriodInDays) days"
        $auditResult.FailureReason = if ($passwordPolicy.PasswordValidityPeriodInDays -eq 0) { "N/A" } else { "Password expiration is not set to never expire" }
        $auditResult.Status = if ($passwordPolicy.PasswordValidityPeriodInDays -eq 0) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
