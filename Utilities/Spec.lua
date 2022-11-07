-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
addonTable.utilities = addonTable.utilities or {}

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local Array = addonTable.utilities.Array

local wrathSpecNames = {TALENT_SPEC_PRIMARY, TALENT_SPEC_SECONDARY}

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
      index = GetActiveTalentGroup()
      name = wrathSpecNames[index]
    else -- classic era or something we don't handle
      index, name = 1, ""
    end

    index = multiSpec and index or 1

    return index, name
  end,

  --- get a list of spec names
  -- boolean -> string[]
  --
  -- @param bool indicating whether we want multispec
  -- @return the names
  names = function(multiSpec)
    local names
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
      names = Array.initialize(
        GetNumSpecializations(),
        function(i) return select(2, GetSpecializationInfo(i)) end
      )
    elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
      names = wrathSpecNames
    else
      names = {""}
    end

    return multiSpec and names or {""}
  end
}

addonTable.utilities.Spec = Spec
