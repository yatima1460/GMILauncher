-- Import modules
local config = require("config")
local gameLoader = require("game_loader")
local draw = require("ui.draw")
local input = require("input")

-- Initialize launcher with config
local launcher = config

function love.load()
    love.window.setTitle(launcher.title)
    love.window.setMode(1280, 720, {resizable = false, vsync = true})
    launcher.titleFont = love.graphics.newFont(24)
    launcher.gameFont = love.graphics.newFont(16)
    launcher.smallFont = love.graphics.newFont(12)
    gameLoader.loadGames(launcher)
end

function love.update(dt)
    local diff = launcher.targetOffset - launcher.scrollOffset
    launcher.scrollOffset = launcher.scrollOffset + diff * launcher.scrollSpeed * dt

    if math.abs(diff) < 0.5 then
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
