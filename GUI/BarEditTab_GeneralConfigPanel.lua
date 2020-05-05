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

local WIDGET_GRID_WIDTH = 165
local WIDGET_GRID_HEIGHT = 45

local INNER_WIDGET_RATIO = 0.95


function NeuronGUI:GeneralConfigPanel(tabFrame)

	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("Flow")
	tabFrame:AddChild(scrollFrame)

	------------------------------------------------
	------------------------------------------------

	--Bar Rename Box
	local renameBox = AceGUI:Create("EditBox")
	renameBox:SetWidth(WIDGET_GRID_WIDTH*1.5)
	renameBox:SetHeight(WIDGET_GRID_HEIGHT)
	renameBox:SetLabel("Rename selected bar:")
	if Neuron.currentBar then
		renameBox:SetText(Neuron.currentBar:GetBarName())
	end
	renameBox:SetCallback("OnEnterPressed", function(self) NeuronGUI:updateBarName(self) end)
	scrollFrame:AddChild(renameBox)

	---------------------------------------------------------
	----------------------Bar Options------------------------
	---------------------------------------------------------

	--Heading spacer
	local heading1 = AceGUI:Create("Heading")
	heading1:SetHeight(WIDGET_GRID_HEIGHT)
	heading1:SetFullWidth(true)
	heading1:SetText(L["General Options"])
	scrollFrame:AddChild(heading1)

	--AutoHide
	if Neuron.registeredGUIData[Neuron.currentBar.class].generalOptions.AUTOHIDE then
		local autoHideCheckbox = AceGUI:Create("CheckBox")
		autoHideCheckbox:SetLabel(L["Auto Hide"])
		autoHideCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		autoHideCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		autoHideCheckbox:SetValue(Neuron.currentBar:GetAutoHide())
		autoHideCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.currentBar:SetAutoHide(self:GetValue())
		end)
		scrollFrame:AddChild(autoHideCheckbox)
	end

	--ShowGrid
	if Neuron.registeredGUIData[Neuron.currentBar.class].generalOptions.SHOWGRID then
		local showGridCheckbox = AceGUI:Create("CheckBox")
		showGridCheckbox:SetLabel(L["Show Grid"])
		showGridCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		showGridCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		showGridCheckbox:SetValue(Neuron.currentBar:GetShowGrid())
		showGridCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.currentBar:SetShowGrid(self:GetValue())
		end)
		scrollFrame:AddChild(showGridCheckbox)
	end

	--SnapTo
	if Neuron.registeredGUIData[Neuron.currentBar.class].generalOptions.SNAPTO then
		local snapToCheckbox = AceGUI:Create("CheckBox")
		snapToCheckbox:SetLabel(L["SnapTo"])
		snapToCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		snapToCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		snapToCheckbox:SetValue(Neuron.currentBar:GetSnapTo())
		snapToCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.currentBar:SetSnapTo(self:GetValue())
		end)
		scrollFrame:AddChild(snapToCheckbox)
	end

	--UpClicks
	if Neuron.registeredGUIData[Neuron.currentBar.class].generalOptions.UPCLICKS then
		local upClicksCheckbox = AceGUI:Create("CheckBox")
		upClicksCheckbox:SetLabel(L["Up Clicks"])
		upClicksCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		upClicksCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		upClicksCheckbox:SetValue(Neuron.currentBar:GetUpClicks())
		upClicksCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.currentBar:SetUpClicks(self:GetValue())
		end)
		scrollFrame:AddChild(upClicksCheckbox)
	end

	--DownClicks
	if Neuron.registeredGUIData[Neuron.currentBar.class].generalOptions.DOWNCLICKS then
		local downClicksCheckbox = AceGUI:Create("CheckBox")
		downClicksCheckbox:SetLabel(L["Down Clicks"])
		downClicksCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		downClicksCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		downClicksCheckbox:SetValue(Neuron.currentBar:GetDownClicks())
		downClicksCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.currentBar:SetDownClicks(self:GetValue())
		end)
		scrollFrame:AddChild(downClicksCheckbox)
	end

	--MultiSpec
	if Neuron.registeredGUIData[Neuron.currentBar.class].generalOptions.MULTISPEC then
		local multiSpecCheckbox = AceGUI:Create("CheckBox")
		multiSpecCheckbox:SetLabel(L["Multi Spec"])
		multiSpecCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		multiSpecCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		multiSpecCheckbox:SetValue(Neuron.currentBar:GetMultiSpec())
		multiSpecCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.currentBar:SetMultiSpec(self:GetValue())
		end)
		scrollFrame:AddChild(multiSpecCheckbox)
	end

	--Hidden
	if Neuron.registeredGUIData[Neuron.currentBar.class].generalOptions.HIDDEN then
		local barConcealCheckbox = AceGUI:Create("CheckBox")
		barConcealCheckbox:SetLabel(L["Hidden"])
		barConcealCheckbox:SetWidth(WIDGET_GRID_WIDTH)
		barConcealCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
		barConcealCheckbox:SetValue(Neuron.currentBar:GetBarConceal())
		barConcealCheckbox:SetCallback("OnValueChanged", function(self)
			Neuron.currentBar:SetBarConceal(self:GetValue())
		end)
		scrollFrame:AddChild(barConcealCheckbox)
	end

	--BarLock
	if Neuron.registeredGUIData[Neuron.currentBar.class].generalOptions.LOCKBAR then

		local spellAlertDropdownContainer = AceGUI:Create("SimpleGroup")
		spellAlertDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
		spellAlertDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(spellAlertDropdownContainer)

		local currentLock = Neuron.currentBar:GetBarLock()
		if not currentLock then
			currentLock = "none"
		end

		local spellAlertDropdown = AceGUI:Create("Dropdown")
		spellAlertDropdown:SetLabel(L["Lock Actions"])
		spellAlertDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
		spellAlertDropdown:SetList({["none"] = L["None"], ["shift"] = L["Shift"], ["ctrl"] = L["Ctrl"], ["alt"] = L["Alt"]},
				{[1] = "none", [2] = "shift", [3] = "ctrl", [4] = "alt"})
		spellAlertDropdown:SetValue(currentLock)
		spellAlertDropdown:SetCallback("OnValueChanged", function(_, _, key)
			Neuron.currentBar:SetBarLock(key)
		end)
		spellAlertDropdownContainer:AddChild(spellAlertDropdown)
	end

	---------------------------------------------------------
	----------------------Layout Configuration---------------
	---------------------------------------------------------

	--Heading spacer
	local heading2 = AceGUI:Create("Heading")
	heading2:SetHeight(WIDGET_GRID_HEIGHT)
	heading2:SetFullWidth(true)
	heading2:SetText(L["Size and Shape"])
	scrollFrame:AddChild(heading2)

	--------------------------------
	--------------------------------

	--Add or Remove Button Widget
	local currentNumObjectsLabel

	local addOrRemoveButtonContainer = AceGUI:Create("InlineGroup")
	addOrRemoveButtonContainer:SetWidth(WIDGET_GRID_WIDTH)
	addOrRemoveButtonContainer:SetHeight(WIDGET_GRID_HEIGHT)
	addOrRemoveButtonContainer:SetLayout("Flow")
	addOrRemoveButtonContainer:SetTitle(L["Buttons"])

	scrollFrame:AddChild(addOrRemoveButtonContainer)

	local subtractObjectButton = AceGUI:Create("Button")
	subtractObjectButton:SetText("|TInterface\\Buttons\\Arrow-Down-Up:15:15:2:-5|t") --this is an escape sequence that gives us a down arrow centered on the button
	subtractObjectButton:SetRelativeWidth(.35)
	subtractObjectButton:SetFullHeight(true)
	subtractObjectButton:SetCallback("OnClick", function()
		Neuron.currentBar:RemoveObjectFromBar()
		NeuronGUI:RefreshEditor()
	end)
	addOrRemoveButtonContainer:AddChild(subtractObjectButton)

	local currentText = Neuron.currentBar:GetNumObjects() --hack to try to keep the number centered between the buttons
	if currentText > 9 then
		currentText = " "..currentText --one space leading two-digit numbers
	else
		currentText = "  "..currentText --two spaces leading one-digit numbers
	end

	currentNumObjectsLabel = AceGUI:Create("Label")
	currentNumObjectsLabel:SetText(currentText)
	currentNumObjectsLabel:SetFont("Fonts\\FRIZQT__.TTF", 20)
	currentNumObjectsLabel:SetRelativeWidth(.3)
	currentNumObjectsLabel:SetFullHeight(true)
	addOrRemoveButtonContainer:AddChild(currentNumObjectsLabel)

	local addObjectButton = AceGUI:Create("Button")
	addObjectButton:SetText("|TInterface\\Buttons\\Arrow-Up-Up:15:15:2:2|t") --this is an escape sequence that gives us an up arrow centered on the button
	addObjectButton:SetRelativeWidth(.35)
	addObjectButton:SetFullHeight(true)
	addObjectButton:SetCallback("OnClick", function()
		Neuron.currentBar:AddObjectToBar()
		NeuronGUI:RefreshEditor()
	end)
	addOrRemoveButtonContainer:AddChild(addObjectButton)

	--------------------------------
	--------------------------------

	--Add or Remove Columns Widget
	local currentNumColumns = Neuron.currentBar:GetColumns()

	if not currentNumColumns then
		currentNumColumns = 0
	end

	local currentNumColumnsContainer = AceGUI:Create("SimpleGroup")
	currentNumColumnsContainer:SetWidth(WIDGET_GRID_WIDTH)
	currentNumColumnsContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(currentNumColumnsContainer)

	local columnSlider = AceGUI:Create("Slider")
	columnSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	columnSlider:SetSliderValues(0,Neuron.currentBar:GetNumObjects(),1)
	columnSlider:SetLabel(L["Columns"])
	columnSlider:SetValue(currentNumColumns)
	columnSlider:SetCallback("OnValueChanged", function(self)
		Neuron.currentBar:SetColumns(self:GetValue())
	end)
	currentNumColumnsContainer:AddChild(columnSlider)

	--Set Scale Widget
	local setScaleContainer = AceGUI:Create("SimpleGroup")
	setScaleContainer:SetWidth(WIDGET_GRID_WIDTH)
	setScaleContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(setScaleContainer)

	local scaleSlider = AceGUI:Create("Slider")
	scaleSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	scaleSlider:SetSliderValues(0.1,2,0.05)
	scaleSlider:SetIsPercent(true)
	scaleSlider:SetLabel(L["Scale"])
	scaleSlider:SetValue(Neuron.currentBar:GetBarScale())
	scaleSlider:SetCallback("OnValueChanged", function(self)
		Neuron.currentBar:SetBarScale(self:GetValue())
	end)
	setScaleContainer:AddChild(scaleSlider)

	--BarShape
	local barShapeDropdownContainer = AceGUI:Create("SimpleGroup")
	barShapeDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
	barShapeDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(barShapeDropdownContainer)

	local barShapeDropdown = AceGUI:Create("Dropdown")
	barShapeDropdown:SetLabel(L["Shape"])
	barShapeDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
	barShapeDropdown:SetList({["linear"] = L["Linear"], ["circle"] = L["Circle"], ["circle + one"] = L["Circle + One"]},
			{[1] = "linear", [2] = "circle", [3] = "circle + one"})
	barShapeDropdown:SetValue(Neuron.currentBar:GetBarShape())
	barShapeDropdown:SetCallback("OnValueChanged", function(_, _, key)
		Neuron.currentBar:SetBarShape(key)
	end)
	barShapeDropdownContainer:AddChild(barShapeDropdown)

	--Set Horizontal Padding Widget
	local horizPadContainer = AceGUI:Create("SimpleGroup")
	horizPadContainer:SetWidth(WIDGET_GRID_WIDTH)
	horizPadContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(horizPadContainer)

	local horizPadSlider = AceGUI:Create("Slider")
	horizPadSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	horizPadSlider:SetSliderValues(-200,200,1)
	horizPadSlider:SetLabel(L["Horizontal Padding"])
	horizPadSlider:SetValue(Neuron.currentBar:GetHorizontalPad())
	horizPadSlider:SetCallback("OnValueChanged", function(self)
		Neuron.currentBar:SetHorizontalPad(self:GetValue())
	end)
	horizPadContainer:AddChild(horizPadSlider)

	--Set Vertical Padding Widget
	local vertPadContainer = AceGUI:Create("SimpleGroup")
	vertPadContainer:SetWidth(WIDGET_GRID_WIDTH)
	vertPadContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(vertPadContainer)

	local vertPadSlider = AceGUI:Create("Slider")
	vertPadSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	vertPadSlider:SetSliderValues(-200,200,1)
	vertPadSlider:SetLabel(L["Vertical Padding"])
	vertPadSlider:SetValue(Neuron.currentBar:GetVerticalPad())
	vertPadSlider:SetCallback("OnValueChanged", function(self)
		Neuron.currentBar:SetVerticalPad(self:GetValue())
	end)
	vertPadContainer:AddChild(vertPadSlider)

	--Set Alpha Widget
	local alphaContainer = AceGUI:Create("SimpleGroup")
	alphaContainer:SetWidth(WIDGET_GRID_WIDTH)
	alphaContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(alphaContainer)

	local alphaSlider = AceGUI:Create("Slider")
	alphaSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	alphaSlider:SetSliderValues(.01,1,.01)
	alphaSlider:SetIsPercent(true)
	alphaSlider:SetLabel(L["Alpha"])
	alphaSlider:SetValue(Neuron.currentBar:GetBarAlpha())
	alphaSlider:SetCallback("OnValueChanged", function(self)
		Neuron.currentBar:SetBarAlpha(self:GetValue())
	end)
	alphaContainer:AddChild(alphaSlider)

	--Alpha Ups Widget
	local AlphaUpDropdownContainer = AceGUI:Create("SimpleGroup")
	AlphaUpDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
	AlphaUpDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(AlphaUpDropdownContainer)

	local alphaUpDropdown = AceGUI:Create("Dropdown")
	alphaUpDropdown:SetLabel(L["AlphaUp"])
	alphaUpDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
	alphaUpDropdown:SetList({["off"] = L["Off"], ["mouseover"] = L["Mouseover"], ["combat"] = L["Combat"], ["combat + mouseover"] = L["Combat + Mouseover"]},
			{[1] = "off", [2] = "mouseover", [3] = "combat", [4] = "combat + mouseover"})
	alphaUpDropdown:SetValue(Neuron.currentBar:GetAlphaUp())
	alphaUpDropdown:SetCallback("OnValueChanged", function(_, _, key)
		Neuron.currentBar:SetAlphaUp(key)
	end)
	AlphaUpDropdownContainer:AddChild(alphaUpDropdown)

	--Set Alpha Up Speed
	local alphaSpeedContainer = AceGUI:Create("SimpleGroup")
	alphaSpeedContainer:SetWidth(WIDGET_GRID_WIDTH)
	alphaSpeedContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(alphaSpeedContainer)

	local alphaSpeedSlider = AceGUI:Create("Slider")
	alphaSpeedSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	alphaSpeedSlider:SetSliderValues(.01,1,.01)
	alphaSpeedSlider:SetIsPercent(true)
	alphaSpeedSlider:SetLabel(L["AlphaUp Speed"])
	alphaSpeedSlider:SetValue(Neuron.currentBar:GetAlphaUpSpeed())
	alphaSpeedSlider:SetCallback("OnValueChanged", function(self)
		Neuron.currentBar:SetAlphaUpSpeed(self:GetValue())
	end)
	alphaSpeedContainer:AddChild(alphaSpeedSlider)

	--Stratas Widget
	local strataDropdownContainer = AceGUI:Create("SimpleGroup")
	strataDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
	strataDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(strataDropdownContainer)

	local strataDropdown = AceGUI:Create("Dropdown")
	strataDropdown:SetLabel(L["Strata"])
	strataDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
	strataDropdown:SetList({[2] = L["Low"], [3] = L["Medium"], [4] = L["High"], [5] = L["Dialog"], [6] = L["Tooltip"]},
			{[1] = 2, [2] = 3, [3] = 4, [4] = 5, [5] = 6})
	strataDropdown:SetValue(Neuron.currentBar:GetStrata())
	strataDropdown:SetCallback("OnValueChanged", function(_, _, key)
		Neuron.currentBar:SetStrata(key)
	end)
	strataDropdownContainer:AddChild(strataDropdown)

	---------------------------------------------------------
	----------------------Style Options----------------------
	---------------------------------------------------------

	if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions then
		--Heading spacer
		local heading3 = AceGUI:Create("Heading")
		heading3:SetHeight(WIDGET_GRID_HEIGHT)
		heading3:SetFullWidth(true)
		heading3:SetText(L["Visuals"])
		scrollFrame:AddChild(heading3)

		--Bind Text
		if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions.BINDTEXT then
			local bindTextContainer = AceGUI:Create("SimpleGroup")
			bindTextContainer:SetWidth(WIDGET_GRID_WIDTH)
			bindTextContainer:SetHeight(WIDGET_GRID_HEIGHT)
			bindTextContainer:SetLayout("Flow")
			scrollFrame:AddChild(bindTextContainer)

			local bindTextCheckbox = AceGUI:Create("CheckBox")
			bindTextCheckbox:SetLabel(L["Keybind Label"])
			bindTextCheckbox:SetRelativeWidth(.70)
			bindTextCheckbox:SetValue(Neuron.currentBar:GetShowBindText())
			bindTextCheckbox:SetCallback("OnValueChanged", function(self)
				Neuron.currentBar:SetShowBindText(self:GetValue())
			end)
			bindTextContainer:AddChild(bindTextCheckbox)

			local bindTextColorPicker = AceGUI:Create("ColorPicker")
			bindTextColorPicker:SetRelativeWidth(.15)
			bindTextColorPicker:SetColor(Neuron.currentBar:GetBindColor()[1],Neuron.currentBar:GetBindColor()[2],Neuron.currentBar:GetBindColor()[3],Neuron.currentBar:GetBindColor()[4])
			bindTextColorPicker:SetCallback("OnValueConfirmed", function(_,_, r,g,b,a)
				Neuron.currentBar:SetBindColor({r,g,b,a})
			end)
			bindTextContainer:AddChild(bindTextColorPicker)
		end

		--Macro Text
		if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions.MACROTEXT then
			local macroTextContainer = AceGUI:Create("SimpleGroup")
			macroTextContainer:SetWidth(WIDGET_GRID_WIDTH)
			macroTextContainer:SetHeight(WIDGET_GRID_HEIGHT)
			macroTextContainer:SetLayout("Flow")
			scrollFrame:AddChild(macroTextContainer)

			local macroTextCheckbox = AceGUI:Create("CheckBox")
			macroTextCheckbox:SetLabel(L["Macro Name"])
			macroTextCheckbox:SetRelativeWidth(.70)
			macroTextCheckbox:SetValue(Neuron.currentBar:GetShowMacroText())
			macroTextCheckbox:SetCallback("OnValueChanged", function(self)
				Neuron.currentBar:SetShowMacroText(self:GetValue())
			end)
			macroTextContainer:AddChild(macroTextCheckbox)

			local macroTextColorPicker = AceGUI:Create("ColorPicker")
			macroTextColorPicker:SetRelativeWidth(.15)
			macroTextColorPicker:SetColor(Neuron.currentBar:GetMacroColor()[1],Neuron.currentBar:GetMacroColor()[2],Neuron.currentBar:GetMacroColor()[3],Neuron.currentBar:GetMacroColor()[4])
			macroTextColorPicker:SetCallback("OnValueConfirmed", function(_,_, r,g,b,a)
				Neuron.currentBar:SetMacroColor({r,g,b,a})
			end)
			macroTextContainer:AddChild(macroTextColorPicker)
		end

		--Count Text
		if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions.COUNTTEXT then
			local countTextContainer = AceGUI:Create("SimpleGroup")
			countTextContainer:SetWidth(WIDGET_GRID_WIDTH)
			countTextContainer:SetHeight(WIDGET_GRID_HEIGHT)
			countTextContainer:SetLayout("Flow")
			scrollFrame:AddChild(countTextContainer)

			local countTextCheckbox = AceGUI:Create("CheckBox")
			countTextCheckbox:SetLabel(L["Stack/Charge"])
			countTextCheckbox:SetRelativeWidth(.70)
			countTextCheckbox:SetValue(Neuron.currentBar:GetShowCountText())
			countTextCheckbox:SetCallback("OnValueChanged", function(self)
				Neuron.currentBar:SetShowCountText(self:GetValue())
			end)
			countTextContainer:AddChild(countTextCheckbox)

			local countTextColorPicker = AceGUI:Create("ColorPicker")
			countTextColorPicker:SetRelativeWidth(.15)
			countTextColorPicker:SetColor(Neuron.currentBar:GetCountColor()[1],Neuron.currentBar:GetCountColor()[2],Neuron.currentBar:GetCountColor()[3],Neuron.currentBar:GetCountColor()[4])
			countTextColorPicker:SetCallback("OnValueConfirmed", function(_,_, r,g,b,a)
				Neuron.currentBar:SetCountColor({r,g,b,a})
			end)
			countTextContainer:AddChild(countTextColorPicker)
		end

		--Range Indicator
		if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions.RANGEIND then
			local rangeIndContainer = AceGUI:Create("SimpleGroup")
			rangeIndContainer:SetWidth(WIDGET_GRID_WIDTH)
			rangeIndContainer:SetHeight(WIDGET_GRID_HEIGHT)
			rangeIndContainer:SetLayout("Flow")
			scrollFrame:AddChild(rangeIndContainer)

			local rangeIndCheckbox = AceGUI:Create("CheckBox")
			rangeIndCheckbox:SetLabel(L["Out-of-Range"])
			rangeIndCheckbox:SetRelativeWidth(.70)
			rangeIndCheckbox:SetValue(Neuron.currentBar:GetShowRangeIndicator())
			rangeIndCheckbox:SetCallback("OnValueChanged", function(self)
				Neuron.currentBar:SetShowRangeIndicator(self:GetValue())
			end)
			rangeIndContainer:AddChild(rangeIndCheckbox)

			local rangIndColorPicker = AceGUI:Create("ColorPicker")
			rangIndColorPicker:SetRelativeWidth(.15)
			rangIndColorPicker:SetColor(Neuron.currentBar:GetRangeColor()[1],Neuron.currentBar:GetRangeColor()[2],Neuron.currentBar:GetRangeColor()[3],Neuron.currentBar:GetRangeColor()[4])
			rangIndColorPicker:SetCallback("OnValueConfirmed", function(_,_, r,g,b,a)
				Neuron.currentBar:SetRangeColor({r,g,b,a})
			end)
			rangeIndContainer:AddChild(rangIndColorPicker)
		end

		--Cooldown Text
		if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions.CDTEXT then
			local cooldownCounterContainer = AceGUI:Create("SimpleGroup")
			cooldownCounterContainer:SetWidth(WIDGET_GRID_WIDTH)
			cooldownCounterContainer:SetHeight(WIDGET_GRID_HEIGHT)
			cooldownCounterContainer:SetLayout("Flow")
			scrollFrame:AddChild(cooldownCounterContainer)

			local cooldownCounterCheckbox = AceGUI:Create("CheckBox")
			cooldownCounterCheckbox:SetLabel(L["CD Counter"])
			cooldownCounterCheckbox:SetRelativeWidth(.70)
			cooldownCounterCheckbox:SetValue(Neuron.currentBar:GetShowCooldownText())
			cooldownCounterCheckbox:SetCallback("OnValueChanged", function(self)
				Neuron.currentBar:SetShowCooldownText(self:GetValue())
			end)
			cooldownCounterContainer:AddChild(cooldownCounterCheckbox)

			local cooldownCounterColorPicker1 = AceGUI:Create("ColorPicker")
			cooldownCounterColorPicker1:SetRelativeWidth(.15)
			cooldownCounterColorPicker1:SetColor(Neuron.currentBar:GetCooldownColor1()[1],Neuron.currentBar:GetCooldownColor1()[2],Neuron.currentBar:GetCooldownColor1()[3],Neuron.currentBar:GetCooldownColor1()[4])
			cooldownCounterColorPicker1:SetCallback("OnValueConfirmed", function(_,_, r,g,b,a)
				Neuron.currentBar:SetCooldownColor1({r,g,b,a})
			end)
			cooldownCounterContainer:AddChild(cooldownCounterColorPicker1)

			local cooldownCounterColorPicker2 = AceGUI:Create("ColorPicker")
			cooldownCounterColorPicker2:SetRelativeWidth(.15)
			cooldownCounterColorPicker2:SetColor(Neuron.currentBar:GetCooldownColor2()[1],Neuron.currentBar:GetCooldownColor2()[2],Neuron.currentBar:GetCooldownColor2()[3],Neuron.currentBar:GetCooldownColor2()[4])
			cooldownCounterColorPicker2:SetCallback("OnValueConfirmed", function(_,_, r,g,b,a)
				Neuron.currentBar:SetCooldownColor2({r,g,b,a})
			end)
			cooldownCounterContainer:AddChild(cooldownCounterColorPicker2)
		end

		--Cooldown Alpha
		if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions.CDALPHA then
			local cooldownAlphaContainer = AceGUI:Create("SimpleGroup")
			cooldownAlphaContainer:SetWidth(WIDGET_GRID_WIDTH)
			cooldownAlphaContainer:SetHeight(WIDGET_GRID_HEIGHT)
			cooldownAlphaContainer:SetLayout("Flow")
			scrollFrame:AddChild(cooldownAlphaContainer)

			local cooldownAlphaCheckbox = AceGUI:Create("CheckBox")
			cooldownAlphaCheckbox:SetLabel(L["Cooldown Alpha"])
			cooldownAlphaCheckbox:SetValue(Neuron.currentBar:GetShowCooldownAlpha())
			cooldownAlphaCheckbox:SetCallback("OnValueChanged", function(self)
				Neuron.currentBar:SetShowCooldownAlpha(self:GetValue())
			end)
			cooldownAlphaContainer:AddChild(cooldownAlphaCheckbox)

		end

		--SpellGlow
		if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions.SPELLGLOW then

			local spellAlertDropdownContainer = AceGUI:Create("SimpleGroup")
			spellAlertDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
			spellAlertDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
			scrollFrame:AddChild(spellAlertDropdownContainer)

			local currentGlow = Neuron.currentBar:GetSpellGlow()
			if not currentGlow then
				currentGlow = "none"
			end

			local spellAlertDropdown = AceGUI:Create("Dropdown")
			spellAlertDropdown:SetLabel(L["Spell Alerts"])
			spellAlertDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
			spellAlertDropdown:SetList({["none"] = L["None"], ["alternate"] = L["Subdued Alert"], ["default"] = L["Default Alert"]},
					{[1] = "none", [2] = "alternate", [3] = "default"})
			spellAlertDropdown:SetValue(currentGlow)
			spellAlertDropdown:SetCallback("OnValueChanged", function(_, _, key)
				Neuron.currentBar:SetSpellGlow(key)
			end)
			spellAlertDropdownContainer:AddChild(spellAlertDropdown)
		end

		--Tooltips
		if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions.TOOLTIPS then

			local tooltipDropdownContainer = AceGUI:Create("SimpleGroup")
			tooltipDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
			tooltipDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
			scrollFrame:AddChild(tooltipDropdownContainer)

			local currentTooltipOption = Neuron.currentBar:GetTooltipOption()
			if not currentTooltipOption then
				currentTooltipOption = "none"
			end

			local tooltipDropdown = AceGUI:Create("Dropdown")
			tooltipDropdown:SetLabel(L["Enable Tooltips"])
			tooltipDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
			tooltipDropdown:SetList({["off"] = L["Off"], ["minimal"] = L["Minimal"], ["normal"] = L["Normal"]},
					{[1] = "off", [2] = "minimal", [3] = "normal"})
			tooltipDropdown:SetValue(currentTooltipOption)
			tooltipDropdown:SetCallback("OnValueChanged", function(_, _, key)
				Neuron.currentBar:SetTooltipOption(key)
			end)

			tooltipDropdownContainer:AddChild(tooltipDropdown)
		end

		--Tooltips in Combat
		if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions.TOOLTIPS then
			local combatTooltipsCheckbox = AceGUI:Create("CheckBox")
			combatTooltipsCheckbox:SetLabel(L["Tooltips in Combat"])
			combatTooltipsCheckbox:SetWidth(WIDGET_GRID_WIDTH)
			combatTooltipsCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
			combatTooltipsCheckbox:SetValue(Neuron.currentBar:GetTooltipCombat())
			combatTooltipsCheckbox:SetCallback("OnValueChanged", function(self)
				Neuron.currentBar:SetTooltipCombat(self:GetValue())
			end)
			scrollFrame:AddChild(combatTooltipsCheckbox)
		end

		--Border Style
		if Neuron.registeredGUIData[Neuron.currentBar.class].styleOptions.BORDERSTYLE then
			local borderStyleCheckbox = AceGUI:Create("CheckBox")
			borderStyleCheckbox:SetLabel(L["Show Border Style"])
			borderStyleCheckbox:SetWidth(WIDGET_GRID_WIDTH)
			borderStyleCheckbox:SetHeight(WIDGET_GRID_HEIGHT)
			borderStyleCheckbox:SetValue(Neuron.currentBar:GetShowBorderStyle())
			borderStyleCheckbox:SetCallback("OnValueChanged", function(self)
				Neuron.currentBar:SetShowBorderStyle(self:GetValue())
			end)
			scrollFrame:AddChild(borderStyleCheckbox)
		end

	end

	--------------------------------------------------
	--------------------------------------------------

	--Heading spacer
	local heading3 = AceGUI:Create("Heading")
	heading3:SetHeight(WIDGET_GRID_HEIGHT)
	heading3:SetFullWidth(true)
	heading3:SetText("Dangerous")
	scrollFrame:AddChild(heading3)

	--Delete Current Bar button
	local deleteBarButton = AceGUI:Create("Button")
	deleteBarButton:SetWidth(WIDGET_GRID_WIDTH*1.5)
	deleteBarButton:SetHeight(WIDGET_GRID_HEIGHT/1.5)
	deleteBarButton:SetText("Delete Current Bar")
	deleteBarButton:SetCallback("OnClick", function() if Neuron.currentBar then NeuronGUI:DeleteBarPopup() end end)
	if not Neuron.currentBar then
		deleteBarButton:SetDisabled(true)
	end
	scrollFrame:AddChild(deleteBarButton)
end

--Delete bar popup menu
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

--Bar Rename
function NeuronGUI:updateBarName(editBox)
	local bar = Neuron.currentBar

	if bar then
		bar:SetBarName(editBox:GetText())
		bar.text:SetText(bar:GetBarName())

		editBox:ClearFocus()
		NeuronGUI:RefreshEditor()
	end
end