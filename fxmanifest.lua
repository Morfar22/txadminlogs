fx_version 'cerulean'
game 'gta5'

author 'Mmorfar'
description 'txAdmin Logs'
version '1.0.0'
lua54 'yes'

ox_lib 'locale'

shared_script '@ox_lib/init.lua'

server_scripts {
    'server/*.lua',
}

files {
    'config.lua',
    'locales/*.json',
}
