local Config = lib.load('config')

-- =============================================
--  Logger Core
-- =============================================
local loggerBuffer = {}

-- Logger function
local function logger(source, type, data)
    loggerBuffer[#loggerBuffer + 1] = {
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
                -- Create Discord embed
                local embed = {
                    title = 'txAdmin Log',
                    description = log.data.message,
                    color = 3447003, -- Blue color
                    fields = {
                        { name = 'Action', value = log.data.action,           inline = true },
                        { name = 'Staff',    value = GetLogPlayerName(log.src), inline = true }
                    },
                    footer = { text = os.date('%d/%m/%Y %H:%M') }
                }

                -- Send til Discord via webhook
                PerformHttpRequest(Config.txAdminWebhook, function(err, text, headers) end, 'POST', json.encode({
                    username = locale('others.webhook_name'),
                    avatar_url = Config.Avatar,
                    embeds = { embed }
                }), { ['Content-Type'] = 'application/json' })
            end
            loggerBuffer = {}
        end
    end
end)

function GetLogPlayerName(src)
    if type(src) == 'number' then
        local name = string.sub(GetPlayerName(src) or locale('self_menu.unknown_player'), 1, 75)
        return ('[#%d] %s'):format(src, name)
    else
        return ('[??] %s'):format(locale('self_menu.unknown_player'))
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
            godmode = locale('self_menu.god_mode'),
            noclip = locale('self_menu.noclip'),
            superjump = locale('self_menu.super_jump'),
            none = locale('self_menu.standard_mode'),
            unknown = locale('self_menu.unknown_mode')
        }
        message = locale('self_menu.player_mode_changed', GetLogPlayerName(source), modeNameMap[data] or modeNameMap.unknown)
    elseif action == 'teleportWaypoint' then
        message = locale('self_menu.teleport_waypoint')
    elseif action == 'teleportCoords' then
        if type(data) ~= 'table' then return end
        message = locale('self_menu.teleport_coords', data.x or 0.0, data.y or 0.0, data.z or 0.0)
    elseif action == 'spawnVehicle' then
        if type(data) ~= 'string' then return end
        message = locale('self_menu.spawn_vehicle', data)
    elseif action == 'deleteVehicle' then
        message = locale('self_menu.delete_vehicle')
    elseif action == 'vehicleRepair' then
        message = locale('self_menu.vehicle_repair')
    elseif action == 'vehicleBoost' then
        message = locale('self_menu.vehicle_boost')
    elseif action == 'healSelf' then
        message = locale('self_menu.heal_self')
    elseif action == 'healAll' then
        message = locale('self_menu.heal_all')
    elseif action == 'announcement' then
        if type(data) ~= 'string' then return end
        message = locale('self_menu.announcement_made', data)
    elseif action == 'clearArea' then
        if type(data) ~= 'number' then return end
        message = locale('self_menu.clear_area', data)

        -- INTERACTION modal options
    elseif action == 'spectatePlayer' then
        message = locale('self_menu.spectate_player', GetLogPlayerName(data))
    elseif action == 'freezePlayer' then
        message = locale('self_menu.freeze_player', GetLogPlayerName(data))
    elseif action == 'teleportPlayer' then
        if type(data) ~= 'table' then return end
        local playerName = GetLogPlayerName(data.target)
        message = locale('self_menu.teleport_to_player', playerName, data.x or 0.0, data.y or 0.0, data.z or 0.0)
    elseif action == 'healPlayer' then
        message = locale('self_menu.heal_player', GetLogPlayerName(data))
    elseif action == 'summonPlayer' then
        message = locale('self_menu.summon_player', GetLogPlayerName(data))

        -- TROLL options
    elseif action == 'drunkEffect' then
        message = locale('self_menu.drunk_effect', GetLogPlayerName(data))
    elseif action == 'setOnFire' then
        message = locale('self_menu.set_on_fire', GetLogPlayerName(data))
    elseif action == 'wildAttack' then
        message = locale('self_menu.wild_attack', GetLogPlayerName(data))
    elseif action == 'showPlayerIDs' then
        if type(data) ~= 'boolean' then return end
        if data then
            message = locale('self_menu.show_player_id_on')
        else
            message = locale('self_menu.show_player_id_off')
        end

        -- Unknown event fallback logs a warning
    else
        lib.print.warn(locale('unkown_event', action))
        return -- Do not log unknown actions to Discord/log buffer.
    end

    -- Log the event using the logger function.
    logger(source, 'MenuEvent', {
        action = action,
        message = message,
    })
end)
