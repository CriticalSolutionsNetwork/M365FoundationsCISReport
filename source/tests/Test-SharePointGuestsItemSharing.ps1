function Test-SharePointGuestsItemSharing {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed

        $auditResult = [CISAuditResult]::new()
        $recnum = "7.2.5"
    }

    process {
        try {
            # 7.2.5 (L2) Ensure that SharePoint guest users cannot share items they don't own
            $SPOTenant = Get-SPOTenant | Select-Object PreventExternalUsersFromResharing
            $isGuestResharingPrevented = $SPOTenant.PreventExternalUsersFromResharing

            # Populate the auditResult object with the required properties
            $params = @{
                Rec           = $recnum
                Result        = $isGuestResharingPrevented
                Status        = if ($isGuestResharingPrevented) { "Pass" } else { "Fail" }
                Details       = "PreventExternalUsersFromResharing: $isGuestResharingPrevented"
                FailureReason = if (-not $isGuestResharingPrevented) { "Guest users can reshare items they don't own." } else { "N/A" }
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
        # Return auditResult
        return $auditResult
    }
}
