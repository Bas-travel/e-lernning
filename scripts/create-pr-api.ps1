<#
Create GitHub Pull Request
Repository: Bas-travel/e-lernning
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Branch,

    [Parameter(Mandatory = $true)]
    [string]$Base,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$BodyFile
)

$ErrorActionPreference = "Stop"

$repoOwner = "Bas-travel"
$repoName  = "e-lernning"
$repo       = "$repoOwner/$repoName"

# --------------------------------------------------
# Validate environment
# --------------------------------------------------

if (-not $env:GH_TOKEN) {
    Write-Error "GH_TOKEN is not set."
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not installed or not in PATH."
    exit 1
}

if (-not (Test-Path $BodyFile)) {
    Write-Error "Body file not found: $BodyFile"
    exit 1
}

$headers = @{
    Authorization          = "Bearer $env:GH_TOKEN"
    Accept                 = "application/vnd.github+json"
    "User-Agent"           = "AB-Learning-PR-Creator"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host ""
Write-Host "======================================"
Write-Host " AB LEARNING - CREATE PULL REQUEST"
Write-Host "======================================"
Write-Host ""

# --------------------------------------------------
# 1. Validate GitHub Token
# --------------------------------------------------

Write-Host "1. Validating GitHub token..."

try {
    $me = Invoke-RestMethod `
        -Uri "https://api.github.com/user" `
        -Method Get `
        -Headers $headers

    Write-Host "Authenticated as: $($me.login)"
}
catch {
    Write-Error "GitHub authentication failed."
    Write-Error $_.Exception.Message
    exit 1
}

# --------------------------------------------------
# 2. Check Repository
# --------------------------------------------------

Write-Host ""
Write-Host "2. Checking repository: $repo"

try {
    $repoInfo = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$repo" `
        -Method Get `
        -Headers $headers

    Write-Host "Repository found: $($repoInfo.full_name)"
}
catch {
    Write-Error "Repository not found or inaccessible."
    Write-Error $_.Exception.Message
    exit 1
}

# --------------------------------------------------
# 3. Push Branch
# --------------------------------------------------

Write-Host ""
Write-Host "3. Pushing branch: $Branch"

try {

    $credential = "x-access-token:$env:GH_TOKEN"

    $encodedCredential = [Convert]::ToBase64String(
        [Text.Encoding]::ASCII.GetBytes($credential)
    )

    $extraHeader = "Authorization: Basic $encodedCredential"

    Write-Host "Executing git push..."

    git -c "http.extraHeader=$extraHeader" `
        push origin "${Branch}:${Branch}"

    if ($LASTEXITCODE -ne 0) {
        throw "Git push failed with exit code $LASTEXITCODE"
    }

    Write-Host "Branch pushed successfully."

}
catch {

    Write-Host ""
    Write-Host "======================================"
    Write-Host " GIT PUSH FAILED"
    Write-Host "======================================"
    Write-Host ""

    Write-Host "Branch : $Branch"
    Write-Host "Remote : origin"
    Write-Host ""

    Write-Host "Error:"
    Write-Host $_.Exception.Message

    Write-Host ""
    Write-Host "Please run manually:"
    Write-Host ""
    Write-Host "git push origin $Branch"
    Write-Host ""

    exit 1
}

# --------------------------------------------------
# 4. Verify Base Branch
# --------------------------------------------------

Write-Host ""
Write-Host "4. Checking base branch: $Base"

try {
    $baseBranch = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$repo/branches/$Base" `
        -Method Get `
        -Headers $headers

    Write-Host "Base branch exists."
}
catch {
    Write-Error "Base branch '$Base' does not exist."
    exit 1
}

# --------------------------------------------------
# 5. Verify Head Branch
# --------------------------------------------------

Write-Host ""
Write-Host "5. Checking head branch: $Branch"

try {
    $headBranch = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$repo/branches/$Branch" `
        -Method Get `
        -Headers $headers

    Write-Host "Head branch exists."
    Write-Host "Head SHA: $($headBranch.commit.sha)"
}
catch {
    Write-Error "Head branch '$Branch' does not exist."
    exit 1
}

# --------------------------------------------------
# 6. Read PR Body
# --------------------------------------------------

Write-Host ""
Write-Host "6. Reading PR body..."

$body = Get-Content -Raw -Path $BodyFile

Write-Host "PR body loaded."

# --------------------------------------------------
# 7. Check Existing PR
# --------------------------------------------------

Write-Host ""
Write-Host "7. Checking for existing PR..."

try {

    $encodedHead = [System.Uri]::EscapeDataString(
        "$repoOwner`:$Branch"
    )

    $encodedBase = [System.Uri]::EscapeDataString(
        $Base
    )

    $existingUrl =
        "https://api.github.com/repos/$repo/pulls" +
        "?state=open" +
        "&head=$encodedHead" +
        "&base=$encodedBase"

    $existing = Invoke-RestMethod `
        -Uri $existingUrl `
        -Method Get `
        -Headers $headers

    if ($existing.Count -gt 0) {

        Write-Host ""
        Write-Host "An open PR already exists:"
        Write-Host $existing[0].html_url

        exit 0
    }

    Write-Host "No existing open PR found."
}
catch {
    Write-Warning "Could not check existing PR. Continuing..."
}

# --------------------------------------------------
# 8. Prepare PR Payload
# --------------------------------------------------

Write-Host ""
Write-Host "8. Preparing PR payload..."

try {

    Write-Host "   [8.1] Building payload object..."

    $payloadObject = @{
        title = [string]$Title
        head  = [string]$Branch
        base  = [string]$Base
        body  = [string]$body
        draft = $true
    }

    Write-Host "   [8.2] Converting payload to JSON..."

    $payload = $payloadObject | ConvertTo-Json -Depth 5 -Compress

    if ([string]::IsNullOrWhiteSpace($payload)) {
        throw "Payload JSON is empty."
    }

    Write-Host "   [8.3] Payload JSON created."
    Write-Host "   Payload size: $($payload.Length) characters"

}
catch {

    Write-Host ""
    Write-Host "======================================"
    Write-Host " PAYLOAD PREPARATION FAILED"
    Write-Host "======================================"
    Write-Host ""
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host ""
Write-Host "Repository : $repo"
Write-Host "Head       : $Branch"
Write-Host "Base       : $Base"
Write-Host "Draft      : true"
Write-Host ""

# --------------------------------------------------
# 9. Create Pull Request
# --------------------------------------------------

Write-Host "9. Creating draft PR..."
Write-Host "   Sending request to GitHub API..."

try {

    $apiUrl = "https://api.github.com/repos/$repo/pulls"

    Write-Host "   API: $apiUrl"

    $response = Invoke-RestMethod `
        -Uri $apiUrl `
        -Method Post `
        -Headers $headers `
        -ContentType "application/json; charset=utf-8" `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
        -TimeoutSec 30

    Write-Host ""
    Write-Host "======================================"
    Write-Host " PR CREATED SUCCESSFULLY"
    Write-Host "======================================"
    Write-Host ""

    Write-Host "PR Number : $($response.number)"
    Write-Host "Title     : $($response.title)"
    Write-Host "State     : $($response.state)"
    Write-Host "Draft     : $($response.draft)"
    Write-Host "URL       : $($response.html_url)"

    Write-Host ""

}
catch {

    Write-Host ""
    Write-Host "======================================"
    Write-Host " PR CREATION FAILED"
    Write-Host "======================================"
    Write-Host ""

    Write-Host "Exception:"
    Write-Host $_.Exception.Message

    if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
        Write-Host ""
        Write-Host "GitHub API Response:"
        Write-Host $_.ErrorDetails.Message
    }

    if ($_.Exception.Response) {

        try {

            $response = $_.Exception.Response

            $stream = $response.GetResponseStream()

            if ($stream) {

                $reader = New-Object System.IO.StreamReader($stream)

                $errorBody = $reader.ReadToEnd()

                $reader.Close()

                if ($errorBody) {

                    Write-Host ""
                    Write-Host "GitHub Response Body:"
                    Write-Host $errorBody
                }
            }

        }
        catch {
            Write-Warning "Unable to read API response body."
        }
    }

    Write-Host ""
    Write-Host "Payload:"
    Write-Host $payload

    exit 1
}