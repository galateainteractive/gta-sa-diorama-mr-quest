@echo off
setlocal
title GTA San Andreas Diorama MR - First-run test

echo ============================================================
echo   GTA SAN ANDREAS DIORAMA MR - FIRST-RUN TEST
echo ============================================================
echo.
echo This test:
echo   1. stops the game;
echo   2. copies and hash-verifies saves/settings on this PC;
echo   3. removes only the VR settings;
echo   4. preserves APKs, saves, game data, audio and game resources.
echo.
echo The shipping Diorama MR defaults will be recreated on the next launch.
echo The Quest must be powered on, connected and authorized over USB.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\reset-vr-settings.ps1" ^
  -WorkDir "%~dp0..\work-upstream" ^
  -BackupBeforeReset

set "SAVR_EXIT=%ERRORLEVEL%"
echo.
if not "%SAVR_EXIT%"=="0" (
  echo The first-run test was not prepared. No settings were removed if backup verification failed.
) else (
  echo First-run test prepared. Start the game normally from the Quest.
)
echo.
pause
exit /b %SAVR_EXIT%
