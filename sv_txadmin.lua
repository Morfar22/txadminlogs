-- Funktion til Discord logging
function SendDiscordLog(title, description, color)
    local embed = {{
        title = title,
        description = description,
        color = color or 16711680,  
        footer = {text = os.date(Config.DateFormat)},
        author = {name = Config.Username}
    }}
    
    PerformHttpRequest(Config.txAdminWebhook, function() end, 'POST', 
        json.encode({embeds = embed}),
        {['Content-Type'] = 'application/json'}
    )
end

-- Håndtering af txAdmin events
AddEventHandler('txAdmin:events:playerKicked', function(data)
    SendDiscordLog('Spiller Udvist', 
        ("Navn: **%s**\nForfatter: **%s**\nÅrsag: **%s**"):format(
            FormatPlayerName(data.target), data.author, data.reason
        )
    )
end)

AddEventHandler('txAdmin:events:playerWarned', function(data)
    SendDiscordLog('Spiller Advarsel', 
        ("Navn: **%s**\nForfatter: **%s**\nÅrsag: **%s**\nID: **%s**"):format(
            FormatPlayerName(data.target), data.author, data.reason, data.actionId
        )
    )
end)

AddEventHandler('txAdmin:events:playerBanned', function(data)
    local playerName = type(data.target) == "table" and "Offline Ban" or FormatPlayerName(data.target)
    SendDiscordLog('Spiller Bannet', 
        ("Navn: **%s**\nForfatter: **%s**\nÅrsag: **%s**\nID: **%s**\nUdløber: **%s**"):format(
            playerName, data.author, data.reason, data.actionId, FormatExpiration(data.expiration)
        )
    )
end)

AddEventHandler('txAdmin:events:playerWhitelisted', function(data)
    SendDiscordLog('Spiller Whitelisted', 
        ("Identifier: **%s**\nForfatter: **%s**\nID: **%s**"):format(
            data.target, data.author, data.actionId
        )
    )
end)

AddEventHandler('txAdmin:events:announcement', function(data)
    if not Config.FilterAnnouncements or data.author ~= 'txAdmin' then
        SendDiscordLog('Kunngøring', 
            ("Forfatter: **%s**\nBesked: **%s**"):format(data.author, data.message)
        )
    end
end)

AddEventHandler('txAdmin:events:configChanged', function()
    SendDiscordLog('Konfiguration Ændret', 
        "Der er blevet lavet ændringer i txAdmin indstillingerne. Hvis dette ikke var dig, så tjek det med det samme."
    )
end)

AddEventHandler('txAdmin:events:healedPlayer', function(data)
    local playerName = data.id == -1 and 'Everyone' or FormatPlayerName(data.id)
    SendDiscordLog('Spiller Helbredt', 
        ("Navn: **%s**"):format(playerName)
    )
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function(data)
    SendDiscordLog('Server Lukker Ned', 
        ("Forfatter: **%s**\nBesked: **%s**\nForsinkelse: **%dms**"):format(
            data.author, data.message, data.delay
        )
    )
end)
