local function boot_client()
    app.reset_content()
    app.config_packs({ "client", "quartz" })
    app.load_content()

    require "quartz:init" (table.copy(app), boot_client)
end

boot_client()
