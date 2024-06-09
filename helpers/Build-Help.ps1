Import-Module .\output\module\M365FoundationsCISReport\*\*.psd1
.\helpers\psDoc-master\src\psDoc.ps1 -moduleName M365FoundationsCISReport -outputDir docs -template ".\helpers\psDoc-master\src\out-html-template.ps1"
.\helpers\psDoc-master\src\psDoc.ps1 -moduleName M365FoundationsCISReport -outputDir ".\" -template ".\helpers\psDoc-master\src\out-markdown-template.ps1" -fileName ".\README.md"


<#
    $ver = "v0.1.8"
    git checkout main
    git pull origin main
    git tag -a $ver -m "Release version $ver refactor Update"
    git push origin $ver
    "Fix: PR #37"
    git push origin $ver
    # git tag -d $ver
#>

# Refresh authentication to ensure the correct scopes
gh auth refresh -s project,read:project,write:project,repo

# Create the project
gh project create --owner CriticalSolutionsNetwork --title "Test Validation Project"

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
        } catch {
            Write-Error "Failed to create issue for $fileName : $_"
        }

        # Introduce a delay of 2 seconds
        Start-Sleep -Seconds 2
    } else {
        Write-Warning "No matching test definition found for $fileName"
    }
}
