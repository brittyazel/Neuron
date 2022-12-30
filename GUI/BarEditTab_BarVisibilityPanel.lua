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
local function barVisibilityOptions(bar)
	local stateList =
    Array.map(
    function (state)
      return state[1]
    end,
    Array.fromIterator(pairs(Neuron.VISIBILITY_STATES)))
  if Neuron.class == 'ROGUE' then
    stateList = Array.filter(
      function (state)
        return state ~= 'stealth0' and state ~= 'stealth1'
      end,
      stateList
    )
  end

	local visibilityStatesContainer = AceGUI:Create("SimpleGroup")
	visibilityStatesContainer:SetFullWidth(true)
	visibilityStatesContainer:SetLayout("Flow")

  for _,state in ipairs(stateList) do
    local checkbox = AceGUI:Create("CheckBox")
    checkbox:SetLabel(Neuron.VISIBILITY_STATES[state])
    checkbox:SetValue(not bar.data.hidestates:find(state))
    checkbox:SetCallback("OnValueChanged", function(_,_,value)
      bar:SetVisibility(state, value)
    end)
    visibilityStatesContainer:AddChild(checkbox)
  end

  return visibilityStatesContainer
end

---@param bar Bar
function NeuronGUI:BarVisibilityPanel(bar, tabFrame)
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

  settingContainer:AddChild(barVisibilityOptions(bar))
  settingContainer:AddChild(reloadButtonContainer)
  tabFrame:AddChild(settingContainer)
end
