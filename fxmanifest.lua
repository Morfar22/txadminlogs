fx_version 'cerulean'
game 'gta5'

author 'Mmorfar'
description 'txAdmin Logs'
version '1.0.0'

lua54 'yes'

server_only 'yes'

server_scripts {
    'config.lua',
    'server/*.lua',   -- Includes all Lua files in the "server" folder
}
