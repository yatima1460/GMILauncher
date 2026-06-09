local tile = {}

local function formatVersion(version)
    if version:match("^[vV]") then
        return version
    end

    return "v" .. version
end

local function drawDemoBadge(launcher, x, y, opacity, uiScale)
    local badgeWidth = 58 * uiScale
    local badgeHeight = 22 * uiScale
    local badgeX = x + launcher.tileSizeWidth - badgeWidth - 10 * uiScale
    local badgeY = y + 10 * uiScale
    local cornerRadius = 5 * uiScale

    love.graphics.setColor(0.86, 0.22, 0.28, 0.95 * opacity)
    love.graphics.rectangle("fill", badgeX, badgeY, badgeWidth, badgeHeight, cornerRadius, cornerRadius)

    love.graphics.setColor(0, 0, 0, 0.35 * opacity)
    love.graphics.rectangle("line", badgeX, badgeY, badgeWidth, badgeHeight, cornerRadius, cornerRadius)

    love.graphics.setFont(launcher.smallFont)
    love.graphics.setColor(1, 1, 1, opacity)
    love.graphics.printf("DEMO", badgeX, badgeY + 4 * uiScale, badgeWidth, "center")
end

function tile.draw(launcher, x, y, game, isSelected, scale, opacity)
    local uiScale = launcher.uiScale or 1

    love.graphics.push()
    local centerX = x + launcher.tileSizeWidth / 2
    local centerY = y + launcher.tileSizeHeight / 2
    love.graphics.translate(centerX, centerY)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-centerX, -centerY)

    local yOffset = isSelected and math.sin(love.timer.getTime() * 2) * 3 * uiScale or 0
    local cornerRadius = 10 * uiScale

    if isSelected then
        love.graphics.setColor(launcher.theme.selectedColor[1], launcher.theme.selectedColor[2], launcher.theme.selectedColor[3], opacity)
        love.graphics.setLineWidth(4 * uiScale)
        love.graphics.rectangle(
            "line",
            x - 5 * uiScale,
            y - 5 * uiScale + yOffset,
            launcher.tileSizeWidth + 10 * uiScale,
            launcher.tileSizeHeight + 10 * uiScale,
            cornerRadius,
            cornerRadius
        )
    end

    love.graphics.setColor(launcher.theme.tileColor[1], launcher.theme.tileColor[2], launcher.theme.tileColor[3], opacity)
    love.graphics.rectangle("fill", x, y + yOffset, launcher.tileSizeWidth, launcher.tileSizeHeight, cornerRadius, cornerRadius)

    if game.icon then
        love.graphics.setColor(1, 1, 1, opacity)
        local iconScale = math.min(
            (launcher.tileSizeWidth - 40 * uiScale) / game.icon:getWidth(),
            (launcher.tileSizeHeight - 100 * uiScale) / game.icon:getHeight()
        )
        local iconX = x + (launcher.tileSizeWidth - game.icon:getWidth() * iconScale) / 2
        love.graphics.draw(game.icon, iconX, y + 20 * uiScale + yOffset, 0, iconScale, iconScale)
    else
        love.graphics.setColor(0.5, 0.5, 0.55, opacity)
        local placeholderWidth = 130 * uiScale
        local placeholderHeight = 90 * uiScale
        local placeholderX = x + (launcher.tileSizeWidth - placeholderWidth) / 2
        love.graphics.rectangle(
            "fill",
            placeholderX,
            y + 40 * uiScale + yOffset,
            placeholderWidth,
            placeholderHeight,
            5 * uiScale,
            5 * uiScale
        )
    end

    if game.demo then
        drawDemoBadge(launcher, x, y + yOffset, opacity, uiScale)
    end

    local titleY = y + launcher.tileSizeHeight - 80 * uiScale + yOffset
    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(0, 0, 0, opacity * 0.7)
    love.graphics.printf(game.title, x + 1, titleY + 1, launcher.tileSizeWidth, "center")
    love.graphics.setColor(launcher.theme.textColor[1], launcher.theme.textColor[2], launcher.theme.textColor[3], opacity)
    love.graphics.printf(game.title, x, titleY, launcher.tileSizeWidth, "center")

    love.graphics.setFont(launcher.smallFont)
    local author = game.author or "Unknown"

    if game.version then
        local versionY = y + launcher.tileSizeHeight - 65 * uiScale + yOffset
        local versionText = formatVersion(game.version)
        love.graphics.setColor(0, 0, 0, opacity * 0.7)
        love.graphics.printf(versionText, x + 1, versionY + 1, launcher.tileSizeWidth, "center")
        love.graphics.setColor(launcher.theme.subtextColor[1], launcher.theme.subtextColor[2], launcher.theme.subtextColor[3], opacity)
        love.graphics.printf(versionText, x, versionY, launcher.tileSizeWidth, "center")
    end

    local authorY = y + launcher.tileSizeHeight - 35 * uiScale + yOffset
    love.graphics.setColor(0, 0, 0, opacity * 0.7)
    love.graphics.printf(author, x + 1, authorY + 1, launcher.tileSizeWidth, "center")
    love.graphics.setColor(launcher.theme.accentColor[1], launcher.theme.accentColor[2], launcher.theme.accentColor[3], opacity)
    love.graphics.printf(author, x, authorY, launcher.tileSizeWidth, "center")

    if game.year then
        local yearY = authorY + 18 * uiScale
        love.graphics.setColor(0, 0, 0, opacity * 0.6)
        love.graphics.printf(game.year, x + 1, yearY + 1, launcher.tileSizeWidth, "center")
        love.graphics.setColor(launcher.theme.subtextColor[1], launcher.theme.subtextColor[2], launcher.theme.subtextColor[3], opacity * 0.8)
        love.graphics.printf(game.year, x, yearY, launcher.tileSizeWidth, "center")
    end

    if game.source then
        local iconSize = 30 * uiScale
        local iconX = x + launcher.tileSizeWidth - iconSize - 10 * uiScale
        local iconY = y + (game.demo and 38 or 10) * uiScale + yOffset

        love.graphics.setColor(0.2, 0.2, 0.2, 0.8 * opacity)
        love.graphics.circle("fill", iconX + iconSize / 2, iconY + iconSize / 2, iconSize / 2)

        love.graphics.setFont(launcher.smallFont)
        love.graphics.setColor(0.5, 0.8, 1, opacity)
        love.graphics.printf("<>", iconX, iconY + 9 * uiScale, iconSize, "center")
    end

    love.graphics.pop()
end

return tile
