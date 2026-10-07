@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0rollback_gemini_storage.ps1"
echo.
pause
