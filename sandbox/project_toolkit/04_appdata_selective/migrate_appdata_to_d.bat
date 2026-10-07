@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0migrate_appdata_to_d.ps1"
echo.
pause
