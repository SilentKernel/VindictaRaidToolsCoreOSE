VTA_T.IRONMAIDENS = {}
local isLoaded = false
local frame = nil
local bossName = "The Iron Maidens"
local triggerShip = "prepares to man the Dreadnaught's Main Cannon!"
-- should has blank behind name -- 
local marakName = "Marak the Blooded "
local sorkaName = "Enforcer Sorka "
local garanName = "Admiral Gar'an "
local timeBeforeHideShip = 5

local function getShipCount(message) 
	local result = 0
	if message == (marakName .. triggerShip) then
		result = 1
	elseif message == (sorkaName .. triggerShip) then
		result = 2
	elseif message == (garanName .. triggerShip) then
		result = 3
	end
	return result
end

local function goToShip(shipCount)
	if shipCount < 4 then
		local stringGeneral = ""
		local shimCompo = VTA_MAIDENS_ROTA_SHIP[shipCount]
		for key,value in pairs(shimCompo) do
			local stringPersonnal = value .. "(".. key .. ") "
			
			VTA_T.SendAuraToClient("pt1", value, true, "Go ship (Crochet : " .. key .. ")", false, "", "")
			stringGeneral = stringGeneral .. stringPersonnal
		end
		if VTA_DEBUG == true then
			print (stringGeneral)
		end	
		
		VTA_T.SendAuraToRaid("gt2", true, stringGeneral, false, nil, nil)
		C_Timer.After(timeBeforeHideShip, function() VTA_T.SendHideAuraToRaid("gt2") VTA_T.SendHideAuraToRaid("pt1") end)
	end
end

local function eventHandler(self, event, ...)
	if event == "CHAT_MSG_RAID_BOSS_EMOTE" then
		local message, sender = ...
		-- print(message); --
		local shipCount = getShipCount(message)
		if shipCount > 0 then
			goToShip(shipCount)	
		end	
	end
	
	if VTA_DEBUG == true then
		if event == "CHAT_MSG_EMOTE" then
			local message, sender = ...
			local shipCount = getShipCount(message)
			if shipCount > 0 then
				goToShip(shipCount)	
			end	
		end
	end
end 

function VTA_T.IRONMAIDENS.load()
	if isLoaded == false
	then
		if frame == nil then
			frame = CreateFrame("frame", "VTA_T_MAIDENS");
			frame:SetScript("OnEvent", eventHandler);
		end		
		frame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE");	
		if VTA_DEBUG == true then
			frame:RegisterEvent("CHAT_MSG_EMOTE");
		end
		isLoaded = true
		print(VTA_T.CHATPREFIX .. bossName .. " begin")
	end
end

function VTA_T.IRONMAIDENS.unload()
	if isLoaded
	then
		frame:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE");
		
		if VTA_DEBUG == true then
			frame:UnregisterEvent("CHAT_MSG_EMOTE");
		end
		
		isLoaded = false
		print(VTA_T.CHATPREFIX .. bossName .. " ended")
	end
end