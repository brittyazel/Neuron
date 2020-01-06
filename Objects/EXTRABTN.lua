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
--copyrights for Neuron are held by Britt Yazel, 2017-2019.

---@class EXTRABTN : BUTTON @define class EXTRABTN inherits from class BUTTON
local EXTRABTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.EXTRABTN = EXTRABTN


----------------------------------------------------------

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return EXTRABTN @ A newly created EXTRABTN object
function EXTRABTN.new(bar, buttonID, defaults)

	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.BUTTON.new(bar, buttonID, EXTRABTN, "ExtraBar", "ExtraActionButton", "NeuronActionButtonTemplate")

	if (defaults) then
		newButton:SetDefaults(defaults)
	end

	newButton.style = newButton:CreateTexture(nil, "OVERLAY")
	newButton.style:SetPoint("CENTER", -2, 1)
	newButton.style:SetWidth(190)
	newButton.style:SetHeight(95)

	return newButton
end


----------------------------------------------------------

function EXTRABTN:SetType()

	self:RegisterEvent("UPDATE_EXTRA_ACTIONBAR", "OnEvent")
	self:RegisterEvent("ZONE_CHANGED", "OnEvent")
	self:RegisterEvent("SPELLS_CHANGED", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_CHARGES", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_USABLE", "OnEvent")

	self:SetAttribute("type1", "action")

	--action content gets set in UpdateButton
	self:UpdateButton()
	self:SetObjectVisibility()

	self:SetScript("OnEnter", function(self, ...) self:OnEnter(...) end)
	self:SetScript("OnLeave", GameTooltip_Hide)



	self:SetSkinned()
end


function EXTRABTN:OnEvent(event, ...)

	self:UpdateButton()
	self:SetObjectVisibility()

	if event == "PLAYER_ENTERING_WORLD" then
		self.binder:ApplyBindings()
		self:UpdateIcon()
	end

end

---overwrite function in parent class BUTTON
function EXTRABTN:UpdateButton()

	---default to 169 as is the most of then the case as of 8.1
	self.actionID = 169

	---get specific extrabutton actionID. Try to query it long form, but if it can't will fall back to 169 (as is the 7.0+ default)
	if HasExtraActionBar() then
		local extraPage = GetExtraBarIndex()
		self.actionID = extraPage*12 - 11 --1st slot on the extraPage (page 15 as of 8.1, so 169)
	end

	if not InCombatLockdown() then
		self:SetAttribute("action1", self.actionID)
	end

	_, self.spellID = GetActionInfo(self.actionID)
	self.spellName, _, self.spellIcon = GetSpellInfo(self.spellID);

	if self.spellID then
		self:UpdateIcon()

		self:SetSpellCooldown(self.spellID) --for some reason this doesn't work if you give it self.spellName. The cooldown will be nil

		---extra button charges (some quests have ability charges)
		self:UpdateSpellCount(self.spellID)
	end

	---make sure our button gets the correct Normal texture if we're not using a Masque skin
	self:UpdateNormalTexture()

end


function EXTRABTN:SetObjectVisibility()

	if HasExtraActionBar() or Neuron.buttonEditMode or Neuron.barEditMode or Neuron.bindingMode then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		self.isShown = true
	else
		self.isShown = false
	end

	Neuron.BUTTON.SetObjectVisibility(self) --call parent function

end


---overwrite function in parent class BUTTON
function EXTRABTN:UpdateIcon()
	self:SetButtonTex()
end


function EXTRABTN:SetButtonTex()

	self.iconframeicon:SetTexture(self.spellIcon)

	local texture = GetOverrideBarSkin() or "Interface\\ExtraButton\\Default"
	self.style:SetTexture(texture)

	if self.bar.data.showBorderStyle then
		self.style:Show() --this actually show/hide the fancy button theme surrounding the bar. If you wanted to do a toggle for the style, it should be here.
	else
		self.style:Hide()
	end
end


function EXTRABTN:OnEnter(...)

	if (self.bar) then
		if (self.tooltipsCombat and InCombatLockdown()) then
			return
		end

		if (self.tooltips) then

			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

			if (self.tooltipsEnhanced and self.spellID) then
				GameTooltip:SetSpellByID(self.spellID)
			elseif (self.spellName) then
				GameTooltip:SetText(self.spellName)
			end

			GameTooltip:Show()
		end

	end
end