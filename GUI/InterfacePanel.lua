-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron


local addonName = ...

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

-----------------------------------------------------------------------------
--------------------------Interface Menu-------------------------------------
-----------------------------------------------------------------------------
-- This is the file that manages this addons main configuration screen
-- this is not the file the manages bars and buttons
--
-- each fooOptions function sets up a separate configuration panel
-- these panels are then loaded via NeuronGUI:LoadInterfaceOptions

local function profileOptions()
	local options = LibStub("AceDBOptions-3.0"):GetOptionsTable(Neuron.db)
	-- Per spec profiles
	if Neuron.isWoWRetail or Neuron.isWoWWrathClassic then
		local LibDualSpec = LibStub('LibDualSpec-1.0')
		LibDualSpec:EnhanceDatabase(Neuron.db, addonName) --enhance the database object with per spec profile features
		LibDualSpec:EnhanceOptions(options, Neuron.db) -- enhance the profiles config panel with per spec profile features
	end
	return options
end

local function experimentalOptions()
	return {
		name = L["Experimental"],
		desc = L["Experimental Options"],
		type = "group",
		order = 1001,
		args = {

			Header = {
				order = 1,
				name = L["Experimental Options"],
				type = "header",
			},

			Warning = {
				order = 2,
				type = "description",
				name = DIM_RED_FONT_COLOR:WrapTextInColorCode(L["Experimental_Options_Warning"]),
				fontSize = "large",
			},
			importexport={
				name = L["Profile"].." "..L["Import"].."/"..L["Export"],
				type = "group",
				order = 1,
				args={

					Header = {
						order = 1,
						name = L["Profile"].." "..L["Import"].."/"..L["Export"],
						type = "header",
					},

					Instructions = {
						order = 2,
						name = L["ImportExport_Desc"],
						type = "description",
						fontSize = "medium",
					},

					TextBox = {
						order = 3,
						name = L["Import or Export the current profile:"],
						desc = DIM_RED_FONT_COLOR:WrapTextInColorCode(L["ImportExport_WarningDesc"]),
						type = "input",
						multiline = 22,
						confirm = function() return L["ImportWarning"] end,
						validate = false,
						set = function(self, input) Neuron:SetSerializedAndCompressedProfile(input) end,
						get = function() return Neuron:GetSerializedAndCompressedProfile() end,
						width = "full",
					},
				},
			},
		},
	}
end

local function guiOptions()
	local DB = Neuron.db.profile
	return {
		name = L["Options"],
		type = "group",
		order = 0,
		args={
			BlizzardBar = {
				order = 1,
				name = L["Display the Blizzard UI"],
				desc = L["Shows / Hides the Default Blizzard UI"],
				type = "toggle",
				set = function() Neuron:ToggleBlizzUI() end,
				get = function() return DB.blizzbar end,
				width = "full",
			},

			NeuronMinimapButton = {
				order = 2,
				name = L["Display Minimap Button"],
				desc = L["Toggles the minimap button."],
				type = "toggle",
				set =  function() Neuron:Minimap_ToggleIcon() end,
				get = function() return not DB.NeuronIcon.hide end,
				width = "full"
			},
		},
	}
end

local function mainOptions()
	return {
		name = "Neuron",
		type = 'group',
		args = {
		},
	}
end

---This is the main entry point
function NeuronGUI:LoadInterfaceOptions()
	local mainPanel = mainOptions()
	local subPanels = {guiOptions(), profileOptions(), experimentalOptions()}

	-- set up the top level panel
	LibStub("AceConfigRegistry-3.0"):ValidateOptionsTable(mainPanel, addonName)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, mainPanel)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)

	-- set up the tree of child panels
	for _,options in ipairs(subPanels) do
		LibStub("AceConfigRegistry-3.0"):ValidateOptionsTable(options, addonName)
		LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName..'-'..options.name, options)
		LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName..'-'..options.name,options.name, addonName)
	end
end
