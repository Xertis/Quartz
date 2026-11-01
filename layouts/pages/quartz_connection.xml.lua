local env = session.get("quartz-env")
local connections = env.CLIENT_API.internal.connections

local server_ip = nil
local server_id = nil

local download_server = nil
local content_list = nil
local download_size = 0
local download_speed = {
    bytes_size = 0,
    prev_bytes_size = 0
}

local function on_progress(progress)
    download_speed.bytes_size = progress
    local bg_size = document.progress_bg.size
    local progress_percentage = math.floor(progress / download_size * 100)
    document.progress.size = { math.floor(bg_size[1] * progress_percentage / 100), bg_size[2] }
end

local function on_stop(success)
    if (success == true) then
        document.download_string.text = "Download completed"
        document.download_panel:add(gui.template("reconnect_button", {}))
    else
        if (download_server == nil) then
            document.download_string.text = "Canceled by user"
        else
            document.download_string.text = "Error"
        end
    end
    document.speed.visible = false
    download_server = nil
end

local function convert_speed(size_bytes)
    if (size_bytes > 1048576) then
        return math.round(size_bytes / 1048576, 2) .. " MiB/s"
    elseif (size_bytes > 1024) then
        return math.round(size_bytes / 1024, 2) .. " KiB/s"
    end
    return size_bytes .. " B/s"
end

function request_content(server_ip, server_name)
    document.download_panel:clear()
    document.download_panel:add(gui.template("download_panel", {}))
    document.download_panel:setInterval(1000, function()
        local diff = download_speed.bytes_size - download_speed.prev_bytes_size
        download_speed.prev_bytes_size = download_speed.bytes_size
        document.speed.text = convert_speed(diff)
    end)

    download_server = connections.request_content(
        server_ip, server_name,
        content_list,
        {
            on_progress = on_progress,
            on_stop = on_stop
        }
    )
end

local function convert_size(size_bytes)
    if (size_bytes > 1000000) then
        return math.round(size_bytes / 1000000, 2) .. " MB"
    elseif (size_bytes > 1000) then
        return math.round(size_bytes / 1000, 2) .. " KB"
    end
    return size_bytes .. " B"
end

function on_disconnect(server, download_content)
    if (download_content.allowed == false) then
        return
    end

    server_id = server.id
    server_ip = server.ip

    content_list = {}
    download_size = 0
    for server_pack_id, server_pack_info in pairs(download_content.missing_packs) do
        local pack_info = table.copy(server_pack_info)
        pack_info.id = server_pack_id
        table.insert(content_list, pack_info)
        download_size = download_size + pack_info.bytes_size
    end
    document.download_panel:add(gui.template("download_button", {
        size = convert_size(download_size),
        server_ip = server.ip,
        server_name = server.name
    }))
end

function cancel_download()
    if (download_server) then
        connections.disconnect(download_server)

        document.speed.visible = false
        download_server = nil
    end
end

function reconnect()
    if (not server_ip) then
        return
    end
    connections.join(
        server_ip, server_id,
        env.CONFIG.Account.name, env.CONFIG.Account.name,
        function() end,
        function(reason) end
    )
    menu.page = "quartz_connection"
end

function back()
    cancel_download()
    time.post_runnable(function()
        menu:reset()
        app.reset_content()
        menu.page = "main"
    end)
end
