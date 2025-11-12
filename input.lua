local gameLauncher = require("game_launcher")

local input = {}

local function moveSelection(launcher, direction)
    launcher.selectedIndex = launcher.selectedIndex + direction

    if launcher.selectedIndex < 1 then
        launcher.selectedIndex = #launcher.games
    elseif launcher.selectedIndex > #launcher.games then
        launcher.selectedIndex = 1
    end

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
