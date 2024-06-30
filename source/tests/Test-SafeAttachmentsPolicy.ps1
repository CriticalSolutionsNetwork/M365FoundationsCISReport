function Test-SafeAttachmentsPolicy {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param ()
    begin {
        $recnum = "2.1.4"
        Write-Verbose "Running Test-SafeAttachmentsPolicy for $recnum..."
        <#
            Conditions for 2.1.4 (L2) Ensure Safe Attachments policy is enabled:
            Validate test for a pass:
                - Ensure the highest priority Safe Attachments policy is enabled.
                - Check if the policy's action is set to 'Block'.
                - Confirm the QuarantineTag is set to 'AdminOnlyAccessPolicy'.
                - Verify that the Redirect setting is disabled.
            Validate test for a fail:
                - If the highest priority Safe Attachments policy's action is not set to 'Block'.
                - If the QuarantineTag is not set to 'AdminOnlyAccessPolicy'.
                - If the Redirect setting is enabled.
                - If no enabled Safe Attachments policies are found.
        #>
    }
    process {
        # 2.1.4 (L2) Ensure Safe Attachments policy is enabled
        # $safeAttachmentPolicies Mock Object
        <#
            $safeAttachmentPolicies = @(
                [PSCustomObject]@{
                    Policy        = "Strict Preset Security Policy"
                    Action        = "Block"
                    QuarantineTag = "AdminOnlyAccessPolicy"
                    Redirect      = $false
                    Enabled       = $true
                }
            )
        #>
        $safeAttachmentPolicies = Get-CISExoOutput -Rec $recnum
        if ($safeAttachmentPolicies -ne 1) {
            try {
                $highestPriorityPolicy = $safeAttachmentPolicies | Select-Object -First 1
                # Initialize details and failure reasons
                $details = @()
                $failureReasons = @()
                # Check policy specifics as per CIS benchmark requirements
                if ($highestPriorityPolicy.Action -ne 'Block') {
                    $failureReasons += "Policy action is not set to 'Block'."
                }
                if ($highestPriorityPolicy.QuarantineTag -ne 'AdminOnlyAccessPolicy') {
                    $failureReasons += "Quarantine policy is not set to 'AdminOnlyAccessPolicy'."
                }
                if ($highestPriorityPolicy.Redirect -ne $false) {
                    $failureReasons += "Redirect is not disabled."
                }
                # The result is a pass if there are no failure reasons
                $result = $failureReasons.Count -eq 0
                $details = [PSCustomObject]@{
                    Policy        = $highestPriorityPolicy.Identity
                    Action        = $highestPriorityPolicy.Action
                    QuarantineTag = $highestPriorityPolicy.QuarantineTag
                    Redirect      = $highestPriorityPolicy.Redirect
                    Enabled       = $highestPriorityPolicy.Enable
                }
                # Format details for output manually
                $detailsString = "Policy|Action|QuarantineTag|Redirect|Enabled`n" + ($details |
                    ForEach-Object { "$($_.Policy)|$($_.Action)|$($_.QuarantineTag)|$($_.Redirect)|$($_.Enabled)`n" }
                )
                $failureReasonsString = ($failureReasons -join "`n")
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
                Details       = "No Safe Attachments policies found."
                FailureReason = "The audit needs Safe Attachment features available or required EXO commands will not be available otherwise."
            }
            $auditResult = Initialize-CISAuditResult @params
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}
