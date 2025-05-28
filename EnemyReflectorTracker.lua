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
		local elapsed = GetTime() - iconFrame_startTime
		if elapsed >= 5 then
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
function ReflectorCast(reflectorType, spell)
	if(iconFrame:IsShown() ~= nil and string.find(iconTexture:GetTexture(), reflectorSpells[reflectorType].texture) ~=nil and string.find(nameText:GetText(), UnitName("target")) ~= nil) then 
		SpellStopCasting()
	else
		CastSpellByName(spell)
	end
end
