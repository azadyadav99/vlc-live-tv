# Live TV for VLC

Curated live TV playlist + channel menu for VLC on Windows.

- **1980 channels** grouped by Featured, Kids & Cartoons, India, countries, and more
- **Channel numbers** on every channel (playlist order)
- **★ Favorites** saved in your browser (localStorage)
- **One-click** desktop launcher opens VLC + menu
- **`livetv://` protocol** — click a channel in the menu, it plays in VLC (`--one-instance`)

> Streams are third-party public links that can break or vary by region. This project packages a playlist and UI only; it does not host or sell content.

## Requirements

- Windows 10/11
- [VLC 3.x](https://www.videolan.org/) (default path `C:\Program Files\VideoLAN\VLC\vlc.exe`)

## Install

```powershell
powershell -ExecutionPolicy Bypass -File install\install.ps1
```

Or run `install\install.ps1` from the repo root.

What it does:

1. Copies `playlist\livetv.m3u8`, `menu\ChannelMenu.html`, and VLC helper scripts into `%APPDATA%\vlc`
2. Backs up existing files as `*.preinstall.bak`
3. Sets VLC hotkeys: **n** = next, **p** = previous
4. Registers `livetv://` for the current user
5. Creates a **Live TV** desktop shortcut

## Use

1. Double-click **Live TV** on the desktop (or `StartLiveTV.cmd` in `%APPDATA%\vlc`)
2. VLC opens the playlist; the browser opens **ChannelMenu.html**
3. Click any channel → VLC plays it (one instance)
4. Click **★** on a channel to favorite; **★ Favorites** filters to stars only
5. Search by channel name, group, or channel number

### Keys inside VLC

| Key | Action |
|-----|--------|
| n | Next channel |
| p | Previous channel |

## Layout

```
vlc-live-tv/
  playlist/livetv.m3u8      # 1980 channels
  menu/ChannelMenu.html     # channel list UI
  vlc/                      # protocol handler + launchers + optional Lua
  install/install.ps1       # one-shot installer
```

## Edit channels

- Edit `playlist\livetv.m3u8` (`#EXTINF` line + URL line)
- Keep HTML in sync with the playlist, or re-copy after structural changes
- Re-run `install\install.ps1` (or copy the two files into `%APPDATA%\vlc`)

## Manual install (no scripts, no ZIP)

If your browser blocks the ZIP (PowerShell installers often trip false positives) or you prefer zero scripts:

1. On the repo page, open each file and use its download (raw) button.
2. Copy these into `%APPDATA%\vlc` (create the folder if missing):
   `playlist\livetv.m3u8`, `menu\ChannelMenu.html`, `vlc\OpenChannel.cmd`, `vlc\OpenChannel.ps1`.
3. Double-click `livetv.m3u8` to open VLC with the playlist; open `ChannelMenu.html` in your browser.

Channel clicks use the `livetv://` protocol. Register it yourself (one-time, per user) if you skipped the installer:

```
reg add "HKCU\Software\Classes\livetv" /ve /d "URL:Live TV protocol" /f
reg add "HKCU\Software\Classes\livetv" /v "URL Protocol" /t REG_SZ /d "" /f
reg add "HKCU\Software\Classes\livetv\shell\open\command" /ve /d "\"%APPDATA%\vlc\OpenChannel.cmd\" \"%1\"" /f
```

## Upgrade

Just re-run `install\install.ps1` from the new version. It overwrites the payload and re-patches VLC safely. (Close VLC first.)

## Uninstall

Close VLC, then run:

```powershell
powershell -ExecutionPolicy Bypass -File install\uninstall.ps1
```

It removes the playlist, menu, launchers, Lua files, logs, `.preinstall.bak` backups, the desktop shortcut and the `livetv://` protocol, and disables the n/p hotkeys in vlcrc. Browser stars (favorites) are kept.

Manual equivalent: delete from `%APPDATA%\vlc`: `livetv.m3u8`, `ChannelMenu.html`, `OpenChannel.*`, `StartLiveTV.cmd`, `lua\extensions\ChannelChecker.lua`, `lua\intf\LiveTVMenu.lua`. Remove the desktop shortcut. Optional: delete registry key `HKCU\Software\Classes\livetv`.

## License

MIT — see [LICENSE](LICENSE).

Playlist links are not owned by this project; use responsibly and respect local laws and terms of service.
