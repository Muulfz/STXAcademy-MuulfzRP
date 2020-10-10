local drops = {}

function tItemDrop.setDrop(drop)
    drop.prop.id = tItemDrop.findPropEntityByNetworkId(drop.prop.network_id)
    drops[drop.id] = drop
end

function tItemDrop.removeDrop(id)
    drops[id] = nil
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
        for id, drop in pairs(drops) do
            local x, y, z = table.unpack(GetEntityCoords(drop.prop.id))
            local distance = GetDistanceBetweenCoords(x, y, z, px, py, pz, true)
            if distance < 150 then
                DrawMarker(22, x, y, z + .3, 0, 0, 0, 0, 180.0, 0, .25, .25, .25, 255, 255, 255, 125, true, false, true)

                if IsControlJustPressed(1, 51) and distance < 3 then
                    ItemDropServer._takeDrop(id)
                    break
                end
            end
        end
    end
end)