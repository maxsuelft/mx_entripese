fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
author 'MX'
name 'mx_enterprise'
description 'Sistema de Empresas para RedM'
version '1.0.0'
lua54 'yes'

dependencies {
    'oxmysql',
    'vorp_inventory',
    'ox_lib',
    'jo_libs',
    'uiprompt'
}

shared_scripts {
    '@ox_lib/init.lua',
    "@uiprompt/uiprompt.lua",
    '@jo_libs/init.lua',
    'shared/config.lua',
    'shared/locales.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua',
    'client/ui_open.lua',
    'client/nui.lua',
    'client/notifications.lua',
    'client/zones.lua',
    'client/animations.lua',
    'client/blips.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/company.lua',
    'server/members.lua',
    'server/bank.lua',
    'server/storage.lua',
    'server/salary.lua',
    'server/craft.lua',
    'server/shop.lua'
}

files {
    'web/dist/**/*',
    'config.json'
}

ui_page 'web/dist/index.html'

jo_libs {
    'blip',
}
