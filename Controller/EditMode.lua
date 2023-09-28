-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...

addonTable.controller = addonTable.controller or {}

---@type BarEditor
local BarEditor = addonTable.overlay.BarEditor
local ButtonBinder = addonTable.overlay.ButtonBinder
local ButtonEditor = addonTable.overlay.ButtonEditor
local Array = addonTable.utilities.Array

---@class EditModeFrames
---@field binderOverlays BinderOverlay[]
---@field barOverlays BarOverlay[]
---@field buttonOverlays ButtonOverlay[]

---@class EditModeState
---@field guiState GuiBarState|GuiButtonState|GuiOffState

---@class GuiBarState
---@field kind "bar"
---@field bar Bar|false
---@field microadjust boolean

---@class GuiBindState
---@field kind "bind"

---@class GuiButtonState
---@field kind "button"
---@field button Button|false

---@class GuiStatusButtonState
---@field kind "status"
---@field button StatusButton|false

---@class GuiOffState
---@field kind "off"

---@type EditModeFrames
local views = {
  barOverlays = {},
  binderOverlays = {},
  buttonOverlays = {},
}

---@class EditMode
local EditMode = {}

local function cleanOverlays()
  for _,overlay in pairs(views.barOverlays) do
    BarEditor.free(overlay)

    overlay.bar:UpdateObjectVisibility()
    overlay.bar:UpdateBarStatus()
    overlay.bar:UpdateObjectStatus()
  end
  for _,overlay in pairs(views.buttonOverlays) do
    ButtonEditor.free(overlay)
  end
  for _,overlay in pairs(views.binderOverlays) do
    ButtonBinder.free(overlay)
  end

  views = {
    barOverlays = {},
    binderOverlays = {},
    buttonOverlays = {},
  }
end

---@param state GuiBarState
local function renderBarOverlays(state)
  views.barOverlays = Array.map(
    function(bar)
      local overlay = BarEditor.allocate(
        bar,
        function(overlay, button, down)
          if down then
            return
          end

          if IsShiftKeyDown() then
            addonTable.Neuron.state = EditMode.enterBarMode(state, bar, true)
          else
            addonTable.Neuron.state = EditMode.enterBarMode(state, bar, false)
          end
          --TODO: this should hit the controller, not the bar
          --[[
          elseif click == "RightButton" and not down then
            if not addonTable.NeuronEditor then
              Neuron.NeuronGUI:CreateEditor()
            end
          end

          if addonTable.NeuronEditor then
            Neuron.NeuronGUI:RefreshEditor()
          end
          --]]
        end,
        function(_)
          addonTable.Neuron.state = EditMode.exit(addonTable.Neuron.state)
        end
      )
      if state.bar == bar then
        BarEditor.activate(overlay)
      end
      if state.bar == bar and state.microadjust then
        BarEditor.microadjust(overlay)
      end

      bar:UpdateObjectVisibility(true)
      bar:UpdateBarStatus(true)
      bar:UpdateObjectStatus()

      return overlay
    end,
    Neuron.bars
  )
end

---@param state EditModeState
local function renderOverlays(state)
  cleanOverlays()

  if state.guiState.kind == "bar" then
    renderBarOverlays(state.guiState --[[ @as GuiBarState]])
  end
end

---@param state EditModeState
---@param bar Bar|false
---@param microadjust boolean
---@return EditModeState
EditMode.enterBarMode = function (state, bar, microadjust)
  local newState = CopyTable(state, true)
  MergeTable(newState, {
    guiState={
      kind="bar",
      microadjust=microadjust,
      bar=bar,
    }
  })

  renderOverlays(newState)
  return newState
end

---@param state EditModeState
---@return EditModeState
EditMode.exit = function (state)
  local newState = CopyTable(state, true)
  MergeTable(newState, {
    guiState={
      kind="off",
    }
  })

  renderOverlays(newState)
  return newState
end

addonTable.controller.EditMode = EditMode
