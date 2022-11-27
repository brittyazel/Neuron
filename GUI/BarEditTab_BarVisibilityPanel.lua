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

function barVisibilityOptions()
	local bar = Neuron.CurrentBar

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

	local button, text

	local visibilityStatesContainer = AceGUI:Create("SimpleGroup")
	visibilityStatesContainer:SetFullWidth(true)
	visibilityStatesContainer:SetLayout("Flow")

  for _,state in ipairs(stateList) do
    local checkbox = AceGUI:Create("CheckBox")
    checkbox:SetLabel(Neuron.VISIBILITY_STATES[state])
    checkbox:SetValue(not Neuron.currentBar.data.hidestates:find(state))
    checkbox:SetCallback("OnValueChanged", function(_,_,value)
      Neuron.currentBar:SetVisibility(state, value)
    end)
    visibilityStatesContainer:AddChild(checkbox)
  end

  return visibilityStatesContainer
end
function NeuronGUI:BarVisibilityPanel(tabFrame)
  -- weird stuff happens if we don't wrap this in a group
  -- like dropdowns showing at the bottom of the screen and stuff
	local settingContainer = AceGUI:Create("SimpleGroup")
	settingContainer:SetFullWidth(true)
	settingContainer:SetLayout("Flow")

  settingContainer:AddChild(barVisibilityOptions())

  tabFrame:AddChild(settingContainer)
end
