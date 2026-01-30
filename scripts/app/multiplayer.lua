app.reset_content()
app.config_packs({ "client", "quartz" })
app.load_content()

require "quartz:init"(app)