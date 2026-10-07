@echo off
rem Start local preview server for Minesweeper demo
echo Starting local web server on port 8000...
start http://localhost:8000/
python -m http.server 8000
