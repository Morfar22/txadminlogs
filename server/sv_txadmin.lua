local Config = lib.load('config')

function FormatAdminName(src)
    if type(src) == 'number' then
        local name = GetPlayerName(src) or locale('others.unknown_player')
        local identifiers = GetPlayerIdentifiers(src)
        local discord = 'No Discord'

        for _, v in pairs(identifiers) do
            if v:match('discord:') then
                discord = '<@' .. v:gsub('discord:', '') .. '>'
                break
            end
        end

        return ('[#%d] %s | %s'):format(src, name, discord)
    end
    return locale('others.server_action')
end

-- =============================================
--  Discord Webhook Function
-- =============================================
function SendDiscordLog(title, description, color)
    if not title or not description then
        lib.print.error(locale('print.info_missing'))
        return
    end

    local embed = {{
        title = title,
        description = description,
        color = color or 16711680, -- Default to red if no color is provided
        footer = { text = os.date(Config.DateFormat) },
        author = {
            name = locale('webhook_name') or 'txAdmin Logs',
            icon_url = Config.Avatar or ''
        }
    }}

    PerformHttpRequest(Config.txAdminWebhook, function(err, text, headers)
        if err ~= 200 and err ~= 204 then
            lib.print.error(locale('print.fail_log', err, text))
        end
    end, 'POST', json.encode({ embeds = embed }), { ['Content-Type'] = 'application/json' })
end


-- =============================================
--  Event Handlers for txAdmin Events
-- =============================================

AddEventHandler('txAdmin:events:playerKicked', function(data)
    SendDiscordLog(
        locale('kick.title'),
        locale('kick.description', FormatAdminName(data.target), FormatAdminName(data.author), data.reason or locale('others.no_reason_given')),
        16711680 -- Red color for kicks
    )
end)

AddEventHandler('txAdmin:events:playerWarned', function(data)
    SendDiscordLog(
        locale('warn.title'),
        locale('warn.description',  FormatAdminName(data.target), FormatAdminName(data.author),  data.reason or locale('others.no_reason_given'), data.actionId or locale('others.unknown_id')),
        16776960 -- Yellow color for warnings
    )
end)

AddEventHandler('txAdmin:events:playerBanned', function(data)
    local playerName = type(data.target) == 'table' and locale('ban.offline_ban') or FormatAdminName(data.target)

    SendDiscordLog(
        locale('ban.title'),
        locale('ban.description', playerName, FormatAdminName(data.author), data.reason or locale('others.no_reason_given'), data.actionId or locale('others.unknown_id'), data.expiration and os.date(Config.DateFormat, data.expiration) or locale('others.permanent_ban')),
        16711680 -- Red color for bans
    )
end)

AddEventHandler('txAdmin:events:playerWhitelisted', function(data)
    SendDiscordLog(
        locale('whiteliste.title'),
        locale('whiteliste.description', data.target or locale('others.unknown_player'), FormatAdminName(data.author), data.actionId or locale('others.unknown_id')),
        65280 -- Green color for whitelisting actions
    )
end)

AddEventHandler('txAdmin:events:announcement', function(data)
    if not Config.FilterAnnouncements or data.author ~= 'txAdmin' then
        local author = FormatAdminName(data.author or 'Unknown')
        local message = data.message or locale('others.no_msg')

        SendDiscordLog(
            locale('announce.title'),
            locale('announce.message', author, message),
            3447003  -- Blue color
        )
    end
end)

AddEventHandler('txAdmin:events:configChanged', function()
    SendDiscordLog(
        locale('config.title'),
        locale('config.description'),
        16711680 -- Red color for config changes warnings.
    )
end)

AddEventHandler('txAdmin:events:healedPlayer', function(data)
    local playerName = data.id == -1 and locale('self_menu.heal_all') or FormatAdminName(data.id)

    SendDiscordLog(
        locale('heal.title'),
        locale('heal.player_name', playerName),
        65280 -- Green color for healing actions.
    )
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function(data)
    SendDiscordLog(
        locale('shutdown.title'),
        locale('shutdown.description', FormatAdminName(data.author), data.message or locale('others.no_msg'), data.delay or 0),
        16711680 -- Red color for server shutdown warnings.
    )
end)