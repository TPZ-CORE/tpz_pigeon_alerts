local TPZ         = {}
local TPZInv      = exports.tpz_inventory:getInventoryAPI()

Alerts            = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Basic Handler Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_pigeon_alerts:startDoctorNPCAssistanceRouteOnDeadMedic")
AddEventHandler("tpz_pigeon_alerts:startDoctorNPCAssistanceRouteOnDeadMedic", function(calledSourceTarget)
	TriggerClientEvent("tpz_pigeon_alerts:startDoctorNPCAssistanceRoute", tonumber(calledSourceTarget))
end)

RegisterServerEvent("tpz_pigeon_alerts:onMedicPlayerRouteStarted")
AddEventHandler("tpz_pigeon_alerts:onMedicPlayerRouteStarted", function(targetSource)
	local _source = tonumber(targetSource)
	TriggerClientEvent('tpz_core:sendRightTipNotification', _source, Locales['NPC_ON_ITS_WAY'], 5000)
end)

RegisterServerEvent("tpz_pigeon_alerts:closeRegisteredAlert")
AddEventHandler("tpz_pigeon_alerts:closeRegisteredAlert", function(alertSourceId, jobAlert)
	local _source = source
	local xPlayer = TPZ.GetPlayer(_source)

	for k, alert in pairs (Alerts) do
		if tonumber(alertSourceId) == tonumber(alert.source) then

			alert.solved   = true
			alert.solvedBy = xPlayer.getFirstName() .. " " .. xPlayer.getLastName()
		
			TriggerClientEvent("tpz_pigeon_alerts:refreshAlertsOnJob", -1, jobAlert)
		end
	end
end)

RegisterServerEvent("tpz_pigeon_alerts:onNPCAssistancePayment")
AddEventHandler("tpz_pigeon_alerts:onNPCAssistancePayment", function()
	local _source = source
	local xPlayer = TPZ.GetPlayer(_source)

	xPlayer.removeAccount(Config.MedicNPCData.ReviveCostMethodType, Config.MedicNPCData.ReviveCost)
	TriggerClientEvent('tpz_core:sendRightTipNotification', _source, string.format(Locales['NPC_MEDICAL_ASSISTANCE_PAYMENT'], Config.MedicNPCData.ReviveCost), 3000)
end)

-----------------------------------------------------------
--[[ Pigeon Alert Events & Handlers  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_pigeon_alerts:requestClientData")
AddEventHandler("tpz_pigeon_alerts:requestClientData", function()
	local _source         = source
    local xPlayer         = TPZ.GetPlayer(_source)

	while not xPlayer.loaded() do
		Wait(1000)
	end

	local identifier      = xPlayer.getIdentifier()
	local charidentifier  = xPlayer.getCharacterIdentifier()

	exports["ghmattimysql"]:execute("SELECT hasPigeon, hunger, dead FROM pigeons WHERE identifier = @identifier AND charIdentifier = @charIdentifier", { ["@identifier"] = identifier, ['@charIdentifier'] = charidentifier}, function(result)
		
		if result[1] then

			local hasPigeon = tonumber(result[1].hasPigeon)
			local hunger    = tonumber(result[1].hunger)
			local isDead    = tonumber(result[1].dead)

			if hasPigeon == 0 then

				local Parameters = {
					hasBoughtPigeon = false, 
					pigeonHunger    = 100, 
					pigeonIsDead    = 0, 
					job             = xPlayer.getJob()
				} 

				TriggerClientEvent("tpz_pigeon_alerts:updateClientData", _source, Parameters)
	
			else

				local Parameters = {
					hasBoughtPigeon = true,  
					pigeonHunger    = hunger, 
					pigeonIsDead    = isDead, 
					job             = xPlayer.getJob()
				}

				TriggerClientEvent("tpz_pigeon_alerts:updateClientData", _source, Parameters)
			end

		else

			local Parameters = { 
				['identifier']     = identifier,
				['charidentifier'] = tonumber(charidentifier),
				['hasPigeon']      = 0,
				['hunger']         = 100,
				['dead']           = 0,
			}
	
			exports.ghmattimysql:execute("INSERT INTO pigeons ( `identifier`,`charidentifier`, `hasPigeon`, `hunger`, `dead`) VALUES ( @identifier, @charidentifier, @hasPigeon, @hunger, @dead)", Parameters)

			local Parameters = {
				hasBoughtPigeon = false, 
				pigeonHunger    = 100, 
				pigeonIsDead    = 0, 
				job             = xPlayer.getJob()
			}

			TriggerClientEvent("tpz_pigeon_alerts:updateClientData", _source, Parameters)
		end
	end)

	TriggerClientEvent("tpz_pigeon_alerts:getPlayerJob", _source, xPlayer.getJob())
end)

RegisterServerEvent("tpz_pigeon_alerts:purchaseTrainedPigeon")
AddEventHandler("tpz_pigeon_alerts:purchaseTrainedPigeon", function()

	local _source         = source
    local xPlayer         = TPZ.GetPlayer(_source)

	local identifier      = xPlayer.getIdentifier()
	local charidentifier  = xPlayer.getCharacterIdentifier()

	local money           = xPlayer.getAccount(Config.TrainedPigeonCostMethodType)

	exports["ghmattimysql"]:execute("SELECT hasPigeon FROM pigeons WHERE identifier = @identifier AND charIdentifier = @charIdentifier", { ["@identifier"] = identifier, ['@charIdentifier'] = charidentifier}, function(result)
		local hasPigeon = tonumber(result[1].hasPigeon)

		if hasPigeon == 0 then

			if Config.TrainedPigeonCost <= money then

				xPlayer.removeAccount(Config.TrainedPigeonCostMethodType, Config.TrainedPigeonCost)

				local Parameters = { 
					['identifier'] = identifier, 
					['charidentifier'] = charidentifier, 
					['hasPigeon'] = 1 
				}
			
				exports.ghmattimysql:execute("UPDATE pigeons SET hasPigeon = @hasPigeon WHERE identifier = @identifier AND charidentifier = @charidentifier", Parameters)

				TriggerClientEvent("tpz_pigeon_alerts:updateClientData", _source, {hasBoughtPigeon = true, job = xPlayer.getJob()})

				TriggerClientEvent('tpz_core:sendRightTipNotification', _source, string.format(Locales['SUCCESSFULLY_BOUGHT_TRAINED_PIGEON'], Config.TrainedPigeonCost), 3000)

			else
				TriggerClientEvent('tpz_core:sendRightTipNotification', _source, Locales['NOT_ENOUGH_MONEY'], 3000)
			end

		else
			TriggerClientEvent('tpz_core:sendRightTipNotification', _source, Locales['ALREADY_HAVE_TRAINED_PIGEON'], 3000)
		end
		
	end)

end)

RegisterServerEvent("tpz_pigeon_alerts:removeRequiredItems")
AddEventHandler("tpz_pigeon_alerts:removeRequiredItems", function()
	local _source = source


	if Config.AlertRequirements.Enabled then
		
		if Config.AlertRequirements.RequiredPaperItem.removeItem then
			TPZInv.removeItem(_source, Config.AlertRequirements.RequiredPaperItem.item, 1)
		end

		local penData = Config.AlertRequirements.RequiredPenItem

		if penData.removeItem then
			TPZInv.removeItem(_source, penData.item, 1)

		elseif not penData.removeItem and penData.removeDurability then
			TPZInv.removeItemDurability(_source, penData.item, penData.removeDurability, nil, true)
		end
		
	end
end)

RegisterServerEvent("tpz_pigeon_alerts:startAlertPlayersJob")
AddEventHandler("tpz_pigeon_alerts:startAlertPlayersJob", function(alert, type, message, pos, hasUsername)
	local _source         = source
    local xPlayer         = TPZ.GetPlayer(_source)

	local identifier      = xPlayer.getIdentifier()
	local charidentifier  = xPlayer.getCharacterIdentifier()
	local firstname       = xPlayer.getFirstName()
	local lastname        = xPlayer.getLastName()

	local time            =  os.date('%H') .. ":" .. os.date('%M')
	local currentDate     = os.date('%d').. '/' ..os.date('%m').. '/1890 ' .. os.date('%H') .. ":" .. os.date('%M')

	local username        = Locales['UNKNOWN_ALERT_SENDER']

	if hasUsername then
		username = firstname .. " " .. lastname
	end

	if Config.SaveInDatabase then

		local Parameters = { 
			['identifier']     = identifier,
			['charidentifier'] = tonumber(charidentifier),
			['username']       = firstname .. " " .. lastname,
			['alerted_job']    = alert.job,
			['message']        = message,
			['date']           = currentDate,
		}

		exports.ghmattimysql:execute("INSERT INTO alerts ( `identifier`,`charidentifier`, `username`, `alerted_job`, `message`, `date`) VALUES ( @identifier, @charidentifier, @username, @alerted_job, @message, @date)", Parameters)
	end

	if alert.WebhookManagement.Enabled then

		--	local title   = "📋` /setgroup` ".. target
		--	--local message = "**Steam name: **`" .. steamName .. " (" .. xPlayer.group .. ")`**\nIdentifier**`" .. identifier .. "` \n**Discord:** <@" .. discordId .. ">**\nIP: **`" .. ip .. "`\n **Action:** `Used Set Group Command`"
		--	TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
	
		--	SendToDiscord(alert.WebhookManagement.Webhook, username, message, nil)
	end

	local NewAlertParameter = {
		source      = _source, 
		name        = username, 
		coords      = {x = pos.x, y = pos.y, z = pos.z},
		job         = alert.job, 
		alertType   = type, 
		messageType = message, 
		time        = time, 
		solved      = false, 
		solvedBy    = nil
	}

	table.insert(Alerts, NewAlertParameter)

	TriggerClientEvent('tpz_core:sendRightTipNotification', _source, alert.originText, 3000)

	-- The following code is used to alert the job where the alert has been sent.

	-- If the job is not for medics, we sent just an alert.

	local getAlertJobPlayersList = TPZ.GetJobPlayers(alert.job)
	
	local onlineMedicPlayerId    = nil -- this is used only for medics.

	if getAlertJobPlayersList.count > 0 then

		for index, player in pairs(getAlertJobPlayersList.players) do

			onlineMedicPlayerId = tonumber(player.source) -- this is used only for medics.

			TriggerClientEvent("tpz_pigeon_alerts:sendJobAlert", tonumber(player.source), alert.message, alert.messageTime, alert.job, alert.hash, pos.x, pos.y, pos.z, alert.icon, alert.radius, alert.blipTime) -- send alert to job
		end
	end
	
	if alert.job == Config.MedicJob then

		if getAlertJobPlayersList.count <= 0 then
			TriggerClientEvent("tpz_pigeon_alerts:startDoctorNPCAssistanceRoute", _source)

		else
			-- We are checking if the count is (1) medic in case this medic is the unconscious player.
			if getAlertJobPlayersList.count == 1 then
				TriggerClientEvent("tpz_pigeon_alerts:checkOnOnlyMedicStatus", onlineMedicPlayerId, _source)
			end

		end

	end

end)
