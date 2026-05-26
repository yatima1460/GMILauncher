local gameLauncher = {}

local function showLaunchError(launcher, gameTitle, details)
    if not launcher then
        return
    end

    launcher.showMessageBox = true
    launcher.messageBoxTitle = "Launch Error"
    launcher.messageBoxText = "Failed to launch:\n"
        .. gameTitle
        .. "\n\n"
        .. (details or "Please check if the game executable exists.")
end

local function normalizeVirtualPath(path)
    return (path or ""):gsub("\\", "/")
end

local function stripExternalPrefix(path)
    return path:gsub("^external/", "")
end

local function joinPath(...)
    local separator = package.config:sub(1, 1)
    local parts = { ... }
    local path = parts[1] or ""

    for i = 2, #parts do
        local part = tostring(parts[i] or "")
        if path:sub(-1) == "/" or path:sub(-1) == "\\" then
            path = path .. part
        else
            path = path .. separator .. part
        end
    end

    if separator == "\\" then
        return path:gsub("/", "\\")
    end

    return path:gsub("\\", "/")
end

local function resolveExecutablePath(game)
    local exeVirtualPath = normalizeVirtualPath(game.exeVirtualPath or (game.path .. "/" .. game.exe))
    if not love.filesystem.getInfo(exeVirtualPath, "file") then
        return nil, "Executable not found:\n" .. exeVirtualPath
    end

    local realDirectory = love.filesystem.getRealDirectory(exeVirtualPath)
    if not realDirectory or realDirectory == "" then
        return nil, "Could not resolve executable path:\n" .. exeVirtualPath
    end

    local relativePath = stripExternalPrefix(exeVirtualPath)
    return joinPath(realDirectory, relativePath), nil
end

local function quoteWindows(value)
    return '"' .. tostring(value):gsub('"', '\\"') .. '"'
end

local function quotePosix(value)
    return "'" .. tostring(value):gsub("'", [['"'"']]) .. "'"
end

local function didCommandStart(ok, reason, code)
    if type(ok) == "number" then
        return ok == 0
    end

    return ok == true and (reason == nil or reason == "exit") and (code == nil or code == 0)
end

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

    local exePath, err = resolveExecutablePath(game)
    if not exePath then
        launcher.isLaunching = false
        launcher.launchingGameTitle = ""
        print("Failed to resolve executable for " .. game.title .. ": " .. err)
        showLaunchError(launcher, game.title, err)
        return
    end

    local osType = love.system.getOS()
    local cmd
    if osType == "Windows" then
        cmd = "cmd /c start \"\" " .. quoteWindows(exePath)
    else
        cmd = "wine " .. quotePosix(exePath) .. " &"
    end

    print("Exe Path: " .. exePath)
    print("Executing: " .. cmd)

    local ok, reason, code = os.execute(cmd)

    -- Clear launching state
    launcher.isLaunching = false
    launcher.launchingGameTitle = ""

    if didCommandStart(ok, reason, code) then
        print("Game launched successfully: " .. game.title)
    else
        print("Failed to launch game: " .. game.title)
        showLaunchError(launcher, game.title, "The launch command did not start successfully.")
    end
end

return gameLauncher
