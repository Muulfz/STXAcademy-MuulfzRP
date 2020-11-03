local htmlEntities = module("lib/htmlEntities")
local Tools = module("lib/Tools")
-- this module define some admin menu functions
function vRP.adminCoordinates(user_id)
    if user_id and vRP.hasPermission(parseInt(user_id), permissions.player.coords) then
        local x, y, z = vRPclient.getPosition(user_id)
        local lang = vRP.lang.commands.admin.coords.description
        vRP.prompt(source,tostring(lang),x..","..y..","..z)
    end
end

function vRP.adminKick(user_id, target_id, reason)
    if user_id and vRP.hasPermission(parseInt(user_id), permissions.player.kick) then
        local source_id = vRP.getUserSource(parseInt(target_id))
        if source_id then
            vRP.kick(source_id, reason)
            return true
        end
    end
    return false
end

function vRP.adminRevive(user_id, target_id)
    if user_id and vRP.hasPermission(parseInt(user_id), permissions.player.revive) then
        local playersToRevive = {}
        local allPlayerTag = "-1"

        if target_id then
            if target_id ~= allPlayerTag then
                table.insert(playersToRevive, target_id)
            else
                playersToRevive = vRP.getUsers()
            end
        else
            table.insert(playersToRevive, user_id)
        end

        vRP.reviveBulk(playersToRevive)
    end
end

function vRP.reviveBulk(listOfUsers)
    local life = 400
    for k, v in pairs(listOfUsers) do
        local ids = vRP.getUserSource(k)
        if ids then
            vRPclient.setHealth(ids, life)
        end
    end
end

function vRP.adminNoclip(user_id, target_id)
    if user_id and vRP.hasPermission(parseInt(user_id), permissions.player.noclip) then
        local noClipUser = user_id
        if target_id then
            noClipUser = target_id
        end

        vRPclient._toggleNoclip(vRP.getUserSource(target_id))
    end
end

function vRP.adminCreateDrop(user_id, x, y, z, item_id, item_amount)
    local source = vRP.getUserSource(user_id)
    if source and vRP.hasPermission(user_id, permissions.player.create_drop) then
        local drop_id = HudRP.createDrop(source, vRP.getItemModel(item_id), x, y, z, item_id, item_amount)
        vRP.sendChatMessage(source, "Drop Id", {255, 255, 255}, drop_id)
    end
end

function vRP.adminDeleteDrop(user_id, drop_id)
    if vRP.hasPermission(user_id, permissions.player.delete_drop) then
        HudRP.deleteDrop(drop_id)
    end
end
-- admin god mode
function task_god()
    SetTimeout(10000, task_god)

    for k, v in pairs(vRP.getUsersByPermission("admin.god")) do
        vRP.setHunger(v, 0)
        vRP.setThirst(v, 0)

        local player = vRP.getUserSource(v)
        if player ~= nil then
            vRPclient._setHealth(player, 200)
        end
    end
end

task_god()

