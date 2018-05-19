--Neuron , a World of Warcraft® user interface addon.


local NEURON = Neuron
local CDB

NEURON.NeuronZoneAbilityBar = NEURON:NewModule("ZoneAbilityBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronZoneAbilityBar = NEURON.NeuronZoneAbilityBar

local zoneabilitybarsCDB
local zoneabilitybtnsCDB

local BUTTON = NEURON.BUTTON

NEURON.ZONEABILITYRBTN = setmetatable({}, { __index = BUTTON })
local ZONEABILITYRBTN = NEURON.ZONEABILITYRBTN

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local gDef = {
	hidestates = ":",
	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOM",
	x = 350,
	y = 75,
	border = true,
}


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


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronZoneAbilityBar:OnInitialize()

	CDB = NeuronCDB

	zoneabilitybarsCDB = CDB.zoneabilitybars
	zoneabilitybtnsCDB = CDB.zoneabilitybtns

	--create pointers for these functions
	ZONEABILITYRBTN.SetTimer = NEURON.NeuronButton.SetTimer
	ZONEABILITYRBTN.SetSkinned = NEURON.NeuronButton.SetSkinned
	ZONEABILITYRBTN.GetSkinned = NEURON.NeuronButton.GetSkinned

	----------------------------------------------------------------
	ZONEABILITYRBTN.SetData = NeuronZoneAbilityBar.SetData
	ZONEABILITYRBTN.LoadData = NeuronZoneAbilityBar.LoadData
	ZONEABILITYRBTN.SaveData = NeuronZoneAbilityBar.SaveData
	ZONEABILITYRBTN.SetAux = NeuronZoneAbilityBar.SetAux
	ZONEABILITYRBTN.LoadAux = NeuronZoneAbilityBar.LoadAux
	ZONEABILITYRBTN.SetGrid = NeuronZoneAbilityBar.SetGrid
	ZONEABILITYRBTN.SetDefaults = NeuronZoneAbilityBar.SetDefaults
	ZONEABILITYRBTN.GetDefaults = NeuronZoneAbilityBar.GetDefaults
	ZONEABILITYRBTN.SetType = NeuronZoneAbilityBar.SetType
	ZONEABILITYRBTN.GetSkinned = NeuronZoneAbilityBar.GetSkinned
	ZONEABILITYRBTN.SetSkinned = NeuronZoneAbilityBar.SetSkinned
	----------------------------------------------------------------


	NEURON:RegisterBarClass("zoneabilitybar", "ZoneActionBar", L["Zone Action Bar"], "Zone Action Button", zoneabilitybarsCDB, zoneabilitybarsCDB, NeuronZoneAbilityBar, zoneabilitybtnsCDB, "CheckButton", "NeuronActionButtonTemplate", { __index = ZONEABILITYRBTN }, 1, STORAGE, gDef, nil, false)

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

	if (CDB.zoneabilitybarFirstRun) then

		local bar = NEURON.NeuronBar:CreateNewBar("zoneabilitybar", 1, true)
		local object = NEURON.NeuronButton:CreateNewObject("zoneabilitybar", 1)

		NEURON.NeuronBar:AddObjectToList(bar, object)

		CDB.zoneabilitybarFirstRun = false

	else

		for id,data in pairs(zoneabilitybarsCDB) do
			if (data ~= nil) then
				NEURON.NeuronBar:CreateNewBar("zoneabilitybar", id)
			end
		end

		for id,data in pairs(zoneabilitybtnsCDB) do
			if (data ~= nil) then
				NEURON.NeuronButton:CreateNewObject("zoneabilitybar", id)
			end
		end
	end

	STORAGE:Hide()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronZoneAbilityBar:OnEnable()
	self:DisableDefault()


end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronZoneAbilityBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------

function NeuronZoneAbilityBar:DisableDefault()

	local disableZoneAbility = false

	for i,v in ipairs(NEURON.NeuronZoneAbilityBar) do

		if (v["bar"]) then --only disable if a specific button has an associated bar
				disableZoneAbility = true
		end
	end


	if disableZoneAbility then
		------Hiding the default blizzard ZoneAbilityFrame
		ZoneAbilityFrame:UnregisterAllEvents()
		ZoneAbilityFrame:Hide()
	end

end

function NeuronZoneAbilityBar:controlOnUpdate(frame, elapsed)

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
		self.elapsed = 0
	end
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


	if zoneabilitybarsCDB[1].border then

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

	if (start) then
		NEURON.NeuronButton:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end

	self.spellName = self.CurrentSpell;
	self.spellID = spellID;

	if (self.spellName and not InCombatLockdown()) then
		self:SetAttribute("*macrotext1", "/cast " .. self.spellName .. "();")
	end
end



---TODO: This should get roped into AceEvent
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
	--local lastState = self.BuffSeen; --sets a flag to mark if we have seen the change in UNIT_AURA
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
				--GameTooltip_SetDefaultAnchor(GameTooltip, self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
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


function NeuronZoneAbilityBar:SetData(button, bar)
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

	if (button.upClicks) then up = up.."LeftButtonUp" end
	if (button.downClicks) then down = down.."LeftButtonDown" end

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
	button.skincolor = {1,1,1,1,1}
	button:SetFrameLevel(4)
	button.iconframe:SetFrameLevel(2)
	button.iconframecooldown:SetFrameLevel(3)
	--button.iconframeaurawatch:SetFrameLevel(3)
	button.iconframeicon:SetTexCoord(0.05,0.95,0.05,0.95)

	button:GetSkinned(button)


end


function NeuronZoneAbilityBar:GetSkinned(button)

	NEURON.NeuronButton:GetSkinned(button)

end

function NeuronZoneAbilityBar:SetSkinned(button)

	NEURON.NeuronButton:SetSkinned(button)

end


function NeuronZoneAbilityBar:SaveData(button)
	-- empty
end

function NeuronZoneAbilityBar:LoadData(button, spec, state)

	local id = button.id

	button.CDB = zoneabilitybtnsCDB

	if (button.CDB and button.CDB) then

		if (not button.CDB[id]) then
			button.CDB[id] = {}
		end

		if (not button.CDB[id].config) then
			button.CDB[id].config = CopyTable(configData)
		end

		if (not button.CDB[id].keys) then
			button.CDB[id].keys = CopyTable(keyData)
		end

		if (not button.CDB[id]) then
			button.CDB[id] = {}
		end

		if (not button.CDB[id].keys) then
			button.CDB[id].keys = CopyTable(keyData)
		end

		if (not button.CDB[id].data) then
			button.CDB[id].data = {}
		end

		NEURON:UpdateData(button.CDB[id].config, configData)
		NEURON:UpdateData(button.CDB[id].keys, keyData)

		button.config = button.CDB [id].config

		if (CDB.perCharBinds) then
			button.keys = button.CDB[id].keys
		else
			button.keys = button.CDB[id].keys
		end

		button.data = button.CDB[id].data
	end
end

function NeuronZoneAbilityBar:SetGrid(button, show, hide)

	if (true) then return end

	if (not InCombatLockdown()) then

		local texture, name, isActive, isCastable = GetShapeshiftFormInfo(button.id);
		button:SetAttribute("isshown", button.showGrid)
		button:SetAttribute("showgrid", button)

		if (show or button.showGrid) then
			button:Show()
		elseif (not (button:IsMouseOver() and button:IsVisible()) and not texture) then
			button:Hide()
		end
	end
end

function NeuronZoneAbilityBar:SetAux(button)
	NEURON.NeuronButton:SetSkinned(button)
end

function NeuronZoneAbilityBar:LoadAux(button)
	button.spellID = ZoneAbilitySpellID;
	NEURON.NeuronBinder:CreateBindFrame(button, button.objTIndex)
	button.style = button:CreateTexture(nil, "OVERLAY")
	button.style:SetPoint("CENTER", -2, 1)
	button.style:SetWidth(190)
	button.style:SetHeight(95)
	button.hotkey:SetPoint("TOPLEFT", -4, -6)
	button.style:SetTexture("Interface\\ExtraButton\\GarrZoneAbility-Armory")
	button:Hide()
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
	if zoneabilitybarsCDB[1].border then

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

function NeuronZoneAbilityBar:SetType(button, save)

	button:RegisterUnitEvent("UNIT_AURA", "player");
	button:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	button:RegisterEvent("SPELL_UPDATE_USABLE");
	button:RegisterEvent("SPELL_UPDATE_CHARGES");
	button:RegisterEvent("SPELLS_CHANGED");
	button:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	button:RegisterEvent("ZONE_CHANGED")

	button:RegisterEvent("UNIT_SPELLCAST_FAILED")
	--BUTTON.MACRO_UNIT_SPELLCAST_FAILED



	button.actionID = button.id

	button:SetAttribute("type1", "macro")
	button:SetAttribute("*action1", button.actionID)

	button:SetAttribute("useparent-unit", false)
	button:SetAttribute("unit", ATTRIBUTE_NOOP)

	button:SetScript("OnEvent", ZONEABILITYRBTN.OnEvent)
	button:SetScript("OnDragStart", ZONEABILITYRBTN.OnDragStart)
	button:SetScript("OnLoad", ZONEABILITYRBTN.OnLoad)
	button:SetScript("OnShow", ZONEABILITYRBTN.OnShow)
	button:SetScript("OnHide", ZONEABILITYRBTN.OnHide)



	button:SetScript("OnEnter", ZONEABILITYRBTN.OnEnter)
	button:SetScript("OnLeave", ZONEABILITYRBTN.OnLeave)
	button:SetScript("OnUpdate", ZONEABILITYRBTN.OnUpdate)
	button:SetScript("OnAttributeChanged", nil)
end

function NeuronZoneAbilityBar:HideZoneAbilityBorder(bar, msg, gui, checked, query)
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
	NEURON.NeuronBar:Update(bar)
	ZONEABILITYRBTN:UpdateFrame()
end