-- Channel Checker / All Channels extension for VLC
-- Dedicated All Channels menu: Sony Sab first, hierarchy by group, clean broadcast names

local dlg = nil
local lbl_status = nil
local list_channels = nil
local id_to_uri = {}
local id_to_name = {}
local next_id = 1
local btn_cancel = false

local PLAYLIST_CANDIDATES = {
    "livetv.m3u8",
    "livetv.m3u",
    "channels.m3u8"
}

local function clean_name(raw)
    if not raw or raw == "" then return "" end
    local n = raw
    n = n:gsub("%s*%(%d+[pi]%w*%)", "")
    n = n:gsub("%s*%[Geo%-blocked%]", "")
    n = n:gsub("%s*%[Not 24/7%]", "")
    n = n:gsub("%s*%[[^%]]*%]", "")
    n = n:gsub("[%z\1-\8\11\12\14-\31]+", "")
    n = n:gsub("%s+", " ")
    n = n:gsub("^%s+", ""):gsub("%s+$", "")
    n = n:gsub("%s*[?]+$", "")
    if n == "" then return raw end
    return n
end

local function find_playlist_path()
    local temp = os.getenv("TEMP") or os.getenv("TMP") or os.getenv("TMPDIR") or ""
    local datadir = vlc.config.userdatadir() or ""
    local roots = {}
    if temp ~= "" then table.insert(roots, temp) end
    if datadir ~= "" then table.insert(roots, datadir) end
    table.insert(roots, ".")
    for _, root in ipairs(roots) do
        for _, name in ipairs(PLAYLIST_CANDIDATES) do
            local path = root .. "\\" .. name
            local f = io.open(path, "r")
            if f then
                f:close()
                return path
            end
            path = root .. "/" .. name
            f = io.open(path, "r")
            if f then
                f:close()
                return path
            end
        end
    end
    return nil
end

local function parse_attr(line, key)
    local pat = key .. '="([^"]*)"'
    local v = line:match(pat)
    if v then return v end
    pat = key .. "=([^,%s]+)"
    return line:match(pat)
end

local function read_playlist_entries()
    local path = find_playlist_path()
    local entries = {}
    if path then
        local f = io.open(path, "r")
        if f then
            local last_extinf = nil
            for line in f:lines() do
                if line:match("^#EXTINF") then
                    local comma = line:find(",[^,]*$")
                    local disp = ""
                    if comma then
                        disp = line:sub(comma + 1)
                    end
                    last_extinf = {
                        name = clean_name(disp),
                        group = parse_attr(line, "group%-title") or "All Channels",
                        uri = ""
                    }
                elseif last_extinf and not line:match("^#") and line:match("%S") then
                    last_extinf.uri = line:gsub("^%s+", ""):gsub("%s+$", "")
                    table.insert(entries, last_extinf)
                    last_extinf = nil
                end
            end
            f:close()
        end
    end

    if #entries == 0 then
        local items = vlc.playlist.get()
        if items then
            for _, it in ipairs(items) do
                local name = clean_name(it.name or it.title or "")
                local uri = it.uri or it.path or ""
                if name ~= "" and uri ~= "" then
                    table.insert(entries, {
                        name = name,
                        group = "All Channels",
                        uri = uri
                    })
                end
            end
        end
    end
    return entries
end

local function is_sony_sab(name)
    if not name then return false end
    local lower = name:lower()
    return lower == "sony sab"
        or lower == "sonysab"
        or lower:find("sony sab", 1, true) == 1
        or lower:find("sonysab", 1, true) == 1
end

local function build_display_list(entries)
    local sony_sab = nil
    local featured = {}
    local by_group = {}
    local order = {}

    for _, e in ipairs(entries) do
        local name = e.name or ""
        local g = e.group or "All Channels"
        if is_sony_sab(name) then
            if not sony_sab then
                sony_sab = { name = "Sony Sab", uri = e.uri, group = "Featured" }
            end
        elseif g == "Featured" then
            table.insert(featured, e)
        else
            if not by_group[g] then
                by_group[g] = {}
                table.insert(order, g)
            end
            table.insert(by_group[g], e)
        end
    end

    local display = {}
    local function push_header(text)
        table.insert(display, { header = true, text = text, uri = "" })
    end
    local function push_item(e)
        table.insert(display, {
            header = false,
            text = e.name or "",
            uri = e.uri or ""
        })
    end

    push_header("FEATURED")
    if sony_sab then
        push_item(sony_sab)
    end
    table.sort(featured, function(a, b)
        return (a.name or ""):lower() < (b.name or "")
    end)
    for _, e in ipairs(featured) do
        push_item(e)
    end

    table.sort(order)
    for _, g in ipairs(order) do
        local list = by_group[g]
        table.sort(list, function(a, b)
            return (a.name or ""):lower() < (b.name or ""):lower()
        end)
        push_header(g .. " (" .. tostring(#list) .. ")")
        for _, e in ipairs(list) do
            push_item(e)
        end
    end

    return display
end

local function fill_channel_list(list_widget, display)
    list_widget:clear()
    id_to_uri = {}
    id_to_name = {}
    next_id = 1
    for _, row in ipairs(display) do
        if row.header then
            local hid = -next_id
            id_to_uri[hid] = ""
            id_to_name[hid] = row.text
            list_widget:add_value("== " .. row.text .. " ==", hid)
            next_id = next_id + 1
        else
            local iid = next_id
            id_to_uri[iid] = row.uri
            id_to_name[iid] = row.text
            local prefix = "  "
            if is_sony_sab(row.text) then
                prefix = "* "
            end
            list_widget:add_value(prefix .. row.text, iid)
            next_id = next_id + 1
        end
    end
end

function descriptor()
    return {
        title = "Channel Checker",
        version = "2.0",
        author = "opencode",
        url = "",
        description = "All Channels list with Sony Sab first, plus channel health checks",
        capabilities = {"menu"}
    }
end

function menu()
    return {
        "All Channels",
        "Check All Channels",
        "Show All Channel Names"
    }
end

function trigger_menu(id)
    if id == 1 then
        show_all_channels()
    elseif id == 2 then
        check_all_channels()
    elseif id == 3 then
        show_all_names()
    end
end

function activate()
    show_all_channels()
end

function deactivate()
    btn_cancel = true
    if dlg then
        dlg:delete()
        dlg = nil
    end
end

local function status(msg)
    if lbl_status then
        lbl_status:set_text(msg or "")
        if dlg then dlg:update() end
    end
end

local function ensure_dialog(title)
    if dlg then
        dlg:delete()
        dlg = nil
    end
    dlg = vlc.dialog(title or "All Channels")
    return dlg
end

function show_all_channels()
    ensure_dialog("All Channels")
    dlg:add_label("<b>All Channels</b> — Sony Sab is first. Select a channel, then Play Selected.", 1, 1, 8, 1)
    lbl_status = dlg:add_label("Loading channels...", 1, 2, 8, 1)
    list_channels = dlg:add_list(1, 3, 8, 18)
    dlg:add_button("Play Selected", play_selected_cb, 1, 21, 3, 1)
    dlg:add_button("Refresh", refresh_cb, 4, 21, 2, 1)
    dlg:add_button("Close", deactivate, 6, 21, 3, 1)
    dlg:show()

    local entries = read_playlist_entries()
    local display = build_display_list(entries)
    fill_channel_list(list_channels, display)
    status(string.format("Loaded %d channels (%d rows). Sony Sab is #1 under FEATURED.", #entries, next_id - 1))
    dlg:update()
end

function refresh_cb()
    show_all_channels()
end

local function get_first_sel(list)
    if not list then return 0 end
    local sel = list:get_selection()
    if not sel then return 0 end
    for index, _ in pairs(sel) do
        return index
    end
    return 0
end

function play_selected_cb()
    if not list_channels then return end
    local index = get_first_sel(list_channels)
    if index == 0 or index == nil then
        status("No channel selected.")
        return
    end
    local uri = id_to_uri[index]
    local name = id_to_name[index] or ""
    if not uri or uri == "" then
        status("Group header selected — pick a channel under it.")
        return
    end
    status("Playing: " .. name)
    vlc.playlist.clear()
    vlc.playlist.add({ { path = uri, name = name } })
    vlc.playlist.play()
end

function show_all_names()
    show_all_channels()
    local entries = read_playlist_entries()
    local out_path = vlc.config.userdatadir() .. "\\channel_names.txt"
    local f = io.open(out_path, "w")
    if f then
        local display = build_display_list(entries)
        local n = 0
        for _, row in ipairs(display) do
            if row.header then
                f:write("\n== " .. row.text .. " ==\n")
            else
                n = n + 1
                f:write(string.format("%d. %s\n", n, row.text))
            end
        end
        f:close()
        status(string.format("Saved %d names to channel_names.txt", n))
    end
end

function check_all_channels()
    ensure_dialog("Channel Check")
    dlg:add_label("<b>Check All Channels</b>", 1, 1, 8, 1)
    lbl_status = dlg:add_label("Starting...", 1, 2, 8, 1)
    list_channels = dlg:add_list(1, 3, 8, 18)
    dlg:add_button("Cancel", function() btn_cancel = true end, 1, 21, 3, 1)
    dlg:add_button("Close", deactivate, 4, 21, 3, 1)
    dlg:show()

    local entries = read_playlist_entries()
    local total = #entries
    if total == 0 then
        status("Playlist is empty.")
        return
    end
    list_channels:clear()
    id_to_uri = {}
    id_to_name = {}
    btn_cancel = false

    local ok_count = 0
    local fail_count = 0
    local out_path = vlc.config.userdatadir() .. "\\channel_check_results.txt"
    local f = io.open(out_path, "w")
    if f then
        f:write("VLC Channel Check Results\n")
        f:write(string.format("Total: %d\n\n", total))
    end

    for i, ch in ipairs(entries) do
        if btn_cancel then break end
        status(string.format("Checking %d / %d ...", i, total))

        local status_str = "FAIL"
        local stream = nil
        if ch.uri ~= "" then
            stream = vlc.stream(ch.uri)
        end

        if stream then
            local data = stream:read(1024)
            if data and #data > 0 then
                status_str = "OK"
                ok_count = ok_count + 1
            else
                fail_count = fail_count + 1
            end
        else
            fail_count = fail_count + 1
        end

        local line = string.format("[%s] %s", status_str, ch.name)
        local hid = -i
        id_to_uri[hid] = ""
        id_to_name[hid] = ch.name
        list_channels:add_value(line, hid)
        if f then
            f:write(string.format("%s | %s | %s\n", status_str, ch.name, ch.uri))
            f:flush()
        end
    end

    if f then
        f:write(string.format("\nOK: %d  FAIL: %d\n", ok_count, fail_count))
        f:close()
    end

    if not btn_cancel then
        status(string.format(
            "Done. OK: %d  FAIL: %d  (saved to channel_check_results.txt)",
            ok_count, fail_count))
    end
end

function close_cb()
    deactivate()
end
