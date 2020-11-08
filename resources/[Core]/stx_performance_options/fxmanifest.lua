-- Resource metadata
fx_version 'bodacious'
game 'gta5'

author 'STX Academy'
description 'STX Performance and Graphic options'
version '1.0.0'

depedencies = {
    'vrp',
    'stx_warmenu'
}

-- What to run
client_script {
    '@vrp/lib/utils.lua',
    "@stx_warmenu/client/warmenu.lua",
    'client/*.lua',
    'tests/client/*.lua'
}