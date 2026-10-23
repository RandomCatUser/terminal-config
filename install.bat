@echo off
chcp 65001 >nul
title fastfetch setup
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
set RESULT=%ERRORLEVEL%
echo.
if %RESULT% NEQ 0 (
  echo  setup failed - see the messages above.
) else (
  echo  setup finished - press any key to close.
)
pause >nul
endlocal
exit /b %RESULT%
