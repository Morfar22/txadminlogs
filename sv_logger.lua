-- Hjælpefunktioner (SKAL VÆRE ØVERST)
function GetPlayerNameFromIdentifiers(playerId)
    if not playerId or type(playerId) ~= "number" then return "Ukendt spiller" end
    
    local identifiers = GetPlayerIdentifiers(playerId)
    local nameParts = {}

    for _, identifier in ipairs(identifiers) do
        if identifier:find("steam:") then
            nameParts[#nameParts+1] = "Steam: "..identifier:sub(7)
        elseif identifier:find("license:") then
            nameParts[#nameParts+1] = "Rockstar: "..identifier:sub(9)
        elseif identifier:find("discord:") then
            nameParts[#nameParts+1] = "<@"..identifier:sub(9)..">"
        end
    end

    return #nameParts > 0 and table.concat(nameParts, " | ") or "Ukendt spiller"
end

function FormatPlayerName(src)
    if type(src) == 'number' then
        return ("[#%d] %s"):format(src, GetPlayerName(src) or "Ukendt")
    end
    return "Server handling"
end

-- Hoved event handler
AddEventHandler('txsv:logger:menuEvent', function(source, action, allowed, data)
    if not allowed then return end

    -- Spectate handling
    if action == "spectatePlayer" then
        local targetId = type(data) == "table" and data.target or data
        local targetName = GetPlayerNameFromIdentifiers(targetId)
        
        SendDiscordLog(
            ("Admin Handling: %s"):format(action),
            ("**Staff:** %s\n**Handling:** Spectater nu %s"):format(
                FormatPlayerName(source),
                targetName
            ),
            65280 -- Grøn farve
        )

    -- Drunk effect handling
    elseif action == "drunkEffect" then
        local targetId = type(data) == "table" and data.target or source
        local targetName = GetPlayerNameFromIdentifiers(targetId)
        
        SendDiscordLog(
            ("Admin Handling: %s"):format(action),
            ("**Staff:** %s\n**Handling:** Aktiverede fuldskabseffekt på %s"):format(
                FormatPlayerName(source),
                targetName
            ),
            16753920 -- Orange farve
        )

    -- Generel håndtering for andre actions fra Config.ActionMessages
    elseif Config.ActionMessages[action] then
        local targetId = type(data) == "table" and data.target or data
        local targetName = type(targetId) == "number" and GetPlayerNameFromIdentifiers(targetId) or targetId
        
        SendDiscordLog(
            ("Admin Handling: %s"):format(action),
            ("**Staff:** %s\n**Handling:** %s"):format(
                FormatPlayerName(source),
                Config.ActionMessages[action]:format(targetName)
            ),
            3447003 -- Blå farve
        )

    -- Teleport til koordinater (eksempel på specialhandling)
    elseif action == "teleportCoords" then
        SendDiscordLog(
            ("Admin Handling: %s"):format(action),
            ("**Staff:** %s\n**Koordinater:** (x=%.2f, y=%.2f, z=%.2f)"):format(
                FormatPlayerName(source),
                data.x or 0, data.y or 0, data.z or 0
            ),
            10181046 -- Lilla farve
        )
    end
end)

-- Discord log funktion (uændret)
function SendDiscordLog(title, description, color)
    local embed = {{
        title = title,
        description = description,
        color = color,
        footer = {text = os.date(Config.DateFormat)},
        author = {name = Config.Username}
    }}
    
    PerformHttpRequest(Config.txAdminWebhook, function() end, 'POST', 
        json.encode({embeds = embed}),
        {['Content-Type'] = 'application/json'}
    )
end
