
-----------------------------------------------------------
--[[ Prompts  ]]--
-----------------------------------------------------------

Prompts       = GetRandomIntInRange(0, 0xffffff)
Prompt        = nil

StorePromptSetUp = function()

    local str      = Locales['STORE_PROMPT_KEY_LABEL']
    local keyPress = Config.OpenStorePromptKey

    Prompt = PromptRegisterBegin()
    PromptSetControlAction(Prompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(Prompt, str)
    PromptSetEnabled(Prompt, 1)
    PromptSetVisible(Prompt, 1)
    PromptSetStandardMode(Prompt, 1)
    PromptSetHoldMode(Prompt, 1000)
    PromptSetGroup(Prompt, Prompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, Prompt, true)
    PromptRegisterEnd(Prompt)

end


-----------------------------------------------------------
--[[ Prompts  ]]--
-----------------------------------------------------------

PigeonPrompts     = GetRandomIntInRange(0, 0xffffff)
PigeonPromptsList = {}

PigeonPromptsSetUp = function()
    local finished = false

    for index, value in pairs(Config.Alerts) do 

        local _pigeonPrompt = PromptRegisterBegin()
        PromptSetControlAction(_pigeonPrompt, value.PromptKey)
    
        local str = CreateVarString(10, 'LITERAL_STRING', value.Label)
        PromptSetText(_pigeonPrompt, str)
    
        PromptSetEnabled(_pigeonPrompt, 1)
        PromptSetVisible(_pigeonPrompt, 1)
        PromptSetStandardMode(_pigeonPrompt, 1)
        PromptSetHoldMode(_pigeonPrompt, 1000)
        PromptSetGroup(_pigeonPrompt, PigeonPrompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, _pigeonPrompt, true)
        PromptRegisterEnd(_pigeonPrompt)
    
        table.insert(PigeonPromptsList, {data = value, prompt = _pigeonPrompt, flee = false})

        if next(Config.Alerts, index) == nil then
            finished = true
        end

    end

    while not finished do
        Wait(500)
    end

    -- If the Alert Prompts are finished, we are adding the Flee Prompt.

    local _pigeonPrompt = PromptRegisterBegin()
    PromptSetControlAction(_pigeonPrompt, Config.PigeonFleePromptKey)

    local str = CreateVarString(10, 'LITERAL_STRING', "Flee")
    PromptSetText(_pigeonPrompt, str)

    PromptSetEnabled(_pigeonPrompt, 1)
    PromptSetVisible(_pigeonPrompt, 1)
    PromptSetStandardMode(_pigeonPrompt, 1)
    PromptSetGroup(_pigeonPrompt, PigeonPrompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, _pigeonPrompt, true)
    PromptRegisterEnd(_pigeonPrompt)

	table.insert(PigeonPromptsList, {data = nil, prompt = _pigeonPrompt, flee = true})
end

-----------------------------------------------------------
--[[ Blips  ]]--
-----------------------------------------------------------

AddBlip = function(Store)
    local data = Config.Stores[Store]

    if data.BlipData then
        data.BlipHandle = N_0x554d9d53f696d002(1664425300, data.Coords.x, data.Coords.y, data.Coords.z)

        SetBlipSprite(data.BlipHandle, data.BlipData.Sprite, 1)
        SetBlipScale(data.BlipHandle, data.BlipData.Scale)
        Citizen.InvokeNative(0x9CB1A1623062F402, data.BlipHandle, data.BlipData.Name)

		Citizen.InvokeNative(0x662D364ABF16DE2F, data.BlipHandle, 0xF91DD38D)
    end
end


SpawnNPC = function(Store)
    local data = Config.Stores[Store]

	LoadModel(data.NPCData.Model)

	local npc = CreatePed(data.NPCData.Model, data.Coords.x, data.Coords.y, data.Coords.z, data.Coords.h, false, true, true, true)

	Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation

	SetEntityCanBeDamaged(npc, false)
	SetEntityInvincible(npc, true)
	Wait(1000)
	FreezeEntityPosition(npc, true) -- NPC can't escape
	SetBlockingOfNonTemporaryEvents(npc, true) -- NPC can't be scared

	Config.Stores[Store].NPC = npc

end

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

LoadModel = function(model)
    local model = GetHashKey(model)

    if IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            RequestModel(model)
            Citizen.Wait(100)
        end
    else
        print(model .. " is not valid") -- Concatenations
    end
end

Anim = function(actor, dict, body, duration, flags, introtiming, exittiming)
	Citizen.CreateThread(function()
		RequestAnimDict(dict)
		local dur = duration or -1
		local flag = flags or 1
		local intro = tonumber(introtiming) or 1.0
		local exit = tonumber(exittiming) or 1.0
		timeout = 5
		while (not HasAnimDictLoaded(dict) and timeout>0) do
			timeout = timeout-1
			if timeout == 0 then 
				print("Animation Failed to Load")
			end
			Citizen.Wait(300)
		end
		TaskPlayAnim(actor, dict, body, intro, exit, dur, flag --[[1 for repeat--]], 1, false, false, false, 0, true)
	end)
end
