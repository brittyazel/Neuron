-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2023 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

local WIDGET_GRID_WIDTH = 165
local WIDGET_GRID_HEIGHT = 45

local INNER_WIDGET_RATIO = 0.95



--------------------------------------------------
--------------------------------------------------

---@param bar Bar
---@param scrollFrame Frame
---@param registeredGUIData any
local function generalBarOptions(bar, scrollFrame, registeredGUIData)
	--------------------------------------------------
	-------------------- AutoHide --------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].generalOptions.AUTOHIDE then
		local autoHideCheckboxContainer = AceGUI:Create("SimpleGroup")
		autoHideCheckboxContainer:SetWidth(WIDGET_GRID_WIDTH)
		autoHideCheckboxContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(autoHideCheckboxContainer)

		local autoHideCheckbox = AceGUI:Create("CheckBox")
		autoHideCheckbox:SetLabel(L["Auto-Hide"])
		autoHideCheckbox:SetRelativeWidth(INNER_WIDGET_RATIO)
		autoHideCheckbox:SetValue(bar:GetAutoHide())
		autoHideCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetAutoHide(self:GetValue())
		end)
		autoHideCheckboxContainer:AddChild(autoHideCheckbox)
	end

	--------------------------------------------------
	-------------------- ShowGrid --------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].generalOptions.SHOWGRID then
		local showGridCheckboxContainer = AceGUI:Create("SimpleGroup")
		showGridCheckboxContainer:SetWidth(WIDGET_GRID_WIDTH)
		showGridCheckboxContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(showGridCheckboxContainer)

		local showGridCheckbox = AceGUI:Create("CheckBox")
		showGridCheckbox:SetLabel(L["Show Grid"])
		showGridCheckbox:SetRelativeWidth(INNER_WIDGET_RATIO)
		showGridCheckbox:SetValue(bar:GetShowGrid())
		showGridCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetShowGrid(self:GetValue())
		end)
		showGridCheckboxContainer:AddChild(showGridCheckbox)
	end

	--------------------------------------------------
	-------------------- SnapTo ----------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].generalOptions.SNAPTO then
		local snapToCheckboxContainer = AceGUI:Create("SimpleGroup")
		snapToCheckboxContainer:SetWidth(WIDGET_GRID_WIDTH)
		snapToCheckboxContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(snapToCheckboxContainer)

		local snapToCheckbox = AceGUI:Create("CheckBox")
		snapToCheckbox:SetLabel(L["SnapTo"])
		snapToCheckbox:SetRelativeWidth(INNER_WIDGET_RATIO)
		snapToCheckbox:SetValue(bar:GetSnapTo())
		snapToCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetSnapTo(self:GetValue())
		end)
		snapToCheckboxContainer:AddChild(snapToCheckbox)
	end

	--------------------------------------------------
	-------------------- MultiSpec -------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].generalOptions.MULTISPEC then
		local multiSpecCheckboxContainer = AceGUI:Create("SimpleGroup")
		multiSpecCheckboxContainer:SetWidth(WIDGET_GRID_WIDTH)
		multiSpecCheckboxContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(multiSpecCheckboxContainer)

		local multiSpecCheckbox = AceGUI:Create("CheckBox")
		multiSpecCheckbox:SetLabel(L["Multi Spec"])
		multiSpecCheckbox:SetRelativeWidth(INNER_WIDGET_RATIO)
		multiSpecCheckbox:SetValue(bar:GetMultiSpec())
		multiSpecCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetMultiSpec(self:GetValue())
		end)
		multiSpecCheckboxContainer:AddChild(multiSpecCheckbox)
	end

	--------------------------------------------------
	-------------------- Hide Bar --------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].generalOptions.HIDDEN then
		local barConcealCheckboxContainer = AceGUI:Create("SimpleGroup")
		barConcealCheckboxContainer:SetWidth(WIDGET_GRID_WIDTH)
		barConcealCheckboxContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(barConcealCheckboxContainer)

		local barConcealCheckbox = AceGUI:Create("CheckBox")
		barConcealCheckbox:SetLabel(L["Hidden"])
		barConcealCheckbox:SetRelativeWidth(INNER_WIDGET_RATIO)
		barConcealCheckbox:SetValue(bar:GetBarConceal())
		barConcealCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetBarConceal(self:GetValue())
		end)
		barConcealCheckboxContainer:AddChild(barConcealCheckbox)
	end

	--------------------------------------------------
	-------------------- Bar Lock --------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].generalOptions.LOCKBAR then
		local spellAlertDropdownContainer = AceGUI:Create("SimpleGroup")
		spellAlertDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
		spellAlertDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(spellAlertDropdownContainer)

		local currentLock = bar:GetBarLock() or "none"

		local spellAlertDropdown = AceGUI:Create("Dropdown")
		spellAlertDropdown:SetLabel(L["Lock Actions"])
		spellAlertDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
		spellAlertDropdown:SetList({["none"] = L["None"], ["shift"] = L["Shift"], ["ctrl"] = L["Ctrl"], ["alt"] = L["Alt"]},
				{[1] = "none", [2] = "shift", [3] = "ctrl", [4] = "alt"})
		spellAlertDropdown:SetValue(currentLock)
		spellAlertDropdown:SetCallback("OnValueChanged", function(_, _, key)
			bar:SetBarLock(key)
		end)
		spellAlertDropdownContainer:AddChild(spellAlertDropdown)
	end

	--------------------------------------------------
	-------------------- Click Mode ------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].generalOptions.CLICKMODE then
		local clickModeDropdownContainer = AceGUI:Create("SimpleGroup")
		clickModeDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
		clickModeDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(clickModeDropdownContainer)

		local clickModeDropdown = AceGUI:Create("Dropdown")
		clickModeDropdown:SetLabel(L["Click Mode"])
		clickModeDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
		clickModeDropdown:SetList({["UpClick"] = L["On Release"], ["DownClick"] = L["On Click"]},
				{[1] = "UpClick", [2] = "DownClick"})
		clickModeDropdown:SetValue(bar:GetClickMode())
		clickModeDropdown:SetCallback("OnValueChanged", function(_, _, key)
			bar:SetClickMode(key)
		end)
		clickModeDropdownContainer:AddChild(clickModeDropdown)
	end
end


---@param bar Bar
---@param scrollFrame Frame
local function layoutBarOptions(bar, scrollFrame)
	--------------------------------------------------
	--------------- Add/Remove Button ----------------
	--------------------------------------------------
	local addOrRemoveButtonContainer = AceGUI:Create("InlineGroup")
	addOrRemoveButtonContainer:SetWidth(WIDGET_GRID_WIDTH)
	addOrRemoveButtonContainer:SetHeight(WIDGET_GRID_HEIGHT)
	addOrRemoveButtonContainer:SetLayout("Flow")
	addOrRemoveButtonContainer:SetTitle(L["Buttons"])
	scrollFrame:AddChild(addOrRemoveButtonContainer)

	local currentText = bar:GetNumObjects() --hack to try to keep the number centered between the buttons
	if currentText > 9 then
		currentText = " "..currentText --one space leading two-digit numbers
	else
		currentText = "  "..currentText --two spaces leading one-digit numbers
	end

	local subtractObjectButton = AceGUI:Create("Button")
	subtractObjectButton:SetText("|TInterface\\Buttons\\Arrow-Down-Up:15:15:2:-5|t") --this is an escape sequence that gives us a down arrow centered on the button
	subtractObjectButton:SetRelativeWidth(.35)
	subtractObjectButton:SetCallback("OnClick", function()
		bar:RemoveObjectFromBar()
		NeuronGUI:RefreshEditor()
	end)
	addOrRemoveButtonContainer:AddChild(subtractObjectButton)

	local currentNumObjectsLabel = AceGUI:Create("Label")
	currentNumObjectsLabel:SetText(currentText)
	currentNumObjectsLabel:SetFont("Fonts\\FRIZQT__.TTF", 20, "")
	currentNumObjectsLabel:SetRelativeWidth(.3)
	addOrRemoveButtonContainer:AddChild(currentNumObjectsLabel)

	local addObjectButton = AceGUI:Create("Button")
	addObjectButton:SetText("|TInterface\\Buttons\\Arrow-Up-Up:15:15:2:2|t") --this is an escape sequence that gives us an up arrow centered on the button
	addObjectButton:SetRelativeWidth(.35)
	addObjectButton:SetCallback("OnClick", function()
		bar:AddObjectToBar()
		NeuronGUI:RefreshEditor()
	end)
	addOrRemoveButtonContainer:AddChild(addObjectButton)

	--------------------------------------------------
	--------------- Add/Remove Column ----------------
	--------------------------------------------------
	local currentNumColumnsContainer = AceGUI:Create("SimpleGroup")
	currentNumColumnsContainer:SetWidth(WIDGET_GRID_WIDTH)
	currentNumColumnsContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(currentNumColumnsContainer)

	local columnSlider = AceGUI:Create("Slider")
	columnSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	columnSlider:SetSliderValues(0,bar:GetNumObjects(),1)
	columnSlider:SetLabel(L["Columns"])
	columnSlider:SetValue(bar:GetColumns())
	columnSlider:SetCallback("OnValueChanged", function(self)
		bar:SetColumns(self:GetValue())
	end)
	currentNumColumnsContainer:AddChild(columnSlider)

	--------------------------------------------------
	-------------------- Set Scale -------------------
	--------------------------------------------------
	local setScaleContainer = AceGUI:Create("SimpleGroup")
	setScaleContainer:SetWidth(WIDGET_GRID_WIDTH)
	setScaleContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(setScaleContainer)

	local scaleSlider = AceGUI:Create("Slider")
	scaleSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	scaleSlider:SetSliderValues(0.1,2,0.05)
	scaleSlider:SetIsPercent(true)
	scaleSlider:SetLabel(L["Scale"])
	scaleSlider:SetValue(bar:GetBarScale())
	scaleSlider:SetCallback("OnValueChanged", function(self)
		bar:SetBarScale(self:GetValue())
	end)
	setScaleContainer:AddChild(scaleSlider)

	--------------------------------------------------
	-------------------- Bar Shape -------------------
	--------------------------------------------------
	local barShapeDropdownContainer = AceGUI:Create("SimpleGroup")
	barShapeDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
	barShapeDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(barShapeDropdownContainer)

	local barShapeDropdown = AceGUI:Create("Dropdown")
	barShapeDropdown:SetLabel(L["Shape"])
	barShapeDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
	barShapeDropdown:SetList({["linear"] = L["Linear"], ["circle"] = L["Circle"], ["circle + one"] = L["Circle + One"]},
			{[1] = "linear", [2] = "circle", [3] = "circle + one"})
	barShapeDropdown:SetValue(bar:GetBarShape())
	barShapeDropdown:SetCallback("OnValueChanged", function(_, _, key)
		bar:SetBarShape(key)
	end)
	barShapeDropdownContainer:AddChild(barShapeDropdown)

	--------------------------------------------------
	--------------- Horizontal Padding ---------------
	--------------------------------------------------
	local horizPadContainer = AceGUI:Create("SimpleGroup")
	horizPadContainer:SetWidth(WIDGET_GRID_WIDTH)
	horizPadContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(horizPadContainer)

	local horizPadSlider = AceGUI:Create("Slider")
	horizPadSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	horizPadSlider:SetSliderValues(-200,200,1)
	horizPadSlider:SetLabel(L["Horizontal Padding"])
	horizPadSlider:SetValue(bar:GetHorizontalPad())
	horizPadSlider:SetCallback("OnValueChanged", function(self)
		bar:SetHorizontalPad(self:GetValue())
	end)
	horizPadContainer:AddChild(horizPadSlider)

	--------------------------------------------------
	----------------- Vertical Padding ---------------
	--------------------------------------------------
	local vertPadContainer = AceGUI:Create("SimpleGroup")
	vertPadContainer:SetWidth(WIDGET_GRID_WIDTH)
	vertPadContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(vertPadContainer)

	local vertPadSlider = AceGUI:Create("Slider")
	vertPadSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	vertPadSlider:SetSliderValues(-200,200,1)
	vertPadSlider:SetLabel(L["Vertical Padding"])
	vertPadSlider:SetValue(bar:GetVerticalPad())
	vertPadSlider:SetCallback("OnValueChanged", function(self)
		bar:SetVerticalPad(self:GetValue())
	end)
	vertPadContainer:AddChild(vertPadSlider)

	--------------------------------------------------
	-------------------- Set Alpha -------------------
	--------------------------------------------------
	local alphaContainer = AceGUI:Create("SimpleGroup")
	alphaContainer:SetWidth(WIDGET_GRID_WIDTH)
	alphaContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(alphaContainer)

	local alphaSlider = AceGUI:Create("Slider")
	alphaSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	alphaSlider:SetSliderValues(.01,1,.01)
	alphaSlider:SetIsPercent(true)
	alphaSlider:SetLabel(L["Alpha"])
	alphaSlider:SetValue(bar:GetBarAlpha())
	alphaSlider:SetCallback("OnValueChanged", function(self)
		bar:SetBarAlpha(self:GetValue())
	end)
	alphaContainer:AddChild(alphaSlider)

	--------------------------------------------------
	-------------------- Alpha Up --------------------
	--------------------------------------------------
	local AlphaUpDropdownContainer = AceGUI:Create("SimpleGroup")
	AlphaUpDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
	AlphaUpDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(AlphaUpDropdownContainer)

	local alphaUpDropdown = AceGUI:Create("Dropdown")
	alphaUpDropdown:SetLabel(L["AlphaUp"])
	alphaUpDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
	alphaUpDropdown:SetList({["off"] = L["Off"], ["mouseover"] = L["Mouseover"], ["combat"] = L["Combat"], ["combat + mouseover"] = L["Combat + Mouseover"]},
			{[1] = "off", [2] = "mouseover", [3] = "combat", [4] = "combat + mouseover"})
	alphaUpDropdown:SetValue(bar:GetAlphaUp())
	alphaUpDropdown:SetCallback("OnValueChanged", function(_, _, key)
		bar:SetAlphaUp(key)
	end)
	AlphaUpDropdownContainer:AddChild(alphaUpDropdown)

	--------------------------------------------------
	--------------- Alpha Up Speed -------------------
	--------------------------------------------------
	local alphaSpeedContainer = AceGUI:Create("SimpleGroup")
	alphaSpeedContainer:SetWidth(WIDGET_GRID_WIDTH)
	alphaSpeedContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(alphaSpeedContainer)

	local alphaSpeedSlider = AceGUI:Create("Slider")
	alphaSpeedSlider:SetRelativeWidth(INNER_WIDGET_RATIO)
	alphaSpeedSlider:SetSliderValues(.01,1,.01)
	alphaSpeedSlider:SetIsPercent(true)
	alphaSpeedSlider:SetLabel(L["AlphaUp Speed"])
	alphaSpeedSlider:SetValue(bar:GetAlphaUpSpeed())
	alphaSpeedSlider:SetCallback("OnValueChanged", function(self)
		bar:SetAlphaUpSpeed(self:GetValue())
	end)
	alphaSpeedContainer:AddChild(alphaSpeedSlider)

	--------------------------------------------------
	-------------------- Set Strata ------------------
	--------------------------------------------------
	local strataDropdownContainer = AceGUI:Create("SimpleGroup")
	strataDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
	strataDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(strataDropdownContainer)

	local strataDropdown = AceGUI:Create("Dropdown")
	strataDropdown:SetLabel(L["Strata"])
	strataDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
	strataDropdown:SetList({[2] = L["Low"], [3] = L["Medium"], [4] = L["High"], [5] = L["Dialog"], [6] = L["Tooltip"]},
			{[1] = 2, [2] = 3, [3] = 4, [4] = 5, [5] = 6})
	strataDropdown:SetValue(bar:GetStrata())
	strataDropdown:SetCallback("OnValueChanged", function(_, _, key)
		bar:SetStrata(key)
	end)
	strataDropdownContainer:AddChild(strataDropdown)
end


---@param bar Bar
---@param scrollFrame Frame
---@param registeredGUIData any
local function visualBarOptions(bar, scrollFrame, registeredGUIData)
	--------------------------------------------------
	-------------------- Bind Text -------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].visualOptions.BINDTEXT then
		local bindTextContainer = AceGUI:Create("SimpleGroup")
		bindTextContainer:SetWidth(WIDGET_GRID_WIDTH)
		bindTextContainer:SetHeight(WIDGET_GRID_HEIGHT)
		bindTextContainer:SetLayout("Flow")
		scrollFrame:AddChild(bindTextContainer)

		local bindTextCheckbox = AceGUI:Create("CheckBox")
		bindTextCheckbox:SetLabel(L["Keybind Label"])
		bindTextCheckbox:SetRelativeWidth(.70)
		bindTextCheckbox:SetValue(bar:GetShowBindText())
		bindTextCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetShowBindText(self:GetValue())
		end)
		bindTextContainer:AddChild(bindTextCheckbox)

		local bindTextColorPicker = AceGUI:Create("ColorPicker")
		bindTextColorPicker:SetRelativeWidth(.15)
		bindTextColorPicker:SetColor(bar:GetBindColor()[1],bar:GetBindColor()[2],bar:GetBindColor()[3])
		bindTextColorPicker:SetCallback("OnValueConfirmed", function(_,_, r,g,b,a)
			bar:SetBindColor({r,g,b,a})
		end)
		bindTextContainer:AddChild(bindTextColorPicker)
	end

	--------------------------------------------------
	------------------- Macro Text -------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].visualOptions.BUTTONTEXT then
		local macroTextContainer = AceGUI:Create("SimpleGroup")
		macroTextContainer:SetWidth(WIDGET_GRID_WIDTH)
		macroTextContainer:SetHeight(WIDGET_GRID_HEIGHT)
		macroTextContainer:SetLayout("Flow")
		scrollFrame:AddChild(macroTextContainer)

		local macroTextCheckbox = AceGUI:Create("CheckBox")
		macroTextCheckbox:SetLabel(L["Button Name"])
		macroTextCheckbox:SetRelativeWidth(.70)
		macroTextCheckbox:SetValue(bar:GetShowButtonText())
		macroTextCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetShowButtonText(self:GetValue())
		end)
		macroTextContainer:AddChild(macroTextCheckbox)

		local macroTextColorPicker = AceGUI:Create("ColorPicker")
		macroTextColorPicker:SetRelativeWidth(.15)
		macroTextColorPicker:SetColor(bar:GetMacroColor()[1],bar:GetMacroColor()[2],bar:GetMacroColor()[3])
		macroTextColorPicker:SetCallback("OnValueConfirmed", function(_,_, r,g,b,a)
			bar:SetMacroColor({r,g,b,a})
		end)
		macroTextContainer:AddChild(macroTextColorPicker)
	end

	--------------------------------------------------
	-------------------- Count Text ------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].visualOptions.COUNTTEXT then
		local countTextContainer = AceGUI:Create("SimpleGroup")
		countTextContainer:SetWidth(WIDGET_GRID_WIDTH)
		countTextContainer:SetHeight(WIDGET_GRID_HEIGHT)
		countTextContainer:SetLayout("Flow")
		scrollFrame:AddChild(countTextContainer)

		local countTextCheckbox = AceGUI:Create("CheckBox")
		countTextCheckbox:SetLabel(L["Stack/Charge"])
		countTextCheckbox:SetRelativeWidth(.70)
		countTextCheckbox:SetValue(bar:GetShowCountText())
		countTextCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetShowCountText(self:GetValue())
		end)
		countTextContainer:AddChild(countTextCheckbox)

		local countTextColorPicker = AceGUI:Create("ColorPicker")
		countTextColorPicker:SetRelativeWidth(.15)
		countTextColorPicker:SetColor(bar:GetCountColor()[1],bar:GetCountColor()[2],bar:GetCountColor()[3])
		countTextColorPicker:SetCallback("OnValueConfirmed", function(_,_, r,g,b,a)
			bar:SetCountColor({r,g,b,a})
		end)
		countTextContainer:AddChild(countTextColorPicker)
	end

	--------------------------------------------------
	------------------ Range Indicator ---------------
	--------------------------------------------------
	if registeredGUIData[bar.class].visualOptions.RANGEIND then
		local rangeIndContainer = AceGUI:Create("SimpleGroup")
		rangeIndContainer:SetWidth(WIDGET_GRID_WIDTH)
		rangeIndContainer:SetHeight(WIDGET_GRID_HEIGHT)
		rangeIndContainer:SetLayout("Flow")
		scrollFrame:AddChild(rangeIndContainer)

		local rangeIndCheckbox = AceGUI:Create("CheckBox")
		rangeIndCheckbox:SetLabel(L["Out-of-Range"])
		rangeIndCheckbox:SetRelativeWidth(.70)
		rangeIndCheckbox:SetValue(bar:GetShowRangeIndicator())
		rangeIndCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetShowRangeIndicator(self:GetValue())
		end)
		rangeIndContainer:AddChild(rangeIndCheckbox)

		local rangIndColorPicker = AceGUI:Create("ColorPicker")
		rangIndColorPicker:SetRelativeWidth(.15)
		rangIndColorPicker:SetColor(bar:GetRangeColor()[1],bar:GetRangeColor()[2],bar:GetRangeColor()[3])
		rangIndColorPicker:SetCallback("OnValueConfirmed", function(_,_, r,g,b,a)
			bar:SetRangeColor({r,g,b,a})
		end)
		rangeIndContainer:AddChild(rangIndColorPicker)
	end

	--------------------------------------------------
	------------------ Cooldown Text -----------------
	--------------------------------------------------
	if registeredGUIData[bar.class].visualOptions.CDTEXT then
		local cooldownCounterContainer = AceGUI:Create("SimpleGroup")
		cooldownCounterContainer:SetWidth(WIDGET_GRID_WIDTH)
		cooldownCounterContainer:SetHeight(WIDGET_GRID_HEIGHT)
		cooldownCounterContainer:SetLayout("Flow")
		scrollFrame:AddChild(cooldownCounterContainer)

		local cooldownCounterCheckbox = AceGUI:Create("CheckBox")
		cooldownCounterCheckbox:SetLabel(L["CD Counter"])
		cooldownCounterCheckbox:SetRelativeWidth(.70)
		cooldownCounterCheckbox:SetValue(bar:GetShowCooldownText())
		cooldownCounterCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetShowCooldownText(self:GetValue())
		end)
		cooldownCounterContainer:AddChild(cooldownCounterCheckbox)

		local cooldownCounterColorPicker1 = AceGUI:Create("ColorPicker")
		cooldownCounterColorPicker1:SetRelativeWidth(.15)
		cooldownCounterColorPicker1:SetColor(bar:GetCooldownColor1()[1],bar:GetCooldownColor1()[2],bar:GetCooldownColor1()[3])
		cooldownCounterColorPicker1:SetCallback("OnValueConfirmed", function(_,_, r,g,b)
			bar:SetCooldownColor1({r,g,b})
		end)
		cooldownCounterContainer:AddChild(cooldownCounterColorPicker1)

		local cooldownCounterColorPicker2 = AceGUI:Create("ColorPicker")
		cooldownCounterColorPicker2:SetRelativeWidth(.15)
		cooldownCounterColorPicker2:SetColor(bar:GetCooldownColor2()[1],bar:GetCooldownColor2()[2],bar:GetCooldownColor2()[3])
		cooldownCounterColorPicker2:SetCallback("OnValueConfirmed", function(_,_, r,g,b)
			bar:SetCooldownColor2({r,g,b})
		end)
		cooldownCounterContainer:AddChild(cooldownCounterColorPicker2)
	end

	--------------------------------------------------
	------------------ Cooldown Alpha ----------------
	--------------------------------------------------
	if registeredGUIData[bar.class].visualOptions.CDALPHA then
		local cooldownAlphaContainer = AceGUI:Create("SimpleGroup")
		cooldownAlphaContainer:SetWidth(WIDGET_GRID_WIDTH)
		cooldownAlphaContainer:SetHeight(WIDGET_GRID_HEIGHT)
		cooldownAlphaContainer:SetLayout("Flow")
		scrollFrame:AddChild(cooldownAlphaContainer)

		local cooldownAlphaCheckbox = AceGUI:Create("CheckBox")
		cooldownAlphaCheckbox:SetLabel(L["Cooldown Alpha"])
		cooldownAlphaCheckbox:SetValue(bar:GetShowCooldownAlpha())
		cooldownAlphaCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetShowCooldownAlpha(self:GetValue())
		end)
		cooldownAlphaContainer:AddChild(cooldownAlphaCheckbox)

	end

	--------------------------------------------------
	------------------ SpellGlow ---------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].visualOptions.SPELLGLOW then
		local spellAlertDropdownContainer = AceGUI:Create("SimpleGroup")
		spellAlertDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
		spellAlertDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(spellAlertDropdownContainer)

		local currentGlow = bar:GetSpellGlow() or "none"

		local spellAlertDropdown = AceGUI:Create("Dropdown")
		spellAlertDropdown:SetLabel(L["Spell Alerts"])
		spellAlertDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
		spellAlertDropdown:SetList({["none"] = L["None"], ["alternate"] = L["Subdued Alert"], ["default"] = L["Default Alert"]},
				{[1] = "none", [2] = "alternate", [3] = "default"})
		spellAlertDropdown:SetValue(currentGlow)
		spellAlertDropdown:SetCallback("OnValueChanged", function(_, _, key)
			bar:SetSpellGlow(key)
		end)
		spellAlertDropdownContainer:AddChild(spellAlertDropdown)
	end

	--------------------------------------------------
	-------------------- Tooltips --------------------
	--------------------------------------------------
	if registeredGUIData[bar.class].visualOptions.TOOLTIPS then
		local tooltipDropdownContainer = AceGUI:Create("SimpleGroup")
		tooltipDropdownContainer:SetWidth(WIDGET_GRID_WIDTH)
		tooltipDropdownContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(tooltipDropdownContainer)

		local currentTooltipOption = bar:GetTooltipOption()

		local tooltipDropdown = AceGUI:Create("Dropdown")
		tooltipDropdown:SetLabel(L["Enable Tooltips"])
		tooltipDropdown:SetRelativeWidth(INNER_WIDGET_RATIO)
		tooltipDropdown:SetList({["off"] = L["Off"], ["minimal"] = L["Minimal"], ["normal"] = L["Normal"]},
				{[1] = "off", [2] = "minimal", [3] = "normal"})
		tooltipDropdown:SetValue(currentTooltipOption)
		tooltipDropdown:SetCallback("OnValueChanged", function(_, _, key)
			bar:SetTooltipOption(key)
		end)

		tooltipDropdownContainer:AddChild(tooltipDropdown)
	end

	--------------------------------------------------
	------------------Tooltips in Combat -------------
	--------------------------------------------------
	if registeredGUIData[bar.class].visualOptions.TOOLTIPS then
		local combatTooltipsCheckboxContainer = AceGUI:Create("SimpleGroup")
		combatTooltipsCheckboxContainer:SetWidth(WIDGET_GRID_WIDTH)
		combatTooltipsCheckboxContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(combatTooltipsCheckboxContainer)

		local combatTooltipsCheckbox = AceGUI:Create("CheckBox")
		combatTooltipsCheckbox:SetLabel(L["Tooltips in Combat"])
		combatTooltipsCheckbox:SetRelativeWidth(INNER_WIDGET_RATIO)
		combatTooltipsCheckbox:SetValue(bar:GetTooltipCombat())
		combatTooltipsCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetTooltipCombat(self:GetValue())
		end)
		combatTooltipsCheckboxContainer:AddChild(combatTooltipsCheckbox)
	end

	--------------------------------------------------
	------------------- Border Style -----------------
	--------------------------------------------------
	if registeredGUIData[bar.class].visualOptions.BORDERSTYLE then
		local borderStyleCheckboxContainer = AceGUI:Create("SimpleGroup")
		borderStyleCheckboxContainer:SetWidth(WIDGET_GRID_WIDTH)
		borderStyleCheckboxContainer:SetHeight(WIDGET_GRID_HEIGHT)
		scrollFrame:AddChild(borderStyleCheckboxContainer)

		local borderStyleCheckbox = AceGUI:Create("CheckBox")
		borderStyleCheckbox:SetLabel(L["Show Border Style"])
		borderStyleCheckbox:SetRelativeWidth(INNER_WIDGET_RATIO)
		borderStyleCheckbox:SetValue(bar:GetShowBorderStyle())
		borderStyleCheckbox:SetCallback("OnValueChanged", function(self)
			bar:SetShowBorderStyle(self:GetValue())
		end)
		borderStyleCheckboxContainer:AddChild(borderStyleCheckbox)
	end
end

--------------------------------------------------
--------------------------------------------------

--Delete bar popup menu
---@param bar Bar
local function deleteBarPopup(bar)
	StaticPopupDialogs["Delete_Bar_Popup"] = {
		text = "Do you really wish to delete "..bar:GetBarName().."?",
		button1 = ACCEPT,
		button2 = CANCEL,
		timeout = 0,
		whileDead = true,
		OnAccept = function() bar:DeleteBar(); NeuronGUI:RefreshEditor() end,
		OnCancel = function() NeuronGUI:RefreshEditor() end,
	}
	StaticPopup_Show("Delete_Bar_Popup")
end

--Bar Rename
---@param bar Bar
---@param editBox any
local function updateBarName(bar, editBox)
	if bar then
		bar:SetBarName(editBox:GetText())

		editBox:ClearFocus()
		NeuronGUI:RefreshEditor()
	end
end

---@param bar Bar
---@param tabFrame Frame
function NeuronGUI:GeneralConfigPanel(bar, tabFrame)
	local registeredGUIData = Neuron:RegisterGUI()

	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("Flow")
	tabFrame:AddChild(scrollFrame)

	--------------------------------------------------
	-------------------- Rename Bar ------------------
	--------------------------------------------------
	local renameBoxContainer = AceGUI:Create("SimpleGroup")
	renameBoxContainer:SetWidth(WIDGET_GRID_WIDTH*1.5)
	renameBoxContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(renameBoxContainer)

	local renameBox = AceGUI:Create("EditBox")
	renameBox:SetRelativeWidth(INNER_WIDGET_RATIO)
	renameBox:SetLabel("Rename selected bar:")
	renameBox:SetText(bar:GetBarName())
	renameBox:SetCallback("OnEnterPressed", function(editBox) updateBarName(bar, editBox) end)
	renameBoxContainer:AddChild(renameBox)

	------------------------------------------------
	------------------------------------------------
	--General Options Heading
	local heading1 = AceGUI:Create("Heading")
	heading1:SetHeight(WIDGET_GRID_HEIGHT)
	heading1:SetFullWidth(true)
	heading1:SetText(L["General Options"])
	scrollFrame:AddChild(heading1)

	generalBarOptions(bar, scrollFrame, registeredGUIData)

	------------------------------------------------
	------------------------------------------------
	--Layout Heading
	local heading2 = AceGUI:Create("Heading")
	heading2:SetHeight(WIDGET_GRID_HEIGHT)
	heading2:SetFullWidth(true)
	heading2:SetText(L["Size and Shape"])
	scrollFrame:AddChild(heading2)

	layoutBarOptions(bar, scrollFrame)

	------------------------------------------------
	------------------------------------------------
	if registeredGUIData[bar.class].visualOptions then
		--Visual Heading
		local heading3 = AceGUI:Create("Heading")
		heading3:SetHeight(WIDGET_GRID_HEIGHT)
		heading3:SetFullWidth(true)
		heading3:SetText(L["Visuals"])
		scrollFrame:AddChild(heading3)

		visualBarOptions(bar, scrollFrame, registeredGUIData)
	end

	--------------------------------------------------
	--------------------------------------------------
	--Dangerous Heading
	local heading4 = AceGUI:Create("Heading")
	heading4:SetHeight(WIDGET_GRID_HEIGHT)
	heading4:SetFullWidth(true)
	heading4:SetText("Dangerous")
	scrollFrame:AddChild(heading4)

	--------------------------------------------------
	------------------ Delete Bar --------------------
	--------------------------------------------------
	local deleteBarButtonContainer = AceGUI:Create("SimpleGroup")
	deleteBarButtonContainer:SetWidth(WIDGET_GRID_WIDTH*1.5)
	deleteBarButtonContainer:SetHeight(WIDGET_GRID_HEIGHT)
	scrollFrame:AddChild(deleteBarButtonContainer)

	local deleteBarButton = AceGUI:Create("Button")
	deleteBarButton:SetRelativeWidth(INNER_WIDGET_RATIO)
	deleteBarButton:SetText("Delete Current Bar")
	deleteBarButton:SetCallback("OnClick", function() deleteBarPopup(bar) end)
	deleteBarButtonContainer:AddChild(deleteBarButton)
end

