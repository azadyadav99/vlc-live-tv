param([Parameter(Mandatory = $true, Position = 0)][string]$Raw)

$ErrorActionPreference = 'Stop'
$u = $Raw.Trim().Trim('"')

try { $u = [uri]::UnescapeDataString($u) } catch { }   # single layer: menu encodes once

if ($u -match '^(?i)livetv://') { $u = $u.Substring(9) }
if ($u -match '^(?i)livetv:') { $u = $u -replace '^(?i)livetv:', '' }
if ($u -match '^(?i)livetv://') { $u = $u.Substring(9) }

$u = $u.Trim().Trim('"')

if ($u -match '^(?i)^(https?)//') {
    $u = $u -replace '^(?i)^(https?)//', '$1://'
}
if ($u -match '^(?i)^https//') { $u = 'https://' + $u.Substring(8) }
if ($u -match '^(?i)^http//') { $u = 'http://' + $u.Substring(7) }

$u = $u.Trim().Trim('"')
# some browsers append a slash (...m3u8/) which 404s on stream CDNs
if ($u -match '\.[A-Za-z0-9]{1,5}/+$') { $u = $u -replace '/+$', '' }

if ($u -notmatch '^(?i)https?://' -and $u -notmatch '^(?i)file:///') {
    $log = Join-Path $env:APPDATA 'vlc\OpenChannel.debug.log'
    Add-Content -LiteralPath $log ("REJECT u=$u raw=$Raw")
    exit 2
}

function Find-Vlc {
  $cands = @(
    'C:\Program Files\VideoLAN\VLC\vlc.exe',
    'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe',
    (Join-Path $env:LOCALAPPDATA 'Programs\VideoLAN\VLC\vlc.exe')
  )
  foreach ($c in $cands) { if ($c -and (Test-Path $c)) { return $c } }
  $w = Get-Command vlc.exe -ErrorAction SilentlyContinue
  if ($w) { return $w.Source }
  return $null
}
$vlc = Find-Vlc
$log = Join-Path $env:APPDATA 'vlc\OpenChannel.debug.log'
if (-not $vlc) {
  Add-Content -LiteralPath $log ("REJECT u=$u raw=$Raw reason=vlc-not-found")
  exit 3
}
$wd = Join-Path $env:APPDATA 'vlc'
Start-Process -FilePath $vlc -WorkingDirectory $wd -ArgumentList @('--one-instance', $u)
exit 0
