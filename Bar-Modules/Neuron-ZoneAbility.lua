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


	NEURON:RegisterBarClass("zoneabilitybar", "ZoneActionBar", L["Zone Action Bar"], "Zone Action Button", zoneabilitybarsCDB, zoneabilitybarsCDB, NeuronZoneAbilityBar, zoneabilitybtnsCDB, "CheckButton", "NeuronActionButtonTemplate", { __index = ZONEABILITYRBTN }, 1, gDef, nil, false)

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

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronZoneAbilityBar:OnEnable()
	NeuronZoneAbilityBar:DisableDefault()


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
function NeuronZoneAbilityBar:STANCE_UpdateButton(button, actionID)
	if (button.editmode) then
		button.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)
	elseif (button.spellName) then
		button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	else
		button.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)

	end
	button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)

end

function NeuronZoneAbilityBar:OnUpdate(button, elapsed)
	button.elapsed = button.elapsed + elapsed

	if (button.elapsed > NeuronGDB.throttle) then
		NeuronZoneAbilityBar:STANCE_UpdateButton(button, button.actionID)
		button.elapsed = 0
	end
end


function NeuronZoneAbilityBar:ZoneAbilityFrame_Update(button)
	if (not button.baseName) then
		return;
	end
	local name, _, tex, _, _, _, spellID = GetSpellInfo(button.baseName);
	--ZoneSpellAbility = button.baseName

	button.CurrentTexture = tex;
	button.CurrentSpell = name;
	button.style:SetTexture(ZONE_SPELL_ABILITY_TEXTURES_BASE[spellID] or ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK);
	button.iconframeicon:SetTexture(tex);

	--button.SpellButton.Style:SetTexture(ZONE_SPELL_ABILITY_TEXTURES_BASE[spellID] or ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK);
	--button.SpellButton.Icon:SetTexture(tex);


	if zoneabilitybarsCDB[1].border then

		button.style:Show()
	else
		button.style:Hide()
	end


	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID);

	local usesCharges = false;
	if (maxCharges and maxCharges > 1) then
		button.count:SetText(charges);
		usesCharges = true;
	else
		button.count:SetText("");
	end

	local start, duration, enable = GetSpellCooldown(name);

	if (usesCharges and charges < maxCharges) then
		StartChargeCooldown(button, chargeStart, chargeDuration, enable);
	end

	if (start) then
		NEURON.NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
	end

	button.spellName = button.CurrentSpell;
	button.spellID = spellID;

	if (button.spellName and not InCombatLockdown()) then
		button:SetAttribute("*macrotext1", "/cast " .. button.spellName .. "();")
	end
end



---TODO: This should get roped into AceEvent
function NeuronZoneAbilityBar:OnEvent(button, event, ...)

	local spellID, spellType = GetZoneAbilitySpellInfo();

	if (not InCombatLockdown() and not spellID) then ---should keep the bar hidden when there is no Zone ability available
		button:Hide()
		return
	end


	if (event == "SPELLS_CHANGED" or event=="UNIT_AURA") then
		button.baseName = GetSpellInfo(spellID);
		ZoneAbilitySpellID = spellID
	end


	button.spellID = spellID;
	--local lastState = button.BuffSeen; --sets a flag to mark if we have seen the change in UNIT_AURA
	button.BuffSeen = (spellID ~= 0);


	local display

	if (button.BuffSeen) then

		if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY) and garrisonType == LE_GARRISON_TYPE_6_0 ) then
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY, true );
		end

		display = true
		NeuronZoneAbilityBar:ZoneAbilityFrame_Update(button);
	else
		if (not button.CurrentTexture) then
			button.CurrentTexture = select(3, GetSpellInfo(button.baseName));
		end
		display = false
	end

	if (not InCombatLockdown() and display) then
		button:Show();
	elseif (not InCombatLockdown() and not display) then
		button:Hide();
	end
end


function NeuronZoneAbilityBar:SetTooltip(button)
	if (GetSpellInfo(ZoneAbilitySpellID)) then
		if (button.UberTooltips) then
			GameTooltip:SetSpellByID(button.spellID)
		else
			GameTooltip:SetText(button.tooltipName)
		end

		if (not edit) then
			button.UpdateTooltip = button.SetTooltip
		end
	elseif (edit) then
		GameTooltip:SetText(L["Empty Button"])
	end

end


function NeuronZoneAbilityBar:OnEnter(button, ...)

	if (button.bar) then
		if (button.tooltipsCombat and InCombatLockdown()) then
			return
		end
		if (button.tooltips) then
			if (button.tooltipsEnhanced) then
				button.UberTooltips = true
				--GameTooltip_SetDefaultAnchor(GameTooltip, button)
				GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			else
				button.UberTooltips = false
				GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			end

			NeuronZoneAbilityBar:SetTooltip(button)

			GameTooltip:Show()
		end
	end
end


function NeuronZoneAbilityBar:OnLeave(button)
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

		local texture, isActive, isCastable = GetShapeshiftFormInfo(button.id);
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


function NeuronZoneAbilityBar:OnLoad(button)
	-- empty
end

function NeuronZoneAbilityBar:OnShow(button)
	NeuronZoneAbilityBar:ZoneAbilityFrame_Update(button);
end

function NeuronZoneAbilityBar:OnHide(button)

end


function NeuronZoneAbilityBar:UpdateFrame(button)
	if zoneabilitybarsCDB[1].border then

		NeuronZoneActionButton1.style:Show()
	else
		NeuronZoneActionButton1.style:Hide()
	end
	-- empty
end

function NeuronZoneAbilityBar:OnDragStart(button)
	PickupSpell(ZoneAbilitySpellID)
end

function NeuronZoneAbilityBar:SetDefaults(button)
	-- empty
end

function NeuronZoneAbilityBar:GetDefaults(button)
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

	button:SetScript("OnEvent", function(self, event, ...) NeuronZoneAbilityBar:OnEvent(self, event, ...) end)
	button:SetScript("OnDragStart", function(self) NeuronZoneAbilityBar:OnDragStart(self) end)
	button:SetScript("OnLoad", function(self) NeuronZoneAbilityBar:OnLoad(self) end)
	button:SetScript("OnShow", function(self) NeuronZoneAbilityBar:OnShow(self) end)
	button:SetScript("OnHide", function(self) NeuronZoneAbilityBar:OnHide(self) end)
	button:SetScript("OnEnter", function(self, ...) NeuronZoneAbilityBar:OnEnter(self, ...) end)
	button:SetScript("OnLeave", function(self) NeuronZoneAbilityBar:OnLeave(self) end)
	button:SetScript("OnUpdate", function(self, elapsed) NeuronZoneAbilityBar:OnUpdate(self, elapsed) end)
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
	NeuronZoneAbilityBar:UpdateFrame()
end