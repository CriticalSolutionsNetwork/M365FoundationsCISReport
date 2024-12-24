function Get-CISMgOutput {
    <#
    .SYNOPSIS
    This is a sample Private function only visible within the module.
    .DESCRIPTION
    This sample function is not exported to the module and only return the data passed as parameter.
    .EXAMPLE
    $null = Get-CISMgOutput -PrivateData 'NOTHING TO SEE HERE'
    .PARAMETER PrivateData
    The PrivateData parameter is what will be returned without transformation.

#>
    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Rec,
        [Parameter(Mandatory = $false)]
        [String]$DomainName
    )
    begin {
        # Begin Block #
        # Tests
        <#
            1.1.1
            1.1.3
            1.2.1
            1.3.1
            5.1.2.3
            5.1.8.1
            6.1.2
            6.1.3
            # Test number array
            $testNumbers = @('1.1.1', '1.1.1-v4', '1.1.3', '1.2.1', '1.3.1', '5.1.2.3', '5.1.8.1', '6.1.2', '6.1.3', '1.1.4')
        #>
    }
    process {
        try {
            Write-Verbose "Get-CISMgOutput: Returning data for Rec: $Rec"
            switch ($rec) {
                '1.1.1' {
                    # 1.1.1 - MicrosoftGraphPlaceholder
                    # Test-AdministrativeAccountCompliance
                    $AdminRoleAssignmentsAndUsers = Get-AdminRoleUserAndAssignment
                    return $AdminRoleAssignmentsAndUsers
                }
                '1.1.1-v4' {
                    # 1.1.1-v4 - MicrosoftGraphPlaceholder
                    # Placeholder for the new v4 logic for Test-AdministrativeAccountCompliance
                }
                '1.1.4' {
                    # 1.1.4 - MicrosoftGraphPlaceholder
                    # Placeholder for Test-AdminAccountLicenses
                }
                '1.1.3' {
                    # Test-GlobalAdminsCount
                    # Step: Retrieve global admin role
                    $globalAdminRole = Get-MgDirectoryRole -Filter "RoleTemplateId eq '62e90394-69f5-4237-9190-012177145e10'"
                    # Step: Retrieve global admin members
                    $globalAdmins = Get-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id
                    return $globalAdmins
                }
                '1.2.1' {
                    # Test-ManagedApprovedPublicGroups
                    $allGroups = Get-MgGroup -All | Where-Object { $_.Visibility -eq "Public" } | Select-Object DisplayName, Visibility
                    return $allGroups
                }
                '1.2.2' {
                    # Test-BlockSharedMailboxSignIn.ps1
                    $users = Get-MgUser
                    return $users
                }
                '1.3.1' {
                    # Test-PasswordNeverExpirePolicy.ps1
                    $domains = if ($DomainName) {
                        Get-MgDomain -DomainId $DomainName
                    }
                    else {
                        Get-MgDomain
                    }
                    return $domains
                }
                '5.1.2.3' {
                    # Test-RestrictTenantCreation
                    # Retrieve the tenant creation policy
                    $tenantCreationPolicy = (Get-MgPolicyAuthorizationPolicy).DefaultUserRolePermissions | Select-Object AllowedToCreateTenants
                    return $tenantCreationPolicy
                }
                '5.1.8.1' {
                    # Test-PasswordHashSync
                    # Retrieve password hash sync status (Condition A and C)
                    $passwordHashSync = Get-MgOrganization | Select-Object -ExpandProperty OnPremisesSyncEnabled
                    return $passwordHashSync
                }
                '6.1.2' {
                    # Test-MailboxAuditingE3
                    $tenantSKUs = Get-MgSubscribedSku -All
                    $e3SkuPartNumber = "SPE_E3"
                    $foundE3Sku = $tenantSKUs | Where-Object { $_.SkuPartNumber -eq $e3SkuPartNumber }
                    if ($foundE3Sku.Count -ne 0) {
                        $allE3Users = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($foundE3Sku.SkuId) )" -All
                        return $allE3Users
                    }
                    else {
                        return $null
                    }
                }
                '6.1.3' {
                    # Test-MailboxAuditingE5
                    $tenantSKUs = Get-MgSubscribedSku -All
                    $e5SkuPartNumber = "SPE_E5"
                    $foundE5Sku = $tenantSKUs | Where-Object { $_.SkuPartNumber -eq $e5SkuPartNumber }
                    if ($foundE5Sku.Count -ne 0) {
                        $allE5Users = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($foundE5Sku.SkuId) )" -All
                        return $allE5Users
                    }
                    else {
                        return $null
                    }
                }
                default { throw "No match found for test: $Rec" }
            }
        }
        catch {
            throw "Get-CISMgOutput: `n$_"
        }
    }
    end {
        Write-Verbose "Returning data for Rec: $Rec"
    }
} # end function Get-CISMgOutput