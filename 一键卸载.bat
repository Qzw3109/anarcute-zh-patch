@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo 正在卸载 Anarcute 简体中文补丁...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1"
echo.
echo 按任意键退出...
pause >nul