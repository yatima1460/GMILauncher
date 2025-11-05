-- Lightweight JSON parser for simple JSON objects
local json = {}

function json.decode(jsonString)
    local result = {}
    jsonString = jsonString:gsub("%s+", "")

    for key, value in jsonString:gmatch('"([^"]+)"%s*:%s*"([^"]*)"') do
        result[key] = value
    end

    return result
end

return json
