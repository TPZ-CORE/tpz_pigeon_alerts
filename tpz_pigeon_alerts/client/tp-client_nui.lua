
local openedJobAlerts     = false
OpenedNoteAlertCreationUI = false

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_pigeon_alerts:OpenJobAlertsUI")
AddEventHandler("tpz_pigeon_alerts:OpenJobAlertsUI", function()
	local allowed = false

	for index, alert in ipairs(Config.Alerts) do

		if ClientData.job and alert.job == ClientData.job then
			OpenJobAlertsUI()
			allowed = true
		end
	end

	if not allowed then
		TriggerEvent('tpz_core:sendRightTipNotification', Locales['NOT_REQUIRED_JOB'], 3000)
	end

end)	

RegisterNetEvent("tpz_pigeon_alerts:closeNUI")
AddEventHandler("tpz_pigeon_alerts:closeNUI", function()
	SendNUIMessage({ action = 'closeUI' })
end)


RegisterNetEvent("tpz_pigeon_alerts:refreshAlertsOnJob")
AddEventHandler("tpz_pigeon_alerts:refreshAlertsOnJob", function(job)
	if openedJobAlerts then
		
		if ClientData.job == job then
			TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_pigeon_alerts:getAlerts", function(alerts)

				SendNUIMessage( { action = 'clearAlerts'})
	
				for k, v in pairs (alerts) do
	
					if v.alertType == "death" then
						
						if not Config.PlayersFullNameAlways then
							v.name = Locales['UNKNOWN_ALERT_SENDER']
						end
						
					end
	
					if v.job == ClientData.job then
						SendNUIMessage( { action = 'loadJobAlerts', index = k, alert = v })
					end
				end
	
			end)
		end

	end
end)

-----------------------------------------------------------
--[[ Callbacks  ]] --
-----------------------------------------------------------

RegisterNUICallback('closeNUI', function()
	EnableGui(false, UIType)
end)

RegisterNUICallback('closeRegisteredAlert', function(data)

	TriggerServerEvent("tpz_pigeon_alerts:closeRegisteredAlert", data.source, ClientData.job)
end)

RegisterNUICallback('createNewRegisteredAlert', function(data)

	local returnedText = data.text

	CloseNUIProperly()

	local player = PlayerPedId()
	local coords = GetEntityCoords(PlayerPedId())

	TriggerServerEvent("tpz_pigeon_alerts:removeRequiredItems")

	SetBlockingOfNonTemporaryEvents(EntityHandler.Pigeon, false)		
	Citizen.InvokeNative(0xE86A537B5A3C297C, EntityHandler.Pigeon, player)
					
	CooldownTime = Config.CallPigeonCooldownAfterSendingAlert
					
	Wait(10000)

	TriggerServerEvent("tpz_pigeon_alerts:startAlertPlayersJob", SelectedAlertData, "pigeon", returnedText, coords, data.show)
					
	DeleteEntity(EntityHandler.Pigeon)
	SetEntityAsNoLongerNeeded(EntityHandler.Pigeon)

	EntityHandler.Pigeon = nil
end)

RegisterNUICallback('routeSelectedRegisteredAlert', function(data)

	local newCoords = {x = tonumber(data.coordsX), y = tonumber(data.coordsY), z = tonumber(data.coordsZ)}

	local playerPed = PlayerPedId()
	local currentCoords = GetEntityCoords(playerPed)

	StartGpsMultiRoute(GetHashKey("COLOR_PURPLE"), true, true)

	AddPointToGpsMultiRoute(currentCoords)
	AddPointToGpsMultiRoute(newCoords.x, newCoords.y, newCoords.z)
    SetGpsMultiRouteRender(true)

	CloseNUIProperly()
	
	if Config.ExpandTimeRespawnOnMedicRoute and ClientData.job == Config.MedicJob then
		TriggerServerEvent("tpz_pigeon_alerts:onMedicPlayerRouteStarted", data.source)
	end

	local blip = Citizen.InvokeNative(0x45f13b7e0a15c880, -1282792512, newCoords.x, newCoords.y, newCoords.z, 40.0)
	Wait(1000 * Config.RouteBlipCooldown) 
	RemoveBlip(blip)
end)

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

CloseNUIProperly = function()
	SendNUIMessage({ action = 'closeUI' })
end

ClearAlertGpsMultiRoute = function()
    ClearGpsMultiRoute()
end

OpenCreateNote = function(data)
	local player = PlayerPedId()
	local isDead = IsEntityDead(player)

	if not isDead and not OpenedNoteAlertCreationUI then
		ExecuteCommand("e notebook")

		Wait(2000)
	
		OpenedNoteAlertCreationUI = true
	
		UIType = "enable_ui"
		EnableGui(true, UIType, "create")
	end
end

OpenJobAlertsUI = function()
	local player = PlayerPedId()
	local isDead = IsEntityDead(player)

	if not isDead and not openedJobAlerts then

		--ExecuteCommand("e notebook")
		--Wait(2000)
		TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_pigeon_alerts:getAlerts", function(alerts)

			for k, v in pairs (alerts) do

                if v.job == ClientData.job then
                    SendNUIMessage( { action = 'loadJobAlerts', index = k, alert = v })
                end
			end

			UIType = "enable_ui"
			EnableGui(true, UIType, "review")

		end)
	end
end

EnableGui = function(state, ui, class)
	SetNuiFocus(state, state)

	openedJobAlerts = state
	OpenedNoteAlertCreationUI = state

	if state == false then
		ExecuteCommand("e c")

	end

	SendNUIMessage({ type = ui, enable = state, displayedClass =  class})
end
