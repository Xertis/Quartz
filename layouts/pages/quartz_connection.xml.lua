function back()
    time.post_runnable(function()
        menu:reset()
        app.reset_content(true)
        menu.page = "main"
    end)
end
