local background = require("src.ui.background")

local messages = {}

local function drawQrCode(qr, x, y, maxSize)
    local quietZone = 4
    local moduleSize = math.floor(maxSize / (qr.size + quietZone * 2))
    local qrSize = (qr.size + quietZone * 2) * moduleSize
    local offset = quietZone * moduleSize

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", x, y, qrSize, qrSize)

    love.graphics.setColor(0, 0, 0)
    for row = 1, qr.size do
        for column = 1, qr.size do
            if qr.modules[row][column] then
                love.graphics.rectangle(
                    "fill",
                    x + offset + (column - 1) * moduleSize,
                    y + offset + (row - 1) * moduleSize,
                    moduleSize,
                    moduleSize
                )
            end
        end
    end

    return qrSize
end

function messages.drawMessageBox(launcher)
    local w, h = love.graphics.getDimensions()
    local uiScale = launcher.uiScale or 1

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local hasQr = launcher.messageBoxQr ~= nil
    local boxWidth = (hasQr and 560 or 500) * uiScale
    local padding = 40 * uiScale
    local titlePadding = 20 * uiScale

    love.graphics.setFont(launcher.gameFont)
    local titleHeight = launcher.gameFont:getHeight()
    local textWidth = boxWidth - padding
    local _, wrappedText = launcher.gameFont:getWrap(launcher.messageBoxText, textWidth)
    local textHeight = #wrappedText * launcher.gameFont:getHeight()
    local qrMaxSize = 400 * uiScale
    local qrModuleSize = hasQr and math.floor(qrMaxSize / (launcher.messageBoxQr.size + 8)) or 0
    local qrSize = hasQr and (launcher.messageBoxQr.size + 8) * qrModuleSize or 0
    local urlHeight = 0

    if hasQr and launcher.messageBoxQrUrl and launcher.messageBoxQrUrl ~= "" then
        local _, wrappedUrl = launcher.smallFont:getWrap(launcher.messageBoxQrUrl, textWidth)
        urlHeight = #wrappedUrl * launcher.smallFont:getHeight()
    end

    local contentHeight = hasQr and (titlePadding + titleHeight + 18 * uiScale + textHeight + 18 * uiScale + qrSize + 16 * uiScale + urlHeight + titlePadding)
        or (titlePadding * 2 + titleHeight + padding + textHeight)
    local boxHeight = math.max(contentHeight, 150 * uiScale)
    local boxX = (w - boxWidth) / 2
    local boxY = (h - boxHeight) / 2

    love.graphics.setColor(0.25, 0.25, 0.3, 0.95)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 10 * uiScale, 10 * uiScale)

    love.graphics.setColor(launcher.theme.selectedColor)
    love.graphics.setLineWidth(3 * uiScale)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 10 * uiScale, 10 * uiScale)

    love.graphics.setColor(launcher.theme.textColor)
    love.graphics.printf(launcher.messageBoxTitle, boxX + 20 * uiScale, boxY + titlePadding, boxWidth - 40 * uiScale, "center")

    local textY = boxY + titlePadding + titleHeight + 20 * uiScale
    love.graphics.printf(launcher.messageBoxText, boxX + 20 * uiScale, textY, boxWidth - 40 * uiScale, "center")

    if hasQr then
        local qrX = boxX + (boxWidth - qrSize) / 2
        local qrY = textY + textHeight + 18 * uiScale
        drawQrCode(launcher.messageBoxQr, qrX, qrY, qrMaxSize)

        if launcher.messageBoxQrUrl and launcher.messageBoxQrUrl ~= "" then
            love.graphics.setFont(launcher.smallFont)
            love.graphics.setColor(launcher.theme.subtextColor)
            love.graphics.printf(
                launcher.messageBoxQrUrl,
                boxX + 20 * uiScale,
                qrY + qrSize + 12 * uiScale,
                boxWidth - 40 * uiScale,
                "center"
            )
        end
    end
end

function messages.drawLaunchingScreen(launcher)
    local w, h = love.graphics.getDimensions()
    local time = love.timer.getTime()
    local uiScale = launcher.uiScale or 1

    background.drawAnimated(w, h, time)

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local boxWidth = 600 * uiScale
    local boxHeight = 200 * uiScale
    local boxX = (w - boxWidth) / 2
    local boxY = (h - boxHeight) / 2
    local stripeHeight = boxHeight / 3
    local cornerRadius = 10 * uiScale

    love.graphics.setColor(0, 0.55, 0.27, 0.9)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, stripeHeight, cornerRadius, cornerRadius)

    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.rectangle("fill", boxX, boxY + stripeHeight, boxWidth, stripeHeight)

    love.graphics.setColor(0.81, 0.13, 0.15, 0.9)
    love.graphics.rectangle("fill", boxX, boxY + stripeHeight * 2, boxWidth, stripeHeight, cornerRadius, cornerRadius)

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, cornerRadius, cornerRadius)

    love.graphics.setFont(launcher.titleFont)
    local dots = string.rep(".", math.floor(time * 2) % 4)
    local launchText = "Launching" .. dots
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.printf(launchText, boxX + 1 * uiScale, boxY + 41 * uiScale, boxWidth, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(launchText, boxX, boxY + 40 * uiScale, boxWidth, "center")

    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.printf(launcher.launchingGameTitle, boxX + 1 * uiScale, boxY + 101 * uiScale, boxWidth, "center")
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.printf(launcher.launchingGameTitle, boxX, boxY + 100 * uiScale, boxWidth, "center")
end

return messages
