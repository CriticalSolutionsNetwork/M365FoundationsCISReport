function Test-GlobalAdminsCount {
    [CmdletBinding()]
    param (
        # Aligned
        # Define your parameters here if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1

        # Initialization code, if needed
    }

    process {
        # 1.1.3 (L1) Ensure that between two and four global admins are designated

        # Retrieve global admin role and members
        $globalAdminRole = Get-MgDirectoryRole -Filter "RoleTemplateId eq '62e90394-69f5-4237-9190-012177145e10'"
        $globalAdmins = Get-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id
        $globalAdminCount = $globalAdmins.AdditionalProperties.Count
        $globalAdminUsernames = ($globalAdmins | ForEach-Object { $_.AdditionalProperties["displayName"] }) -join ', '

        # Prepare failure reasons and details based on compliance
        $failureReasons = if ($globalAdminCount -lt 2) {
            "Less than 2 global admins: $globalAdminUsernames"
        }
        elseif ($globalAdminCount -gt 4) {
            "More than 4 global admins: $globalAdminUsernames"
        }
        else {
            "N/A"
        }

        $details = "Count: $globalAdminCount; Users: $globalAdminUsernames"

        # Create and populate the CISAuditResult object
        $params = @{
            Rec            = "1.1.3"
            Result         = $globalAdminCount -ge 2 -and $globalAdminCount -le 4
            Status         = if ($globalAdminCount -ge 2 -and $globalAdminCount -le 4) { "Pass" } else { "Fail" }
            Details        = $details
            FailureReason  = $failureReasons
        }
        $auditResult = Initialize-CISAuditResult @params
    }

    end {
        # Return the audit result
        return $auditResult
    }
}
