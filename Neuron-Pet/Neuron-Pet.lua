--Neuron Pet Action Bar, a World of Warcraft® user interface addon.


local NEURON = Neuron
local DB, PEW

NEURON.PETIndex = {}

local PETIndex = NEURON.PETIndex

local petbarsDB, petbtnsDB

local BUTTON = NEURON.BUTTON

local PETBTN = setmetatable({}, { __index = CreateFrame("CheckButton") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local SKIN = LibStub("Masque", true)

local sIndex = NEURON.sIndex

local defDB = {
	petbars = {},
	petbtns = {},
	firstRun = true,
}

NeuronPetDB = CopyTable(defDB)

NeuronDefaults.profile['NeuronPetDB'] = NeuronPetDB

local gDef = {

	hidestates = ":pet0:",

    scale = 0.8,
	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOM",
	x = -440,
	y = 75,
}

local format = string.format

local GetParentKeys = NEURON.GetParentKeys


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

	if (self.elapsed > NeuronGDB.throttle) then --throttle down this code to ease up on the CPU a bit
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

	self.DB = petbtnsDB

	if (self.DB and self.DB) then

		if (not self.DB[id]) then
			self.DB[id] = {}
		end

		if (not self.DB[id].config) then
			self.DB[id].config = CopyTable(configData)
		end

		if (not self.DB[id].keys) then
			self.DB[id].keys = CopyTable(keyData)
		end

		if (not self.DB[id]) then
			self.DB[id] = {}
		end

		if (not self.DB[id].keys) then
			self.DB[id].keys = CopyTable(keyData)
		end

		if (not self.DB[id].data) then
			self.DB[id].data = {}
		end

		NEURON:UpdateData(self.DB[id].config, configData)
		NEURON:UpdateData(self.DB[id].keys, keyData)

		self.config = self.DB [id].config

		if (DB.perCharBinds) then
			self.keys = self.DB[id].keys
		else
			self.keys = self.DB[id].keys
		end

		self.data = self.DB[id].data
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


function PetProfileUpdate()
    petbarsDB = NeuronPetDB.petbars
    petbtnsDB = NeuronPetDB.petbtns
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Neuron-Pet") then

		PETBTN.SetTimer = BUTTON.SetTimer
		PETBTN.SetSkinned = BUTTON.SetSkinned
		PETBTN.GetSkinned = BUTTON.GetSkinned
		PETBTN.CreateBindFrame = BUTTON.CreateBindFrame


        if (not NeuronBase.db.profile["NeuronPetDB"]) then
            NeuronBase.db.profile["NeuronPetDB"] = NeuronPetDB
        end

		DB = NeuronBase.db.profile["NeuronPetDB"]

		for k,v in pairs(defDB) do
			if (DB[k] == nil) then
				DB[k] = v
			end
		end

		petbarsDB = DB.petbars
		petbtnsDB = DB.petbtns

		NEURON:RegisterBarClass("pet", "PetBar", L["Pet Bar"], "Pet Button", petbarsDB, petbarsDB, PETIndex, petbtnsDB, "CheckButton", "NeuronActionButtonTemplate", { __index = PETBTN }, NEURON.maxPetID, false, STORAGE, gDef, nil, false)

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

		if (DB.firstRun) then

			local bar, object = NEURON:CreateNewBar("pet", 1, true)

			for i=1,NEURON.maxPetID do
				object = NEURON:CreateNewObject("pet", i)
				bar:AddObjectToList(object)
			end

			DB.firstRun = false

		else

			for id,data in pairs(petbarsDB) do
				if (data ~= nil) then
					NEURON:CreateNewBar("pet", id)
				end
			end

			for id,data in pairs(petbtnsDB) do
				if (data ~= nil) then
					NEURON:CreateNewObject("pet", id)
				end
			end
		end

		STORAGE:Hide()

	elseif (event == "PLAYER_LOGIN") then

    elseif (event == "VARIABLES_LOADED") then

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