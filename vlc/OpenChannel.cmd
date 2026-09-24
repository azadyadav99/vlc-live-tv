@echo off
setlocal
set "RAW=%~1"
if not defined RAW exit /b 1
set "LIVETV_RAW=%RAW%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0OpenChannel.ps1" "%RAW%"
exit /b %ERRORLEVEL%
