ReflectorTracker = {}

function ReflectorTracker_OnLoad()
	this:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	-- Create frame for handling events
	ReflectorTrackerFrame = CreateFrame("Frame")
	-- Frame to show the reflector icon
	iconFrame = CreateFrame("Frame", nil, UIParent)
	iconFrame:SetWidth(64)
	iconFrame:SetHeight(64)
	iconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
	iconFrame:Hide()
	-- Frame to show the icon texture
	iconTexture = iconFrame:CreateTexture(nil, "OVERLAY")
	iconTexture:SetAllPoints()
	iconTexture:SetTexture("")  -- will set dynamically

	-- Name text above icon
	nameText = iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	nameText:SetPoint("BOTTOM", iconFrame, "TOP", 0, 4)
	nameText:SetText("")
	
	-- Countdown timer
	iconFrame:SetScript("OnUpdate", function()
		ReflectorTracker_elapsed = GetTime() - iconFrame_startTime
		if ReflectorTracker_elapsed >= 5 then
			iconFrame:Hide()
			nameText:SetText("")
		end
	end)
	DEFAULT_CHAT_FRAME:AddMessage("EnemyReflectorTracker loaded.")
end

function ReflectorTracker_OnEvent(event, arg1, arg2, arg3)
	if (event == "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF" or event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS") then
		for name, data in pairs(reflectorSpells) do
			local playerNameIndex = string.find(arg1, ""..data.effectText)
			local playerName = nil;
			if(playerNameIndex ~= nil) then
				playerName = string.sub(arg1, 1, playerNameIndex - 1)
			end
			if playerName then
				iconTexture:SetTexture(data.texture)
				nameText:SetText(playerName)
				iconFrame_Show()
			end
		end
	end
end

-- Reflector spell effect lookup
reflectorSpells = {
    ["fire"] = {
        effectText = "gains Fire Reflector", -- what shows in combat log
        texture = "Interface\\Icons\\Spell_Fire_FireArmor"
    },
    ["frost"] = {
        effectText = "gains Frost Reflector",
        texture = "Interface\\Icons\\Spell_Frost_FrostWard"
    },
    ["shadow"] = {
        effectText = "gains Shadow Reflector",
        texture = "Interface\\Icons\\Spell_Shadow_AntiShadow"
    }
}

--IconFrame Show
function iconFrame_Show()
	iconFrame_startTime = GetTime()
	iconFrame:Show()
end

--Allows for a shorter macro
function ReflectorCast(reflectorType, spell, options)
	if(options ~= nil) then
		local castTime = options.castTime or nil
	end
	if(iconFrame:IsShown() ~= nil and string.find(iconTexture:GetTexture(), reflectorSpells[reflectorType].texture) ~= nil and string.find(nameText:GetText(), UnitName("target")) ~= nil) then 
		if(castTime ~= nil and CastingBarFrame.casting ~= 1 and CastingBarFrame.channeling ~= 1 and castTime > (5 - ReflectorTracker_elapsed)) then
			CastSpellByName(spell)
		elseif(CastingBarFrame.casting == 1 and not ReflectorTracker_isSpellOnCd(spell) and castTime < (5 - ReflectorTracker_elapsed)) then
			SpellStopCasting()
		end
	else
		CastSpellByName(spell)
	end
end

--Function to determine if spell or ability is on Cooldown, returns true or false. (For experimental mode that checks the cd based on your latency: uncomment the commented lines, and comment out the last return line)
function ReflectorTracker_isSpellOnCd(spell)
	local gameTime = GetTime();
	--local _,_, latency = GetNetStats();
	local subSpell = string.find(spell, "%(");
	local spellTest = spell;
	if(subSpell ~= nil) then 
		subSpell = string.sub(spell, 1, string.find(spell, "%(") - 1);
		spellTest = subSpell;
	end
	local spellId = ReflectorTracker_getSpellId(spellTest);
	local start,duration,_ = GetSpellCooldown(spellId, BOOKTYPE_SPELL);
	local cdT = start + duration - gameTime;
	--latency = latency / 1000;
	--return (duration > latency);
	return (duration ~= 0);
end;

--returns id of a spell from player's spellbook
function ReflectorTracker_getSpellId(spell)
	local i = 1
	while true do
	   local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
	   if not spellName then
		  do break end
	   end
	   if string.find(string.lower(spellName), string.lower(spell)) == 1 then
	   return i; end;
	   i = i + 1
	end
	return nil;
end;
