local background = require("src.ui.background")
local messages = require("src.ui.messages")
local tile = require("src.ui.tile")

local draw = {}

function draw.drawLauncher(launcher)
    if launcher.isLaunching then
        messages.drawLaunchingScreen(launcher)
        return
    end

    local w, h = love.graphics.getDimensions()
    local time = love.timer.getTime()
    local shouldDrawMessageBox = launcher.showMessageBox

    background.drawAnimated(w, h, time)
    background.drawTitleBanner(launcher, w)

    local centerX = w / 2
    local centerY = (h - launcher.tileSizeHeight) / 2
    local tileDistance = launcher.tileSizeWidth + launcher.tilePadding

    love.graphics.setFont(launcher.gameFont)
    for i, game in ipairs(launcher.games) do
        local offset = (i - launcher.selectedIndex) * tileDistance + launcher.scrollOffset
        local x = centerX - (launcher.tileSizeWidth / 2) + offset
        local visualDistance = math.abs(offset) / tileDistance
        local scale = math.max(1.0 - visualDistance * 0.15, 0.7)
        local opacity = math.max(1.0 - visualDistance * 0.3, 0.3)

        tile.draw(launcher, x, centerY, game, visualDistance < 0.5, scale, opacity)
    end

    local selectedGame = launcher.games[launcher.selectedIndex]
    if selectedGame then
        love.graphics.setFont(launcher.titleFont)
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.printf(selectedGame.title, 1, h - 111, w, "center")
        love.graphics.setColor(launcher.theme.textColor)
        love.graphics.printf(selectedGame.title, 0, h - 112, w, "center")
    end

    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.print(launcher.helpText, 40, h - 40)

    if shouldDrawMessageBox then
        messages.drawMessageBox(launcher)
    end
end

return draw
