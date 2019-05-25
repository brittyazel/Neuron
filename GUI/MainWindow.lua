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


local chkOptions = {
	[1] = { "AUTOHIDE", L["AutoHide"], 1, "SetAutoHide" },
	[2] = { "SHOWGRID", L["Show Grid"], 1, "SetShowGrid" },
	[3] = { "SNAPTO", L["SnapTo"], 1, "SetSnapTo" },
	[4] = { "UPCLICKS", L["Up Clicks"], 1, "SetUpClicks" },
	[5] = { "DOWNCLICKS", L["Down Clicks"], 1, "SetDownClicks" },
	[6] = { "MULTISPEC", L["Multi Spec"], 1, "SetMultiSpec" },
	[7] = { "HIDDEN", L["Hidden"], 1, "SetBarConceal" },
	[8] = { "SPELLGLOW", L["Spell Alerts"], 1, "SetSpellGlow" },
	[9] = { "LOCKBAR", L["Lock Actions"], 1, "SetBarLock" },
	[10] = { "LOCKBAR", L["Unlock on SHIFT"], 0.9, "SetBarLock", "shift" },
	[1] = { "LOCKBAR", L["Unlock on CTRL"], 0.9, "SetBarLock", "ctrl" },
	[12] = { "LOCKBAR", L["Unlock on ALT"], 0.9, "SetBarLock", "alt" },
	[13] = { "TOOLTIPS", L["Enable Tooltips"], 1, "SetTooltipEnable" },
	[14] = { "TOOLTIPS", L["Enhanced"], 0.9, "SetTooltipEnhanced" },
	[15] = { "TOOLTIPS", L["Hide in Combat"], 0.9, "SetTooltipCombat" },
	[16] = { "BORDERSTYLE", L["Show Border Style"], 1, "SetBorderStyle"},
}

local adjOptions = {
	[1] = { "SCALE", L["Scale"], 1, "SetScale", 0.01, 0.1, 4 },
	[2] = { "SHAPE", L["Shape"], 2, "SetBarShape", nil, nil, nil, Neuron.BarShapes },
	[3] = { "COLUMNS", L["Columns"], 1, "SetColumns", 1 , 0},
	[4] = { "ARCSTART", L["Arc Start"], 1, "SetArcStart", 1, 0, 359 },
	[5] = { "ARCLENGTH", L["Arc Length"], 1, "SetArcLength", 1, 0, 359 },
	[6] = { "HPAD",L["Horiz Padding"], 1, "SetHorizontalPad", 0.5 },
	[7] = { "VPAD", L["Vert Padding"], 1, "SetVerticalPad", 0.5 },
	[9] = { "STRATA", L["Strata"], 2, "SetStrata", nil, nil, nil, Neuron.STRATAS },
	[10] = { "ALPHA", L["Alpha"], 1, "SetBarAlpha", 0.01, 0, 1 },
	[11] = { "ALPHAUP", L["AlphaUp"], 2, "SetAlphaUp", nil, nil, nil, Neuron.AlphaUps },
	[12] = { "ALPHAUP", L["AlphaUp Speed"], 1, "SetAlphaUpSpeed", 0.01, 0.01, 1, nil, "%0.0f", 100, "%" },
	[13] = { "XPOS", L["X Position"], 1, "SetXAxis", 1, nil, nil, nil, "%0.2f", 1, "" },
	[14] = { "YPOS", L["Y Position"], 1, "SetYAxis", 1, nil, nil, nil, "%0.2f", 1, "" },
}

local swatchOptions = {
	[1] = { "BINDTEXT", L["Keybind Label"], 1, "SetBindText", true, nil, "bindColor" },
	[2] = { "MACROTEXT", L["Macro Name"], 1, "SetMacroText", true, nil, "macroColor" },
	[3] = { "COUNTTEXT", L["Stack/Charge Count Label"], 1, "SetCountText", true, nil, "countColor" },
	[4] = { "RANGEIND", L["Out-of-Range Indicator"], 1, "SetRangeInd", true, nil, "rangecolor" },
	[5] = { "CDTEXT", L["Cooldown Countdown"], 1, "SetCDText", true, true, "cdcolor1", "cdcolor2" },
	[6] = { "CDALPHA", L["Cooldown Transparency"], 1, "SetCDAlpha", nil, nil },
	[7] = { "AURAIND", L["Buff/Debuff Aura Border"], 1, "SetAuraInd", true, true, "buffcolor", "debuffcolor" },
}

-----------------------------------------------------------------------------
--------------------------Initialize-----------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:Initialize_GUI()

	DB = Neuron.db.profile

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


function NeuronGUI:CreateEditor()

	--Outer Window
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



	--Container for the Left Column
	local leftContainer = AceGUI:Create("SimpleGroup")
	leftContainer:SetRelativeWidth(.79)
	leftContainer:SetFullHeight(true)
	leftContainer:SetLayout("Flow")
	NeuronEditor:AddChild(leftContainer)

	--Tab group that will contain all of our settings to configure
	local tabFrame = AceGUI:Create("TabGroup")
	tabFrame:SetLayout("Flow")
	tabFrame:SetFullHeight(true)
	tabFrame:SetFullWidth(true)
	tabFrame:SetTabs({{text="Bar Settings", value="tab1"}, {text="Button Settings", value="tab2"}})
	tabFrame:SetCallback("OnGroupSelected", function(self, event, tab) NeuronGUI:SelectTab(self, event, tab) end)
	tabFrame:SelectTab("tab1")
	leftContainer:AddChild(tabFrame)




	--Container for the Right Column
	local rightContainer = AceGUI:Create("SimpleGroup")
	rightContainer:SetRelativeWidth(.20)
	rightContainer:SetFullHeight(true)
	rightContainer:SetLayout("Flow")
	NeuronEditor:AddChild(rightContainer)

	local topPadding = AceGUI:Create("SimpleGroup")
	topPadding:SetHeight(20)
	rightContainer:AddChild(topPadding)

	--Container for the Add/Delete bars buttons
	barEditOptionsContainer = AceGUI:Create("InlineGroup")
	barEditOptionsContainer:SetTitle("Create a new bar:")
	barEditOptionsContainer:SetLayout("Flow")
	barEditOptionsContainer:SetFullWidth(true)
	rightContainer:AddChild(barEditOptionsContainer)
	NeuronGUI:PopulateEditOptions(barEditOptionsContainer) --this is to make the Rename/Create/Delete Bars group

	--Container for the Rename box in the right column
	local barRenameContainer = AceGUI:Create("SimpleGroup")
	barRenameContainer:SetLayout("Flow")
	barRenameContainer:SetHeight(30)
	barRenameContainer:SetFullWidth(true)
	rightContainer:AddChild(barRenameContainer)
	NeuronGUI:PopulateRenameBar(barRenameContainer) --this is to make the Rename/Create/Delete Bars group


	--Container for the Bar List scroll frame
	local barListContainer = AceGUI:Create("InlineGroup")
	barListContainer:SetTitle("Select an available bar:")
	barListContainer:SetLayout("Fill")
	barListContainer:SetFullWidth(true)
	barListContainer:SetFullHeight(true)
	rightContainer:AddChild(barListContainer)

	--Scroll frame that will contain the Bar List
	barListFrame = AceGUI:Create("ScrollFrame")
	barListFrame:SetLayout("Flow")
	barListContainer:AddChild(barListFrame)
	NeuronGUI:PopulateBarList(barListFrame) --fill the bar list frame with the actual list of the bars

end

function NeuronGUI:PopulateBarList()

	for _, bar in pairs(Neuron.BARIndex) do
		local barLabel = AceGUI:Create("InteractiveLabel")
		barLabel:SetText(bar.data.name)
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


	--populate the dropdown menu with available bar types
	local barTypes = {}

	for class, info in pairs(Neuron.registeredBarData) do
		barTypes[class] = info.barLabel
	end

	local selectedBarType

	barTypeDropdown:SetList(barTypes) --assign the bar type table to the dropdown menu
	barTypeDropdown:SetCallback("OnValueChanged", function(self, key) selectedBarType = key; newBarButton:SetDisabled(false) end)



end

function NeuronGUI:PopulateRenameBar(container)

	renameBox = AceGUI:Create("EditBox")
	if Neuron.CurrentBar then
		renameBox:SetText(Neuron.CurrentBar:GetName())
	end
	renameBox:SetLabel("Rename selected bar")

	renameBox:SetCallback("OnEnterPressed", function(self) NeuronGUI:updateBarName(self) end)

	container:AddChild(renameBox)

end

function NeuronGUI:updateBarName(editBox)
	local bar = Neuron.CurrentBar

	if (bar) then
		bar:SetName(editBox:GetText())
		bar.text:SetText(bar:GetName())

		editBox:ClearFocus()
		NeuronGUI:RefreshEditor()
	end
end




-----------------------------------------------------------------------------
--------------------------Inner Window---------------------------------------
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
--------------------------Bar Editor-----------------------------------------
-----------------------------------------------------------------------------
