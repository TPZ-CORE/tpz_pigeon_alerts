local hasOpenedStore = false

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for i, v in pairs(Config.Stores) do
        if v.BlipHandle then
            RemoveBlip(v.BlipHandle)
        end

        if v.NPC then
            DeleteEntity(v.NPC)
            DeletePed(v.NPC)
            SetEntityAsNoLongerNeeded(v.NPC)
        end
    end

end)

RegisterNetEvent("tpz_core:isPlayerReady")
AddEventHandler("tpz_core:isPlayerReady", function()
	if Config.DevMode then
		return
	end

	StorePromptSetUp()
end)


Citizen.CreateThread(function ()
	if not Config.DevMode then
        return
    end

	StorePromptSetUp()

end)

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

OpenTrainedPigeonStore = function()

	local inputData = {
		title        = Locales['TRAINED_PIGEONS_STORE_TITLE'],
		desc         = string.format(Locales['TRAINED_PIGEONS_STORE_DESCRIPTION'], Config.TrainedPigeonCost),
		buttonparam1 = Locales['TRAINED_PIGEONS_STORE_ACCEPT_BUTTON'],
		buttonparam2 = Locales['TRAINED_PIGEONS_STORE_DECLINE_BUTTON']
	}

	TriggerEvent("tp_inputs:getButtonInput", inputData, function(cb)

		if cb == "ACCEPT" then
			TriggerServerEvent("tpz_pigeon_alerts:purchaseTrainedPigeon")
		end

        hasOpenedStore = false

	end)

end


-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(0)

        local sleep        = true
        local player       = PlayerPedId()
        local isPlayerDead = IsEntityDead(player)

        if not hasOpenedStore and not isPlayerDead then

            local coords = GetEntityCoords(player)
            local hour = GetClockHours()

            for storeId, storeConfig in pairs(Config.Stores) do

                local coordsDist  = vector3(coords.x, coords.y, coords.z)
                local coordsStore = vector3(storeConfig.Coords.x, storeConfig.Coords.y, storeConfig.Coords.z)
                local distance    = #(coordsDist - coordsStore)

                if not Config.Stores[storeId].BlipHandle and storeConfig.BlipData.Enabled then
                    AddBlip(storeId)
                end

                if Config.Stores[storeId].NPC and distance > Config.RenderNPCDistance then
                    DeleteEntity(Config.Stores[storeId].NPC)
                    DeletePed(Config.Stores[storeId].NPC)
                    SetEntityAsNoLongerNeeded(Config.Stores[storeId].NPC)
                    Config.Stores[storeId].NPC = nil
                end
                    
                if not Config.Stores[storeId].NPC and storeConfig.NPCData.Enabled and distance <= Config.RenderNPCDistance then
                    SpawnNPC(storeId)
                end

                if (distance <= storeConfig.DistanceOpenStore) then 
    
                    sleep = false
                    local label = CreateVarString(10, 'LITERAL_STRING', Locales['TRAINED_PIGEONS_STORE_PROMPT_LABEL'] )
                    PromptSetActiveGroupThisFrame(Prompts, label)

                    if PromptHasHoldModeCompleted(Prompt) then 

                        OpenTrainedPigeonStore()
                        hasOpenedStore = true

                        Wait(1000)
                    end

                end

            end
        end
        if sleep then
            Citizen.Wait(1000)
        end
    end
end)