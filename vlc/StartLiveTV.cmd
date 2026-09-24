@echo off
start "" "C:\Program Files\VideoLAN\VLC\vlc.exe" --one-instance --started-from-file "%~dp0livetv.m3u8"
timeout /t 2 /nobreak >nul
start "" "%~dp0ChannelMenu.html"