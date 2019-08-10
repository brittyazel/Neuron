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
--along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2018.

---@class PETBTN : BUTTON @define class PETBTN inherits from class BUTTON
local PETBTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.PETBTN = PETBTN


local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

LibStub("AceEvent-3.0"):Embed(PETBTN)
LibStub("AceTimer-3.0"):Embed(PETBTN)



---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return PETBTN @ A newly created PETBTN object
function PETBTN.new(bar, buttonID, defaults)

	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.BUTTON.new(bar, buttonID, PETBTN, "PetBar", "PetButton", "NeuronActionButtonTemplate")

	if (defaults) then
		newButton:SetDefaults(defaults)
	end

	return newButton
end


-----utilities


function PETBTN.HasPetAction(id)
	if id and GetPetActionInfo(id) then
		return true
	else
		return false
	end
end


-----



function PETBTN:SetType()

	self:RegisterEvent("PET_BAR_UPDATE")
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	self:RegisterEvent("PET_DISMISS_START")
	self:RegisterEvent("PLAYER_CONTROL_LOST")
	self:RegisterEvent("PLAYER_CONTROL_GAINED")
	self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_PET")

	if not Neuron.isWoWClassic then
		self:RegisterEvent("PET_SPECIALIZATION_CHANGED")
	end

	self.actionID = self.id

	self:SetAttribute("type1", "pet")
	self:SetAttribute("type2", "macro")
	self:SetAttribute("*action1", self.actionID)

	self:SetScript("PostClick", function(self) self:PostClick() end)
	self:SetScript("OnDragStart", function(self) self:OnDragStart() end)
	self:SetScript("OnDragStop", function(self) self:OnDragStop() end)
	self:SetScript("OnReceiveDrag", function(self) self:OnReceiveDrag() end)
	self:SetScript("OnEnter", function(self,...) self:OnEnter(...) end)
	self:SetScript("OnLeave", function(self) self:OnLeave() end)

	self:SetScript("OnAttributeChanged", nil)

	self:SetSkinned()

end

function PETBTN:PET_UpdateIcon(spell, texture, isToken)

	self.macroname:SetText("")
	self.count:SetText("")

	if (texture) then
		if (isToken) then
			self.iconframeicon:SetTexture(_G[texture])
			self.tooltipName = _G[spell]
		else
			self.iconframeicon:SetTexture(texture)
			self.tooltipName = spell
		end

		self.iconframeicon:Show()
	else
		self.iconframeicon:SetTexture("")
		self.iconframeicon:Hide()
	end
end

function PETBTN:PET_UpdateState(isActive, allowed, enabled)

	if (isActive) then

		if (IsPetAttackAction(self.actionID)) then
			self:GetCheckedTexture():SetAlpha(0.5)
		else
			self:GetCheckedTexture():SetAlpha(1.0)
		end

		self:SetChecked(1)
	else
		self:GetCheckedTexture():SetAlpha(1.0)
		self:SetChecked(nil)
	end

	if (allowed) then
		self.autocastable:Show()
	else
		self.autocastable:Hide()
	end

	if (enabled) then
		self.shine:Show()
		AutoCastShine_AutoCastStart(self.shine)
		self.autocastable:Hide()

	else
		self.shine:Hide()
		AutoCastShine_AutoCastStop(self.shine)

		if (allowed) then
			self.autocastable:Show()
		end

	end

	self:UpdateButton(self.actionID)
end


function PETBTN:PET_UpdateCooldown()

	local actionID = self.actionID

	if self.HasPetAction(actionID) then

		local start, duration, enable, modrate = GetPetActionCooldown(actionID)

		self:SetCooldownTimer(start, duration, enable, self.cdText, modrate, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end

function PETBTN:PET_UpdateTexture()

	local actionID = self.actionID

	if (not self:GetSkinned()) then

		if (self.HasPetAction(actionID)) then
			self:SetNormalTexture(self.hasAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,1)
		else
			self:SetNormalTexture(self.noAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,0.5)
		end
	end
end

function PETBTN:PET_UpdateOnEvent(state)

	local actionID = self.actionID

	local spell, texture, isToken, isActive, allowed, enabled = GetPetActionInfo(actionID)

	if (not state) then

		self.actionSpell = spell


		if (self.actionSpell and NeuronSpellCache[self.actionSpell:lower()]) then
			self.spellID = NeuronSpellCache[self.actionSpell:lower()].spellID
		else
			self.spellID = nil
		end

		self:PET_UpdateTexture()
		self:PET_UpdateIcon(spell, texture, isToken)
		self:PET_UpdateCooldown()

	end


	if (self.updateRightClick and not InCombatLockdown()) then

		if (spell) then
			self:SetAttribute("*macrotext2", "/petautocasttoggle "..spell)
			self.updateRightClick = nil
		end
	end

	self:PET_UpdateState(isActive, allowed, enabled)

end

function PETBTN:UpdateButton(actionID)

	if (self.editmode) then
		self.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)
	elseif (actionID and GetPetActionSlotUsable(actionID)) then
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	else
		self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end


function PETBTN:PET_BAR_UPDATE(...)
	self:PET_UpdateOnEvent()
end

PETBTN.PLAYER_CONTROL_LOST = PETBTN.PET_BAR_UPDATE
PETBTN.PLAYER_CONTROL_GAINED = PETBTN.PET_BAR_UPDATE
PETBTN.PLAYER_FARSIGHT_FOCUS_CHANGED = PETBTN.PET_BAR_UPDATE

function PETBTN:UNIT_PET(event, ...)
	if (select(1,...) ==  "player") then
		self.updateRightClick = true
		self:PET_UpdateOnEvent()
	end
end



function PETBTN:PET_BAR_UPDATE_COOLDOWN(event, ...)
	self:PET_UpdateCooldown()
end


function PETBTN:PLAYER_ENTERING_WORLD(event, ...)

	self.updateRightClick = true

	self:UpdateAll()

	self:SetObjectVisibility(true) --have to set true at login or the buttons on the bar don't show

	self.binder:ApplyBindings()

	---This part is so that the grid get's set properly on login
	self:ScheduleTimer(function() self.bar:UpdateObjectVisibility() end, 2)

end

PETBTN.PET_SPECIALIZATION_CHANGED = PETBTN.PLAYER_ENTERING_WORLD
PETBTN.PET_DISMISS_START = PETBTN.PLAYER_ENTERING_WORLD




function PETBTN:PostClick()
	self:PET_UpdateOnEvent(true)

end

function PETBTN:OnDragStart()

	if InCombatLockdown() then
		return
	end

	if (not self.barLock) then
		self.drag = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		self.drag = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		self.drag = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		self.drag = true
	end

	if (self.drag) then
		self:SetChecked(0)

		PickupPetAction(self.actionID)

		self:PET_UpdateOnEvent(true)
	end

	for i,bar in pairs(Neuron.BARIndex) do
		if bar.class == "pet" then
			bar:UpdateObjectVisibility(true)
		end
	end
end


function PETBTN:OnDragStop()

end

function PETBTN:OnReceiveDrag()

	if InCombatLockdown() then
		return
	end

	local cursorType = GetCursorInfo()

	if (cursorType == "petaction") then
		self:SetChecked(0)
		PickupPetAction(self.actionID)
		self:PET_UpdateOnEvent(true)
	end

end


function PETBTN:PET_SetTooltip(edit)
	local actionID = self.actionID

	if (self.HasPetAction(actionID)) then
		if (self.UberTooltips) then
			GameTooltip:SetPetAction(actionID)
		else
			GameTooltip:SetText(self.actionSpell)
		end
	end

end


function PETBTN:OnEnter(...)
	if (self.bar) then
		if (self.tooltipsCombat and InCombatLockdown()) then
			return
		end

		if (self.tooltips) then
			if (self.tooltipsEnhanced) then
				self.UberTooltips = true

				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			else
				self.UberTooltips = false
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			end

			self:PET_SetTooltip()

			GameTooltip:Show()
		end
	end
end


function PETBTN:OnLeave()
	GameTooltip:Hide()
end


function PETBTN:SetObjectVisibility(show)

	if show or self.showGrid or self.HasPetAction(self.actionID) or Neuron.buttonEditMode or Neuron.barEditMode or Neuron.bindingMode then
		self:SetAlpha(1)
	else
		self:SetAlpha(0)
	end

end