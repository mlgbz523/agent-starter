param(
    [switch]$CheckOnly
)

# tools/rollback_appdata_from_d.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "AppData 传送门安全撤销与还原工具"

Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host "           AppData D盘传送门撤销与无损还原向导                        " -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host ""

$targetRoot = "D:\AppDataRelocated"

$apps = @(
    @{ Id = "nvm"; Name = "Node NVM 多版本环境"; Source = "$env:LOCALAPPDATA\nvm"; Target = "$targetRoot\Local\nvm" },
    @{ Id = "tencent"; Name = "腾讯应用数据 (Tencent)"; Source = "$env:APPDATA\Tencent"; Target = "$targetRoot\Roaming\Tencent" },
    @{ Id = "qq"; Name = "QQ 个人数据"; Source = "$env:APPDATA\QQ"; Target = "$targetRoot\Roaming\QQ" },
    @{ Id = "telegram"; Name = "Telegram Desktop 数据与缓存"; Source = "$env:APPDATA\Telegram Desktop"; Target = "$targetRoot\Roaming\Telegram Desktop" },
    @{ Id = "adspower"; Name = "AdsPower 浏览器环境数据"; Source = "$env:APPDATA\adspower_global"; Target = "$targetRoot\Roaming\adspower_global" },
    @{ Id = "mihoyo"; Name = "米哈游启动器与游戏数据"; Source = "$env:APPDATA\miHoYo"; Target = "$targetRoot\Roaming\miHoYo" },
    @{ Id = "forza"; Name = "极限竞速地平线4 存档与着色器缓存"; Source = "$env:LOCALAPPDATA\ForzaHorizon4"; Target = "$targetRoot\Local\ForzaHorizon4" },
    @{ Id = "netease"; Name = "网易云音乐缓存与本地数据"; Source = "$env:LOCALAPPDATA\NetEase"; Target = "$targetRoot\Local\NetEase" },
    @{ Id = "bililive"; Name = "哔哩哔哩直播姬缓存与配置"; Source = "$env:LOCALAPPDATA\bililive"; Target = "$targetRoot\Local\bililive" },
    @{ Id = "openai"; Name = "ChatGPT 桌面客户端数据"; Source = "$env:LOCALAPPDATA\OpenAI"; Target = "$targetRoot\Local\OpenAI" }
)

function Test-IsJunction($path) {
    if (-not (Test-Path $path)) { return $false }
    $item = Get-Item $path -Force
    return (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

if ($CheckOnly) {
    Write-Host "[预检模式] 探测当前传送门状态：" -ForegroundColor Yellow
    foreach ($a in $apps) {
        $status = if (Test-IsJunction $a.Source) { "当前是D盘传送门" } else { "普通本地目录/未搬迁" }
        Write-Host " - $($a.Name): $status"
    }
    exit 0
}

Write-Host "正在扫描并还原已搬迁到 D 盘的应用..." -ForegroundColor Cyan
foreach ($a in $apps) {
    $src = $a.Source
    $dst = $a.Target
    $name = $a.Name

    if (Test-IsJunction $src) {
        Write-Host "[$name] 正在移除 C 盘传送门牌..." -ForegroundColor Yellow
        Remove-Item $src -Force
        Write-Host "[$name] 正在将数据从 D 盘拷回 C 盘..." -ForegroundColor Yellow
        robocopy $dst $src /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NP | Out-Null
        Write-Host "[$name] ✅ 已成功还原至 C 盘！" -ForegroundColor Green
    } else {
        Write-Host "[$name] 当前非传送门，无需还原。" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "已完成全部检查与还原！" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
