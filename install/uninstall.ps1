# Live TV uninstaller - removes playlist, menu, launchers, Lua bits, protocol and shortcut.
# Close VLC first. Favorites (stars) live in your browser localStorage and are NOT touched.
$ErrorActionPreference = 'Stop'
$AppDataVlc = Join-Path $env:APPDATA 'vlc'

Write-Host "Live TV uninstaller" -ForegroundColor Cyan

# 1. Desktop shortcut
$lnk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Live TV.lnk'
if (Test-Path $lnk) { Remove-Item $lnk -Force; Write-Host "  - Desktop shortcut" }

# 2. livetv:// protocol handler
if (Test-Path 'HKCU:\Software\Classes\livetv') {
  Remove-Item -Path 'HKCU:\Software\Classes\livetv' -Recurse -Force
  Write-Host "  - livetv:// protocol"
}

# 3. Payload files (incl. Lua extension and logs)
$files = @(
  'livetv.m3u8', 'ChannelMenu.html',
  'OpenChannel.ps1', 'OpenChannel.cmd', 'StartLiveTV.cmd',
  'OpenChannel.debug.log', 'channel_check_results.txt', 'channel_names.txt',
  'lua\extensions\ChannelChecker.lua', 'lua\intf\LiveTVMenu.lua'
)
foreach ($f in $files) {
  $p = Join-Path $AppDataVlc $f
  if (Test-Path $p) { Remove-Item $p -Force; Write-Host "  - $f" }
}

# Backups made by the installer
Get-ChildItem -Path $AppDataVlc -Filter '*.preinstall.bak' -ErrorAction SilentlyContinue | ForEach-Object {
  Remove-Item $_.FullName -Force; Write-Host "  - $($_.Name)"
}

# Empty lua dirs we created
foreach ($d in @('lua\extensions', 'lua\intf', 'lua')) {
  $p = Join-Path $AppDataVlc $d
  if ((Test-Path $p) -and -not (Get-ChildItem $p -Force)) { Remove-Item $p -Force }
}

# 4. vlcrc: disable the hotkeys/setting we wrote (VLC falls back to its defaults)
$vlcrc = Join-Path $AppDataVlc 'vlcrc'
if (Test-Path $vlcrc) {
  $raw = [System.IO.File]::ReadAllText($vlcrc)
  $raw = $raw -replace '(?m)^key-next=n.*$', '#key-next=n'
  $raw = $raw -replace '(?m)^key-prev=p.*$', '#key-prev=p'
  [System.IO.File]::WriteAllText($vlcrc, $raw, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host "  - vlcrc n/p hotkeys disabled"
}

Write-Host ""
Write-Host "Uninstall complete." -ForegroundColor Green
Write-Host "  Browser stars were kept. Install again with: install\install.ps1"
