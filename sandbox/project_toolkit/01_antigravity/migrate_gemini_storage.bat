@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0migrate_gemini_storage.ps1"
echo.
pause
