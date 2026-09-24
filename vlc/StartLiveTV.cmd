@echo off
set "VLC=C:\Program Files\VideoLAN\VLC\vlc.exe"
if not exist "%VLC%" set "VLC=C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
if not exist "%VLC%" for /f "delims=" %i in ('where vlc.exe 2^>nul') do set "VLC=%i"
start "" "%VLC%" --one-instance --started-from-file "%~dp0livetv.m3u8"
timeout /t 2 /nobreak >nul
start "" "%~dp0ChannelMenu.html"