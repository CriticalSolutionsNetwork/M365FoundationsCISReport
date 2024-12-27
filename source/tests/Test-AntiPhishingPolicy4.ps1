function Test-AntiPhishingPolicy4 {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param ()
    begin {
        # Set the record number and start the process
        $RecNum = '2.1.7'
        Write-Verbose "Running Test-AntiPhishingPolicy4 for $RecNum..."
    }
    process {
        try {
            # Step 1: Retrieve all anti-phishing policies and rules
            Write-Verbose 'Retrieving all anti-phishing policies and rules...'
            $antiPhishPolicies, $antiPhishRules = Get-CISExoOutput -Rec $RecNum
            if ($null -eq $antiPhishPolicies -or $antiPhishPolicies.Count -eq 0) {
                throw 'No Anti-Phishing policies found.'
            }
            # Initialize lists to track compliant and non-compliant policies and reasons for failures
            $compliantPolicies = @()
            $failureReasons = @()
            $nonCompliantPolicies = @()
            # Step 2: Evaluate strict and standard preset policies
            Write-Verbose 'Evaluating strict and standard preset policies...'
            $strictPolicy = $antiPhishPolicies | Where-Object { $_.Name -eq 'Strict Preset Security Policy' }
            $standardPolicy = $antiPhishPolicies | Where-Object { $_.Name -eq 'Standard Preset Security Policy' }
            $strictStandardCompliant = $false
            foreach ($policy in @($strictPolicy, $standardPolicy)) {
                if ($null -ne $policy) {
                    # Check if the Strict or Standard policy is compliant
                    $isCompliant = Get-PhishPolicyCompliance -policy $policy
                    if ($isCompliant) {
                        $strictStandardCompliant = $true
                        $compliantPolicies += $policy.Name
                        # If Strict is compliant, stop evaluating further
                        if ($policy.Name -eq 'Strict Preset Security Policy') {
                            break
                        }
                    } else {
                        $nonCompliantPolicies += $policy.Name
                    }
                }
            }
            # Step 3: Evaluate custom policies if strict and standard are not compliant
            if (-not $strictStandardCompliant) {
                Write-Verbose 'Evaluating custom policies for compliance...'
                # Filter custom policies using $antiPhishRules to exclude default, strict, and standard
                $customPolicies = $antiPhishPolicies | Where-Object { $antiPhishRules.AntiPhishPolicy -contains $_.Name -and $_.Name -notin @('Strict Preset Security Policy', 'Standard Preset Security Policy', 'Office365 AntiPhish Default') }
                $customPolicies = $customPolicies | Sort-Object -Property { $antiPhishRules | Where-Object { $_.AntiPhishPolicy -eq $_.Name } | Select-Object -ExpandProperty Priority }
                foreach ($policy in $customPolicies) {
                    # Check for scope overlap between custom policies and strict/standard policies
                    $scopeOverlap = Get-ScopeOverlap -Policy $policy -OtherPolicies @($strictPolicy, $standardPolicy)
                    if ($scopeOverlap) {
                        $failureReasons += "Custom policy $($policy.Name) overlaps with strict or standard preset policies."
                        $nonCompliantPolicies += $policy.Name
                    } else {
                        # Check if the custom policy is compliant
                        $isCompliant = Get-PhishPolicyCompliance -policy $policy
                        if ($isCompliant) {
                            $compliantPolicies += $policy.Name
                        } else {
                            $nonCompliantPolicies += $policy.Name
                        }
                    }
                }
            }
            # Step 4: Evaluate the default policy if no compliant custom, strict, or standard policies
            if ($compliantPolicies.Count -eq 0) {
                Write-Verbose 'Evaluating default policy for compliance...'
                $defaultPolicy = $antiPhishPolicies | Where-Object { $_.Name -eq 'Office365 AntiPhish Default' }
                if ($null -ne $defaultPolicy) {
                    # Check for scope overlap between the default policy and other policies
                    $scopeOverlap = Get-ScopeOverlap -Policy $defaultPolicy -OtherPolicies @($strictPolicy, $standardPolicy, $customPolicies)
                    if ($scopeOverlap) {
                        $failureReasons += "Default policy overlaps with other scoped policies."
                        $nonCompliantPolicies += $defaultPolicy.Name
                    } else {
                        # Check if the default policy is compliant
                        $isCompliant = Get-PhishPolicyCompliance -policy $defaultPolicy
                        if ($isCompliant) {
                            $compliantPolicies += $defaultPolicy.Name
                        } else {
                            $nonCompliantPolicies += $defaultPolicy.Name
                        }
                    }
                }
            }
            # Step 5: Determine overall compliance
            $isOverallCompliant = ($compliantPolicies.Count -gt 0) -and ($failureReasons.Count -eq 0)
            # Step 6: Prepare result details
            $resultDetails = if ($isOverallCompliant) {
                # Prepare details for compliant policies
                "Compliant Policies: $($compliantPolicies -join ', ')"
            }
            else {
                # Prepare details for non-compliant policies and reasons
                "Non-Compliant Policies: $($nonCompliantPolicies -join ', ')`nFailure Reasons:`n" + ($failureReasons -join "`n")
            }
            # Step 7: Prepare the audit result object
            $params = @{
                Rec           = $RecNum
                Result        = $isOverallCompliant
                Status        = if ($isOverallCompliant) { 'Pass' } else { 'Fail' }
                Details       = $resultDetails
                FailureReason = if (-not $isOverallCompliant) { $failureReasons -join "`n" } else { 'None' }
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            # Handle errors and return the error result
            Write-Error "An error occurred during the test $RecNum`: $_"
            $auditResult = Get-TestError -LastError $_ -RecNum $RecNum
        }
    }
    end {
        # Return the audit result object
        return $auditResult
    }
}
