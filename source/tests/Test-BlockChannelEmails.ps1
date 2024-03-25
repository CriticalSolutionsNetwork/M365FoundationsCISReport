function Test-BlockChannelEmails {
    [CmdletBinding()]
    param (
        # Parameters can be added here if needed
    )

    begin {
        # Dot source the class script

        $auditResults = @()
    }

    process {
        # 8.1.2 (L1) Ensure users can't send emails to a channel email address
        # Connect to Teams PowerShell using Connect-MicrosoftTeams

        $teamsClientConfig = Get-CsTeamsClientConfiguration -Identity Global
        $allowEmailIntoChannel = $teamsClientConfig.AllowEmailIntoChannel

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "0.0" # This control is Explicitly Not Mapped as per the image provided
        $auditResult.CISDescription = "Explicitly Not Mapped"
        $auditResult.Rec = "8.1.2"
        $auditResult.ELevel = "E3"
        $auditResult.ProfileLevel = "L1"
        $auditResult.IG1 = $false # Set based on the benchmark
        $auditResult.IG2 = $false # Set based on the benchmark
        $auditResult.IG3 = $false # Set based on the benchmark
        $auditResult.RecDescription = "Ensure users can't send emails to a channel email address"
        $auditResult.Result = -not $allowEmailIntoChannel
        $auditResult.Details = "AllowEmailIntoChannel is set to $allowEmailIntoChannel"
        $auditResult.FailureReason = if ($allowEmailIntoChannel) { "Emails can be sent to a channel email address" } else { "N/A" }
        $auditResult.Status = if (-not $allowEmailIntoChannel) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
