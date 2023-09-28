-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2023 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

local Array = addonTable.utilities.Array

local function statusButtonOptions(button)
	local statusContainer = AceGUI:Create("SimpleGroup")
	statusContainer:SetFullWidth(true)
	statusContainer:SetLayout("Flow")

	local widthSlider = AceGUI:Create("Slider")
	widthSlider:SetSliderValues(10,1000,1)
	widthSlider:SetLabel(L["Width"])
	widthSlider:SetValue(button.config.width)
	widthSlider:SetCallback("OnValueChanged", function(_,_,value)
		button:UpdateWidth(value)
	end)
	statusContainer:AddChild(widthSlider)

	local heightSlider = AceGUI:Create("Slider")
	heightSlider:SetSliderValues(4,200,1)
	heightSlider:SetLabel(L["Height"])
	heightSlider:SetValue(button.config.height)
	heightSlider:SetCallback("OnValueChanged", function(_,_,value)
		button:UpdateHeight(value)
	end)
	statusContainer:AddChild(heightSlider)

	local barfillDropdown = AceGUI:Create("Dropdown")
	barfillDropdown:SetLabel(L["Bar Fill"])
	barfillDropdown:SetList(
    Array.map(function(fill) return fill[3] end, Neuron.BAR_TEXTURES)
  )
  barfillDropdown:SetValue(button.config.texture)
	barfillDropdown:SetCallback("OnValueChanged", function(_, _, index)
		button:UpdateBarFill(index)
	end)
  statusContainer:AddChild(barfillDropdown)

	local borderDropdown = AceGUI:Create("Dropdown")
	borderDropdown:SetLabel(L["Border"])
	borderDropdown:SetList(
    Array.map(function(border) return border[1] end, Neuron.BAR_BORDERS)
  )
  borderDropdown:SetValue(button.config.border)
	borderDropdown:SetCallback("OnValueChanged", function(_, _, index)
		button:UpdateBorder(index)
	end)
	statusContainer:AddChild(borderDropdown)

	local orientationDropdown = AceGUI:Create("Dropdown")
	orientationDropdown:SetLabel(L["Orientation"])
	orientationDropdown:SetList(Neuron.BAR_ORIENTATIONS)
  orientationDropdown:SetValue(button.config.orientation)
	orientationDropdown:SetCallback("OnValueChanged", function(_, _, index)
		button:UpdateOrientation(index)
	end)
	statusContainer:AddChild(orientationDropdown)

	local centerTextDropdown = AceGUI:Create("Dropdown")
	centerTextDropdown:SetLabel(L["Center Text"])
	centerTextDropdown:SetList(
    Array.map(function(sbString) return sbString[1] end, button.sbStrings)
  )
  centerTextDropdown:SetValue(button.config.cIndex)
	centerTextDropdown:SetCallback("OnValueChanged", function(_, _, index)
		button:UpdateCenterText(index)
	end)
	statusContainer:AddChild(centerTextDropdown)

	local leftTextDropdown = AceGUI:Create("Dropdown")
	leftTextDropdown:SetLabel(L["Left Text"])
	leftTextDropdown:SetList(
    Array.map(function(sbString) return sbString[1] end, button.sbStrings)
  )
  leftTextDropdown:SetValue(button.config.lIndex)
	leftTextDropdown:SetCallback("OnValueChanged", function(_, _, index)
		button:UpdateLeftText(index)
	end)
	statusContainer:AddChild(leftTextDropdown)

	local rightTextDropdown = AceGUI:Create("Dropdown")
	rightTextDropdown:SetLabel(L["Right Text"])
	rightTextDropdown:SetList(
    Array.map(function(sbString) return sbString[1] end, button.sbStrings)
  )
  rightTextDropdown:SetValue(button.config.rIndex)
	rightTextDropdown:SetCallback("OnValueChanged", function(_, _, index)
		button:UpdateRightText(index)
	end)
	statusContainer:AddChild(rightTextDropdown)

	local mouseoverTextDropdown = AceGUI:Create("Dropdown")
	mouseoverTextDropdown:SetLabel(L["Mouseover Text"])
	mouseoverTextDropdown:SetList(
    Array.map(function(sbString) return sbString[1] end, button.sbStrings)
  )
  mouseoverTextDropdown:SetValue(button.config.mIndex)
	mouseoverTextDropdown:SetCallback("OnValueChanged", function(_, _, index)
		button:UpdateMouseover(index)
	end)
	statusContainer:AddChild(mouseoverTextDropdown)

	local tooltipTextDropdown = AceGUI:Create("Dropdown")
	tooltipTextDropdown:SetLabel(L["Tooltip Text"])
	tooltipTextDropdown:SetList(
    Array.map(function(sbString) return sbString[1] end, button.sbStrings)
  )
  tooltipTextDropdown:SetValue(button.config.tIndex)
	tooltipTextDropdown:SetCallback("OnValueChanged", function(_, _, index)
		button:UpdateTooltip(index)
	end)
	statusContainer:AddChild(tooltipTextDropdown)

  return statusContainer
end

local function castButtonOptions(button)
	local castContainer = AceGUI:Create("SimpleGroup")
	castContainer:SetFullWidth(true)
	castContainer:SetLayout("Flow")

  local castIconCheckbox = AceGUI:Create("CheckBox")
  castIconCheckbox:SetLabel(L["Cast Icon"])
  castIconCheckbox:SetValue(button.config.showIcon)
  castIconCheckbox:SetCallback("OnValueChanged", function(_,_,value)
    button:SetShowIcon(value)
  end)
  castContainer:AddChild(castIconCheckbox)

  local barUnits = {
    "player",
    "pet",
    "target",
    "targettarget",
    "focus",
    "mouseover",
    "party1",
    "party2",
    "party3",
    "party4"
  }
  local currentUnitIndex = Array.find(function(unit) return unit == button.config.unit end, barUnits)
	local unitDropdown = AceGUI:Create("Dropdown")
	unitDropdown:SetLabel(L["Tooltip Text"])
	unitDropdown:SetList(barUnits)
  unitDropdown:SetValue(currentUnitIndex)
	unitDropdown:SetCallback("OnValueChanged", function(_, _, index)
		button:SetUnit(barUnits[index])
	end)
	castContainer:AddChild(unitDropdown)

  return castContainer
end

---@param button CastButton|ExpButton|MirrorButton|RepButton
---@param tabFrame Frame
function NeuronGUI:ButtonStatusEditPanel(button, tabFrame)
	Neuron.ToggleButtonEditMode(true)

  -- weird stuff happens if we don't wrap this in a group
  -- like dropdowns showing at the bottom of the screen and stuff
	local settingContainer = AceGUI:Create("SimpleGroup")
	settingContainer:SetFullWidth(true)
	settingContainer:SetLayout("Flow")


  --sometimes the apply button doesn't appear
  --so far it doesn't seem to happen when it is in
  --it's own group :-/
	local reloadButtonContainer = AceGUI:Create("SimpleGroup")
	reloadButtonContainer:SetFullWidth(true)
	reloadButtonContainer:SetLayout("Flow")

  --visibility status doesn't apply properly
  --so just suggest a ui reload with this apply button
  local reloadButton = AceGUI:Create("Button")
  reloadButton:SetText(L["Apply"])
  reloadButton:SetCallback("OnClick", ReloadUI)
  reloadButtonContainer:AddChild(reloadButton)

  settingContainer:AddChild(statusButtonOptions(button))
  if button.bar.barType == "CastBar" then
    settingContainer:AddChild(castButtonOptions(button))
  end
  settingContainer:AddChild(reloadButtonContainer)
  tabFrame:AddChild(settingContainer)
end
