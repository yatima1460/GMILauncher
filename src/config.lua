local config = {
    games = {},
    selectedIndex = 1,
    baseTileSizeWidth = 250,
    baseTileSizeHeight = 275,
    baseTilePadding = 20,
    tileSizeWidth = 250,
    tileSizeHeight = 275,
    tilePadding = 20,
    uiScale = nil,
    scrollOffset = 0,
    targetOffset = 0,
    helpText = "Arrows: Nav | D: Info | Q: QR (page) | F: Fullscreen | Enter: Launch | B: Open page in browser | S: Open source in browser | ESCape: Quit",
    isLaunching = false,
    launchingGameTitle = "",
    showMessageBox = false,
    messageBoxTitle = "",
    messageBoxText = "",
    messageBoxQr = nil,
    messageBoxQrUrl = "",
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
