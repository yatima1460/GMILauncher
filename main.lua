
local HELP_TEXT = "Arrow Left/Right or D-Pad: Navigate | Enter/A: Launch | ESC: Quit"

io = require("io")

-- Config
local launcher = {
    title = "GameMaker Italia Launcher",
    games = {},
    selectedIndex = 1,
    tileSize = 250, 
    tilePadding = 20,
    scrollOffset = 0,
    targetOffset = 0,
    scrollSpeed = 8,
    theme = {
        background = {0.2, 0.2, 0.25},
        tileColor = {0.3, 0.3, 0.35},
        selectedColor = {0.4, 0.6, 0.9},
        textColor = {1, 1, 1},
        accentColor = {0.5, 0.8, 1},
        subtextColor = {0.7, 0.7, 0.75} 
    }
}

local function loadGames()
    local success, gamesData = pcall(love.filesystem.load, "games.lua")
    launcher.games = (success and gamesData) and gamesData() or {
        { title = "Game 1", path = "path/to/game1.exe", description = "First game", year = "2024", author = "Author 1" },
        { title = "Game 2", path = "path/to/game2.exe", description = "Second game", year = "2023", author = "Author 2" },
        { title = "Game 3", path = "path/to/game3.exe", description = "Third game", year = "2025", author = "Author 3" },
        { title = "Game 4", path = "path/to/game4.exe", description = "Fourth game", year = "2022", author = "Author 4" },
        { title = "Game 5", path = "path/to/game5.exe", description = "Fifth game", year = "2024", author = "Author 5" },
        { title = "Game 6", path = "path/to/game6.exe", description = "Sixth game", year = "2023", author = "Author 6" },
        { title = "Game 7", path = "path/to/game7.exe", description = "Seventh game", year = "2025", author = "Author 7" }
    }
end

function love.load()
    love.window.setTitle(launcher.title)
    love.window.setMode(1280, 720, {resizable = false, vsync = true})
    launcher.titleFont = love.graphics.newFont(24)
    launcher.gameFont = love.graphics.newFont(16)
    launcher.smallFont = love.graphics.newFont(12)
    loadGames()
end


function love.update(dt)
    local diff = launcher.targetOffset - launcher.scrollOffset
    launcher.scrollOffset = launcher.scrollOffset + diff * launcher.scrollSpeed * dt
    
    if math.abs(diff) < 0.5 then
        launcher.scrollOffset = launcher.targetOffset
    end
end


local function drawTile(x, y, game, isSelected)
    -- Selection border
    if isSelected then
        love.graphics.setColor(launcher.theme.selectedColor)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x - 5, y - 5, launcher.tileSize + 10, launcher.tileSize + 10, 10, 10)
    end
    
    -- Tile background
    love.graphics.setColor(launcher.theme.tileColor)
    love.graphics.rectangle("fill", x, y, launcher.tileSize, launcher.tileSize, 10, 10)
    
    -- Icon or placeholder
    if game.icon then
        love.graphics.setColor(1, 1, 1)
        local scale = math.min((launcher.tileSize - 40) / game.icon:getWidth(),
                              (launcher.tileSize - 100) / game.icon:getHeight())  -- Adjusted for more text space
        local iconX = x + (launcher.tileSize - game.icon:getWidth() * scale) / 2
        love.graphics.draw(game.icon, iconX, y + 20, 0, scale, scale)
    else
        love.graphics.setColor(0.5, 0.5, 0.55)
        love.graphics.rectangle("fill", x + 60, y + 40, 130, 90, 5, 5)  -- Slightly larger placeholder
    end
    
    -- Title with shadow
    local titleY = y + launcher.tileSize - 70
    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(game.title, x + 1, titleY + 1, launcher.tileSize, "center")
    love.graphics.setColor(launcher.theme.textColor)
    love.graphics.printf(game.title, x, titleY, launcher.tileSize, "center")
    
    -- Year and Author
    love.graphics.setFont(launcher.smallFont)
    local year = game.year or "N/A"
    local author = game.author or "Unknown"
    
    -- Year
    local yearY = y + launcher.tileSize - 45
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(year, x + 1, yearY + 1, launcher.tileSize, "center")
    love.graphics.setColor(launcher.theme.subtextColor)
    love.graphics.printf(year, x, yearY, launcher.tileSize, "center")
    
    -- Author
    local authorY = y + launcher.tileSize - 25
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(author, x + 1, authorY + 1, launcher.tileSize, "center")
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.printf(author, x, authorY, launcher.tileSize, "center")
end

function love.draw()
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
        drawTile(x, centerY, game, i == launcher.selectedIndex)
    end
    
    -- Footer
    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.print(HELP_TEXT, 40, h - 40)
end

local function moveSelection(direction)
    launcher.selectedIndex = launcher.selectedIndex + direction
    
    if launcher.selectedIndex < 1 then
        launcher.selectedIndex = #launcher.games
    elseif launcher.selectedIndex > #launcher.games then
        launcher.selectedIndex = 1
    end
    
    launcher.targetOffset = 0
end

function love.keypressed(key)
    local keyActions = {
        right = function() moveSelection(1) end,
        left = function() moveSelection(-1) end,
        ["return"] = function() io.LaunchGame(launcher.selectedIndex) end,
        space = function() io.LaunchGame(launcher.selectedIndex) end,
        escape = love.event.quit
    }
    
    if keyActions[key] then keyActions[key]() end
end





-- local function launchGame(index)
--     local game = launcher.games[index]
--     if not (game and game.path and game.path ~= "") then
--         print("No valid path for: " .. (game and game.title or "Unknown"))
--         return
--     end
    
--     print("Launching: " .. game.title)
    
--     local commands = {
--         'start "" "' .. game.path .. '"',  -- Windows
--         'open "' .. game.path .. '"'        -- macOS
--     }
    
--     for _, cmd in ipairs(commands) do
--         if os.execute(cmd) then return end
--     end
    
--     print("Failed to launch game: " .. game.title)
-- end

function love.gamepadpressed(joystick, button)
    local buttonActions = {
        a = function() launchGame(launcher.selectedIndex) end,
        b = love.event.quit,
        dpright = function() moveSelection(1) end,
        dpleft = function() moveSelection(-1) end
    }
    
    if buttonActions[button] then buttonActions[button]() end
end


