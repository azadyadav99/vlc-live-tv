-- LiveTVMenu: interface scripts cannot use vlc.dialog (extension-only API).
-- Channel menu is ChannelMenu.html; play links use livetv:// -> VLC --one-instance.
function main()
    vlc.msg.info("[LiveTVMenu] Channel menu is ChannelMenu.html (open with desktop Live TV icon).")
    vlc.msg.info("[LiveTVMenu] vlc.dialog is not available in interface scripts.")
end