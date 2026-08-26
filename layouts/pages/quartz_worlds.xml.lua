local instances = require "instances_manager"

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
    instances.open_world(name)
end
