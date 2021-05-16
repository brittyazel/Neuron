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
						set =  function() Neuron.NeuronMinimapIcon:ToggleIcon() end,
						get = function() return not DB.NeuronIcon.hide end,
						width = "full"
					},
				},
			},

			changelog = {
				name = L["Changelog"],
				type = "group",
				order = 1000,
				args = {
					line1 = {
						type = "description",
						name = L["Changelog_Latest_Version"],
					},
				},
			},

			faq = {
				name = L["F.A.Q."],
				desc = L["Frequently Asked Questions"],
				type = "group",
				order = 1001,
				args = {

					line1 = {
						type = "description",
						name = L["FAQ_Intro"],
					},

					g1 = {
						type = "group",
						name = L["Bar Configuration"],
						order = 1,
						args = {

							line1 = {
								type = "description",
								name = L["Bar_Configuration_FAQ"],
								order = 1,
							},

							g1 = {
								type = "group",
								name = L["General Options"],
								order = 1,
								args = {
									line1 = {
										type = "description",
										name = L["General_Bar_Configuration_Option_FAQ"] ,
										order = 1,
									},
								},
							},

							g2 = {
								type = "group",
								name = L["Bar States"],
								order = 2,
								args = {
									line1 = {
										type = "description",
										name = L["Bar_State_Configuration_FAQ"],
										order = 1,
									},
								},
							},

							g3 = {
								type = "group",
								name = L["Spell Target Options"],
								order = 3,
								args = {
									line1 = {
										type = "description",
										name = L["Spell_Target_Options_FAQ"],
										order = 1,
									},
								},
							},
						},
					},

					g2 = {
						type = "group",
						name = L["Flyout"],
						order = 3,
						args = {
							line1a = {
								type = "description",
								name = L["Flyout_FAQ"],
								order = 1,
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
	if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC then
		local LibDualSpec = LibStub('LibDualSpec-1.0')
		LibDualSpec:EnhanceDatabase(Neuron.db, addonName) --enhance the database object with per spec profile features
		LibDualSpec:EnhanceOptions(interfaceOptions.args.profile, Neuron.db) -- enhance the profiles config panel with per spec profile features
	end

	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
end