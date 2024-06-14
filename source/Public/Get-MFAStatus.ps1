<#
    .SYNOPSIS
        Retrieves the MFA (Multi-Factor Authentication) status for Azure Active Directory users.
    .DESCRIPTION
        The Get-MFAStatus function connects to Microsoft Online Service and retrieves the MFA status for all Azure Active Directory users, excluding guest accounts. Optionally, you can specify a single user by their User Principal Name (UPN) to get their MFA status.
    .PARAMETER UserId
        The User Principal Name (UPN) of a specific user to retrieve MFA status for. If not provided, the function retrieves MFA status for all users.
    .EXAMPLE
        Get-MFAStatus
        Retrieves the MFA status for all Azure Active Directory users.
    .EXAMPLE
        Get-MFAStatus -UserId "example@domain.com"
        Retrieves the MFA status for the specified user with the UPN "example@domain.com".
    .OUTPUTS
        System.Object
        Returns a sorted list of custom objects containing the following properties:
        - UserPrincipalName
        - DisplayName
        - MFAState
        - MFADefaultMethod
        - MFAPhoneNumber
        - PrimarySMTP
        - Aliases
    .NOTES
        The function requires the MSOL module to be installed and connected to your tenant.
        Ensure that you have the necessary permissions to read user and MFA status information.
    .LINK
    https://criticalsolutionsnetwork.github.io/M365FoundationsCISReport/#Get-MFAStatus
#>
function Get-MFAStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$UserId
    )

    begin {
        # Connect to Microsoft Online service
    }

    process {
        if (Get-Module MSOnline){
            Connect-MsolService
            Write-Host "Finding Azure Active Directory Accounts..."
            # Get all users, excluding guests
            $Users = if ($PSBoundParameters.ContainsKey('UserId')) {
                Get-MsolUser -UserPrincipalName $UserId
            } else {
                Get-MsolUser -All | Where-Object { $_.UserType -ne "Guest" }
            }
            $Report = [System.Collections.Generic.List[Object]]::new() # Create output list
            Write-Host "Processing" $Users.Count "accounts..."
            ForEach ($User in $Users) {
                $MFADefaultMethod = ($User.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq "True" }).MethodType
                $MFAPhoneNumber = $User.StrongAuthenticationUserDetails.PhoneNumber
                $PrimarySMTP = $User.ProxyAddresses | Where-Object { $_ -clike "SMTP*" } | ForEach-Object { $_ -replace "SMTP:", "" }
                $Aliases = $User.ProxyAddresses | Where-Object { $_ -clike "smtp*" } | ForEach-Object { $_ -replace "smtp:", "" }

                If ($User.StrongAuthenticationRequirements) {
                    $MFAState = $User.StrongAuthenticationRequirements.State
                }
                Else {
                    $MFAState = 'Disabled'
                }

                If ($MFADefaultMethod) {
                    Switch ($MFADefaultMethod) {
                        "OneWaySMS" { $MFADefaultMethod = "Text code authentication phone" }
                        "TwoWayVoiceMobile" { $MFADefaultMethod = "Call authentication phone" }
                        "TwoWayVoiceOffice" { $MFADefaultMethod = "Call office phone" }
                        "PhoneAppOTP" { $MFADefaultMethod = "Authenticator app or hardware token" }
                        "PhoneAppNotification" { $MFADefaultMethod = "Microsoft authenticator app" }
                    }
                }
                Else {
                    $MFADefaultMethod = "Not enabled"
                }

                $ReportLine = [PSCustomObject] @{
                    UserPrincipalName = $User.UserPrincipalName
                    DisplayName       = $User.DisplayName
                    MFAState          = $MFAState
                    MFADefaultMethod  = $MFADefaultMethod
                    MFAPhoneNumber    = $MFAPhoneNumber
                    PrimarySMTP       = ($PrimarySMTP -join ',')
                    Aliases           = ($Aliases -join ',')
                }

                $Report.Add($ReportLine)
            }

            Write-Host "Processing complete."
            return $Report | Select-Object UserPrincipalName, DisplayName, MFAState, MFADefaultMethod, MFAPhoneNumber, PrimarySMTP, Aliases | Sort-Object UserPrincipalName
        }
        else {
            Write-Host "You must first install MSOL using:`nInstall-Module MSOnline -Scope CurrentUser -Force"
        }
    }

}