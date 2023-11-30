RegisterCommand(Config.CallPigeonCommand, function(source, args, rawCommand)

	local player = PlayerPedId()
	local isDead = IsEntityDead(player)

	if not isDead then

		if ClientData.hasBoughtPigeon then
			WhistleTrainedPigeon("default")
		else
			TriggerEvent('tpz_core:sendRightTipNotification', Locales['NO_TRAINED_PIGEON'], 3000)
		end
	end
end)

RegisterCommand(Config.CancelRouteCommand, function(source, args, rawCommand)
    ClearAlertGpsMultiRoute()
end)