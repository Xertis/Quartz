local env = session.get_entry("quartz-env")

local default_player_icons = {
    entity = "gui/entity",
    friend = "gui/friend",
}

local custom_icons = {}

function place_player(info)
    document.player_list:add(gui.template("player", info))
end

function leave()
    env.CLIENT_API.internal.connections.disconnect(env.SERVER, function()
        time.post_runnable(function()
            if world.is_open() then
                app.close_world()
            end
            app.reset_content(true)
        end)
    end)
end

-- Тута надо функцию переименовать, но я пока не придумал
function player(id)
    local name = document["player_name_" .. id].text
    local is_friend = table.has(env.CONFIG.Account.friends, id)

    local custom_icon = nil
    if not table.has(default_player_icons, document["player_icon_" .. id].src) then
        custom_icon = document["player_icon_" .. id].src
    end

    if is_friend then
        document["player_icon_" .. id].src = custom_icon or default_player_icons.entity
        document["player_action_" .. id].src = "gui/invite_friend"
        table.remove_value(env.CONFIG.Account.friends, name)
    else
        document["player_icon_" .. id].src = custom_icon or default_player_icons.friend
        document["player_action_" .. id].src = "gui/delete_friend"
        table.insert(env.CONFIG.Account.friends, name)
    end

    update_config()
end

function update()
    local player_list = env.CLIENT_API.extensions.sandbox.players.get_all()
    local players_online = table.count_pairs(player_list or {})

    local friends = table.copy(env.CONFIG.Account.friends)
    -- TODO: Исправить пинг
    local wait_time = math.max(time.uptime() - env.CLIENT_PLAYER.ping.last_upd - 5, 0)

    document.pid.text = "PID: " .. env.CLIENT_PLAYER.pid
    document.ping.text = "Ping: " .. math.round(wait_time * 1000) .. "ms"
    document.online.text = string.format("Online: %s/%s", players_online + 1, env.SERVER_INFO.max)

    if not player_list or players_online == 0 then
        document.sad.visible = true
        return
    else
        document.sad.visible = false
    end

    for _, player in pairs(player_list) do
        local icon = nil
        local action = nil

        if table.has(friends, player.name) then
            icon = default_player_icons.friend
            action = "gui/delete_friend"
        else
            icon = default_player_icons.entity
            action = "gui/invite_friend"
        end

        place_player({
            id = player.name,
            player_icon = custom_icons[player.name] or icon,
            player_pid = "PID: " .. player.pid,
            player_name = player.name,
            player_action = action
        })
    end
end

function on_open()
    update()
    local player_list = env.CLIENT_API.extensions.sandbox.players.get_all()
    local main_container = document.player_list.parent

    events.emit("quartz:pause_opened", document)

    main_container:setInterval(700, function()
        for _, player in pairs(player_list) do
            local ok, icon = pcall(function()
                return document["player_icon_" .. player.name].src
            end)

            if (ok and icon) and not table.has(default_player_icons, icon) then
                custom_icons[player.name] = icon
            end
        end
        document.player_list:clear()
        update()
        custom_icons = {}
    end)
end
