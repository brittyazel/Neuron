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


---@param bar Bar
---@return Frame @a dropdown widget
local function actionPrimaryBarKindOptions(bar)
  local barKinds =
    Array.map(
      function(state) return state[1] end,
    Array.fromIterator(pairs(Neuron.MANAGED_HOME_STATES)))
  local currentKind = Array.foldl(
    function (kind, candidate)
      return bar.data[candidate] and candidate or kind
    end,
    "none",
    barKinds
  )
  local kindList = Array.foldl(
    function (list, kind)
      list[kind] = Neuron.MANAGED_HOME_STATES[kind].localizedName
      return list
    end,
    {none = L["None"]},
    barKinds
  )

  local barKindDropdown = AceGUI:Create("Dropdown")
  barKindDropdown:SetLabel(L["Home State"])
  barKindDropdown:SetList(kindList)
  barKindDropdown:SetFullWidth(false)
  barKindDropdown:SetFullHeight(false)
  barKindDropdown:SetValue(currentKind)
  barKindDropdown:SetCallback("OnValueChanged", function(_, _, key)
    if key == "none" then
      for _,kind in ipairs(barKinds) do
        bar:SetState(kind, true, false)
      end
    else
      bar:SetState(key, true, true)
    end
  end)

  return barKindDropdown
end

---@param bar Bar
---@return Frame @a group containing checkboxes
local function actionSecondaryStateOptions(bar)
  local stateList =
    Array.map(
      function(state) return state[1] end,
    Array.fromIterator(pairs(Neuron.MANAGED_SECONDARY_STATES)))

	--Might want to add some checks for states like stealth for classes that
  --don't have stealth. But for now it doesn't break anything to have it show
  --generically
  if Neuron.class == "ROGUE" then
    stateList = Array.filter(function (state) return state ~= "stealth" end, stateList)
  end

	local secondaryStatesContainer = AceGUI:Create("SimpleGroup")
	secondaryStatesContainer:SetFullWidth(true)
	secondaryStatesContainer:SetLayout("Flow")

  for _,state in ipairs(stateList) do
    local checkbox = AceGUI:Create("CheckBox")
    checkbox:SetLabel(Neuron.MANAGED_SECONDARY_STATES[state].localizedName)
    checkbox:SetValue(bar.data[state])
    checkbox:SetCallback("OnValueChanged", function(_,_,value)
      bar:SetState(state, true, value)
    end)
    secondaryStatesContainer:AddChild(checkbox)
  end

  return secondaryStatesContainer
end

---@param bar Bar
---@param tabFrame Frame
function NeuronGUI:BarStatesPanel(bar, tabFrame)
  -- weird stuff happens if we don't wrap this in a group
  -- like dropdowns showing at the bottom of the screen and stuff
	local settingContainer = AceGUI:Create("SimpleGroup")
	settingContainer:SetFullWidth(true)
	settingContainer:SetLayout("Flow")

  settingContainer:AddChild(actionPrimaryBarKindOptions(bar))
  settingContainer:AddChild(actionSecondaryStateOptions(bar))

  tabFrame:AddChild(settingContainer)
end
