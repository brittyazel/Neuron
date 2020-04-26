--Neuron, a World of Warcraft® user interface addon.

--This file is part of Neuron.
--
--Neuron is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--Neuron is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with this add-on.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2020.

---@class ZONEABILITYBTN : BUTTON @define class ZONEABILITYBTN inherits from class BUTTON
local ZONEABILITYBTN = setmetatable({}, {__index = Neuron.BUTTON}) --this is the metatable for our button object
Neuron.ZONEABILITYBTN = ZONEABILITYBTN

----------------------------------------------------------

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return ZONEABILITYBTN @ A newly created ZONEABILITYBTN object
function ZONEABILITYBTN.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.BUTTON.new(bar, buttonID, ZONEABILITYBTN, "ZoneAbilityBar", "ZoneActionButton", "NeuronActionButtonTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	return newButton
end

----------------------------------------------------------
function ZONEABILITYBTN:SetType()
	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("SPELLS_CHANGED", "OnEvent")
	self:RegisterEvent("ZONE_CHANGED", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_CHARGES", "OnEvent")

	self:SetAttribute("type1", "macro")

	--macro content gets set in UpdateData
	self:UpdateData()

	self:SetScript("OnDragStart", function(self)
		if self.spellID then
			PickupSpell(self.spellID)
		end
	end)
	self:SetScript("PostClick", function(self) self:UpdateStatus() end)
	self:SetScript("OnEnter", function(self) self:UpdateTooltip() end)
	self:SetScript("OnLeave", GameTooltip_Hide)

	self:SetSkinned()
end

function ZONEABILITYBTN:OnEvent(event, ...)
	self:UpdateData();

	if event == "PLAYER_ENTERING_WORLD" then
		self.binder:ApplyBindings()
		self:UpdateIcon()
	end
end

---overwrite function in parent class BUTTON
function ZONEABILITYBTN:UpdateData()
	--update the ZoneAbility spell ID
	self.spellID = GetZoneAbilitySpellInfo();

	if self.spellID then
		self.spell = GetSpellInfo(self.spellID);
		if self.spell and not InCombatLockdown() then
			self:SetAttribute("macrotext1", "/cast " .. self.spell .. "();")
		end
	else
		self.spell = nil
	end

	self.elements.Name:Hide()

	self:UpdateObjectVisibility()
	self:UpdateIcon()
	self:UpdateCooldown()
	--zone ability button charges (I'm not sure if zone abilities have charges, but this is just in case)
	self:UpdateCount()
	--make sure our button gets the correct Normal texture if we're not using a Masque skin
	self:UpdateNormalTexture()
end

function ZONEABILITYBTN:UpdateObjectVisibility()
	if HasZoneAbility() then
		self.isShown = true
	else
		self.isShown = false
	end

	Neuron.BUTTON.UpdateObjectVisibility(self) --call parent function
end

--overwrite function in parent class BUTTON
function ZONEABILITYBTN:UpdateIcon()
	local spellTexture = GetSpellTexture(self.spellID)
	self.elements.IconFrameIcon:SetTexture(spellTexture);

	local texture = ZONE_SPELL_ABILITY_TEXTURES_BASE[self.spellID] or ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK
	self.elements.Flair:SetTexture(texture)

	if self.bar.data.showBorderStyle then
		self.elements.Flair:Show() --this actually show/hide the fancy button theme surrounding the bar. If you wanted to do a toggle for the style, it should be here.
	else
		self.elements.Flair:Hide()
	end
end

function ZONEABILITYBTN:UpdateTooltip()
	if not self.isShown then
		return
	end

	if self.bar then
		if self.tooltipsCombat and InCombatLockdown() then
			return
		end

		if self.tooltips then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			if self.tooltipsEnhanced and self.spellID then
				GameTooltip:SetSpellByID(self.spellID)
			elseif self.spell then
				GameTooltip:SetText(self.spell)
			end
			GameTooltip:Show()
		end
	end
end