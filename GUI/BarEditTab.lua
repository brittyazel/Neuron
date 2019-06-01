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

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")


--[[
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
	[1] = { "BINDTEXT", L["Keybind Label"], 1, "SetShowBindText", true, nil, "bindColor" },
	[2] = { "MACROTEXT", L["Macro Name"], 1, "SetShowMacroText", true, nil, "macroColor" },
	[3] = { "COUNTTEXT", L["Stack/Charge Count Label"], 1, "SetShowCountText", true, nil, "countColor" },
	[4] = { "RANGEIND", L["Out-of-Range Indicator"], 1, "SetShowRangeIndicator", true, nil, "rangecolor" },
	[5] = { "CDTEXT", L["Cooldown Countdown"], 1, "SetShowCooldownText", true, true, "cdcolor1", "cdcolor2" },
	[6] = { "CDALPHA", L["Cooldown Transparency"], 1, "SetShowCooldownAlpha", nil, nil },
	[7] = { "AURAIND", L["Buff/Debuff Aura Border"], 1, "SetShowAuraIndicator", true, true, "buffcolor", "debuffcolor" },
}]]

local currentTab = "tab1" --remember which tab we were using between refreshes


local WIDGET_GRID_WIDTH = 165
local WIDGET_GRID_HEIGHT = 40

local INNER_WIDGET_RATIO = 0.9
-----------------------------------------------------------------------------
--------------------------Bar Editor-----------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:BarEditPanel(tabFrame)

	if Neuron.CurrentBar then
		--Tab group that will contain all of our settings to configure
		local innerTabFrame = AceGUI:Create("TabGroup")
		innerTabFrame:SetLayout("Flow")
		innerTabFrame:SetFullWidth(true)
		innerTabFrame:SetFullHeight(true)
		innerTabFrame:SetTabs({{text="General Configuration", value="tab1"}, {text="Bar States", value="tab2"}, {text="Bar Visibility", value="tab3"}, {text="Spell Target Options", value="tab4"}})
		innerTabFrame:SetCallback("OnGroupSelected", function(self, _, tab) NeuronGUI:SelectInnerTab(self, _, tab) end)
		innerTabFrame:SelectTab(currentTab)
		tabFrame:AddChild(innerTabFrame)
	else
		local selectBarMessage = AceGUI:Create("Label")
		selectBarMessage:SetFullWidth(true)
		selectBarMessage:SetFullHeight(true)
		selectBarMessage:SetText("Please select a bar to continue")
		selectBarMessage:SetFont("Fonts\\FRIZQT__.TTF", 30)
		tabFrame:AddChild(selectBarMessage)
	end

end

-----------------------------------------------------------------------------
----------------------Inner Tab Frame----------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:SelectInnerTab(tabFrame, _, tab)

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
	elseif tab == "tab4" then
		NeuronGUI:SpellTargetingPanel(tabFrame)
		currentTab = "tab4"
	end

end



function NeuronGUI:GeneralConfigPanel(tabFrame)

	-------------------------------------------------

	--Heading spacer
	local heading1 = AceGUI:Create("Heading")
	heading1:SetText("Bar Options")
	heading1:SetHeight(WIDGET_GRID_HEIGHT)
	heading1:SetFullWidth(true)
	tabFrame:AddChild(heading1)

	-------------------------------------------------

	--AutoHide
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.AUTOHIDE then
		local autoHideCheckbox = AceGUI:Create("CheckBox")
		autoHideCheckbox:SetLabel(L["AutoHide"])
		autoHideCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		autoHideCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		autoHideCheckbox:SetValue(Neuron.CurrentBar:GetAutoHide())
		autoHideCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.CurrentBar:SetAutoHide(self:GetValue())
		end)
		tabFrame:AddChild(autoHideCheckbox)
	end

	--ShowGrid
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.SHOWGRID then
		local showGridCheckbox = AceGUI:Create("CheckBox")
		showGridCheckbox:SetLabel(L["Show Grid"])
		showGridCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		showGridCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		showGridCheckbox:SetValue(Neuron.CurrentBar:GetShowGrid())
		showGridCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.CurrentBar:SetShowGrid(self:GetValue())
		end)
		tabFrame:AddChild(showGridCheckbox)
	end

	--SnapTo
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.SNAPTO then
		local snapToCheckbox = AceGUI:Create("CheckBox")
		snapToCheckbox:SetLabel(L["SnapTo"])
		snapToCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		snapToCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		snapToCheckbox:SetValue(Neuron.CurrentBar:GetSnapTo())
		snapToCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.CurrentBar:SetSnapTo(self:GetValue())
		end)
		tabFrame:AddChild(snapToCheckbox)
	end

	--UpClicks
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.UPCLICKS then
		local upClicksCheckbox = AceGUI:Create("CheckBox")
		upClicksCheckbox:SetLabel(L["Up Clicks"])
		upClicksCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		upClicksCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		upClicksCheckbox:SetValue(Neuron.CurrentBar:GetUpClicks())
		upClicksCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.CurrentBar:SetUpClicks(self:GetValue())
		end)
		tabFrame:AddChild(upClicksCheckbox)
	end

	--DownClicks
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.DOWNCLICKS then
		local downClicksCheckbox = AceGUI:Create("CheckBox")
		downClicksCheckbox:SetLabel(L["Down Clicks"])
		downClicksCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		downClicksCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		downClicksCheckbox:SetValue(Neuron.CurrentBar:GetDownClicks())
		downClicksCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.CurrentBar:SetDownClicks(self:GetValue())
		end)
		tabFrame:AddChild(downClicksCheckbox)
	end

	--MultiSpec
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.MULTISPEC then
		local multiSpecCheckbox = AceGUI:Create("CheckBox")
		multiSpecCheckbox:SetLabel(L["Multi Spec"])
		multiSpecCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		multiSpecCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		multiSpecCheckbox:SetValue(Neuron.CurrentBar:GetMultiSpec())
		multiSpecCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.CurrentBar:SetMultiSpec(self:GetValue())
		end)
		tabFrame:AddChild(multiSpecCheckbox)
	end

	--Hidden
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.HIDDEN then
		local barConcealCheckbox = AceGUI:Create("CheckBox")
		barConcealCheckbox:SetLabel(L["Hidden"])
		barConcealCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		barConcealCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		barConcealCheckbox:SetValue(Neuron.CurrentBar:GetBarConceal())
		barConcealCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.CurrentBar:SetBarConceal(self:GetValue())
		end)
		tabFrame:AddChild(barConcealCheckbox)
	end

	--SpellGlow
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.SPELLGLOW then

		local spellAlertDropdownContainer = AceGUI:Create("SimpleGroup")
		spellAlertDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
		spellAlertDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)

		local currentGlow = Neuron.CurrentBar:GetSpellGlow()
		if not currentGlow then
			currentGlow = "none"
		end

		local spellAlertDropdown = AceGUI:Create("Dropdown")
		spellAlertDropdown:SetLabel(L["Spell Alerts"])
		spellAlertDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
		spellAlertDropdown:SetList({["none"] = L["None"], ["default"] = L["Default Alert"], ["alternate"] = L["Subdued Alert"]},
				{[1] = "none", [2] = "default", [3] = "alternate"})
		spellAlertDropdown:SetValue(currentGlow)
		spellAlertDropdown:SetCallback("OnValueChanged", function(self, callBackType, key)
			Neuron.CurrentBar:SetSpellGlow(key)
		end)
		spellAlertDropdownContainer:AddChild(spellAlertDropdown)
		tabFrame:AddChild(spellAlertDropdownContainer)
	end

	--BarLock
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.LOCKBAR then

		local spellAlertDropdownContainer = AceGUI:Create("SimpleGroup")
		spellAlertDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
		spellAlertDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)

		local currentLock = Neuron.CurrentBar:GetBarLock()
		if not currentLock then
			currentLock = "none"
		end

		local spellAlertDropdown = AceGUI:Create("Dropdown")
		spellAlertDropdown:SetLabel(L["Lock Actions"])
		spellAlertDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
		spellAlertDropdown:SetList({["none"] = L["None"], ["shift"] = L["Shift"], ["ctrl"] = L["Ctrl"], ["alt"] = L["Alt"]},
				{[1] = "none", [2] = "shift", [3] = "ctrl", [4] = "alt"})
		spellAlertDropdown:SetValue(currentLock)
		spellAlertDropdown:SetCallback("OnValueChanged", function(self, callBackType, key)
			Neuron.CurrentBar:SetBarLock(key)
		end)
		spellAlertDropdownContainer:AddChild(spellAlertDropdown)
		tabFrame:AddChild(spellAlertDropdownContainer)
	end

	--Tooltips
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.TOOLTIPS then

		local tooltipDropdownContainer = AceGUI:Create("SimpleGroup")
		tooltipDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
		tooltipDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)

		local currentTooltipOption = Neuron.CurrentBar:GetTooltipOption()
		if not currentTooltipOption then
			currentTooltipOption = "none"
		end

		local tooltipDropdown = AceGUI:Create("Dropdown")
		tooltipDropdown:SetLabel(L["Enable Tooltips"])
		tooltipDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
		tooltipDropdown:SetList({["off"] = L["Off"], ["minimal"] = L["Minimal"], ["enhanced"] = L["Enhanced"]},
				{[1] = "off", [2] = "minimal", [3] = "enhanced"})
		tooltipDropdown:SetValue(currentTooltipOption)
		tooltipDropdown:SetCallback("OnValueChanged", function(self, callBackType, key)
			Neuron.CurrentBar:SetTooltipOption(key)
		end)

		tooltipDropdownContainer:AddChild(tooltipDropdown)
		tabFrame:AddChild(tooltipDropdownContainer)
	end

	--Tooltips in Combat
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.TOOLTIPS then
		local combatTooltipsCheckbox = AceGUI:Create("CheckBox")
		combatTooltipsCheckbox:SetLabel(L["Tooltips in Combat"])
		combatTooltipsCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		combatTooltipsCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		combatTooltipsCheckbox:SetValue(Neuron.CurrentBar:GetTooltipCombat())
		combatTooltipsCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.CurrentBar:SetTooltipCombat(self:GetValue())
		end)
		tabFrame:AddChild(combatTooltipsCheckbox)
	end

	--Border Style
	if Neuron.registeredGUIData[Neuron.CurrentBar.class].chkOpt.BORDERSTYLE then
		local borderStyleCheckbox = AceGUI:Create("CheckBox")
		borderStyleCheckbox:SetLabel(L["Show Border Style"])
		borderStyleCheckbox:SeteWidth(WIDGET_GRID_WIDTH)
		borderStyleCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		borderStyleCheckbox:SetValue(Neuron.CurrentBar:GetShowBorderStyle())
		borderStyleCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.CurrentBar:SetShowBorderStyle(self:GetValue())
		end)
		tabFrame:AddChild(borderStyleCheckbox)
	end


	-----------------------------------------------

	--Heading spacer
	local heading2 = AceGUI:Create("Heading")
	heading2:SetText("Layout Configuration")
	heading2:SetHeight(WIDGET_GRID_HEIGHT)
	heading2:SetFullWidth(true)
	tabFrame:AddChild(heading2)

	-------------------------------------------------

	--------------------------------
	--Add or Remove Button Widget
	local currentNumObjectsLabel

	local addOrRemoveButtonOuterContainer = AceGUI:Create("SimpleGroup")
	addOrRemoveButtonOuterContainer:SetWidth(WIDGET_GRID_WIDTH)
	addOrRemoveButtonOuterContainer:SetHeight(WIDGET_GRID_HEIGHT)

	tabFrame:AddChild(addOrRemoveButtonOuterContainer)

	local addOrRemoveButtonInnerContainer = AceGUI:Create("InlineGroup")
	addOrRemoveButtonInnerContainer:SetRelativeWidth(INNER_WIDGET_RATIO)
	addOrRemoveButtonInnerContainer:SetLayout("Flow")
	addOrRemoveButtonInnerContainer:SetTitle(L["Buttons"])

	addOrRemoveButtonOuterContainer:AddChild(addOrRemoveButtonInnerContainer)

	local subtractObjectButton = AceGUI:Create("Button")
	subtractObjectButton:SetText("|TInterface\\Buttons\\Arrow-Down-Up:15:15:2:-5|t") --this is an escape sequence that gives us a down arrow centered on the button
	subtractObjectButton:SetRelativeWidth(.35)
	subtractObjectButton:SetFullHeight(true)
	subtractObjectButton:SetCallback("OnClick", function(self)
		Neuron.CurrentBar:RemoveObjectFromBar()
		NeuronGUI:RefreshEditor()
	end)
	addOrRemoveButtonInnerContainer:AddChild(subtractObjectButton)

	currentNumObjectsLabel = AceGUI:Create("Label")
	currentNumObjectsLabel:SetText(" " .. Neuron.CurrentBar:GetNumObjects())
	currentNumObjectsLabel:SetFont("Fonts\\FRIZQT__.TTF", 20)
	currentNumObjectsLabel:SetRelativeWidth(.3)
	currentNumObjectsLabel:SetFullHeight(true)
	addOrRemoveButtonInnerContainer:AddChild(currentNumObjectsLabel)

	local addObjectButton = AceGUI:Create("Button")
	addObjectButton:SetText("|TInterface\\Buttons\\Arrow-Up-Up:15:15:2:2|t") --this is an escape sequence that gives us an up arrow centered on the button
	addObjectButton:SetRelativeWidth(.35)
	addObjectButton:SetFullHeight(true)
	addObjectButton:SetCallback("OnClick", function(self)
		Neuron.CurrentBar:AddObjectToBar()
		NeuronGUI:RefreshEditor()
	end)
	addOrRemoveButtonInnerContainer:AddChild(addObjectButton)
	--------------------------------

	--Add or Remove Column Widget
	local currentNumColumns = Neuron.CurrentBar:GetColumns()

	if not currentNumColumns then
		currentNumColumns = 0
	end

	local currentNumColumnsContainer = AceGUI:Create("SimpleGroup")
	currentNumColumnsContainer:SetWidth(WIDGET_GRID_WIDTH)
	currentNumColumnsContainer:SetHeight(WIDGET_GRID_HEIGHT)

	tabFrame:AddChild(currentNumColumnsContainer)

	local columnSlider = AceGUI:Create("Slider")
	columnSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	columnSlider:SetSliderValues(0,Neuron.CurrentBar:GetNumObjects(),1)
	columnSlider:SetLabel(L["Columns"])
	columnSlider:SetValue(currentNumColumns)
	columnSlider:SetCallback("OnValueChanged", function(self)
		Neuron.CurrentBar:SetColumns(self:GetValue())
	end)
	currentNumColumnsContainer:AddChild(columnSlider)


end

function NeuronGUI:BarStatesPanel(tabFrame)

end

function NeuronGUI:BarVisibilityPanel(tabFrame)

end

function NeuronGUI:SpellTargetingPanel(tabFrame)

end