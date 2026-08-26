local env = session.get("quartz-env")
local default_player_icons = {
    entity = "gui/entity",
    friend = "gui/friend",
}
local custom_icons = {}
local rendered_players = {}

local function is_default_icon(src)
    for _, v in pairs(default_player_icons) do
        if v == src then return true end
    end
    return false
end

local function place_player(info)
    document.player_list:add(gui.template("player", info))
    rendered_players[info.id] = true
end

local function remove_player(name)
    local el = document["player_" .. name]
    if el and el.exists then
        el:remove()
    end
    rendered_players[name] = nil
    custom_icons[name]     = nil
end

local function update_player_display(p, friends)
    local icon_el = document["player_icon_" .. p.name]
    local action_el = document["player_action_" .. p.name]
    local pid_el = document["player_pid_" .. p.name]

    if icon_el.exists and not is_default_icon(icon_el.src) then
        custom_icons[p.name] = icon_el.src
    end

    local is_friend = table.has(friends, p.name)
    local icon = custom_icons[p.name] or (is_friend and default_player_icons.friend or default_player_icons.entity)
    local action = is_friend and "gui/delete_friend" or "gui/invite_friend"

    if icon_el.exists then icon_el.src = icon end
    if action_el.exists then action_el.src = action end
    if pid_el and pid_el.exists then pid_el.text = "PID: " .. p.pid end
end

local function sync_players()
    local player_list = env.CLIENT_API.extensions.sandbox.players.get_all()
    local players_online = table.count_pairs(player_list or {})
    local friends = table.copy(env.CONFIG.Account.friends)
    local wait_time = math.max(time.uptime() - env.CLIENT_PLAYER.ping.last_upd - 5, 0)

    document.pid.text = "PID: " .. env.CLIENT_PLAYER.pid
    document.ping.text = "Ping: " .. math.round(wait_time * 1000) .. "ms"
    document.online.text = string.format("Online: %s/%s", players_online + 1, env.SERVER_INFO.max)

    if not player_list or players_online == 0 then
        document.sad.visible = true
        for name in pairs(table.copy(rendered_players)) do
            remove_player(name)
        end
        return
    end
    document.sad.visible = false

    local current = {}
    for _, p in pairs(player_list) do
        current[p.name] = p
    end

    for name in pairs(table.copy(rendered_players)) do
        if not current[name] then
            remove_player(name)
        end
    end

    for name, p in pairs(current) do
        if not rendered_players[name] then
            local is_friend = table.has(friends, name)
            local icon      = custom_icons[name] or
                (is_friend and default_player_icons.friend or default_player_icons.entity)
            local action    = is_friend and "gui/delete_friend" or "gui/invite_friend"
            place_player({
                id            = name,
                player_icon   = icon,
                player_pid    = "PID: " .. p.pid,
                player_name   = name,
                player_action = action,
            })
        else
            update_player_display(p, friends)
        end
    end
end

function leave()
    env.CLIENT_API.internal.connections.disconnect(env.SERVER, function()
        time.post_runnable(function()
            if world.is_open() then
                app.close_world()
            end
            app.reset_content()
            app.load_content()
        end)
    end)
end

function player(id)
    local name = id
    local is_friend = table.has(env.CONFIG.Account.friends, name)
    local icon_el = document["player_icon_" .. id]
    local action_el = document["player_action_" .. id]
    if not icon_el.exists or not action_el.exists then return end

    local custom_icon = not is_default_icon(icon_el.src) and icon_el.src or nil

    if is_friend then
        icon_el.src = custom_icon or default_player_icons.entity
        action_el.src = "gui/invite_friend"
        table.remove_value(env.CONFIG.Account.friends, name)
    else
        icon_el.src = custom_icon or default_player_icons.friend
        action_el.src = "gui/delete_friend"
        table.insert(env.CONFIG.Account.friends, name)
    end
    update_config()
end

function on_open()
    rendered_players = {}
    custom_icons = {}
    sync_players()

    local main_container = document.player_list.parent
    events.emit("quartz:pause_opened", document)

    main_container:setInterval(700, sync_players())
end
