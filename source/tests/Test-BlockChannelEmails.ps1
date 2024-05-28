function Test-BlockChannelEmails {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 8.1.2 (L1) Ensure users can't send emails to a channel email address

        # Retrieve Teams client configuration
        $teamsClientConfig = Get-CsTeamsClientConfiguration -Identity Global
        $allowEmailIntoChannel = $teamsClientConfig.AllowEmailIntoChannel

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($allowEmailIntoChannel) {
            "Emails can be sent to a channel email address"
        }
        else {
            "N/A"
        }

        $details = if ($allowEmailIntoChannel) {
            "AllowEmailIntoChannel is set to True"
        }
        else {
            "AllowEmailIntoChannel is set to False"
        }

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # This control is explicitly not mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.1.2"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Set based on the benchmark
        $auditResult.IG2 = $false # Set based on the benchmark
        $auditResult.IG3 = $false # Set based on the benchmark
        $auditResult.RecDescription = "Ensure users can't send emails to a channel email address"
        $auditResult.Result = -not $allowEmailIntoChannel
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
        $auditResult.Status = if (-not $allowEmailIntoChannel) { "Pass" } else { "Fail" }
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
