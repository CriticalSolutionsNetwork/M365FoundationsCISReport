function Test-SafeLinksOfficeApps {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here if needed
    )
    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
        $recnum = "2.1.1"
        Write-Verbose "Running Test-SafeLinksOfficeApps for $recnum..."
        <#
        Conditions for 2.1.1 (L2) Ensure Safe Links for Office Applications is Enabled
        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
          - Condition A: In the Microsoft 365 security center, Safe Links policy for Office applications is enabled and the following protection settings are set:
            - Office 365 Apps: On
            - Teams: On
            - Email: On
            - Click protection settings: On
            - Do not track when users click safe links: Off
          - Condition B: Using the Exchange Online PowerShell Module, Safe Links policies are retrieved, and the relevant policy shows Safe Links for Office applications is enabled.
        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
          - Condition A: In the Microsoft 365 security center, Safe Links policy for Office applications is not enabled or one or more of the required protection settings are not set correctly.
            - Office 365 Apps: Off
            - Teams: Off
            - Email: Off
            - Click protection settings: Off
            - Do not track when users click safe links: On
          - Condition B: Using the Exchange Online PowerShell Module, Safe Links policies are retrieved, and the relevant policy shows Safe Links for Office applications is not enabled.
        #>
    }
    process {
        # 2.1.1 (L2) Ensure Safe Links for Office Applications is Enabled
        # Retrieve all Safe Links policies
        $misconfiguredDetails = Get-CISExoOutput -Rec $recnum
        # Misconfigured details returns 1 if EXO Commands needed for the test are not available
        if ($misconfiguredDetails -ne 1) {
            try {
                # Prepare the final result
                # Condition B: Ensuring no misconfigurations
                $result = $misconfiguredDetails.Count -eq 0
                $details = if ($result) { "All Safe Links policies are correctly configured." } else { $misconfiguredDetails -join '`n' }
                $failureReasons = if ($result) { "N/A" } else { "The following Safe Links policies settings do not meet the recommended configuration: $($misconfiguredDetails -join ' | ')" }
                # Create and populate the CISAuditResult object
                $params = @{
                    Rec           = $recnum
                    Result        = $result
                    Status        = if ($result) { "Pass" } else { "Fail" }
                    Details       = $details
                    FailureReason = $failureReasons
                }
                $auditResult = Initialize-CISAuditResult @params
            }
            catch {
                Write-Error "An error occurred during the test $recnum`:: $_"
                # Retrieve the description from the test definitions
                $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
                $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }
                $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })
                # Call Initialize-CISAuditResult with error parameters
                $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
            }
        }
        else {
            $params = @{
                Rec           = $recnum
                Result        = $false
                Status        = "Fail"
                Details       = "No M365 E5 licenses found."
                FailureReason = "The audit is for M365 E5 licenses and the required EXO commands will not be available otherwise."
            }
            $auditResult = Initialize-CISAuditResult @params
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}
