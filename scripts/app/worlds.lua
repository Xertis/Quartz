local function boot_client()
    app.reset_content()
    app.config_packs({ "client", "quartz" })
    app.load_content()

    require "quartz:run/single" (app, boot_client)
end

boot_client()
