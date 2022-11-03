-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron


local addonName = ...

local DB

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

-----------------------------------------------------------------------------
--------------------------Interface Menu-------------------------------------
-----------------------------------------------------------------------------

---This loads the Neuron interface panel
function NeuronGUI:LoadInterfaceOptions()

	DB = Neuron.db.profile

	--ACE GUI OPTION TABLE
	local interfaceOptions = {
		name = "Neuron",
		type = 'group',
		args = {
			moreoptions={
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
			},

			experimental = {
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
			},
		},
	}

	LibStub("AceConfigRegistry-3.0"):ValidateOptionsTable(interfaceOptions, addonName)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, interfaceOptions)
	interfaceOptions.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Neuron.db)

	-- Per spec profiles
	if Neuron.isWoWRetail then
		local LibDualSpec = LibStub('LibDualSpec-1.0')
		LibDualSpec:EnhanceDatabase(Neuron.db, addonName) --enhance the database object with per spec profile features
		LibDualSpec:EnhanceOptions(interfaceOptions.args.profile, Neuron.db) -- enhance the profiles config panel with per spec profile features
	end

	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
end
