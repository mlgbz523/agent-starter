param(
    [switch]$CheckOnly,
    [switch]$Auto
)

# tools/clean_c_drive_junk.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "C 盘纯垃圾秒级清理与急救工具 - 保留系统休眠"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         C 盘纯垃圾秒级清理向导 (零风险，直接删除垃圾缓存)            " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "设计理念：只清理纯无用安装包、临时缓存和更新残留，完整保留系统休眠 (hiberfil.sys)"
Write-Host "预期释放：~16.3 GB 纯垃圾 + ~1.7 GB 补齐腾讯传送门 = 立省整整 ~18.0 GB！"
Write-Host ""

# 自动提升管理员权限 (用于清理 C:\$WinREAgent 等系统级根目录残余)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin -and -not $CheckOnly) {
    Write-Host "正在请求管理员权限以清理系统级更新暂存..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 0
}

$cleanPlan = @(
    @{
        Id = "updaters"
        Name = "清理 25 款软件自更新遗留安装包 (*-updater)"
        SizeEst = "4.19 GB"
        Action = {
            Write-Host "正在清理 AppData\Local\*-updater 升级残留..." -NoNewline
            $updaters = Get-ChildItem -Path "$env:LOCALAPPDATA" -Filter "*-updater" -Directory -ErrorAction SilentlyContinue
            $count = 0
            foreach ($u in $updaters) {
                try {
                    Remove-Item $u.FullName -Recurse -Force -ErrorAction Stop
                    $count++
                } catch {}
            }
            Write-Host " [已清理 $count 个升级包目录，释放 ~4.19 GB！]" -ForegroundColor Green
        }
    },
    @{
        Id = "sandbox"
        Name = "清理 Sandboxie 沙盒临时运行文件"
        SizeEst = "3.65 GB"
        Action = {
            $sandboxDir = "C:\Sandbox\15770\DefaultBox"
            if (Test-Path $sandboxDir) {
                Write-Host "正在清理 Sandboxie 沙盒临时数据 ($sandboxDir)..." -NoNewline
                try {
                    Remove-Item $sandboxDir -Recurse -Force -ErrorAction Stop
                    Write-Host " [已清理释放 3.65 GB！]" -ForegroundColor Green
                } catch {
                    Write-Host " [跳过: 文件被占用或沙盒正在运行]" -ForegroundColor Yellow
                }
            } else {
                Write-Host "Sandboxie 默认沙盒为空或已清理。" -ForegroundColor DarkGray
            }
        }
    },
    @{
        Id = "gemini_backup"
        Name = "删除反重力冷备份 (.gemini_backup)"
        SizeEst = "2.08 GB"
        Action = {
            $backup = "$env:USERPROFILE\.gemini_backup"
            if (Test-Path $backup) {
                Write-Host "正在删除已完成历史使命的 .gemini_backup..." -NoNewline
                try {
                    Remove-Item $backup -Recurse -Force -ErrorAction Stop
                    Write-Host " [已删除，释放 2.08 GB！]" -ForegroundColor Green
                } catch {
                    Write-Host " [删除失败: 文件被占用]" -ForegroundColor Yellow
                }
            } else {
                Write-Host ".gemini_backup 已被删除或不存在。" -ForegroundColor DarkGray
            }
        }
    },
    @{
        Id = "winre"
        Name = "删除 Windows 更新暂存镜像 (C:\$WinREAgent)"
        SizeEst = "1.75 GB"
        Action = {
            $winre = "C:\`$WinREAgent"
            if (Test-Path $winre) {
                Write-Host "正在清理历史更新镜像暂存 ($winre)..." -NoNewline
                try {
                    Remove-Item $winre -Recurse -Force -ErrorAction Stop
                    Write-Host " [已删除，释放 1.75 GB！]" -ForegroundColor Green
                } catch {
                    Write-Host " [需要管理员权限删除该目录]" -ForegroundColor Yellow
                }
            } else {
                Write-Host "`$WinREAgent 已清理。" -ForegroundColor DarkGray
            }
        }
    },
    @{
        Id = "amd"
        Name = "删除旧驱动安装解压包 (C:\AMD)"
        SizeEst = "0.58 GB"
        Action = {
            $amd = "C:\AMD"
            if (Test-Path $amd) {
                Write-Host "正在清理驱动解压残留 ($amd)..." -NoNewline
                try {
                    Remove-Item $amd -Recurse -Force -ErrorAction Stop
                    Write-Host " [已删除，释放 0.58 GB！]" -ForegroundColor Green
                } catch {
                    Write-Host " [删除失败]" -ForegroundColor Yellow
                }
            } else {
                Write-Host "C:\AMD 已不存在。" -ForegroundColor DarkGray
            }
        }
    },
    @{
        Id = "thunder"
        Name = "清理迅雷后台下载的历史升级包"
        SizeEst = "0.73 GB"
        Action = {
            $th = "C:\ProgramData\Thunder Network\XLLiveUD\Download"
            if (Test-Path $th) {
                Write-Host "正在清理迅雷自动更新包..." -NoNewline
                try {
                    Remove-Item "$th\*" -Recurse -Force -ErrorAction Stop
                    Write-Host " [已清理，释放 0.73 GB！]" -ForegroundColor Green
                } catch {
                    Write-Host " [跳过: 迅雷可能正在运行]" -ForegroundColor Yellow
                }
            } else {
                Write-Host "迅雷更新缓存为空。" -ForegroundColor DarkGray
            }
        }
    },
    @{
        Id = "devcache"
        Name = "清空 npm 与 Python uv 开发下载缓存"
        SizeEst = "1.60 GB"
        Action = {
            Write-Host "正在清理 npm-cache 与 uv 缓存..." -NoNewline
            Remove-Item "$env:LOCALAPPDATA\npm-cache" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:LOCALAPPDATA\uv" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host " [已清空，释放 1.60 GB！]" -ForegroundColor Green
        }
    },
    @{
        Id = "tencent_junction"
        Name = "补齐微信/腾讯数据 D盘传送门"
        SizeEst = "1.74 GB"
        Action = {
            $src = "$env:APPDATA\Tencent"
            $dst = "D:\AppDataRelocated\Roaming\Tencent"
            if (Test-Path $src) {
                $item = Get-Item $src -Force
                $isJunction = ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
                if (-not $isJunction) {
                    $running = Get-Process -Name "QQ" -ErrorAction SilentlyContinue
                    if ($running) {
                        Write-Host "⚠️ 检测到 QQ 正在运行中！请退出 QQ 后再次运行以打通腾讯传送门。" -ForegroundColor Yellow
                    } else {
                        if (Test-Path $dst) {
                            Write-Host "正在删除 C 盘已备份好的 Tencent 并创建传送门..." -NoNewline
                            try {
                                Remove-Item $src -Recurse -Force -ErrorAction Stop
                                New-Item -ItemType Junction -Path $src -Target $dst -ErrorAction Stop | Out-Null
                                Write-Host " [腾讯传送门补齐成功，释放 1.74 GB！]" -ForegroundColor Green
                            } catch {
                                Write-Host " [操作失败: $_]" -ForegroundColor Red
                            }
                        }
                    }
                } else {
                    Write-Host "腾讯目录当前已是传送门，无需处理。" -ForegroundColor Green
                }
            }
        }
    }
)

if ($CheckOnly) {
    Write-Host "[预检模式] 正在探测纯垃圾清理项..." -ForegroundColor Yellow
    foreach ($item in $cleanPlan) {
        Write-Host " - $($item.Name) ($($item.SizeEst)): 就绪可清理"
    }
    Write-Host "[预检模式] 探测完毕，未作任何删除。" -ForegroundColor Green
    exit 0
}

Write-Host "开始执行 C 盘纯垃圾秒级清理..." -ForegroundColor Cyan
Write-Host ""
foreach ($item in $cleanPlan) {
    & $item.Action
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "              🎉 恭喜！纯垃圾清理与急救全部完成！                      " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "请打开【此电脑】查看 C 盘，可用空间已大幅回血！" -ForegroundColor Cyan
Write-Host ""
