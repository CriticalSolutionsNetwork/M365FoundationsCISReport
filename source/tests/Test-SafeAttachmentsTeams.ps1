function Test-SafeAttachmentsTeams {
    [CmdletBinding()]
    [OutputType([CISAuditResult])]
    param (
        # Aligned
        # Parameters can be added if needed
    )
    begin {
        # Dot source the class script if necessary
        #. .\source\Classes\CISAuditResult.ps1
        # Conditions for 2.1.5 (L2) Ensure Safe Attachments for SharePoint, OneDrive, and Microsoft Teams is Enabled
        #
        # Validate test for a pass:
        # - Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
        # - Specific conditions to check:
        #   - Condition A: Safe Attachments for SharePoint is enabled.
        #   - Condition B: Safe Attachments for OneDrive is enabled.
        #   - Condition C: Safe Attachments for Microsoft Teams is enabled.
        #
        # Validate test for a fail:
        # - Confirm that the failure conditions in the automated test are consistent with the manual audit results.
        # - Specific conditions to check:
        #   - Condition A: Safe Attachments for SharePoint is not enabled.
        #   - Condition B: Safe Attachments for OneDrive is not enabled.
        #   - Condition C: Safe Attachments for Microsoft Teams is not enabled.
        # Initialization code, if needed
        $recnum = "2.1.5"
        Write-Verbose "Running Test-SafeAttachmentsTeams for $recnum..."
    }
    process {
        # $atpPolicyResult Mock Object
        <#
            $atpPolicyResult = @(
                [PSCustomObject]@{
                    Name                   = "Default"
                    EnableATPForSPOTeamsODB = $true
                    EnableSafeDocs         = $true
                    AllowSafeDocsOpen      = $false
                }
            )
        #>
        $atpPolicyResult = Get-CISExoOutput -Rec $recnum
        if ($atpPolicyResult -ne 1) {
            try {
                # Condition A: Check Safe Attachments for SharePoint
                # Condition B: Check Safe Attachments for OneDrive
                # Condition C: Check Safe Attachments for Microsoft Teams
                # Determine the result based on the ATP policy settings
                $result = $null -ne $atpPolicyResult
                #$atpPolicyResult | Where-Object { $_.Identity -eq "Default" }
                if ($result) {
                    $detailpass = [PSCustomObject]@{
                        Name                    = $atpPolicyResult.Name
                        EnableATPForSPOTeamsODB = $atpPolicyResult.EnableATPForSPOTeamsODB
                        EnableSafeDocs          = $atpPolicyResult.EnableSafeDocs
                        AllowSafeDocsOpen       = $atpPolicyResult.AllowSafeDocsOpen
                    }
                    $detailsString = $detailpass | ForEach-Object {
                        @"
Name: $($_.Name)
EnableATPForSPOTeamsODB: $($_.EnableATPForSPOTeamsODB)
EnableSafeDocs: $($_.EnableSafeDocs)
AllowSafeDocsOpen: $($_.AllowSafeDocsOpen)
`n
"@
                    }
                }
                $details = if ($result) {
                    $detailsString
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
                    Rec           = $recnum
                    Result        = $result
                    Status        = if ($result) { "Pass" } else { "Fail" }
                    Details       = $details
                    FailureReason = $failureReasons
                }
                $auditResult = Initialize-CISAuditResult @params
            }
            catch {
                Write-Error "An error occurred during the test $recnum`:: $_"
                # Retrieve the description from the test definitions
                $testDefinition = $script:TestDefinitionsObject | Where-Object { $_.Rec -eq $recnum }
                $description = if ($testDefinition) { $testDefinition.RecDescription } else { "Description not found" }
                $script:FailedTests.Add([PSCustomObject]@{ Rec = $recnum; Description = $description; Error = $_ })
                # Call Initialize-CISAuditResult with error parameters
                $auditResult = Initialize-CISAuditResult -Rec $recnum -Failure
            }
        }
        else {
            $params = @{
                Rec           = $recnum
                Result        = $false
                Status        = "Fail"
                Details       = "No M365 E5 licenses found."
                FailureReason = "The audit is for M365 E5 licenses and the required EXO commands will not be available otherwise."
            }
            $auditResult = Initialize-CISAuditResult @params
        }
    }
    end {
        # Return the audit result
        return $auditResult
    }
}