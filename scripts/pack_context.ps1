# Repomix Context Packager Script
$ErrorActionPreference = "Stop"

Write-Host "=== [Repomix] Packaging Workspace Context ===" -ForegroundColor Cyan

# Verify npx
try {
    $npxVersion = npx --version
    Write-Host "[OK] npx version: $npxVersion" -ForegroundColor Green
} catch {
    Write-Error "[FAIL] npx not found. Please install Node.js."
    exit 1
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$configFile = Join-Path $repoRoot "repomix.config.json"
$outputFile = Join-Path $repoRoot "repomix-output.xml"

Write-Host "[RUN] Executing repomix with config: $configFile" -ForegroundColor Yellow
npx --yes repomix --config "$configFile"

if (Test-Path "$outputFile") {
    $fileItem = Get-Item "$outputFile"
    $sizeKb = [math]::Round($fileItem.Length / 1KB, 2)
    Write-Host "[SUCCESS] Context package created successfully!" -ForegroundColor Green
    Write-Host "  - Path: $outputFile" -ForegroundColor Gray
    Write-Host "  - Size: $sizeKb KB" -ForegroundColor Gray
    Write-Host "  - Hint: Agent can read this file directly for project-wide context." -ForegroundColor Cyan
} else {
    Write-Error "[FAIL] Output file was not generated."
    exit 1
}
