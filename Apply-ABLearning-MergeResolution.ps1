[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$RepoPath
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath $RepoPath).Path
$gitRoot = (git -C $repo rev-parse --show-toplevel 2>$null).Trim()
if (-not $gitRoot) { throw "Not a Git repository: $repo" }
$gitRoot = (Resolve-Path -LiteralPath $gitRoot).Path
$resolved = Join-Path $PSScriptRoot 'resolved'
if (-not (Test-Path -LiteralPath $resolved -PathType Container)) { throw "Missing resolved folder: $resolved" }
if (-not (Test-Path -LiteralPath (Join-Path $gitRoot 'ab_learning_app\pubspec.yaml'))) { throw "Expected Flutter project not found under repository: $gitRoot" }
$targets = @(
  'README.md',
  'ab_learning_app/.gitignore', 'ab_learning_app/.metadata', 'ab_learning_app/README.md',
  'ab_learning_app/analysis_options.yaml', 'ab_learning_app/lib/core/router/app_router.dart',
  'ab_learning_app/lib/features/auth/data/auth_repository.dart',
  'ab_learning_app/lib/features/auth/presentation/login_screen.dart',
  'ab_learning_app/lib/features/auth/presentation/register_controller.dart',
  'ab_learning_app/lib/features/auth/presentation/register_screen.dart',
  'ab_learning_app/lib/features/auth/presentation/splash_screen.dart',
  'ab_learning_app/lib/features/course/presentation/course_detail_screen.dart',
  'ab_learning_app/lib/features/course/presentation/video_player_screen.dart',
  'ab_learning_app/lib/features/explore/presentation/explore_screen.dart',
  'ab_learning_app/lib/features/home/presentation/home_screen.dart',
  'ab_learning_app/pubspec.lock', 'ab_learning_app/test/core/api_test.dart',
  'ab_learning_app/test/features/sub_pages_test.dart', 'ab_learning_app/test/widget_test.dart'
)
foreach ($relative in $targets) {
  if (-not (Test-Path -LiteralPath (Join-Path $resolved $relative) -PathType Leaf)) {
    throw "Resolution package missing required file: $relative"
  }
}
$unmerged = @(git -C $gitRoot diff --name-only --diff-filter=U)
Write-Host "Repository: $gitRoot"
Write-Host "Git reports $($unmerged.Count) unmerged paths before applying."
Write-Host "This will replace $($targets.Count) files with the prepared resolution versions."
Write-Host "A backup ZIP will be created in your TEMP folder. No git add/commit/merge-continue will run."
$confirm = Read-Host 'Type APPLY to continue'
if ($confirm -cne 'APPLY') { Write-Host 'Cancelled; no files changed.'; exit 0 }
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $env:TEMP "AB-Learning-PreResolution-$stamp"
New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
foreach ($relative in $targets) {
  $source = Join-Path $gitRoot $relative
  if (Test-Path -LiteralPath $source -PathType Leaf) {
    $dest = Join-Path $backupRoot $relative
    New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
    Copy-Item -LiteralPath $source -Destination $dest
  }
}
$backupZip = "$backupRoot.zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($backupRoot, $backupZip)
foreach ($relative in $targets) {
  $dest = Join-Path $gitRoot $relative
  New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
  Copy-Item -LiteralPath (Join-Path $resolved $relative) -Destination $dest -Force
}
Write-Host "Applied resolution files. Backup: $backupZip" -ForegroundColor Green
$markerPattern = '^(<<<<<<< |=======$|>>>>>>> |\|\|\|\|\|\|\| )'
$found = @()
foreach ($relative in $targets) {
  $path = Join-Path $gitRoot $relative
  $hits = @(Select-String -LiteralPath $path -Pattern $markerPattern -ErrorAction SilentlyContinue)
  if ($hits.Count) { $found += $relative }
}
if ($found.Count) {
  Write-Warning "Conflict markers remain in: $($found -join ', ')"
} else {
  Write-Host 'No conflict markers found in the 19 prepared target files.' -ForegroundColor Green
}
Write-Host "`nNEXT — run these checks manually:" -ForegroundColor Cyan
Write-Host "  cd `"$gitRoot\ab_learning_app`""
Write-Host '  flutter pub get'
Write-Host '  dart format lib test'
Write-Host '  flutter analyze'
Write-Host '  flutter test'
Write-Host "`nDo not run git add or git merge --continue until checks pass and you review the diff."
