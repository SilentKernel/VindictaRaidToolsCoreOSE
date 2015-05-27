VTA_T.BLACKHAND = {}
local isLoaded = false
local frame = nil
local bossName = "Blackhand"
local VTA_BH_PHASE = 1
local MARKED_COUNT = 0
local BOMB_COUNT = 0
local SMASH_COUNT = 1

local function refreshSmashlInfos()
	VTA_T.SendAuraToRaid("gt1", true, "Smash : " .. SMASH_COUNT, false, nil, nil)
	if (SMASH_COUNT > 8)
	then
		VTA_T.SendAuraToRaid("gt2", true,  VTA_BH_ROTA_SMASH[1], false, nil, nil)
	else
		VTA_T.SendAuraToRaid("gt2", true,  VTA_BH_ROTA_SMASH[SMASH_COUNT], false, nil, nil)
	end		
end

local function updatePhase()
	local healthPercent = VTA_T.getHealthPercent("boss1")	
	if healthPercent <= 30
	then
		if VTA_BH_PHASE ~= 3
		then
			VTA_BH_PHASE = 3
			VTA_T.SendClearAllToRaid()
		end
	elseif healthPercent <= 70
	then
		if VTA_BH_PHASE ~= 2
		then
			VTA_BH_PHASE = 2
			refreshSmashlInfos();
		end
	end	
end

local function eventHandler(self, event, ...)
    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2 = select(1, ...)
    local spellId, spellName = select(12, ...)
    updatePhase()

   -- if VTA_BH_PHASE == 3 -- Phase 3 --
   -- then
		local position = ""
        if type == "SPELL_AURA_APPLIED"    
        then        
            if spellId == 156096 -- Marked 156096
            then
                MARKED_COUNT = MARKED_COUNT + 1
                if MARKED_COUNT == 1 then
                    position = "Gauche";
                elseif MARKED_COUNT == 2 then
                    position = "Milieu";
                elseif MARKED_COUNT == 3 then
                    position = "Droite";
                end                
                -- SEND Position to DEST
                VTA_T.SendAuraToClient("pt1", destName, true, "Marked : " .. position, true, "say", position .. " Marked for Death")            
            elseif (spellId == 157000) and not VTA_T.IsTank(destName) -- Bomb 157000
            then
                BOMB_COUNT = BOMB_COUNT + 1
                if BOMB_COUNT == 1 then
                    position = "Devant";
                elseif BOMB_COUNT == 2 then
                    position = "Derrière";
                end
                -- SEND Position to DEST
                VTA_T.SendAuraToClient("pt1", destName, true, "Bomb : " .. position, true, "say", position .. " Bomb")            
            end
            
        elseif type == "SPELL_AURA_REMOVED"
        then
            local spellId, spellName = select(12, ...)
            if spellId == 156096 -- Marked 156096
            then
                MARKED_COUNT = 0
                -- Send to the player to remove Weak Aura
                VTA_T.SendHideAuraToClient("pt1", destName)
            elseif (spellId == 157000) and not VTA_T.IsTank(destName) -- Bomb 157000
            then
                BOMB_COUNT = 0            
                -- Send to the player to remove Weak Aura
                VTA_T.SendHideAuraToClient("pt1", destName)
            end
        end
    --end -- End Phase 3 --
    
    if VTA_BH_PHASE == 2 -- phase 2
    then        
        if type == "SPELL_CAST_SUCCESS"
        then
            if spellId == 155992 or spellId == 159142 or spellId == 168766 -- SMASH 155992
            then
                SMASH_COUNT = SMASH_COUNT + 1
                refreshSmashlInfos();
            end
        end
    end -- end phase 2 --
end 

function VTA_T.BLACKHAND.load()
	if isLoaded == false
	then
		if frame == nil then
			frame = CreateFrame("frame", "VTA_T_BLACKHAND");
			frame:SetScript("OnEvent", eventHandler);
		end		
		frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");	
		isLoaded = true
		print(VTA_T.CHATPREFIX .. bossName .. " begin")
	end
end

function VTA_T.BLACKHAND.unload()
	if isLoaded
	then
		frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
		VTA_BH_PHASE = 1
		SMASH_COUNT = 1
		BOMB_COUNT = 0
		MARKED_COUNT = 0
		isLoaded = false
		print(VTA_T.CHATPREFIX .. bossName .. " ended")
	end
end