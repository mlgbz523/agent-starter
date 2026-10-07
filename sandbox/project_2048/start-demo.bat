@echo off
rem Start local preview server for 2048 game
echo Starting local web server on port 8001...
start http://localhost:8001/
python -m http.server 8001
