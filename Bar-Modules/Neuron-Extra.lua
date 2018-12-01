--Neuron , a World of Warcraft® user interface addon.

local DB

Neuron.NeuronExtraBar = Neuron:NewModule("ExtraBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronExtraBar = Neuron.NeuronExtraBar



local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local defaultBarOptions = {
	[1] = {
		hidestates = ":",
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 205,
	}
}


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronExtraBar:OnInitialize()

	DB = Neuron.db.profile

	Neuron:RegisterBarClass("extrabar", "ExtraActionBar", L["Extra Action Bar"], "Extra Action Button", DB.extrabar, Neuron.NeuronExtraBar, Neuron.EXTRABTN,1)

	Neuron:RegisterGUIOptions("extrabar", {
		AUTOHIDE = true,
		SHOWGRID = false,
		SNAPTO = true,
		UPCLICKS = true,
		DOWNCLICKS = true,
		HIDDEN = true,
		LOCKBAR = true,
		BINDTEXT = true,
		RANGEIND = true,
		CDTEXT = true,
		CDALPHA = true },
			false, 65)

	NeuronExtraBar:CreateBarsAndButtons()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronExtraBar:OnEnable()

	NeuronExtraBar:DisableDefault()

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronExtraBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------

function NeuronExtraBar:CreateBarsAndButtons()

	if (DB.extrabarFirstRun) then

		for id, defaults in ipairs(defaultBarOptions) do

			local bar = Neuron.NeuronBar:CreateNewBar("extrabar", id, true) --this calls the bar constructor

			for	k,v in pairs(defaults) do
				bar.data[k] = v
			end

			local object

			object = Neuron:CreateNewObject("extrabar", 1, true)
			Neuron.NeuronBar:AddObjectToList(bar, object)
		end

		DB.extrabarFirstRun = false

	else

		for id,data in pairs(DB.extrabar) do
			if (data ~= nil) then
				local extrabar = Neuron.NeuronBar:CreateNewBar("extrabar", id)


				--this is a fix for adding a hidestate to the extrabar that kept it hidden even in bind/edit modes
				if extrabar.barDB[id].hidestates == ":extrabar0:" then
					extrabar.barDB[id].hidestates = ":"
				end

			end
		end

		for id,data in pairs(DB.extrabtn) do
			if (data ~= nil) then
				Neuron:CreateNewObject("extrabar", id)
			end
		end
	end

end


function NeuronExtraBar:DisableDefault()

	local disableExtraButton = false

	for i,v in ipairs(Neuron.NeuronExtraBar) do

		if (v["bar"]) then --only disable if a specific button has an associated bar
			disableExtraButton = true
		end
	end


	if disableExtraButton then
		------Hiding the default blizzard
		ExtraActionButton1:UnregisterAllEvents()
		ExtraActionButton1:SetPoint("BOTTOM", 0, -250)
	end

end