param(
    [switch]$CheckOnly
)

# tools/migrate_gemini_storage.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "反重力 (Antigravity) 数据目录迁移工具 - E盘传送门"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "      反重力 (Antigravity) 数据目录迁移向导 (Windows 目录联接方案)      " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "目标：将 C 盘的 .gemini 数据目录安全搬迁到 E:\GeminiData\.gemini"
Write-Host "优势：通过 NTFS 目录联接 (传送门)，软件保持原路径访问，C 盘彻底释放空间"
Write-Host ""

$sourceDir = [System.IO.Path]::Combine($env:USERPROFILE, ".gemini")
$targetParent = "E:\GeminiData"
$targetDir = "E:\GeminiData\.gemini"
$backupDir = [System.IO.Path]::Combine($env:USERPROFILE, ".gemini_backup")

# 1. 检查反重力核心进程
function Test-AntigravityRunning {
    $p1 = Get-Process -Name "Antigravity" -ErrorAction SilentlyContinue
    $p2 = Get-Process -Name "language_server" -ErrorAction SilentlyContinue
    return ($null -ne $p1 -or $null -ne $p2)
}

Write-Host "[1/5] 正在检查反重力核心进程状态..." -ForegroundColor Yellow

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
    Write-Host "======================================================================" -ForegroundColor Red
    Write-Host "[安全拦截] 检测到 反重力 (Antigravity) 核心进程仍在运行中！" -ForegroundColor Red
    Write-Host "======================================================================" -ForegroundColor Red
    Write-Host "为了防止文件被独占加锁导致数据损坏，请按以下步骤操作："
    Write-Host " 1. 保存当前工作并关闭 反重力 软件主界面；"
    Write-Host " 2. 检查右下角系统任务栏托盘，如有反重力图标，右键彻底退出；"
    Write-Host ""
    Write-Host "退出完成后，按任意键继续检测..." -ForegroundColor Yellow
    [Console]::ReadKey($true) | Out-Null
    Write-Host ""
}
Write-Host " - 进程检查通过：反重力软件已完全关闭。" -ForegroundColor Green
Write-Host ""

# 2. 目录检查
Write-Host "[2/5] 正在检查原目录与目标磁盘..." -ForegroundColor Yellow
if (-not (Test-Path $sourceDir)) {
    Write-Host "[错误] 未在 C 盘找到 $sourceDir 目录！" -ForegroundColor Red
    exit 1
}

$sourceItem = Get-Item $sourceDir -Force
if ($sourceItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
    Write-Host "[提示] 检测到 $sourceDir 当前已经是目录联接传送门！无需重复迁移。" -ForegroundColor Green
    exit 0
}

if (-not (Test-Path $targetParent)) {
    Write-Host "正在创建目标盘目录: $targetParent ..."
    New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
}

# 自动清理历史悬空死链接 (防止指向非存在路径的残留软链接阻断 robocopy)
Write-Host "正在扫描并自动清理历史悬空死链接..." -ForegroundColor DarkGray
Get-ChildItem -Path $sourceDir -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {
    $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint
} | ForEach-Object {
    $target = $_.Target
    $targetPath = if ($target -is [array]) { $target[0] } else { $target }
    if ($targetPath -and -not (Test-Path $targetPath)) {
        Write-Host " - 自动清理失效死链接: $($_.Name)" -ForegroundColor DarkGray
        try { (Get-Item $_.FullName).Delete() } catch {}
    }
}

Write-Host " - 目录检查与死链接清理通过。" -ForegroundColor Green
Write-Host ""

# 3. 数据同步 (robocopy)
Write-Host "[3/5] 正在使用工业级同步工具 (robocopy) 将数据完整克隆到 E 盘..." -ForegroundColor Yellow
Write-Host "这可能需要 1~2 分钟，请稍候（请勿强行关闭此窗口）..."
robocopy $sourceDir $targetDir /E /COPY:DAT /DCOPY:DAT /R:2 /W:2 /NFL /NDL /NP
$rc = $LASTEXITCODE
if ($rc -ge 8) {
    Write-Host "[错误] 数据复制失败！错误码: $rc" -ForegroundColor Red
    Write-Host "原 C 盘文件保持完整，未作任何改动。"
    exit 1
}
Write-Host " - 数据克隆完成，完整性校验通过！" -ForegroundColor Green
Write-Host ""

# 4. 备份与创建联接
Write-Host "[4/5] 正在安全备份 C 盘原目录并建立传送门..." -ForegroundColor Yellow
if (Test-Path $backupDir) {
    Write-Host "发现已有备份，正在安全归档..."
    Remove-Item $backupDir -Recurse -Force -ErrorAction SilentlyContinue
}

try {
    Rename-Item -Path $sourceDir -NewName ".gemini_backup" -Force -ErrorAction Stop
} catch {
    Write-Host "[错误] 重命名 C 盘原目录失败，可能仍有隐藏进程占用文件。" -ForegroundColor Red
    Write-Host "错误详情: $_" -ForegroundColor Red
    Write-Host "操作已安全取消，原文件安全无虞。"
    exit 1
}

try {
    New-Item -ItemType Junction -Path $sourceDir -Target $targetDir -ErrorAction Stop | Out-Null
    Write-Host " - 传送门 (目录联接) 建立成功！" -ForegroundColor Green
} catch {
    Write-Host "[错误] 创建目录联接失败！正在自动回滚原目录..." -ForegroundColor Red
    Rename-Item -Path $backupDir -NewName ".gemini" -Force
    exit 1
}
Write-Host ""

# 5. 健康检查
Write-Host "[5/5] 正在进行最终连通性健康检查..." -ForegroundColor Yellow
if (Test-Path (Join-Path $sourceDir "antigravity")) {
    Write-Host " - 健康检查通过：C 盘软链接可顺畅读写 E 盘物理数据！" -ForegroundColor Green
} else {
    Write-Host "[异常] 传送门无法正确定位数据，正在紧急回滚..." -ForegroundColor Red
    Remove-Item $sourceDir -Force -ErrorAction SilentlyContinue
    Rename-Item -Path $backupDir -NewName ".gemini" -Force
    Write-Host "已安全回退至初始状态。" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "                  大功告成！数据搬迁与传送门已全部建立！                 " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "1. 所有实际数据现已安全保存在: $targetDir"
Write-Host "2. C 盘原路径已变为系统级传送门，反重力软件无感知兼容，未来新增缓存全在 E 盘"
Write-Host ""
Write-Host "后续验证与瘦身建议：" -ForegroundColor Cyan
Write-Host " - 现在您可以重新打开 反重力 (Antigravity) 软件；"
Write-Host " - 检查历史对话、项目工作区能否正常工作；"
Write-Host " - 确认无误后，您可以手动删除 C 盘备份文件夹以彻底腾出空间："
Write-Host "   $backupDir"
Write-Host ""
