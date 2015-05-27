VTA_T.GRUUL = {}
local isLoaded = false
local frame = nil
local bossName = "Gruul"
local cleaveCount = 1

local function refreshCleavelInfos()
	VTA_T.SendHideAuraToRaid("pt1")
	VTA_T.SendAuraToRaid("gt1", true, VTA_GRULL_ROTA_CLEAVE[cleaveCount], false, nil, nil)
end

local function showCleaveInfosPersonnal()
	VTA_T.SendAuraToRaid("pt1", true, VTA_GRULL_ROTA_CLEAVE[cleaveCount], false, nil, nil)
	VTA_T.SendHideAuraToRaid("gt1")
end

local function eventHandler(self, event, ...)
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2 = select(1, ...)
    local spellId, spellName = select(12, ...)
	
	if type == "SPELL_CAST_START" and spellId == 155080 -- Sliece 155080
	then		
		showCleaveInfosPersonnal()
	end	
	
	if type == "SPELL_CAST_SUCCESS" and spellId == 155080 -- Sliece 155080
	then
		cleaveCount = cleaveCount + 1
		if cleaveCount > 9 then
			cleaveCount = 1
		end			
		refreshCleavelInfos()
	end	
	
end 

function VTA_T.GRUUL.load()
	if isLoaded == false
	then
		if frame == nil then
			frame = CreateFrame("frame", "VTA_T_GRUUL");
			frame:SetScript("OnEvent", eventHandler);
		end		
		frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");	
		isLoaded = true
		print(VTA_T.CHATPREFIX .. bossName .. " begin")
		refreshCleavelInfos()
	end
end

function VTA_T.GRUUL.unload()
	if isLoaded
	then
		frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
		cleaveCount = 1
		isLoaded = false
		print(VTA_T.CHATPREFIX .. bossName .. " ended")
	end
end