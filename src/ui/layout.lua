local layout = {}

local BASE_WIDTH = 1280
local BASE_HEIGHT = 720
local BASE_TITLE_FONT = 24
local BASE_GAME_FONT = 16
local BASE_SMALL_FONT = 12

local function scaledFont(size, scale)
    return love.graphics.newFont(math.max(10, math.floor(size * scale + 0.5)))
end

function layout.update(launcher)
    local width, height = love.graphics.getDimensions()
    local scale = math.min(width / BASE_WIDTH, height / BASE_HEIGHT)

    if launcher.uiScale == scale then
        return
    end

    launcher.uiScale = scale
    launcher.tileSizeWidth = math.floor(launcher.baseTileSizeWidth * scale + 0.5)
    launcher.tileSizeHeight = math.floor(launcher.baseTileSizeHeight * scale + 0.5)
    launcher.tilePadding = math.floor(launcher.baseTilePadding * scale + 0.5)
    launcher.titleFont = scaledFont(BASE_TITLE_FONT, scale)
    launcher.gameFont = scaledFont(BASE_GAME_FONT, scale)
    launcher.smallFont = scaledFont(BASE_SMALL_FONT, scale)
end

return layout
