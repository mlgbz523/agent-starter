param(
    [switch]$CheckOnly
)

# tools/rollback_permanent_redirection.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "源头重定向体系撤销与还原工具"

Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host "         源头重定向体系撤销与无损还原向导                             " -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Yellow
Write-Host ""

$programsSrc = "$env:LOCALAPPDATA\Programs"
$programsDst = "D:\Programs"

$cacheSrc = "$env:USERPROFILE\.cache"
$cacheDst = "D:\.cache"

function Test-IsJunction($path) {
    if (-not (Test-Path $path)) { return $false }
    $item = Get-Item $path -Force
    return (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Rollback-Junction($src, $dst, $title) {
    if (Test-IsJunction $src) {
        Write-Host "正在拆除 $title 传送门并将数据拷回 C 盘..." -ForegroundColor Cyan
        Remove-Item $src -Force
        robocopy $dst $src /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NP | Out-Null
        Write-Host " - ✅ $title 已成功还原回 C 盘！" -ForegroundColor Green
    } else {
        Write-Host " - $title 当前非传送门，无需还原。" -ForegroundColor DarkGray
    }
}

Rollback-Junction $programsSrc $programsDst "Programs 目录"
Rollback-Junction $cacheSrc $cacheDst ".cache 目录"

Write-Host "正在清理重定向环境变量..." -ForegroundColor Cyan
@("NPM_CONFIG_CACHE", "PIP_CACHE_DIR", "UV_CACHE_DIR", "HF_HOME", "TORCH_HOME", "CARGO_HOME") | ForEach-Object {
    [Environment]::SetEnvironmentVariable($_, $null, "User")
    Write-Host " - 已重置 $_" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "全部还原完成！" -ForegroundColor Green
