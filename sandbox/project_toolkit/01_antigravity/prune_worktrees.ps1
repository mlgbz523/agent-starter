# tools/prune_worktrees.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "反重力历史工作树清理与瘦身工具"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         反重力项目工作树瘦身向导 (清理历史无效分支缓存)               " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = "E:\workSpace\planProject"

if (-not (Test-Path (Join-Path $projectDir ".git"))) {
    Write-Host "[错误] 未在 $projectDir 找到有效 Git 仓库！" -ForegroundColor Red
    exit 1
}

Write-Host "[1/2] 正在清理已关闭或已删除的历史会话分支残留..." -ForegroundColor Yellow
git -C $projectDir worktree prune -v
Write-Host ""

Write-Host "[2/2] 当前正在保留的有效工作树列表如下：" -ForegroundColor Yellow
git -C $projectDir worktree list
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "工作树瘦身完成！无效的临时分支已被安全清理。" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""
