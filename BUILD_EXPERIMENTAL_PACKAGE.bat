@echo off
setlocal
call "%~dp0BUILD_AND_INSTALL.bat" -ExperimentalPackage %*
exit /b %ERRORLEVEL%
