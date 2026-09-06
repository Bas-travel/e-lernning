<#
.SYNOPSIS
Create a GitHub pull request using the REST API and a Personal Access Token.

USAGE
Set environment variable GH_TOKEN to a token with `repo` scope, then run from
the repository root:

    $env:GH_TOKEN = 'ghp_...'
    pwsh .\scripts\create-pr-api.ps1 -Branch 'design/tokens-update' -Base 'main' -Title 'Update design tokens and sync Flutter theme' -BodyFile 'deployments/PRs/0001-update-design-tokens.md'

The script will attempt to push the branch first (`git push -u origin <branch>`).
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Branch,
    [Parameter(Mandatory=$true)]
    [string]$Base,
    [Parameter(Mandatory=$true)]
    [string]$Title,
    [Parameter(Mandatory=$true)]
    [string]$BodyFile
)

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git is not installed or not in PATH. Install Git and retry."
    exit 1
}

if (-not $env:GH_TOKEN) {
    Write-Error "GH_TOKEN environment variable is not set. Create a GitHub PAT with 'repo' scope and set GH_TOKEN."
    exit 1
}

Write-Host "Validating GH token..."
try {
    $me = Invoke-RestMethod -Uri 'https://api.github.com/user' -Headers @{ Authorization = "token $env:GH_TOKEN"; 'User-Agent' = 'create-pr-script' }
    Write-Host "Authenticated as $($me.login)"
} catch {
    Write-Error "GH_TOKEN invalid or unauthorized (need 'repo' scope). API response: $($_.Exception.Message)"
    exit 1
}

# Push via HTTPS to avoid SSH host fingerprint prompts
$repo = 'Bas-travel/e-lernning'
$remoteHttps = "https://github.com/$repo.git"
Write-Host "Pushing branch '$Branch' to $remoteHttps ..."
$pair = "$($Branch):$($Branch)"

# Try pushing by supplying an Authorization header so git doesn't prompt for credentials
try {
    $credString = "x-access-token:$env:GH_TOKEN"
    $b64 = [Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credString))
    $extra = "Authorization: Basic $b64"
    $push = git -c http.extraHeader="$extra" push $remoteHttps $pair 2>&1
    if ($LASTEXITCODE -ne 0) { throw $push }
}
catch {
    Write-Warning "Push with header failed: $_"
    Write-Host "Attempting fallback: embed token into remote URL (temporary)..."
    # Fallback: embed token into URL. Note: this exposes token in command; avoid long-term.
    $encodedToken = [System.Uri]::EscapeDataString($env:GH_TOKEN)
    $remoteWithToken = "https://x-access-token:$encodedToken@github.com/$Owner/$Repo.git"
    $push = git push $remoteWithToken $pair 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to push branch to $remoteHttps. Output:`n$push`n
Hint: ensure you have network access and the remote repository exists and your PAT has push rights (repo scope). If you prefer not to allow the script to embed tokens, configure a credential helper or install the GitHub CLI and run 'gh auth login'. You can try pushing manually using:`n git push $remoteWithToken $pair"
        exit $LASTEXITCODE
    }
}

if (-not (Test-Path $BodyFile)) {
    Write-Error "Body file '$BodyFile' not found."
    exit 1
}

$bodyText = Get-Content -Raw -Path $BodyFile

$payload = @{
    title = $Title
    head  = $Branch
    base  = $Base
    body  = $bodyText
    draft = $true
} | ConvertTo-Json -Depth 6

Write-Host "Preparing PR payload..."
$url = "https://api.github.com/repos/$repo/pulls"

Write-Host "Creating PR (draft) at $url ..."
try {
    $resp = Invoke-RestMethod -Uri $url -Method Post -Body $payload -Headers @{ Authorization = "token $env:GH_TOKEN"; 'User-Agent' = 'create-pr-script' } -ContentType 'application/json'
    Write-Host "PR created: $($resp.html_url)"
} catch {
    Write-Error "PR creation failed: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $text = $reader.ReadToEnd(); $reader.Close()
        Write-Error $text
    }
    exit 1
}
