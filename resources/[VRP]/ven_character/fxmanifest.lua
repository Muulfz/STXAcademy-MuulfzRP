fx_version 'bodacious'
game 'gta5'

ui_page "character-nui/index.html"

files {
	"character-nui/*",
}

client_scripts {
	"@vrp/lib/utils.lua",
	"client-side/*"
}

server_scripts {
	"@vrp/lib/utils.lua",
	"server.lua"
}