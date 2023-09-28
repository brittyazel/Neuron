-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2023 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class ZoneAbilityButton : Button @define class ZoneAbilityButton inherits from class Button
local ZoneAbilityButton = setmetatable({}, {__index = Neuron.Button}) --this is the metatable for our button object
Neuron.ZoneAbilityButton = ZoneAbilityButton

----------------------------------------------------------

---Constructor: Create a new Neuron Button object (this is the base object for all Neuron button types)
---@param bar Bar @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return ZoneAbilityButton @ A newly created ZoneAbilityButton object
function ZoneAbilityButton.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.Button.new(bar, buttonID, ZoneAbilityButton, "ZoneAbilityBar", "ZoneActionButton", "NeuronActionButtonTemplate")

	newButton.abilityIndex = buttonID

	if defaults then
		newButton:SetDefaults(defaults)
	end

	return newButton
end

----------------------------------------------------------
function ZoneAbilityButton:InitializeButton()
	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("SPELLS_CHANGED", "OnEvent")
	self:RegisterEvent("ZONE_CHANGED", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_CHARGES", "OnEvent")

	self:SetAttribute("type1", "macro")

	self:SetAttribute("hotkeypri", self.keys.hotKeyPri)
	self:SetAttribute("hotkeys", self.keys.hotKeys)

	self:SetSize(52,52)
	self.Style:SetPoint("CENTER", -1.5, 1)

	--macro content gets set in UpdateData
	self:UpdateData()

	self:SetScript("OnDragStart", function()
		if self.spellID then
			PickupSpell(self.spellID)
		end
	end)
	self:SetScript("PostClick", function() self:UpdateStatus() end)
	self:SetScript("OnEnter", function() self:UpdateTooltip() end)
	self:SetScript("OnLeave", GameTooltip_Hide)

	self:InitializeButtonSettings()
end

function ZoneAbilityButton:InitializeButtonSettings()
	self.bar:SetShowGrid(false)
	self:SetFrameStrata(Neuron.STRATAS[self.bar:GetStrata()-1])
	self:SetSkinned()
end

function ZoneAbilityButton:OnEvent(event, ...)
	self:UpdateData();
	if event == "PLAYER_ENTERING_WORLD" then
		self:ApplyBindings()
		self:UpdateIcon()
	end
end


-----------------------------------------------------
--------------------- Overrides ---------------------
-----------------------------------------------------

--overwrite function in parent class Button
function ZoneAbilityButton:UpdateData()
	--get table with zone ability info. The table has 5 values, "zoneAbilityID", "uiPriority", "spellID", "textureKit", and "tutorialText"
	local zoneAbilityTable = C_ZoneAbility.GetActiveAbilities()

	--TODO: figure out a way to use the fancy texture style even when having multiple zone abilities at once
	self.disableStyle = #zoneAbilityTable > 1

	table.sort(zoneAbilityTable, function(a, b) return a.uiPriority < b.uiPriority end);

	if zoneAbilityTable[self.abilityIndex] then
		self.spellID = zoneAbilityTable[self.abilityIndex].spellID
		self.textureKit = zoneAbilityTable[self.abilityIndex].textureKit
	else
		self.spellID = nil
		self.textureKit = nil
	end

	if self.spellID then
		self.spell = GetSpellInfo(self.spellID);
		if self.spell and not InCombatLockdown() then
			self:SetAttribute("macrotext1", "/cast " .. self.spell .. "();")
		end
	else
		self.spell = nil
	end

	self.Name:Hide()

	self:UpdateVisibility()
	self:UpdateIcon()
	self:UpdateCooldown()
	--zone ability button charges (I'm not sure if zone abilities have charges, but this is just in case)
	self:UpdateCount()
end

--overwrite function in parent class Button
function ZoneAbilityButton:UpdateVisibility()
	if self.spellID then
		self.isShown = true
	else
		self.isShown = false
	end

	Neuron.Button.UpdateVisibility(self) --call parent function
end

--overwrite function in parent class Button
function ZoneAbilityButton:UpdateIcon()
	local spellTexture = GetSpellTexture(self.spellID)
	self.Icon:SetTexture(spellTexture);

	local texture = self.textureKit or "Interface\\ExtraButton\\GarrZoneAbility-Armory"

	if C_Texture.GetAtlasInfo(texture) then
		self.Style:SetAtlas(texture, true);
	elseif texture then
		self.Style:SetTexture(texture);
	end

	if not self.disableStyle and self.abilityIndex == 1 and self.bar:GetShowBorderStyle() then
		self.Style:Show() --this actually show/hide the fancy button theme surrounding the bar. If you wanted to do a toggle for the style, it should be here.
	else
		self.Style:Hide()
	end
	--make sure our button gets the correct Normal texture if we're not using a Masque skin
	self:UpdateNormalTexture()
end

--overwrite function in parent class Button
function ZoneAbilityButton:UpdateTooltip()
	if not self.isShown then
		return
	end

	--if we are in combat and we don't have tooltips enable in-combat, don't go any further
	if InCombatLockdown() and not self.bar:GetTooltipCombat() then
		return
	end

	if self.bar:GetTooltipOption() ~= "off" then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.bar:GetTooltipOption() == "normal" and self.spellID then
			GameTooltip:SetSpellByID(self.spellID)
		elseif self.bar:GetTooltipOption() == "minimal" and self.spell then
			GameTooltip:SetText(self.spell)
		end
		GameTooltip:Show()
	end
end
