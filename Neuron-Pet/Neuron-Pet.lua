--Neuron Pet Action Bar, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local NEURON, GDB, CDB, PEW = Neuron

NEURON.PETIndex = {}

local PETIndex = NEURON.PETIndex

local petbarsGDB, petbarsCDB, petbtnsGDB, petbtnsCDB

local BUTTON = NEURON.BUTTON

local PETBTN = setmetatable({}, { __index = CreateFrame("CheckButton") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local	SKIN = LibStub("Masque", true)

local sIndex = NEURON.sIndex

NeuronPetGDB = {
	petbars = {},
	petbtns = {},
	firstRun = true,
}

NeuronPetCDB = {
	petbars = {},
	petbtns = {},
}

local gDef = {

	hidestates = ":pet0:",

	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOM",
	x = 0,
	y = 146,
}

local format = string.format

local GetParentKeys = NEURON.GetParentKeys

local defGDB, defCDB = CopyTable(NeuronPetGDB), CopyTable(NeuronPetCDB)

local GetPetActionInfo = _G.GetPetActionInfo
local GetPetActionsUsable = _G.GetPetActionsUsable
local GetPetActionSlotUsable = _G.GetPetActionSlotUsable
local GetPetActionCooldown = _G.GetPetActionCooldown
local AutoCastStart = NEURON.AutoCastStart
local AutoCastStop = NEURON.AutoCastStop

local configData = {

	stored = false,
}

local keyData = {

	hotKeys = ":",
	hotKeyText = ":",
	hotKeyLock = false,
	hotKeyPri = false,
}

local alphaTimer, alphaDir = 0, 0

local function controlOnUpdate(self, elapsed)

	alphaTimer = alphaTimer + elapsed * 2.5

	if (alphaDir == 1) then
		if (1-alphaTimer <= 0) then
			alphaDir = 0; alphaTimer = 0
		end
	else
		if (alphaTimer >= 1) then
			alphaDir = 1; alphaTimer = 0
		end
	end

end

local function HasPetAction(id, icon)

	local _, _, texture = GetPetActionInfo(id)

	if (GetPetActionSlotUsable(id)) then

		if (texture) then
			return true
		else
			return false
		end
	else

		if (icon and texture) then
			return true
		else
			return false
		end
	end
end

function PETBTN:PET_UpdateIcon(spell, subtext, texture, isToken)

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

		AutoCastStart(self.shine)
		self.autocastable:Hide()
		self.autocastenabled = true

	else
		AutoCastStop(self.shine)

		if (allowed) then
			self.autocastable:Show()
		end

		self.autocastenabled = false
	end
end

function PETBTN:PET_UpdateCooldown()

	local actionID = self.actionID

	if (HasPetAction(actionID)) then

		local start, duration, enable = GetPetActionCooldown(actionID)

		if (duration and duration >= NeuronGDB.timerLimit and self.iconframeaurawatch.active) then
			self.auraQueue = self.iconframeaurawatch.queueinfo
			self.iconframeaurawatch.duration = 0
			self.iconframeaurawatch:Hide()
		end

		self:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end

function PETBTN:PET_UpdateTexture(force)

	local actionID = self.actionID

	if (not self:GetSkinned()) then

		if (HasPetAction(actionID, true) or force) then
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

	local spell, subtext, texture, isToken, isActive, allowed, enabled = GetPetActionInfo(actionID)

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
		self:PET_UpdateIcon(spell, subtext, texture, isToken)
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

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > NeuronGDB.throttle) then
		self:PET_UpdateButton(self.actionID)
	end

	if (self.updateRightClick and not InCombatLockdown()) then
		local spell = GetPetActionInfo(self.actionID)

		if (spell) then
			self:SetAttribute("*macrotext2", "/petautocasttoggle "..spell)
			self.updateRightClick = nil
		end
	end
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
	--empty
end


function PETBTN:PET_BAR_HIDEGRID(event, ...)
	--empty
end


function PETBTN:PLAYER_ENTERING_WORLD(event, ...)
	if InCombatLockdown() then return end
	self.binder:ApplyBindings(self)
	self.updateRightClick = true
end


PETBTN.PET_SPECIALIZATION_CHANGED = PETBTN.PLAYER_ENTERING_WORLD

PETBTN.PET_DISMISS_START = PETBTN.PLAYER_ENTERING_WORLD

function PETBTN:PET_OnEvent(event, ...)

	if (PETBTN[event]) then
		PETBTN[event](self, event, ...)
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
end


function PETBTN:OnReceiveDrag()
	local cursorType = GetCursorInfo()

	if (cursorType == "petaction") then
		self:SetChecked(0)
		PickupPetAction(self.actionID)
		self:PET_UpdateOnEvent(true)
	end
end


function PETBTN:PET_SetTooltip()
	local actionID = self.actionID

	if (self.isToken) then
		if (self.tooltipName) then
			GameTooltip:SetText(self.tooltipName, 1.0, 1.0, 1.0)
		end

		if (self.tooltipSubtext and self.UberTooltips) then
			GameTooltip:AddLine(self.tooltipSubtext, "", 0.5, 0.5, 0.5)
		end
	elseif (HasPetAction(actionID)) then
		if (self.UberTooltips) then
			GameTooltip:SetPetAction(actionID)
		else
			GameTooltip:SetText(self.actionSpell)
		end

		if (not edit) then
			self.UpdateTooltip = self.PET_SetTooltip
		end
	elseif (edit) then
		GameTooltip:SetText(L.EMPTY_PETBTN)
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
				GameTooltip_SetDefaultAnchor(GameTooltip, self)
			else
				self.UberTooltips = false
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			end

			self:PET_SetTooltip()

			GameTooltip:Show()
		end
	end
end


function PETBTN:OnLeave ()
	GameTooltip:Hide()
end


function PETBTN:SetData(bar)

	if (bar) then

		self.bar = bar

		self.cdText = bar.cdata.cdText

		if (bar.cdata.cdAlpha) then
			self.cdAlpha = 0.2
		else
			self.cdAlpha = 1
		end

		self.barLock = bar.cdata.barLock
		self.barLockAlt = bar.cdata.barLockAlt
		self.barLockCtrl = bar.cdata.barLockCtrl
		self.barLockShift = bar.cdata.barLockShift

		self.upClicks = bar.cdata.upClicks
		self.downClicks = bar.cdata.downClicks

		self.bindText = bar.cdata.bindText

		self.tooltips = bar.cdata.tooltips
		self.tooltipsEnhanced = bar.cdata.tooltipsEnhanced
		self.tooltipsCombat = bar.cdata.tooltipsCombat

		self:SetFrameStrata(bar.gdata.objectStrata)

		self:SetScale(bar.gdata.scale)

	end

	local down, up = "", ""

	if (self.upClicks) then up = up.."AnyUp" end
	if (self.downClicks) then down = down.."AnyDown" end

	self:RegisterForClicks(down, up)
	self:RegisterForDrag("LeftButton", "RightButton")

	self.cdcolor1 = { 1, 0.82, 0, 1 }
	self.cdcolor2 = { 1, 0.1, 0.1, 1 }
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

function PETBTN:SaveData()

	-- empty

end

function PETBTN:LoadData(spec, state)

	local id = self.id

	self.GDB = petbtnsGDB
	self.CDB = petbtnsCDB

	if (self.GDB and self.CDB) then

		if (not self.GDB[id]) then
			self.GDB[id] = {}
		end

		if (not self.GDB[id].config) then
			self.GDB[id].config = CopyTable(configData)
		end

		if (not self.GDB[id].keys) then
			self.GDB[id].keys = CopyTable(keyData)
		end

		if (not self.CDB[id]) then
			self.CDB[id] = {}
		end

		if (not self.CDB[id].keys) then
			self.CDB[id].keys = CopyTable(keyData)
		end

		if (not self.CDB[id].data) then
			self.CDB[id].data = {}
		end

		NEURON:UpdateData(self.GDB[id].config, configData)
		NEURON:UpdateData(self.GDB[id].keys, keyData)

		self.config = self.GDB [id].config

		if (CDB.perCharBinds) then
			self.keys = self.CDB[id].keys
		else
			self.keys = self.GDB[id].keys
		end

		self.data = self.CDB[id].data
	end
end

function PETBTN:SetGrid(show, hide)

	if (true) then return end

	if (not InCombatLockdown()) then

		self:SetAttribute("isshown", self.showGrid)
		self:SetAttribute("showgrid", show)

		if (show or self.showGrid) then
			self:Show()
		elseif (not (self:IsMouseOver() and self:IsVisible()) and not HasPetAction(self.actionID)) then
			self:Hide()
		end
	end
end

function PETBTN:SetAux()

	self:SetSkinned()

end

function PETBTN:LoadAux()

	self:CreateBindFrame(self.objTIndex)

end

function PETBTN:SetDefaults()

	-- empty

end

function PETBTN:GetDefaults()

	--empty

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

	self:SetScript("OnEvent", PETBTN.PET_OnEvent)
	self:SetScript("PostClick", PETBTN.PostClick)
	self:SetScript("OnDragStart", PETBTN.OnDragStart)
	self:SetScript("OnReceiveDrag", PETBTN.OnReceiveDrag)
	self:SetScript("OnEnter", PETBTN.OnEnter)
	self:SetScript("OnLeave", PETBTN.OnLeave)
	self:SetScript("OnUpdate", PETBTN.OnUpdate)
	self:SetScript("OnAttributeChanged", nil)

end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Neuron-Pet") then

		PETBTN.SetTimer = BUTTON.SetTimer
		PETBTN.SetSkinned = BUTTON.SetSkinned
		PETBTN.GetSkinned = BUTTON.GetSkinned
		PETBTN.CreateBindFrame = BUTTON.CreateBindFrame

		GDB = NeuronPetGDB; CDB = NeuronPetCDB

		for k,v in pairs(defGDB) do
			if (GDB[k] == nil) then
				GDB[k] = v
			end
		end

		for k,v in pairs(defCDB) do
			if (CDB[k] == nil) then
				CDB[k] = v
			end
		end

		petbarsGDB = GDB.petbars
		petbarsCDB = CDB.petbars

		petbtnsGDB = GDB.petbtns
		petbtnsCDB = CDB.petbtns

		NEURON:RegisterBarClass("pet", "Pet Bar", "Pet Button", petbarsGDB, petbarsCDB, PETIndex, petbtnsGDB, "CheckButton", "NeuronActionButtonTemplate", { __index = PETBTN }, NEURON.maxPetID, false, STORAGE, gDef, nil, true)

		NEURON:RegisterGUIOptions("pet", {
			AUTOHIDE = true,
			SHOWGRID = true,
			SNAPTO = true,
			UPCLICKS = true,
			DOWNCLICKS = true,
			HIDDEN = true,
			LOCKBAR = true,
			TOOLTIPS = true,
			BINDTEXT = true,
			RANGEIND = true,
			CDTEXT = true,
			CDALPHA = true }, false, 65)

		if (GDB.firstRun) then

			local bar, object = NEURON:CreateNewBar("pet", 1, true)

			for i=1,NEURON.maxPetID do
				object = NEURON:CreateNewObject("pet", i)
				bar:AddObjectToList(object)
			end

			GDB.firstRun = false

		else

			for id,data in pairs(petbarsGDB) do
				if (data ~= nil) then
					NEURON:CreateNewBar("pet", id)
				end
			end

			for id,data in pairs(petbtnsGDB) do
				if (data ~= nil) then
					NEURON:CreateNewObject("pet", id)
				end
			end
		end

		STORAGE:Hide()

	elseif (event == "PLAYER_LOGIN") then

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")