function Test-SafeAttachmentsTeams {
    [CmdletBinding()]
    param (
        # Aligned
        # Parameters can be added if needed
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed
    }

    process {
        # 2.1.5 (L2) Ensure Safe Attachments for SharePoint, OneDrive, and Microsoft Teams is Enabled

        # Retrieve the ATP policies for Office 365 and check Safe Attachments settings
        $atpPolicies = Get-AtpPolicyForO365

        # Check if the required ATP policies are enabled
        $atpPolicyResult = $atpPolicies | Where-Object {
            $_.EnableATPForSPOTeamsODB -eq $true -and
            $_.EnableSafeDocs -eq $true -and
            $_.AllowSafeDocsOpen -eq $false
        }

        # Determine the result based on the ATP policy settings
        $result = $null -ne $atpPolicyResult
        $details = if ($result) {
            "ATP for SharePoint, OneDrive, and Teams is enabled with correct settings."
        }
        else {
            "ATP for SharePoint, OneDrive, and Teams is not enabled with correct settings."
        }

        $failureReasons = if ($result) {
            "N/A"
        }
        else {
            "ATP policy for SharePoint, OneDrive, and Microsoft Teams is not correctly configured."
        }

        # Create and populate the CISAuditResult object
        $auditResult = [CISAuditResult]::new()
        $auditResult.Status = if ($result) { "Pass" } else { "Fail" }
        $auditResult.ELevel = "E5"
        $auditResult.ProfileLevel = "L2"
        $auditResult.Rec = "2.1.5"
        $auditResult.RecDescription = "Ensure Safe Attachments for SharePoint, OneDrive, and Microsoft Teams is Enabled"
        $auditResult.CISControlVer = "v8"
        $auditResult.CISControl = "9.7, 10.1"
        $auditResult.CISDescription = "Deploy and Maintain Email Server Anti-Malware Protections, Deploy and Maintain Anti-Malware Software"
        $auditResult.IG1 = $true
        $auditResult.IG2 = $true
        $auditResult.IG3 = $true
        $auditResult.Result = $result
        $auditResult.Details = $details
        $auditResult.FailureReason = $failureReasons
    }

    end {
        # Return the audit result
        return $auditResult
    }
}

# Additional helper functions (if any)
