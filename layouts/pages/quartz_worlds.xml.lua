local env = session.get("quartz-env")
local connections = env.CLIENT_API.internal.connections

function on_open()
    local worlds = world.get_list()
    for _, info in ipairs(worlds) do
        local major, minor = app.get_version()
        if info.version[1] > major or info.version[2] > minor then
            info.versionColor = "#A02010"
        else
            info.versionColor = "#808080"
        end

        info.versionString = string.format("%s.%s", unpack(info.version))

        if file.exists(string.format("user:worlds/%s/server.bjson", info.name)) then
            document.worlds:add(gui.template("quartz_world", info))
        end
    end
end

function open_world(name)
    local config = json.parse(file.read("quartz:resources/server_config.json"))
    config.game.main_world = name
    config.game.worlds[name] = config.game.worlds.overworld

    connections.run_single(config, "main", env.CONFIG.Account.name, env.CONFIG.Account.name, function ()
        print("кайф, подключились")
    end)
    menu.page = "quartz_connection"
end
