local background = {}

function background.drawAnimated(w, h, time)
    local lineScale = math.min(w / 1280, h / 720)
    local segments = 20

    for i = 0, segments do
        local progress = i / segments

        local r = 0.15 + math.sin(time * 0.3 + progress * 2) * 0.08
        local g = 0.15 + math.sin(time * 0.4 + progress * 3) * 0.08
        local b = 0.2 + math.sin(time * 0.5 + progress * 1.5) * 0.1

        love.graphics.setColor(r, g, b)
        local y = (h / segments) * i
        love.graphics.rectangle("fill", 0, y, w, h / segments + 1)
    end

    love.graphics.setLineWidth(2 * lineScale)
    for i = 0, 30 do
        local offset = (time * 20 + i * 40) % (w + h)
        local alpha = 0.03 + math.sin(time + i * 0.5) * 0.02
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.line(offset - h, 0, offset, h)
    end
end

function background.drawTitleBanner(launcher, width)
    local uiScale = launcher.uiScale or 1
    love.graphics.setFont(launcher.titleFont)
    local launcherTitle = "GameMaker Italia Launcher"

    local titleWidth = launcher.titleFont:getWidth(launcherTitle)
    local titleHeight = launcher.titleFont:getHeight()
    local padding = 20 * uiScale
    local bgWidth = titleWidth + padding * 2
    local bgHeight = titleHeight + padding * 2
    local bgX = (width - bgWidth) / 2
    local bgY = 20 * uiScale
    local stripeWidth = bgWidth / 3
    local cornerRadius = 5 * uiScale

    love.graphics.setColor(0, 0.55, 0.27)
    love.graphics.rectangle("fill", bgX, bgY, stripeWidth, bgHeight, cornerRadius, cornerRadius)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", bgX + stripeWidth, bgY, stripeWidth, bgHeight)

    love.graphics.setColor(0.81, 0.13, 0.15)
    love.graphics.rectangle("fill", bgX + stripeWidth * 2, bgY, stripeWidth, bgHeight, cornerRadius, cornerRadius)

    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", bgX, bgY, bgWidth, bgHeight, cornerRadius, cornerRadius)

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.printf(launcherTitle, bgX + 1, bgY + padding + 1, bgWidth, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(launcherTitle, bgX, bgY + padding, bgWidth, "center")
end

return background
