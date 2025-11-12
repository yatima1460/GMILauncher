local gameLauncher = {}

function gameLauncher.launch(game, launcher)
    if not (game and game.exe and game.exe ~= "") then
        print("No valid executable for: " .. (game and game.title or "Unknown"))
        return
    end

    -- Play launch sound
    if launcher and launcher.launchSound then
        launcher.launchSound:play()
    end

    -- Set launching state
    launcher.isLaunching = true
    launcher.launchingGameTitle = game.title

    -- Force screen update to show launching message
    love.graphics.clear()
    love.draw()
    love.graphics.present()

    print("Launching: " .. game.title)

    local os_type = love.system.getOS()
    local cmd

    if os_type == "Windows" then
        -- Convert paths to Windows-style backslashes
        -- Remove "external/" prefix if present (from mounted directory)
        local cleanPath = game.path:gsub("^external/", "")

        -- Get the directory where the executable is located
        -- love.filesystem.getSource() returns the path to the .love or .exe
        local source = love.filesystem.getSource()
        local baseDir

        -- If it's a fused exe, get the directory containing it
        if source:match("%.exe$") then
            baseDir = source:match("^(.+)\\[^\\]+$")
        else
            baseDir = source
        end

        baseDir = baseDir:gsub("/", "\\")
        local gameDir = baseDir .. "\\" .. cleanPath:gsub("/", "\\")
        local exePath = gameDir .. "\\" .. game.exe

        print("Source: " .. source)
        print("Base Directory: " .. baseDir)
        print("Clean Path: " .. cleanPath)
        print("Game Directory: " .. gameDir)
        print("Exe Path: " .. exePath)

        -- Use start command to launch asynchronously - this returns immediately
        cmd = 'start "" "' .. exePath .. '"'
    else  -- Linux, OS X
        local exePath = game.path .. "/" .. game.exe
        cmd = 'wine "' .. exePath .. '" &'
    end

    print("Executing: " .. cmd)

    -- Use os.execute to launch without blocking
    local success = os.execute(cmd)

    -- Clear launching state
    launcher.isLaunching = false
    launcher.launchingGameTitle = ""

    if success then
        print("Game launched successfully: " .. game.title)
    else
        print("Failed to launch game: " .. game.title)
        launcher.showMessageBox = true
        launcher.messageBoxTitle = "Launch Error"
        launcher.messageBoxText = "Failed to launch:\n" .. game.title .. "\n\nPlease check if the game executable exists."
    end
end

return gameLauncher
