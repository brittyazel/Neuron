--Neuron , a World of Warcraft® user interface addon.


local NEURON = Neuron
local  GDB, CDB, PEW

NEURON.ZONEABILITYRBTNIndex = {}

local ZONEABILITYRBTNIndex = NEURON.ZONEABILITYRBTNIndex


local zoneabilitybarsGDB, zoneabilitybarsCDB, zoneabilitybtnsGDB, zoneabilitybtnsCDB

local BUTTON = NEURON.BUTTON
local BAR = NEURON.BAR

local ZONEABILITYRBTN = setmetatable({}, { __index = CreateFrame("CheckButton") })

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
	y = 226,
	border = true,
}



local GetParentKeys = NEURON.GetParentKeys


local configData = {
	stored = false
}

local keyData = {
	hotKeys = ":",
	hotKeyText = ":",
	hotKeyLock = false,
	hotKeyPri = false,
}

local ZoneAbilitySpellID

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

--- Updates button's texture
--@pram: force - (boolean) will force a texture update

--UPDATE?
function ZONEABILITYRBTN:STANCE_UpdateButton(actionID)
	if (self.editmode) then
		self.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)
	elseif (self.spellName) then
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	else
		self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)

	end
	self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)

end

function ZONEABILITYRBTN:OnUpdate(elapsed)
	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > NeuronGDB.throttle) then
		self:STANCE_UpdateButton(self.actionID)
	end
end


function ZONEABILITYRBTN:PLAYER_ENTERING_WORLD(event, ...)
	self.binder:ApplyBindings(self)
	self.updateRightClick = false
	--self:STANCE_UpdateCooldown()
end


local function ZoneAbilityFrame_Update(self)
	if (not self.baseName) then
		return;
	end
	local name, _, tex, _, _, _, spellID = GetSpellInfo(self.baseName);
	--ZoneSpellAbility = self.baseName

	self.CurrentTexture = tex;
	self.CurrentSpell = name;
	self.style:SetTexture(ZONE_SPELL_ABILITY_TEXTURES_BASE[spellID] or ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK);
	self.iconframeicon:SetTexture(tex);

	--self.SpellButton.Style:SetTexture(ZONE_SPELL_ABILITY_TEXTURES_BASE[spellID] or ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK);
	--self.SpellButton.Icon:SetTexture(tex);


	if zoneabilitybarsGDB[1].border then

		self.style:Show()
	else
		self.style:Hide()
	end


	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID);

	local usesCharges = false;
	if (maxCharges and maxCharges > 1) then
		self.count:SetText(charges);
		usesCharges = true;
	else
		self.count:SetText("");
	end

	local start, duration, enable = GetSpellCooldown(name);

	if (usesCharges and charges < maxCharges) then
		StartChargeCooldown(self, chargeStart, chargeDuration, enable);
	end

	--if (duration and duration >= NeuronGDB.timerLimit and self.iconframeaurawatch.active) then
	--self.auraQueue = self.iconframeaurawatch.queueinfo
	--self.iconframeaurawatch.duration = 0
	--self.iconframeaurawatch:Hide()
	--end
	if (start) then
		--CooldownFrame_SetTimer(self.SpellButton.Cooldown, start, duration, enable);
		self:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end

	self.spellName = self.CurrentSpell;
	self.spellID = spellID;

	if (self.spellName and not InCombatLockdown()) then
		self:SetAttribute("*macrotext1", "/cast " .. self.spellName .. "();")
	end
end



--function that runs whenever any of the below specifid events are registered
function ZONEABILITYRBTN:OnEvent(event, ...)

	local spellID, spellType = GetZoneAbilitySpellInfo();

	if (not InCombatLockdown() and not spellID) then ---should keep the bar hidden when there is no Zone ability available
		self:Hide()
		return
	end


	if (event == "SPELLS_CHANGED" or event=="UNIT_AURA") then
		self.baseName = GetSpellInfo(spellID);
		ZoneAbilitySpellID = spellID
	end


	self.spellID = spellID;
	local lastState = self.BuffSeen; --sets a flag to mark if we have seen the change in UNIT_AURA
	self.BuffSeen = (spellID ~= 0);


	local display

	if (self.BuffSeen) then

		if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY) and garrisonType == LE_GARRISON_TYPE_6_0 ) then
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY, true );
		end

		display = true
		ZoneAbilityFrame_Update(self);
	else
		if (not self.CurrentTexture) then
			self.CurrentTexture = select(3, GetSpellInfo(self.baseName));
		end
		display = false
	end

	if (not InCombatLockdown() and display) then
		self:Show();
	elseif (not InCombatLockdown() and not display) then
		self:Hide();
	end
end


function ZONEABILITYRBTN:SetTooltip()
	if (GetSpellInfo(ZoneAbilitySpellID)) then
		if (self.UberTooltips) then
			GameTooltip:SetSpellByID(self.spellID)
		else
			GameTooltip:SetText(self.tooltipName)
		end

		if (not edit) then
			self.UpdateTooltip = self.SetTooltip
		end
	elseif (edit) then
		GameTooltip:SetText(L["Empty Button"])
	end

end


function ZONEABILITYRBTN:OnEnter(...)

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

			self:SetTooltip()

			GameTooltip:Show()
		end
	end
end


function ZONEABILITYRBTN:OnLeave ()
	GameTooltip:Hide()
end


function ZONEABILITYRBTN:SetData(bar)

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
	self:RegisterForDrag("LeftButton", "RightButton")

	self.cdcolor1 = { 1, 0.82, 0, 1 }
	self.cdcolor2 = { 1, 0.1, 0.1, 1 }
	self.auracolor1 = { 0, 0.82, 0, 1 }
	self.auracolor2 = { 1, 0.1, 0.1, 1 }
	self.buffcolor = { 0, 0.8, 0, 1 }
	self.debuffcolor = { 0.8, 0, 0, 1 }
	self.manacolor = { 0.5, 0.5, 1.0 }
	self.rangecolor = { 0.7, 0.15, 0.15, 1 }
	self.skincolor = {1,1,1,1,1}
	self:SetFrameLevel(4)
	self.iconframe:SetFrameLevel(2)
	self.iconframecooldown:SetFrameLevel(3)
	--self.iconframeaurawatch:SetFrameLevel(3)
	self.iconframeicon:SetTexCoord(0.05,0.95,0.05,0.95)

	self:GetSkinned()


end

function ZONEABILITYRBTN:SaveData()
	-- empty
end

function ZONEABILITYRBTN:LoadData(spec, state)

	local id = self.id

	self.GDB = zoneabilitybtnsGDB
	self.CDB = zoneabilitybtnsCDB

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

function ZONEABILITYRBTN:SetGrid(show, hide)

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

function ZONEABILITYRBTN:SetAux()
	self:SetSkinned()
end

function ZONEABILITYRBTN:LoadAux()
	self.spellID = ZoneAbilitySpellID;
	self:CreateBindFrame(self.objTIndex)
	self.style = self:CreateTexture(nil, "OVERLAY")
	self.style:SetPoint("CENTER", -2, 1)
	self.style:SetWidth(190)
	self.style:SetHeight(95)
	self.hotkey:SetPoint("TOPLEFT", -4, -6)
	self.style:SetTexture("Interface\\ExtraButton\\GarrZoneAbility-Armory")
	self:Hide()
end


function ZONEABILITYRBTN:OnLoad()
	-- empty
end

function ZONEABILITYRBTN:OnShow()
	--ZoneAbilityFrame_Update(self);
end
function ZONEABILITYRBTN:OnHide()

end


function ZONEABILITYRBTN:UpdateFrame()
	if zoneabilitybarsGDB[1].border then

		NeuronZoneActionButton1.style:Show()
	else
		NeuronZoneActionButton1.style:Hide()
	end
	-- empty
end

function ZONEABILITYRBTN:OnDragStart()
	PickupSpell(ZoneAbilitySpellID)
end

function ZONEABILITYRBTN:SetDefaults()
	-- empty
end

function ZONEABILITYRBTN:GetDefaults()
	--empty
end

function ZONEABILITYRBTN:SetType(save)

	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("SPELL_UPDATE_USABLE");
	self:RegisterEvent("SPELL_UPDATE_CHARGES");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
    self:RegisterEvent("ZONE_CHANGED")

	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	--BUTTON.MACRO_UNIT_SPELLCAST_FAILED



	self.actionID = self.id

	self:SetAttribute("type1", "macro")
	self:SetAttribute("*action1", self.actionID)

	self:SetAttribute("useparent-unit", false)
	self:SetAttribute("unit", ATTRIBUTE_NOOP)

	self:SetScript("OnEvent", ZONEABILITYRBTN.OnEvent)
	self:SetScript("OnDragStart", ZONEABILITYRBTN.OnDragStart)
	self:SetScript("OnLoad", ZONEABILITYRBTN.OnLoad)
	self:SetScript("OnShow", ZONEABILITYRBTN.OnShow)
	self:SetScript("OnHide", ZONEABILITYRBTN.OnHide)



	self:SetScript("OnEnter", ZONEABILITYRBTN.OnEnter)
	self:SetScript("OnLeave", ZONEABILITYRBTN.OnLeave)
	self:SetScript("OnUpdate", ZONEABILITYRBTN.OnUpdate)
	self:SetScript("OnAttributeChanged", nil)
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Neuron") then

		--it seems like this code is meant to extract out working copies of the necessary elements form the addon-wide NeuronGDB and NeuronCDB tables
		GDB = NeuronGDB; CDB = NeuronCDB

		zoneabilitybarsGDB = GDB.zoneabilitybars
		zoneabilitybarsCDB = CDB.zoneabilitybars

		zoneabilitybtnsGDB = GDB.zoneabilitybtns
		zoneabilitybtnsCDB = CDB.zoneabilitybtns

		ZONEABILITYRBTN.SetTimer = BUTTON.SetTimer
		ZONEABILITYRBTN.SetSkinned = BUTTON.SetSkinned
		ZONEABILITYRBTN.GetSkinned = BUTTON.GetSkinned
		ZONEABILITYRBTN.CreateBindFrame = BUTTON.CreateBindFrame

		NEURON:RegisterBarClass("zoneabilitybar", "Zone Action Bar", "Zone Action Button", zoneabilitybarsGDB, zoneabilitybarsCDB, ZONEABILITYRBTNIndex, zoneabilitybtnsGDB, "CheckButton", "NeuronActionButtonTemplate", { __index = ZONEABILITYRBTN }, 1, false, STORAGE, gDef, nil, false)

		NEURON:RegisterGUIOptions("zoneabilitybar", { AUTOHIDE = true,
			SHOWGRID = false,
			SNAPTO = true,
			UPCLICKS = true,
			DOWNCLICKS = true,
			HIDDEN = true,
			LOCKBAR = false,
			TOOLTIPS = true,
			BINDTEXT = true,
			RANGEIND = true,
			CDTEXT = true,
			CDALPHA = true,
			ZONEABILITY = true}, false, 65)

		if (GDB.zoneabilitybarFirstRun) then

			local bar = NEURON:CreateNewBar("zoneabilitybar", 1, true)
			local object = NEURON:CreateNewObject("zoneabilitybar", 1)

			bar:AddObjectToList(object)

			GDB.zoneabilitybarFirstRun = false

		else

			for id,data in pairs(zoneabilitybarsGDB) do
				if (data ~= nil) then
					NEURON:CreateNewBar("zoneabilitybar", id)
				end
			end

			for id,data in pairs(zoneabilitybtnsGDB) do
				if (data ~= nil) then
					NEURON:CreateNewObject("zoneabilitybar", id)
				end
			end
		end

		STORAGE:Hide()

	elseif (event == "PLAYER_LOGIN") then

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end


---------------------------------
--This is where the action starts
---------------------------------

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

------Hiding the default blizzard ZoneAbilityFrame
ZoneAbilityFrame:SetScript('OnEvent', nil)
ZoneAbilityFrame:Hide()


function BAR:HideZoneAbilityBorder(msg, gui, checked, query)
	if (query) then
		return Neuron.CurrentBar.gdata.border
	end

	if (gui) then

		if (checked) then
			Neuron.CurrentBar.gdata.border = true
		else
			Neuron.CurrentBar.gdata.border = false
		end

	else

		local toggle = Neuron.CurrentBar.gdata.border

		if (toggle) then
			Neuron.CurrentBar.gdata.border = false
		else
			Neuron.CurrentBar.gdata.border = true
		end
	end
	self:Update()
	ZONEABILITYRBTN:UpdateFrame()
end
