local gameLauncher = require("src.game_launcher")
local qrcode = require("src.qrcode")
local layout = require("src.ui.layout")

local input = {}

local function selectedGame(launcher)
    return launcher.games[launcher.selectedIndex]
end

local function showMessageBox(launcher, title, text, images)
    launcher.showMessageBox = true
    launcher.messageBoxTitle = title
    launcher.messageBoxText = text
    launcher.messageBoxQr = nil
    launcher.messageBoxQrUrl = ""
    launcher.messageBoxImages = images
    launcher.messageBoxImageRects = nil
    launcher.messageBoxHoveredImageIndex = nil
    launcher.fullscreenImage = nil
end

local function showQrMessageBox(launcher, title, url)
    local qr, err = qrcode.encode(url)

    if not qr then
        showMessageBox(launcher, "Not Available", err)
        return
    end

    launcher.showMessageBox = true
    launcher.messageBoxTitle = title
    launcher.messageBoxText = "Scan to open author page"
    launcher.messageBoxQr = qr
    launcher.messageBoxQrUrl = url
    launcher.messageBoxImages = nil
    launcher.messageBoxImageRects = nil
    launcher.messageBoxHoveredImageIndex = nil
    launcher.fullscreenImage = nil
end

local function dismissFullscreenImage(launcher)
    if not launcher.fullscreenImage then
        return false
    end

    launcher.fullscreenImage = nil
    return true
end

local function clearMessageBoxState(launcher)
    launcher.showMessageBox = false
    launcher.messageBoxTitle = ""
    launcher.messageBoxText = ""
    launcher.messageBoxQr = nil
    launcher.messageBoxQrUrl = ""
    launcher.messageBoxImages = nil
    launcher.messageBoxImageRects = nil
    launcher.messageBoxHoveredImageIndex = nil
    launcher.fullscreenImage = nil
end

local function dismissMessageBox(launcher)
    if not launcher.showMessageBox then
        return false
    end

    clearMessageBoxState(launcher)
    return true
end

local function pointInRect(x, y, rect)
    return x >= rect.x
        and x <= rect.x + rect.width
        and y >= rect.y
        and y <= rect.y + rect.height
end

local function updateScreenshotHover(launcher, x, y)
    launcher.messageBoxHoveredImageIndex = nil

    if not launcher.showMessageBox or launcher.fullscreenImage then
        return
    end

    for _, rect in ipairs(launcher.messageBoxImageRects or {}) do
        if pointInRect(x, y, rect) then
            launcher.messageBoxHoveredImageIndex = rect.index
            return
        end
    end
end

local function launchSelectedGame(launcher)
    local game = selectedGame(launcher)
    if not game then
        return
    end

    if game.exe and game.exe ~= "" then
        gameLauncher.launch(game, launcher)
    elseif game.url and game.url ~= "" then
        love.system.openURL(game.url)
    else
        showMessageBox(launcher, "Not Available", "No executable or page available for\n" .. game.title)
    end
end

local function toggleFullscreen(launcher)
    local isFullscreen = love.window.getFullscreen()
    love.window.setFullscreen(not isFullscreen, "desktop")
    launcher.uiScale = nil
    layout.update(launcher)
end

local function openOptionalUrl(launcher, field, fallbackTitle, fallbackText)
    local game = selectedGame(launcher)
    if not game then
        return
    end

    local url = game[field]
    if url and url ~= "" then
        love.system.openURL(url)
    else
        showMessageBox(launcher, fallbackTitle, fallbackText .. "\n" .. game.title)
    end
end

local function showSelectedDescription(launcher)
    local game = selectedGame(launcher)
    if not game then
        return
    end

    if game.description and game.description ~= "" then
        showMessageBox(launcher, game.title, game.description, game.screenshotImages)
    else
        showMessageBox(launcher, "Not Available", "No description available for\n" .. game.title)
    end
end

local function showSelectedUrlQr(launcher)
    local game = selectedGame(launcher)
    if not game then
        return
    end

    if game.url and game.url ~= "" then
        showQrMessageBox(launcher, game.title, game.url)
    else
        showMessageBox(launcher, "Not Available", "No author page available for\n" .. game.title)
    end
end

local function moveSelection(launcher, direction)
    -- Don't allow navigation if message box is showing
    if launcher.showMessageBox then
        return
    end

    -- Check if we would go out of bounds
    local newIndex = launcher.selectedIndex + direction

    -- Stop at boundaries instead of wrapping
    if newIndex < 1 or newIndex > #launcher.games then
        return -- Don't move if at boundary
    end

    -- Store the distance before changing selection
    local tileDistance = launcher.tileSizeWidth + launcher.tilePadding

    launcher.selectedIndex = newIndex

    -- Offset scroll to maintain visual position, then animate back to 0
    launcher.scrollOffset = direction * tileDistance
    launcher.targetOffset = 0

    -- Play navigation sound
    if launcher.navigationSound then
        launcher.navigationSound:stop()
        launcher.navigationSound:play()
    end
end

function input.handleKeypress(launcher, key)
    if dismissFullscreenImage(launcher) then
        return
    end

    -- If message box is showing, dismiss it on any key press
    if dismissMessageBox(launcher) then
        return
    end

    local keyActions = {
        right = function() moveSelection(launcher, 1) end,
        left = function() moveSelection(launcher, -1) end,
        ["return"] = function() launchSelectedGame(launcher) end,
        space = function() launchSelectedGame(launcher) end,
        s = function()
            openOptionalUrl(launcher, "source", "Source Not Available", "No source code available for")
        end,
        b = function()
            openOptionalUrl(launcher, "url", "Author Page Not Available", "No author page available for")
        end,
        q = function() showSelectedUrlQr(launcher) end,
        d = function() showSelectedDescription(launcher) end,
        f = function() toggleFullscreen(launcher) end,
        escape = love.event.quit
    }

    if keyActions[key] then
        keyActions[key]()
    end
end

function input.handleMouseMoved(launcher, x, y)
    updateScreenshotHover(launcher, x, y)
end

function input.handleMousePressed(launcher, x, y, button)
    if button ~= 1 then
        return
    end

    if dismissFullscreenImage(launcher) then
        return
    end

    updateScreenshotHover(launcher, x, y)

    local imageIndex = launcher.messageBoxHoveredImageIndex
    if imageIndex and launcher.messageBoxImages then
        launcher.fullscreenImage = launcher.messageBoxImages[imageIndex]
    end
end

function input.handleGamepadPress(launcher, _joystick, button)
    if dismissFullscreenImage(launcher) then
        return
    end

    -- If message box is showing, dismiss it on any button press
    if dismissMessageBox(launcher) then
        return
    end

    local buttonActions = {
        a = function() launchSelectedGame(launcher) end,
        b = function()
            openOptionalUrl(launcher, "url", "Author Page Not Available", "No author page available for")
        end,
        y = love.event.quit,
        dpright = function() moveSelection(launcher, 1) end,
        dpleft = function() moveSelection(launcher, -1) end
    }

    if buttonActions[button] then
        buttonActions[button]()
    end
end

return input
