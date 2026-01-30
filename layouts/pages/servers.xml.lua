local server_list = document.server_list
local servers_infos = {}
local handlers = {}

local connections = CLIENT_API.internal.connections

function place_server(panel, server_info, callback)
    server_info.callback = callback
    panel:add(gui.template("server", server_info))
end

function refresh()
    server_list:clear()
    for id, server in ipairs(CONFIG.Servers) do

        place_server(server_list, {
            id = id,
            server_favicon = "gui/not_connected",
            server_name = server.name,
            server_desc = '',
            server_status = COLORS.gray .. "pending...",
            players_online = ""
        })

        connections.get_status(
            server.ip, id, server.name,
            handlers.on_status,
            handlers.on_disconnect
        )
    end
    -- TODO: Реализовать API
    --events.emit("quartz:server_list_opened", document)
end

function on_open()
    refresh()
end

function handlers.on_status(server, packet)
    assets.load_texture(packet.favicon, server.name .. ".icon")

    local friends = {}

    for id, friend in ipairs(packet.friends_states) do
        if friend == true then
            table.insert(friends, CONFIG.Account.friends[id])
        end
    end

    servers_infos[server.id] = {
        name = server.name,
        max = packet.max,
        online = packet.online,
        description = packet.description,
        engine_version = packet.engine_version,
        neutron_version = packet.neutron_version,
        protocol_version = packet.protocol_version,
        friends_online = friends,
        server = server
    }

    if table.count_pairs(friends) > 0 then
        document["serverdata_" .. server.id].color = {139, 0, 255, 32}
    end

    document["servericon_" .. server.id].src = server.name .. ".icon"
    document["playersonline_" .. server.id].text = string.left_pad(string.format("%s / %s", packet.online, packet.max), 10)
    document["serverdesc_" .. server.id].text = packet.short_desc
    document["serverstatus_" .. server.id].text = ''
end

function handlers.on_disconnect(server, err)
    if err == nil then return end
    document["serverstatus_" .. server.id].text = COLORS.red .. "offline"
end

function get_server_info(id)
    local info = servers_infos[id]
    if not info then return end

    info.friends_online = info.friends_online or {}

    document.engine_version.text = info.engine_version or "None"
    document.neutron_version.text = info.neutron_version or "None"
    document.protocol_version.text = info.protocol_version or "None"

    if info.protocol_version ~= PROTOCOL_VERSION then
        document.protocol_version.color = {255, 0, 0, 255}
    end

    document.description.text = info.description or "None"
    document.friends.text = table.concat(info.friends_online, ', ')

    if #info.friends_online == 0 then
        document.friends.text = "None"
    end
end

function remove_server(id)
    table.remove(CONFIG.Servers, id)
    update_config()

    document["serverdata_" .. id]:destruct()
end

local edited_server = nil
function start_edit(id)
    if edited_server then
        return
    end

    id = tonumber(id)

    local info = CONFIG.Servers[id]
    edited_server = id
    document.root:add(gui.template("server_edit", {
        name = info.name,
        ip = info.ip
    }))
end

function edit_server(data)
    local server_ip = data.ip
    local server_name = data.name

    if server_name then
        CONFIG.Servers[edited_server].name = server_name
    end

    if server_ip then
        CONFIG.Servers[edited_server].ip = server_ip
    end
end

function finish_edit()
    update_config()
    edited_server = nil
    refresh()
    document.server_edit:destruct()
end

function edit_server_name(text)
    edit_server({name = text})
end

function edit_server_ip(text)
    edit_server({ip = text})
end

function connect(id)
    local info = servers_infos[id]
    if not info then return end

    local server = info.server

    if info.protocol_version ~= PROTOCOL_VERSION then
        gui.alert(gui.str("quartz.different_protocols", "quartz"))
        return
    end

    menu.page = "quartz_connection"
    connections.join(
        server.ip, id,
        CONFIG.Account.name, CONFIG.Account.name,
        -- on_connect
        function ()
            print("подключились")
        end,
        -- on_disconnect
        function ()
            print("отключились")
            menu:reset()
            menu.page = "quartz_connection"
            local document = Document.new("quartz:pages/quartz_connection")

            document.info.text = gui.str("quartz.connection_interrupted")
        end
    )

    menu.page = "quartz_connection"
end

function to_config()
    menu.page="quartz_config"
    events.emit("quartz:config_opened", document)
end

function main_menu()
    app.reset_content(true)
    menu.page="main"
end