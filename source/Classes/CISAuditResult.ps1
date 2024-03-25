class CISAuditResult {
    [string]$Status
    [string]$ELevel
    [string]$ProfileLevel
    [string]$Rec
    [string]$RecDescription
    [string]$CISControlVer = 'v8'
    [string]$CISControl
    [string]$CISDescription
    [bool]$IG1
    [bool]$IG2
    [bool]$IG3
    [bool]$Result
    [string]$Details
    [string]$FailureReason
}
