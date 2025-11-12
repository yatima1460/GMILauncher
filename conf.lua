-- LÖVE2D Configuration
function love.conf(t)
    t.identity = "GMILauncher"
    t.version = "11.5"
    t.console = false
    t.accelerometerjoystick = false
    t.externalstorage = false
    t.gammacorrect = false

    t.window.title = "GameMaker Italia Launcher"
    t.window.icon = "assets/gmi_logo.png"
    t.window.width = 1280
    t.window.height = 720
    t.window.borderless = false
    t.window.resizable = false
    t.window.minwidth = 1
    t.window.minheight = 1
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.depth = nil
    t.window.stencil = nil
    t.window.display = 1
    t.window.highdpi = false
    t.window.usedpiscale = true
    t.window.x = nil
    t.window.y = nil

    t.modules.audio = false
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = false
    t.modules.window = true
end

local config = {
    games = {},
    selectedIndex = 1,
    tileSizeWidth = 250,
    tileSizeHeight = 275,
    tilePadding = 20,
    scrollOffset = 0,
    targetOffset = 0,
    scrollSpeed = 8,
    helpText = "Arrow Left/Right or D-Pad: Navigate | Enter/A: Launch | S: Open source code if available | ESC: Quit",
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
