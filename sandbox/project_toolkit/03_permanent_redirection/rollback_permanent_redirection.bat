@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0rollback_permanent_redirection.ps1"
echo.
pause
