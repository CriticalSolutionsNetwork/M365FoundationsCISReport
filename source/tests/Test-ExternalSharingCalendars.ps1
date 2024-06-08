function Test-ExternalSharingCalendars {
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
        $recnum = "1.3.3"
    }

    process {

        try {
            # 1.3.3 (L2) Ensure 'External sharing' of calendars is not available (Automated)

            # Retrieve sharing policies related to calendar sharing
            $sharingPolicies = Get-SharingPolicy | Where-Object { $_.Domains -like '*CalendarSharing*' }

            # Check if calendar sharing is disabled in all applicable policies
            $isExternalSharingDisabled = $true
            $sharingPolicyDetails = @()
            foreach ($policy in $sharingPolicies) {
                if ($policy.Enabled -eq $true) {
                    $isExternalSharingDisabled = $false
                    $sharingPolicyDetails += "$($policy.Name): Enabled"
                }
            }

            # Prepare failure reasons and details based on compliance
            $failureReasons = if (-not $isExternalSharingDisabled) {
                "Calendar sharing with external users is enabled in one or more policies."
            }
            else {
                "N/A"
            }

            $details = if ($isExternalSharingDisabled) {
                "Calendar sharing with external users is disabled."
            }
            else {
                "Enabled Sharing Policies: $($sharingPolicyDetails -join ', ')"
            }

            # Create and populate the CISAuditResult object
            $params = @{
                Rec           = $recnum
                Result        = $isExternalSharingDisabled
                Status        = if ($isExternalSharingDisabled) { "Pass" } else { "Fail" }
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
