local gameLauncher = require("src.game_launcher")

local input = {}

local function selectedGame(launcher)
    return launcher.games[launcher.selectedIndex]
end

local function showMessageBox(launcher, title, text)
    launcher.showMessageBox = true
    launcher.messageBoxTitle = title
    launcher.messageBoxText = text
end

local function dismissMessageBox(launcher)
    if not launcher.showMessageBox then
        return false
    end

    launcher.showMessageBox = false
    launcher.messageBoxTitle = ""
    launcher.messageBoxText = ""
    return true
end

local function launchSelectedGame(launcher)
    gameLauncher.launch(selectedGame(launcher), launcher)
end

local function openOptionalUrl(launcher, field, fallbackText)
    local game = selectedGame(launcher)
    if not game then
        return
    end

    local url = game[field]
    if url and url ~= "" then
        love.system.openURL(url)
    else
        showMessageBox(launcher, "Not Available", fallbackText .. "\n" .. game.title)
    end
end

local function showSelectedDescription(launcher)
    local game = selectedGame(launcher)
    if not game then
        return
    end

    if game.description and game.description ~= "" then
        showMessageBox(launcher, game.title, game.description)
    else
        showMessageBox(launcher, "Not Available", "No description available for\n" .. game.title)
    end
end

local function moveSelection(launcher, direction)
    -- Don't allow navigation if message box is showing
    if launcher.showMessageBox then
        return
    end

    -- Check if we would go out of bounds
    local newIndex = launcher.selectedIndex + direction

    -- Stop at boundaries instead of wrapping
    if newIndex < 1 or newIndex > #launcher.games then
        return -- Don't move if at boundary
    end

    -- Store the distance before changing selection
    local tileDistance = launcher.tileSizeWidth + launcher.tilePadding

    launcher.selectedIndex = newIndex

    -- Offset scroll to maintain visual position, then animate back to 0
    launcher.scrollOffset = direction * tileDistance
    launcher.targetOffset = 0

    -- Play navigation sound
    if launcher.navigationSound then
        launcher.navigationSound:stop()
        launcher.navigationSound:play()
    end
end

function input.handleKeypress(launcher, key)
    -- If message box is showing, dismiss it on any key press
    if dismissMessageBox(launcher) then
        return
    end

    local keyActions = {
        right = function() moveSelection(launcher, 1) end,
        left = function() moveSelection(launcher, -1) end,
        ["return"] = function() launchSelectedGame(launcher) end,
        space = function() launchSelectedGame(launcher) end,
        s = function()
            openOptionalUrl(launcher, "source", "No source code available for")
        end,
        b = function()
            openOptionalUrl(launcher, "url", "No author page available for")
        end,
        d = function() showSelectedDescription(launcher) end,
        escape = love.event.quit
    }

    if keyActions[key] then
        keyActions[key]()
    end
end

function input.handleGamepadPress(launcher, _joystick, button)
    -- If message box is showing, dismiss it on any button press
    if dismissMessageBox(launcher) then
        return
    end

    local buttonActions = {
        a = function() launchSelectedGame(launcher) end,
        b = function()
            openOptionalUrl(launcher, "url", "No author page available for")
        end,
        y = love.event.quit,
        dpright = function() moveSelection(launcher, 1) end,
        dpleft = function() moveSelection(launcher, -1) end
    }

    if buttonActions[button] then
        buttonActions[button]()
    end
end

return input
