local name = nil
local env = session.get("quartz-env")

function on_open()
    name = CONFIG.Account.name
    document.username.text = CONFIG.Account.name
end

function username_changed(text)
    name = text
end

function add_server()
    local server_ip = document.ip.text
    local server_name = document.server_name.text

    if not server_name or not server_ip then
        return
    end

    table.insert(CONFIG.Servers, { name = server_name, ip = server_ip })
end

function finish()
    CONFIG.Account.name = name
    PERSISTENT_ENV.name = name

    update_config()
    menu:back()
end

function open_cache_folder()
    local packs_cache_path = env.CLIENT_API.internal.packs.get_cache_path()
    if (file.isdir(packs_cache_path) == false) then
        file.mkdirs(packs_cache_path)
    end
    app.open_folder(packs_cache_path)
end