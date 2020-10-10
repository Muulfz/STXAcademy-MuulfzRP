local function load_model(model_hash)
    if IsModelValid(model_hash) then
        while not HasModelLoaded(model_hash) do
            RequestModel(model_hash)
            Citizen.Wait(50)
        end

        return true
    end

    return false
end

local function synchronize_entity_to_network(entity)
    while not NetworkGetEntityIsNetworked(entity) do
        NetworkRegisterEntityAsNetworked(entity)
        Citizen.Wait(10)
    end

    local networkId = NetworkGetNetworkIdFromEntity(entity)
    SetNetworkIdExistsOnAllMachines(networkId)
    SetNetworkIdCanMigrate(networkId, true)

    for i, player in ipairs(GetActivePlayers()) do
        SetNetworkIdSyncToPlayer(networkId, player, true)
    end

    return networkId
end

function tItemDrop.spawnProp(model_hash, x, y, z)
    if load_model(model_hash) then
        local entity = CreateObject(model_hash, x, y, z, true, true, true)
        SetModelAsNoLongerNeeded(model_hash)

        SetEntityAsMissionEntity(entity, true, true)
        ActivatePhysics(entity)

        return synchronize_entity_to_network(entity)
    end

    return nil
end

function tItemDrop.deleteProp(network_id)
    local entity = tItemDrop.findPropEntityByNetworkId(network_id)
    if entity ~= 0 then
        while DoesEntityExist(entity) do
            NetworkRequestControlOfEntity(entity)
            if NetworkHasControlOfEntity(entity) then
                DeleteObject(entity)
            end
            Citizen.Wait(50)
        end
    end
end

function tItemDrop.findPropEntityByNetworkId(network_id)
    local start_time = GetGameTimer()
    local entity = 0
    while entity == 0 and GetGameTimer() - start_time < 60000 do
        if NetworkDoesNetworkIdExist(network_id) then
            entity = NetworkGetEntityFromNetworkId(network_id)
        end
        Citizen.Wait(50)
    end

    return entity
end