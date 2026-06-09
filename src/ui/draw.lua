local background = require("src.ui.background")
local messages = require("src.ui.messages")
local tile = require("src.ui.tile")

local draw = {}

local function helpTextForGame(game)
    local sourceAction = game and game.source and game.source ~= ""
        and "S: Open source in browser"
        or "S: Source not available"

    return "Arrows: Nav | D: Info | Q: QR (page) | F: Fullscreen | Enter: Launch/Open page | B: Open page in browser | "
        .. sourceAction
        .. " | ESCape: Quit"
end

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
        local titleFont = launcher.selectedTitleFont or launcher.titleFont
        local titlePaddingX = 28 * uiScale
        local titlePaddingY = 10 * uiScale
        local maxTitleWidth = w - 80 * uiScale
        local titleTextWidth = math.min(titleFont:getWidth(selectedGame.title), maxTitleWidth - titlePaddingX * 2)
        local _, titleLines = titleFont:getWrap(selectedGame.title, titleTextWidth)
        local titleTextHeight = #titleLines * titleFont:getHeight()
        local titleBoxWidth = titleTextWidth + titlePaddingX * 2
        local titleBoxHeight = titleTextHeight + titlePaddingY * 2
        local titleBoxX = (w - titleBoxWidth) / 2
        local titleBoxY = h - 150 * uiScale
        local titleY = titleBoxY + titlePaddingY

        love.graphics.setColor(0, 0, 0, 0.42)
        love.graphics.rectangle("fill", titleBoxX, titleBoxY, titleBoxWidth, titleBoxHeight, 8 * uiScale, 8 * uiScale)

        love.graphics.setFont(titleFont)
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.printf(selectedGame.title, titleBoxX + titlePaddingX + 2 * uiScale, titleY + 2 * uiScale, titleTextWidth, "center")
        love.graphics.setColor(launcher.theme.textColor)
        love.graphics.printf(selectedGame.title, titleBoxX + titlePaddingX, titleY, titleTextWidth, "center")
    end

    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.print(helpTextForGame(selectedGame), 40 * uiScale, h - 40 * uiScale)

    if shouldDrawMessageBox then
        messages.drawMessageBox(launcher)
    end
end

return draw
