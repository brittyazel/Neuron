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

local NeuronGUI = {}
Neuron.NeuronGUI = NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

NeuronEditor = {} --outer frame for our editor window

local currentTab = "tab1" --remember which tab we were using between refreshes
local selectedBarType --remember which bar type was selected for creating new bars between refreshes


-----------------------------------------------------------------------------
--------------------------Initialize-----------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:Initialize_GUI()

	NeuronGUI:LoadInterfaceOptions()

	NeuronGUI:CreateEditor()
	NeuronEditor:Hide()

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
	NeuronEditor:ReleaseChildren()
	NeuronGUI:PopulateEditorWindow()

	if Neuron.CurrentBar then
		NeuronEditor:SetStatusText("The currently selected bar is: " .. Neuron.CurrentBar:GetName())
	else
		NeuronEditor:SetStatusText("Please select a bar from the right to begin")
	end
end


function NeuronGUI:CreateEditor()
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

	NeuronGUI:PopulateEditorWindow()
end

function NeuronGUI:PopulateEditorWindow()

	----------------------------------
	---Left Column
	--Tab group that will contain all of our settings to configure
	local tabFrame = AceGUI:Create("TabGroup")
	tabFrame:SetLayout("Flow")
	tabFrame:SetFullHeight(true)
	tabFrame:SetRelativeWidth(.78)
	tabFrame:SetTabs({{text="Bar Settings", value="tab1"}, {text="Button Settings", value="tab2"}})
	tabFrame:SetCallback("OnGroupSelected", function(self, event, tab) NeuronGUI:SelectTab(self, event, tab) end)
	tabFrame:SelectTab(currentTab)
	NeuronEditor:AddChild(tabFrame)


	----------------------------------
	---Right Column
	--Container for the Right Column
	local rightContainer = AceGUI:Create("SimpleGroup")
	rightContainer:SetRelativeWidth(.20)
	rightContainer:SetFullHeight(true)
	rightContainer:SetLayout("Flow")
	NeuronEditor:AddChild(rightContainer)


	local padding1 = AceGUI:Create("Heading")
	padding1:SetWidth(0)
	padding1:SetHeight(55)
	rightContainer:AddChild(padding1)

	--Rename/Add/Delete Bar options
	local barTypeDropdown
	local newBarButton
	local deleteBarButton

	-------------------------------
	--populate the dropdown menu with available bar types
	local barTypes = {}
	for class, info in pairs(Neuron.registeredBarData) do
		barTypes[class] = info.barLabel
	end

	--bar type list dropdown menu
	barTypeDropdown = AceGUI:Create("Dropdown")
	barTypeDropdown:SetText("Select a Bar Type")
	barTypeDropdown:SetFullWidth(true)
	rightContainer:AddChild(barTypeDropdown)

	barTypeDropdown:SetList(barTypes) --assign the bar type table to the dropdown menu
	barTypeDropdown:SetCallback("OnValueChanged", function(self, callBackType, key) selectedBarType = key; newBarButton:SetDisabled(false) end)

	--Create New Bar button
	newBarButton = AceGUI:Create("Button")
	newBarButton:SetText("Create New Bar")
	newBarButton:SetFullWidth(true)
	newBarButton:SetCallback("OnClick", function() if selectedBarType then Neuron.BAR:CreateNewBar(selectedBarType); NeuronGUI:RefreshEditor() end end)
	newBarButton:SetDisabled(true) --we want to disable it until they chose a bar type in the dropdown
	rightContainer:AddChild(newBarButton)


	--Delete Current Bar button
	deleteBarButton = AceGUI:Create("Button")
	deleteBarButton:SetText("Delete Current Bar")
	deleteBarButton:SetFullWidth("true")
	deleteBarButton:SetCallback("OnClick", function() if Neuron.CurrentBar then Neuron.CurrentBar:DeleteBar(); NeuronGUI:RefreshEditor() end end)
	if not Neuron.CurrentBar then
		deleteBarButton:SetDisabled(true)
	end
	rightContainer:AddChild(deleteBarButton)

	----------------------------------

	--small padding
	local padding2 = AceGUI:Create("Heading")
	padding2:SetWidth(0)
	padding2:SetHeight(10)
	rightContainer:AddChild(padding2)

	--Heading spacer
	local heading1 = AceGUI:Create("Heading")
	heading1:SetFullWidth(true)
	heading1:SetText("Rename selected bar")
	rightContainer:AddChild(heading1)

	--Bar Rename Box
	local renameBox = AceGUI:Create("EditBox")
	if Neuron.CurrentBar then
		renameBox:SetText(Neuron.CurrentBar:GetName())
	end
	renameBox:SetFullWidth(true)
	renameBox:SetCallback("OnEnterPressed", function(self) NeuronGUI:updateBarName(self) end)
	rightContainer:AddChild(renameBox)

	--Container for the Bar List scroll frame
	local barListContainer = AceGUI:Create("InlineGroup")
	barListContainer:SetLayout("Fill")
	barListContainer:SetTitle("Select an available bar")
	barListContainer:SetFullWidth(true)
	barListContainer:SetFullHeight(true)
	rightContainer:AddChild(barListContainer)

	--Scroll frame that will contain the Bar List
	local barListFrame = AceGUI:Create("ScrollFrame")
	barListFrame:SetLayout("Flow")
	barListContainer:AddChild(barListFrame)
	NeuronGUI:PopulateBarList(barListFrame) --fill the bar list frame with the actual list of the bars

end

---Bar List Window
function NeuronGUI:PopulateBarList(barListFrame)

	for _, bar in pairs(Neuron.BARIndex) do
		local barLabel = AceGUI:Create("InteractiveLabel")
		barLabel:SetText(bar:GetName())
		barLabel:SetFont("Fonts\\FRIZQT__.TTF", 12)
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


---Bar Rename
function NeuronGUI:updateBarName(editBox)
	local bar = Neuron.CurrentBar

	if (bar) then
		bar:SetName(editBox:GetText())
		bar.text:SetText(bar:GetName())

		editBox:ClearFocus()
		NeuronGUI:RefreshEditor()
	end
end


function NeuronGUI:SelectTab(tabFrame, _, tab)

	tabFrame:ReleaseChildren()

	if tab == "tab1" then
		NeuronGUI:BarEditPanel(tabFrame)
		currentTab = "tab1"
	elseif tab == "tab2" then
		NeuronGUI:ButtonEditPanel(tabFrame)
		currentTab = "tab2"
	end

end