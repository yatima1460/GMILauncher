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
    local uiScale = launcher.uiScale or 1

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
        love.graphics.printf(selectedGame.title, 1 * uiScale, h - 111 * uiScale, w, "center")
        love.graphics.setColor(launcher.theme.textColor)
        love.graphics.printf(selectedGame.title, 0, h - 112 * uiScale, w, "center")
    end

    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.print(launcher.helpText, 40 * uiScale, h - 40 * uiScale)

    if shouldDrawMessageBox then
        messages.drawMessageBox(launcher)
    end
end

return draw
