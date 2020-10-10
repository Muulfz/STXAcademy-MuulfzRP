local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
local cam = nil
local freezedOnTop = true
local doStatus = -1
local continuousFadeOutNetwork = false
local disablefiring = false

function f(n)
	n = n + 0.00000
	return n
end

function setCamHeight(height)
	local pos = GetEntityCoords(PlayerPedId())
	SetCamCoord(cam,vector3(pos.x,pos.y,f(height)))
end

local function StartFade()
	DoScreenFadeOut(500)
	while IsScreenFadingOut() do
		Citizen.Wait(1)
	end
end

local function EndFade()
	ShutdownLoadingScreen()
	DoScreenFadeIn(500)
	while IsScreenFadingIn() do
		Citizen.Wait(1)
	end
end

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(1)
		if disablefiring then 
			DisableControlAction(0,24) -- INPUT_ATTACK
			DisableControlAction(0,69) -- INPUT_VEH_ATTACK
			DisableControlAction(0,70) -- INPUT_VEH_ATTACK2
			DisableControlAction(0,92) -- INPUT_VEH_PASSENGER_ATTACK
			DisableControlAction(0,114) -- INPUT_VEH_FLY_ATTACK
			DisableControlAction(0,257) -- INPUT_ATTACK2
			DisableControlAction(0,331) -- INPUT_VEH_FLY_ATTACK2
		end
	end
end)

Citizen.CreateThread(function()
	SetNuiFocus(false,false)
	SetEntityInvincible(PlayerPedId(),true)
	SetEntityVisible(PlayerPedId(),false)
	FreezeEntityPosition(PlayerPedId(),true)
	SetPedDiesInWater(PlayerPedId(),false)
	while freezedOnTop do
		if doStatus == 1 then
			SetEntityInvincible(PlayerPedId(),true)
			SetEntityVisible(PlayerPedId(),true)
			FreezeEntityPosition(PlayerPedId(),true)
			SetPedDiesInWater(PlayerPedId(),false)

		elseif doStatus == 2 then
			TriggerCamController(doStatus)
			SetEntityInvincible(PlayerPedId(),false)
			SetEntityVisible(PlayerPedId(),true)
			FreezeEntityPosition(PlayerPedId(),false)
			SetPedDiesInWater(PlayerPedId(),true)
			TriggerCamController(-2)
			freezedOnTop = false
		else
			SetEntityInvincible(PlayerPedId(),true)
			SetEntityVisible(PlayerPedId(),false)
			FreezeEntityPosition(PlayerPedId(),true)
		end
		Citizen.Wait(1)
	end
end)

function TriggerCamController(statusSent)
	ShutdownLoadingScreenNui()
	
	if not DoesCamExist(cam) then
		cam = CreateCam("DEFAULT_SCRIPTED_CAMERA",false)
	end

	if statusSent == -1 then
		local pos = GetEntityCoords(PlayerPedId())
		SetCamCoord(cam,vector3(pos.x,pos.y,f(1500)))
		SetCamRot(cam,-f(90),f(0),f(0),2)
		SetCamActive(cam, true)
		StopCamPointing(cam)
		RenderScriptCams(true,true,0,0,0,0)
		PlaySound(-1, "Frontend_Beast_Fade_Screen", "FM_Events_Sasquatch_Sounds", 0, 0, 1)
	elseif statusSent == 2 then
		Citizen.Wait(1000)
		setCamHeight(1000)
		PlaySound(-1, "Hit", "RESPAWN_ONLINE_SOUNDSET", 0, 0, 1)
		Citizen.Wait(1000)
		setCamHeight(750)
		PlaySound(-1, "Hit", "RESPAWN_ONLINE_SOUNDSET", 0, 0, 1)
		Citizen.Wait(1000)
		setCamHeight(400)
		PlaySound(-1, "Hit", "RESPAWN_ONLINE_SOUNDSET", 0, 0, 1)
		Citizen.Wait(1000)
		setCamHeight(100)
		PlaySound(-1, "Hit", "RESPAWN_ONLINE_SOUNDSET", 0, 0, 1)
		Citizen.Wait(2000)
	elseif statusSent == -2 then
		SetCamActive(cam,false)
		StopCamPointing(cam)
		RenderScriptCams(0,0,0,0,0,0)
		SetFocusEntity(PlayerPedId())
		PlaySound(-1, "Frontend_Beast_Fade_Screen", "FM_Events_Sasquatch_Sounds", 0, 0, 1)
	elseif statusSent == 1 then
		SetCamCoord(cam,vector3(-126.53629302979,-633.5449267578,170.25035827637))
		SetCamRot(cam,--[[vertical]]f(-15),--[[rotação]]f(0),--[[horizontal]]f(276),0)
		SetCamActive(cam,true)
		RenderScriptCams(true,true,20000000000000000000000000,0,0,0)
	end
end

RegisterNetEvent('ToogleBackCharacter')
AddEventHandler('ToogleBackCharacter',function()
	doStatus = 2
end)

RegisterNetEvent("ven_character:characterCreate")
AddEventHandler("ven_character:characterCreate",function()
	doStatus = 1
	SetTimeout(3000,function()
		TriggerCreateCharacter()
	end)
end)

RegisterNetEvent("ven_character:normalSpawn")
AddEventHandler("ven_character:normalSpawn",function(firstspawn)
	if firstspawn then
		TriggerCamController(-1)
		TriggerEvent('ven_intro:showicon', source)
		SetTimeout(15000, function()
		doStatus = 2
		TriggerEvent("on_hud")
		TriggerCamController(doStatus)
		end)
	else
		TriggerCamController(-1)
		TriggerEvent('ven_intro:showicon', source)
		SetTimeout(15000, function()
		TriggerEvent("vrp:ToogleLoginMenu")
		TriggerEvent("on_hud")
		end)
	end
end)

local isInCharacterMode = false

local currentCharacterMode = { fathersID = 0, mothersID = 0, skinColor = 0, shapeMix = 0.0,
								eyesColor = 0, eyebrowsHeight = 0, eyebrowsWidth = 0, noseWidth = 0,
								noseHeight = 0, noseLength = 0, noseBridge = 0, noseTip = 0, noseShift = 0,
								cheekboneHeight = 0, cheekboneWidth = 0, cheeksWidth = 0, lips = 0, jawWidth = 0,
								jawHeight = 0, chinLength = 0, chinPosition = 0,
								chinWidth = 0, chinShape = 0, neckWidth = 0,
								hairModel = 4, firstHairColor = 0, secondHairColor = 0, eyebrowsModel = 0, eyebrowsColor = 0,
								beardModel = -1, beardColor = 0, chestModel = -1, chestColor = 0, blushModel = -1, blushColor = 0, lipstickModel = -1, lipstickColor = 0,
								blemishesModel = -1, ageingModel = -1, complexionModel = -1, sundamageModel = -1, frecklesModel = -1, makeupModel = -1 }
local characterNome = ""
local characterSobrenome = ""
local characterAge = 0

function TriggerCreateCharacter()
	TriggerCamController(-1)
	TriggerEvent('ven_intro:showicon', source)
	TriggerEvent('InteractSound_CL:PlayOnOne', 'Parte1', 0.8)
	disablefiring = true
	SetTimeout(15000, function()
		isInCharacterMode = true
		StartFade()
		continuousFadeOutNetwork = true
		TriggerCamController(-2)
		changeGender("mp_m_freemode_01")
		refreshDefaultCharacter()
		TaskUpdateSkinOptions()
		TaskUpdateFaceOptions()
		TaskUpdateHeadOptions()
		SetEntityCoordsNoOffset(PlayerPedId(), -125.85735198975,-633.30960449219,169.5152130127, true, true, true) 
		SetEntityHeading(PlayerPedId(), f(103.166687011719))
		TriggerCamController(doStatus)
		Citizen.Wait(5000)
		EndFade()
		SetNuiFocus(isInCharacterMode, isInCharacterMode)
		SendNUIMessage({CharacterMode = isInCharacterMode, CharacterMode2 = not isInCharacterMode, CharacterMode3 = not isInCharacterMode})
		print("isInCharacterMode " .. tostring(isInCharacterMode))
	end)
end

function refreshDefaultCharacter()
	SetPedDefaultComponentVariation(PlayerPedId())
	ClearAllPedProps(PlayerPedId())
	if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
		SetPedComponentVariation(PlayerPedId(), 3, 8, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 4, 4, 4, 2)
		SetPedComponentVariation(PlayerPedId(), 6, 1, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 11, 225, 0, 2)
	else
		SetPedComponentVariation(PlayerPedId(), 3, 1, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 4, 0, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 6, 1, 1, 2)
		SetPedComponentVariation(PlayerPedId(), 8, 2, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 11, 235, 0, 2)
	end
end

function changeGender(model)
	local mhash = GetHashKey(model)
	while not HasModelLoaded(mhash) do
		RequestModel(mhash)
		Citizen.Wait(10)
	end

	if HasModelLoaded(mhash) then
		SetPlayerModel(PlayerId(), mhash)
		SetPedMaxHealth(PlayerPedId(), 400)
		SetEntityHealth(PlayerPedId(), 400)
		SetModelAsNoLongerNeeded(mhash)
	end
end

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(1)
		if continuousFadeOutNetwork then 
	        for _, player in ipairs(GetActivePlayers()) do
				if player ~= PlayerId() and NetworkIsPlayerActive(player) then
					NetworkFadeOutEntity(GetPlayerPed(player), false)
				end
			end
		else
			Citizen.Wait(1000)
		end
	end
end)

RegisterNUICallback('cDone', function(data, cb)
	SetNuiFocus(isInCharacterMode, isInCharacterMode)
	SendNUIMessage({CharacterMode = not isInCharacterMode, CharacterMode2 = isInCharacterMode, CharacterMode3 = not isInCharacterMode})
end)

RegisterNUICallback('BackPart1', function(data, cb)
	SetNuiFocus(isInCharacterMode, isInCharacterMode)
	SendNUIMessage({CharacterMode = isInCharacterMode, CharacterMode2 = not isInCharacterMode, CharacterMode3 = not isInCharacterMode})
end)

RegisterNUICallback('cDonePart2', function(data, cb)
	SetNuiFocus(isInCharacterMode, isInCharacterMode)
	SendNUIMessage({CharacterMode = not isInCharacterMode, CharacterMode2 = not isInCharacterMode, CharacterMode3 = isInCharacterMode})
end)

RegisterNUICallback('BackPart2', function(data, cb)
	SetNuiFocus(isInCharacterMode, isInCharacterMode)
	SendNUIMessage({CharacterMode = not isInCharacterMode, CharacterMode2 = isInCharacterMode, CharacterMode3 = not isInCharacterMode})
end)

RegisterNUICallback('cDoneSave', function(data, cb)
	StartFade()

	isInCharacterMode = false
	SetNuiFocus(isInCharacterMode, isInCharacterMode)
	SendNUIMessage({CharacterMode = isInCharacterMode, CharacterMode2 = isInCharacterMode, CharacterMode3 = isInCharacterMode})
	SetPedComponentVariation(PlayerPedId(), 3, 0, 0, 2)

	if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
		SetPedComponentVariation(PlayerPedId(), 3, 8, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 4, 4, 4, 2)
		SetPedComponentVariation(PlayerPedId(), 6, 1, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 11, 225, 0, 2)
	else
		SetPedComponentVariation(PlayerPedId(), 3, 1, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 4, 0, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 6, 1, 1, 2)
		SetPedComponentVariation(PlayerPedId(), 8, 2, 0, 2)
		SetPedComponentVariation(PlayerPedId(), 11, 235, 0, 2)
	end
	SetEntityCoordsNoOffset(PlayerPedId(),-3157.5241699219,1095.1154785156,20.852516174316,true,true,true)
	SetEntityHeading(PlayerPedId(),f(299.00))
	continuousFadeOutNetwork = false

	for _, player in ipairs(GetActivePlayers()) do
		if player ~= PlayerId() and NetworkIsPlayerActive(player) then
			NetworkFadeInEntity(GetPlayerPed(player), true)
		end
	end

	TriggerServerEvent("ven_character:finishedCharacter", characterNome, characterSobrenome, characterAge, currentCharacterMode)
	EndFade()
	SetTimeout(2000, function()
		TriggerEvent('InteractSound_CL:PlayOnOne', 'Parte2', 0.8)
		disablefiring = false
	end)
end)

RegisterNUICallback('cChangeHeading', function(data, cb)
	SetEntityHeading(PlayerPedId(), f(data.camRotation))
    cb('ok')
end)
RegisterNUICallback('ChangeGender', function(data, cb)
    currentCharacterMode.gender = data.gender
    if data.gender == 1 then
    	changeGender("mp_f_freemode_01")
    else
    	changeGender("mp_m_freemode_01")
    end
	refreshDefaultCharacter()
	TaskUpdateSkinOptions()
	TaskUpdateFaceOptions()
	TaskUpdateHeadOptions()
    cb('ok')
end)

RegisterNUICallback('UpdateSkinOptions', function(data, cb)
	currentCharacterMode.fathersID = data.fathersID
	currentCharacterMode.mothersID = data.mothersID
	currentCharacterMode.skinColor = data.skinColor
	currentCharacterMode.shapeMix = data.shapeMix

	characterNome = data.characterNome
	characterSobrenome = data.characterSobrenome
	characterAge = data.characterAge

    TaskUpdateSkinOptions()
    cb('ok')
end)

function TaskUpdateSkinOptions()
	local data = currentCharacterMode
	SetPedHeadBlendData(PlayerPedId(), data.fathersID, data.mothersID, 0, data.skinColor, 0, 0, f(data.shapeMix), 0, 0, false)
end

RegisterNUICallback('UpdateFaceOptions', function(data, cb)
	currentCharacterMode.eyesColor = data.eyesColor
	currentCharacterMode.eyebrowsHeight = data.eyebrowsHeight
	currentCharacterMode.eyebrowsWidth = data.eyebrowsWidth
	currentCharacterMode.noseWidth = data.noseWidth
	currentCharacterMode.noseHeight = data.noseHeight
	currentCharacterMode.noseLength = data.noseLength
	currentCharacterMode.noseBridge = data.noseBridge
	currentCharacterMode.noseTip = data.noseTip
	currentCharacterMode.noseShift = data.noseShift
	currentCharacterMode.cheekboneHeight = data.cheekboneHeight
	currentCharacterMode.cheekboneWidth = data.cheekboneWidth
	currentCharacterMode.cheeksWidth = data.cheeksWidth
	currentCharacterMode.lips = data.lips
	currentCharacterMode.jawWidth = data.jawWidth
	currentCharacterMode.jawHeight = data.jawHeight
	currentCharacterMode.chinLength = data.chinLength
	currentCharacterMode.chinPosition = data.chinPosition
	currentCharacterMode.chinWidth = data.chinWidth
	currentCharacterMode.chinShape = data.chinShape
	currentCharacterMode.neckWidth = data.neckWidth
	TaskUpdateFaceOptions()
	cb('ok')
end)

function TaskUpdateFaceOptions()
	local ped = PlayerPedId()
	local data = currentCharacterMode
	SetPedEyeColor(ped, data.eyesColor)
	SetPedFaceFeature(ped, 6, data.eyebrowsHeight)
	SetPedFaceFeature(ped, 7, data.eyebrowsWidth)
	SetPedFaceFeature(ped, 0, data.noseWidth)
	SetPedFaceFeature(ped, 1, data.noseHeight)
	SetPedFaceFeature(ped, 2, data.noseLength)
	SetPedFaceFeature(ped, 3, data.noseBridge)
	SetPedFaceFeature(ped, 4, data.noseTip)
	SetPedFaceFeature(ped, 5, data.noseShift)
	SetPedFaceFeature(ped, 8, data.cheekboneHeight)
	SetPedFaceFeature(ped, 9, data.cheekboneWidth)
	SetPedFaceFeature(ped, 10, data.cheeksWidth)
	SetPedFaceFeature(ped, 12, data.lips)
	SetPedFaceFeature(ped, 13, data.jawWidth)
	SetPedFaceFeature(ped, 14, data.jawHeight)
	SetPedFaceFeature(ped, 15, data.chinLength)
	SetPedFaceFeature(ped, 16, data.chinPosition)
	SetPedFaceFeature(ped, 17, data.chinWidth)
	SetPedFaceFeature(ped, 18, data.chinShape)
	SetPedFaceFeature(ped, 19, data.neckWidth)
end

RegisterNUICallback('UpdateHeadOptions', function(data, cb)
	currentCharacterMode.hairModel = data.hairModel
	currentCharacterMode.firstHairColor = data.firstHairColor
	currentCharacterMode.secondHairColor = data.secondHairColor
	currentCharacterMode.eyebrowsModel = data.eyebrowsModel
	currentCharacterMode.eyebrowsColor = data.eyebrowsColor
	currentCharacterMode.beardModel = data.beardModel
	currentCharacterMode.beardColor = data.beardColor
    currentCharacterMode.chestModel = data.chestModel
    currentCharacterMode.chestColor = data.chestColor
    currentCharacterMode.blushModel = data.blushModel
    currentCharacterMode.blushColor = data.blushColor
    currentCharacterMode.lipstickModel = data.lipstickModel
    currentCharacterMode.lipstickColor = data.lipstickColor
	currentCharacterMode.blemishesModel = data.blemishesModel
	currentCharacterMode.ageingModel = data.ageingModel
	currentCharacterMode.complexionModel = data.complexionModel
	currentCharacterMode.sundamageModel = data.sundamageModel
	currentCharacterMode.frecklesModel = data.frecklesModel
	currentCharacterMode.makeupModel = data.makeupModel

	TaskUpdateHeadOptions()
	cb('ok')
end)

function TaskUpdateHeadOptions()
	local ped = PlayerPedId()
	local data = currentCharacterMode
	SetPedComponentVariation(ped, 2, data.hairModel, 0, 0)
	SetPedHairColor(ped, data.firstHairColor, data.secondHairColor)
	SetPedHeadOverlay(ped, 2, data.eyebrowsModel, 0.99)
	SetPedHeadOverlayColor(ped, 2, 1, data.eyebrowsColor, data.eyebrowsColor)
	SetPedHeadOverlay(ped, 1, data.beardModel, 0.99)
	SetPedHeadOverlayColor(ped, 1, 1, data.beardColor, data.beardColor)
    SetPedHeadOverlay(ped, 10, data.chestModel, 0.99)
    SetPedHeadOverlayColor(ped, 10, 1, data.chestColor, data.chestColor)
    SetPedHeadOverlay(ped, 5, data.blushModel, 0.99)
    SetPedHeadOverlayColor(ped, 5, 2, data.blushColor, data.blushColor)
    SetPedHeadOverlay(ped, 8, data.lipstickModel, 0.99)
    SetPedHeadOverlayColor(ped, 8, 2, data.lipstickColor, data.lipstickColor)
	SetPedHeadOverlay(ped, 0, data.blemishesModel, 0.99)
	SetPedHeadOverlayColor(ped, 0, 0, 0, 0)
	SetPedHeadOverlay(ped, 3, data.ageingModel, 0.99)
	SetPedHeadOverlayColor(ped, 3, 0, 0, 0)
	SetPedHeadOverlay(ped, 6, data.complexionModel, 0.99)
	SetPedHeadOverlayColor(ped, 6, 0, 0, 0)
	SetPedHeadOverlay(ped, 7, data.sundamageModel, 0.99)
	SetPedHeadOverlayColor(ped, 7, 0, 0, 0)
	SetPedHeadOverlay(ped, 9, data.frecklesModel, 0.99)
	SetPedHeadOverlayColor(ped, 9, 0, 0, 0)
	SetPedHeadOverlay(ped, 4, data.makeupModel, 0.99)
	SetPedHeadOverlayColor(ped, 4, 0, 0, 0)
end