<#
    .SYNOPSIS
        This is a sample Private function only visible within the module.
    .DESCRIPTION
        This sample function is not exported to the module and only return the data passed as parameter.
    .EXAMPLE
        $null = Get-CISSpoOutput -PrivateData 'NOTHING TO SEE HERE'
    .PARAMETER PrivateData
        The PrivateData parameter is what will be returned without transformation.
#>
function Get-CISSpoOutput {
    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Rec
    )
    begin {
        # Begin Block #
        <#
            # Tests
            7.2.1
            7.2.2
            7.2.3
            7.2.4
            7.2.5
            7.2.6
            7.2.7
            7.2.9
            7.2.10
            7.3.1
            7.3.2
            7.3.4

            # Test number array
            $testNumbers = @('7.2.1', '7.2.2', '7.2.3', '7.2.4', '7.2.5', '7.2.6', '7.2.7', '7.2.9', '7.2.10', '7.3.1', '7.3.2', '7.3.4')
        #>
    }
    process {
        Write-Verbose "Retuning data for Rec: $Rec"
        switch ($Rec) {
            '7.2.1' {
                # Test-ModernAuthSharePoint.ps1
                $SPOTenant = Get-SPOTenant | Select-Object -Property LegacyAuthProtocolsEnabled
                return $SPOTenant
            }
            '7.2.2' {
                # Test-SharePointAADB2B.ps1
                # 7.2.2 (L1) Ensure SharePoint and OneDrive integration with Azure AD B2B is enabled
                $SPOTenantAzureADB2B = Get-SPOTenant | Select-Object EnableAzureADB2BIntegration
                return $SPOTenantAzureADB2B
            }
            '7.2.3' {
                # Test-RestrictExternalSharing.ps1
                # 7.2.3 (L1) Ensure external content sharing is restricted
                # Retrieve the SharingCapability setting for the SharePoint tenant
                $SPOTenantSharingCapability = Get-SPOTenant | Select-Object SharingCapability
                return $SPOTenantSharingCapability
            }
            '7.2.4' {
                # Test-OneDriveContentRestrictions.ps1
                $SPOTenant = Get-SPOTenant | Select-Object OneDriveSharingCapability
                return $SPOTenant
            }
            '7.2.5' {
                # Test-SharePointGuestsItemSharing.ps1
                # 7.2.5 (L2) Ensure that SharePoint guest users cannot share items they don't own
                $SPOTenant = Get-SPOTenant | Select-Object PreventExternalUsersFromResharing
                return $SPOTenant
            }
            '7.2.6' {
                # Test-SharePointExternalSharingDomains.ps1
                # 7.2.6 (L2) Ensure SharePoint external sharing is managed through domain whitelist/blacklists
                $SPOTenant = Get-SPOTenant | Select-Object SharingDomainRestrictionMode, SharingAllowedDomainList
                return $SPOTenant
            }
            '7.2.7' {
                # Test-LinkSharingRestrictions.ps1
                # Retrieve link sharing configuration for SharePoint and OneDrive
                $SPOTenantLinkSharing = Get-SPOTenant | Select-Object DefaultSharingLinkType
                return $SPOTenantLinkSharing
            }
            '7.2.9' {
                # Test-GuestAccessExpiration.ps1
                # Retrieve SharePoint tenant settings related to guest access expiration
                $SPOTenantGuestAccess = Get-SPOTenant | Select-Object ExternalUserExpirationRequired, ExternalUserExpireInDays
                return $SPOTenantGuestAccess
            }
            '7.2.10' {
                # Test-ReauthWithCode.ps1
                # 7.2.10 (L1) Ensure reauthentication with verification code is restricted
                # Retrieve reauthentication settings for SharePoint Online
                $SPOTenantReauthentication = Get-SPOTenant | Select-Object EmailAttestationRequired, EmailAttestationReAuthDays
                return $SPOTenantReauthentication
            }
            '7.3.1' {
                # Test-DisallowInfectedFilesDownload.ps1
                # Retrieve the SharePoint tenant configuration
                $SPOTenantDisallowInfectedFileDownload = Get-SPOTenant | Select-Object DisallowInfectedFileDownload
                return $SPOTenantDisallowInfectedFileDownload
            }
            '7.3.2' {
                # Test-OneDriveSyncRestrictions.ps1
                # Retrieve OneDrive sync client restriction settings
                $SPOTenantSyncClientRestriction = Get-SPOTenantSyncClientRestriction | Select-Object TenantRestrictionEnabled, AllowedDomainList
                return $SPOTenantSyncClientRestriction
            }
            '7.3.4' {
                # Test-RestrictCustomScripts.ps1
                # Retrieve all site collections and select necessary properties
                $SPOSitesCustomScript = Get-SPOSite -Limit All | Select-Object Title, Url, DenyAddAndCustomizePages
                return $SPOSitesCustomScript
            }
            default { throw "No match found for test: $Rec" }
        }
    }
    end {
        Write-Verbose "Retuning data for Rec: $Rec"
    }
} # end function Get-CISMSTeamsOutput