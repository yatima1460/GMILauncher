local json = require("utils.json")

local gameLoader = {}

function gameLoader.loadGames(launcher)
    launcher.games = {}

    local gamesPath = "games"
    local gamesFolders = love.filesystem.getDirectoryItems(gamesPath)

    for _, folder in ipairs(gamesFolders) do
        local folderPath = gamesPath .. "/" .. folder

        -- Check if it's actually a directory
        local info = love.filesystem.getInfo(folderPath)
        if info and info.type == "directory" then
            local metadataPath = folderPath .. "/metadata.json"
            local coverPath = folderPath .. "/cover.png"

            -- Try to load metadata
            local metadata = {}
            if love.filesystem.getInfo(metadataPath) then
                local content = love.filesystem.read(metadataPath)
                if content then
                    metadata = json.decode(content)
                end
            end

            -- Try to load cover image
            local coverImage = nil
            if love.filesystem.getInfo(coverPath) then
                local success, image = pcall(love.graphics.newImage, coverPath)
                if success then
                    coverImage = image
                end
            end

            -- Add game to launcher
            table.insert(launcher.games, {
                title = metadata.title,
                path = folderPath,
                start = folderPath .. "/" .. metadata.start,
                author = metadata.author or "Unknown",
                version = metadata.version or "N/A",
                url = metadata.url or "",
                icon = coverImage
            })
        end
    end

    -- Fallback if no games found
    if #launcher.games == 0 then
        launcher.games = {
            { title = "No Games Found", path = "", author = "Add games to /games folder", version = "", icon = nil }
        }
    end
end

return gameLoader
