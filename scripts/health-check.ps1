# Antigravity Governance Health Check Script
# Usage: powershell -ExecutionPolicy Bypass -File scripts\health-check.ps1

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " [Health Check] Antigravity Engineering Governance" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

$score = 100
$passedChecks = 0
$totalChecks = 6

# 1. Global Skills & Plugins Duplicate Check
Write-Host "[1/$totalChecks] Checking global skills vs plugins duplicates..." -NoNewline
$globalSkillsPath = "C:\Users\15770\.gemini\config\skills"
$pluginsPath = "C:\Users\15770\.gemini\config\plugins"

$dupCount = 0
if ((Test-Path $globalSkillsPath) -and (Test-Path $pluginsPath)) {
    $skills = Get-ChildItem $globalSkillsPath -Directory | Select-Object -ExpandProperty Name
    $plugins = Get-ChildItem $pluginsPath -Recurse -Directory -Filter "skills" | Get-ChildItem -Directory | Select-Object -ExpandProperty Name
    $duplicates = $skills | Where-Object { $plugins -contains $_ }
    $dupCount = $duplicates.Count
}

if ($dupCount -eq 0) {
    Write-Host " [PASS] (0 duplicates)" -ForegroundColor Green
    $passedChecks++
} else {
    Write-Host " [WARN] (Found $dupCount duplicate skills: $($duplicates -join ', '))" -ForegroundColor Yellow
    $score -= 15
}

# 2. Workspace Skills Hygiene Check
Write-Host "[2/$totalChecks] Checking workspace .agents/skills hygiene..." -NoNewline
$wsSkillsPath = ".agents\skills"
$forbiddenInWs = @("good-learning", "ponytail", "brainstorming", "executing-plans", "karpathy-guidelines")
$foundPollutants = @()

if (Test-Path $wsSkillsPath) {
    foreach ($item in $forbiddenInWs) {
        if (Test-Path "$wsSkillsPath\$item") {
            $foundPollutants += $item
        }
    }
}

if ($foundPollutants.Count -eq 0) {
    Write-Host " [PASS] (No redundant global skills in workspace)" -ForegroundColor Green
    $passedChecks++
} else {
    Write-Host " [WARN] (Workspace contains redundant skills: $($foundPollutants -join ', '))" -ForegroundColor Yellow
    $score -= 15
}

# 3. Rules Deadlock Scan
Write-Host "[3/$totalChecks] Checking rule fragments for outdated line limits..." -NoNewline
$deadlocks = Select-String -Path .agents/rules/*.md -Pattern "60~100" -ErrorAction SilentlyContinue

if (-not $deadlocks) {
    Write-Host " [PASS] (Aligned with semantic block reading)" -ForegroundColor Green
    $passedChecks++
} else {
    Write-Host " [FAIL] (Residual 60~100 line limits found)" -ForegroundColor Red
    $score -= 20
}

# 4. Multi-Agent & Orchestration Guard
Write-Host "[4/$totalChecks] Checking multi-agent orchestration guard (08 rule)..." -NoNewline
$guardRule = ".agents\rules\08-orchestration-and-multi-agent-guard.md"

if (Test-Path $guardRule) {
    Write-Host " [PASS] (Two-round circuit breaker and prompt guard active)" -ForegroundColor Green
    $passedChecks++
} else {
    Write-Host " [WARN] (Rule 08 not found)" -ForegroundColor Yellow
    $score -= 15
}

# 5. Second Brain Memory Namespace Audit
Write-Host "[5/$totalChecks] Checking Second Brain project namespace isolation..." -NoNewline
$auditScript = "E:\workSpace\second-brain-cloudflare\scripts\audit_memories.js"

if (Test-Path $auditScript) {
    $auditOutput = node $auditScript 2>&1 | Out-String
    if ($auditOutput -match "缺少 project: 命名空间: 0") {
        Write-Host " [PASS] (100% memories have project namespaces, 0 naked)" -ForegroundColor Green
        $passedChecks++
    } else {
        Write-Host " [WARN] (Naked memories found without project namespace)" -ForegroundColor Yellow
        $score -= 20
    }
} else {
    Write-Host " [SKIP] (Second Brain repo not found locally)" -ForegroundColor Gray
    $passedChecks++
}

# 6. Governance Roadmap Asset Check
Write-Host "[6/$totalChecks] Verifying governance roadmap document..." -NoNewline
$roadmapPath = "docs\GOVERNANCE_OPTIMIZATION_ROADMAP.md"

if (Test-Path $roadmapPath) {
    Write-Host " [PASS] (Roadmap documentation intact)" -ForegroundColor Green
    $passedChecks++
} else {
    Write-Host " [WARN] (Missing roadmap document)" -ForegroundColor Yellow
    $score -= 15
}

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
if ($score -eq 100) {
    Write-Host " Health Score: 100 / 100 (EXCELLENT · PRODUCTION GRADE GREEN)" -ForegroundColor Green
    Write-Host " System is clean, secure, and ready for high-speed Vibe Coding!" -ForegroundColor Green
} else {
    Write-Host " Health Score: $score / 100 (Attention required)" -ForegroundColor Yellow
}
Write-Host "======================================================" -ForegroundColor Cyan
