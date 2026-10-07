param(
    [switch]$CheckOnly
)

# tools/rollback_gemini_storage.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "反重力 (Antigravity) 目录联接撤销与还原工具"

Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host "           反重力 (Antigravity) 传送门安全撤销与还原向导              " -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host ""

$sourceDir = [System.IO.Path]::Combine($env:USERPROFILE, ".gemini")
$targetDir = "E:\GeminiData\.gemini"
$backupDir = [System.IO.Path]::Combine($env:USERPROFILE, ".gemini_backup")

# 1. 检查进程
function Test-AntigravityRunning {
    $p1 = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue
    $p2 = Get-Process -Name "language_server" -ErrorAction SilentlyContinue
    return ($null -ne $p1 -or $null -ne $p2)
}

Write-Host "[1/3] 正在检查反重力核心进程状态..." -ForegroundColor Yellow

if ($CheckOnly) {
    if (Test-AntigravityRunning) {
        Write-Host " - [安全拦截机制验证] 成功检测到反重力核心进程正在运行，拦截防护机制生效！" -ForegroundColor Green
    } else {
        Write-Host " - 进程检查通过：反重力软件未运行。" -ForegroundColor Green
    }
    Write-Host "[预检模式] 预检结束，未修改任何磁盘数据与配置。" -ForegroundColor Cyan
    exit 0
}
while (Test-AntigravityRunning) {
    Write-Host ""
    Write-Host "[安全拦截] 反重力核心进程仍在运行！请先彻底关闭反重力软件后再还原。" -ForegroundColor Red
    Write-Host "请退出后按任意键重试..." -ForegroundColor Yellow
    [Console]::ReadKey($true) | Out-Null
    Write-Host ""
}
Write-Host " - 进程检查通过。" -ForegroundColor Green
Write-Host ""

# 2. 检查并移除联接
Write-Host "[2/3] 正在检查当前 C 盘传送门状态..." -ForegroundColor Yellow
if (Test-Path $sourceDir) {
    $item = Get-Item $sourceDir -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "检测到当前存在目录联接传送门，正在安全移除门牌..."
        Remove-Item $sourceDir -Force
        Write-Host " - 传送门牌已安全移除（E盘物理数据完好无损）。" -ForegroundColor Green
    } else {
        Write-Host "未检测到目录联接，继续执行还原。"
    }
}
Write-Host ""

# 3. 恢复物理数据
Write-Host "[3/3] 正在恢复物理数据到 C 盘..." -ForegroundColor Yellow
if (Test-Path $backupDir) {
    Write-Host "发现 C 盘本地完整备份，正在秒级还原..."
    Rename-Item -Path $backupDir -NewName ".gemini" -Force
    Write-Host " - 已成功从本地备份秒级还原至 C 盘！" -ForegroundColor Green
} elseif (Test-Path $targetDir) {
    Write-Host "未发现本地备份，正在从 E 盘数据源同步回 C 盘..."
    robocopy $targetDir $sourceDir /E /COPY:DAT /DCOPY:DAT /R:2 /W:2 /NFL /NDL /NP
    Write-Host " - 已成功将 E 盘数据完整复制回 C 盘！" -ForegroundColor Green
} else {
    Write-Host "[警告] 未能找到可用备份或 E 盘数据源！" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "                 还原完成！已成功恢复原状                             " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "C 盘目录已恢复为普通本地文件夹: $sourceDir"
Write-Host "您现在可以重新打开反重力软件正常使用。"
Write-Host ""
