
CooldownTime = 0

ClientData = {hasBoughtPigeon = false, pigeonHunger = 0, pigeonIsDead = 0, job = nil}

local isNPCReviving   = false

EntityHandler = { Pigeon = nil, Doctor = nil }
-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end

	SetNuiFocus(false, false)

	if EntityHandler.Pigeon then
		DeleteEntity(EntityHandler.Pigeon)
		SetEntityAsNoLongerNeeded(EntityHandler.Pigeon)
		EntityHandler.Pigeon = nil
	end

	if EntityHandler.Doctor then
		DeleteEntity(EntityHandler.Doctor)
		SetEntityAsNoLongerNeeded(EntityHandler.Doctor)
		EntityHandler.Doctor = nil
		isNPCReviving = false
	end

end)

-- Requesting client data (pigeon data).
RegisterNetEvent("tpz_core:isPlayerReady")
AddEventHandler("tpz_core:isPlayerReady", function()
	if Config.DevMode then
		return
	end

	PigeonPromptsSetUp()
	TriggerServerEvent("tpz_pigeon_alerts:requestClientData")

end)

-- Requesting client data (pigeon data).
Citizen.CreateThread(function ()
	if not Config.DevMode then
		return
	end

	PigeonPromptsSetUp()
	TriggerServerEvent("tpz_pigeon_alerts:requestClientData")

end)


-- @param job
-- @param jobGrade
RegisterNetEvent("tpz_core:getPlayerJob")
AddEventHandler("tpz_core:getPlayerJob", function(data)
	ClientData.job = data.job
end)

-- Update client data (pigeon data).
RegisterNetEvent("tpz_pigeon_alerts:updateClientData")
AddEventHandler("tpz_pigeon_alerts:updateClientData", function(data)
	ClientData = data
end)

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

-- The following event is triggered only when sending an alert.
RegisterNetEvent("tpz_pigeon_alerts:sendJobAlert")
AddEventHandler("tpz_pigeon_alerts:sendJobAlert", function(msg, time, job, bliphash, x, y, z, shape, radius, bliptime)
	TriggerEvent('tpz_core:sendLeftNotification', job, msg, 'generic_textures', shape, time)
	-- blip in future updates (to-do)
end)

-- The following system is triggered when alerting medics and there is only 1 medic available
-- we are checking if the medic is also dead so we have to call the doctor npc.
RegisterNetEvent("tpz_pigeon_alerts:checkOnOnlyMedicStatus")
AddEventHandler("tpz_pigeon_alerts:checkOnOnlyMedicStatus", function(calledSourceTarget)
	local playerPed    = PlayerPedId()
	local isPlayerDead = IsEntityDead(playerPed)

	if isPlayerDead then
		TriggerServerEvent("tpz_pigeon_alerts:startDoctorNPCAssistanceRouteOnDeadMedic", calledSourceTarget)
	end
end)

-- The following event is triggered when alerting doctors while the player is dead (used on tpz-core death system).
RegisterNetEvent("tpz_pigeon_alerts:AlertDoctorsOnPlayersDeath")
AddEventHandler("tpz_pigeon_alerts:AlertDoctorsOnPlayersDeath", function()

	local playerPed = PlayerPedId()

	if CooldownTime == 0 then

		local isPlayerDead = IsEntityDead(playerPed)

		if isPlayerDead and ClientData.hasBoughtPigeon then

			CooldownTime = 0

			if EntityHandler.Pigeon then

				SetBlockingOfNonTemporaryEvents(EntityHandler.Pigeon, false)
		
				Citizen.InvokeNative(0xE86A537B5A3C297C, EntityHandler.Pigeon, playerPed)

				Wait(3000)
				
				DeleteEntity(EntityHandler.Pigeon)
				SetEntityAsNoLongerNeeded(EntityHandler.Pigeon)
				EntityHandler.Pigeon = nil
			end

			WhistleTrainedPigeon("death")
		end

	end
end)

RegisterNetEvent("tpz_pigeon_alerts:startDoctorNPCAssistanceRoute")
AddEventHandler("tpz_pigeon_alerts:startDoctorNPCAssistanceRoute", function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	local model     = Config.MedicNPCData.Model
	
	LoadModel(model)

	local height = coords.z

	if height < 0.0 then
		height = coords.z - 50.0
	else
		height = coords.z + 50.0
	end

	local spawnPosition = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, coords.z) 

	EntityHandler.Doctor = CreatePed(model, spawnPosition, GetEntityHeading(playerPed), false, false)
	Citizen.InvokeNative(0x283978A15512B2FE, EntityHandler.Doctor, true)

	SetEntityCanBeDamaged(EntityHandler.Doctor, false)
	SetEntityInvincible(EntityHandler.Doctor, true)
	
	Wait(500)
	SetBlockingOfNonTemporaryEvents(EntityHandler.Doctor, true)

	SetEntityCoords(EntityHandler.Doctor, spawnPosition.x, spawnPosition.y, height + 0.0)
	FreezeEntityPosition(EntityHandler.Doctor, true)

	local foundground, groundZ, normal  = GetGroundZAndNormalFor_3dCoord(spawnPosition.x, spawnPosition.y, height + 0.0)
	while not foundground do 
		height = height + 10
		foundground, groundZ, normal = GetGroundZAndNormalFor_3dCoord(spawnPosition.x, spawnPosition.y, height + 0.0)
		Wait(100)
	end

	SetEntityCoords(EntityHandler.Doctor, spawnPosition.x, spawnPosition.y, groundZ)
    FreezeEntityPosition(EntityHandler.Doctor, false)

	ClearPedTasks(EntityHandler.Doctor)
	TaskGoToEntity(EntityHandler.Doctor, PlayerPedId(), -1, 1.0, 2.0, 0, 0)

end)

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

WhistleTrainedPigeon = function (cb)

	Wait(1000)

	local playerPed = PlayerPedId()

	if EntityHandler.Pigeon == nil then 

		if CooldownTime == 0 then

			local coords = GetEntityCoords(playerPed)
			local model  = "a_c_pigeon"
	
			LoadModel(model)
	
			Citizen.InvokeNative(0xD6401A1B2F63BED6, playerPed, 0x33D023F4, 1)
	
			local spawnPosition = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 30.0) 
	
			EntityHandler.Pigeon = CreatePed(model, spawnPosition, GetEntityHeading(playerPed), false, false)
	
			SetPedScale(EntityHandler.Pigeon, 2.0)
			Citizen.InvokeNative(0x283978A15512B2FE, EntityHandler.Pigeon, true)
	
			SetEntityCanBeDamaged(EntityHandler.Pigeon, false)
			SetEntityInvincible(EntityHandler.Pigeon, true)
			SetEntityCanBeDamagedByRelationshipGroup(EntityHandler.Pigeon, false, GetHashKey('PLAYER'))
			
			Wait(500)
	
			Citizen.InvokeNative(0x23f74c2fda6e7c61, -1749618580, EntityHandler.Pigeon)
			SetBlockingOfNonTemporaryEvents(EntityHandler.Pigeon, true)
	
			Citizen.InvokeNative(0xD6CFC2D59DA72042, EntityHandler.Pigeon, 1, coords.x - 1.0, coords.y - 1.0, coords.z, true, true)

			SetEntityNoCollisionEntity(PlayerPedId(), EntityHandler.Pigeon, false)

			if cb == "default" then
				Wait(1000 * Config.CalledPigeonCooldown)
	
				if EntityHandler.Pigeon then
					SetBlockingOfNonTemporaryEvents(EntityHandler.Pigeon, false)
		
					Citizen.InvokeNative(0xE86A537B5A3C297C, EntityHandler.Pigeon, playerPed)
		
					CooldownTime = Config.CallPigeonCooldownAfterLeaving
		
					if OpenedNoteAlertCreationUI then
						CloseNUIProperly()
					end

					local isEntityDead = IsEntityDead(EntityHandler.Pigeon)
		
					if not isEntityDead then
						TriggerEvent('tpz_core:sendRightTipNotification', Locales['PIGEON_HAS_LEFT'], 3000)
						Wait(10000)
			
						DeleteEntity(EntityHandler.Pigeon)
						SetEntityAsNoLongerNeeded(EntityHandler.Pigeon)

						EntityHandler.Pigeon = nil
					else
						TriggerEvent('tpz_core:sendRightTipNotification', Locales['PIGEON_IS_UNCONCIOUS'], 3000)
		
						DeleteEntity(EntityHandler.Pigeon)
						SetEntityAsNoLongerNeeded(EntityHandler.Pigeon)

						EntityHandler.Pigeon = nil
					end
				end
			else

				Wait(15000)
	
				SetBlockingOfNonTemporaryEvents(EntityHandler.Pigeon, false)
	
				Citizen.InvokeNative(0xE86A537B5A3C297C, EntityHandler.Pigeon, playerPed)
	
				for k, alert in pairs (Config.Alerts) do

					if alert.name == Config.MedicJob then

						CooldownTime = Config.CallPigeonCooldownAfterSendingAlertOnUnconciousPlayer
	
						Wait(3000)
	
						DeleteEntity(EntityHandler.Pigeon)
						SetEntityAsNoLongerNeeded(EntityHandler.Pigeon)

						EntityHandler.Pigeon = nil

						Wait(7000)

						TriggerServerEvent("tpz_pigeon_alerts:startAlertPlayersJob", alert, "death", Locales["UNCONCIOUS_DEFAULT_NOTE_ALERT"], GetEntityCoords(playerPed), false)
	
					end
				end
	
			end
		else
			TriggerEvent('tpz_core:sendRightTipNotification', string.format(Locales['CANNOT_CALL'], CooldownTime), 3000)
		end

	end
end


-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

Citizen.CreateThread(function ()
	while true do
		Wait(1000)

		if EntityHandler.Doctor then
			local playerPed       = PlayerPedId()
			local coords          = GetEntityCoords(playerPed)
			local entityCoords    = GetEntityCoords(EntityHandler.Doctor)

			local coordsDist      = vector3(coords.x, coords.y, coords.z)
			local coordsEntity    = vector3(entityCoords.x, entityCoords.y, entityCoords.z)
			local distance        = #(coordsDist - coordsEntity)

			if distance > 1.4 and distance <= 2.0 then
				TaskGoToEntity(EntityHandler.Doctor, PlayerPedId(), -1, 1.0, 2.0, 0, 0)
			end
			if distance <= 1.4 then
				if not isNPCReviving then

					isNPCReviving = true

					ClearPedTasks(EntityHandler.Doctor)

					local AnimationData     = Config.MedicNPCData

					RequestAnimDict(AnimationData.AnimationDict)
					while not HasAnimDictLoaded(AnimationData.AnimationDict) do
						Citizen.Wait(100)
					end
				
					FreezeEntityPosition(EntityHandler.Doctor, true)

					Anim(EntityHandler.Doctor,AnimationData.AnimationDict,AnimationData.AnimationBody,-1,0)
						
					Wait(2000)
					Citizen.InvokeNative(0xEAA885BA3CEA4E4A, EntityHandler.Doctor, AnimationData.AnimationDict, AnimationData.AnimationBody, 0)

					exports.tpz_core:rClientAPI().DisplayProgressBar(2000, Locales['NPC_APPLYING_SYRINGE'])

					Citizen.InvokeNative(0xEAA885BA3CEA4E4A, EntityHandler.Doctor, AnimationData.AnimationDict, AnimationData.AnimationBody, 1)
					FreezeEntityPosition(EntityHandler.Doctor, false)
					
					--TriggerServerEvent('mega_doctorjob:revivePlayer', GetPlayerFromServerId(PlayerId()))    
					--TriggerServerEvent('mega_doctorjob:healPlayer', GetPlayerFromServerId(PlayerId()), 200, 20)

					TriggerEvent('tpz_core:resurrectPlayer', true)
					
					-- When NPC Revives you, you are paying for the assistance.
					TriggerServerEvent("tpz_pigeon_alerts:onNPCAssistancePayment")

					ClearPedTasks(EntityHandler.Doctor)

					Wait(2000)
					TaskGoToCoordAnyMeans(EntityHandler.Doctor, entityCoords.x + 50.0, entityCoords.y + 50.0, entityCoords.z, 2.0)

					Wait(10000)
					DeleteEntity(EntityHandler.Doctor)  
					SetEntityAsNoLongerNeeded(EntityHandler.Doctor)

					EntityHandler.Doctor = nil
					isNPCReviving   = false

					CooldownTime = 0
					
				end
			end

		end
	end
end)

SelectedAlertData = nil

Citizen.CreateThread(function()

	while true do
		Citizen.Wait(0)
		local sleep  = true
		local player = PlayerPedId()
		local coords = GetEntityCoords(PlayerPedId())

		local isDead = IsEntityDead(player)

		if EntityHandler.Pigeon and not isDead and not OpenedNoteAlertCreationUI then
			local isEntityDead = IsEntityDead(EntityHandler.Pigeon)

			if not isEntityDead then
				local entityCoords = GetEntityCoords(EntityHandler.Pigeon)

				local coordsDist = vector3(coords.x, coords.y, coords.z)
				local coordsEntity = vector3(entityCoords.x, entityCoords.y, entityCoords.z)
				local distance = #(coordsDist - coordsEntity)

				if distance <= 1.5 then
					sleep = false

					local label = CreateVarString(10, 'LITERAL_STRING', Locales['PIGEON_PROMPT_LABEL'] )
					PromptSetActiveGroupThisFrame(PigeonPrompts, label)

					for index, prompt in pairs(PigeonPromptsList) do

						if PromptHasHoldModeCompleted(prompt.prompt) then 

							if not prompt.flee then

								TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_pigeon_alerts:hasRequiredItems", function(cb)

									if cb or not Config.AlertRequirements.Enabled then

										SelectedAlertData = prompt.data

										OpenCreateNote()
									else
										TriggerEvent('tpz_core:sendRightTipNotification', Locales['NOT_REQUIRED_ITEMS'], 3000)
									end
								end)

							elseif prompt.flee then
			
								SetBlockingOfNonTemporaryEvents(EntityHandler.Pigeon, false)

								Citizen.InvokeNative(0xE86A537B5A3C297C, EntityHandler.Pigeon, player)
					
								CooldownTime = Config.CallPigeonCooldownAfterLeaving
					
								Wait(5000)

								if EntityHandler.Pigeon then
									DeleteEntity(EntityHandler.Pigeon)
									SetEntityAsNoLongerNeeded(EntityHandler.Pigeon)
								end

								EntityHandler.Pigeon = nil
								
							end

							Wait(2000)
						end
					end
				end
			end
		end

		if sleep then
			Citizen.Wait(1000)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(1000)

		if CooldownTime > 0 then
			CooldownTime = CooldownTime - 1

			if CooldownTime <= 0 then
				CooldownTime = 0
			end
		end

	end
end)
