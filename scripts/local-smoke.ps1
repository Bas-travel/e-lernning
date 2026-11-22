<#
  Local smoke test: starts MySQL + API with Docker, waits until healthy, then
  exercises real endpoints against the real local database.
  Run from the repo root:  powershell -ExecutionPolicy Bypass -File scripts\local-smoke.ps1
  Local only: talks to http://localhost:8080 and never to any shared server.
#>
$ErrorActionPreference = 'Stop'
$api = 'http://localhost:8080/api/v1'

Push-Location (Join-Path $PSScriptRoot '..\ab-learning-api')
try {
  docker compose up --build -d
  if ($LASTEXITCODE -ne 0) { throw 'docker compose up failed' }
} finally { Pop-Location }

Write-Host 'Waiting for the API...' -NoNewline
$ok = $false
for ($i = 0; $i -lt 60; $i++) {
  try { Invoke-RestMethod "$api/health" | Out-Null; $ok = $true; break } catch { Start-Sleep 2; Write-Host '.' -NoNewline }
}
Write-Host ''
if (-not $ok) {
  Push-Location (Join-Path $PSScriptRoot '..\ab-learning-api')
  try { docker compose ps; docker compose logs api --tail 40 } finally { Pop-Location }
  throw 'API did not become healthy (see the logs above)'
}

function Check($name, [scriptblock]$body) {
  try { $r = & $body; Write-Host "PASS  $name"; return $r }
  catch { Write-Host "FAIL  $name -> $($_.Exception.Message)"; $script:failed = $true }
}
$script:failed = $false

Check 'health' { (Invoke-RestMethod "$api/health").status -eq 'ok' -or $(throw 'bad status') } | Out-Null
$login = Check 'login learner@ablearning.co' {
  Invoke-RestMethod "$api/auth/login" -Method Post -ContentType 'application/json' `
    -Body (@{ identifier = 'learner@ablearning.co'; password = 'Password123!' } | ConvertTo-Json)
}
$headers = @{ Authorization = "Bearer $($login.access_token)" }
$courses = Check 'GET /courses' { Invoke-RestMethod "$api/courses" }
Check 'courses not empty' { if (-not $courses) { throw 'no courses' } } | Out-Null
Check 'GET /courses/1' { Invoke-RestMethod "$api/courses/1" } | Out-Null
Check 'GET /courses/1/curriculum' { Invoke-RestMethod "$api/courses/1/curriculum" } | Out-Null
Check 'GET /home (auth)' { Invoke-RestMethod "$api/home" -Headers $headers } | Out-Null
Check 'GET /home without token is rejected' {
  try { Invoke-RestMethod "$api/home" | Out-Null; throw 'expected 401' } catch { if ($_.Exception.Message -eq 'expected 401') { throw } }
} | Out-Null

if ($script:failed) { Write-Host "`nSMOKE FAILED"; exit 1 }
Write-Host "`nSMOKE OK. Run the app:  cd ab_learning_app; flutter run -d chrome"
