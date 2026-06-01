local config = require("src.config")
local gameLoader = require("src.game_loader")
local draw = require("src.ui.draw")
local input = require("src.input")
local layout = require("src.ui.layout")

local launcher = config

function love.load()
    layout.update(launcher)
    launcher.games = gameLoader.loadGames("games")
    love.audio.setVolume(0.1)
    launcher.navigationSound = love.audio.newSource("assets/sounds/523422__andersmmg__ding-1.wav", "static")
    launcher.launchSound = love.audio.newSource("assets/sounds/523425__andersmmg__ding-2.wav", "static")
end

function love.update(dt)
    local diff = launcher.targetOffset - launcher.scrollOffset

    local interpolationSpeed = 15 * dt
    launcher.scrollOffset = launcher.scrollOffset + diff * interpolationSpeed

    if math.abs(diff) < 1 then
        launcher.scrollOffset = launcher.targetOffset
    end
end

function love.draw()
    layout.update(launcher)
    draw.drawLauncher(launcher)
end

function love.resize()
    launcher.uiScale = nil
    layout.update(launcher)
end

function love.keypressed(key)
    input.handleKeypress(launcher, key)
end

function love.gamepadpressed(joystick, button)
    input.handleGamepadPress(launcher, joystick, button)
end
