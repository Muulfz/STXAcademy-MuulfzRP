-- this module define the emotes menu

local cfg = module("cfg/emotes")
local lang = vRP.lang

local emotes = cfg.emotes

function vRP.UseEmotes(player, choice)
    local emote = emotes[choice]
    if emote then
        vRPclient._playAnim(player, emote[1], emote[2], emote[3])
    end
end
