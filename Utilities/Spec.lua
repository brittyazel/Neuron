-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
addonTable.utilities = addonTable.utilities or {}

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local Spec; Spec = {
  --- get the currently active spec
  -- bool -> int, string
  --
  -- @param bool indicating whether we want multispec
  -- @return the spec index and name
  active = function (multiSpec)
    local index, name
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
      index = GetSpecialization()
      _, name = GetSpecializationInfo(index)
    elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
      local specNames = {TALENT_SPEC_PRIMARY, TALENT_SPEC_SECONDARY}
      index = GetActiveTalentGroup()
      name = specNames[index]
    else -- classic era or something we don't handle
      index, name = 1, L["None"]
    end

    index = multiSpec and index or 1

    return index, name
  end,

}

addonTable.utilities.Spec = Spec
