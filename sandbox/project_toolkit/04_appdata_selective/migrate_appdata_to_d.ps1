param(
    [switch]$CheckOnly,
    [switch]$CleanCacheOnly,
    [switch]$MigrateAll,
    [switch]$Auto
)

# tools/migrate_appdata_to_d.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "AppData 安全精准瘦身工具 - D盘传送门"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         AppData 安全精准瘦身向导 (D盘目录联接传送门方案)             " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "设计理念：绝不触碰 Windows 系统底层核心，仅精准搬迁 10 个大型第三方应用"
Write-Host "预期释放：清理纯缓存约 3.3 GB + 应用搬迁约 12.2 GB = 总计可腾出 ~15.5 GB"
Write-Host ""

$targetRoot = "D:\AppDataRelocated"

$cacheTargets = @(
    @{ Name = "npm 历史下载包缓存"; Path = "$env:LOCALAPPDATA\npm-cache"; SizeEst = "1.45 GB" },
    @{ Name = "Python uv 依赖缓存"; Path = "$env:LOCALAPPDATA\uv"; SizeEst = "1.35 GB" },
    @{ Name = "Playwright 浏览器测试镜像"; Path = "$env:LOCALAPPDATA\ms-playwright"; SizeEst = "0.54 GB" }
)

$apps = @(
    @{
        Id = "nvm"
        Name = "Node NVM 多版本环境"
        Source = "$env:LOCALAPPDATA\nvm"
        Target = "$targetRoot\Local\nvm"
        Processes = @()
        SizeEst = "2.11 GB"
    },
    @{
        Id = "tencent"
        Name = "腾讯应用数据 (Tencent)"
        Source = "$env:APPDATA\Tencent"
        Target = "$targetRoot\Roaming\Tencent"
        Processes = @("QQ", "WeChat", "QQProtect")
        SizeEst = "1.74 GB"
    },
    @{
        Id = "qq"
        Name = "QQ 个人数据"
        Source = "$env:APPDATA\QQ"
        Target = "$targetRoot\Roaming\QQ"
        Processes = @("QQ")
        SizeEst = "0.84 GB"
    },
    @{
        Id = "telegram"
        Name = "Telegram Desktop 数据与缓存"
        Source = "$env:APPDATA\Telegram Desktop"
        Target = "$targetRoot\Roaming\Telegram Desktop"
        Processes = @("Telegram")
        SizeEst = "1.47 GB"
    },
    @{
        Id = "adspower"
        Name = "AdsPower 浏览器环境数据"
        Source = "$env:APPDATA\adspower_global"
        Target = "$targetRoot\Roaming\adspower_global"
        Processes = @("adspower")
        SizeEst = "1.41 GB"
    },
    @{
        Id = "mihoyo"
        Name = "米哈游启动器与游戏数据"
        Source = "$env:APPDATA\miHoYo"
        Target = "$targetRoot\Roaming\miHoYo"
        Processes = @("HYP", "GenshinImpact", "StarRail")
        SizeEst = "1.22 GB"
    },
    @{
        Id = "forza"
        Name = "极限竞速地平线4 存档与着色器缓存"
        Source = "$env:LOCALAPPDATA\ForzaHorizon4"
        Target = "$targetRoot\Local\ForzaHorizon4"
        Processes = @("ForzaHorizon4")
        SizeEst = "1.20 GB"
    },
    @{
        Id = "netease"
        Name = "网易云音乐缓存与本地数据"
        Source = "$env:LOCALAPPDATA\NetEase"
        Target = "$targetRoot\Local\NetEase"
        Processes = @("cloudmusic")
        SizeEst = "0.84 GB"
    },
    @{
        Id = "bililive"
        Name = "哔哩哔哩直播姬缓存与配置"
        Source = "$env:LOCALAPPDATA\bililive"
        Target = "$targetRoot\Local\bililive"
        Processes = @("bililive")
        SizeEst = "0.73 GB"
    },
    @{
        Id = "openai"
        Name = "ChatGPT 桌面客户端数据"
        Source = "$env:LOCALAPPDATA\OpenAI"
        Target = "$targetRoot\Local\OpenAI"
        Processes = @("ChatGPT")
        SizeEst = "0.65 GB"
    }
)

function Test-IsJunction($path) {
    if (-not (Test-Path $path)) { return $false }
    $item = Get-Item $path -Force
    return (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Clean-CacheTargets {
    Write-Host "--- [正在清理纯临时开发缓存] ---" -ForegroundColor Yellow
    foreach ($c in $cacheTargets) {
        if (Test-Path $c.Path) {
            Write-Host "正在清除 $($c.Name) ($($c.SizeEst))..." -NoNewline
            try {
                Remove-Item $c.Path -Recurse -Force -ErrorAction Stop
                Write-Host " [已清空释放]" -ForegroundColor Green
            } catch {
                Write-Host " [跳过: 正在被占用]" -ForegroundColor DarkGray
            }
        } else {
            Write-Host "$($c.Name): 已不存在，无需清理。" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
}

function Migrate-AppItem($app) {
    $src = $app.Source
    $dst = $app.Target
    $name = $app.Name

    if (-not (Test-Path $src)) {
        Write-Host "[$name] C 盘不存在该目录，跳过。" -ForegroundColor DarkGray
        return
    }

    if (Test-IsJunction $src) {
        Write-Host "[$name] 已经是传送门 (目录联接)，无需重复迁移。" -ForegroundColor Green
        return
    }

    # 进程安全检查
    foreach ($proc in $app.Processes) {
        $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
        if ($running) {
            Write-Host "[$name] ⚠️ 检测到相关软件 ($proc) 正在运行！为了防数据冲突，已安全跳过本次搬迁。" -ForegroundColor Yellow
            return
        }
    }

    Write-Host "[$name] 开始搬迁 ($($app.SizeEst)) 至 D 盘..." -ForegroundColor Cyan

    $dstParent = Split-Path $dst -Parent
    if (-not (Test-Path $dstParent)) {
        New-Item -ItemType Directory -Path $dstParent -Force | Out-Null
    }

    # 同步数据
    robocopy $src $dst /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NP /XJ | Out-Null
    $rc = $LASTEXITCODE
    if ($rc -ge 8) {
        Write-Host "[$name] ❌ 数据复制出错 (代码 $rc)，保持 C 盘不动，跳过。" -ForegroundColor Red
        return
    }

    # 备份原目录
    $backupPath = "$src" + "_backup"
    if (Test-Path $backupPath) {
        Remove-Item $backupPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    try {
        Rename-Item $src -NewName (Split-Path $backupPath -Leaf) -Force -ErrorAction Stop
    } catch {
        Write-Host "[$name] ❌ 重命名原目录失败（文件被占用），已取消搬迁。" -ForegroundColor Red
        return
    }

    # 创建联接
    try {
        New-Item -ItemType Junction -Path $src -Target $dst -ErrorAction Stop | Out-Null
        Write-Host "[$name] ✅ 传送门建立成功！已迁移至: $dst" -ForegroundColor Green
        # 成功后删除备份以释放空间
        Remove-Item $backupPath -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "[$name] ❌ 建立联接失败，正在自动还原原目录..." -ForegroundColor Red
        Rename-Item $backupPath -NewName (Split-Path $src -Leaf) -Force
    }
}

if ($CheckOnly) {
    Write-Host "[预检模式] 正在探测各目录就绪状态..." -ForegroundColor Yellow
    foreach ($a in $apps) {
        $status = if (Test-Path $a.Source) { if (Test-IsJunction $a.Source) { "已是传送门" } else { "就绪可搬" } } else { "不存在" }
        Write-Host " - $($a.Name) ($($a.SizeEst)): $status"
    }
    Write-Host "[预检模式] 探测完毕，退出。" -ForegroundColor Green
    exit 0
}

if ($CleanCacheOnly) {
    Clean-CacheTargets
    Write-Host "纯缓存清理完毕！" -ForegroundColor Green
    exit 0
}

if ($MigrateAll -or $Auto) {
    Clean-CacheTargets
    Write-Host "--- [正在建立第三方应用传送门] ---" -ForegroundColor Yellow
    foreach ($a in $apps) {
        Migrate-AppItem $a
    }
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host "                 🎉 AppData 精准瘦身已全部完成！                      " -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Green
    exit 0
}

# 交互式菜单
Write-Host "请选择执行模式：" -ForegroundColor Yellow
Write-Host " [1] 一键全套处理（清理 3.3GB 纯缓存 + 搬迁 10 个安全应用，释放最多空间，推荐）"
Write-Host " [2] 仅清理纯缓存（零改动，立刻清理 3.3GB npm/uv/playwright 垃圾）"
Write-Host " [3] 仅搬迁第三方应用（保留缓存，仅搬迁 Tencent/Telegram/nvm 等至 D 盘）"
Write-Host " [Q] 退出"
Write-Host ""
$choice = Read-Host "请输入选项 (1/2/3/Q)"

switch ($choice) {
    "1" {
        Clean-CacheTargets
        Write-Host "--- [正在建立第三方应用传送门] ---" -ForegroundColor Yellow
        foreach ($a in $apps) { Migrate-AppItem $a }
        Write-Host "恭喜！全套瘦身已完成！" -ForegroundColor Green
    }
    "2" {
        Clean-CacheTargets
        Write-Host "纯缓存清理完成！" -ForegroundColor Green
    }
    "3" {
        Write-Host "--- [正在建立第三方应用传送门] ---" -ForegroundColor Yellow
        foreach ($a in $apps) { Migrate-AppItem $a }
        Write-Host "应用迁移完成！" -ForegroundColor Green
    }
    default {
        Write-Host "操作已取消。"
    }
}
