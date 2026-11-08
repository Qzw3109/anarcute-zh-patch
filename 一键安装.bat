@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ============================================
echo   Anarcute 简体中文补丁 - 一键安装
echo ============================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
echo 按任意键退出...
pause >nul