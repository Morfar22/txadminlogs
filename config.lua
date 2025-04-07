Config = {
    txAdminWebhook = 'UR_WEBHOOK_HERE',
    Username = 'txAdmin Logs',
    Avatar = 'https://cdn.discordapp.com/attachments/1023716639289647104/1340433867789697104/image.png?ex=67d2a492&is=67d15312&hm=28f471252a93db338f68ed3ac4b7e522a9a7e3d81f552bbd21356a5e0206444b&',
    FilterAnnouncements = true,
    Timezone = 'Europe/Copenhagen',  
    DateFormat = '%d/%m/%Y %H:%M',
}

-- Fælles hjælpefunktioner
function FormatPlayerName(src)
    if type(src) == 'number' then
        local name = GetPlayerName(src) or "unknown"
        return ("[#%d] %s"):format(src, name:sub(1, 75))
    elseif src == -1 then
        return "Everyone"
    end
    return "[??] " .. (src or "unknown")
end

function FormatExpiration(exp)
    if not exp then return 'Permanent' end
    return os.date(Config.DateFormat, exp + 3600)  
end
