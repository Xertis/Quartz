local function boot_client()
    app.reset_content()
    app.config_packs({ "client", "quartz" })
    app.load_content()

    session.reset("quartz-env")
    session.get("quartz-env")["main_page"] = "quartz_worlds"
    require "quartz:run/main" (app, boot_client)
end

boot_client()
