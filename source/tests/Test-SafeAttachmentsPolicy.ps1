function Test-SafeAttachmentsPolicy {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        [Parameter(Mandatory = $false)]
        [string]$DomainName
    )
    begin {
        $recnum = "2.1.4"
        Write-Verbose "Running Test-SafeAttachmentsPolicy for $recnum..."
        <#
            Conditions for 2.1.4 (L2) Ensure Safe Attachments policy is enabled:
            Validate test for a pass:
                - Ensure Safe Attachments policies are enabled.
                - Check if each policy's action is set to 'Block'.
                - Confirm the QuarantineTag is set to 'AdminOnlyAccessPolicy'.
                - Verify that the Redirect setting is disabled.
            Validate test for a fail:
                - If any Safe Attachments policy's action is not set to 'Block'.
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
        $safeAttachmentPolicies, $safeAttachmentRules = Get-CISExoOutput -Rec $recnum
        $safeAttachmentPolicies = $safeAttachmentPolicies | Where-Object { $_.Identity -in $safeAttachmentRules.SafeAttachmentPolicy }
        if ($safeAttachmentPolicies -ne 1) {
            try {
                if ($DomainName) {
                    $safeAttachmentPolicies = $safeAttachmentPolicies | Where-Object { $_.Identity -eq ($safeAttachmentRules | Sort-Object -Property Priority | Where-Object { $_.RecipientDomainIs -in $DomainName } | Select-Object -ExpandProperty SafeAttachmentPolicy -First 1) }
                    $RecipientDomains = $safeAttachmentRules | Where-Object { $_.SafeAttachmentPolicy -eq $safeAttachmentPolicies.Identity } | Select-Object -ExpandProperty RecipientDomainIs
                }
                # Initialize details and failure reasons
                $details = @()
                $failureReasons = @()
                foreach ($policy in $safeAttachmentPolicies) {
                    # Check policy specifics as per CIS benchmark requirements
                    if ($Policy.Action -ne 'Block') {
                        $failureReasons += "Policy: $($Policy.Identity); Action is not set to 'Block'."
                    }
                    if ($Policy.QuarantineTag -ne 'AdminOnlyAccessPolicy') {
                        $failureReasons += "Policy: $($Policy.Identity); Quarantine is not set to 'AdminOnlyAccessPolicy'."
                    }
                    if ($Policy.Redirect -ne $false) {
                        $failureReasons += "Policy: $($Policy.Identity); Redirect is not disabled."
                    }
                    # The result is a pass if there are no failure reasons
                    $details += [PSCustomObject]@{
                        Policy        = ($Policy.Identity).trim()
                        Action        = $Policy.Action
                        QuarantineTag = $Policy.QuarantineTag
                        Redirect      = $Policy.Redirect
                        Enabled       = $Policy.Enable
                        Priority      = [int]($safeAttachmentRules | Where-Object { $_.SafeAttachmentPolicy -eq $Policy.Identity } | Select-Object -ExpandProperty Priority)
                    }
                }
                $result = $failureReasons.Count -eq 0
                if ($RecipientDomains) {
                    $failureReasons += "Recipient domain(s): '$($RecipientDomains -join ', ' )' included in tested policy."
                }
                # Format details for output manually
                $detailsString = "Policy|Action|QuarantineTag|Redirect|Enabled|Priority`n" + `
                ($details | ForEach-Object {
                        "$($_.Policy)|$($_.Action)|$($_.QuarantineTag)|$($_.Redirect)|$($_.Enabled)|$($_.Priority)`n"
                    }
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
