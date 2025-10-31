-- main.lua - Nintendo Switch-style Launcher for Love2D
-- A simple game launcher inspired by Ninty Launcher

-- Global variables
local launcher = {}

function love.load()
    
    -- Window settings
    love.window.setTitle("GameMaker Italia Launcher")
    love.window.setMode(1280, 720, {resizable = true, vsync = true})

    -- Initialize launcher state
    launcher.games = {}
    launcher.selectedIndex = 1
    launcher.scrollOffset = 0
    launcher.columns = 5
    launcher.rows = 2
    launcher.tileSize = 200
    launcher.tilePadding = 20

    -- Input handling
    launcher.keysPressed = {}
    launcher.joystickPressed = {}

    -- Theme settings
    launcher.theme = {
        background = {0.2, 0.2, 0.25},
        tileColor = {0.3, 0.3, 0.35},
        selectedColor = {0.4, 0.6, 0.9},
        textColor = {1, 1, 1},
        accentColor = {0.5, 0.8, 1}
    }

    -- Fonts
    launcher.titleFont = love.graphics.newFont(24)
    launcher.gameFont = love.graphics.newFont(16)

    -- Background image (optional)
    launcher.background = nil

    -- Load games from games.lua or create default
    loadGames()

    -- Get joysticks
    launcher.joysticks = love.joystick.getJoysticks()
end

function loadGames()
    -- Try to load games from external file
    local success, gamesData = pcall(love.filesystem.load, "games.lua")

    if success and gamesData then
        launcher.games = gamesData()
    else
        -- Default example games if no file exists
        launcher.games = {
            {
                title = "Game 1",
                path = "path/to/game1.exe",
                icon = nil,
                description = "First game"
            },
            {
                title = "Game 2",
                path = "path/to/game2.exe",
                icon = nil,
                description = "Second game"
            },
            {
                title = "Game 3",
                path = "path/to/game2.exe",
                icon = nil,
                description = "Second game"
            },
            -- {
            --     title = "Add Game",
            --     path = "",
            --     icon = nil,
            --     description = "Add a new game"
            -- }
        }
    end
end

function love.update(dt)
    -- Reset pressed keys for next frame
    launcher.keysPressed = {}
    launcher.joystickPressed = {}

    -- Handle gamepad input
    for k, joystick in ipairs(launcher.joysticks) do
        -- Navigation with analog stick
        local deadzone = 0.3
        local x = joystick:getGamepadAxis("leftx")
        local y = joystick:getGamepadAxis("lefty")

        -- You can add analog navigation here if needed
    end
end

function love.draw()
    -- Clear screen with background color
    love.graphics.clear(launcher.theme.background)

    -- Draw background image if available
    if launcher.background then
        love.graphics.draw(launcher.background, 0, 0)
    end

    -- Draw title
    love.graphics.setFont(launcher.titleFont)
    love.graphics.setColor(launcher.theme.textColor)
    love.graphics.print("GameMaker Italia Launcher", 40, 20)

    -- Draw game grid
    drawGameGrid()

    -- Draw instructions at bottom
    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.print("Arrow Keys/D-Pad: Navigate | Enter/A: Launch | ESC: Quit", 40, love.graphics.getHeight() - 40)
end

function drawGameGrid()
    local startX = 40
    local startY = 100
    local visibleGames = launcher.columns * launcher.rows

    love.graphics.setFont(launcher.gameFont)

    for i = 1, math.min(#launcher.games, visibleGames) do
        local gameIndex = i + launcher.scrollOffset
        if gameIndex > #launcher.games then break end

        local game = launcher.games[gameIndex]
        local col = (i - 1) % launcher.columns
        local row = math.floor((i - 1) / launcher.columns)

        local x = startX + col * (launcher.tileSize + launcher.tilePadding)
        local y = startY + row * (launcher.tileSize + launcher.tilePadding)

        -- Determine if this tile is selected
        local isSelected = (gameIndex == launcher.selectedIndex)

        -- Draw tile background
        if isSelected then
            love.graphics.setColor(launcher.theme.selectedColor)
            -- Draw selection border
            love.graphics.setLineWidth(4)
            love.graphics.rectangle("line", x - 5, y - 5, launcher.tileSize + 10, launcher.tileSize + 10, 10, 10)
            love.graphics.setColor(launcher.theme.tileColor)
        else
            love.graphics.setColor(launcher.theme.tileColor)
        end

        -- Draw tile
        love.graphics.rectangle("fill", x, y, launcher.tileSize, launcher.tileSize, 10, 10)

        -- Draw icon if available
        if game.icon then
            love.graphics.setColor(1, 1, 1)
            local iconScale = math.min((launcher.tileSize - 40) / game.icon:getWidth(), 
                                      (launcher.tileSize - 60) / game.icon:getHeight())
            local iconX = x + (launcher.tileSize - game.icon:getWidth() * iconScale) / 2
            local iconY = y + 20
            love.graphics.draw(game.icon, iconX, iconY, 0, iconScale, iconScale)
        else
            -- Draw placeholder icon
            love.graphics.setColor(0.5, 0.5, 0.55)
            love.graphics.rectangle("fill", x + 60, y + 40, 80, 80, 5, 5)
        end

        -- Draw game title
        love.graphics.setColor(launcher.theme.textColor)
        local titleY = y + launcher.tileSize - 30
        love.graphics.printf(game.title, x, titleY, launcher.tileSize, "center")
    end
end

function love.keypressed(key)
    launcher.keysPressed[key] = true

    -- Navigation
    if key == "right" then
        moveSelection(1, 0)
    elseif key == "left" then
        moveSelection(-1, 0)
    elseif key == "down" then
        moveSelection(0, 1)
    elseif key == "up" then
        moveSelection(0, -1)
    elseif key == "return" or key == "space" then
        launchGame(launcher.selectedIndex)
    elseif key == "escape" then
        love.event.quit()
    end
end

function love.gamepadpressed(joystick, button)
    launcher.joystickPressed[button] = true

    -- A button to launch
    if button == "a" then
        launchGame(launcher.selectedIndex)
    elseif button == "b" then
        love.event.quit()
    elseif button == "dpright" then
        moveSelection(1, 0)
    elseif button == "dpleft" then
        moveSelection(-1, 0)
    elseif button == "dpdown" then
        moveSelection(0, 1)
    elseif button == "dpup" then
        moveSelection(0, -1)
    end
end

function moveSelection(dx, dy)
    local col = (launcher.selectedIndex - 1) % launcher.columns
    local row = math.floor((launcher.selectedIndex - 1) / launcher.columns)

    col = col + dx
    row = row + dy

    -- Wrap horizontally
    if col < 0 then
        col = launcher.columns - 1
        row = row - 1
    elseif col >= launcher.columns then
        col = 0
        row = row + 1
    end

    -- Clamp vertically
    local totalRows = math.ceil(#launcher.games / launcher.columns)
    if row < 0 then row = 0 end
    if row >= totalRows then row = totalRows - 1 end

    -- Calculate new index
    local newIndex = row * launcher.columns + col + 1

    -- Clamp to valid game indices
    if newIndex >= 1 and newIndex <= #launcher.games then
        launcher.selectedIndex = newIndex

        -- Auto-scroll if needed
        local visibleGames = launcher.columns * launcher.rows
        if launcher.selectedIndex > launcher.scrollOffset + visibleGames then
            launcher.scrollOffset = launcher.selectedIndex - visibleGames
        elseif launcher.selectedIndex <= launcher.scrollOffset then
            launcher.scrollOffset = math.max(0, launcher.selectedIndex - 1)
        end
    end
end

function launchGame(index)
    local game = launcher.games[index]

    if game and game.path and game.path ~= "" then
        print("Launching: " .. game.title)
        print("Path: " .. game.path)

        -- Launch the game using os.execute
        -- Note: This is platform-specific
        local success = os.execute('start "" "' .. game.path .. '"')

        if not success then
            -- Try alternative launch method for Linux/Mac
            success = os.execute('open "' .. game.path .. '"')
        end

        if not success then
            print("Failed to launch game: " .. game.title)
        end
    else
        print("No valid path for: " .. (game and game.title or "Unknown"))
    end
end

function wasPressed(key)
    return launcher.keysPressed[key]
end

function joystickWasPressed(button)
    return launcher.joystickPressed[button]
end
