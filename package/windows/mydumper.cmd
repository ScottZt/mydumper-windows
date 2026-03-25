@echo off
setlocal
set "VOL=%CD%"
docker --version >NUL 2>&1
if errorlevel 1 (
  echo [ERROR] Docker Desktop 未安装或未运行。请安装并启动 Docker 后重试。
  exit /b 1
)
docker run --rm -v "%VOL%":"%VOL%" -w "%VOL%" mydumper/mydumper mydumper %*
endlocal
