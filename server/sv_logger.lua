-- =============================================
--  Logger Core
-- =============================================
local loggerBuffer = {}

-- Logger function
local function logger(source, type, data)
    loggerBuffer[#loggerBuffer+1] = {
        src = source,
        type = type,
        data = data or false
    }
end

-- Buffer processing thread
CreateThread(function()
    while true do
        Wait(1000)
        if #loggerBuffer > 0 then
            for _, log in ipairs(loggerBuffer) do
                -- Opret Discord-embed
                local embed = {
                    title = "txAdmin Log",
                    description = log.data.message,
                    color = 3447003, -- Blå farve
                    fields = {
                        { name = "Handling", value = log.data.action, inline = true },
                        { name = "Staff", value = getLogPlayerName(log.src), inline = true }
                    },
                    footer = { text = os.date('%d/%m/%Y %H:%M') }
                }

                -- Send til Discord via webhook
                PerformHttpRequest(Config.txAdminWebhook, function(err, text, headers) end, 'POST', json.encode({
                    username = "txAdmin Logs",
                    avatar_url = "https://cdn.discordapp.com/attachments/1023716639289647104/1340433867789697104/image.png",
                    embeds = { embed }
                }), { ['Content-Type'] = 'application/json' })
            end
            loggerBuffer = {}
        end
    end
end)


-- =============================================
--  Locale Configuration
-- =============================================
local CurrentLocale = 'en' -- Change to 'da' for Danish
local localesPath = ('locales/%s.lua'):format(CurrentLocale)
local localesFile = LoadResourceFile(GetCurrentResourceName(), localesPath)
assert(localesFile, ('Locale file "%s" not found!'):format(localesPath))

local Locales = assert(
    load(localesFile, ('@@%s'):format(localesPath)),
    ('Failed to parse locale file: %s'):format(localesPath)
)()

-- =============================================
--  Helper Functions
-- =============================================
function Translate(key, ...)
    return Locales[key] and string.format(Locales[key], ...) or key
end

function getLogPlayerName(src)
    if type(src) == 'number' then 
        local name = string.sub(GetPlayerName(src) or Translate('unknownPlayer'), 1, 75)
        return ('[#%d] %s'):format(src, name)
    else
        return ('[??] %s'):format(Translate('unknownPlayer'))
    end
end

-- =============================================
--  Event Handlers
-- =============================================

AddEventHandler('txsv:logger:menuEvent', function(source, action, allowed, data)
    if not allowed then return end

    local message

    -- SELF menu options
    if action == 'playerModeChanged' then
        local modeNameMap = {
            godmode = Translate('God Mode'),
            noclip = Translate('Noclip'),
            superjump = Translate('Super Jump'),
            none = Translate('Standard Mode'),
            unknown = Translate('Unknown Mode')
        }
        message = Translate('playerModeChanged', getLogPlayerName(source), modeNameMap[data] or modeNameMap.unknown)

    elseif action == 'teleportWaypoint' then
        message = Translate('teleportWaypoint')

    elseif action == 'teleportCoords' then
        if type(data) ~= 'table' then return end
        message = Translate('teleportCoords', data.x or 0.0, data.y or 0.0, data.z or 0.0)

    elseif action == 'spawnVehicle' then
        if type(data) ~= 'string' then return end
        message = Translate('spawnVehicle', data)

    elseif action == 'deleteVehicle' then
        message = Translate('deleteVehicle')

    elseif action == 'vehicleRepair' then
        message = Translate('vehicleRepair')

    elseif action == 'vehicleBoost' then
        message = Translate('vehicleBoost')

    elseif action == 'healSelf' then
        message = Translate('healSelf')

    elseif action == 'healAll' then
        message = Translate('healAll')

    elseif action == 'announcement' then
        if type(data) ~= 'string' then return end
        message = Translate('announcement', data)

    elseif action == 'clearArea' then
        if type(data) ~= 'number' then return end
        message = Translate('clearArea', data)

    -- INTERACTION modal options
    elseif action == 'spectatePlayer' then
        message = Translate('spectatePlayer', getLogPlayerName(data))

    elseif action == 'freezePlayer' then
        message = Translate('freezePlayer', getLogPlayerName(data))

    elseif action == 'teleportPlayer' then
        if type(data) ~= 'table' then return end
        local playerName = getLogPlayerName(data.target)
        message = Translate('teleportPlayer', playerName, data.x or 0.0, data.y or 0.0, data.z or 0.0)

    elseif action == 'healPlayer' then
        message = Translate('healPlayer', getLogPlayerName(data))

    elseif action == 'summonPlayer' then
        message = Translate('summonPlayer', getLogPlayerName(data))

    -- TROLL modal options
    elseif action == 'drunkEffect' then
        message = Translate('drunkEffect', getLogPlayerName(data))

    elseif action == 'setOnFire' then
        message = Translate('setOnFire', getLogPlayerName(data))

    elseif action == 'wildAttack' then
        message = Translate('wildAttack', getLogPlayerName(data))

    elseif action == 'showPlayerIDs' then
        if type(data) ~= 'boolean' then return end
        if data then
            message = Translate('showPlayerIDs_on')
        else
            message = Translate('showPlayerIDs_off')
        end

    -- Unknown event fallback (logs a warning)
    else
        print("^3[WARNING]^0 Unknown menu event: " .. tostring(action))
        return -- Do not log unknown actions to Discord/log buffer.
    end

    -- Log the event using the logger function.
    logger(source, 'MenuEvent', {
        action = action,
        message = message,
    })
end)

