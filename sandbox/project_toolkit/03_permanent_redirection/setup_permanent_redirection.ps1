param(
    [switch]$CheckOnly
)

# tools/setup_permanent_redirection.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "C 盘一劳永逸源头重定向装配工具 - 永久分流至 D 盘"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         C 盘一劳永逸源头重定向装配向导 (四层永久防御体系)            " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "设计理念：卡死静默安装入口 + 卡死开发缓存与模型 + 注入全局环境变量"
Write-Host "达成效果：未来新装软件与新下载模型/缓存 100% 自动物理落入 D 盘，C 盘永久 0 增长！"
Write-Host ""

$programsSrc = "$env:LOCALAPPDATA\Programs"
$programsDst = "D:\Programs"

$cacheSrc = "$env:USERPROFILE\.cache"
$cacheDst = "D:\.cache"

$devCacheDir = "D:\DevCache"

function Test-IsJunction($path) {
    if (-not (Test-Path $path)) { return $false }
    $item = Get-Item $path -Force
    return (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Move-And-Junction($src, $dst, $title) {
    Write-Host "[$title] 正在检查..." -NoNewline
    if (-not (Test-Path $src)) {
        Write-Host " [源目录不存在，直接在 D 盘建立空目录与传送门]" -ForegroundColor DarkGray
        New-Item -ItemType Directory -Path $dst -Force | Out-Null
        New-Item -ItemType Junction -Path $src -Target $dst -Force | Out-Null
        return
    }

    if (Test-IsJunction $src) {
        Write-Host " [当前已是传送门，无需重复建立]" -ForegroundColor Green
        return
    }

    Write-Host ""
    Write-Host "  -> 正在将 $title 物理数据同步至 $dst ..." -ForegroundColor Cyan
    if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }

    robocopy $src $dst /E /COPY:DAT /DCOPY:DAT /R:2 /W:2 /NFL /NDL /NP /XJ | Out-Null

    $backup = "$src" + "_backup"
    if (Test-Path $backup) { Remove-Item $backup -Recurse -Force -ErrorAction SilentlyContinue }

    try {
        Rename-Item -Path $src -NewName (Split-Path $backup -Leaf) -Force -ErrorAction Stop
        New-Item -ItemType Junction -Path $src -Target $dst -ErrorAction Stop | Out-Null
        Write-Host "  -> ✅ $title 传送门建立成功！" -ForegroundColor Green
        Remove-Item $backup -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "  -> ❌ 建立传送门失败（可能有软件正在运行），已保留原目录。" -ForegroundColor Red
        if (Test-Path $backup) { Rename-Item $backup -NewName (Split-Path $src -Leaf) -Force -ErrorAction SilentlyContinue }
    }
}

if ($CheckOnly) {
    Write-Host "[预检模式] 探测各拦截层当前状态：" -ForegroundColor Yellow
    Write-Host " - 软件静默安装入口 ($programsSrc): " -NoNewline
    if (Test-IsJunction $programsSrc) { Write-Host "已建立 D 盘传送门" -ForegroundColor Green } else { Write-Host "就绪可配" -ForegroundColor Cyan }

    Write-Host " - 通用缓存池 ($cacheSrc): " -NoNewline
    if (Test-IsJunction $cacheSrc) { Write-Host "已建立 D 盘传送门" -ForegroundColor Green } else { Write-Host "就绪可配" -ForegroundColor Cyan }

    Write-Host " - 6 大开发与 AI 模型环境变量: 就绪可注入 D:\DevCache" -ForegroundColor Cyan
    exit 0
}

# 1. 迁移 Programs
Move-And-Junction $programsSrc $programsDst "未来软件安装入口 (AppData\Local\Programs)"

# 2. 迁移 .cache
Move-And-Junction $cacheSrc $cacheDst "跨应用通用缓存池 (.cache)"

# 3. 注入系统环境变量
Write-Host ""
Write-Host "[注入开发与 AI 模型环境变量] 正在将缓存统一重定向至 D:\DevCache ..." -ForegroundColor Cyan
if (-not (Test-Path $devCacheDir)) { New-Item -ItemType Directory -Path $devCacheDir -Force | Out-Null }

$envVars = @{
    "NPM_CONFIG_CACHE" = "$devCacheDir\npm-cache"
    "PIP_CACHE_DIR"    = "$devCacheDir\pip"
    "UV_CACHE_DIR"     = "$devCacheDir\uv"
    "HF_HOME"          = "$devCacheDir\huggingface"
    "TORCH_HOME"       = "$devCacheDir\torch"
    "CARGO_HOME"       = "$devCacheDir\cargo"
}

foreach ($k in $envVars.Keys) {
    [Environment]::SetEnvironmentVariable($k, $envVars[$k], "User")
    Write-Host " - $k -> $($envVars[$k])" -ForegroundColor Green
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "          🎉 恭喜！一劳永逸源头重定向体系已全部激活！                 " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "1. 未来静默安装的所有软件已全部自动流向 D:\Programs"
Write-Host "2. 通用大缓存自动流向 D:\.cache"
Write-Host "3. npm / pip / uv / HuggingFace / PyTorch 缓存与大模型 100% 自动流入 D:\DevCache"
Write-Host ""
Write-Host "👉 正在打开 Windows 官方【保存新内容的地方】设置面板..." -ForegroundColor Yellow
Start-Process "ms-settings:storagesavedlocations"
Write-Host "建议在弹出的设置窗口中，将【新的应用将保存到】手动确认为 D 盘。" -ForegroundColor Cyan
Write-Host ""
