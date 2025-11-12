local gameLauncher = require("game_launcher")

local input = {}

local function moveSelection(launcher, direction)
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
end

function input.handleKeypress(launcher, key)
    local keyActions = {
        right = function() moveSelection(launcher, 1) end,
        left = function() moveSelection(launcher, -1) end,
        ["return"] = function() gameLauncher.launch(launcher.games[launcher.selectedIndex]) end,
        space = function() gameLauncher.launch(launcher.games[launcher.selectedIndex]) end,
        s = function()
            local game = launcher.games[launcher.selectedIndex]
            if game.source then
                love.system.openURL(game.source)
            else
                print("No source code URL available for: " .. game.title)
            end
        end,
        escape = love.event.quit
    }

    if keyActions[key] then
        keyActions[key]()
    end
end

function input.handleGamepadPress(launcher, joystick, button)
    local buttonActions = {
        a = function() gameLauncher.launch(launcher.games[launcher.selectedIndex]) end,
        b = love.event.quit,
        dpright = function() moveSelection(launcher, 1) end,
        dpleft = function() moveSelection(launcher, -1) end
    }

    if buttonActions[button] then
        buttonActions[button]()
    end
end

return input
