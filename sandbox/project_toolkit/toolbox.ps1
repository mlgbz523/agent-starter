# toolbox.ps1 - Master Control Launcher
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Windows C 盘全能瘦身与源头重定向总控台"

$baseDir = $PSScriptRoot

function Show-Menu {
    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "         Windows C 盘全能瘦身与源头重定向总控台 (Toolbox)              " -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "当前工具目录: $baseDir" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "【核心功能推荐流程】" -ForegroundColor Yellow
    Write-Host " [1] C 盘纯垃圾秒级清理 (立省 ~18.0 GB，100% 完整保留系统休眠)" -ForegroundColor White
    Write-Host " [2] 一劳永逸源头重定向体系 (立省 ~6.3 GB + 未来软件/模型 100% 自动入 D 盘)" -ForegroundColor White
    Write-Host " [3] AppData 10 大常用应用定向搬迁 (搬迁 Telegram/AdsPower/miHoYo 等，立省 ~12 GB)" -ForegroundColor White
    Write-Host " [4] 反重力工作树历史分支瘦身 (清理 Git worktree 废弃残留)" -ForegroundColor White
    Write-Host ""
    Write-Host "【一键后悔药 / 撤销中心】" -ForegroundColor Yellow
    Write-Host " [R1] 撤销源头重定向 (将 Programs/.cache 移回 C 盘并重置环境变量)" -ForegroundColor DarkGray
    Write-Host " [R2] 撤销 AppData 10 大应用搬迁 (将已搬迁应用移回 C 盘)" -ForegroundColor DarkGray
    Write-Host " [R3] 撤销反重力迁移 (将 .gemini 移回 C 盘)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " [0] 打开本工具箱使用说明书 (使用说明.md)" -ForegroundColor Cyan
    Write-Host " [Q] 退出总控台" -ForegroundColor DarkGray
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

while ($true) {
    Show-Menu
    $choice = Read-Host "请输入功能编号按回车"
    Write-Host ""

    switch ($choice.ToUpper()) {
        "1" {
            $script = Join-Path $baseDir "02_c_drive_cleanup\clean_c_drive_junk.ps1"
            if (Test-Path $script) {
                & $script
            } else {
                Write-Host "未找到脚本: $script" -ForegroundColor Red
            }
            Write-Host "按任意键返回主菜单..."
            [Console]::ReadKey($true) | Out-Null
        }
        "2" {
            $script = Join-Path $baseDir "03_permanent_redirection\setup_permanent_redirection.ps1"
            if (Test-Path $script) {
                & $script
            } else {
                Write-Host "未找到脚本: $script" -ForegroundColor Red
            }
            Write-Host "按任意键返回主菜单..."
            [Console]::ReadKey($true) | Out-Null
        }
        "3" {
            $script = Join-Path $baseDir "04_appdata_selective\migrate_appdata_to_d.ps1"
            if (Test-Path $script) {
                & $script
            } else {
                Write-Host "未找到脚本: $script" -ForegroundColor Red
            }
            Write-Host "按任意键返回主菜单..."
            [Console]::ReadKey($true) | Out-Null
        }
        "4" {
            $script = Join-Path $baseDir "01_antigravity\prune_worktrees.ps1"
            if (Test-Path $script) {
                & $script
            } else {
                Write-Host "未找到脚本: $script" -ForegroundColor Red
            }
            Write-Host "按任意键返回主菜单..."
            [Console]::ReadKey($true) | Out-Null
        }
        "R1" {
            $script = Join-Path $baseDir "03_permanent_redirection\rollback_permanent_redirection.ps1"
            if (Test-Path $script) {
                & $script
            } else {
                Write-Host "未找到脚本: $script" -ForegroundColor Red
            }
            Write-Host "按任意键返回主菜单..."
            [Console]::ReadKey($true) | Out-Null
        }
        "R2" {
            $script = Join-Path $baseDir "04_appdata_selective\rollback_appdata_from_d.ps1"
            if (Test-Path $script) {
                & $script
            } else {
                Write-Host "未找到脚本: $script" -ForegroundColor Red
            }
            Write-Host "按任意键返回主菜单..."
            [Console]::ReadKey($true) | Out-Null
        }
        "R3" {
            $script = Join-Path $baseDir "01_antigravity\rollback_gemini_storage.ps1"
            if (Test-Path $script) {
                & $script
            } else {
                Write-Host "未找到脚本: $script" -ForegroundColor Red
            }
            Write-Host "按任意键返回主菜单..."
            [Console]::ReadKey($true) | Out-Null
        }
        "0" {
            $readme = Join-Path $baseDir "使用说明.md"
            if (Test-Path $readme) {
                Start-Process notepad.exe -ArgumentList "`"$readme`""
            }
        }
        "Q" {
            Write-Host "感谢使用，总控台已退出。" -ForegroundColor Green
            exit 0
        }
        default {
            Write-Host "输入无效，请重新选择。" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}
