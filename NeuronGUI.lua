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
--along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2018.


local addonName = ...

local DB

local NeuronGUI = {}
Neuron.NeuronGUI = NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

NeuronEditor = {} --outer frame for our editor window

---Class level handles for frame elements that need to be refreshed often

local barListFrame = {} --the frame containing just the bar list
local renameBox = {} --the rename bar Box
local barEditOptionsContainer = {} --The container that houses the add/remove bar buttons



function NeuronGUI:Initialize_GUI()

	DB = Neuron.db.profile

	NeuronGUI:LoadInterfaceOptions()

	NeuronGUI:CreateBarEditor()
	NeuronEditor:Hide()
	NeuronGUI.GUILoaded = true

	NeuronEditor:DoLayout() ---we need to keep this here to recomupute the layout, as it doesn't get it right the first time

end

-----------------------------------------------------------------------------
--------------------------Main Window----------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:ToggleEditor()
	if not NeuronEditor:IsVisible() then
		NeuronGUI:RefreshEditor()
		NeuronEditor:Show()
	else
		NeuronEditor:Hide()
	end
end

function NeuronGUI:RefreshEditor()

	if Neuron.CurrentBar then
		renameBox:SetText(Neuron.CurrentBar.data.name)
		NeuronEditor:SetStatusText("The currently selected bar is: " .. Neuron.CurrentBar.data.name)
	else
		renameBox:SetText("")
		NeuronEditor:SetStatusText("Please select a bar from the right to begin")
	end

	barListFrame:ReleaseChildren()
	NeuronGUI:PopulateBarList(barListFrame)

	barEditOptionsContainer:ReleaseChildren()
	NeuronGUI:PopulateEditOptions(barEditOptionsContainer)
end


function NeuronGUI:CreateBarEditor()

	---Outer Window
	NeuronEditor = AceGUI:Create("Frame")
	NeuronEditor:SetTitle("Neuron Editor")
	NeuronEditor:SetWidth("1000")
	NeuronEditor:SetHeight("700")
	NeuronEditor:EnableResize(false)
	if Neuron.CurrentBar then
		NeuronEditor:SetStatusText("The Currently Selected Bar is: " .. Neuron.CurrentBar.data.name)
	else
		NeuronEditor:SetStatusText("Welcome to the Neuron editor, please select a bar to begin")
	end
	NeuronEditor:SetCallback("OnClose", function() NeuronEditor:Hide() end)
	NeuronEditor:SetLayout("Flow")


	---Container for the Right Column
	local rightContainer = AceGUI:Create("SimpleGroup")
	rightContainer:SetRelativeWidth(.20)
	rightContainer:SetFullHeight(true)
	rightContainer:SetLayout("Flow")
	NeuronEditor:AddChild(rightContainer)

	---Container for the Rename box in the right column
	local barRenameContainer = AceGUI:Create("SimpleGroup")
	barRenameContainer:SetHeight(20)
	barRenameContainer:SetLayout("Flow")
	rightContainer:AddChild(barRenameContainer)
	NeuronGUI:PopulateRenameBar(barRenameContainer) --this is to make the Rename/Create/Delete Bars group


	---Container for the Bar List scroll frame
	local barListContainer = AceGUI:Create("InlineGroup")
	barListContainer:SetTitle("Select an available bar  ")
	barListContainer:SetHeight(480)
	barListContainer:SetLayout("Fill")
	rightContainer:AddChild(barListContainer)


	---Scroll frame that will contain the Bar List
	barListFrame = AceGUI:Create("ScrollFrame")
	barListFrame:SetLayout("Flow")
	barListContainer:AddChild(barListFrame)
	NeuronGUI:PopulateBarList(barListFrame) --fill the bar list frame with the actual list of the bars

	---Container for the Add/Delete bars buttons
	barEditOptionsContainer = AceGUI:Create("SimpleGroup")
	barEditOptionsContainer:SetHeight(110)
	barEditOptionsContainer:SetLayout("Flow")
	rightContainer:AddChild(barEditOptionsContainer)
	NeuronGUI:PopulateEditOptions(barEditOptionsContainer) --this is to make the Rename/Create/Delete Bars group


	---Container for the tab frame
	local tabFrameContainer = AceGUI:Create("SimpleGroup")
	tabFrameContainer:SetRelativeWidth(.79)
	tabFrameContainer:SetFullHeight(true)
	tabFrameContainer:SetLayout("Fill")
	NeuronEditor:AddChild(tabFrameContainer, rightContainer)

	---Tab group that will contain all of our settings to configure
	local tabFrame = AceGUI:Create("TabGroup")
	tabFrame:SetLayout("Flow")
	tabFrame:SetTabs({{text="Bar Settings", value="tab1"}, {text="Button Settings", value="tab2"}})
	tabFrame:SetCallback("OnGroupSelected", function(self, event, tab) NeuronGUI:SelectTab(self, event, tab) end)
	tabFrame:SelectTab("tab1")
	tabFrameContainer:AddChild(tabFrame)

end

function NeuronGUI:PopulateBarList()

	for _, bar in pairs(Neuron.BARIndex) do
		local barLabel = AceGUI:Create("InteractiveLabel")
		barLabel:SetText(bar.data.name)
		barLabel:SetFont("Fonts\\FRIZQT__.TTF", 18)
		barLabel:SetFullWidth(true)
		barLabel:SetHighlight("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		if Neuron.CurrentBar == bar then
			barLabel:SetColor(1,.9,0)
		end
		barLabel.bar = bar
		barLabel:SetCallback("OnEnter", function(self) self.bar:OnEnter() end)
		barLabel:SetCallback("OnLeave", function(self) self.bar:OnLeave() end)
		barLabel:SetCallback("OnClick", function(self)
			self.bar:ChangeBar()
			NeuronGUI:RefreshEditor()
			self:SetColor(1,.9,0)
		end)
		barListFrame:AddChild(barLabel)
	end

end

function NeuronGUI:PopulateEditOptions(container)

	local barTypeDropdown = AceGUI:Create("Dropdown")
	barTypeDropdown:SetText("Select a Bar Type")
	container:AddChild(barTypeDropdown)

	local newBarButton = AceGUI:Create("Button")
	newBarButton:SetText("Create New Bar")
	newBarButton:SetDisabled(true) --we want to disable it until they chose a bar type in the dropdown
	container:AddChild(newBarButton)

	local deleteBarButton = AceGUI:Create("Button")
	deleteBarButton:SetText("Delete Current Bar")
	if not Neuron.CurrentBar then
		deleteBarButton:SetDisabled(true)
	end
	container:AddChild(deleteBarButton)


	---populate the dropdown menu with available bar types
	local barTypes = {}

	for class, info in pairs(Neuron.registeredBarData) do
		if (info.barCreateMore or NeuronGUI:MissingBarCheck(class)) then
			barTypes[class] = info.barLabel
		end
	end

	local selectedBarType

	barTypeDropdown:SetList(barTypes) --assign the bar type table to the dropdown menu
	barTypeDropdown:SetCallback("OnValueChanged", function(self, key) selectedBarType = key; newBarButton:SetDisabled(false) end)



end

function NeuronGUI:PopulateRenameBar(container)

	renameBox = AceGUI:Create("EditBox")
	if Neuron.CurrentBar then
		renameBox:SetText(Neuron.CurrentBar.data.name)
	end
	renameBox:SetLabel("Rename selected bar")

	renameBox:SetCallback("OnEnterPressed", function(self) NeuronGUI:updateBarName(self) end)

	container:AddChild(renameBox)

end

--TODO: rework this Missing Bar Check code to be smarter
function NeuronGUI:MissingBarCheck(class)
	local allow = true
	if (class == "extrabar" and DB.extrabar[1])
			or (class == "zoneabilitybar" and DB.zoneabilitybar[1])
			or (class == "pet" and DB.petbar[1])
			or (class == "bag" and DB.bagbar[1])
			or (class == "menu" and DB.menubar[1]) then
		allow = false
	end
	return allow
end

function NeuronGUI:updateBarName(editBox)

	local bar = Neuron.CurrentBar

	if (bar) then
		bar.data.name = editBox:GetText()
		bar.text:SetText(bar.data.name)

		editBox:ClearFocus()
		NeuronGUI:RefreshEditor()
	end
end

-----------------------------------------------------------------------------
--------------------------Inner WIndow---------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:SelectTab(tabContainer, event, tab)

	tabContainer:ReleaseChildren()

	if tab == "tab1" then
		NeuronGUI:BarEditWindow(tabContainer)
	elseif tab == "tab2" then
		NeuronGUI:ButtonEditWindow(tabContainer)
	end

end


function NeuronGUI:BarEditWindow(tabContainer)

	local settingContainer = AceGUI:Create("SimpleGroup")
	settingContainer:SetFullWidth(true)
	settingContainer:SetLayout("Flow")
	tabContainer:AddChild(settingContainer)

	local desc = AceGUI:Create("Label")
	desc:SetText("This is Tab 1")
	desc:SetFullWidth(true)
	settingContainer:AddChild(desc)

end


function NeuronGUI:ButtonEditWindow(tabContainer)
	local settingContainer = AceGUI:Create("SimpleGroup")
	settingContainer:SetFullWidth(true)
	settingContainer:SetLayout("Flow")
	tabContainer:AddChild(settingContainer)

	local desc = AceGUI:Create("Label")
	desc:SetText("This is Tab 2")
	desc:SetFullWidth(true)
	settingContainer:AddChild(desc)
end








-----------------------------------------------------------------------------
--------------------------Interface Menu-------------------------------------
-----------------------------------------------------------------------------

---This loads the Neuron interface panel
function NeuronGUI:LoadInterfaceOptions()
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