---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 9/8/2020 11:21 PM
---
-- Resource Metadata
fx_version 'bodacious'
games { 'gta5' }

author 'Muulfz and Stinx Academmy'
description 'Example resource'
version '1.0.0'

ui_page "html/index.html"

client_scripts {
    "@vrp/lib/utils.lua",
    'client.lua'
}
server_script {
    "@vrp/lib/utils.lua",
    "@vrp/modules/model/Inventory.lua",
    'server.lua'
}

files {
    'html/*',
    'html/img/*'
}