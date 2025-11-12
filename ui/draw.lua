local draw = {}

local function drawAnimatedBackground(w, h, time)
    -- Create a flowing gradient background with animated colors
    local segments = 20

    for i = 0, segments do
        local progress = i / segments

        -- Animated color shifts using sine waves with different frequencies
        local r = 0.15 + math.sin(time * 0.3 + progress * 2) * 0.08
        local g = 0.15 + math.sin(time * 0.4 + progress * 3) * 0.08
        local b = 0.2 + math.sin(time * 0.5 + progress * 1.5) * 0.1

        love.graphics.setColor(r, g, b)
        local y = (h / segments) * i
        love.graphics.rectangle("fill", 0, y, w, h / segments + 1)
    end

    -- Add subtle moving diagonal stripes for depth
    love.graphics.setLineWidth(2)
    for i = 0, 30 do
        local offset = (time * 20 + i * 40) % (w + h)
        local alpha = 0.03 + math.sin(time + i * 0.5) * 0.02
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.line(offset - h, 0, offset, h)
    end
end

local function drawTile(launcher, x, y, game, isSelected, scale, opacity)
    -- Apply transformations from center of tile
    love.graphics.push()
    local centerX = x + launcher.tileSizeWidth / 2
    local centerY = y + launcher.tileSizeHeight / 2
    love.graphics.translate(centerX, centerY)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-centerX, -centerY)

    -- Calculate vertical offset (slight bounce effect for selected)
    local yOffset = isSelected and math.sin(love.timer.getTime() * 2) * 3 or 0

    -- Selection border
    if isSelected then
        love.graphics.setColor(launcher.theme.selectedColor[1], launcher.theme.selectedColor[2], launcher.theme.selectedColor[3], opacity)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x - 5, y - 5 + yOffset, launcher.tileSizeWidth + 10, launcher.tileSizeHeight + 10, 10, 10)
    end

    -- Tile background
    love.graphics.setColor(launcher.theme.tileColor[1], launcher.theme.tileColor[2], launcher.theme.tileColor[3], opacity)
    love.graphics.rectangle("fill", x, y + yOffset, launcher.tileSizeWidth, launcher.tileSizeHeight, 10, 10)

    -- Cover image or placeholder
    if game.icon then
        love.graphics.setColor(1, 1, 1, opacity)
        local iconScale = math.min((launcher.tileSizeWidth - 40) / game.icon:getWidth(),
                              (launcher.tileSizeHeight - 100) / game.icon:getHeight())
        local iconX = x + (launcher.tileSizeWidth - game.icon:getWidth() * iconScale) / 2
        love.graphics.draw(game.icon, iconX, y + 20 + yOffset, 0, iconScale, iconScale)
    else
        love.graphics.setColor(0.5, 0.5, 0.55, opacity)
        local placeholderX = x + (launcher.tileSizeWidth - 130) / 2
        love.graphics.rectangle("fill", placeholderX, y + 40 + yOffset, 130, 90, 5, 5)
    end

    -- Title with shadow
    local titleY = y + launcher.tileSizeHeight - 80 + yOffset
    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(0, 0, 0, opacity * 0.7)
    love.graphics.printf(game.title, x + 1, titleY + 1, launcher.tileSizeWidth, "center")
    love.graphics.setColor(launcher.theme.textColor[1], launcher.theme.textColor[2], launcher.theme.textColor[3], opacity)
    love.graphics.printf(game.title, x, titleY, launcher.tileSizeWidth, "center")

    -- Version and Author
    love.graphics.setFont(launcher.smallFont)
    local author = game.author or "Unknown"

    -- Version (only if specified)
    if game.version then
        local versionY = y + launcher.tileSizeHeight - 65 + yOffset
        love.graphics.setColor(0, 0, 0, opacity * 0.7)
        love.graphics.printf("v" .. game.version, x + 1, versionY + 1, launcher.tileSizeWidth, "center")
        love.graphics.setColor(launcher.theme.subtextColor[1], launcher.theme.subtextColor[2], launcher.theme.subtextColor[3], opacity)
        love.graphics.printf("v" .. game.version, x, versionY, launcher.tileSizeWidth, "center")
    end

    -- Author (adjusted position based on whether version exists)
    local authorY = game.version and (y + launcher.tileSizeHeight - 35 + yOffset) or (y + launcher.tileSizeHeight - 35 + yOffset)
    love.graphics.setColor(0, 0, 0, opacity * 0.7)
    love.graphics.printf(author, x + 1, authorY + 1, launcher.tileSizeWidth, "center")
    love.graphics.setColor(launcher.theme.accentColor[1], launcher.theme.accentColor[2], launcher.theme.accentColor[3], opacity)
    love.graphics.printf(author, x, authorY, launcher.tileSizeWidth, "center")

    -- Year (only if specified)
    if game.year then
        local yearY = authorY + 18
        love.graphics.setColor(0, 0, 0, opacity * 0.6)
        love.graphics.printf(game.year, x + 1, yearY + 1, launcher.tileSizeWidth, "center")
        love.graphics.setColor(launcher.theme.subtextColor[1], launcher.theme.subtextColor[2], launcher.theme.subtextColor[3], opacity * 0.8)
        love.graphics.printf(game.year, x, yearY, launcher.tileSizeWidth, "center")
    end

    -- Source code indicator
    if game.source then
        local iconSize = 30
        local iconX = x + launcher.tileSizeWidth - iconSize - 10
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

    -- Draw animated background
    local time = love.timer.getTime()
    drawAnimatedBackground(w, h, time)

    -- Selected game title with Italian flag background
    local selectedGame = launcher.games[launcher.selectedIndex]
    if selectedGame then
        love.graphics.setFont(launcher.titleFont)

        -- Measure text width for background sizing
        local titleWidth = launcher.titleFont:getWidth(selectedGame.title)
        local titleHeight = launcher.titleFont:getHeight()
        local padding = 20
        local bgWidth = titleWidth + padding * 2
        local bgHeight = titleHeight + padding * 2
        local bgX = (w - bgWidth) / 2
        local bgY = 20

        -- Italian flag background (green, white, red vertical stripes)
        local stripeWidth = bgWidth / 3

        -- Green stripe
        love.graphics.setColor(0, 0.55, 0.27)
        love.graphics.rectangle("fill", bgX, bgY, stripeWidth, bgHeight, 5, 5)

        -- White stripe
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", bgX + stripeWidth, bgY, stripeWidth, bgHeight)

        -- Red stripe
        love.graphics.setColor(0.81, 0.13, 0.15)
        love.graphics.rectangle("fill", bgX + stripeWidth * 2, bgY, stripeWidth, bgHeight, 5, 5)

        -- Semi-transparent overlay for better text readability
        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.rectangle("fill", bgX, bgY, bgWidth, bgHeight, 5, 5)

        -- Game title text with shadow
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.printf(selectedGame.title, bgX + 1, bgY + padding + 1, bgWidth, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(selectedGame.title, bgX, bgY + padding, bgWidth, "center")
    end

    -- Game tiles
    local centerX = w / 2
    local centerY = (h - launcher.tileSizeHeight) / 2
    love.graphics.setFont(launcher.gameFont)
    for i, game in ipairs(launcher.games) do
        local x = centerX - (launcher.tileSizeWidth / 2) + (i - launcher.selectedIndex) * (launcher.tileSizeWidth + launcher.tilePadding) + launcher.scrollOffset

        -- Calculate visual distance from center (continuous, not discrete)
        local tileDistance = launcher.tileSizeWidth + launcher.tilePadding
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
