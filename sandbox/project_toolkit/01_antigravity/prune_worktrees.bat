@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0prune_worktrees.ps1"
echo.
pause
