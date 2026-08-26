return function (app, boot_client)
    PACK_ENV["app"] = app
    PACK_ENV["boot_client"] = boot_client
    require "constants"
    require "globals"

    menu.page = "quartz_worlds"
end
