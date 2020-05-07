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

	if defaults then
		newButton:SetDefaults(defaults)
	end

	newButton:KeybindOverlay_CreateEditFrame()

	return newButton
end


function PETBTN:SetType()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("PET_BAR_UPDATE", "UpdateData")
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", "UpdateCooldown")
	self:RegisterEvent("PET_DISMISS_START", "PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_CONTROL_LOST", "UpdateData")
	self:RegisterEvent("PLAYER_CONTROL_GAINED", "UpdateData")
	self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", "UpdateData")

	if not Neuron.isWoWClassic then
		self:RegisterEvent("PET_SPECIALIZATION_CHANGED", "PLAYER_ENTERING_WORLD")
	end

	self.actionID = self.id

	self:SetAttribute("type1", "pet")
	self:SetAttribute("type2", "macro")
	self:SetAttribute("*action1", self.actionID)

	self:SetAttribute("hotkeypri", self.keys.hotKeyPri)
	self:SetAttribute("hotkeys", self.keys.hotKeys)

	self:SetScript("PostClick", function() self:UpdateData() self:UpdateStatus() end)
	self:SetScript("OnDragStart", function() self:OnDragStart() end)
	self:SetScript("OnReceiveDrag", function() self:OnReceiveDrag() end)
	self:SetScript("OnEnter", function() self:UpdateTooltip() end)
	self:SetScript("OnLeave", function() GameTooltip:Hide() end)

	self:SetScript("OnAttributeChanged", nil)

	self:SetSkinned()
end

function PETBTN:UpdateIcon()
	local _, texture, isToken = GetPetActionInfo(self.actionID)

	self.elements.Name:SetText("")
	self.elements.Count:SetText("")

	if texture then
		if isToken then
			self.elements.IconFrameIcon:SetTexture(_G[texture])
		else
			self.elements.IconFrameIcon:SetTexture(texture)
		end

		self.elements.IconFrameIcon:Show()
	else
		self.elements.IconFrameIcon:SetTexture("")
		self.elements.IconFrameIcon:Hide()
	end
end

function PETBTN:UpdateStatus()
	local _, _, _, isActive, allowed, enabled = GetPetActionInfo(self.actionID)

	if isActive then
		if IsPetAttackAction(self.actionID) then
			self:GetCheckedTexture():SetAlpha(0.5)
		else
			self:GetCheckedTexture():SetAlpha(1.0)
		end

		self:SetChecked(1)
	else
		self:GetCheckedTexture():SetAlpha(1.0)
		self:SetChecked(false)
	end

	if allowed then
		self.elements.AutoCastable:Show()
	else
		self.elements.AutoCastable:Hide()
	end

	if enabled then
		self.elements.Shine:Show()
		AutoCastShine_AutoCastStart(self.elements.Shine)
		self.elements.AutoCastable:Hide()
	else
		self.elements.Shine:Hide()
		AutoCastShine_AutoCastStop(self.elements.Shine)

		if allowed then
			self.elements.AutoCastable:Show()
		end
	end

	self:UpdateUsable()
end


function PETBTN:UpdateCooldown()
	if self.actionID and GetPetActionInfo(self.actionID) then
		local start, duration, enable, modrate = GetPetActionCooldown(self.actionID)
		self:SetCooldownTimer(start, duration, enable, modrate, self.bar:GetShowCooldownText(), self.bar:GetCooldownColor1(), self.bar:GetCooldownColor2(), self.bar:GetShowCooldownAlpha())
	end
end

function PETBTN:UpdateNormalTexture()
	if not self:GetSkinned() then
		if GetPetActionInfo(self.actionID) then
			self:SetNormalTexture(self.hasAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,1)
		else
			self:SetNormalTexture(self.noAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,0.5)
		end
	end
end

function PETBTN:UpdateData()
	local spell = GetPetActionInfo(self.actionID)

	self.spell = spell

	self:UpdateNormalTexture()
	self:UpdateIcon()
	self:UpdateCooldown()


	if not InCombatLockdown() then
		if spell then
			self:SetAttribute("*macrotext2", "/petautocasttoggle "..spell)
		end
	end

	self:UpdateStatus()
end

function PETBTN:UpdateUsable()
	if self.editmode then
		self.elements.IconFrameIcon:SetVertexColor(0.2, 0.2, 0.2)
	elseif self.actionID and GetPetActionSlotUsable(self.actionID) then
		self.elements.IconFrameIcon:SetVertexColor(1.0, 1.0, 1.0)
	else
		self.elements.IconFrameIcon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

function PETBTN:PLAYER_ENTERING_WORLD()
	self:UpdateData()
	self:UpdateUsable()
	self:UpdateIcon()
	self:UpdateStatus()
	self:UpdateNormalTexture()

	self:UpdateObjectVisibility() --have to set true at login or the buttons on the bar don't show

	self:KeybindOverlay_ApplyBindings()
end

function PETBTN:UNIT_PET(event, unit)
	if unit ==  "player" then
		self:UpdateData()
	end
end

function PETBTN:OnDragStart()
	if InCombatLockdown() then
		return
	end

	local drag

	if not self.bar:GetBarLock() then
		drag = true
	elseif self.bar:GetBarLock() == "alt" and IsAltKeyDown() then
		drag = true
	elseif self.bar:GetBarLock() == "ctrl" and IsControlKeyDown() then
		drag = true
	elseif self.bar:GetBarLock() == "shift" and IsShiftKeyDown() then
		drag = true
	else
		drag = false
	end

	if drag then
		self:SetChecked(0)

		PickupPetAction(self.actionID)

		self:UpdateData()
	end

	for i,bar in pairs(Neuron.bars) do
		if bar.class == "pet" then
			bar:UpdateBarObjectVisibility(true)
		end
	end
end


function PETBTN:OnReceiveDrag()
	if InCombatLockdown() then
		return
	end

	local cursorType = GetCursorInfo()

	if cursorType == "petaction" then
		self:SetChecked(0)
		PickupPetAction(self.actionID)
		self:UpdateData()
	end
end


function PETBTN:UpdateTooltip()
	--if we are in combat and we don't have tooltips enable in-combat, don't go any further
	if InCombatLockdown() and not self.bar:GetTooltipCombat() then
		return
	end

	if self.bar:GetTooltipOption() ~= "off" and GetPetActionInfo(self.actionID) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.bar:GetTooltipOption() == "normal" then
			GameTooltip:SetPetAction(self.actionID)
		elseif self.bar:GetTooltipOption() == "minimal" then
			GameTooltip:SetText(self.spell)
		end
		GameTooltip:Show()
	end
end


function PETBTN:UpdateObjectVisibility(show)
	if show or IsPetActive() then
		self.isShown = true
	else
		self.isShown = false
	end

	Neuron.BUTTON.UpdateObjectVisibility(self) --call parent function
end