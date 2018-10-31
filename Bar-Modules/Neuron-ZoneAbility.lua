--Neuron , a World of Warcraft® user interface addon.


local NEURON = Neuron
local DB

NEURON.NeuronZoneAbilityBar = NEURON:NewModule("ZoneAbilityBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronZoneAbilityBar = NEURON.NeuronZoneAbilityBar

local ZONEABILITYBTN = setmetatable({}, { __index = CreateFrame("CheckButton") })

local SKIN = LibStub("Masque", true)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local defaultBarOptions = {
	[1] = {
		hidestates = ":",
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		showGrid = false,
		point = "BOTTOM",
		x = 350,
		y = 75,
		border = true,
	}
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

	DB = NEURON.db.profile

	DB.zoneabilitybar = DB.zoneabilitybar
	DB.zoneabilitybtn = DB.zoneabilitybtn

	--create pointers for these functions
	ZONEABILITYBTN.SetTimer = NEURON.NeuronButton.SetTimer

	----------------------------------------------------------------
	ZONEABILITYBTN.SetData = NeuronZoneAbilityBar.SetData
	ZONEABILITYBTN.LoadData = NeuronZoneAbilityBar.LoadData
	ZONEABILITYBTN.SetAux = NeuronZoneAbilityBar.SetAux
	ZONEABILITYBTN.LoadAux = NeuronZoneAbilityBar.LoadAux
	ZONEABILITYBTN.SetObjectVisibility = NeuronZoneAbilityBar.SetObjectVisibility
	ZONEABILITYBTN.SetDefaults = NeuronZoneAbilityBar.SetDefaults
	ZONEABILITYBTN.GetDefaults = NeuronZoneAbilityBar.GetDefaults
	ZONEABILITYBTN.SetType = NeuronZoneAbilityBar.SetType
	ZONEABILITYBTN.GetSkinned = NeuronZoneAbilityBar.GetSkinned
	ZONEABILITYBTN.SetSkinned = NeuronZoneAbilityBar.SetSkinned
	----------------------------------------------------------------


	NEURON:RegisterBarClass("zoneabilitybar", "ZoneActionBar", L["Zone Action Bar"], "Zone Action Button", DB.zoneabilitybar, NeuronZoneAbilityBar, DB.zoneabilitybtn, "CheckButton", "NeuronActionButtonTemplate", { __index = ZONEABILITYBTN }, 1, false)

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

	NeuronZoneAbilityBar:CreateBarsAndButtons()

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

function NeuronZoneAbilityBar:CreateBarsAndButtons()

	if (DB.zoneabilitybarFirstRun) then

		for id, defaults in ipairs(defaultBarOptions) do

			local bar = NEURON.NeuronBar:CreateNewBar("zoneabilitybar", id, true) --this calls the bar constructor

			for	k,v in pairs(defaults) do
				bar.data[k] = v
			end

			local object

			object = NEURON.NeuronButton:CreateNewObject("zoneabilitybar", 1, true)
			NEURON.NeuronBar:AddObjectToList(bar, object)
		end

		DB.zoneabilitybarFirstRun = false

	else

		for id,data in pairs(DB.zoneabilitybar) do
			if (data ~= nil) then
				NEURON.NeuronBar:CreateNewBar("zoneabilitybar", id)
			end
		end

		for id,data in pairs(DB.zoneabilitybtn) do
			if (data ~= nil) then
				NEURON.NeuronButton:CreateNewObject("zoneabilitybar", id)
			end
		end
	end

end


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

	if (button.elapsed > DB.throttle) then

		NeuronZoneAbilityBar:STANCE_UpdateButton(button, button.actionID)

		button.elapsed = 0
	end

end

function NeuronZoneAbilityBar:SetNeuronButtonTex(button)

	local _, _, _, _, _, _, spellID = GetSpellInfo(button.baseName);

	local texture = ZONE_SPELL_ABILITY_TEXTURES_BASE[spellID] or ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK
	button.style:SetTexture(texture)
end


function NeuronZoneAbilityBar:ZoneAbilityFrame_Update(button)

	if (not button.baseName) then
		return;
	end

	local name, _, tex, _, _, _, spellID = GetSpellInfo(button.baseName);

	button.CurrentTexture = tex;
	button.CurrentSpell = name;
	button.iconframeicon:SetTexture(tex);
	NeuronZoneAbilityBar:SetNeuronButtonTex(button)


	if DB.zoneabilitybar[1].border then
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



function NeuronZoneAbilityBar:PLAYER_ENTERING_WORLD(button, event, ...)
	if InCombatLockdown() then return end
	NEURON.NeuronBinder:ApplyBindings(button)
end



---TODO: This should get roped into AceEvent
function NeuronZoneAbilityBar:OnEvent(button, event, ...)

	local spellID, spellType = GetZoneAbilitySpellInfo();

	button.baseName = GetSpellInfo(spellID);
	ZoneAbilitySpellID = spellID

	if event == "PLAYER_ENTERING_WORLD" then
		NeuronZoneAbilityBar:PLAYER_ENTERING_WORLD(button, event, ...)
	end


	if (spellID) then

		if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY) and garrisonType == LE_GARRISON_TYPE_6_0 ) then
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY, true );
		end

		NeuronZoneAbilityBar:ZoneAbilityFrame_Update(button);

		if (not InCombatLockdown()) then
			button:Show();
		end
	end

	button.spellID = spellID;
	button:SetObjectVisibility(button)
end


function NeuronZoneAbilityBar:SetTooltip(button)
	if (GetSpellInfo(ZoneAbilitySpellID)) then
		if (button.UberTooltips) then
			GameTooltip:SetSpellByID(button.spellID)
		else
			GameTooltip:SetText(button.tooltipName)
		end
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
	NEURON.NeuronButton:SetData(button, bar)
end


function NeuronZoneAbilityBar:GetSkinned(button)
	NEURON.NeuronButton:GetSkinned(button)
end

function NeuronZoneAbilityBar:SetSkinned(button)
	if (SKIN) then

		local bar = button.bar

		if (bar) then

			local btnData = {
				Normal = button.normaltexture,
				Icon = button.iconframeicon,
				Cooldown = button.iconframecooldown,
				HotKey = button.hotkey,
				Count = button.count,
				Name = button.name,
				Border = button.border,
				AutoCast = false,
			}

			SKIN:Group("Neuron", bar.data.name):AddButton(button, btnData)

		end

	end
end


function NeuronZoneAbilityBar:LoadData(button, spec, state)

	local id = button.id

	if not DB.zoneabilitybtn[id] then
		DB.zoneabilitybtn[id] = {}
	end

	button.DB = DB.zoneabilitybtn[id]

	button.config = button.DB.config
	button.keys = button.DB.keys
	button.data = button.DB.data
end

function NeuronZoneAbilityBar:SetObjectVisibility(button, show)
	
	if (GetZoneAbilitySpellInfo() or show) then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		button:SetAlpha(1)
	elseif not NEURON.ButtonEditMode and not NEURON.BarEditMode and not NEURON.BindingMode then
		button:SetAlpha(0)
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
	if DB.zoneabilitybar[1].border then

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

	button:RegisterUnitEvent("UNIT_AURA", "player")
	button:RegisterEvent("SPELLS_CHANGED")
	button:RegisterEvent("ZONE_CHANGED")
	button:RegisterEvent("PLAYER_ENTERING_WORLD")


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

	NeuronZoneAbilityBar:SetObjectVisibility(button)
end

function NeuronZoneAbilityBar:HideZoneAbilityBorder(bar, msg, gui, checked, query)
	if (query) then
		return NEURON.CurrentBar.data.border
	end

	if (gui) then

		if (checked) then
			NEURON.CurrentBar.data.border = true
		else
			NEURON.CurrentBar.data.border = false
		end

	else

		local toggle = NEURON.CurrentBar.data.border

		if (toggle) then
			NEURON.CurrentBar.data.border = false
		else
			NEURON.CurrentBar.data.border = true
		end
	end

	NEURON.NeuronBar:Update(bar)
	NeuronZoneAbilityBar:UpdateFrame()
end