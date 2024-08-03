function Get-CISSpoOutput {
    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Rec
    )
    begin {
        if (($script:PnpAuth)) {
            $UsePnP = $true
        }
        # Determine the prefix based on the switch
        $prefix = if ($UsePnP) { "PnP" } else { "SPO" }
        # Define a hashtable to map the function calls
        $commandMap = @{
            '7.2.1'  = "Get-${prefix}Tenant | Select-Object -Property LegacyAuthProtocolsEnabled"
            '7.2.2'  = "Get-${prefix}Tenant | Select-Object EnableAzureADB2BIntegration"
            '7.2.3'  = "Get-${prefix}Tenant | Select-Object SharingCapability"
            '7.2.4'  = "Get-${prefix}Tenant | Select-Object OneDriveSharingCapability"
            '7.2.5'  = "Get-${prefix}Tenant | Select-Object PreventExternalUsersFromResharing"
            '7.2.6'  = "Get-${prefix}Tenant | Select-Object SharingDomainRestrictionMode, SharingAllowedDomainList"
            '7.2.7'  = "Get-${prefix}Tenant | Select-Object DefaultSharingLinkType"
            '7.2.9'  = "Get-${prefix}Tenant | Select-Object ExternalUserExpirationRequired, ExternalUserExpireInDays"
            '7.2.10' = "Get-${prefix}Tenant | Select-Object EmailAttestationRequired, EmailAttestationReAuthDays"
            '7.3.1'  = "Get-${prefix}Tenant | Select-Object DisallowInfectedFileDownload"
            '7.3.2'  = "Get-${prefix}TenantSyncClientRestriction | Select-Object TenantRestrictionEnabled, AllowedDomainList"
            '7.3.4'  = if ($prefix -eq "SPO") {"Get-${prefix}Site -Limit All | Select-Object Title, Url, DenyAddAndCustomizePages"} else {"Get-${Prefix}TenantSite | Select-Object Title, Url, DenyAddAndCustomizePages"}
        }
    }
    process {
        try {
            Write-Verbose "Returning data for Rec: $Rec"
            if ($commandMap.ContainsKey($Rec)) {
                $command = $commandMap[$Rec]
                $result = Invoke-Expression $command
                return $result
            }
            else {
                throw "No match found for test: $Rec"
            }
        }
        catch {
            throw "Get-CISSpoOutput: `n$_"
        }

    }
    end {
        Write-Verbose "Finished processing for Rec: $Rec"
    }
}
