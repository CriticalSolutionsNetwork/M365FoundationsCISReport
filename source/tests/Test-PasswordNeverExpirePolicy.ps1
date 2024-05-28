function Test-PasswordNeverExpirePolicy {
    [CmdletBinding()]
    param (
        # Aligned
        [Parameter(Mandatory)]
        [string]$DomainName # DomainName parameter is now mandatory
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 1.3.1 (L1) Ensure the 'Password expiration policy' is set to 'Set passwords to never expire'
        # Pass if PasswordValidityPeriodInDays is 0. Fail otherwise.

        # Retrieve password expiration policy
        $passwordPolicy = Get-MgDomain -DomainId $DomainName | Select-Object -ExpandProperty PasswordValidityPeriodInDays

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($passwordPolicy -ne 0) {
            "Password expiration is not set to never expire"
        }
        else {
            "N/A"
        }

        $details = "Validity Period: $passwordPolicy days"

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($passwordPolicy -eq 0) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.Rec = "1.3.1"
        $auditResult.RecDescription = "Ensure the 'Password expiration policy' is set to 'Set passwords to never expire'"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "5.2"
        $auditResult.CISDescription = "Use Unique Passwords"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $passwordPolicy -eq 0
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
