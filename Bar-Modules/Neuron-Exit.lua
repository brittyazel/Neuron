--Neuron , a World of Warcraft® user interface addon.

local DB

Neuron.NeuronExitBar = Neuron:NewModule("ExitBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronExitBar = Neuron.NeuronExitBar


local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local defaultBarOptions = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 305,
	}
}

-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronExitBar:OnInitialize()

	DB = Neuron.db.profile

	Neuron:RegisterBarClass("exitbar", "VehicleExitBar", L["Vehicle Exit Bar"], "Vehicle Exit Button", DB.exitbar, Neuron.NeuronExitBar, Neuron.EXITBTN,1)


	Neuron:RegisterGUIOptions("exitbar", {
		AUTOHIDE = true,
		SHOWGRID = false,
		SNAPTO = true,
		UPCLICKS = true,
		DOWNCLICKS = true,
		HIDDEN = true,
		LOCKBAR = true,
		TOOLTIPS = true,
		BINDTEXT = true,
		RANGEIND = true,
		CDTEXT = true,
		CDALPHA = true },
			false, 65)


	NeuronExitBar:CreateBarsAndButtons()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronExitBar:OnEnable()

	NeuronExitBar:DisableDefault()

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronExitBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------

function NeuronExitBar:CreateBarsAndButtons()

	if (DB.exitbarFirstRun) then

		for id, defaults in ipairs(defaultBarOptions) do

			local bar = Neuron.NeuronBar:CreateNewBar("exitbar", id, true) --this calls the bar constructor

			for	k,v in pairs(defaults) do
				bar.data[k] = v
			end

			local object

			object = Neuron:CreateNewObject("exitbar", 1, true)
			Neuron.NeuronBar:AddObjectToList(bar, object)
		end

		DB.exitbarFirstRun = false

	else

		for id,data in pairs(DB.exitbar) do
			if (data ~= nil) then
				Neuron.NeuronBar:CreateNewBar("exitbar", id)
			end
		end

		for id,data in pairs(DB.exitbtn) do
			if (data ~= nil) then
				Neuron:CreateNewObject("exitbar", id)
			end
		end
	end

end

function NeuronExitBar:DisableDefault()

	local disableExitButton = false

	for i,v in ipairs(Neuron.NeuronExitBar) do

		if (v["bar"]) then --only disable if a specific button has an associated bar
			disableExitButton = true
		end
	end


	if disableExitButton then
		------Hiding the default blizzard
		MainMenuBarVehicleLeaveButton:UnregisterAllEvents()
		MainMenuBarVehicleLeaveButton:SetPoint("BOTTOM", 0, -250)
	end

end