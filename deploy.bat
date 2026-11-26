@echo off
setlocal
set "GAME_DIR=%~dp0stable\0.0.3"
if not "%~1"=="" set "GAME_DIR=%~f1"
pwsh -NoProfile -File "%~dp0tools\deploy-config.ps1" -Destination "%GAME_DIR%" -ImportWorkbook
exit /b %ERRORLEVEL%
