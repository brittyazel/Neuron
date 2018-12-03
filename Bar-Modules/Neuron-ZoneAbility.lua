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

--local alphaTimer, alphaDir = 0, 0
-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronZoneAbilityBar:OnInitialize()

	DB = Neuron.db.profile

	Neuron:RegisterBarClass("zoneabilitybar", "ZoneActionBar", L["Zone Action Bar"], "Zone Action Button", DB.zoneabilitybar, Neuron.NeuronZoneAbilityBar, Neuron.ZONEABILITYBTN, 1)

	Neuron:RegisterGUIOptions("zoneabilitybar", {
		AUTOHIDE = true,
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
		ZONEABILITY = true},
			false, 65)

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

--[[function NeuronZoneAbilityBar:controlOnUpdate(frame, elapsed)

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

end]]