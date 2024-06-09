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


