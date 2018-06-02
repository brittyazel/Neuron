--Neuron Pet Action Bar, a World of Warcraft® user interface addon.


local NEURON = Neuron
local DB

NEURON.NeuronPetBar = NEURON:NewModule("PetBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronPetBar = NEURON.NeuronPetBar

local petbarsDB, petbtnsDB

local BUTTON = NEURON.BUTTON


NEURON.PETBTN = setmetatable({}, { __index = CreateFrame("CheckButton") })
local PETBTN = NEURON.PETBTN

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

	NEURON:RegisterBarClass("pet", "PetBar", L["Pet Bar"], "Pet Button", petbarsDB, petbarsDB, NeuronPetBar, petbtnsDB, "CheckButton", "NeuronActionButtonTemplate", { __index = NEURON.PETBTN }, NEURON.maxPetID, gDef, nil, false)

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

function NeuronPetBar:PET_UpdateIcon(button, spell, subtext, texture, isToken)

	button.isToken = isToken

	button.macroname:SetText("")
	button.count:SetText("")

	if (texture) then

		if (isToken) then
			button.iconframeicon:SetTexture(_G[texture])
			button.tooltipName = _G[spell]
			button.tooltipSubtext = _G[spell.."_TOOLTIP"]
		else
			button.iconframeicon:SetTexture(texture)
			button.tooltipName = spell
			button.tooltipSubtext = subtext
		end

		button.iconframeicon:Show()

	else
		button.iconframeicon:SetTexture("")
		button.iconframeicon:Hide()
	end
end

function NeuronPetBar:PET_UpdateState(button, isActive, allowed, enabled)

	if (isActive) then

		if (IsPetAttackAction(button.actionID)) then
			button.mac_flash = true
			button:GetCheckedTexture():SetAlpha(0.5)
		else
			button.mac_flash = false
			button:GetCheckedTexture():SetAlpha(1.0)
		end

		button:SetChecked(1)
	else
		button.mac_flash = false
		button:GetCheckedTexture():SetAlpha(1.0)
		button:SetChecked(nil)
	end

	if (allowed) then
		button.autocastable:Show()
	else
		button.autocastable:Hide()
	end

	if (enabled) then

		NEURON.NeuronButton:AutoCastStart(button.shine)
		button.autocastable:Hide()
		button.autocastenabled = true

	else
		NEURON.NeuronButton:AutoCastStop(button.shine)

		if (allowed) then
			button.autocastable:Show()
		end

		button.autocastenabled = false
	end
end

function NeuronPetBar:PET_UpdateCooldown(button)

	local actionID = button.actionID

	if (HasPetAction(actionID)) then

		local start, duration, enable = GetPetActionCooldown(actionID)

		if (duration and duration >= NeuronGDB.timerLimit and button.iconframeaurawatch.active) then
			button.auraQueue = button.iconframeaurawatch.queueinfo
			button.iconframeaurawatch.duration = 0
			button.iconframeaurawatch:Hide()
		end

		NEURON.NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
	end
end

function NeuronPetBar:PET_UpdateTexture(button, force)

	local actionID = button.actionID

	if (not button:GetSkinned(button)) then

		if (HasPetAction(actionID, true) or force) then
			button:SetNormalTexture(button.hasAction or "")
			button:GetNormalTexture():SetVertexColor(1,1,1,1)
		else
			button:SetNormalTexture(button.noAction or "")
			button:GetNormalTexture():SetVertexColor(1,1,1,0.5)
		end
	end
end

function NeuronPetBar:PET_UpdateOnEvent(button, state)

	local actionID = button.actionID

	local spell, subtext, texture, isToken, isActive, allowed, enabled = GetPetActionInfo(actionID)

	if (not state) then

		if (isToken) then
			button.actionSpell = _G[spell]
		else
			button.actionSpell = spell
		end

		if (button.actionSpell and sIndex[button.actionSpell:lower()]) then
			button.spellID = sIndex[button.actionSpell:lower()].spellID
		else
			button.spellID = nil
		end

		NeuronPetBar:PET_UpdateTexture(button)
		NeuronPetBar:PET_UpdateIcon(button, spell, subtext, texture, isToken)
		NeuronPetBar:PET_UpdateCooldown(button)
	end

	NeuronPetBar:PET_UpdateState(button, isActive, allowed, enabled)

end

function NeuronPetBar:PET_UpdateButton(button, actionID)

	if (button.editmode) then
		button.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)
	elseif (GetPetActionSlotUsable(actionID)) then
		button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	else
		button.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

function NeuronPetBar:OnUpdate(button, elapsed)

	if (button.elapsed > NeuronGDB.throttle) then --throttle down this code to ease up on the CPU a bit
		if (button.mac_flash) then

			button.mac_flashing = true

			if (alphaDir == 1) then
				if ((1-(alphaTimer)) >= 0) then
					button.iconframeflash:Show()
				end
			elseif (alphaDir == 0) then
				if ((alphaTimer) <= 1) then
					button.iconframeflash:Hide()
				end
			end

		elseif (button.mac_flashing) then

			button.iconframeflash:Hide()
			button.mac_flashing = false
		end

		NeuronPetBar:PET_UpdateButton(button, button.actionID)

		if (button.updateRightClick and not InCombatLockdown()) then
			local spell = GetPetActionInfo(button.actionID)

			if (spell) then
				button:SetAttribute("*macrotext2", "/petautocasttoggle "..spell)
				button.updateRightClick = nil
			end
		end

		button.elapsed = 0
	end

	button.elapsed = button.elapsed + elapsed
end


function NeuronPetBar:PET_BAR_UPDATE(button, event, ...)
	NeuronPetBar:PET_UpdateOnEvent(button)
end

NeuronPetBar.PLAYER_CONTROL_LOST = NeuronPetBar.PET_BAR_UPDATE
NeuronPetBar.PLAYER_CONTROL_GAINED = NeuronPetBar.PET_BAR_UPDATE
NeuronPetBar.PLAYER_FARSIGHT_FOCUS_CHANGED = NeuronPetBar.PET_BAR_UPDATE

function NeuronPetBar:UNIT_PET(button, event, ...)
	if (select(1,...) ==  "player") then
		button.updateRightClick = true
		NeuronPetBar:PET_UpdateOnEvent(button)
	end
end


function NeuronPetBar:UNIT_FLAGS(button, event, ...)
	if (select(1,...) ==  "pet") then
		NeuronPetBar:PET_UpdateOnEvent(button)
	end
end


NeuronPetBar.UNIT_AURA = NeuronPetBar.UNIT_FLAGS


function NeuronPetBar:PET_BAR_UPDATE_COOLDOWN(button, event, ...)
	NeuronPetBar:PET_UpdateCooldown(button)
end


function NeuronPetBar:PET_BAR_SHOWGRID(button, event, ...)
	--empty
end


function NeuronPetBar:PET_BAR_HIDEGRID(button, event, ...)
	--empty
end


function NeuronPetBar:PLAYER_ENTERING_WORLD(button, event, ...)
	if InCombatLockdown() then return end
	NEURON.NeuronBinder:ApplyBindings(button)
	button.updateRightClick = true
end


NeuronPetBar.PET_SPECIALIZATION_CHANGED = NeuronPetBar.PLAYER_ENTERING_WORLD

NeuronPetBar.PET_DISMISS_START = NeuronPetBar.PLAYER_ENTERING_WORLD

function NeuronPetBar:PET_OnEvent(button, event, ...)

	if (NeuronPetBar[event]) then
		NeuronPetBar[event](NeuronPetBar, button, event, ...)
	end
end


function NeuronPetBar:PostClick(button)
	NeuronPetBar:PET_UpdateOnEvent(button, true)
end


function NeuronPetBar:OnDragStart(button)
	if (not button.barLock) then
		button.drag = true
	elseif (button.barLockAlt and IsAltKeyDown()) then
		button.drag = true
	elseif (button.barLockCtrl and IsControlKeyDown()) then
		button.drag = true
	elseif (button.barLockShift and IsShiftKeyDown()) then
		button.drag = true
	end

	if (button.drag) then
		button:SetChecked(0)

		PickupPetAction(button.actionID)

		NeuronPetBar:PET_UpdateOnEvent(button, true)
	end
end


function NeuronPetBar:OnReceiveDrag(button)
	local cursorType = GetCursorInfo()

	if (cursorType == "petaction") then
		button:SetChecked(0)
		PickupPetAction(button.actionID)
		NeuronPetBar:PET_UpdateOnEvent(button, true)
	end
end


function NeuronPetBar:PET_SetTooltip(button)
	local actionID = button.actionID

	if (button.isToken) then
		if (button.tooltipName) then
			GameTooltip:SetText(button.tooltipName, 1.0, 1.0, 1.0)
		end

		if (button.tooltipSubtext and button.UberTooltips) then
			GameTooltip:AddLine(button.tooltipSubtext, "", 0.5, 0.5, 0.5)
		end
	elseif (HasPetAction(actionID)) then
		if (button.UberTooltips) then
			GameTooltip:SetPetAction(actionID)
		else
			GameTooltip:SetText(button.actionSpell)
		end

		if (not edit) then
			button.UpdateTooltip = button.PET_SetTooltip
		end
	elseif (edit) then
		GameTooltip:SetText(L["Empty Button"])
	end
end


function NeuronPetBar:OnEnter(button, ...)
	if (button.bar) then
		if (button.tooltipsCombat and InCombatLockdown()) then
			return
		end

		if (button.tooltips) then
			if (button.tooltipsEnhanced) then
				button.UberTooltips = true

				GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			else
				button.UberTooltips = false
				GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			end

			NeuronPetBar:PET_SetTooltip(button)

			GameTooltip:Show()
		end
	end
end


function NeuronPetBar:OnLeave(button)
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

	button:SetScript("OnEvent", function(self, event, ...) NeuronPetBar:PET_OnEvent(self, event, ...) end)
	button:SetScript("PostClick", function(self) NeuronPetBar:PostClick(self) end)
	button:SetScript("OnDragStart", function(self) NeuronPetBar:OnDragStart(self) end)
	button:SetScript("OnReceiveDrag", function(self) NeuronPetBar:OnReceiveDrag(self) end)
	button:SetScript("OnEnter", function(self, ...) NeuronPetBar:OnEnter(self, ...) end)
	button:SetScript("OnLeave", function(self) NeuronPetBar:OnLeave(self) end)
	button:SetScript("OnUpdate", function(self, elapsed) NeuronPetBar:OnUpdate(self, elapsed) end)
	button:SetScript("OnAttributeChanged", nil)

end