class CISAuthenticationParameters {
    [string]$ClientCertThumbPrint
    [string]$ClientId
    [string]$TenantId
    [string]$OnMicrosoftUrl
    [string]$SpAdminUrl

    # Constructor with validation
    CISAuthenticationParameters(
        [string]$ClientCertThumbPrint,
        [string]$ClientId,
        [string]$TenantId,
        [string]$OnMicrosoftUrl,
        [string]$SpAdminUrl
    ) {
        # Validate ClientCertThumbPrint
        if (-not $ClientCertThumbPrint -or $ClientCertThumbPrint.Length -ne 40 -or $ClientCertThumbPrint -notmatch '^[0-9a-fA-F]{40}$') {
            throw [ArgumentException]::new("ClientCertThumbPrint must be a 40-character hexadecimal string.")
        }
        # Validate ClientId
        if (-not $ClientId -or $ClientId -notmatch '^[0-9a-fA-F\-]{36}$') {
            throw [ArgumentException]::new("ClientId must be a valid GUID in the format 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'.")
        }
        # Validate TenantId
        if (-not $TenantId -or $TenantId -notmatch '^[0-9a-fA-F\-]{36}$') {
            throw [ArgumentException]::new("TenantId must be a valid GUID in the format 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'.")
        }
        # Validate OnMicrosoftUrl
        if (-not $OnMicrosoftUrl -or $OnMicrosoftUrl -notmatch '^[a-zA-Z0-9]+\.onmicrosoft\.com$') {
            throw [ArgumentException]::new("OnMicrosoftUrl must be in the format 'example.onmicrosoft.com'.")
        }
        # Validate SpAdminUrl
        if (-not $SpAdminUrl -or $SpAdminUrl -notmatch '^https:\/\/[a-zA-Z0-9\-]+\-admin\.sharepoint\.com$') {
            throw [ArgumentException]::new("SpAdminUrl must be in the format 'https://[name]-admin.sharepoint.com'.")
        }
        # Assign validated properties
        $this.ClientCertThumbPrint = $ClientCertThumbPrint
        $this.ClientId = $ClientId
        $this.TenantId = $TenantId
        $this.OnMicrosoftUrl = $OnMicrosoftUrl
        $this.SpAdminUrl = $SpAdminUrl
    }
}
