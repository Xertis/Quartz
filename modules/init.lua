return function(app)
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

    app.reset_content = function (packs)
        if packs == true then return original_reset() end
        original_reset(table.merge({"client", PACK_ID}, packs))
    end
    PACK_ENV["app"] = app
    ---

    api.internal.run(copy_app)
end