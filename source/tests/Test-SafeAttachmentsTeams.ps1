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
        $params = @{
            Rec            = "2.1.5"
            Result         = $result
            Status         = if ($result) { "Pass" } else { "Fail" }
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

# Additional helper functions (if any)
