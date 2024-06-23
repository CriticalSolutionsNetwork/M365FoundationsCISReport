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
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $Rec
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
            $testNumbers = @('1.1.1', '1.1.3', '1.2.1', '1.3.1', '5.1.2.3', '5.1.8.1', '6.1.2', '6.1.3')
        #>
    }
    process {
        Write-Verbose "Get-CISMgOutput: Retuning data for Rec: $Rec"
        switch ($rec) {
            '1.1.1' {
                # 1.1.1
                $AdminRoleAssignmentsAndUsers = Get-AdminRoleUserAndAssignment
                return $AdminRoleAssignmentsAndUsers
            }
            '1.1.3' {
                # Step: Retrieve global admin role
                $globalAdminRole = Get-MgDirectoryRole -Filter "RoleTemplateId eq '62e90394-69f5-4237-9190-012177145e10'"
                # Step: Retrieve global admin members
                $globalAdmins = Get-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id
                return $globalAdmins
            }
            '1.2.1' {
                $allGroups = Get-MgGroup -All | Where-Object { $_.Visibility -eq "Public" } | Select-Object DisplayName, Visibility
                return $allGroups
            }
            '5.1.2.3' {
                # Retrieve the tenant creation policy
                $tenantCreationPolicy = (Get-MgPolicyAuthorizationPolicy).DefaultUserRolePermissions | Select-Object AllowedToCreateTenants
                return $tenantCreationPolicy
            }
            '5.1.8.1' {
                # Retrieve password hash sync status (Condition A and C)
                $passwordHashSync = Get-MgOrganization | Select-Object -ExpandProperty OnPremisesSyncEnabled
                return $passwordHashSync
            }
            '6.1.2' {
                $tenantSkus = Get-MgSubscribedSku -All
                $e3SkuPartNumber = "SPE_E3"
                $founde3Sku = $tenantSkus | Where-Object { $_.SkuPartNumber -eq $e3SkuPartNumber }
                if ($founde3Sku.Count -ne 0) {
                    $allE3Users = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($founde3Sku.SkuId) )" -All
                    return $allE3Users
                }
                else {
                    return $null
                }
            }
            '6.1.3' {
                $tenantSkus = Get-MgSubscribedSku -All
                $e5SkuPartNumber = "SPE_E5"
                $founde5Sku = $tenantSkus | Where-Object { $_.SkuPartNumber -eq $e5SkuPartNumber }
                if ($founde5Sku.Count -ne 0) {
                    $allE5Users = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($founde5Sku.SkuId) )" -All
                    return $allE5Users
                }
                else {
                    return $null
                }
            }
            default { throw "No match found for test: $Rec" }
        }
    }
    end {
        Write-Verbose "Retuning data for Rec: $Rec"
    }
} # end function Get-CISMgOutput

