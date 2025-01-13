function Connect-M365Suite {
    [OutputType([void])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$TenantAdminUrl,

        [Parameter(Mandatory = $false)]
        [CISAuthenticationParameters]$AuthParams,

        [Parameter(Mandatory)]
        [string[]]$RequiredConnections,

        [Parameter(Mandatory = $false)]
        [switch]$SkipConfirmation
    )

    $VerbosePreference = if ($SkipConfirmation) { 'SilentlyContinue' } else { 'Continue' }
    $tenantInfo = @()
    $connectedServices = @()

    try {
        if ($RequiredConnections -contains 'Microsoft Graph' -or $RequiredConnections -contains 'EXO | Microsoft Graph') {
            try {
                Write-Verbose 'Connecting to Microsoft Graph...'
                if ($AuthParams) {
                    Connect-MgGraph -CertificateThumbprint $AuthParams.ClientCertThumbPrint -AppId $AuthParams.ClientId -TenantId $AuthParams.TenantId -NoWelcome | Out-Null
                }
                else {
                    Connect-MgGraph -Scopes 'Directory.Read.All', 'Domain.Read.All', 'Policy.Read.All', 'Organization.Read.All' -NoWelcome | Out-Null
                }
                $graphOrgDetails = Get-MgOrganization
                $tenantInfo += [PSCustomObject]@{
                    Service    = 'Microsoft Graph'
                    TenantName = $graphOrgDetails.DisplayName
                    TenantID   = $graphOrgDetails.Id
                }
                $connectedServices += 'Microsoft Graph'
                Write-Verbose 'Successfully connected to Microsoft Graph.'
            }
            catch {
                throw "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
            }
        }

        if ($RequiredConnections -contains 'EXO' -or $RequiredConnections -contains 'AzureAD | EXO' -or $RequiredConnections -contains 'Microsoft Teams | EXO' -or $RequiredConnections -contains 'EXO | Microsoft Graph') {
            try {
                Write-Verbose 'Connecting to Exchange Online...'
                if ($AuthParams) {
                    Connect-ExchangeOnline -AppId $AuthParams.ClientId -CertificateThumbprint $AuthParams.ClientCertThumbPrint -Organization $AuthParams.OnMicrosoftUrl -ShowBanner:$false | Out-Null
                }
                else {
                    Connect-ExchangeOnline -ShowBanner:$false | Out-Null
                }
                $exoTenant = (Get-OrganizationConfig).Identity
                $tenantInfo += [PSCustomObject]@{
                    Service    = 'Exchange Online'
                    TenantName = $exoTenant
                    TenantID   = 'N/A'
                }
                $connectedServices += 'EXO'
                Write-Verbose 'Successfully connected to Exchange Online.'
            }
            catch {
                throw "Failed to connect to Exchange Online: $($_.Exception.Message)"
            }
        }

        if ($RequiredConnections -contains 'SPO') {
            try {
                Write-Verbose 'Connecting to SharePoint Online...'
                if ($AuthParams) {
                    Connect-PnPOnline -Url $AuthParams.SpAdminUrl -ClientId $AuthParams.ClientId -Tenant $AuthParams.OnMicrosoftUrl -Thumbprint $AuthParams.ClientCertThumbPrint | Out-Null
                }
                else {
                    Connect-SPOService -Url $TenantAdminUrl | Out-Null
                }
                $tenantName = if ($AuthParams) {
                    (Get-PnPSite).Url
                }
                else {
                    $sites =  Get-SPOSite
                    # Get the URL from the first site collection
                    $url = $sites[0].Url
                    # Use regex to extract the base URL up to the .com portion
                    $baseUrl = [regex]::Match($url, 'https://[^/]+.com').Value
                    # Output the base URL
                    $baseUrl
                }
                $tenantInfo += [PSCustomObject]@{
                    Service    = 'SharePoint Online'
                    TenantName = $tenantName
                }
                $connectedServices += 'SPO'
                Write-Verbose 'Successfully connected to SharePoint Online.'
            }
            catch {
                throw "Failed to connect to SharePoint Online: $($_.Exception.Message)"
            }
        }

        if ($RequiredConnections -contains 'Microsoft Teams' -or $RequiredConnections -contains 'Microsoft Teams | EXO') {
            try {
                Write-Verbose 'Connecting to Microsoft Teams...'
                if ($AuthParams) {
                    Connect-MicrosoftTeams -TenantId $AuthParams.TenantId -CertificateThumbprint $AuthParams.ClientCertThumbPrint -ApplicationId $AuthParams.ClientId | Out-Null
                }
                else {
                    Connect-MicrosoftTeams | Out-Null
                }
                $teamsTenantDetails = Get-CsTenant
                $tenantInfo += [PSCustomObject]@{
                    Service    = 'Microsoft Teams'
                    TenantName = $teamsTenantDetails.DisplayName
                    TenantID   = $teamsTenantDetails.TenantId
                }
                $connectedServices += 'Microsoft Teams'
                Write-Verbose 'Successfully connected to Microsoft Teams.'
            }
            catch {
                throw "Failed to connect to Microsoft Teams: $($_.Exception.Message)"
            }
        }

        if (-not $SkipConfirmation) {
            Write-Verbose 'Connected to the following tenants:'
            foreach ($tenant in $tenantInfo) {
                Write-Verbose "Service: $($tenant.Service) | Tenant: $($tenant.TenantName)"
            }
            $confirmation = Read-Host 'Do you want to proceed with these connections? (Y/N)'
            if ($confirmation -notlike 'Y') {
                Disconnect-M365Suite -RequiredConnections $connectedServices
                throw 'User aborted connection setup.'
            }
        }
    }
    catch {
        $VerbosePreference = 'Continue'
        throw "Connection failed: $($_.Exception.Message)"
    }
    finally {
        $VerbosePreference = 'Continue'
    }
}