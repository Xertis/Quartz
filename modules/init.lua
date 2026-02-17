return function(app, boot_client)
    require "constants"
    require "globals"

    PACK_ENV["boot_client"] = boot_client

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

    SHELL_CONFIG = json.parse(file.read(SHELL_CONFIG_PATH))

    ---
    local api = require "client:api/v2/shell/api"
    CLIENT_API = api

    local constants = api.register_as_shell(SHELL_CONFIG, require "api/api")

    PROTOCOL_VERSION = constants.protocol_version
    API_VERSION = constants.api_version
    ---
    local copy_app = table.copy(app)
    local original_reset = app.reset_content

    app.reset_content = function(reset_env)
        if reset_env == true then return original_reset() end
        original_reset(table.merge({ "client", PACK_ID }, reset_env or {}))
    end

    PACK_ENV["app"] = app
    ---
    session.reset_entry("quartz-env")
    local env_meta = {
        __index = PACK_ENV,
        __newindex = function(t, key, value)
            rawset(PACK_ENV, key, value)
        end
    }

    setmetatable(session.get_entry("quartz-env"), env_meta)
    ---

    api.internal.run(copy_app)
end
