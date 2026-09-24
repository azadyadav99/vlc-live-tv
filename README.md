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

## Uninstall

Delete from `%APPDATA%\vlc`: `livetv.m3u8`, `ChannelMenu.html`, `OpenChannel.*`, `StartLiveTV.cmd`.  
Remove the desktop shortcut. Optional: delete registry key `HKCU\Software\Classes\livetv`.

## License

MIT — see [LICENSE](LICENSE).

Playlist links are not owned by this project; use responsibly and respect local laws and terms of service.
