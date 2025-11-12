-- Import modules
local config = require("conf")
local gameLoader = require("game_loader")
local draw = require("ui.draw")
local input = require("input")

local launcher = config

function love.load()
    launcher.titleFont = love.graphics.newFont(24)
    launcher.gameFont = love.graphics.newFont(16)
    launcher.smallFont = love.graphics.newFont(12)
    launcher.games = gameLoader.loadGames("games")
    love.audio.setVolume(0.1)
    launcher.navigationSound = love.audio.newSource("assets/sounds/523422__andersmmg__ding-1.wav", "static")
    launcher.launchSound = love.audio.newSource("assets/sounds/523425__andersmmg__ding-2.wav", "static")
end

function love.update(dt)
    local diff = launcher.targetOffset - launcher.scrollOffset

    -- Smooth interpolation with exponential decay (faster response)
    local interpolationSpeed = 15 * dt
    launcher.scrollOffset = launcher.scrollOffset + diff * interpolationSpeed

    -- Snap to target when very close
    if math.abs(diff) < 1 then
        launcher.scrollOffset = launcher.targetOffset
    end
end

function love.draw()
    draw.drawLauncher(launcher)
end

function love.keypressed(key)
    input.handleKeypress(launcher, key)
end

function love.gamepadpressed(joystick, button)
    input.handleGamepadPress(launcher, joystick, button)
end
