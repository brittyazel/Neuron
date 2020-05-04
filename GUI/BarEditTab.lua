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

	--Container for the top Row
	local topRow = AceGUI:Create("SimpleGroup")
	topRow:SetFullWidth(true)
	topRow:SetHeight(50)
	topRow:SetAutoAdjustHeight(false)
	topRow:SetLayout("Flow")

	tabFrame:AddChild(topRow)


	local spacer1 = AceGUI:Create("SimpleGroup")
	spacer1:SetWidth(10)
	spacer1:SetHeight(40)
	spacer1:SetLayout("Fill")
	topRow:AddChild(spacer1)

	-------------------------------
	--Bar Rename Box
	local renameBox = AceGUI:Create("EditBox")
	renameBox:SetWidth(200)
	renameBox:SetLabel("Rename selected bar")
	if Neuron.currentBar then
		renameBox:SetText(Neuron.currentBar:GetBarName())
	end
	renameBox:SetCallback("OnEnterPressed", function(self) NeuronGUI:updateBarName(self) end)
	topRow:AddChild(renameBox)

	-------------------------------
	--populate the dropdown menu with available bar types
	local barTypes = {}
	for class, info in pairs(Neuron.registeredBarData) do
		barTypes[class] = info.barLabel
	end

	local spacer2 = AceGUI:Create("SimpleGroup")
	spacer2:SetWidth(15)
	spacer2:SetHeight(40)
	spacer2:SetLayout("Fill")
	topRow:AddChild(spacer2)

	local newBarButton
	--bar type list dropdown menu
	local barTypeDropdown = AceGUI:Create("Dropdown")
	barTypeDropdown:SetWidth(180)
	barTypeDropdown:SetText("Select a Bar Type")
	barTypeDropdown:SetList(barTypes) --assign the bar type table to the dropdown menu
	barTypeDropdown:SetCallback("OnValueChanged", function(self, callBackType, key) selectedBarType = key; newBarButton:SetDisabled(false) end)
	topRow:AddChild(barTypeDropdown)

	--Create New Bar button
	newBarButton = AceGUI:Create("Button")
	newBarButton:SetWidth(140)
	newBarButton:SetText("Create New Bar")
	newBarButton:SetCallback("OnClick", function() if selectedBarType then Neuron.BAR:CreateNewBar(selectedBarType); NeuronGUI:RefreshEditor() end end)
	newBarButton:SetDisabled(true) --we want to disable it until they chose a bar type in the dropdown
	topRow:AddChild(newBarButton)

	local spacer3 = AceGUI:Create("SimpleGroup")
	spacer3:SetWidth(15)
	spacer3:SetHeight(40)
	spacer3:SetLayout("Fill")
	topRow:AddChild(spacer3)

	--Delete Current Bar button
	local deleteBarButton = AceGUI:Create("Button")
	deleteBarButton:SetWidth(140)
	deleteBarButton:SetText("Delete Current Bar")
	deleteBarButton:SetCallback("OnClick", function() if Neuron.currentBar then NeuronGUI:DeleteBarPopup() end end)
	if not Neuron.currentBar then
		deleteBarButton:SetDisabled(true)
	end
	topRow:AddChild(deleteBarButton)


	---------------------------------
	------ Settings Tab Group -------
	---------------------------------

	if Neuron.currentBar then
		--Tab group that will contain all of our settings to configure
		local innerTabFrame = AceGUI:Create("TabGroup")
		innerTabFrame:SetLayout("Fill")
		innerTabFrame:SetFullHeight(true)
		innerTabFrame:SetFullWidth(true)
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

function NeuronGUI:DeleteBarPopup()

	StaticPopupDialogs["Delete_Bar_Popup"] = {
		text = "Do you really wish to delete "..Neuron.currentBar:GetBarName().."?",
		button1 = ACCEPT,
		button2 = CANCEL,
		timeout = 0,
		whileDead = true,
		OnAccept = function() Neuron.currentBar:DeleteBar(); NeuronGUI:RefreshEditor() end,
		OnCancel = function() NeuronGUI:RefreshEditor() end,
	}

	StaticPopup_Show("Delete_Bar_Popup")

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