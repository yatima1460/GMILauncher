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

    -- Use io.popen to capture any error output
    local handle = io.popen(cmd .. " 2>&1")
    if handle then
        local result = handle:read("*a")
        handle:close()

        if result and result ~= "" then
            print("Output: " .. result)
            -- Check if there's an error in the output
            if result:match("cannot find") or result:match("error") or result:match("Error") then
                local errorMsg = "Failed to launch game: " .. game.title .. "\n\nError: " .. result
                love.window.showMessageBox("Launch Error", errorMsg, "error")
            else
                print("Game launched successfully")
            end
        else
            print("Game launched successfully")
        end
    else
        local errorMsg = "Failed to execute command for: " .. game.title
        print(errorMsg)
        love.window.showMessageBox("Launch Error", errorMsg, "error")
    end
end

return gameLauncher
