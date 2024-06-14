function Test-SafeAttachmentsPolicy {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param ()

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
        $recnum = "2.1.4"

        <#
        Conditions for 2.1.4 (L2) Ensure Safe Attachments policy is enabled

        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Specific conditions to check:
          - Condition A: The Safe Attachments policy is enabled in the Microsoft 365 Defender portal.
          - Condition B: The policy covers all recipients within the organization.
          - Condition C: The policy action is set to "Dynamic Delivery" or "Quarantine".
          - Condition D: The policy is not disabled.

        Validate test for a fail:
        - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        - Specific conditions to check:
          - Condition A: The Safe Attachments policy is not enabled in the Microsoft 365 Defender portal.
          - Condition B: The policy does not cover all recipients within the organization.
          - Condition C: The policy action is not set to "Dynamic Delivery" or "Quarantine".
          - Condition D: The policy is disabled.
        #>
    }

    process {
        if (Get-Command Get-SafeAttachmentPolicy -ErrorAction SilentlyContinue) {
            try {
                # Retrieve all Safe Attachment policies where Enable is set to True
                $safeAttachmentPolicies = Get-SafeAttachmentPolicy -ErrorAction SilentlyContinue | Where-Object { $_.Enable -eq $true }
                # Check if any Safe Attachments policy is enabled (Condition A)
                $result = $null -ne $safeAttachmentPolicies -and $safeAttachmentPolicies.Count -gt 0

                # Initialize details and failure reasons
                $details = @()
                $failureReasons = @()

                foreach ($policy in $safeAttachmentPolicies) {
                    # Initialize policy detail and failed status
                    $failed = $false

                    # Check if the policy action is set to "Dynamic Delivery" or "Quarantine" (Condition C)
                    if ($policy.Action -notin @("DynamicDelivery", "Quarantine")) {
                        $failureReasons += "Policy '$($policy.Name)' action is not set to 'Dynamic Delivery' or 'Quarantine'."
                        $failed = $true
                    }

                    # Check if the policy is not disabled (Condition D)
                    if (-not $policy.Enable) {
                        $failureReasons += "Policy '$($policy.Name)' is disabled."
                        $failed = $true
                    }

                    # Add policy details to the details array
                    $details += [PSCustomObject]@{
                        Policy   = $policy.Name
                        Enabled  = $policy.Enable
                        Action   = $policy.Action
                        Failed   = $failed
                    }
                }

                # The result is a pass if there are no failure reasons
                $result = $failureReasons.Count -eq 0

                # Format details for output
                $detailsString = $details | Format-Table -AutoSize | Out-String
                $failureReasonsString = ($failureReasons | ForEach-Object { $_ }) -join ' '

                # Create and populate the CISAuditResult object
                $params = @{
                    Rec           = $recnum
                    Result        = $result
                    Status        = if ($result) { "Pass" } else { "Fail" }
                    Details       = $detailsString
                    FailureReason = if ($result) { "N/A" } else { $failureReasonsString }
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
