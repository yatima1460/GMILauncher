local config = {
    games = {},
    selectedIndex = 1,
    tileSizeWidth = 250,
    tileSizeHeight = 275,
    tilePadding = 20,
    scrollOffset = 0,
    targetOffset = 0,
    helpText = "Arrows: Navigate | D: description | Enter: Launch | B: Author page | S: Source code | ESC/Y: Quit",
    isLaunching = false,
    launchingGameTitle = "",
    showMessageBox = false,
    messageBoxTitle = "",
    messageBoxText = "",
    theme = {
        background = { 0.2, 0.2, 0.25 },
        tileColor = { 0.3, 0.3, 0.35 },
        selectedColor = { 0.4, 0.6, 0.9 },
        textColor = { 1, 1, 1 },
        accentColor = { 0.5, 0.8, 1 },
        subtextColor = { 0.7, 0.7, 0.75 }
    }
}

return config
