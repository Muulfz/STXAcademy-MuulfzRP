local suppressed_vehicles = {
    "pounder" -- Caminhão do diabo
}

local suppressed_pickups = {
    0x6C5B941A,
    0xF33C83B0,
    0xDF711959,
    0xB2B5325E,
    0x85CAA9B1,
    0xB2930A14,
    0xFE2A352C,
    0x693583AD,
    0x1D9588D3,
    0x3A4C2AD2,
    0x4D36C349,
    0x2F36B434,
    0xA9355DCD,
    0x96B412A3,
    0x9299C95B,
    0xF9AFB48F,
    0x8967B4F3,
    0x3B662889,
    0xFD16169E,
    0xCB13D282,
    0xC69DE3FF,
    0x278D8734,
    0x5EA16D74,
    0x295691A9,
    0x81EE601E,
    0x88EAACA7,
    0x872DC888,
    0xC5B72713,
    0x9CF13918,
    0x0968339D,
    0xBFEE6C3B,
    0xBED46EC5,
    0x079284A9,
    0x8ADDEC75
}

local cached_vehicles_hash_keys = {}

Citizen.CreateThread(
    function()
        while true do
            InvalidateIdleCam()
            DisablePlayerVehicleRewards(PlayerId())

            for i = 1, 15 do
                EnableDispatchService(i, false)
            end

            SetCreateRandomCops(false)
            SetGarbageTrucks(false)
            SetRandomBoats(false)
            SetPlayerWantedLevel(PlayerId(), 0, false)

            -- We will only suppress vehicles once we have its hashes
            if #cached_vehicles_hash_keys then
                for _, hash_key in ipairs(cached_vehicles_hash_keys) do
                    SetVehicleModelIsSuppressed(hash_key, true)
                end
            end

            for _, suppressed_pickup in ipairs(suppressed_pickups) do
                RemoveAllPickupsOfType(suppressed_pickup)
            end

            for i = 1, 22 do
                if i == 14 or i == 10 or i == 19 or i == 16 then
                    goto continue
                end

                HideHudComponentThisFrame(i)
                ::continue::
            end

            Citizen.Wait(1)
        end
    end
)

-- Populate cached_vehicles_hash_keys
Citizen.CreateThread(
    function()
        for _, suppressed_vehicle in ipairs(suppressed_vehicles) do
            table.insert(cached_vehicles_hash_keys, GetHashKey(suppressed_vehicle))
        end
    end
)
