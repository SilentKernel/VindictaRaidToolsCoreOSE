-- Vindicta Raid Tool Core By Silentkernel --
VTA_T = {} -- Will Get all global data of this addon --
VTA_T.CHATPREFIX = "[VRTC] : "
VTA_DEBUG = false

local WELCOME_MESSAGE_SHOWED = false
local VTA_CHAN_CLIENT = "RAID"

if VTA_DEBUG == true then
	VTA_CHAN_CLIENT = "PARTY"
end

local VTA_MP = {}
-- Global Action --
VTA_MP["g"] = "VRT_G"
-- General Weak Aura --
VTA_MP["gt1"] = "VRT_GT1"
VTA_MP["gt2"] = "VRT_GT2"
VTA_MP["gt3"] = "VRT_GT3"
-- General Weak Aura --
VTA_MP["pt1"] = "VRT_PT1"
VTA_MP["pt2"] = "VRT_PT2"
VTA_MP["pt3"] = "VRT_PT3"

-- Theses function will be usefull for the Addon --
local function VTA_ChecjInArray(playerName, table)
	local result = false
	for key,value in pairs(table) do
        if value == playerName
		then
			result = true
		end
    end
	return result
end

function VTA_T.IsHeal(playerName)
	return VTA_ChecjInArray(playerName, VTA_HEAL)
end

function VTA_T.IsTank(playerName)
	return VTA_ChecjInArray(playerName, VTA_TANK)
end

local function VTA_ShowAddonLoaded()
 	print(VTA_T.CHATPREFIX .. "Core loaded");
end

local function getArrayToSend()
	local const VTA_CLIENT_ARRAY_TO_SEND = {}
	VTA_CLIENT_ARRAY_TO_SEND["show"] = false
	VTA_CLIENT_ARRAY_TO_SEND["hideNow"] = false
	VTA_CLIENT_ARRAY_TO_SEND["playerOnly"] = false
	VTA_CLIENT_ARRAY_TO_SEND["say"] = false
	-- Theses entries are added if necessary
	--VTA_CLIENT_ARRAY_TO_SEND["sayChan"] = "say"
	--VTA_CLIENT_ARRAY_TO_SEND["sayMessage"] = ""
	--VTA_CLIENT_ARRAY_TO_SEND["playerName"] = ""
	--VTA_CLIENT_ARRAY_TO_SEND["message"] = ""

	return VTA_CLIENT_ARRAY_TO_SEND	
end

local function sendMessageToClients(prefix, toSend)
	local message = WeakAuras.TableToString(toSend, true)
	SendAddonMessage(VTA_MP[prefix], message , VTA_CHAN_CLIENT, nil)
end

function VTA_T.SendClearAllToRaid()
	local toSend = getArrayToSend()
	toSend["hideNow"] = true
	sendMessageToClients("g", toSend)
	sendMessageToClients("g", toSend) -- double send to fix sometime weak aura does not has time to hide them
end

function VTA_T.SendAuraToRaid(channel, show, message, say, sayChan, sayMessage)
	local toSend = getArrayToSend()
	
	toSend["show"] = show
	if show == true then
		toSend["message"] = message
	end	
	
	toSend["say"] = say
	if say == true then
		toSend["sayChan"] = sayChan
		toSend["sayMessage"] = sayMessage
	end

	sendMessageToClients(channel, toSend)
end

function VTA_T.SendHideAuraToRaid(channel)
	local toSend = getArrayToSend()
	toSend["hideNow"] = true
	sendMessageToClients(channel, toSend)
end

function VTA_T.SendAuraToClient(channel, client, show, message, say, sayChan, sayMessage)
	local toSend = getArrayToSend()
	
	toSend["show"] = show
	if show == true then
		toSend["message"] = message
	end
	
	toSend["say"] = say
	if say == true then
		toSend["sayChan"] = sayChan
		toSend["sayMessage"] = sayMessage
	end
	
	toSend["playerOnly"] = true
	toSend["playerName"] = client
	sendMessageToClients(channel , toSend)
end

function VTA_T.SendHideAuraToClient(channel, client)
	local toSend = getArrayToSend()
	toSend["hideNow"] = true
	toSend["playerOnly"] = true
	toSend["playerName"] = client
	sendMessageToClients(channel, toSend)
end

function VTA_T.getHealthPercent(unitToTrack)
	local currentHealth = UnitHealth(unitToTrack)
	local maxHealth = UnitHealthMax(unitToTrack)
	if (currentHealth ~= 0) and (maxHealth ~= 0)
	then
		local percent = (currentHealth / maxHealth) * 100
		return percent		
	else
		return 100
	end
end

-- register slash command --
SLASH_VTACORELOADED1 = '/vrtc';
function SlashCmdList.VTACORELOADED(msg, editbox) 
	VTA_ShowAddonLoaded();
end

SLASH_VTACORECHECK1 = '/vrtccheck';
function SlashCmdList.VTACORECHECK(msg, editbox) 
	VTA_T.SendAuraToRaid("gt1", true, "GENERAL MESSAGE 1", false, "", "")
	VTA_T.SendAuraToRaid("gt2", true, "GENERAL MESSAGE 2", false, "", "")
	VTA_T.SendAuraToRaid("gt3", true, "GENERAL MESSAGE 3", false, "", "")
	
	VTA_T.SendAuraToRaid("pt1", true, "PERSONAL MESSAGE 1", false, "", "")
	VTA_T.SendAuraToRaid("pt2", true, "PERSONAL MESSAGE 2", false, "", "")
	VTA_T.SendAuraToRaid("pt3", true, "PERSONAL MESSAGE 3", false, "", "")
	
	VTA_T.SendAuraToRaid("g", false, "", true, "SAY", VTA_T.CHATPREFIX .. "Test mod")	
end

SLASH_VTACORECLEAR1 = '/vrtcclearall';
function SlashCmdList.VTACORECLEAR(msg, editbox) 
	VTA_T.SendClearAllToRaid()
end

local function VTA_UnloaAllBoss()
	VTA_T.SendClearAllToRaid()
	VTA_T.BLACKHAND.unload()
	VTA_T.GRUUL.unload()
	VTA_T.IRONMAIDENS.unload()
end

local VTA_FRAME = CreateFrame("Frame", "VINDICTA_RAID_TOOLS_CORE_FRAME") -- Will handle encouter begin and ending
-- Register Event to get when we are in combat and face who --
VTA_FRAME:RegisterEvent("PLAYER_ENTERING_WORLD");
-- When we enter fight begin and when fight end
VTA_FRAME:RegisterEvent("ENCOUNTER_START");
VTA_FRAME:RegisterEvent("ENCOUNTER_END");
-- DEBUG ONLY WILL BE COMMENTED ON FINAL VERSION
if VTA_DEBUG == true
then
	VTA_FRAME:RegisterEvent("PLAYER_REGEN_DISABLED");
	VTA_FRAME:RegisterEvent("PLAYER_REGEN_ENABLED");
end

-- [1691] = "Gruul",
-- [1696] = "Oregorger",
-- [1694] = "Beastlord Darmac",
-- [1689] = "Flamebender Ka'graz",
-- [1693] = "Hans'gar & Franzok",
-- [1692] = "Operator Thogar",
-- [1690] = "The Blast Furnace",
-- [1713] = "Kromog, Legend of the Mountain",
-- [1695] = "The Iron Maidens",
-- [1704] = "Blackhand",

-- Function handle event --
local function eventHandler(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD"
 	then
		if WELCOME_MESSAGE_SHOWED ~= true
		then
			WELCOME_MESSAGE_SHOWED = true
	 	    VTA_ShowAddonLoaded();
	   end
	   
    -- Real boss start
	 elseif event == "ENCOUNTER_START" 
	 then
	 local encounterID, encounterName, difficultyID, raidSize = ...
	 print(VTA_T.CHATPREFIX .. "Encouter " .. encounterID .. " started");
	 
	
	 if encounterID == 1691 then -- Gruul start
		 VTA_T.GRUUL.load()
	 elseif encounterID == 1695 then -- Maiden's start	 
		 VTA_T.IRONMAIDENS.load()
	 elseif encounterID == 1704 then -- Black Hand Start	 
		 VTA_T.BLACKHAND.load()
	 end
		 
 	elseif event == "ENCOUNTER_END"
 	then
	 VTA_UnloaAllBoss();
	end
  
 -- debug --
 if VTA_DEBUG == true
 then 
  	if event == "PLAYER_REGEN_DISABLED" -- We begin a fight DEBUG --
  	   then
		   -- VTA_T.GRUUL.load()
		   --VTA_T.IRONMAIDENS.load()
		   --VTA_T.BLACKHAND.load()
 	elseif event == "PLAYER_REGEN_ENABLED" -- fight finished wipe or down DEBUG --
  	   then
 	 	-- VTA_UnloaAllBoss();
	end
 end
end

-- reguster event --
VTA_FRAME:SetScript("OnEvent", eventHandler);
