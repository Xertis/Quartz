local module = {}

function module.open_world(name)
    local packinfo = pack.get_info("server")
    local path = packinfo.path

    local pipe = file.open_named_pipe("neutron_root_client", "w")
    app.start_background_instance(path .. "/scripts/standalone.lua", "export:background.log")
    pipe:write_line("amogus")
end

return module
