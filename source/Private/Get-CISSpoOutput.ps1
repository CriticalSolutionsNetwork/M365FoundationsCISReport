<#
    .SYNOPSIS
        Retrieves configuration settings from SharePoint Online or PnP based on the specified recommendation.
    .DESCRIPTION
        The Get-CISSpoOutput function retrieves specific configuration settings from SharePoint Online or PnP based on a recommendation number.
        It dynamically switches between using SPO and PnP commands based on the provided authentication context.
    .PARAMETER Rec
        The recommendation number corresponding to the specific test to be run.
    .INPUTS
        None. You cannot pipe objects to this function.
    .OUTPUTS
        PSCustomObject
            Returns configuration details for the specified recommendation.
    .EXAMPLE
        PS> Get-CISSpoOutput -Rec '7.2.1'
        Retrieves the LegacyAuthProtocolsEnabled property from the SharePoint Online or PnP tenant.
#>
function Get-CISSpoOutput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "The recommendation number corresponding to the specific test to be run.")]
        [String]$Rec
    )
    begin {
        # Check if PnP should be used
        $UsePnP = $script:PnpAuth
        # Determine the prefix based on the switch
        $prefix = if ($UsePnP) { "PnP" } else { "SPO" }
        # Define a hashtable to map the function calls
        $commandMap = @{
            # Test-ModernAuthSharePoint.ps1
            # 7.2.1 (L1) Ensure Legacy Authentication Protocols are disabled
            # $SPOTenant Mock Object
            '7.2.1' = {
                Invoke-Command {
                    & "$((Get-Command -Name "Get-${prefix}Tenant").Name)"
                } | Select-Object -Property LegacyAuthProtocolsEnabled
            }
            # Test-SharePointAADB2B.ps1
            # 7.2.2 (L1) Ensure SharePoint and OneDrive integration with Azure AD B2B is enabled
            # $SPOTenantAzureADB2B Mock Object
            '7.2.2' = {
                Invoke-Command {
                    & "$((Get-Command -Name "Get-${prefix}Tenant").Name)"
                } | Select-Object -Property EnableAzureADB2BIntegration
            }
            # Test-RestrictExternalSharing.ps1
            # 7.2.3 (L1) Ensure external content sharing is restricted
            # Retrieve the SharingCapability setting for the SharePoint tenant
            # $SPOTenantSharingCapability Mock Object
            '7.2.3' = {
                Invoke-Command {
                    & "$((Get-Command -Name "Get-${prefix}Tenant").Name)"
                } | Select-Object -Property SharingCapability
            }
            # Test-OneDriveContentRestrictions.ps1
            # 7.2.4 (L2) Ensure OneDrive content sharing is restricted
            # $SPOTenant Mock Object
            '7.2.4' = {
                Invoke-Command {
                    if ($prefix -eq "SPO") {
                        & "$((Get-Command -Name "Get-${prefix}Tenant").Name)" | Select-Object -Property OneDriveSharingCapability
                    } else {
                        # Workaround until bugfix in PnP.PowerShell
                        & "$((Get-Command -Name "Get-${prefix}Tenant").Name)" | Select-Object -Property OneDriveLoopSharingCapability | Select-Object @{Name = "OneDriveSharingCapability"; Expression = { $_.OneDriveLoopSharingCapability }}
                    }
                }
            }
            # Test-SharePointGuestsItemSharing.ps1
            # 7.2.5 (L2) Ensure that SharePoint guest users cannot share items they don't own
            # $SPOTenant Mock Object
            '7.2.5' = {
                Invoke-Command {
                    & "$((Get-Command -Name "Get-${prefix}Tenant").Name)"
                } | Select-Object -Property PreventExternalUsersFromResharing
            }
            # Test-SharePointExternalSharingDomains.ps1
            # 7.2.6 (L2) Ensure SharePoint external sharing is managed through domain whitelist/blacklists
            # Add Authorized Domains?
            # $SPOTenant Mock Object
            '7.2.6' = {
                Invoke-Command {
                    & "$((Get-Command -Name "Get-${prefix}Tenant").Name)"
                } | Select-Object -Property SharingDomainRestrictionMode, SharingAllowedDomainList
            }
            # Test-LinkSharingRestrictions.ps1
            # Retrieve link sharing configuration for SharePoint and OneDrive
            # $SPOTenantLinkSharing Mock Object
            '7.2.7' = {
                Invoke-Command {
                    & "$((Get-Command -Name "Get-${prefix}Tenant").Name)"
                } | Select-Object -Property DefaultSharingLinkType
            }
            # Test-GuestAccessExpiration.ps1
            # Retrieve SharePoint tenant settings related to guest access expiration
            # $SPOTenantGuestAccess Mock Object
            '7.2.9' = {
                Invoke-Command {
                    & "$((Get-Command -Name "Get-${prefix}Tenant").Name)"
                } | Select-Object -Property ExternalUserExpirationRequired, ExternalUserExpireInDays
            }
            # Test-ReauthWithCode.ps1
            # 7.2.10 (L1) Ensure reauthentication with verification code is restricted
            # Retrieve reauthentication settings for SharePoint Online
            # $SPOTenantReauthentication Mock Object
            '7.2.10' = {
                Invoke-Command {
                    & "$((Get-Command -Name "Get-${prefix}Tenant").Name)"
                } | Select-Object -Property EmailAttestationRequired, EmailAttestationReAuthDays
            }
            # Test-DisallowInfectedFilesDownload.ps1
            # Retrieve the SharePoint tenant configuration
            # $SPOTenantDisallowInfectedFileDownload Mock Object
            '7.3.1' = {
                Invoke-Command {
                    & "$((Get-Command -Name "Get-${prefix}Tenant").Name)"
                } | Select-Object -Property DisallowInfectedFileDownload
            }
            # Test-OneDriveSyncRestrictions.ps1
            # Retrieve OneDrive sync client restriction settings
            # Add isHybrid parameter?
            # $SPOTenantSyncClientRestriction Mock Object
            '7.3.2' = {
                Invoke-Command {
                    & "$((Get-Command -Name "Get-${prefix}TenantSyncClientRestriction").Name)"
                } | Select-Object -Property TenantRestrictionEnabled, AllowedDomainList
            }
            # Test-RestrictCustomScripts.ps1
            # Retrieve all site collections and select necessary properties
            # $SPOSitesCustomScript Mock Object
            '7.3.4' = {
                Invoke-Command {
                    if ($prefix -eq "SPO") {
                        & "$((Get-Command -Name "Get-${prefix}Site").Name)" -Limit All | Select-Object Title, Url, DenyAddAndCustomizePages
                    } else {
                        & "$((Get-Command -Name "Get-${prefix}TenantSite").Name)" | Select-Object Title, Url, DenyAddAndCustomizePages
                    }
                }
            }
        }
    }
    process {
        try {
            Write-Verbose "Returning data for Rec: $Rec"
            if ($commandMap.ContainsKey($Rec)) {
                # Invoke the script block associated with the command
                $result = & $commandMap[$Rec] -ErrorAction Stop
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
