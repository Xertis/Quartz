local function prepare_pause(pause_menu)
    gui_util.add_page_dispatcher(function(name, args)
        if name == "pause" then
            name = pause_menu
        end

        return name, args
    end)
end

return function(app, boot_client)
    PACK_ENV["app"] = app
    PACK_ENV["boot_client"] = boot_client
    require "constants"
    require "globals"

    ---
    local default_config = {
        Account = {
            name = "Test",
            friends = {}
        },
        Servers = {
        },
        Pinned_packs = {
        }
    }

    if not file.exists(CONFIG_PATH) then
        file.write(CONFIG_PATH, json.tostring(default_config))
    end

    CONFIG = table.merge(json.parse(file.read(CONFIG_PATH)), default_config)

    ---
    local api = require "client:api/v2/shell/api"
    CLIENT_API = api

    prepare_pause("quartz_pause")
    local constants = api.register_as_shell(require "api/api")

    PROTOCOL_VERSION = constants.protocol_version
    API_VERSION = constants.api_version
    ---
    session.reset("quartz-env")
    local env_meta = {
        __index = PACK_ENV,
        __newindex = function(t, key, value)
            rawset(PACK_ENV, key, value)
        end
    }

    setmetatable(session.get("quartz-env"), env_meta)
    ---

    api.internal.run(app)
end
