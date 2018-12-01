--Neuron, a World of Warcraft® user interface addon.

---Class PETBTN inherits from class BUTTON
---@class PETBTN : BUTTON
local PETBTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.PETBTN = PETBTN



local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


local sIndex = Neuron.sIndex




---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return BUTTON @ A newly created BUTTON object
function PETBTN:new(name)

	local object = CreateFrame("CheckButton", name, UIParent, "NeuronActionButtonTemplate")

	setmetatable(object, {__index = PETBTN})

	return object
end


-------------------------------------------------
-----Base Methods that all buttons have----------
---These will often be overwritten per bar type--
-------------------------------------------------

function PETBTN:PET_UpdateIcon(spell, texture, isToken)

	self.isToken = isToken

	self.macroname:SetText("")
	self.count:SetText("")

	if (texture) then

		if (isToken) then
			self.iconframeicon:SetTexture(_G[texture])
			self.tooltipName = _G[spell]
			self.tooltipSubtext = _G[spell.."_TOOLTIP"]
		else
			self.iconframeicon:SetTexture(texture)
			self.tooltipName = spell
			self.tooltipSubtext = subtext
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
			self.mac_flash = true
			self:GetCheckedTexture():SetAlpha(0.5)
		else
			self.mac_flash = false
			self:GetCheckedTexture():SetAlpha(1.0)
		end

		self:SetChecked(1)
	else
		self.mac_flash = false
		self:GetCheckedTexture():SetAlpha(1.0)
		self:SetChecked(nil)
	end

	if (allowed) then
		self.autocastable:Show()
	else
		self.autocastable:Hide()
	end

	if (enabled) then

		Neuron:AutoCastStart(self.shine)
		self.autocastable:Hide()
		self.autocastenabled = true

	else
		Neuron:AutoCastStop(self.shine)

		if (allowed) then
			self.autocastable:Show()
		end

		self.autocastenabled = false
	end
end

function PETBTN:PET_UpdateCooldown()

	local DB = Neuron.db.profile

	local actionID = self.actionID

	if (Neuron.NeuronPetBar:HasPetAction(actionID)) then

		local start, duration, enable = GetPetActionCooldown(actionID)

		if (duration and duration >= DB.timerLimit and self.iconframeaurawatch.active) then
			self.auraQueue = self.iconframeaurawatch.queueinfo
			self.iconframeaurawatch.duration = 0
			self.iconframeaurawatch:Hide()
		end

		Neuron:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end

function PETBTN:PET_UpdateTexture(force)

	local actionID = self.actionID

	if (not self:GetSkinned()) then

		if (Neuron.NeuronPetBar:HasPetAction(actionID, true) or force) then
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

		if (isToken) then
			self.actionSpell = _G[spell]
		else
			self.actionSpell = spell
		end

		if (self.actionSpell and sIndex[self.actionSpell:lower()]) then
			self.spellID = sIndex[self.actionSpell:lower()].spellID
		else
			self.spellID = nil
		end

		self:PET_UpdateTexture()
		self:PET_UpdateIcon(spell, texture, isToken)
		self:PET_UpdateCooldown()
	end

	self:PET_UpdateState(isActive, allowed, enabled)

end

function PETBTN:PET_UpdateButton(actionID)

	if (self.editmode) then
		self.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)
	elseif (GetPetActionSlotUsable(actionID)) then
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	else
		self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

function PETBTN:OnUpdate(elapsed)

	local DB = Neuron.db.profile

	if (self.elapsed > DB.throttle) then --throttle down this code to ease up on the CPU a bit
		if (self.mac_flash) then

			self.mac_flashing = true

			if (alphaDir == 1) then
				if ((1-(alphaTimer)) >= 0) then
					self.iconframeflash:Show()
				end
			elseif (alphaDir == 0) then
				if ((alphaTimer) <= 1) then
					self.iconframeflash:Hide()
				end
			end

		elseif (self.mac_flashing) then

			self.iconframeflash:Hide()
			self.mac_flashing = false
		end

		self:PET_UpdateButton(self.actionID)


		if (self.updateRightClick and not InCombatLockdown()) then
			local spell = GetPetActionInfo(self.actionID)

			if (spell) then
				self:SetAttribute("*macrotext2", "/petautocasttoggle "..spell)
				self.updateRightClick = nil
			end
		end


		self.elapsed = 0
	end

	self.elapsed = self.elapsed + elapsed

end


function PETBTN:PET_BAR_UPDATE(event, ...)
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


function PETBTN:UNIT_FLAGS(event, ...)
	if (select(1,...) ==  "pet") then
		self:PET_UpdateOnEvent()
	end
end


PETBTN.UNIT_AURA = PETBTN.UNIT_FLAGS


function PETBTN:PET_BAR_UPDATE_COOLDOWN(event, ...)
	self:PET_UpdateCooldown()
end


function PETBTN:PET_BAR_SHOWGRID(event, ...)
	---This part is so that the grid get's set properly on login
end


function PETBTN:PET_BAR_HIDEGRID(event, ...)
end


function PETBTN:PLAYER_ENTERING_WORLD(event, ...)
	if InCombatLockdown() then return end
	Neuron.NeuronBinder:ApplyBindings(self)
	self.updateRightClick = true
	self:SetObjectVisibility(true) --have to set true at login or the buttons on the bar don't show

	---This part is so that the grid get's set properly on login
	C_Timer.After(2, function() Neuron.NeuronBar:UpdateObjectVisibility(self.bar) end)

end

PETBTN.PET_SPECIALIZATION_CHANGED = PETBTN.PLAYER_ENTERING_WORLD

PETBTN.PET_DISMISS_START = PETBTN.PLAYER_ENTERING_WORLD

function PETBTN:PET_OnEvent(event, ...)

	if (self[event]) then
		self[event](self, event, ...)
	end
end


function PETBTN:PostClick()
	self:PET_UpdateOnEvent(true)

end


function PETBTN:OnDragStart()
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
			Neuron.NeuronBar:UpdateObjectVisibility(bar, true)
		end
	end
end


function PETBTN:OnDragStop()

end

function PETBTN:OnReceiveDrag()
	local cursorType = GetCursorInfo()

	if (cursorType == "petaction") then
		self:SetChecked(0)
		PickupPetAction(self.actionID)
		self:PET_UpdateOnEvent(true)
	end

end


function PETBTN:PET_SetTooltip(edit)
	local actionID = self.actionID

	if (self.isToken) then
		if (self.tooltipName) then
			GameTooltip:SetText(self.tooltipName, 1.0, 1.0, 1.0)
		end

		if (self.tooltipSubtext and self.UberTooltips) then
			GameTooltip:AddLine(self.tooltipSubtext, "", 0.5, 0.5, 0.5)
		end
	elseif (Neuron.NeuronPetBar:HasPetAction(actionID)) then
		if (self.UberTooltips) then
			GameTooltip:SetPetAction(actionID)
		else
			GameTooltip:SetText(self.actionSpell)
		end

		if (not edit) then
			self.UpdateTooltip = self.PET_SetTooltip
		end
	elseif (edit) then
		GameTooltip:SetText(L["Empty Button"])
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


PETBTN.SetSkinned = Neuron.ACTIONBUTTON.SetSkinned
PETBTN.GetSkinned = Neuron.ACTIONBUTTON.GetSkinned



function PETBTN:SetData(bar)

	if (bar) then

		self.bar = bar

		self.cdText = bar.data.cdText

		if (bar.data.cdAlpha) then
			self.cdAlpha = 0.2
		else
			self.cdAlpha = 1
		end

		if (not self.cdcolor1) then
			self.cdcolor1 = { (";"):split(bar.data.cdcolor1) }
		else
			self.cdcolor1[1], self.cdcolor1[2], self.cdcolor1[3], self.cdcolor1[4] = (";"):split(bar.data.cdcolor1)
		end

		if (not self.cdcolor2) then
			self.cdcolor2 = { (";"):split(bar.data.cdcolor2) }
		else
			self.cdcolor2[1], self.cdcolor2[2], self.cdcolor2[3], self.cdcolor2[4] = (";"):split(bar.data.cdcolor2)
		end

		self.showGrid = bar.data.showGrid

		self.barLock = bar.data.barLock
		self.barLockAlt = bar.data.barLockAlt
		self.barLockCtrl = bar.data.barLockCtrl
		self.barLockShift = bar.data.barLockShift

		self.upClicks = bar.data.upClicks
		self.downClicks = bar.data.downClicks

		self.bindText = bar.data.bindText
		self.macroText = bar.data.macroText
		self.countText = bar.data.countText

		self.bindColor = bar.data.bindColor
		self.macroColor = bar.data.macroColor
		self.countColor = bar.data.countColor

		self.tooltips = bar.data.tooltips
		self.tooltipsEnhanced = bar.data.tooltipsEnhanced
		self.tooltipsCombat = bar.data.tooltipsCombat

		self:SetFrameStrata(bar.data.objectStrata)

		self:SetScale(bar.data.scale)

	end

	if (self.bindText) then
		self.hotkey:Show()
		if (self.bindColor) then
			self.hotkey:SetTextColor((";"):split(self.bindColor))
		end
	else
		self.hotkey:Hide()
	end

	if (self.macroText) then
		self.macroname:Show()
		if (self.macroColor) then
			self.macroname:SetTextColor((";"):split(self.macroColor))
		end
	else
		self.macroname:Hide()
	end

	if (self.countText) then
		self.count:Show()
		if (self.countColor) then
			self.count:SetTextColor((";"):split(self.countColor))
		end
	else
		self.count:Hide()
	end

	local down, up = "", ""

	if (self.upClicks) then up = up.."AnyUp" end
	if (self.downClicks) then down = down.."AnyDown" end

	self:RegisterForClicks(down, up)
	self:RegisterForDrag("LeftButton", "RightButton")

	self.auracolor1 = { 0, 0.82, 0, 1 }
	self.auracolor2 = { 1, 0.1, 0.1, 1 }
	self.buffcolor = { 0, 0.8, 0, 1 }
	self.debuffcolor = { 0.8, 0, 0, 1 }
	self.manacolor = { 0.5, 0.5, 1.0 }
	self.rangecolor = { 0.7, 0.15, 0.15, 1 }

	self:SetFrameLevel(4)
	self.iconframe:SetFrameLevel(2)
	self.iconframecooldown:SetFrameLevel(3)
	self.iconframeaurawatch:SetFrameLevel(3)
	self.iconframeicon:SetTexCoord(0.05,0.95,0.05,0.95)

	self:GetSkinned()
end


function PETBTN:LoadData(spec, state)

	local DB = Neuron.db.profile

	local id = self.id

	if not DB.petbtn[id] then
		DB.petbtn[id] = {}
	end

	self.DB = DB.petbtn[id]

	self.config = self.DB.config
	self.keys = self.DB.keys
	self.data = self.DB.data
end

function PETBTN:SetObjectVisibility(show)

	if (show or self.showGrid) then
		self:SetAlpha(1)
	elseif not Neuron.NeuronPetBar:HasPetAction(self.actionID) and (not Neuron.ButtonEditMode and not Neuron.BarEditMode and not Neuron.BindingMode) then
		self:SetAlpha(0)
	end

end


function PETBTN:SetAux()

	self:SetSkinned()

end


function PETBTN:LoadAux()

	Neuron.NeuronBinder:CreateBindFrame(self, self.objTIndex)

end


function PETBTN:SetType(save)

	self:RegisterEvent("PET_BAR_UPDATE")
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	self:RegisterEvent("PET_BAR_SHOWGRID")
	self:RegisterEvent("PET_BAR_HIDEGRID")
	self:RegisterEvent("PET_SPECIALIZATION_CHANGED")
	self:RegisterEvent("PET_DISMISS_START")
	self:RegisterEvent("PLAYER_CONTROL_LOST")
	self:RegisterEvent("PLAYER_CONTROL_GAINED")
	self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_FLAGS")
	self:RegisterEvent("UNIT_AURA")

	self.actionID = self.id

	self:SetAttribute("type1", "pet")
	self:SetAttribute("type2", "macro")
	self:SetAttribute("*action1", self.actionID)

	self:SetAttribute("useparent-unit", false)
	self:SetAttribute("unit", ATTRIBUTE_NOOP)

	self:SetScript("OnEvent", function(self, event, ...) self:PET_OnEvent( event, ...) end)
	self:SetScript("PostClick", function(self) self:PostClick() end)
	self:SetScript("OnDragStart", function(self) self:OnDragStart() end)
	self:SetScript("OnDragStop", function(self) self:OnDragStop() end)
	self:SetScript("OnReceiveDrag", function(self) self:OnReceiveDrag() end)
	self:SetScript("OnEnter", function(self,...) self:OnEnter(...) end)
	self:SetScript("OnLeave", function(self) self:OnLeave() end)
	self:SetScript("OnUpdate", function(self, elapsed) self:OnUpdate(elapsed) end)

	self:SetScript("OnAttributeChanged", nil)

end