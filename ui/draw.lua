local draw = {}

local function drawTile(launcher, x, y, game, isSelected)
    -- Selection border
    if isSelected then
        love.graphics.setColor(launcher.theme.selectedColor)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x - 5, y - 5, launcher.tileSize + 10, launcher.tileSize + 10, 10, 10)
    end

    -- Tile background
    love.graphics.setColor(launcher.theme.tileColor)
    love.graphics.rectangle("fill", x, y, launcher.tileSize, launcher.tileSize, 10, 10)

    -- Cover image or placeholder
    if game.icon then
        love.graphics.setColor(1, 1, 1)
        local scale = math.min((launcher.tileSize - 40) / game.icon:getWidth(),
                              (launcher.tileSize - 100) / game.icon:getHeight())
        local iconX = x + (launcher.tileSize - game.icon:getWidth() * scale) / 2
        love.graphics.draw(game.icon, iconX, y + 20, 0, scale, scale)
    else
        love.graphics.setColor(0.5, 0.5, 0.55)
        love.graphics.rectangle("fill", x + 60, y + 40, 130, 90, 5, 5)
    end

    -- Title with shadow
    local titleY = y + launcher.tileSize - 70
    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(game.title, x + 1, titleY + 1, launcher.tileSize, "center")
    love.graphics.setColor(launcher.theme.textColor)
    love.graphics.printf(game.title, x, titleY, launcher.tileSize, "center")

    -- Version and Author
    love.graphics.setFont(launcher.smallFont)
    local version = game.version or "N/A"
    local author = game.author or "Unknown"

    -- Version
    local versionY = y + launcher.tileSize - 45
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("v" .. version, x + 1, versionY + 1, launcher.tileSize, "center")
    love.graphics.setColor(launcher.theme.subtextColor)
    love.graphics.printf("v" .. version, x, versionY, launcher.tileSize, "center")

    -- Author
    local authorY = y + launcher.tileSize - 25
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(author, x + 1, authorY + 1, launcher.tileSize, "center")
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.printf(author, x, authorY, launcher.tileSize, "center")
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
        drawTile(launcher, x, centerY, game, i == launcher.selectedIndex)
    end

    -- Footer
    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.print(launcher.helpText, 40, h - 40)
end

return draw
