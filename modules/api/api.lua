local module = {
    players = {},
    handlers = {
        game = {}
    }
}

function module.init()
    local packs = CLIENT_API.internal.packs
    for _, pack in ipairs(pack.get_available()) do
        if table.has(CONFIG.Pinned_packs, pack) then
            packs.insert_pack(pack)
        end
    end
    packs.reload_packs(true)

    packs.init_scripts()
    menu.page = "servers"
end

function module.players.get_main_identity()
    return CONFIG.Account.name
end

function module.players.get_main_username()
    return CONFIG.Account.name
end

function module.handlers.game.join(server, client_player)
    CLIENT_PLAYER = client_player
    SERVER = server
end

function module.handlers.game.on_disconnect(server, packet)
    packet = packet or {}
    time.post_runnable(function()
        local reason = packet.reason or gui.str("quartz.connection_interrupted")
        if world.is_open() then
            app.close_world()
        end

        app.reset_content({ PACK_ID, "client" })
        app.config_packs({ PACK_ID, "client" })
        app.load_content()

        menu.page = "quartz_connection"
        local document_name = "quartz:pages/quartz_connection"
        local document = Document.new(document_name)
        local document_env = gui.get_env(document_name)

        document.info.text = reason
        document_env.on_disconnect(server, json.parse(packet.download_content))
    end)
end

return module
