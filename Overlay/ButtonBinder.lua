-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...

addonTable.overlay = addonTable.overlay or {}

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

---@class BinderOverlay
---@field button Button
---@field frame ButtonOverlayFrame
---@field onBindCallback fun(button: Button, key: string): nil

---@type ButtonOverlayFrame[]
local framePool = {}

--- Returns the keybind for a given button
--- @param keys {hotKeys:string}
--- @return string @The current key that is bound to the selected button
local function getBindKeyList(keys)
	if not keys then
		return L["None"]
	end

	local bindkeys = keys.hotKeys:gsub("[^:]+", addonTable.Neuron.Button.hotKeyText):gsub(":", ", ")

	bindkeys = bindkeys:gsub("^, ", "")
	bindkeys = bindkeys:gsub(", $", "")

	if string.len(bindkeys) < 1 then
		bindkeys = L["None"]
	end

	return bindkeys
end

---@parameter overlay BinderOverlay
local function updateAppearance(overlay)
	local priority = ""

	if overlay.button.keys.hotKeyPri then
		priority = "|cff00ff00"..L["Priority"].."|r\n"
	end

	if overlay.button.keys.hotKeyLock then
		overlay.frame.label:SetText(priority.."|cfff00000"..L["Locked"].."|r")
	else
		overlay.frame.label:SetText(priority.."|cffffffff"..L["Bind"].."|r")
	end
end

---@parameter overlay BinderOverlay
local function updateTooltip(overlay)
	local name

	---TODO:we should definitely added name strings for pets/companions as well. This was just to get it going
	if overlay.button.spellID then
		name = GetSpellInfo(overlay.button.spellID)
	elseif overlay.button.actionSpell then
		name = overlay.button.actionSpell
	elseif overlay.button.macroitem then
		name = overlay.button.macroitem
	elseif overlay.button.macrospell then
		name = overlay.button.macrospell --this is kind of a catch-all
	end

	if not name then
		name = "Button"
	end

	GameTooltip:SetOwner(overlay.frame, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:SetText("Neuron", 1.0, 1.0, 1.0)
	GameTooltip:AddLine(L["Keybind_Tooltip_1"] .. ": |cffffffff" .. name  .. "|r")
	GameTooltip:AddLine(L["Keybind_Tooltip_2"] .. ": |cffffffff" .. getBindKeyList(overlay.button.keys) .. "|r")
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["Keybind_Tooltip_3"])
	GameTooltip:AddLine(L["Keybind_Tooltip_4"])
	GameTooltip:AddLine(L["Keybind_Tooltip_5"])
	GameTooltip:Show()
end

--- Returns a string representation of the modifier that is currently being pressed down, if any
--- @return string @Field of the key modifiers currently being pressed
local function modifierString()
	return
		(IsAltKeyDown() and "ALT-" or "")..
		(IsControlKeyDown() and "CTRL-" or "")..
		(IsShiftKeyDown() and "SHIFT-" or "")
end

---@param overlay BinderOverlay
local function onEnter(overlay)
	overlay.frame.select:Show()
	updateTooltip(overlay)
	overlay.frame:EnableKeyboard(true)
	overlay.frame:EnableMouseWheel(true)
end

---@param overlay BinderOverlay
local function onLeave(overlay)
	overlay.frame:EnableKeyboard(false)
	overlay.frame:EnableMouseWheel(false)
	overlay.frame.select:Hide()
	GameTooltip:Hide()
end

---@param overlay BinderOverlay
---@param mousebutton string
---@param down boolean
local function onClick(overlay, mousebutton, down)
	--overlay.onClick(overlay.button)

	if mousebutton == "LeftButton" then
		overlay.button.keys.hotKeyLock = not overlay.button.keys.hotKeyLock
	elseif mousebutton== "RightButton" then
		overlay.button.keys.hotKeyPri = not overlay.button.keys.hotKeyPri
		overlay.button:ApplyBindings()
	else
		local key = mousebutton == "MiddleButton" and "Button3" or mousebutton
		overlay.onBindCallback(overlay.button, modifierString()..key)
	end

	updateAppearance(overlay)
	updateTooltip(overlay)
end

---@param overlay BinderOverlay
---@param key string
local function onKeyDown(overlay, key)
	if key:find("ALT") or key:find("SHIFT") or key:find("CTRL") or key:find("PRINTSCREEN") then
		return
	end

	overlay.onBindCallback(overlay.button, modifierString()..key)
	updateAppearance(overlay)
	updateTooltip(overlay)
end

---@param overlay BinderOverlay
---@param delta 1|-1
local function onMouseWheel(overlay, delta)
	local key = delta > 0 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN"

	overlay.onBindCallback(overlay.button, modifierString()..key)
	updateAppearance(overlay)
	updateTooltip(overlay)
end

local ButtonBinder = {
	---@param button Button
	---@param onBindCallback fun(button: Button, key: string): nil
	---@return BinderOverlay
	allocate = function (button, onBindCallback)
		---@type BinderOverlay
		local overlay = {
			button = button,
			frame = -- try to pop a frame off the stack, otherwise make a new one
				table.remove(framePool) or
				CreateFrame("Button", nil, UIParent, "NeuronOverlayFrameTemplate") --[[@as ButtonOverlayFrame]],
			onBindCallback = onBindCallback,
		}

		overlay.frame:SetAllPoints(button)
		overlay.frame:SetScript("OnEnter", function() onEnter(overlay) end)
		overlay.frame:SetScript("OnLeave", function() onLeave(overlay) end)
		overlay.frame:SetScript("OnClick", function(_, mousebutton, down) onClick(overlay, mousebutton, down) end)
		overlay.frame:SetScript("OnKeyDown", function(_, key) onKeyDown(overlay, key) end)
		overlay.frame:SetScript("OnMouseWheel", function(_, delta) onMouseWheel(overlay, delta) end)

		overlay.frame.label:SetText(L["Bind"])
		overlay.frame.select.Left:Hide()
		overlay.frame.select.Right:Hide()
		overlay.frame.select.Reticle:Show()
		overlay.frame.select:Hide()

		overlay.frame:Show()
		updateAppearance(overlay)

		-- this seems to not work if we do it before showing the frame
		-- which sometimes results in a random frame getting the binding
		-- instead of binding to the frame under the mouse
		overlay.frame:EnableKeyboard(false)
		overlay.frame:EnableMouseWheel(false)
		overlay.frame:RegisterForClicks("AnyDown")

		return overlay
	end,

	---@param overlay BinderOverlay
	free = function (overlay)
		overlay.frame:SetScript("OnEnter", nil)
		overlay.frame:SetScript("OnLeave", nil)
		overlay.frame:SetScript("OnClick", nil)
		overlay.frame:SetScript("OnKeyDown", nil)
		overlay.frame:SetScript("OnMouseWheel", nil)
		overlay.frame.select:Hide()
		overlay.frame:Hide()
		table.insert(framePool, overlay.frame)

		-- just for good measure to make sure nothing else can mess with
		-- the frame after we put it back into the pool
		overlay.frame = nil
	end,
}

addonTable.overlay.ButtonBinder = ButtonBinder
