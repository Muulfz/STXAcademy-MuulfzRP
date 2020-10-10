fx_version "bodacious"
game "gta5"

author "Marmota"
description "Make the dropped items lay on ground."

client_scripts {
    "@vrp/lib/utils.lua",
    "client/main.lua",
    "client/prop.lua",
    "client/drop.lua"
}

server_scripts {
    "@vrp/lib/utils.lua",
    "server/main.lua",
    "server/drop.lua"
}

