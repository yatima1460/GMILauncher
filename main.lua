-- main.lua - Nintendo Switch-style Launcher with Smooth Scrolling

local launcher = {}

function love.load()
    love.window.setTitle("GameMaker Italia Launcher")
    love.window.setMode(1280, 720, {resizable = true, vsync = true})

    launcher.games = {}
    launcher.selectedIndex = 1
    launcher.tileSize = 200
    launcher.tilePadding = 20
    
    -- Smooth scrolling variables
    launcher.scrollOffset = 0        -- Current scroll position
    launcher.targetOffset = 0        -- Target scroll position
    launcher.scrollSpeed = 8         -- Higher = faster scrolling (adjust to taste)

    launcher.theme = {
        background = {0.2, 0.2, 0.25},
        tileColor = {0.3, 0.3, 0.35},
        selectedColor = {0.4, 0.6, 0.9},
        textColor = {1, 1, 1},
        accentColor = {0.5, 0.8, 1}
    }

    launcher.titleFont = love.graphics.newFont(24)
    launcher.gameFont = love.graphics.newFont(16)

    loadGames()
    launcher.joysticks = love.joystick.getJoysticks()
end

function loadGames()
    local success, gamesData = pcall(love.filesystem.load, "games.lua")
    if success and gamesData then
        launcher.games = gamesData()
    else
        launcher.games = {
            { title = "Game 1", path = "path/to/game1.exe", icon = nil, description = "First game" },
            { title = "Game 2", path = "path/to/game2.exe", icon = nil, description = "Second game" },
            { title = "Game 3", path = "path/to/game3.exe", icon = nil, description = "Third game" },
            { title = "Game 4", path = "path/to/game4.exe", icon = nil, description = "Fourth game" },
            { title = "Game 5", path = "path/to/game5.exe", icon = nil, description = "Fifth game" },
            { title = "Game 6", path = "path/to/game6.exe", icon = nil, description = "Sixth game" },
            { title = "Game 7", path = "path/to/game7.exe", icon = nil, description = "Seventh game" }
        }
    end
end

function love.update(dt)
    -- Smooth scrolling using linear interpolation (lerp)
    -- The formula: current = current + (target - current) * speed * dt
    local diff = launcher.targetOffset - launcher.scrollOffset
    launcher.scrollOffset = launcher.scrollOffset + diff * launcher.scrollSpeed * dt
    
    -- Snap to target if very close (prevents infinite tiny movements)
    if math.abs(diff) < 0.5 then
        launcher.scrollOffset = launcher.targetOffset
    end
end

function love.draw()
    love.graphics.clear(launcher.theme.background)
    love.graphics.setFont(launcher.titleFont)
    love.graphics.setColor(launcher.theme.textColor)
    love.graphics.print("GameMaker Italia Launcher", 40, 20)

    drawGameGrid()

    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.print("Arrow Left/Right or D-Pad: Navigate | Enter/A: Launch | ESC: Quit", 40, love.graphics.getHeight() - 40)
end

function drawGameGrid()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local startY = (screenHeight - launcher.tileSize) / 2

    love.graphics.setFont(launcher.gameFont)

    for i, game in ipairs(launcher.games) do
        -- Apply smooth scroll offset to x position
        local x = (screenWidth / 2) - (launcher.tileSize / 2) + 
                  (i - launcher.selectedIndex) * (launcher.tileSize + launcher.tilePadding) + 
                  launcher.scrollOffset
        local y = startY

        local isSelected = (i == launcher.selectedIndex)

        if isSelected then
            love.graphics.setColor(launcher.theme.selectedColor)
            love.graphics.setLineWidth(4)
            love.graphics.rectangle("line", x - 5, y - 5, launcher.tileSize + 10, launcher.tileSize + 10, 10, 10)
            love.graphics.setColor(launcher.theme.tileColor)
        else
            love.graphics.setColor(launcher.theme.tileColor)
        end

        love.graphics.rectangle("fill", x, y, launcher.tileSize, launcher.tileSize, 10, 10)

        if game.icon then
            love.graphics.setColor(1, 1, 1)
            local iconScale = math.min((launcher.tileSize - 40) / game.icon:getWidth(),
                                      (launcher.tileSize - 60) / game.icon:getHeight())
            local iconX = x + (launcher.tileSize - game.icon:getWidth() * iconScale) / 2
            local iconY = y + 20
            love.graphics.draw(game.icon, iconX, iconY, 0, iconScale, iconScale)
        else
            love.graphics.setColor(0.5, 0.5, 0.55)
            love.graphics.rectangle("fill", x + 60, y + 40, 80, 80, 5, 5)
        end

        local titleY = y + launcher.tileSize - 30
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(game.title, x + 1, titleY + 1, launcher.tileSize, "center")
        love.graphics.setColor(launcher.theme.textColor)
        love.graphics.printf(game.title, x, titleY, launcher.tileSize, "center")
    end
end

function love.keypressed(key)
    if key == "right" then
        moveSelection(1)
    elseif key == "left" then
        moveSelection(-1)
    elseif key == "return" or key == "space" then
        launchGame(launcher.selectedIndex)
    elseif key == "escape" then
        love.event.quit()
    end
end

function love.gamepadpressed(joystick, button)
    if button == "a" then
        launchGame(launcher.selectedIndex)
    elseif button == "b" then
        love.event.quit()
    elseif button == "dpright" then
        moveSelection(1)
    elseif button == "dpleft" then
        moveSelection(-1)
    end
end

function moveSelection(dx)
    local newIndex = launcher.selectedIndex + dx
    if newIndex < 1 then
        newIndex = #launcher.games
    elseif newIndex > #launcher.games then
        newIndex = 1
    end
    launcher.selectedIndex = newIndex
    
    -- Update target offset (this will be smoothly interpolated in love.update)
    launcher.targetOffset = 0  -- Always scroll to center the selected tile
end

function launchGame(index)
    local game = launcher.games[index]
    if game and game.path and game.path ~= "" then
        print("Launching: " .. game.title)
        local success = os.execute('start "" "' .. game.path .. '"')
        if not success then
            success = os.execute('open "' .. game.path .. '"')
        end
        if not success then
            print("Failed to launch game: " .. game.title)
        end
    else
        print("No valid path for: " .. (game and game.title or "Unknown"))
    end
end
