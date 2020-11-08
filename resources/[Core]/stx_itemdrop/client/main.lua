local Tunnel = module("lib/Tunnel")

tItemDrop = {}
Tunnel.bindInterface("stx_itemdrop", tItemDrop)

ItemDropServer = Tunnel.getInterface("stx_itemdrop")