fx_version 'cerulean'
game 'gta5'

author 'Solos#7777'
description 'solos-rentals'
version '1.0.0'


shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua',
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

-- Include HTML UI files and images
files {
    'html/images/*',
}

escrow_ignore {
    'config.lua',
    'client.lua',
    'server.lua'
}

dependencies {
    'ox_inventory',
    'ox_lib',
}

lua54 'yes'
dependency '/assetpacks'