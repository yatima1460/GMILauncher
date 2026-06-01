local buildInfo = require("src.build_info")

local gameLoader = {}

local function trim(value)
    if type(value) ~= "string" then
        return nil
    end

    return value:match("^%s*(.-)%s*$")
end

local function optionalString(value)
    local text = trim(value)
    if text == "" then
        return nil
    end

    return text
end

local function isSafeExecutableName(value)
    return type(value) == "string"
        and value ~= ""
        and not value:find("[/\\]")
        and not value:find('[%c"<>|&^%%]')
end

local function loadMetadata(metadataPath)
    local content = love.filesystem.read(metadataPath)
    if not content then
        return nil, "failed to read metadata file"
    end

    local chunk
    local err
    if _VERSION == "Lua 5.1" then
        chunk, err = loadstring(content, "@" .. metadataPath)
        if chunk then
            setfenv(chunk, {})
        end
    else
        chunk, err = load(content, "@" .. metadataPath, "t", {})
    end

    if not chunk then
        return nil, err or "failed to load metadata file"
    end

    local success, result = pcall(chunk)
    if not success then
        return nil, result
    end
    if type(result) ~= "table" then
        return nil, "metadata did not return a table"
    end

    return result, nil
end

local function normalizeMetadata(metadata, folder)
    local year = optionalString(metadata.year)
    if year and not year:match("^%d%d%d%d$") then
        year = nil
    end

    local exe = optionalString(metadata.exe) or (folder .. ".exe")
    if not isSafeExecutableName(exe) then
        return nil, "unsafe executable name: " .. tostring(exe)
    end

    return {
        title = optionalString(metadata.title) or folder,
        exe = exe,
        author = optionalString(metadata.author) or "Unknown",
        version = optionalString(metadata.version),
        url = optionalString(metadata.url) or "",
        source = optionalString(metadata.source),
        year = year,
        description = optionalString(metadata.description)
    }, nil
end

local function findGamesPath(gamesPath)
    if love.filesystem.getInfo(gamesPath, "directory") then
        return gamesPath
    end

    local isFused = love.filesystem.isFused and love.filesystem.isFused()
    local sourceDir = love.filesystem.getSourceBaseDirectory()
    if not isFused or not sourceDir or sourceDir == "" then
        return gamesPath
    end

    local mounted = love.filesystem.mount(sourceDir, "external")
    local externalGamesPath = "external/games"
    if mounted and love.filesystem.getInfo(externalGamesPath, "directory") then
        return externalGamesPath
    end

    return gamesPath
end

local function loadOptionalImage(imagePath)
    if not love.filesystem.getInfo(imagePath, "file") then
        return nil
    end

    local success, image = pcall(love.graphics.newImage, imagePath)
    if success then
        return image
    end

    print("Failed to load image: " .. imagePath)
    return nil
end

local function createLauncherCreditsTile()
    local launcherUrl = "https://github.com/yatima1460/GMILauncher"

    return {
        title = "GMILauncher Credits",
        path = "",
        exe = "",
        exeVirtualPath = "",
        author = "yatima1460",
        version = optionalString(buildInfo.version),
        url = launcherUrl,
        source = launcherUrl,
        year = nil,
        description = "GameMaker Italia Launcher\n\nCreated by yatima1460.\n\nGitHub: yatima1460/GMILauncher",
        icon = loadOptionalImage("assets/gmi_logo.png")
    }
end

function gameLoader.loadGames(gamesPath)
    local games = {}

    gamesPath = findGamesPath(gamesPath)
    print("Loading games from: " .. gamesPath)

    if not love.filesystem.getInfo(gamesPath, "directory") then
        print("Games directory not found: " .. gamesPath)
        gamesPath = nil
    end

    local gamesFolders = gamesPath and love.filesystem.getDirectoryItems(gamesPath) or {}
    for _, folder in ipairs(gamesFolders) do
        local folderPath = gamesPath .. "/" .. folder

        print("Checking folder: " .. folderPath)

        -- Check if it's actually a directory
        if love.filesystem.getInfo(folderPath, "directory") then
            local metadataPath = folderPath .. "/metadata.lua"
            local coverPath = folderPath .. "/cover.png"

            local metadata
            if love.filesystem.getInfo(metadataPath) then
                local err
                metadata, err = loadMetadata(metadataPath)
                if err then
                    print("Failed to load metadata file: " .. metadataPath .. " (" .. err .. ")")
                end
            else
                print("No metadata found for game directory, skipping: " .. folderPath)
            end

            if metadata then
                local gameInfo
                local err
                gameInfo, err = normalizeMetadata(metadata, folder)
                if err then
                    print("Invalid metadata for game directory, skipping: " .. folderPath .. " (" .. err .. ")")
                else
                    local exeVirtualPath = folderPath .. "/" .. gameInfo.exe
                    if not love.filesystem.getInfo(exeVirtualPath, "file") then
                        print("Executable not found for game, skipping: " .. exeVirtualPath)
                    else

                        local coverImage = nil
                        if love.filesystem.getInfo(coverPath, "file") then
                            coverImage = loadOptionalImage(coverPath)
                        else
                            print("No cover image found for game: " .. gameInfo.title)
                        end

                        gameInfo.path = folderPath
                        gameInfo.exeVirtualPath = exeVirtualPath
                        gameInfo.icon = coverImage

                        table.insert(games, gameInfo)
                        print("Loaded game: " .. gameInfo.title)
                    end
                end
            end
        end
    end

    -- Sort games by year (newer first, games without year go last)
    table.sort(games, function(a, b)
        local yearA = tonumber(a.year)
        local yearB = tonumber(b.year)

        -- If neither has a year, maintain original order
        if not yearA and not yearB then
            return false
        end
        -- If only a has no year, b comes first
        if not yearA then
            return false
        end
        -- If only b has no year, a comes first
        if not yearB then
            return true
        end
        -- Both have years, sort by year descending (newer first)
        return yearA > yearB
    end)

    -- Fallback if no games found
    if #games == 0 then
        games = {
            {
                title = "No Games Found",
                path = "",
                exe = "",
                exeVirtualPath = "",
                author = "Add games to /games folder",
                version = "",
                icon = nil
            }
        }
    end

    table.insert(games, createLauncherCreditsTile())

    return games
end

return gameLoader
