function Test-BlockChannelEmails {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "8.1.2"
    }

    process {

        try {
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
        $params = @{
            Rec            = $recnum
            Result         = -not $allowEmailIntoChannel
            Status         = if (-not $allowEmailIntoChannel) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
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
