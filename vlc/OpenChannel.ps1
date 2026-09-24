param([Parameter(Mandatory = $true, Position = 0)][string]$Raw)

$ErrorActionPreference = 'Stop'
$u = $Raw.Trim().Trim('"')

for ($i = 0; $i -lt 3; $i++) {
    try { $u = [uri]::UnescapeDataString($u) } catch { break }
}

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

if ($u -notmatch '^(?i)https?://' -and $u -notmatch '^(?i)file:///') {
    $log = Join-Path $env:APPDATA 'vlc\OpenChannel.debug.log'
    Add-Content -LiteralPath $log ("REJECT u=$u raw=$Raw")
    exit 2
}

$vlc = 'C:\Program Files\VideoLAN\VLC\vlc.exe'
$wd = Join-Path $env:APPDATA 'vlc'
Start-Process -FilePath $vlc -WorkingDirectory $wd -ArgumentList @('--one-instance', $u)
$log = Join-Path $env:APPDATA 'vlc\OpenChannel.debug.log'
Add-Content -LiteralPath $log ("OK u=$u raw=$Raw")
exit 0
