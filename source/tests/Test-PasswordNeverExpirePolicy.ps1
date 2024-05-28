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
        $params = @{
            Rec            = "1.3.1"
            Result         = $passwordPolicy -eq 0
            Status         = if ($passwordPolicy -eq 0) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
