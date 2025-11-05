local HELP_TEXT = "Arrow Left/Right or D-Pad: Navigate | Enter/A: Launch | ESC: Quit"

-- Launcher configuration
local config = {
    title = "GameMaker Italia Launcher",
    games = {},
    selectedIndex = 1,
    tileSize = 250,
    tilePadding = 20,
    scrollOffset = 0,
    targetOffset = 0,
    scrollSpeed = 8,
    helpText = HELP_TEXT,
    theme = {
        background = {0.2, 0.2, 0.25},
        tileColor = {0.3, 0.3, 0.35},
        selectedColor = {0.4, 0.6, 0.9},
        textColor = {1, 1, 1},
        accentColor = {0.5, 0.8, 1},
        subtextColor = {0.7, 0.7, 0.75}
    }
}

return config
