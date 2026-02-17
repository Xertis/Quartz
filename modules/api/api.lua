local module = {
    states = {},
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

function module.states.get_identity()
    return CONFIG.Account.name
end

function module.states.get_username()
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

        app.config_packs({ PACK_ID, "client" })
        app.load_content()

        menu.page = "quartz_connection"
        local document = Document.new("quartz:pages/quartz_connection")

        document.info.text = reason
    end)
end

return module
