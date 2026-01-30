local module = {
    states = {}
}

function module.init()
    menu.page = "servers"
end

function module.states.get_identity()
    return CONFIG.Account.name
end

function module.states.get_username()
    return CONFIG.Account.name
end

return module