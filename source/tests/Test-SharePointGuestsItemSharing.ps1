function Test-SharePointGuestsItemSharing {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Define your parameters here
    )

    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Initialization code, if needed

        $recnum = "7.2.5"

        # Conditions for 7.2.5 (L2) Ensure that SharePoint guest users cannot share items they don't own
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: The SharePoint setting "PreventExternalUsersFromResharing" is set to `True` using PowerShell.
        #   - Condition B: The SharePoint admin center setting "Allow guests to share items they don't own" is unchecked.
        #   - Condition C: Ensure that external users cannot re-share items they don't own.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: The SharePoint setting "PreventExternalUsersFromResharing" is set to `False` using PowerShell.
        #   - Condition B: The SharePoint admin center setting "Allow guests to share items they don't own" is checked.
        #   - Condition C: Ensure that external users can re-share items they don't own.
    }

    process {
        try {
            # 7.2.5 (L2) Ensure that SharePoint guest users cannot share items they don't own
            $SPOTenant = Get-CISSpoOutput -Rec $recnum
            $isGuestResharingPrevented = $SPOTenant.PreventExternalUsersFromResharing

            # Populate the auditResult object with the required properties
            $params = @{
                Rec           = $recnum
                Result        = $isGuestResharingPrevented
                Status        = if ($isGuestResharingPrevented) { "Pass" } else { "Fail" }
                Details       = "PreventExternalUsersFromResharing: $isGuestResharingPrevented"
                FailureReason = if (-not $isGuestResharingPrevented) { "Guest users can reshare items they don't own." } else { "N/A" }
            }
            $auditResult = Initialize-CISAuditResult @params
        }
        catch {
            $LastError = $_
            $auditResult = Get-TestError -LastError $LastError -recnum $recnum
        }
    }

    end {
        # Return auditResult
        return $auditResult
    }
}
