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

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

local currentTab = "tab1" --remember which tab we were using between refreshes
local selectedBarType --remember which bar type was selected for creating new bars between refreshes


-----------------------------------------------------------------------------
--------------------------Bar Editor-----------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:BarEditPanel(tabFrame)

	Neuron:ToggleBarEditMode(true)

	----------------------------------
	----------- Left Column ----------
	----------------------------------

	--Container for the left Column
	--[[local leftContainer = AceGUI:Create("SimpleGroup")
	leftContainer:SetRelativeWidth(0.22)
	leftContainer:SetFullHeight(true)
	leftContainer:SetLayout("List")

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
	barTypeDropdown:SetRelativeWidth(1)
	barTypeDropdown:SetText("Select a Bar Type")
	leftContainer:AddChild(barTypeDropdown)

	barTypeDropdown:SetList(barTypes) --assign the bar type table to the dropdown menu
	barTypeDropdown:SetCallback("OnValueChanged", function(self, callBackType, key) selectedBarType = key; newBarButton:SetDisabled(false) end)

	--Create New Bar button
	newBarButton = AceGUI:Create("Button")
	newBarButton:SetRelativeWidth(1)
	newBarButton:SetText("Create New Bar")
	newBarButton:SetCallback("OnClick", function() if selectedBarType then Neuron.BAR:CreateNewBar(selectedBarType); NeuronGUI:RefreshEditor() end end)
	newBarButton:SetDisabled(true) --we want to disable it until they chose a bar type in the dropdown
	leftContainer:AddChild(newBarButton)


	--Delete Current Bar button
	deleteBarButton = AceGUI:Create("Button")
	deleteBarButton:SetRelativeWidth(1)
	deleteBarButton:SetText("Delete Current Bar")
	deleteBarButton:SetCallback("OnClick", function() if Neuron.currentBar then Neuron.currentBar:DeleteBar(); NeuronGUI:RefreshEditor() end end)
	if not Neuron.currentBar then
		deleteBarButton:SetDisabled(true)
	end
	leftContainer:AddChild(deleteBarButton)

	----------------------------------

	--Bar Rename Box
	local renameBox = AceGUI:Create("EditBox")
	renameBox:SetRelativeWidth(1)
	renameBox:SetLabel("Rename selected bar")
	if Neuron.currentBar then
		renameBox:SetText(Neuron.currentBar:GetBarName())
	end
	renameBox:SetCallback("OnEnterPressed", function(self) NeuronGUI:updateBarName(self) end)
	leftContainer:AddChild(renameBox)

	--Container for the Bar List scroll frame
	local barListContainer = AceGUI:Create("InlineGroup")
	barListContainer:SetRelativeWidth(1)
	barListContainer:SetLayout("Fill")
	barListContainer:SetHeight(240)
	barListContainer:SetTitle("Select an available bar")
	leftContainer:AddChild(barListContainer)

	--Scroll frame that will contain the Bar List
	local barListFrame = AceGUI:Create("ScrollFrame")
	barListFrame:SetLayout("List")
	barListContainer:AddChild(barListFrame)
	NeuronGUI:PopulateBarList(barListFrame) --fill the bar list frame with the actual list of the bars

]]
	----------------------------------
	---------- Right Column ----------
	----------------------------------

	if Neuron.currentBar then
		--Tab group that will contain all of our settings to configure
		local innerTabFrame = AceGUI:Create("TabGroup")
		innerTabFrame:SetLayout("Fill")
		innerTabFrame:SetTabs({{text="General Configuration", value="tab1"}, {text="Bar States", value="tab2"}, {text="Bar Visibility", value="tab3"}})
		innerTabFrame:SetCallback("OnGroupSelected", function(self, _, tab) NeuronGUI:SelectInnerBarTab(self, _, tab) end)

		tabFrame:AddChild(innerTabFrame)

		innerTabFrame:SelectTab(currentTab)
	else
		local selectBarMessage = AceGUI:Create("Label")
		selectBarMessage:SetText("Please select a bar to continue")
		selectBarMessage:SetFont("Fonts\\FRIZQT__.TTF", 30)
		tabFrame:AddChild(selectBarMessage)
	end

end



---Bar List Window
function NeuronGUI:PopulateBarList(barListFrame)

	for _, bar in pairs(Neuron.BARIndex) do
		local barLabel = AceGUI:Create("InteractiveLabel")
		barLabel:SetText(bar:GetBarName())
		barLabel:SetFont("Fonts\\FRIZQT__.TTF", 12)
		barLabel:SetHighlight("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		if Neuron.currentBar == bar then
			barLabel:SetColor(1,.9,0)
		end
		barLabel.bar = bar
		barLabel:SetCallback("OnEnter", function(self) self.bar:OnEnter() end)
		barLabel:SetCallback("OnLeave", function(self) self.bar:OnLeave() end)
		barLabel:SetCallback("OnClick", function(self)
			Neuron.BAR.ChangeSelectedBar(self.bar)
			NeuronGUI:RefreshEditor()
			self:SetColor(1,.9,0)
		end)
		barListFrame:AddChild(barLabel)
	end
end


---Bar Rename
function NeuronGUI:updateBarName(editBox)
	local bar = Neuron.currentBar

	if bar then
		bar:SetBarName(editBox:GetText())
		bar.text:SetText(bar:GetBarName())

		editBox:ClearFocus()
		NeuronGUI:RefreshEditor()
	end
end


-----------------------------------------------------------------------------
----------------------Inner Tab Frame----------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:SelectInnerBarTab(tabFrame, _, tab)
	tabFrame:ReleaseChildren()
	if tab == "tab1" then
		NeuronGUI:GeneralConfigPanel(tabFrame)
		currentTab = "tab1"
	elseif tab == "tab2" then
		NeuronGUI:BarStatesPanel(tabFrame)
		currentTab = "tab2"
	elseif tab == "tab3" then
		NeuronGUI:BarVisibilityPanel(tabFrame)
		currentTab = "tab3"
	end
end