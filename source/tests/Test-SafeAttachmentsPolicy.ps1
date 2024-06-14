function Test-SafeAttachmentsPolicy {
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
        # Retrieve all Safe Attachment policies where Enable is set to True
        $safeAttachmentPolicies = Get-SafeAttachmentPolicy | Where-Object { $_.Enable -eq $true }
        if ($null -ne $safeAttachmentPolicies) {
            try {
                # 2.1.4 (L2) Ensure Safe Attachments policy is enabled



                # Condition A: Check if any Safe Attachments policy is enabled
                $result = $null -ne $safeAttachmentPolicies -and $safeAttachmentPolicies.Count -gt 0

                # Condition B, C, D: Additional checks can be added here if more detailed policy attributes are required

                # Determine details and failure reasons based on the presence of enabled policies
                $details = if ($result) {
                    "Enabled Safe Attachments Policies: $($safeAttachmentPolicies.Name -join ', ')"
                }
                else {
                    "No Safe Attachments Policies are enabled."
                }

                $failureReasons = if ($result) {
                    "N/A"
                }
                else {
                    "Safe Attachments policy is not enabled."
                }

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

