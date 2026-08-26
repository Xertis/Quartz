function back()
    time.post_runnable(function()
        menu:reset()
        app.reset_content()
        menu.page = "main"
    end)
end
