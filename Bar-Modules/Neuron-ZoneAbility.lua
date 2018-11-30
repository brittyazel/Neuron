--Neuron , a World of Warcraft® user interface addon.

local DB

Neuron.NeuronZoneAbilityBar = Neuron:NewModule("ZoneAbilityBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronZoneAbilityBar = Neuron.NeuronZoneAbilityBar


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


---@class ZONEABILITYBTN : BUTTON
local ZONEABILITYBTN = setmetatable({}, { __index = Neuron.BUTTON })

-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronZoneAbilityBar:OnInitialize()

	DB = Neuron.db.profile

	DB.zoneabilitybar = DB.zoneabilitybar
	DB.zoneabilitybtn = DB.zoneabilitybtn


	Neuron:RegisterBarClass("zoneabilitybar", "ZoneActionBar", L["Zone Action Bar"], "Zone Action Button", DB.zoneabilitybar, NeuronZoneAbilityBar, "CheckButton", "NeuronActionButtonTemplate", { __index = ZONEABILITYBTN }, 1)

	Neuron:RegisterGUIOptions("zoneabilitybar", { AUTOHIDE = true,
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

			local bar = Neuron.NeuronBar:CreateNewBar("zoneabilitybar", id, true) --this calls the bar constructor

			for	k,v in pairs(defaults) do
				bar.data[k] = v
			end

			local object

			object = Neuron:CreateNewObject("zoneabilitybar", 1, true)
			Neuron.NeuronBar:AddObjectToList(bar, object)
		end

		DB.zoneabilitybarFirstRun = false

	else

		for id,data in pairs(DB.zoneabilitybar) do
			if (data ~= nil) then
				Neuron.NeuronBar:CreateNewBar("zoneabilitybar", id)
			end
		end

		for id,data in pairs(DB.zoneabilitybtn) do
			if (data ~= nil) then
				Neuron:CreateNewObject("zoneabilitybar", id)
			end
		end
	end

end


function NeuronZoneAbilityBar:DisableDefault()

	local disableZoneAbility = false

	for i,v in ipairs(Neuron.NeuronZoneAbilityBar) do

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
		Neuron:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
	end

	button.spellName = button.CurrentSpell;
	button.spellID = spellID;

	if (button.spellName and not InCombatLockdown()) then
		button:SetAttribute("*macrotext1", "/cast " .. button.spellName .. "();")
	end
end



function NeuronZoneAbilityBar:PLAYER_ENTERING_WORLD(button, event, ...)
	if InCombatLockdown() then return end
	Neuron.NeuronBinder:ApplyBindings(button)
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
	button:SetObjectVisibility()
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


function ZONEABILITYBTN:SetSkinned()
	if (SKIN) then

		local bar = self.bar

		if (bar) then

			local btnData = {
				Normal = self.normaltexture,
				Icon = self.iconframeicon,
				Cooldown = self.iconframecooldown,
				HotKey = self.hotkey,
				Count = self.count,
				Name = self.name,
				Border = self.border,
				AutoCast = false,
			}

			SKIN:Group("Neuron", bar.data.name):AddButton(self, btnData)

		end

	end
end

ZONEABILITYBTN.GetSkinned = Neuron.ACTIONBUTTON.GetSkinned

ZONEABILITYBTN.SetData = Neuron.ACTIONBUTTON.SetData


function ZONEABILITYBTN:LoadData(spec, state)

	local id = self.id

	if not DB.zoneabilitybtn[id] then
		DB.zoneabilitybtn[id] = {}
	end

	self.DB = DB.zoneabilitybtn[id]

	self.config = self.DB.config
	self.keys = self.DB.keys
	self.data = self.DB.data
end

function ZONEABILITYBTN:SetObjectVisibility(show)

	if (GetZoneAbilitySpellInfo() or show) then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		self:SetAlpha(1)
	elseif not Neuron.ButtonEditMode and not Neuron.BarEditMode and not Neuron.BindingMode then
		self:SetAlpha(0)
	end
end

function ZONEABILITYBTN:LoadAux()
	self.spellID = ZoneAbilitySpellID;
	Neuron.NeuronBinder:CreateBindFrame(self, self.objTIndex)
	self.style = self:CreateTexture(nil, "OVERLAY")
	self.style:SetPoint("CENTER", -2, 1)
	self.style:SetWidth(190)
	self.style:SetHeight(95)
	self.hotkey:SetPoint("TOPLEFT", -4, -6)
	self.style:SetTexture("Interface\\ExtraButton\\GarrZoneAbility-Armory")
end

function ZONEABILITYBTN:SetAux()

	self:SetSkinned()

end


function ZONEABILITYBTN:OnLoad(button)
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


function ZONEABILITYBTN:SetType(save)

	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("SPELLS_CHANGED")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")


	self.actionID = self.id

	self:SetAttribute("type1", "macro")
	self:SetAttribute("*action1", self.actionID)

	self:SetAttribute("useparent-unit", false)
	self:SetAttribute("unit", ATTRIBUTE_NOOP)

	self:SetScript("OnEvent", function(self, event, ...) NeuronZoneAbilityBar:OnEvent(self, event, ...) end)
	self:SetScript("OnDragStart", function(self) NeuronZoneAbilityBar:OnDragStart(self) end)
	self:SetScript("OnLoad", function(self) NeuronZoneAbilityBar:OnLoad(self) end)
	self:SetScript("OnShow", function(self) NeuronZoneAbilityBar:OnShow(self) end)
	self:SetScript("OnHide", function(self) NeuronZoneAbilityBar:OnHide(self) end)
	self:SetScript("OnEnter", function(self, ...) NeuronZoneAbilityBar:OnEnter(self, ...) end)
	self:SetScript("OnLeave", function(self) NeuronZoneAbilityBar:OnLeave(self) end)
	self:SetScript("OnUpdate", function(self, elapsed) NeuronZoneAbilityBar:OnUpdate(self, elapsed) end)
	self:SetScript("OnAttributeChanged", nil)

	self:SetObjectVisibility()
end

function NeuronZoneAbilityBar:HideZoneAbilityBorder(bar, msg, gui, checked, query)
	if (query) then
		return Neuron.CurrentBar.data.border
	end

	if (gui) then

		if (checked) then
			Neuron.CurrentBar.data.border = true
		else
			Neuron.CurrentBar.data.border = false
		end

	else

		local toggle = Neuron.CurrentBar.data.border

		if (toggle) then
			Neuron.CurrentBar.data.border = false
		else
			Neuron.CurrentBar.data.border = true
		end
	end

	Neuron.NeuronBar:Update(bar)
	NeuronZoneAbilityBar:UpdateFrame()
end