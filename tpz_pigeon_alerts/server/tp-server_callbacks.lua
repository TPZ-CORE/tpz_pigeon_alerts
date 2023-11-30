
local TPZ         = {}
local TPZInv      = exports.tpz_inventory:getInventoryAPI()

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:rServerAPI().addNewCallBack("tpz_pigeon_alerts:getAlerts", function(source, cb)
	cb(Alerts)
end)

exports.tpz_core:rServerAPI().addNewCallBack("tpz_pigeon_alerts:hasPigeon", function(source, cb)
	local _source         = source
    local xPlayer         = TPZ.GetPlayer(_source)

	local identifier      = xPlayer.getIdentifier()
	local charidentifier  = xPlayer.getCharacterIdentifier()

	exports["ghmattimysql"]:execute("SELECT hasPigeon FROM pigeons WHERE identifier = @identifier AND charIdentifier = @charIdentifier", { ["@identifier"] = identifier, ['@charIdentifier'] = charidentifier}, function(result)
		
		if result[1] then

			local hasPigeon = tonumber(result[1].hasPigeon)

			if hasPigeon == 0 then
				return cb(false)
	
			else
				return cb(true)
			end
		end

		return cb(false)
	end)
end)

exports.tpz_core:rServerAPI().addNewCallBack("tpz_pigeon_alerts:hasRequiredItems", function(source, cb)
	local _source   = source

	if not Config.AlertRequirements.Enabled then return cb(true) end
  
	local paperItem = TPZInv.getItemQuantity(_source, Config.AlertRequirements.RequiredPaperItem.item)
	local penItem   = TPZInv.getItemQuantity(_source, Config.AlertRequirements.RequiredPenItem.item)

	if paperItem > 0 and penItem > 0 then
		return cb(true)
	end

	return cb(false)

end)

