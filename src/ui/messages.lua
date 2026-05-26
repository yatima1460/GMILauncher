local background = require("src.ui.background")

local messages = {}

function messages.drawMessageBox(launcher)
    local w, h = love.graphics.getDimensions()

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local boxWidth = 500
    local padding = 40
    local titlePadding = 20

    love.graphics.setFont(launcher.gameFont)
    local titleHeight = launcher.gameFont:getHeight()
    local _, wrappedText = launcher.gameFont:getWrap(launcher.messageBoxText, boxWidth - padding)
    local textHeight = #wrappedText * launcher.gameFont:getHeight()
    local boxHeight = math.max(titlePadding * 2 + titleHeight + padding + textHeight, 150)
    local boxX = (w - boxWidth) / 2
    local boxY = (h - boxHeight) / 2

    love.graphics.setColor(0.25, 0.25, 0.3, 0.95)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 10, 10)

    love.graphics.setColor(launcher.theme.selectedColor)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 10, 10)

    love.graphics.setColor(launcher.theme.textColor)
    love.graphics.printf(launcher.messageBoxTitle, boxX + 20, boxY + titlePadding, boxWidth - 40, "center")
    love.graphics.printf(launcher.messageBoxText, boxX + 20, boxY + titlePadding + titleHeight + 20, boxWidth - 40, "center")
end

function messages.drawLaunchingScreen(launcher)
    local w, h = love.graphics.getDimensions()
    local time = love.timer.getTime()

    background.drawAnimated(w, h, time)

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local boxWidth = 600
    local boxHeight = 200
    local boxX = (w - boxWidth) / 2
    local boxY = (h - boxHeight) / 2
    local stripeHeight = boxHeight / 3

    love.graphics.setColor(0, 0.55, 0.27, 0.9)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, stripeHeight, 10, 10)

    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.rectangle("fill", boxX, boxY + stripeHeight, boxWidth, stripeHeight)

    love.graphics.setColor(0.81, 0.13, 0.15, 0.9)
    love.graphics.rectangle("fill", boxX, boxY + stripeHeight * 2, boxWidth, stripeHeight, 10, 10)

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 10, 10)

    love.graphics.setFont(launcher.titleFont)
    local dots = string.rep(".", math.floor(time * 2) % 4)
    local launchText = "Launching" .. dots
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.printf(launchText, boxX + 1, boxY + 41, boxWidth, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(launchText, boxX, boxY + 40, boxWidth, "center")

    love.graphics.setFont(launcher.gameFont)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.printf(launcher.launchingGameTitle, boxX + 1, boxY + 101, boxWidth, "center")
    love.graphics.setColor(launcher.theme.accentColor)
    love.graphics.printf(launcher.launchingGameTitle, boxX, boxY + 100, boxWidth, "center")
end

return messages
