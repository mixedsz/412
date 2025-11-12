fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Modern ESX Job Selector'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}