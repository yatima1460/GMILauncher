local draw = {}

local function drawTile(launcher, x, y, game, isSelected, scale, opacity)
    -- Apply transformations from center of tile
    love.graphics.push()
    local centerX = x + launcher.tileSize / 2
    local centerY = y + launcher.tileSize / 2
    love.graphics.translate(centerX, centerY)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-centerX, -centerY)

    -- Calculate vertical offset (slight bounce effect for selected)
    local yOffset = isSelected and math.sin(love.timer.getTime() * 2) * 3 or 0

    -- Selection border
    if isSelected then
        love.graphics.setColor(launcher.theme.selectedColor[1], launcher.theme.selectedColor[2], launcher.theme.selectedColor[3], opacity)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x - 5, y - 5 + yOffset, launcher.tileSize + 10, launcher.tileSize + 10, 10, 10)
    end

    -- Tile background
    love.graphics.setColor(launcher.theme.tileColor[1], launcher.theme.tileColor[2], launcher.theme.tileColor[3], opacity)
    love.graphics.rectangle("fill", x, y + yOffset, launcher.tileSize, launcher.tileSize, 10, 10)

    -- Cover image or placeholder
    if game.icon then
        love.graphics.setColor(1, 1, 1, opacity)
        local iconScale = math.min((launcher.tileSize - 40) / game.icon:getWidth(),
                              (launcher.tileSize - 100) / game.icon:getHeight())
        local iconX = x + (launcher.tileSize - game.icon:getWidth() * iconScale) / 2
        love.graphics.draw(game.icon, iconX, y + 20 + yOffset, 0, iconScale, iconScale)
    else
        love.graphics.setColor(0.5, 0.5, 0.55, opacity)
        love.graphics.rectangle("fill", x + 60, y + 40 + yOffset, 130, 90, 5, 5)
    end

    -- Title with shadow
    local titleY = y + launcher.tileSize - 70 + yOffset
    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(0, 0, 0, opacity * 0.7)
    love.graphics.printf(game.title, x + 1, titleY + 1, launcher.tileSize, "center")
    love.graphics.setColor(launcher.theme.textColor[1], launcher.theme.textColor[2], launcher.theme.textColor[3], opacity)
    love.graphics.printf(game.title, x, titleY, launcher.tileSize, "center")

    -- Version and Author
    love.graphics.setFont(launcher.smallFont)
    local version = game.version or "N/A"
    local author = game.author or "Unknown"

    -- Version
    local versionY = y + launcher.tileSize - 45 + yOffset
    love.graphics.setColor(0, 0, 0, opacity * 0.7)
    love.graphics.printf("v" .. version, x + 1, versionY + 1, launcher.tileSize, "center")
    love.graphics.setColor(launcher.theme.subtextColor[1], launcher.theme.subtextColor[2], launcher.theme.subtextColor[3], opacity)
    love.graphics.printf("v" .. version, x, versionY, launcher.tileSize, "center")

    -- Author
    local authorY = y + launcher.tileSize - 25 + yOffset
    love.graphics.setColor(0, 0, 0, opacity * 0.7)
    love.graphics.printf(author, x + 1, authorY + 1, launcher.tileSize, "center")
    love.graphics.setColor(launcher.theme.accentColor[1], launcher.theme.accentColor[2], launcher.theme.accentColor[3], opacity)
    love.graphics.printf(author, x, authorY, launcher.tileSize, "center")

    -- Source code indicator
    if game.source then
        local iconSize = 30
        local iconX = x + launcher.tileSize - iconSize - 10
        local iconY = y + 10 + yOffset

        -- Background circle
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8 * opacity)
        love.graphics.circle("fill", iconX + iconSize/2, iconY + iconSize/2, iconSize/2)

        -- Code symbol "<>"
        love.graphics.setFont(launcher.smallFont)
        love.graphics.setColor(0.5, 0.8, 1, opacity)
        love.graphics.printf("<>", iconX, iconY + 9, iconSize, "center")
    end

    love.graphics.pop()
end

function draw.drawLauncher(launcher)
    local w, h = love.graphics.getDimensions()

    love.graphics.clear(launcher.theme.background)

    -- Header
    love.graphics.setFont(launcher.titleFont)
    love.graphics.setColor(launcher.theme.textColor)
    love.graphics.print("GameMaker Italia Launcher", 40, 20)

    -- Game tiles
    local centerX = w / 2
    local centerY = (h - launcher.tileSize) / 2
    love.graphics.setFont(launcher.gameFont)
    for i, game in ipairs(launcher.games) do
        local x = centerX - (launcher.tileSize / 2) + (i - launcher.selectedIndex) * (launcher.tileSize + launcher.tilePadding) + launcher.scrollOffset

        -- Calculate visual distance from center (continuous, not discrete)
        local tileDistance = launcher.tileSize + launcher.tilePadding
        local visualDistance = math.abs((i - launcher.selectedIndex) * tileDistance + launcher.scrollOffset) / tileDistance

        -- Scale: smoothly interpolate based on visual distance
        local scale = 1.0 - (visualDistance * 0.15)
        scale = math.max(scale, 0.7)

        -- Opacity: smoothly interpolate based on visual distance
        local opacity = 1.0 - (visualDistance * 0.3)
        opacity = math.max(opacity, 0.3)

        -- Check if this tile is visually centered (within threshold)
        local isVisuallySelected = visualDistance < 0.5

        drawTile(launcher, x, centerY, game, isVisuallySelected, scale, opacity)
    end

    -- Footer
    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.print(launcher.helpText, 40, h - 40)
end

return draw
