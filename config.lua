Config = {
    txAdminWebhook = 'https://discord.com/api/webhooks/1351147190785150996/yixNYz7YBpiYlaxtqa9z9okc2zgEmDhD59N0db5Pp_mbafuC8Fzblk3f1v3yc0NdzDwX',
    Username = 'txAdmin Logs',
    Avatar = 'https://cdn.discordapp.com/attachments/1023716639289647104/1340433867789697104/image.png?ex=67d2a492&is=67d15312&hm=28f471252a93db338f68ed3ac4b7e522a9a7e3d81f552bbd21356a5e0206444b&',
    FilterAnnouncements = true,
    Timezone = 'Europe/Copenhagen',  
    DateFormat = '%d/%m/%Y %H:%M',

    -- Liste over handlinger
    ActionMessages = {
        teleportWaypoint = "Teleporterede til waypoint",
        spawnVehicle = "Spawnede køretøj: %s",
        deleteVehicle = "Slettede køretøj",
        vehicleRepair = "Reparerer køretøj",
        vehicleBoost = "Boostede køretøj",
        healSelf = "Helbredte sig selv",
        healAll = "Helbredte alle spillere",
        announcement = "Lavede en server-wide fjernelse: %s",
        clearArea = "Rensede et område med %dm radius",
        spectatePlayer = "Spectater nu %s",
        freezePlayer = "Fryser spiller %s",
        healPlayer = "Helbredte spiller %s",
        summonPlayer = "Kaldte spiller %s",
        drunkEffect = "Aktiverede fuldskabseffekt på %s",
        setOnFire = "Satte %s i brand",
        wildAttack = "Udløste vild angreb på %s",
        showPlayerIDs = "Slåede visning af spiller ID'er til/fra"
    }
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
