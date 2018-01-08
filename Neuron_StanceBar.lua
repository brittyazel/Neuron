--Neuron , a World of Warcraft® user interface addon.


local NEURON = Neuron
local GDB, CDB, PEW

NEURON.SBTNIndex = {}

local SBTNIndex = NEURON.SBTNIndex


local sbarsGDB, sbarsCDB, sbtnsGDB, sbtnsCDB

local BUTTON = NEURON.BUTTON

local SBTN = setmetatable({}, { __index = CreateFrame("CheckButton") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local	SKIN = LibStub("Masque", true)

local sIndex = NEURON.sIndex

local gDef = {
	hidestates = ":",
	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOM",
	x = 0,
	y = 145,
}


local GetParentKeys = NEURON.GetParentKeys


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


--Do Need?
local function HasAction(id, icon)

	local texture, _, _, _ = GetShapeshiftFormInfo(id)

	--if (GetPetActionSlotUsable(id)) then
	--
	--if (texture) then
	--return true
	--else
	--	return false
	--end
	--else

	if (icon and texture) then
		return true
	else
		return false
	end
	--end
end


--Useds
function SBTN:STANCE_UpdateIcon(spell, subtext, texture, isToken)
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

--used
function SBTN:STANCE_UpdateCooldown()

	local i = self.actionID
	local numForms = GetNumShapeshiftForms();
	local texture, name, isActive, isCastable, spell, spellID;
	local button, icon, cooldown;
	local start, duration, enable;
	local _ --place to hold unwanted return values
	local display = false

	if ( i <= numForms ) then
		texture, spell, isActive, isCastable = GetShapeshiftFormInfo(i);
		_, _, _, _, _, _, spellID = GetSpellInfo(spell)

		start, duration, enable = GetShapeshiftFormCooldown(i);

		if ( isActive ) then
			self:SetChecked(true);
		else
			self:SetChecked(false);
		end

		if (duration and duration >= NeuronGDB.timerLimit and self.iconframeaurawatch.active) then
			self.auraQueue = self.iconframeaurawatch.queueinfo
			self.iconframeaurawatch.duration = 0
			self.iconframeaurawatch:Hide()
		end

		self:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)

		if (not state) then
			self.spellID = spellID
			self.actionSpell = spell

			self:STANCE_UpdateTexture()
			self:STANCE_UpdateIcon(spell, nil, texture, false)
		end
		display = true

	else
		display = false
	end

	if (not InCombatLockdown()) then
		if display then
			self:Show();
		else
			self:Hide();
		end
	end
end


--- Updates button's texture
--@pram: force - (boolean) will force a texture update
function SBTN:STANCE_UpdateTexture(force)

	local actionID = self.actionID

	if (not self:GetSkinned()) then

		if (HasAction(actionID, true) or force) then
			self:SetNormalTexture(self.hasAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,1)
		else
			self:SetNormalTexture(self.noAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,0.5)
		end
	end
end

--- Updates button's texture
--@pram: force - (boolean) will force a texture update

--UPDATE?
function SBTN:STANCE_UpdateButton(actionID)

	if (self.editmode) then
		self.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)
	elseif (GetPetActionSlotUsable(actionID)) then
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	else
		self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

function SBTN:OnUpdate(elapsed)
	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > NeuronGDB.throttle) then
		self:STANCE_UpdateButton(self.actionID)
	end

	if (not InCombatLockdown()) then
		local _,spell = GetShapeshiftFormInfo(self.actionID)

		if (spell) then
			self:SetAttribute("*macrotext1", "/cast "..spell.."()")
		end
	end
end


function SBTN:UPDATE_SHAPESHIFT_COOLDOWN(event, ...)
	self:STANCE_UpdateCooldown()
end


SBTN.UPDATE_SHAPESHIFT_FORM = SBTN.UPDATE_SHAPESHIFT_COOLDOWN
SBTN.UPDATE_SHAPESHIFT_USABLE = SBTN.UPDATE_SHAPESHIFT_COOLDOWN
SBTN.UPDATE_SHAPESHIFT_FORMS = SBTN.UPDATE_SHAPESHIFT_COOLDOWN

function SBTN:PLAYER_ENTERING_WORLD(event, ...)
	self.binder:ApplyBindings(self)
	self.updateRightClick = false
	self:STANCE_UpdateCooldown()
end


SBTN.STANCE_SPECIALIZATION_CHANGED = SBTN.PLAYER_ENTERING_WORLD

function SBTN:STANCE_OnEvent(event, ...)
	if (SBTN[event]) then
		SBTN[event](self, event, ...)
	end
end


function SBTN:STANCE_SetTooltip()
	local actionID = self.actionID

	if (HasAction(actionID, true)) then
		if (self.UberTooltips) then
			GameTooltip:SetSpellByID(self.spellID)
		else
			GameTooltip:SetText(self.tooltipName)
		end

		if (not edit) then
			self.UpdateTooltip = self.STANCE_SetTooltip
		end
	elseif (edit) then
		GameTooltip:SetText(L["Empty Button"])
	end

end


function SBTN:OnEnter(...)
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

			self:STANCE_SetTooltip()

			GameTooltip:Show()
		end
	end
end

function SBTN:SetData(bar)

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

	if (self.upClicks) then up = up.."LeftButtonUp" end
	if (self.downClicks) then down = down.."LeftButtonDown" end

	self:RegisterForClicks(down, up)

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

function SBTN:SaveData()
	-- empty
end

function SBTN:LoadData(spec, state)

	local id = self.id

	self.GDB = sbtnsGDB
	self.CDB = sbtnsCDB

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

function SBTN:SetGrid(show, hide)

	if (true) then return end

	if (not InCombatLockdown()) then

		local texture, name, isActive, isCastable = GetShapeshiftFormInfo(self.id);
		self:SetAttribute("isshown", self.showGrid)
		self:SetAttribute("showgrid", show)

		if (show or self.showGrid) then
			self:Show()
		elseif (not (self:IsMouseOver() and self:IsVisible()) and not texture) then
			self:Hide()
		end
	end
end

function SBTN:SetAux()
	self:SetSkinned()
end

function SBTN:LoadAux()
	self:CreateBindFrame(self.objTIndex)
end

function SBTN:SetDefaults()
	-- empty
end

function SBTN:GetDefaults()
	--empty
end

function SBTN:SetType(save)
	self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
	self.bar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	self.bar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
	self.bar:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")

	self:RegisterEvent("PLAYER_CONTROL_LOST")
	self:RegisterEvent("PLAYER_CONTROL_GAINED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self.actionID = self.id

	self:SetAttribute("type1", "macro")
	self:SetAttribute("*action1", self.actionID)

	self:SetAttribute("useparent-unit", false)
	self:SetAttribute("unit", ATTRIBUTE_NOOP)

	self:SetScript("OnEvent", SBTN.STANCE_OnEvent)
	self:SetScript("OnEnter", SBTN.OnEnter)
	self:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self:SetScript("OnUpdate", SBTN.OnUpdate)
	self:SetScript("OnAttributeChanged", nil)
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Neuron") then

		GDB = NeuronGDB; CDB = NeuronCDB

		sbarsGDB = GDB.sbars
		sbarsCDB = CDB.sbars

		sbtnsGDB = GDB.sbtns
		sbtnsCDB = CDB.sbtns

		SBTN.SetTimer = BUTTON.SetTimer
		SBTN.SetSkinned = BUTTON.SetSkinned
		SBTN.GetSkinned = BUTTON.GetSkinned
		SBTN.CreateBindFrame = BUTTON.CreateBindFrame

		NEURON:RegisterBarClass("stancebar", "StanceBar", L["Stance Bar"], "Stance Button", sbarsGDB, sbarsCDB, SBTNIndex, sbtnsGDB, "CheckButton", "NeuronStanceButtonTemplate", { __index = SBTN }, NEURON.maxStanceID, false, STORAGE, gDef, nil, false)

		NEURON:RegisterGUIOptions("stancebar", {
			AUTOHIDE = true,
			SHOWGRID = true,
			SNAPTO = true,
			UPCLICKS = true,
			DOWNCLICKS = true,
			HIDDEN = true,
			LOCKBAR = false,
			TOOLTIPS = true,
			BINDTEXT = true,
			RANGEIND = false,
			CDTEXT = true,
			CDALPHA = true }, false, 65)

		if (GDB.sbarFirstRun) then

			local bar, object = NEURON:CreateNewBar("stancebar", 1, true)

			for i=1,NEURON.maxStanceID do
				object = NEURON:CreateNewObject("stancebar", i)
				bar:AddObjectToList(object)
			end

			GDB.sbarFirstRun = false

		else

			for id,data in pairs(sbarsGDB) do
				if (data ~= nil) then
					NEURON:CreateNewBar("stancebar", id)
				end
			end

			for id,data in pairs(sbtnsGDB) do
				if (data ~= nil) then
					NEURON:CreateNewObject("stancebar", id)
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