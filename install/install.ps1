# Live TV installer — copies playlist + menu + protocol handler into %APPDATA%\vlc
# Requires VLC 3.x installed (default path below). Safe to re-run.
$ErrorActionPreference = 'Stop'
$VlcExe = 'C:\Program Files\VideoLAN\VLC\vlc.exe'
$AppDataVlc = Join-Path $env:APPDATA 'vlc'
$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path $RepoRoot)) { $RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot) }

function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $dir = Split-Path -Parent $Path
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host "Live TV installer" -ForegroundColor Cyan
Write-Host "  VLC:  $VlcExe"
Write-Host "  Dest: $AppDataVlc"

if (-not (Test-Path $VlcExe)) {
  Write-Warning "VLC not found at $VlcExe. Install VLC 3.x first, then re-run."
  exit 1
}
if (-not (Test-Path $AppDataVlc)) {
  New-Item -ItemType Directory -Force -Path $AppDataVlc | Out-Null
}

# Backup existing files once
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
foreach ($name in @('livetv.m3u8','ChannelMenu.html','OpenChannel.ps1','OpenChannel.cmd','StartLiveTV.cmd')) {
  $p = Join-Path $AppDataVlc $name
  if ((Test-Path $p) -and -not (Test-Path "$p.preinstall.bak")) {
    Copy-Item $p "$p.preinstall.bak" -Force
  }
}

# Copy payload
$files = @(
  @{ S = "playlist\livetv.m3u8";      D = 'livetv.m3u8' },
  @{ S = "menu\ChannelMenu.html";      D = 'ChannelMenu.html' },
  @{ S = "vlc\OpenChannel.ps1";        D = 'OpenChannel.ps1' },
  @{ S = "vlc\OpenChannel.cmd";        D = 'OpenChannel.cmd' },
  @{ S = "vlc\StartLiveTV.cmd";        D = 'StartLiveTV.cmd' },
  @{ S = "vlc\ChannelChecker.lua";     D = 'lua\extensions\ChannelChecker.lua' },
  @{ S = "vlc\LiveTVMenu.lua";         D = 'lua\intf\LiveTVMenu.lua' }
)
foreach ($f in $files) {
  $src = Join-Path $RepoRoot $f.S
  $dst = Join-Path $AppDataVlc $f.D
  $dstDir = Split-Path -Parent $dst
  if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
  if (-not (Test-Path $src)) { throw "Missing payload: $src" }
  Copy-Item $src $dst -Force
  Write-Host "  + $($f.D)"
}

# vlcrc tweaks: next/prev hotkeys + autoload extensions
$vlcrc = Join-Path $AppDataVlc 'vlcrc'
if (Test-Path $vlcrc) {
  $raw = [System.IO.File]::ReadAllText($vlcrc)
  $raw = $raw -replace '(?m)^#?key-next=.*$', "key-next=n`t6"
  $raw = $raw -replace '(?m)^#?key-prev=.*$', "key-prev=p`t4"
  $raw = $raw -replace '(?m)^#?qt-autoload-extensions=.*$', 'qt-autoload-extensions=1'
  [System.IO.File]::WriteAllText($vlcrc, $raw, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host "  + vlcrc hotkeys (n/p) + extensions"
} else {
  Write-Warning "vlcrc not found — skipped hotkey patch"
}

# livetv:// protocol
$reg = 'HKCU:\Software\Classes\livetv'
New-Item -Path $reg -Force | Out-Null
New-Item -Path "$reg\shell\open\command" -Force | Out-Null
Set-Item -Path (Get-Item $reg).PSPath -Value 'URL:Live TV protocol'
Set-Item -Path "HKCU:\Software\Classes\livetv\URL Protocol" -Value ''
$cmd = "`"$AppDataVlc\OpenChannel.cmd`" `"%1`""
Set-Item -Path "$reg\shell\open\command" -Value $cmd
Write-Host "  + livetv:// protocol"

# Desktop shortcut (optional)
$desktop = [Environment]::GetFolderPath('Desktop')
$lnkPath = Join-Path $desktop 'Live TV.lnk'
try {
  $ws = New-Object -ComObject WScript.Shell
  $lnk = $ws.CreateShortcut($lnkPath)
  $lnk.TargetPath = Join-Path $AppDataVlc 'StartLiveTV.cmd'
  $lnk.WorkingDirectory = $AppDataVlc
  $lnk.Description = 'Open Live TV playlist + channel menu'
  $lnk.Save()
  Write-Host "  + Desktop shortcut: Live TV.lnk"
} catch {
  Write-Warning "Could not create desktop shortcut: $_"
}

Write-Host ""
Write-Host "Install complete." -ForegroundColor Green
Write-Host "  Start: Desktop 'Live TV' or StartLiveTV.cmd"
Write-Host "  Menu:  ChannelMenu.html (star favorites saved in browser localStorage)"
Write-Host "  Playlist: livetv.m3u8"
