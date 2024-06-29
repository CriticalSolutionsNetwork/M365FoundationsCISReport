
function Test-PhishPolicyCompliance {
    param ($policy)
    return ($policy.Enabled -eq $true -and
        $policy.PhishThresholdLevel -ge 2 -and
        $policy.EnableMailboxIntelligenceProtection -eq $true -and
        $policy.EnableMailboxIntelligence -eq $true -and
        $policy.EnableSpoofIntelligence -eq $true)
}



function Test-AntiPhishingPolicy {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param ()

    begin {
        $recnum = "2.1.7"
        Write-Verbose "Running Test-AntiPhishingPolicy for $recnum..."
        . .\source\Classes\CISAuditResult.ps1
        <#
        Conditions for 2.1.7 (L1) Ensure robust anti-phishing policies are enforced
        Validate test for a pass:
        - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        - Ensure the policies are checked in the following order of precedence: Strict, Standard, Custom, and Default.
            - Specific conditions to check:
                - Condition A: At least one policy (preferably Strict or Standard) should cover all users or be marked as default.
                - Condition B: The policy must have enabled settings including PhishThresholdLevel at least 2, EnableMailboxIntelligenceProtection, EnableMailboxIntelligence, and EnableSpoofIntelligence.
        Validate test for a fail:
        - Identify any policy misconfigurations or absence of comprehensive coverage.
            - Specific conditions to check:
                - Condition A: No policy comprehensively covers all users or meets specified security criteria.
                - Condition B: Critical security features like Spoof Intelligence or Mailbox Intelligence are disabled in the relevant policies.
        #>
    }

    process {
        try {
            # Step 1: Retrieve all anti-phishing policies
            $VerbosePreference = "Continue"
            Write-Verbose "Retrieving all anti-phishing policies..."
            #$antiPhishPolicies = Get-CISExoOutput -Rec $recnum

            # Step 2: Initialize variables to track compliance and details
            $compliantPolicy = $null
            $details = @()
            $failureReasons = @()
            $hasFullCoveragePolicy = $false
            $policiesEvaluated = @()
            $PassedTests = @()
            $FailedTests = @()

            Write-Verbose "Evaluating each policy for compliance..."

            # Separate policies based on type
            $strictPolicy = $antiPhishPolicies | Where-Object { $_.Identity -match "Strict Preset Security Policy" }
            $standardPolicy = $antiPhishPolicies | Where-Object { $_.Identity -match "Standard Preset Security Policy" }
            $customPolicies = $antiPhishPolicies | Where-Object { -not ($_.Identity -match "Strict Preset Security Policy" -or $_.Identity -match "Standard Preset Security Policy" -or $_.IsDefault) }
            $defaultPolicy = $antiPhishPolicies | Where-Object { $_.IsDefault }

            # Step 3: Check for Strict Preset Security Policy
            if ($null -ne $strictPolicy) {
                Write-Verbose "Evaluating policy: $($strictPolicy.Identity)"
                $policiesEvaluated += $strictPolicy.Identity
                # Check if policy is compliant
                $isCompliant = Test-PhishPolicyCompliance -policy $strictPolicy
                # Log failure reasons for non-compliant policies
                if (-not $isCompliant) {
                    $failureReasons += "Policy $($strictPolicy.Identity) does not meet compliance criteria."
                    Write-Verbose "Policy $($strictPolicy.Identity) fails to meet one or more required conditions."
                    $FailedTests += $strictPolicy.Identity
                }
                # Compile details of each policy using the new function
                $details += Get-PhishPolicyDetail -policy $strictPolicy -isCompliant $isCompliant
                # Check if policy is Strict and covers all users
                if ($isCompliant) {
                    $PassedTests += $strictPolicy.Identity
                    Write-Verbose "Policy $($strictPolicy.Identity) is compliant."
                    $strictUsersToProtect = $strictPolicy.TargetedUsersToProtect
                    if ($strictUsersToProtect.count -eq 0) {
                        $hasFullCoveragePolicy = $true
                        $compliantPolicy = $strictPolicy
                        $details += "Is Full Coverage Policy: $hasFullCoveragePolicy`n`n"
                        Write-Verbose "$($strictPolicy.Identity) is compliant and covers all users. Stopping further evaluation."
                    }
                    else {
                        $details += "Is Full Coverage Policy: $($false)`n`n"
                    }
                }
            }
            # Step 4: Check for Standard Preset Security Policy if no full coverage from Strict
            if ($null -ne $standardPolicy -and $hasFullCoveragePolicy -ne $true) {
                Write-Verbose "Evaluating policy: $($standardPolicy.Identity)"
                $policiesEvaluated += $standardPolicy.Identity
                # Check if policy is compliant
                $isCompliant = Test-PhishPolicyCompliance -policy $standardPolicy
                # Log failure reasons for non-compliant policies
                if (-not $isCompliant) {
                    $failureReasons += "$($standardPolicy.Identity) does not meet compliance criteria."
                    Write-Verbose "$($standardPolicy.Identity) fails to meet one or more required conditions."
                    $FailedTests += $standardPolicy.Identity
                }
                # Compile details of each policy using the new function
                $details += Get-PhishPolicyDetail -policy $standardPolicy -isCompliant $isCompliant
                # Check if policy is Strict and covers all users
                if ($isCompliant) {
                    Write-Verbose "$($standardPolicy.Identity) is compliant."
                    $PassedTests += $standardPolicy.Identity
                    $standardUsersToProtect = $standardPolicy.TargetedUsersToProtect
                    if ($standardUsersToProtect.count -eq 0) {
                        $hasFullCoveragePolicy = $true
                        $compliantPolicy = $standardPolicy
                        $details += "Is Full Coverage Policy: $hasFullCoveragePolicy`n`n"
                        Write-Verbose "$($standardPolicy.Identity) is compliant and covers all users. Stopping further evaluation."
                    }
                    else {
                        $details += "Is Full Coverage Policy: $($false)`n`n"
                    }
                }
            }
            elseif ($null -ne $standardPolicy) {
                Write-Verbose "$($standardPolicy.Identity) was not evaluated."
                $isCompliant = Test-PhishPolicyCompliance -policy $standardPolicy
                $details += Get-PhishPolicyDetail -policy $standardPolicy -isCompliant $isCompliant
                $details += "Is Full Coverage Policy: $($false)`n`n"
            }
            # Step 5: Check Custom Policies if no full coverage from Strict or Standard
            if ($null -ne $customPolicies -and $hasFullCoveragePolicy -ne $true) {
                foreach ($policy in $customPolicies) {
                    if (-not $compliantPolicy) {
                        Write-Verbose "Evaluating policy: $($policy.Identity)"
                        $policiesEvaluated += $policy.Identity
                        # Check if policy is compliant
                        $isCompliant = Test-PhishPolicyCompliance -policy $policy
                        # Log failure reasons for non-compliant policies
                        if (-not $isCompliant) {
                            $failureReasons += "$($policy.Identity) Policy does not meet compliance criteria."
                            Write-Verbose "$($policy.Identity) Policy fails to meet one or more required conditions."
                            $FailedTests += $policy.Identity
                        }
                        # Compile details of each policy using the new function
                        $details += Get-PhishPolicyDetail -policy $policy -isCompliant $isCompliant
                        # Check if policy is Custom and covers all users
                        if ($isCompliant) {
                            Write-Verbose "$($policy.Identity) is compliant."
                            $PassedTests += $policy.Identity
                            $custompolicyUsersToProtect = $policy.TargetedUsersToProtect
                            if ($custompolicyUsersToProtect.count -eq 0) {
                                $hasFullCoveragePolicy = $true
                                $compliantPolicy = $policy
                                $details += "Is Full Coverage Policy: $hasFullCoveragePolicy`n"
                                Write-Verbose "$($policy.Identity) is compliant and covers all users. Stopping further evaluation."
                            }
                            else {
                                $details += "Is Full Coverage Policy: $($false)`n`n"
                            }
                        }
                    }
                    elseif ($compliantPolicy) {
                        Write-Verbose "$($policy.Identity) was not evaluated."
                        $isCompliant = Test-PhishPolicyCompliance -policy $policy
                        $details += Get-PhishPolicyDetail -policy $policy -isCompliant $isCompliant
                        $details += "Is Full Coverage Policy: $($false)`n`n"
                    }
                }
            }
            elseif ($null -ne $customPolicies ) {
                foreach ($policy in $customPolicies) {
                    Write-Verbose "$($policy.Identity) was not evaluated."
                    $isCompliant = Test-PhishPolicyCompliance -policy $policy
                    $details += Get-PhishPolicyDetail -policy $policy -isCompliant $isCompliant
                    $details += "Is Full Coverage Policy: $($false)`n`n"
                }
            }
            # Step 6: Check Default Policy if no full coverage from Strict, Standard, or Custom
            if ($null -ne $defaultPolicy -and $hasFullCoveragePolicy -ne $true) {
                Write-Verbose "Evaluating policy: $($defaultPolicy.Identity)"
                $policiesEvaluated += $defaultPolicy.Identity
                # Check if policy is compliant
                $isCompliant = Test-PhishPolicyCompliance -policy $defaultPolicy
                # Log failure reasons for non-compliant policies
                if (-not $isCompliant) {
                    $failureReasons += "$($defaultPolicy.Identity) Policy does not meet compliance criteria."
                    Write-Verbose "$($defaultPolicy.Identity) Policy fails to meet one or more required conditions."
                    $FailedTests += $defaultPolicy.Identity
                }
                # Compile details of each policy using the new function
                $details += Get-PhishPolicyDetail -policy $defaultPolicy -isCompliant $isCompliant
                # Check if policy is Default and covers all users
                if ($isCompliant) {
                    Write-Verbose "$($defaultPolicy.Identity) is compliant."
                    $PassedTests += $defaultPolicy.Identity
                    $defaultUsersToProtect = $defaultPolicy.TargetedUsersToProtect
                    if ($defaultUsersToProtect.count -eq 0) {
                        $hasFullCoveragePolicy = $true
                        $compliantPolicy = $defaultPolicy
                        $details += "Is Full Coverage Policy: $hasFullCoveragePolicy`n"
                        Write-Verbose "$($defaultPolicy.Identity) is compliant and covers all users. Stopping further evaluation."
                    }
                    else {
                        $details += "Is Full Coverage Policy: $($false)`n`n"
                    }
                }
            }
            elseif ($null -ne $defaultPolicy) {
                Write-Verbose "$($defaultPolicy.Identity) was not evaluated."
                $isCompliant = Test-PhishPolicyCompliance -policy $defaultPolicy
                $details += Get-PhishPolicyDetail -policy $defaultPolicy -isCompliant $isCompliant
                $details += "Is Full Coverage Policy: $($false)`n`n"
            }
            # Determine overall compliance based on the evaluations
            $isOverallCompliant = $hasFullCoveragePolicy -and $null -ne $compliantPolicy
            # Prepare result details
            $resultDetails = if ($isOverallCompliant) {
                "Compliant Policy: $($compliantPolicy.Identity)`nDetails:`n" + ($details -join "`n")
            }
            else {
                "Non-Compliant or No Policy Fully Covers All Users.`nDetails:`n" + ($details -join "`n")
            }
            # Verbose output for the overall compliance
            Write-Verbose "Overall Compliance: $isOverallCompliant"
            $VerbosePreference = "SilentlyContinue"
            # Prepare the parameters for the audit result
            $params = @{
                Rec           = $recnum
                Result        = $isOverallCompliant
                Status        = if ($isOverallCompliant) { "Pass" } else { "Fail" }
                Details       = $resultDetails
                FailureReason = if (-not $isOverallCompliant) { $failureReasons -join "`n" } else { "All settings are correct based on the highest precedence policy that applies to all users." }
            }
            # Initialize the audit result
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            Write-Error "An error occurred during the test: $_"
            $auditResult = Get-TestError -LastError $_ -recnum $recnum
        }
    }

    end {
        return $auditResult
    }
}


