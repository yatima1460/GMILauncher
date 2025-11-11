local gameLauncher = {}

function gameLauncher.launch(game)
    if not (game and game.start and game.start ~= "") then
        print("No valid path for: " .. (game and game.title or "Unknown"))
        return
    end

    print("Launching: " .. game.title)

    local os_type = love.system.getOS()
    local cmd

    if os_type == "Windows" then
        cmd = 'start "" "' .. game.start .. '"'
    else  -- Linux, OS X
        cmd = 'wine "' .. game.start .. '"'
    end

    if not os.execute(cmd) then
        print("Failed to launch game: " .. game.title)
    end
end

return gameLauncher
