fx_version 'cerulean'
games { 'gta5' }
author 'Beere'
description 'A script where you can select your vehicle seat'
version '1.0.0'

shared_scripts{
    'config.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'

}

client_script 'client.lua'