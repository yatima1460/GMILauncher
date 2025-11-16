local gameLauncher = require("game_launcher")

local input = {}

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
    if launcher.showMessageBox then
        launcher.showMessageBox = false
        launcher.messageBoxTitle = ""
        launcher.messageBoxText = ""
        return
    end

    local keyActions = {
        right = function() moveSelection(launcher, 1) end,
        left = function() moveSelection(launcher, -1) end,
        ["return"] = function() gameLauncher.launch(launcher.games[launcher.selectedIndex], launcher) end,
        space = function() gameLauncher.launch(launcher.games[launcher.selectedIndex], launcher) end,
        s = function()
            local game = launcher.games[launcher.selectedIndex]
            if game.source then
                love.system.openURL(game.source)
            else
                launcher.showMessageBox = true
                launcher.messageBoxTitle = "Not Available"
                launcher.messageBoxText = "No source code available for\n" .. game.title
            end
        end,
        b = function()
            local game = launcher.games[launcher.selectedIndex]
            if game.url and game.url ~= "" then
                love.system.openURL(game.url)
            else
                launcher.showMessageBox = true
                launcher.messageBoxTitle = "Not Available"
                launcher.messageBoxText = "No author page available for\n" .. game.title
            end
        end,
        d = function()
            local game = launcher.games[launcher.selectedIndex]
            if game.description and game.description ~= "" then
                launcher.showMessageBox = true
                launcher.messageBoxTitle = game.title
                launcher.messageBoxText = game.description
            else
                launcher.showMessageBox = true
                launcher.messageBoxTitle = "Not Available"
                launcher.messageBoxText = "No description available for\n" .. game.title
            end
        end,
        escape = love.event.quit
    }

    if keyActions[key] then
        keyActions[key]()
    end
end

function input.handleGamepadPress(launcher, joystick, button)
    -- If message box is showing, dismiss it on any button press
    if launcher.showMessageBox then
        launcher.showMessageBox = false
        launcher.messageBoxTitle = ""
        launcher.messageBoxText = ""
        return
    end

    local buttonActions = {
        a = function() gameLauncher.launch(launcher.games[launcher.selectedIndex], launcher) end,
        b = function()
            local game = launcher.games[launcher.selectedIndex]
            if game.url and game.url ~= "" then
                love.system.openURL(game.url)
            else
                launcher.showMessageBox = true
                launcher.messageBoxTitle = "Not Available"
                launcher.messageBoxText = "No author page available for\n" .. game.title
            end
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
