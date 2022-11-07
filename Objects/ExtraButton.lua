-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class ExtraButton : Button @define class ExtraButton inherits from class Button
local ExtraButton = setmetatable({}, { __index = Neuron.Button })
Neuron.ExtraButton = ExtraButton

----------------------------------------------------------

---Constructor: Create a new Neuron Button object (this is the base object for all Neuron button types)
---@param bar Bar @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return ExtraButton @ A newly created ExtraButton object
function ExtraButton.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.Button.new(bar, buttonID, ExtraButton, "ExtraBar", "ExtraActionButton", "NeuronActionButtonTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	newButton:KeybindOverlay_CreateEditFrame()

	return newButton
end

----------------------------------------------------------

function ExtraButton:InitializeButton()
	self:RegisterEvent("UPDATE_EXTRA_ACTIONBAR", "OnEvent")
	self:RegisterEvent("ZONE_CHANGED", "OnEvent")
	self:RegisterEvent("SPELLS_CHANGED", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_CHARGES", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_USABLE", "OnEvent")

	self:SetAttribute("type1", "action")

	self:SetAttribute("action1", 169) --baseline actionID for most extra actions

	self:SetAttribute("hotkeypri", self.keys.hotKeyPri)
	self:SetAttribute("hotkeys", self.keys.hotKeys)
	self:SetSize(52,52)
	self.Style:SetPoint("CENTER", -2, 0)

	--action content gets set in UpdateData
	self:UpdateData()

	self:SetScript("PostClick", function() self:UpdateStatus() end)
	self:SetScript("OnEnter", function() self:UpdateTooltip() end)
	self:SetScript("OnLeave", GameTooltip_Hide)

	self:InitializeButtonSettings()
end

function ExtraButton:InitializeButtonSettings()
	self.bar:SetShowGrid(false)
	self:SetFrameStrata(Neuron.STRATAS[self.bar:GetStrata()-1])
	self:SetSkinned()
end

function ExtraButton:OnEvent(event, ...)
	self:UpdateData()
	if event == "PLAYER_ENTERING_WORLD" then
		self:KeybindOverlay_ApplyBindings()
		self:UpdateIcon()
	end
end


-----------------------------------------------------
--------------------- Overrides ---------------------
-----------------------------------------------------

--overwrite function in parent class Button
function ExtraButton:UpdateData()
	--get specific extrabutton actionID. Try to query it long form, but if it can't will fall back to 169 (as is the 7.0+ default)
	if HasExtraActionBar() then
		--default to 169 as is the most of then the case as of 8.1
		self.actionID = 169

		local extraPage = GetExtraBarIndex()
		self.actionID = extraPage*12 - 11 --1st slot on the extraPage (page 15 as of 8.1, so 169)

		if not InCombatLockdown() then
			self:SetAttribute("action1", self.actionID)
		end

		_, self.spellID = GetActionInfo(self.actionID)

		if self.spellID then
			self.spell = GetSpellInfo(self.spellID);
		else
			self.spell = nil
		end
	else
		self.actionID = nil
		self.spellID = nil
		self.spell = nil
	end

	-----------------------
	self.Name:Hide()

	self:UpdateVisibility()
	self:UpdateIcon()
	self:UpdateCooldown()
	--extra button charges (some quests have ability charges)
	self:UpdateCount()
end

--overwrite function in parent class Button
function ExtraButton:UpdateVisibility()
	if HasExtraActionBar() then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		self.isShown = true
	else
		self.isShown = false
	end
	Neuron.Button.UpdateVisibility(self) --call parent function
end

--overwrite function in parent class Button
function ExtraButton:UpdateIcon()
	local spellTexture = GetSpellTexture(self.spellID)
	self.Icon:SetTexture(spellTexture)

	local texture = GetOverrideBarSkin() or "Interface\\ExtraButton\\Default"
	self.Style:SetTexture(texture)

	if self.bar:GetShowBorderStyle() then
		self.Style:Show() --this actually show/hide the fancy button theme surrounding the bar. If you wanted to do a toggle for the style, it should be here.
	else
		self.Style:Hide()
	end
	--make sure our button gets the correct Normal texture if we're not using a Masque skin
	self:UpdateNormalTexture()
end

--overwrite function in parent class Button
function ExtraButton:UpdateTooltip()
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