local Tools = module("lib/Tools")

local cfg = module(GetCurrentResourceName(), "config")

local drops = {}
local drops_ids = Tools.newIDGenerator()

function ItemDrop.createDrop(source, model_hash, x, y, z, item_id, item_amount)
    local spawner_id = vRP.getUserId(source)
    if spawner_id then
        local drop = {
            id = drops_ids:gen(),
            owner_id = vRP.getUserId(source),
            item = {
                id = item_id,
                amount = item_amount
            },
            prop = {
                network_id = ItemDropClient.spawnProp(source, model_hash, x, y, z)
            }
        }

        drops[drop.id] = drop

        ItemDropClient._setDrop(-1, drop)

        SetTimeout(cfg.despawn_time * 1000, function ()
            ItemDrop.deleteDrop(drop.id)
            drops_ids:free(drop.id)
        end)

        return drop.id
    end

    return nil
end

function ItemDrop.deleteDrop(id)
    local drop = drops[id]
    if drop then
        ItemDropClient._removeDrop(-1, id)
        ItemDropClient._deleteProp(-1, drop.prop.network_id)

        drops[id] = nil
    end
end

function ItemDrop.updateDropItemAmount(id, itemAmount)
    local drop = drops[id]
    if drop then
        drop.item.amount = itemAmount

        if itemAmount <= 0 then
            ItemDrop.deleteDrop(id)
        else
            ItemDropClient._setDrop(-1, drop)
        end
    end
end

function tItemDrop.takeDrop(id)
    local drop = drops[id]
    if drop then
        local user_id = vRP.getUserId(source)
        if user_id then
            local item = drop.item

            local item_weight = vRP.getItemWeight(item.id)
            local inventory_remaining_weight = vRP.getInventoryMaxWeight(user_id) - vRP.getInventoryWeight(user_id)

            local givable_item_amount = math.min(item.amount, math.floor(inventory_remaining_weight / item_weight))

            if givable_item_amount > 0 then
                vRPclient._playAnim(source, true, { { "pickup_object", "pickup_low", 1 } }, false)

                ItemDrop.updateDropItemAmount(id, item.amount - givable_item_amount)
                vRP.giveInventoryItem(user_id, item.id, givable_item_amount)
            else
                vRPclient._notify(source, "Inventory full") -- TODO use vRP.lang
            end
        end
    end
end

AddEventHandler("vRP:playerSpawn", function (user_id, source, first_spawn)
    if first_spawn then
        for id, drop in pairs(drops) do
            ItemDropClient._setDrop(source, drop)
        end
    end
end)