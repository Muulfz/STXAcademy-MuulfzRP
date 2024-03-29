---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 9/13/2020 4:00 AM
---

local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")

t_stx_character_inventory = Tunnel.getInterface("stx_character_inventory")
stx_character_inventory = {}

Proxy.addInterface("stx_character_inventory", stx_character_inventory)

vRP = Proxy.getInterface("vRP")
tvRP = Tunnel.getInterface("vRP")

RegisterCommand("Inventario", function(source)
    local user_id = vRP.getUserId(source)
    local inventory = vRP.getUserDataTable(user_id).inventory

    Inventory:AddItem(inventory, InventoryItem:new("Muulfz", 100, true, true, "https://pbs.twimg.com/profile_images/727953935395360768/R4uTDKd9_400x400.jpg", 10), 10)

    print(json.encode(inventory))
    TriggerClientEvent("t_stx_character_inventory.OpenInventory",source, inventory)
    --t_stx_character_inventory.OpenInventory(source, inventory)
end)

