local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")

ItemDrop = {}
Proxy.addInterface("stx_itemdrop", ItemDrop)

tItemDrop = {}
Tunnel.bindInterface("stx_itemdrop", tItemDrop)

vRP = Proxy.getInterface("vRP")

vRPclient = Tunnel.getInterface("vRP")
ItemDropClient = Tunnel.getInterface("stx_itemdrop")