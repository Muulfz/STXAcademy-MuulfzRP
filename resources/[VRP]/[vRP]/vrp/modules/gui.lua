local Tools = module("lib/Tools")

local cfg = module("cfg/gui")

function vRP.openMenu(source, menudef)

end

function vRP.closeMenu(source)

end

function vRP.prompt(source, title, default_text)

end


function vRP.request(source, text, time)

end

function vRP.registerMenuBuilder(name, builder)

end

function vRP.buildMenu(name, data)

end

-- open the player main menu
function vRP.openMainMenu(source)

end

-- SERVER TUNNEL API

function tvRP.closeMenu(id)

end

function tvRP.validMenuChoice(id, choice, mod)

end

-- receive prompt result
function tvRP.promptResult(text)

end

-- receive request result
function tvRP.requestResult(id, ok)

end

-- open the general player menu
function tvRP.openMainMenu()

end
-- STATIC MENUS

local function build_client_static_menus(source)

end

-- events
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)

end)

AddEventHandler("vRP:playerLeave", function(user_id, source)

end)

