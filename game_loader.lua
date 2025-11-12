local gameLoader = {}

function gameLoader.loadGames(gamesPath)
    local games = {}

    -- Mount the source directory (where the .exe is located) so we can access external games folder
    local sourceDir = love.filesystem.getSourceBaseDirectory()
    if sourceDir and sourceDir ~= "" then
        love.filesystem.mount(sourceDir, "external")
        -- Try to load from external mount point first (for games outside the .exe)
        local externalGamesPath = "external/games"
        if love.filesystem.getInfo(externalGamesPath) then
            gamesPath = externalGamesPath
        end
    end

    local gamesFolders = love.filesystem.getDirectoryItems(gamesPath)
    print("Loading games from: " .. gamesPath)
    
    for _, folder in ipairs(gamesFolders) do
        local folderPath = gamesPath .. "/" .. folder

        print("Checking folder: " .. folderPath)

        -- Check if it's actually a directory
        local info = love.filesystem.getInfo(folderPath)
        if info and info.type == "directory" then
            local metadataPath = folderPath .. "/metadata.lua"
            local coverPath = folderPath .. "/cover.png"

            -- Try to load metadata
            local metadata = {}
            if love.filesystem.getInfo(metadataPath) then
                local content = love.filesystem.read(metadataPath)
                if content then
                    -- Load the metadata as Lua code
                    local metadataFunc = load(content)
                    if metadataFunc then
                        local success, result = pcall(metadataFunc)
                        if success and type(result) == "table" then
                            metadata = result
                        else
                            print("Failed to execute metadata file: " .. metadataPath)
                        end
                    else
                        print("Failed to load metadata file: " .. metadataPath)
                    end
                else
                    print("Failed to read metadata file: " .. metadataPath)
                end
            else
                print("No metadata found for game directory, skipping: " .. folderPath)
            end


            -- Try to load cover image
            local coverImage = nil
            if love.filesystem.getInfo(coverPath) then
                local success, image = pcall(love.graphics.newImage, coverPath)
                if success then
                    coverImage = image
                else 
                    print("Failed to load cover image: " .. coverPath)
                end
            else
                print("No cover image found for game: " .. (metadata.title or folder))
            end

            -- Add game to launcher
            table.insert(games, {
                title = metadata.title or folder,
                path = folderPath,
                exe = metadata.exe or folder .. ".exe",
                author = metadata.author or "Unknown",
                version = metadata.version or nil,
                url = metadata.url or "",
                icon = coverImage,
                source = metadata.source or nil,
                year = metadata.year or nil
            })
            print("Loaded game: " .. (metadata.title or folder))
        end
    end

    -- Fallback if no games found
    if #games == 0 then
        games = {
            { title = "No Games Found", path = "", author = "Add games to /games folder", version = "", icon = nil }
        }
    end

    return games
end

return gameLoader
