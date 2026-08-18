# Publish the Aqua plugin to npm as `dsh-client-ui-aqua-unofficial`.
# The manifest already carries the final name, the dsh.bundle.patch layer,
# and the files list; staging only strips devDependencies (workspace links
# must never ship) and then publishes the pre-built lib/ bundle.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\publish.ps1          # publish
#   powershell -ExecutionPolicy Bypass -File .\publish.ps1 -DryRun  # inspect only

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$stage = Join-Path $root '.npm-stage'

# ---------- 1. stage ----------
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

Copy-Item (Join-Path $root 'lib') -Destination $stage -Recurse
Copy-Item (Join-Path $root 'cordis.patch.yml') -Destination $stage
foreach ($name in 'README.md', 'README.zh.md', 'LICENSE') {
    $src = Join-Path $root $name
    if (Test-Path $src) { Copy-Item $src -Destination $stage }
}

# ---------- 2. manifest ----------
$json = Get-Content (Join-Path $root 'package.json') -Raw
# devDependencies are workspace links - never ship them (strip wherever they sit).
$json = $json -replace ',\s*"devDependencies":\s*\{[^{}]*\}', ''
[System.IO.File]::WriteAllText((Join-Path $stage 'package.json'), $json, [System.Text.UTF8Encoding]::new($false))

$name = ([regex]::Match($json, '"name":\s*"([^"]+)"')).Groups[1].Value
$version = ([regex]::Match($json, '"version":\s*"([^"]+)"')).Groups[1].Value
Write-Host "staged: $stage"
Write-Host "name: $name @ $version"

# ---------- 3. publish ----------
if ($DryRun) {
    Push-Location $stage
    try { npm publish --dry-run } finally { Pop-Location }
    return
}
Push-Location $stage

try {
    npm publish
    if ($LASTEXITCODE -ne 0) { throw 'npm publish failed' }
} finally {
    Pop-Location
}
Write-Host ''
Write-Host 'Done. Install anywhere with:' -ForegroundColor Green
Write-Host "  dsh plugin --profile web add dsh-client-ui-aqua-unofficial" -ForegroundColor Cyan
