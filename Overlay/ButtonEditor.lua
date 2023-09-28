-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2023 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...

addonTable.overlay = addonTable.overlay or {}

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

---type definition the contents of the xml file
---@class OverlayFrameSelect:Frame
---@field Left Texture
---@field Reticle Texture
---@field Right Texture

---@class ButtonOverlayFrame:Button,ScriptObject
---@field label FontString
---@field select OverlayFrameSelect

---@class ButtonOverlay
---@field active boolean
---@field button Button
---@field frame ButtonOverlayFrame
---@field onClick fun(button: Button):nil

---@type ButtonOverlayFrame[]
local framePool = {}

---@param overlay ButtonOverlay
local function onEnter(overlay)
	overlay.frame.select:Show()
	GameTooltip:SetOwner(overlay.frame, "ANCHOR_RIGHT")
	GameTooltip:Show()
end

---@param overlay ButtonOverlay
local function onLeave(overlay)
		if overlay.active == false then
			overlay.frame.select:Hide()
		end
		GameTooltip:Hide()
end

---@param overlay ButtonOverlay
local function onClick(overlay)
	overlay.onClick(overlay.button)
end

local ButtonEditor= {
	---@param button Button
	---@param recticle "sides"|"corners"
	---@param onClickCallback fun(button: Button): nil
	---@return ButtonOverlay
	allocate = function (button, recticle, onClickCallback)
		---@type ButtonOverlay
		local overlay = {
			active = false,
			button = button,
			frame = -- try to pop a frame off the stack, otherwise make a new one
				table.remove(framePool) or
				CreateFrame("Button", nil, UIParent, "NeuronOverlayFrameTemplate") --[[@as ButtonOverlayFrame]],
			onClick = onClickCallback,
		}

		overlay.frame:EnableMouseWheel(true)
		overlay.frame:RegisterForClicks("AnyDown")
		overlay.frame:SetAllPoints(button)
		overlay.frame:SetScript("OnEnter", function() onEnter(overlay) end)
		overlay.frame:SetScript("OnLeave", function() onLeave(overlay) end)
		overlay.frame:SetScript("OnClick", function() onClick(overlay) end)

		overlay.frame.label:SetText(L["Edit"])

		if recticle == "corners" then
			overlay.frame.select.Left:Hide()
			overlay.frame.select.Right:Hide()
			overlay.frame.select.Reticle:Show()
		else
			overlay.frame.select.Left:ClearAllPoints()
			overlay.frame.select.Left:SetPoint("RIGHT", overlay.frame.select, "LEFT", 4, 0)
			overlay.frame.select.Left:SetTexture("Interface\\AddOns\\Neuron\\Images\\flyout.tga")
			overlay.frame.select.Left:SetTexCoord(0.71875, 1, 0, 1)
			overlay.frame.select.Left:SetWidth(16)
			overlay.frame.select.Left:SetHeight(55)

			overlay.frame.select.Right:ClearAllPoints()
			overlay.frame.select.Right:SetPoint("LEFT", overlay.frame.select, "RIGHT", -4, 0)
			overlay.frame.select.Right:SetTexture("Interface\\AddOns\\Neuron\\Images\\flyout.tga")
			overlay.frame.select.Right:SetTexCoord(0, 0.28125, 0, 1)
			overlay.frame.select.Right:SetWidth(16)
			overlay.frame.select.Right:SetHeight(55)

			overlay.frame.select.Left:Show()
			overlay.frame.select.Right:Show()
			overlay.frame.select.Reticle:Hide()
		end

		overlay.frame:Show()

		return overlay
	end,

	---@param overlay ButtonOverlay
	activate = function(overlay)
		overlay.active = true
		overlay.frame.select:Show()
	end,

	---@param overlay ButtonOverlay
	deactivate = function(overlay)
		overlay.active = false
		overlay.frame.select:Hide()
	end,

	---@param overlay ButtonOverlay
	free = function (overlay)
		overlay.frame:SetScript("OnEnter", nil)
		overlay.frame:SetScript("OnLeave", nil)
		overlay.frame:SetScript("OnClick", nil)
		overlay.frame.select:Hide()
		overlay.frame:Hide()
		table.insert(framePool, overlay.frame)

		-- just for good measure to make sure nothing else can mess with
		-- the frame after we put it back into the pool
		overlay.frame = nil
	end,
}

addonTable.overlay.ButtonEditor = ButtonEditor
