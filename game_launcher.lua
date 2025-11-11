local gameLauncher = {}

function gameLauncher.launch(game)
    if not (game and game.exe and game.exe ~= "") then
        print("No valid executable for: " .. (game and game.title or "Unknown"))
        return
    end

    print("Launching: " .. game.title)

    local os_type = love.system.getOS()
    local cmd

    if os_type == "Windows" then
        -- Convert paths to Windows-style backslashes
        local gameDir = love.filesystem.getWorkingDirectory():gsub("/", "\\") .. "\\" .. game.path:gsub("/", "\\")
        print("Game Directory: " .. gameDir)

        
        -- Change to game directory and launch
        cmd = 'cmd /c cd /d "' .. gameDir .. '" && start /B "" "' .. game.exe .. '"'
    else  -- Linux, OS X
        cmd = 'wine "' .. game.exe .. '" &'
    end

    print("Executing: " .. cmd)

    local success, _, exit_code = os.execute(cmd)
    if not success then
        print("Failed to launch game: " .. game.title .. " (Exit code: " .. tostring(exit_code) .. ")")
    end
end

return gameLauncher
