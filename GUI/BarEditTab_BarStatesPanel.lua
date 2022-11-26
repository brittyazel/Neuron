-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")
local Array = addonTable.utilities.Array


---@return Frame @a dropdown widget
local function actionBarKindOptions()
  local barKinds = {"paged", "stance", "pet"}
  local currentKind = Array.foldl(
    function (kind, candidate)
      return Neuron.currentBar.data[candidate] and candidate or kind
    end,
    "paged",
    barKinds
  )
  local kindList = Array.foldl(
    function (list, kind)
      list[kind] = Neuron.MANAGED_BAR_STATES[kind].localizedName
      return list
    end,
    {},
    barKinds
  )

  local barKindDropdown = AceGUI:Create("Dropdown")
  barKindDropdown:SetLabel(L["Home State"])
  barKindDropdown:SetList(kindList)
  barKindDropdown:SetFullWidth(false)
  barKindDropdown:SetFullHeight(false)
  barKindDropdown:SetValue(currentKind)
  barKindDropdown:SetCallback("OnValueChanged", function(_, _, key)
    Neuron.currentBar:SetState(key)
  end)

  return barKindDropdown
end

---@param tabFrame Frame
function NeuronGUI:BarStatesPanel(tabFrame)
  -- weird stuff happens if we don't wrap this in a group
  -- like dropdowns showing at the bottom of the screen and stuff
	local settingContainer = AceGUI:Create("SimpleGroup")
	settingContainer:SetFullWidth(true)
	settingContainer:SetLayout("Flow")

  settingContainer:AddChild(actionBarKindOptions())

  tabFrame:AddChild(settingContainer)
end
