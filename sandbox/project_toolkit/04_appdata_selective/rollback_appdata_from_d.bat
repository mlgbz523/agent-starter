@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0rollback_appdata_from_d.ps1"
echo.
pause
