--Neuron Pet Action Bar, a World of Warcraft® user interface addon.


local NEURON = Neuron
local DB

NEURON.NeuronPetBar = NEURON:NewModule("PetBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronPetBar = NEURON.NeuronPetBar

local petbarsDB, petbtnsDB

local BUTTON = NEURON.BUTTON

local PETBTN = setmetatable({}, { __index = CreateFrame("CheckButton") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local sIndex = NEURON.sIndex

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

local configData = {

	stored = false,
}

local keyData = {

	hotKeys = ":",
	hotKeyText = ":",
	hotKeyLock = false,
	hotKeyPri = false,
}


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronPetBar:OnInitialize()

	DB = NeuronCDB

	---TODO: Remove this in the future. This is just temp code.
	if (Neuron.db.profile["NeuronPetDB"]) then --migrate old settings to new location
		if(Neuron.db.profile["NeuronPetDB"].petbars) then
			NeuronCDB.petbars = CopyTable(Neuron.db.profile["NeuronPetDB"].petbars)
		end
		if(Neuron.db.profile["NeuronPetDB"].petbtns) then
			NeuronCDB.petbtns = CopyTable(Neuron.db.profile["NeuronPetDB"].petbtns)
		end
		Neuron.db.profile["NeuronPetDB"] = nil
		DB.petbarFirstRun = false
	end


	petbarsDB = DB.petbars
	petbtnsDB = DB.petbtns


	----------------------------------------------------------------
	PETBTN.SetData = NeuronPetBar.SetData
	PETBTN.LoadData = NeuronPetBar.LoadData
	PETBTN.SaveData = NeuronPetBar.SaveData
	PETBTN.SetAux = NeuronPetBar.SetAux
	PETBTN.LoadAux = NeuronPetBar.LoadAux
	PETBTN.SetGrid = NeuronPetBar.SetGrid
	PETBTN.SetDefaults = NeuronPetBar.SetDefaults
	PETBTN.GetDefaults = NeuronPetBar.GetDefaults
	PETBTN.SetType = NeuronPetBar.SetType
	PETBTN.GetSkinned = NeuronPetBar.GetSkinned
	PETBTN.SetSkinned = NeuronPetBar.SetSkinned
	----------------------------------------------------------------

	NEURON:RegisterBarClass("pet", "PetBar", L["Pet Bar"], "Pet Button", petbarsDB, petbarsDB, NeuronPetBar, petbtnsDB, "CheckButton", "NeuronActionButtonTemplate", { __index = PETBTN }, NEURON.maxPetID, STORAGE, gDef, nil, false)

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

	if (DB.petbarFirstRun) then

		local bar, object = NEURON.NeuronBar:CreateNewBar("pet", 1, true)

		for i=1,NEURON.maxPetID do
			object = NEURON.NeuronButton:CreateNewObject("pet", i)
			NEURON.NeuronBar:AddObjectToList(bar, object)
		end

		DB.petbarFirstRun = false

	else

		for id,data in pairs(petbarsDB) do
			if (data ~= nil) then
				NEURON.NeuronBar:CreateNewBar("pet", id)
			end
		end

		for id,data in pairs(petbtnsDB) do
			if (data ~= nil) then
				NEURON.NeuronButton:CreateNewObject("pet", id)
			end
		end
	end

	STORAGE:Hide()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronPetBar:OnEnable()


end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronPetBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------



--this function gets called from the controlOnUpdate in the Neuron.lua file
function NeuronPetBar:controlOnUpdate(frame, elapsed)
	local alphaTimer, alphaDir = 0, 0

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

		NEURON.NeuronButton:AutoCastStart(self.shine)
		self.autocastable:Hide()
		self.autocastenabled = true

	else
		NEURON.NeuronButton:AutoCastStop(self.shine)

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

		NEURON.NeuronButton:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end

function PETBTN:PET_UpdateTexture(force)

	local actionID = self.actionID

	if (not self:GetSkinned(self)) then

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
	NEURON.NeuronBinder:ApplyBindings(self)
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
				--GameTooltip_SetDefaultAnchor(GameTooltip, self)
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


function PETBTN:OnLeave ()
	GameTooltip:Hide()
end


function NeuronPetBar:SetData(button, bar)

	if (bar) then

		button.bar = bar

		button.cdText = bar.cdata.cdText

		if (bar.cdata.cdAlpha) then
			button.cdAlpha = 0.2
		else
			button.cdAlpha = 1
		end

		button.barLock = bar.cdata.barLock
		button.barLockAlt = bar.cdata.barLockAlt
		button.barLockCtrl = bar.cdata.barLockCtrl
		button.barLockShift = bar.cdata.barLockShift

		button.upClicks = bar.cdata.upClicks
		button.downClicks = bar.cdata.downClicks

		button.bindText = bar.cdata.bindText

		button.tooltips = bar.cdata.tooltips
		button.tooltipsEnhanced = bar.cdata.tooltipsEnhanced
		button.tooltipsCombat = bar.cdata.tooltipsCombat

		button:SetFrameStrata(bar.gdata.objectStrata)

		button:SetScale(bar.gdata.scale)

	end

	local down, up = "", ""

	if (button.upClicks) then up = up.."AnyUp" end
	if (button.downClicks) then down = down.."AnyDown" end

	button:RegisterForClicks(down, up)
	button:RegisterForDrag("LeftButton", "RightButton")

	button.cdcolor1 = { 1, 0.82, 0, 1 }
	button.cdcolor2 = { 1, 0.1, 0.1, 1 }
	button.auracolor1 = { 0, 0.82, 0, 1 }
	button.auracolor2 = { 1, 0.1, 0.1, 1 }
	button.buffcolor = { 0, 0.8, 0, 1 }
	button.debuffcolor = { 0.8, 0, 0, 1 }
	button.manacolor = { 0.5, 0.5, 1.0 }
	button.rangecolor = { 0.7, 0.15, 0.15, 1 }

	button:SetFrameLevel(4)
	button.iconframe:SetFrameLevel(2)
	button.iconframecooldown:SetFrameLevel(3)
	button.iconframeaurawatch:SetFrameLevel(3)
	button.iconframeicon:SetTexCoord(0.05,0.95,0.05,0.95)

	button:GetSkinned(button)
end

function NeuronPetBar:SaveData(button)

	-- empty

end

function NeuronPetBar:LoadData(button, spec, state)

	local id = button.id

	button.DB = petbtnsDB

	if (button.DB and button.DB) then

		if (not button.DB[id]) then
			button.DB[id] = {}
		end

		if (not button.DB[id].config) then
			button.DB[id].config = CopyTable(configData)
		end

		if (not button.DB[id].keys) then
			button.DB[id].keys = CopyTable(keyData)
		end

		if (not button.DB[id]) then
			button.DB[id] = {}
		end

		if (not button.DB[id].keys) then
			button.DB[id].keys = CopyTable(keyData)
		end

		if (not button.DB[id].data) then
			button.DB[id].data = {}
		end

		NEURON:UpdateData(button.DB[id].config, configData)
		NEURON:UpdateData(button.DB[id].keys, keyData)

		button.config = button.DB [id].config

		if (DB.perCharBinds) then
			button.keys = button.DB[id].keys
		else
			button.keys = button.DB[id].keys
		end

		button.data = button.DB[id].data
	end
end

function NeuronPetBar:SetGrid(button, show, hide)

	if (true) then return end

	if (not InCombatLockdown()) then

		button:SetAttribute("isshown", button.showGrid)
		button:SetAttribute("showgrid", button)

		if (button or button.showGrid) then
			button:Show()
		elseif (not (button:IsMouseOver() and button:IsVisible()) and not HasPetAction(button.actionID)) then
			button:Hide()
		end
	end
end

function NeuronPetBar:SetAux(button)

	NEURON.NeuronButton:SetSkinned(button)

end

function NeuronPetBar:LoadAux(button)

	NEURON.NeuronBinder:CreateBindFrame(button, button.objTIndex)

end

function NeuronPetBar:SetDefaults(button)

	-- empty

end

function NeuronPetBar:GetDefaults(button)

	--empty

end

function NeuronPetBar:SetSkinned(button)

	NEURON.NeuronButton:SetSkinned(button)

end

function NeuronPetBar:GetSkinned(button)

	NEURON.NeuronButton:GetSkinned(button)

end

function NeuronPetBar:SetType(button, save)

	button:RegisterEvent("PET_BAR_UPDATE")
	button:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	button:RegisterEvent("PET_BAR_SHOWGRID")
	button:RegisterEvent("PET_BAR_HIDEGRID")
	button:RegisterEvent("PET_SPECIALIZATION_CHANGED")
	button:RegisterEvent("PET_DISMISS_START")
	button:RegisterEvent("PLAYER_CONTROL_LOST")
	button:RegisterEvent("PLAYER_CONTROL_GAINED")
	button:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
	button:RegisterEvent("PLAYER_ENTERING_WORLD")
	button:RegisterEvent("UNIT_PET")
	button:RegisterEvent("UNIT_FLAGS")
	button:RegisterEvent("UNIT_AURA")

	button.actionID = button.id

	button:SetAttribute("type1", "pet")
	button:SetAttribute("type2", "macro")
	button:SetAttribute("*action1", button.actionID)

	button:SetAttribute("useparent-unit", false)
	button:SetAttribute("unit", ATTRIBUTE_NOOP)

	button:SetScript("OnEvent", PETBTN.PET_OnEvent)
	button:SetScript("PostClick", PETBTN.PostClick)
	button:SetScript("OnDragStart", PETBTN.OnDragStart)
	button:SetScript("OnReceiveDrag", PETBTN.OnReceiveDrag)
	button:SetScript("OnEnter", PETBTN.OnEnter)
	button:SetScript("OnLeave", PETBTN.OnLeave)
	button:SetScript("OnUpdate", PETBTN.OnUpdate)
	button:SetScript("OnAttributeChanged", nil)

end