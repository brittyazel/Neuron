--Neuron, a World of Warcraft® user interface addon.

--This file is part of Neuron.
--
--Neuron is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--Neuron is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with this add-on.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2019.


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
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
end