local gameLauncher = {}

local launchCompletionChannelName = "gmi-launch-completion"
local runningLaunchThreads = {}

local waitForGameThreadCode = [[
local command, channelName, gameTitle = ...
local ok, reason, code = os.execute(command)
love.thread.getChannel(channelName):push({
    gameTitle = gameTitle,
    ok = ok,
    reason = reason,
    code = code
})
]]

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

local function minimizeLauncherWindow()
    if love.window and love.window.minimize then
        love.window.minimize()
    end
end

local function restoreLauncherWindow()
    if love.window and love.window.restore then
        love.window.restore()
    end

    if love.window and love.window.requestAttention then
        love.window.requestAttention()
    end
end

local function startGameWaitThread(command, gameTitle)
    local thread = love.thread.newThread(waitForGameThreadCode)
    thread:start(command, launchCompletionChannelName, gameTitle)
    table.insert(runningLaunchThreads, thread)
end

local function cleanupFinishedThreads()
    for i = #runningLaunchThreads, 1, -1 do
        if not runningLaunchThreads[i]:isRunning() then
            table.remove(runningLaunchThreads, i)
        end
    end
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
        cmd = "cmd /c start /wait \"\" " .. quoteWindows(exePath)
    else
        cmd = "wine " .. quotePosix(exePath)
    end

    print("Exe Path: " .. exePath)
    print("Executing: " .. cmd)

    startGameWaitThread(cmd, game.title)

    -- Clear launching state
    launcher.isLaunching = false
    launcher.launchingGameTitle = ""

    print("Game launched successfully: " .. game.title)
    minimizeLauncherWindow()
end

function gameLauncher.update()
    cleanupFinishedThreads()

    local channel = love.thread.getChannel(launchCompletionChannelName)
    local launchResult = channel:pop()

    while launchResult do
        if didCommandStart(launchResult.ok, launchResult.reason, launchResult.code) then
            print("Game closed: " .. launchResult.gameTitle)
        else
            print("Game exited with an error: " .. launchResult.gameTitle)
        end

        restoreLauncherWindow()
        launchResult = channel:pop()
    end
end

return gameLauncher
