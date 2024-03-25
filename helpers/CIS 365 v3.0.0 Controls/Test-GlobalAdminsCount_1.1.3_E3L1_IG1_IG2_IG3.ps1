function Test-GlobalAdminsCount_1.1.3_E3L1_IG1_IG2_IG3 {
    [CmdletBinding()]
    param (
        # Define your parameters here
    )

    begin {
        # Dot source the class script
        . ".\source\Classes\CISAuditResult.ps1"
        $auditResults = @()
    }

    process {
        # 1.1.3 (L1) Ensure that between two and four global admins are designated
        # Pass if the count of global admins is between 2 and 4. Fail otherwise.

        $globalAdminRole = Get-MgDirectoryRole -Filter "RoleTemplateId eq '62e90394-69f5-4237-9190-012177145e10'"
        $globalAdmins = Get-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id
        $globalAdminCount = $globalAdmins.AdditionalProperties.Count
        $globalAdminUsernames = ($globalAdmins | ForEach-Object { $_.AdditionalProperties["displayName"] }) -join ', '

        # Create an instance of CISAuditResult and populate it
        $auditResult = [CISAuditResult]::new()
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "5.1"
        $auditResult.CISDescription = "Establish and Maintain an Inventory of Accounts"
        $auditResult.Rec = "1.1.3"
        $auditResult.ELevel = "E3" # Based on your environment (E3, E5, etc.)
        $auditResult.Profile = "L1"
        $auditResult.IG1 = $true # Set based on the benchmark
        $auditResult.IG2 = $true # Set based on the benchmark
        $auditResult.IG3 = $true # Set based on the benchmark
        $auditResult.RecDescription = "Ensure that between two and four global admins are designated"
        $auditResult.Result = $globalAdminCount -ge 2 -and $globalAdminCount -le 4
        $auditResult.Details = "Count: $globalAdminCount; Users: $globalAdminUsernames"
        $auditResult.FailureReason = if ($globalAdminCount -lt 2) { "Less than 2 global admins: $globalAdminUsernames" } elseif ($globalAdminCount -gt 4) { "More than 4 global admins: $globalAdminUsernames" } else { "N/A" }
        $auditResult.Status = if ($globalAdminCount -ge 2 -and $globalAdminCount -le 4) { "Pass" } else { "Fail" }

        $auditResults += $auditResult
    }

    end {
        # Return auditResults
        return $auditResults
    }
}
