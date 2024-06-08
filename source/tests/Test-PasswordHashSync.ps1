function Test-PasswordHashSync {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "5.1.8.1"
    }

    process {
        try {
            # 5.1.8.1 (L1) Ensure password hash sync is enabled for hybrid deployments
            # Pass if OnPremisesSyncEnabled is True. Fail otherwise.

            # Retrieve password hash sync status
            $passwordHashSync = Get-MgOrganization | Select-Object -ExpandProperty OnPremisesSyncEnabled
            $hashSyncResult = $passwordHashSync

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $hashSyncResult) {
                "Password hash sync for hybrid deployments is not enabled"
            }
            else {
                "N/A"
            }

            $details = "OnPremisesSyncEnabled: $($passwordHashSync)"

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $hashSyncResult
                Status        = if ($hashSyncResult) { "Pass" } else { "Fail" }
                Details       = $details
                FailureReason = $failureReasons
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
