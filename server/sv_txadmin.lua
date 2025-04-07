-- =============================================
--  Locale Configuration
-- =============================================
local CurrentLocale = 'en' -- Skift til 'da' for dansk
local localesPath = ('locales/%s.lua'):format(CurrentLocale)

--print('[txAdminLogs] Loading locale file:', localesPath)
local localesFile = LoadResourceFile(GetCurrentResourceName(), localesPath)
assert(localesFile, ('[txAdminLogs] ERROR: Locale file "%s" not found!'):format(localesPath))

--print('[txAdminLogs] Parsing locale file...')
local chunk, err = load(localesFile, '@'..localesPath)
if not chunk then
    error(('[txAdminLogs] ERROR: Failed to parse locale file: %s'):format(err))
end

local Locales = chunk() -- Korrekt indlæsning med return
--print('[txAdminLogs] Locale keys loaded:', json.encode(Locales))

-- =============================================
--  Helper Functions
-- =============================================
function Translate(key, ...)
    if not Locales[key] then
       -- print(('[txAdminLogs] WARNING: Missing translation for key "%s"'):format(key))
        return ("[MISSING: %s]"):format(key)
    end

    local status, result = pcall(string.format, Locales[key], ...)
    
    if not status then
        --print(('[txAdminLogs] ERROR: Failed to format key "%s" with arguments: %s'):format(key, json.encode({...})))
        return Locales[key] -- Returner den rå tekst hvis formatering fejler
    end

    return result
end


function FormatAdminName(src)
    if type(src) == 'number' then
        local name = GetPlayerName(src) or Translate('unknownPlayer')
        local identifiers = GetPlayerIdentifiers(src)
        local discord = "No Discord"

        for _, v in pairs(identifiers) do
            if v:match("discord:") then
                discord = "<@" .. v:gsub("discord:", "") .. ">"
                break
            end
        end

        return ("[#%d] %s | %s"):format(src, name, discord)
    end
    return Translate('Server Action')
end

function FormatExpiration(exp)
    if not exp then return Translate('Permanent') end
    return os.date(Config.DateFormat, exp + 3600)
end

-- =============================================
--  Discord Webhook Function
-- =============================================
function SendDiscordLog(title, description, color)
    if not title or not description then
        print("^1[ERROR]^0 Missing title or description for Discord log.")
        return
    end

    local embed = {{
        title = title,
        description = description,
        color = color or 16711680, -- Default to red if no color is provided
        footer = { text = os.date(Config.DateFormat) },
        author = {
            name = Config.Username or "txAdmin Logs",
            icon_url = Config.Avatar or ""
        }
    }}

    PerformHttpRequest(Config.txAdminWebhook, function(err, text, headers)
        if err ~= 200 and err ~= 204 then
            print(("^1[ERROR]^0 Failed to send log (HTTP %s): %s"):format(err, text))
        end
    end, 'POST', json.encode({ embeds = embed }), { ['Content-Type'] = 'application/json' })
end


-- =============================================
--  Event Handlers for txAdmin Events
-- =============================================

AddEventHandler('txAdmin:events:playerKicked', function(data)
    SendDiscordLog(
        Translate('playerKicked'),
        Translate("Navn: **%s**\nForfatter: **%s**\nÅrsag: **%s**", 
            FormatAdminName(data.target), 
            FormatAdminName(data.author), 
            data.reason or Translate('Ingen årsag angivet')
        ),
        16711680 -- Red color for kicks
    )
end)

AddEventHandler('txAdmin:events:playerWarned', function(data)
    SendDiscordLog(
        Translate('playerWarned'),
        Translate("Navn: **%s**\nForfatter: **%s**\nÅrsag: **%s**\nID: **%s**", 
            FormatAdminName(data.target), 
            FormatAdminName(data.author), 
            data.reason or Translate('Ingen årsag angivet'), 
            data.actionId or Translate('Ukendt ID')
        ),
        16776960 -- Yellow color for warnings
    )
end)

AddEventHandler('txAdmin:events:playerBanned', function(data)
    local playerName = type(data.target) == "table" and Translate("Offline Ban") or FormatAdminName(data.target)

    SendDiscordLog(
        Translate('playerBanned'),
        Translate("Navn: **%s**\nForfatter: **%s**\nÅrsag: **%s**\nID: **%s**\nUdløber: **%s**", 
            playerName, 
            FormatAdminName(data.author), 
            data.reason or Translate('Ingen årsag angivet'), 
            data.actionId or Translate('Ukendt ID'), 
            data.expiration and os.date(Config.DateFormat, data.expiration) or Translate('Permanent')
        ),
        16711680 -- Red color for bans
    )
end)

AddEventHandler('txAdmin:events:playerWhitelisted', function(data)
    SendDiscordLog(
        Translate('playerWhitelisted'),
        Translate("Identifier: **%s**\nForfatter: **%s**\nID: **%s**", 
            data.target or Translate('Ukendt spiller'), 
            FormatAdminName(data.author), 
            data.actionId or Translate('Ukendt ID')
        ),
        65280 -- Green color for whitelisting actions
    )
end)

AddEventHandler('txAdmin:events:announcement', function(data)
    if not Config.FilterAnnouncements or data.author ~= 'txAdmin' then
        local author = FormatAdminName(data.author or "Unknown")
        local message = data.message or Translate("No message provided")

        SendDiscordLog(
            Translate('announcementTitle'),  -- Static title
            Translate('announcementMade', author, message),  -- Formatted description
            3447003  -- Blue color
        )
    end
end)




AddEventHandler('txAdmin:events:configChanged', function()
    SendDiscordLog(
        Translate('configChanged'),
        Translate("Konfigurationen er blevet ændret. Hvis dette ikke var dig, så tjek det med det samme."),
        16711680 -- Red color for config changes warnings.
    )
end)

AddEventHandler('txAdmin:events:healedPlayer', function(data)
    local playerName = data.id == -1 and Translate("Everyone") or FormatAdminName(data.id)

    SendDiscordLog(
        Translate("Spiller Helbredt"),
        ("Navn: **%s**"):format(playerName),
        65280 -- Green color for healing actions.
    )
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function(data)
    SendDiscordLog(
        Translate("Server Lukker Ned"),
        ("Forfatter: **%s**\nBesked: **%s**\nForsinkelse: **%dms**"):format(
            FormatAdminName(data.author),
            data.message or Translate("Ingen besked angivet"),
            data.delay or 0
        ),
        16711680 -- Red color for server shutdown warnings.
    )
end)
