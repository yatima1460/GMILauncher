local tile = {}

function tile.draw(launcher, x, y, game, isSelected, scale, opacity)
    love.graphics.push()
    local centerX = x + launcher.tileSizeWidth / 2
    local centerY = y + launcher.tileSizeHeight / 2
    love.graphics.translate(centerX, centerY)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-centerX, -centerY)

    local yOffset = isSelected and math.sin(love.timer.getTime() * 2) * 3 or 0

    if isSelected then
        love.graphics.setColor(launcher.theme.selectedColor[1], launcher.theme.selectedColor[2], launcher.theme.selectedColor[3], opacity)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x - 5, y - 5 + yOffset, launcher.tileSizeWidth + 10, launcher.tileSizeHeight + 10, 10, 10)
    end

    love.graphics.setColor(launcher.theme.tileColor[1], launcher.theme.tileColor[2], launcher.theme.tileColor[3], opacity)
    love.graphics.rectangle("fill", x, y + yOffset, launcher.tileSizeWidth, launcher.tileSizeHeight, 10, 10)

    if game.icon then
        love.graphics.setColor(1, 1, 1, opacity)
        local iconScale = math.min(
            (launcher.tileSizeWidth - 40) / game.icon:getWidth(),
            (launcher.tileSizeHeight - 100) / game.icon:getHeight()
        )
        local iconX = x + (launcher.tileSizeWidth - game.icon:getWidth() * iconScale) / 2
        love.graphics.draw(game.icon, iconX, y + 20 + yOffset, 0, iconScale, iconScale)
    else
        love.graphics.setColor(0.5, 0.5, 0.55, opacity)
        local placeholderX = x + (launcher.tileSizeWidth - 130) / 2
        love.graphics.rectangle("fill", placeholderX, y + 40 + yOffset, 130, 90, 5, 5)
    end

    local titleY = y + launcher.tileSizeHeight - 80 + yOffset
    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(0, 0, 0, opacity * 0.7)
    love.graphics.printf(game.title, x + 1, titleY + 1, launcher.tileSizeWidth, "center")
    love.graphics.setColor(launcher.theme.textColor[1], launcher.theme.textColor[2], launcher.theme.textColor[3], opacity)
    love.graphics.printf(game.title, x, titleY, launcher.tileSizeWidth, "center")

    love.graphics.setFont(launcher.smallFont)
    local author = game.author or "Unknown"

    if game.version then
        local versionY = y + launcher.tileSizeHeight - 65 + yOffset
        love.graphics.setColor(0, 0, 0, opacity * 0.7)
        love.graphics.printf("v" .. game.version, x + 1, versionY + 1, launcher.tileSizeWidth, "center")
        love.graphics.setColor(launcher.theme.subtextColor[1], launcher.theme.subtextColor[2], launcher.theme.subtextColor[3], opacity)
        love.graphics.printf("v" .. game.version, x, versionY, launcher.tileSizeWidth, "center")
    end

    local authorY = y + launcher.tileSizeHeight - 35 + yOffset
    love.graphics.setColor(0, 0, 0, opacity * 0.7)
    love.graphics.printf(author, x + 1, authorY + 1, launcher.tileSizeWidth, "center")
    love.graphics.setColor(launcher.theme.accentColor[1], launcher.theme.accentColor[2], launcher.theme.accentColor[3], opacity)
    love.graphics.printf(author, x, authorY, launcher.tileSizeWidth, "center")

    if game.year then
        local yearY = authorY + 18
        love.graphics.setColor(0, 0, 0, opacity * 0.6)
        love.graphics.printf(game.year, x + 1, yearY + 1, launcher.tileSizeWidth, "center")
        love.graphics.setColor(launcher.theme.subtextColor[1], launcher.theme.subtextColor[2], launcher.theme.subtextColor[3], opacity * 0.8)
        love.graphics.printf(game.year, x, yearY, launcher.tileSizeWidth, "center")
    end

    if game.source then
        local iconSize = 30
        local iconX = x + launcher.tileSizeWidth - iconSize - 10
        local iconY = y + 10 + yOffset

        love.graphics.setColor(0.2, 0.2, 0.2, 0.8 * opacity)
        love.graphics.circle("fill", iconX + iconSize / 2, iconY + iconSize / 2, iconSize / 2)

        love.graphics.setFont(launcher.smallFont)
        love.graphics.setColor(0.5, 0.8, 1, opacity)
        love.graphics.printf("<>", iconX, iconY + 9, iconSize, "center")
    end

    love.graphics.pop()
end

return tile
