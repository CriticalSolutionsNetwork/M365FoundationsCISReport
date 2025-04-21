function Test-AdministrativeAccountCompliance4 {
    [CmdletBinding()]
    param ()
    begin {
        $RecNum = "1.1.1"
        Write-Verbose "Starting Test-AdministrativeAccountCompliance4 for Rec: $RecNum"
    }
    process {
        try {
            # Retrieve privileged users with OnPremisesSyncEnabled
            Write-Verbose "Retrieving data for privileged users"
            $PrivilegedUsers = Get-CISMgOutput -Rec $RecNum
            # Filter for users with OnPremisesSyncEnabled
            $NonCompliantUsers = $PrivilegedUsers | Where-Object { $_.OnPremisesSyncEnabled -eq $true }
            if ($NonCompliantUsers.Count -gt 0) {
                Write-Verbose "Non-compliant users found: $($NonCompliantUsers.Count)"
                # Generate pipe-delimited failure table as plain text
                $Header = "DisplayName|UserPrincipalName|OnPremisesSyncEnabled"
                $FailureRows = $NonCompliantUsers | ForEach-Object {
                    "$($_.DisplayName)|$($_.UserPrincipalName)|$($_.OnPremisesSyncEnabled)"
                }
                $Details = "$Header`n$($FailureRows -join "`n")"
                $Status = "Fail"
                $FailureReason = "Non-compliant accounts detected: $($NonCompliantUsers.Count)"
            }
            else {
                Write-Verbose "All accounts are compliant."
                $Details = "N/A"
                $Status = "Pass"
                $FailureReason = "All administrative accounts are cloud-only."
            }
            # Prepare audit result
            $Params = @{
                Rec           = $RecNum
                Result        = ($NonCompliantUsers.Count -eq 0)
                Status        = $Status
                Details       = $Details
                FailureReason = $FailureReason
            }
            $AuditResult = Initialize-CISAuditResult @Params
        }
        catch {
            Write-Error "Error during compliance check: $_"
            $AuditResult = Get-TestError -LastError $_ -RecNum $RecNum
        }
    }
    end {
        # Output result
        return $AuditResult
    }
}
