@echo off
chcp 65001 >nul
echo ===================================================
echo   扫雷项目本地一键启动预览服务 (PM 专用)
echo ===================================================
echo 正在启动本地服务并打开浏览器，请勿关闭此窗口...
start http://localhost:8000/minesweeper.html
python -m http.server 8000
