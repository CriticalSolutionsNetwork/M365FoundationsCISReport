<#
    .SYNOPSIS
        This is a sample Private function only visible within the module.

    .DESCRIPTION
        This sample function is not exported to the module and only return the data passed as parameter.

    .EXAMPLE
        $null = Get-ExoOutput -PrivateData 'NOTHING TO SEE HERE'

    .PARAMETER PrivateData
        The PrivateData parameter is what will be returned without transformation.

#>
function Get-ExoOutput {
    [cmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $Rec
    )

    begin {
        # Begin Block #
    }
    process {
        switch ($Rec) {
            '1.2.2' {
                $MBX = Get-EXOMailbox -RecipientTypeDetails SharedMailbox
                return $MBX
            }
            '1.3.3' {
                # Step: Retrieve sharing policies related to calendar sharing
                $sharingPolicies = Get-SharingPolicy | Where-Object { $_.Domains -like '*CalendarSharing*' }
                return $sharingPolicies
            }
            '1.3.6' {
                # Step: Retrieve the organization configuration (Condition C: Pass/Fail)
                $orgConfig = Get-OrganizationConfig | Select-Object CustomerLockBoxEnabled
                $customerLockboxEnabled = $orgConfig.CustomerLockBoxEnabled
                return $customerLockboxEnabled
            }
            '2.1.1' {
                if (Get-Command Get-SafeLinksPolicy -ErrorAction SilentlyContinue) {
                    # 2.1.1 (L2) Ensure Safe Links for Office Applications is Enabled
                    # Retrieve all Safe Links policies
                    $policies = Get-SafeLinksPolicy
                    # Initialize the details collection
                    $misconfiguredDetails = @()

                    foreach ($policy in $policies) {
                        # Get the detailed configuration of each policy
                        $policyDetails = Get-SafeLinksPolicy -Identity $policy.Name

                        # Check each required property and record failures
                        # Condition A: Checking policy settings
                        $failures = @()
                        if ($policyDetails.EnableSafeLinksForEmail -ne $true) { $failures += "EnableSafeLinksForEmail: False" } # Email: On
                        if ($policyDetails.EnableSafeLinksForTeams -ne $true) { $failures += "EnableSafeLinksForTeams: False" } # Teams: On
                        if ($policyDetails.EnableSafeLinksForOffice -ne $true) { $failures += "EnableSafeLinksForOffice: False" } # Office 365 Apps: On
                        if ($policyDetails.TrackClicks -ne $true) { $failures += "TrackClicks: False" } # Click protection settings: On
                        if ($policyDetails.AllowClickThrough -ne $false) { $failures += "AllowClickThrough: True" } # Do not track when users click safe links: Off

                        # Only add details for policies that have misconfigurations
                        if ($failures.Count -gt 0) {
                            $misconfiguredDetails += "Policy: $($policy.Name); Failures: $($failures -join ', ')"
                        }
                    }
                    return $misconfiguredDetails
                }
                else {
                    return 1
                }

            }
            '2.1.2' { Write-Output "Matched 2.1.2" }
            '2.1.3' { Write-Output "Matched 2.1.3" }
            '2.1.4' { Write-Output "Matched 2.1.4" }
            '2.1.5' { Write-Output "Matched 2.1.5" }
            '2.1.6' { Write-Output "Matched 2.1.6" }
            '2.1.7' { Write-Output "Matched 2.1.7" }
            '2.1.9' { Write-Output "Matched 2.1.9" }
            '3.1.1' { Write-Output "Matched 3.1.1" }
            '6.1.1' { Write-Output "Matched 6.1.1" }
            '6.1.2' { Write-Output "Matched 6.1.2" }
            '6.1.3' { Write-Output "Matched 6.1.3" }
            '6.2.1' { Write-Output "Matched 6.2.1" }
            '6.2.2' { Write-Output "Matched 6.2.2" }
            '6.2.3' { Write-Output "Matched 6.2.3" }
            '6.3.1' { Write-Output "Matched 6.3.1" }
            '6.5.1' { Write-Output "Matched 6.5.1" }
            '6.5.2' { Write-Output "Matched 6.5.2" }
            '6.5.3' { Write-Output "Matched 6.5.3" }
            '8.6.1' { Write-Output "Matched 8.6.1" }
            default { Write-Output "No match found" }
        }
    }
    end {
        Write-Verbose "Retuning data for Rec: $Rec"
    }
} # end function Get-MgOutput

