$repoOwner = "CriticalSolutionsNetwork"
$repoName = "M365FoundationsCISReport"
$directoryPath = ".\source\tests"
$projectName = "Test Validation Project"

# Function to create GitHub issues
function Create-GitHubIssue {
    param (
        [string]$title,
        [string]$body,
        [string]$project
    )

    # Create the issue and add it to the specified project
    $issue = gh issue create --repo "$repoOwner/$repoName" --title "$title" --body "$body" --project "$project"
    return $issue
}

# Load test definitions from CSV
$testDefinitionsPath = ".\source\helper\TestDefinitions.csv"
$testDefinitions = Import-Csv -Path $testDefinitionsPath

# Iterate over each .ps1 file in the directory
Get-ChildItem -Path $directoryPath -Filter "*.ps1" | ForEach-Object {
    $fileName = $_.Name
    $testDefinition = $testDefinitions | Where-Object { $_.TestFileName -eq $fileName }

    if ($testDefinition) {
        $rec = $testDefinition.Rec
        $elevel = $testDefinition.ELevel
        $profileLevel = $testDefinition.ProfileLevel
        $ig1 = $testDefinition.IG1
        $ig2 = $testDefinition.IG2
        $ig3 = $testDefinition.IG3
        $connection = $testDefinition.Connection

        $issueTitle = "Rec: $rec - Validate $fileName, ELevel: $elevel, ProfileLevel: $profileLevel, IG1: $ig1, IG2: $ig2, IG3: $ig3, Connection: $connection"
        $issueBody = @"
# Validation for $fileName

## Tasks
- [ ] Validate test for a pass
  - Description of passing criteria:
- [ ] Validate test for a fail
  - Description of failing criteria:
- [ ] Add notes and observations
  - Placeholder for additional notes:
"@

        # Create the issue using GitHub CLI
        try {
            Create-GitHubIssue -title "$issueTitle" -body "$issueBody" -project "$projectName"
            Write-Output "Created issue for $fileName"
        }
        catch {
            Write-Error "Failed to create issue for $fileName`: $_"
        }

        # Introduce a delay of 2 seconds
        Start-Sleep -Seconds 2
    }
    else {
        Write-Warning "No matching test definition found for $fileName"
    }
}
######################################
$repoOwner = "CriticalSolutionsNetwork"
$repoName = "M365FoundationsCISReport"

# Function to update GitHub issue
function Update-GitHubTIssue {
    param (
        [int]$issueNumber,
        [string]$title,
        [string]$body,
        [string]$owner,
        [string]$repositoryName
    )

    # Update the issue using Set-GitHubIssue
    Set-GitHubIssue -OwnerName $owner -RepositoryName $repositoryName -Issue $issueNumber -Title $title -Body $body -Label @("documentation", "help wanted", "question") -Confirm:$false
}

# Load test definitions from CSV
$testDefinitionsPath = ".\source\helper\TestDefinitions.csv"
$testDefinitions = Import-Csv -Path $testDefinitionsPath

# Fetch existing issues that start with "Rec:"
$existingIssues = Get-GitHubIssue -OwnerName 'CriticalSolutionsNetwork' -RepositoryName 'M365FoundationsCISReport'

# Create a list to hold matched issues
$matchedIssues = @()
$warnings = @()

# Iterate over each existing issue
$existingIssues | ForEach-Object {
    $issueNumber = $_.Number
    $issueTitle = $_.Title
    $issueBody = $_.Body

    # Extract the rec number from the issue title
    if ($issueTitle -match "Rec: (\d+\.\d+\.\d+)") {
        $rec = $matches[1]

        # Find the matching test definition based on rec number
        $testDefinition = $testDefinitions | Where-Object { $_.Rec -eq $rec }

        if ($testDefinition) {
            # Create the new issue body
            $newIssueBody = @"
# Validation for $($testDefinition.TestFileName)

## Recommendation Details
- **Recommendation**: $($testDefinition.Rec)
- **Description**: $($testDefinition.RecDescription)
- **ELevel**: $($testDefinition.ELevel)
- **Profile Level**: $($testDefinition.ProfileLevel)
- **CIS Control**: $($testDefinition.CISControl)
- **CIS Description**: $($testDefinition.CISDescription)
- **Implementation Group 1**: $($testDefinition.IG1)
- **Implementation Group 2**: $($testDefinition.IG2)
- **Implementation Group 3**: $($testDefinition.IG3)
- **Automated**: $($testDefinition.Automated)
- **Connection**: $($testDefinition.Connection)

## [$($testDefinition.TestFileName)](https://github.com/CriticalSolutionsNetwork/M365FoundationsCISReport/blob/main/source/tests/$($testDefinition.TestFileName))

## Tasks

### Validate recommendation details
- [ ] Confirm that the recommendation details are accurate and complete as per the CIS benchmark.

### Validate test for a pass
- [ ] Confirm that the automated test results align with the manual audit steps outlined in the CIS benchmark.
  - Specific conditions to check:
    - Condition A: (Detail about what constitutes Condition A)
    - Condition B: (Detail about what constitutes Condition B)
    - Condition C: (Detail about what constitutes Condition C)

### Validate test for a fail
- [ ] Confirm that the failure conditions in the automated test are consistent with the manual audit results.
  - Specific conditions to check:
    - Condition A: (Detail about what constitutes Condition A)
    - Condition B: (Detail about what constitutes Condition B)
    - Condition C: (Detail about what constitutes Condition C)

### Add notes and observations
- [ ] Compare the automated audit results with the manual audit steps and provide detailed observations.
  - Automated audit produced info consistent with the manual audit test results? (Yes/No)
  - Without disclosing any sensitive information, document any discrepancies between the actual output and the expected output.
  - Document any error messages, removing any sensitive information before submitting.
  - Identify the specific function, line, or section of the script that failed, if known.
  - Provide any additional context or observations that might help in troubleshooting.

If needed, the helpers folder in .\source\helpers contains a CSV to assist with locating the test definition.
"@

            # Add to matched issues list
            $matchedIssues += [PSCustomObject]@{
                IssueNumber = $issueNumber
                Title = $issueTitle
                NewBody = $newIssueBody
            }
        } else {
            $warnings += "No matching test definition found for Rec: $rec"
        }
    } else {
        $warnings += "No matching rec number found in issue title #$issueNumber"
    }
}

# Display matched issues for confirmation
if ($matchedIssues.Count -gt 0) {
    Write-Output "Matched Issues:"
    $matchedIssues | ForEach-Object {
        Write-Output $_.Title
    }

    $confirmation = Read-Host "Do you want to proceed with updating these issues? (yes/no)"

    if ($confirmation -eq 'yes') {
        # Update the issues
        $matchedIssues | ForEach-Object {
            try {
                Update-GitHubTIssue -issueNumber $_.IssueNumber -title $_.Title -body $_.NewBody -owner $repoOwner -repositoryName $repoName
                Write-Output "Updated issue #$($_.IssueNumber)"
            } catch {
                Write-Error "Failed to update issue #$($_.IssueNumber): $_"
            }

            # Introduce a delay of 2 seconds
            Start-Sleep -Seconds 2
        }
    } else {
        Write-Output "Update canceled by user."
    }
} else {
    Write-Output "No matched issues found to update."
}

# Display any warnings that were captured
if ($warnings.Count -gt 0) {
    Write-Output "Warnings:"
    $warnings | ForEach-Object {
        Write-Output $_
    }
}

# Test command to verify GitHub access
Get-GitHubRepository -OwnerName 'CriticalSolutionsNetwork' -RepositoryName 'M365FoundationsCISReport'


#########################################################################################
connect-MgGraph -Scopes "Directory.Read.All", "Domain.Read.All", "Policy.Read.All", "Organization.Read.All" -NoWelcome
# Retrieve the subscribed SKUs
$sub = Get-MgSubscribedSku -All

# Define the product array
$ProductArray = @(
    "Microsoft_Cloud_App_Security_App_Governance_Add_On",
    "Defender_Threat_Intelligence",
    "THREAT_INTELLIGENCE",
    "WIN_DEF_ATP",
    "Microsoft_Defender_for_Endpoint_F2",
    "DEFENDER_ENDPOINT_P1",
    "DEFENDER_ENDPOINT_P1_EDU",
    "MDATP_XPLAT",
    "MDATP_Server",
    "ATP_ENTERPRISE_FACULTY",
    "ATA",
    "ATP_ENTERPRISE_GOV",
    "ATP_ENTERPRISE_USGOV_GCCHIGH",
    "THREAT_INTELLIGENCE_GOV",
    "TVM_Premium_Standalone",
    "TVM_Premium_Add_on",
    "ATP_ENTERPRISE",
    "Azure_Information_Protection_Premium_P1",
    "Azure_Information_Protection_Premium_P2",
    "Microsoft_Application_Protection_and_Governance",
    "Exchange_Online_Protection",
    "Microsoft_365_Defender",
    "Cloud_App_Security_Discovery"
)

# Define the hashtable
$ProductHashTable = @{
    "App governance add-on to Microsoft Defender for Cloud Apps" = "Microsoft_Cloud_App_Security_App_Governance_Add_On"
    "Defender Threat Intelligence" = "Defender_Threat_Intelligence"
    "Microsoft Defender for Office 365 (Plan 2)" = "THREAT_INTELLIGENCE"
    "Microsoft Defender for Endpoint" = "WIN_DEF_ATP"
    "Microsoft Defender for Endpoint F2" = "Microsoft_Defender_for_Endpoint_F2"
    "Microsoft Defender for Endpoint P1" = "DEFENDER_ENDPOINT_P1"
    "Microsoft Defender for Endpoint P1 for EDU" = "DEFENDER_ENDPOINT_P1_EDU"
    "Microsoft Defender for Endpoint P2_XPLAT" = "MDATP_XPLAT"
    "Microsoft Defender for Endpoint Server" = "MDATP_Server"
    "Microsoft Defender for Office 365 (Plan 1) Faculty" = "ATP_ENTERPRISE_FACULTY"
    "Microsoft Defender for Identity" = "ATA"
    "Microsoft Defender for Office 365 (Plan 1) GCC" = "ATP_ENTERPRISE_GOV"
    "Microsoft Defender for Office 365 (Plan 1)_USGOV_GCCHIGH" = "ATP_ENTERPRISE_USGOV_GCCHIGH"
    "Microsoft Defender for Office 365 (Plan 2) GCC" = "THREAT_INTELLIGENCE_GOV"
    "Microsoft Defender Vulnerability Management" = "TVM_Premium_Standalone"
    "Microsoft Defender Vulnerability Management Add-on" = "TVM_Premium_Add_on"
    "Microsoft Defender for Office 365 (Plan 1)" = "ATP_ENTERPRISE"
    "Azure Information Protection Premium P1" = "Azure_Information_Protection_Premium_P1"
    "Azure Information Protection Premium P2" = "Azure_Information_Protection_Premium_P2"
    "Microsoft Application Protection and Governance" = "Microsoft_Application_Protection_and_Governance"
    "Exchange Online Protection" = "Exchange_Online_Protection"
    "Microsoft 365 Defender" = "Microsoft_365_Defender"
    "Cloud App Security Discovery" = "Cloud_App_Security_Discovery"
}

# Reverse the hashtable
$ReverseProductHashTable = @{}
foreach ($key in $ProductHashTable.Keys) {
    $ReverseProductHashTable[$ProductHashTable[$key]] = $key
}

# Loop through each SKU and get the enabled security features
$securityFeatures = foreach ($sku in $sub) {
if ($sku.SkuPartNumber -eq "MDATP_XPLAT_EDU") {
Write-Host "the SKU is: `n$($sku  | gm)"
            [PSCustomObject]@{
            Skupartnumber      = $sku.skupartnumber
            AppliesTo          = $sku.AppliesTo
            ProvisioningStatus = $sku.ProvisioningStatus
            ServicePlanId      = $sku.ServicePlanId
            ServicePlanName    = $sku.ServicePlanName
            FriendlyName       = "Defender P2 for EDU"
        }
   }
   else {

       $sku.serviceplans | Where-Object { $_.serviceplanname -in $ProductArray } | ForEach-Object {
        $friendlyName = $ReverseProductHashTable[$_.ServicePlanName]
        [PSCustomObject]@{
            Skupartnumber      = $sku.skupartnumber
            AppliesTo          = $_.AppliesTo
            ProvisioningStatus = $_.ProvisioningStatus
            ServicePlanId      = $_.ServicePlanId
            ServicePlanName    = $_.ServicePlanName
            FriendlyName       = $friendlyName
        }
    }

   }

}

# Output the security features
$securityFeatures | Format-Table -AutoSize



##########

# Ensure the ImportExcel module is available


# Ensure the ImportExcel module is available
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Install-Module -Name ImportExcel -Force -Scope CurrentUser
}

# Function to wait until the file is available
function Wait-ForFile {
    param (
        [string]$FilePath
    )
    while (Test-Path -Path $FilePath -PathType Leaf -and -not (Get-Content $FilePath -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 1
    }
}

# Path to the Excel file
$excelFilePath = "C:\Users\dougrios\OneDrive - CRITICALSOLUTIONS NET LLC\Documents\_Tools\Benchies\SKUs.xlsx"

# Wait for the file to be available


# Import the Excel file
$excelData = Import-Excel -Path $excelFilePath

# Retrieve the subscribed SKUs
$subscribedSkus = Get-MgSubscribedSku -All

# Define the hashtable with security-related product names
$ProductHashTable = @{
    "App governance add-on to Microsoft Defender for Cloud Apps" = "Microsoft_Cloud_App_Security_App_Governance_Add_On"
    "Defender Threat Intelligence" = "Defender_Threat_Intelligence"
    "Microsoft Defender for Office 365 (Plan 2)" = "THREAT_INTELLIGENCE"
    "Microsoft Defender for Endpoint" = "WIN_DEF_ATP"
    "Microsoft Defender for Endpoint F2" = "Microsoft_Defender_for_Endpoint_F2"
    "Microsoft Defender for Endpoint P1" = "DEFENDER_ENDPOINT_P1"
    "Microsoft Defender for Endpoint P1 for EDU" = "DEFENDER_ENDPOINT_P1_EDU"
    "Microsoft Defender for Endpoint P2_XPLAT" = "MDATP_XPLAT"
    "Microsoft Defender for Endpoint Server" = "MDATP_Server"
    "Microsoft Defender for Office 365 (Plan 1) Faculty" = "ATP_ENTERPRISE_FACULTY"
    "Microsoft Defender for Identity" = "ATA"
    "Microsoft Defender for Office 365 (Plan 1) GCC" = "ATP_ENTERPRISE_GOV"
    "Microsoft Defender for Office 365 (Plan 1)_USGOV_GCCHIGH" = "ATP_ENTERPRISE_USGOV_GCCHIGH"
    "Microsoft Defender for Office 365 (Plan 2) GCC" = "THREAT_INTELLIGENCE_GOV"
    "Microsoft Defender Vulnerability Management" = "TVM_Premium_Standalone"
    "Microsoft Defender Vulnerability Management Add-on" = "TVM_Premium_Add_on"
    "Microsoft Defender for Office 365 (Plan 1)" = "ATP_ENTERPRISE"
    "Azure Information Protection Premium P1" = "Azure_Information_Protection_Premium_P1"
    "Azure Information Protection Premium P2" = "Azure_Information_Protection_Premium_P2"
    "Microsoft Application Protection and Governance" = "Microsoft_Application_Protection_and_Governance"
    "Exchange Online Protection" = "Exchange_Online_Protection"
    "Microsoft 365 Defender" = "Microsoft_365_Defender"
    "Cloud App Security Discovery" = "Cloud_App_Security_Discovery"
}

# Create a hashtable to store the SKU part numbers and their associated security features
$skuSecurityFeatures = @{}

# Populate the hashtable with data from the Excel file
foreach ($row in $excelData) {
    if ($null -ne $row.'String ID' -and $null -ne $row.'Service plans included (friendly names)') {
        $skuSecurityFeatures[$row.'String ID'] = $row.'Service plans included (friendly names)'
    }
}

# Display the SKU part numbers and their associated security features
foreach ($sku in $subscribedSkus) {
    $skuPartNumber = $sku.SkuPartNumber
    if ($skuSecurityFeatures.ContainsKey($skuPartNumber)) {
        $securityFeatures = $skuSecurityFeatures[$skuPartNumber]

        # Check if the security feature is in the hashtable
        $isSecurityFeature = $ProductHashTable.ContainsKey($securityFeatures)

        if ($isSecurityFeature) {
            Write-Output "SKU Part Number: $skuPartNumber"
            Write-Output "Security Features: $securityFeatures (Security-related)"
        } else {
            Write-Output "SKU Part Number: $skuPartNumber"
            Write-Output "Security Features: $securityFeatures"
        }
        Write-Output "----------------------------"
    } else {
        Write-Output "SKU Part Number: $skuPartNumber"
        Write-Output "Security Features: Not Found in Excel"
        Write-Output "----------------------------"
    }
}
