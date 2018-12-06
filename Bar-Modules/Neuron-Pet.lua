--Neuron Pet Action Bar, a World of Warcraft® user interface addon.

local DB

Neuron.NeuronPetBar = Neuron:NewModule("PetBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronPetBar = Neuron.NeuronPetBar


local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local defaultBarOptions = {

	[1] = {
		hidestates = ":pet0:",
		showGrid = true,
		scale = 0.8,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = -440,
		y = 75,
	}
}


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronPetBar:OnInitialize()

	DB = Neuron.db.profile

	Neuron:RegisterBarClass("pet", "PetBar", L["Pet Bar"], "Pet Button", DB.petbar, Neuron.NeuronPetBar, Neuron.PETBTN, 10)

	Neuron:RegisterGUIOptions("pet", {
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


	if DB.blizzbar == false then
		NeuronPetBar:CreateBarsAndButtons()
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

function NeuronPetBar:CreateBarsAndButtons()

	if (DB.petbarFirstRun) then

		for id, defaults in ipairs(defaultBarOptions) do

			local bar = Neuron.NeuronBar:CreateNewBar("pet", id, true) --this calls the bar constructor

			for	k,v in pairs(defaults) do
				bar.data[k] = v
			end

			local object

			for i=1,10 do
				object = Neuron:CreateNewObject("pet", i, true)
				Neuron.NeuronBar:AddObjectToList(bar, object)
			end
		end

		DB.petbarFirstRun = false

	else

		for id,data in pairs(DB.petbar) do
			if (data ~= nil) then
				Neuron.NeuronBar:CreateNewBar("pet", id)
			end
		end

		for id,data in pairs(DB.petbtn) do
			if (data ~= nil) then
				Neuron:CreateNewObject("pet", id)
			end
		end
	end
end
