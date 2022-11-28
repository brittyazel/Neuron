-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

function Neuron:RegisterBars(DB)
  local allBars = {
    ActionBar = {
      class = "ActionBar",
      barType = "ActionBar",
      barLabel = L["Action Bar"],
      objType = "ActionButton",
      barDB = DB.ActionBar,
      objTemplate = Neuron.ActionButton,
      objMax = 250
    },
    BagBar = {
      class = "BagBar",
      barType = "BagBar",
      barLabel = L["Bag Bar"],
      objType = "BagButton",
      barDB = DB.BagBar,
      objTemplate = Neuron.BagButton,
      objMax = Neuron.NUM_BAG_BUTTONS
    },
    MenuBar = {
      class = "MenuBar",
      barType = "MenuBar",
      barLabel = L["Menu Bar"],
      objType = "MenuButton",
      barDB = DB.MenuBar,
      objTemplate = Neuron.MenuButton,
      objMax = 11
    },
    PetBar = {
      class = "PetBar",
      barType = "PetBar",
      barLabel = L["Pet Bar"],
      objType = "PetButton",
      barDB = DB.PetBar,
      objTemplate = Neuron.PetButton,
      objMax = 10
    },
    XPBar = {
      class = "XPBar",
      barType = "XPBar",
      barLabel = L["XP Bar"],
      objType = "ExpButton",
      barDB = DB.XPBar,
      objTemplate = Neuron.ExpButton,
      objMax = 10
    },
    RepBar = {
      class = "RepBar",
      barType = "RepBar",
      barLabel = L["Rep Bar"],
      objType = "RepButton",
      barDB = DB.RepBar,
      objTemplate = Neuron.RepButton,
      objMax = 10
    },
    CastBar = {
      class = "CastBar",
      barType = "CastBar",
      barLabel = L["Cast Bar"],
      objType = "CastButton",
      barDB = DB.CastBar,
      objTemplate = Neuron.CastButton,
      objMax = 10
    },
    MirrorBar = {
      class = "MirrorBar",
      barType = "MirrorBar",
      barLabel = L["Mirror Bar"],
      objType = "MirrorButton",
      barDB = DB.MirrorBar,
      objTemplate = Neuron.MirrorButton,
      objMax = 10
    },
  }

	if Neuron.isWoWRetail then
    MergeTable(allBars, {
      ZoneAbilityBar = {
        class = "ZoneAbilityBar",
        barType = "ZoneAbilityBar",
        barLabel = L["Zone Action Bar"],
        objType = "ZoneActionButton",
        barDB = DB.ZoneAbilityBar,
        objTemplate = Neuron.ZoneAbilityButton,
        objMax = 5, true
      },
      ExtraBar = {
        class = "ExtraBar",
        barType = "ExtraBar",
        barLabel = L["Extra Action Bar"],
        objType = "ExtraActionButton",
        barDB = DB.ExtraBar,
        objTemplate = Neuron.ExtraButton,
        objMax = 1
      },
      ExitBar = {
        class = "ExitBar",
        barType = "ExitBar",
        barLabel = L["Vehicle Exit Bar"],
        objType = "VehicleExitButton",
        barDB = DB.ExitBar,
        objTemplate = Neuron.ExitButton,
        objMax = 1
      },
    })
  end

  return allBars
end
