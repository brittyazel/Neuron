-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2023 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...

addonTable.overlay = addonTable.overlay or {}

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

---type definition the contents of the xml file
---@class NeuronBarFrame:CheckButton,ScriptObject
---@field Text FontString
---@field Message FontString
---@field MessageBG Texture

---@class BarOverlay
---@field active boolean
---@field bar Bar
---@field frame NeuronBarFrame
---@field microadjust number
---@field onClick fun(overlay: BarOverlay, button:string, down: boolean):nil
---@field onExit fun(overlay: BarOverlay):nil

---@type NeuronBarFrame[]
local framePool = {}

---@param overlay BarOverlay
local function updateAppearance(overlay)
	local concealed = overlay.bar:GetBarConceal()
	if concealed and overlay.active then
		overlay.frame:SetBackdropColor(1,0,0,0.6)
		overlay.frame.Text:Show()
	elseif not concealed and overlay.active then
		overlay.frame:SetBackdropColor(0,0,1,0.5)
		overlay.frame.Text:Show()
	elseif concealed and not overlay.active then
		overlay.frame:SetBackdropColor(1,0,0,0.4)
		overlay.frame.Text:Hide()
	elseif not concealed and not overlay.active then
		overlay.frame:SetBackdropColor(0,0,0,0.4)
		overlay.frame.Text:Hide()
	end

	if overlay.microadjust == 0 then
		overlay.frame.Message:Hide()
		overlay.frame.MessageBG:Hide()
		overlay.frame:SetFrameStrata(Neuron.STRATAS[overlay.bar:GetStrata()])
	else
		-- overlay never gets keyboard events unless a high strata
		-- this hack doesn't work if there is a tooltip level bar
		-- until you choose that bar and then it starts working for others
		overlay.frame:SetFrameStrata(Neuron.STRATAS[#Neuron.STRATAS])
		overlay.frame:SetBackdropColor(1,1,0,0.6)
		overlay.frame.Message:Show()
		overlay.frame.Message:SetText(overlay.bar.data.point:lower().."     x: "..format("%0.2f", overlay.bar:GetXAxis()).."     y: "..format("%0.2f", overlay.bar:GetYAxis()))
		overlay.frame.MessageBG:Show()
		overlay.frame.MessageBG:SetWidth(overlay.frame.Message:GetWidth()*1.05)
		overlay.frame.MessageBG:SetHeight(overlay.frame.Message:GetHeight()*1.1)
	end

	overlay.frame:SetAllPoints(overlay.bar)
end

-- forward declare it so the event handlers can use it
---@class BarEditor
local BarEditor = {}

---@param overlay BarOverlay
local function onEnter(overlay)
	-- we don't want to mutate the real overlay
	local fakeOverlay = CopyTable(overlay, true --[[shallow copy]])

	-- this will update the real overlay frame as if active
	BarEditor.activate(fakeOverlay)
end

--TODO: the overlay should not be mutating objects.
--put the movement code into the overlay controller
---@param overlay BarOverlay
---@param button string
local function onDragStart(overlay, button)
	overlay.bar.data.snapToPoint = false
	overlay.bar.data.snapToFrame = false

	overlay.frame:StartMoving()
end


---@param overlay BarOverlay
local function onDragStop(overlay)

	local point
	overlay.frame:StopMovingOrSizing()

	for _,v in pairs(Neuron.bars) do
		if not point and overlay.bar:GetSnapTo() and v:GetSnapTo() and overlay.bar ~= v then
			point = overlay.bar:Stick(v, Neuron.SNAPTO_TOLERANCE, overlay.bar:GetHorizontalPad(), overlay.bar:GetVerticalPad())

			if point then
				overlay.bar.data.snapToPoint = point
				overlay.bar.data.snapToFrame = v:GetName()
				overlay.bar.data.point = "SnapTo: "..point
			end
		end
	end

	if not point then
		overlay.bar.data.snapToPoint = false
		overlay.bar.data.snapToFrame = false

		local newPoint, x, y = overlay.bar.GetPosition(overlay.frame)
		overlay.bar.data.point = newPoint
		overlay.bar:SetXAxis(x)
		overlay.bar:SetYAxis(y)

		overlay.bar:SetPosition()
	end

	if overlay.bar:GetSnapTo() and not overlay.bar.data.snapToPoint then
		overlay.bar:StickToEdge()
	end

	overlay.bar:SetPosition()
	overlay.bar:UpdateBarStatus()
end

---@param overlay BarOverlay
---@param key string
local function onKeyDown(overlay, key)
	--this allows for the "Esc" key to disable the Edit Mode instead of bringing up the game menu
	if key == "ESCAPE" then
		overlay.onExit(overlay)
		return
	end

	if overlay.microadjust == 0 then
		return
	end
		local newPoint, x, y = overlay.bar:GetPosition()
		overlay.bar.data.point = newPoint
		overlay.bar:SetXAxis(x)
		overlay.bar:SetYAxis(y)

		overlay.bar:SetUserPlaced(false)
		overlay.bar:ClearAllPoints()

		if key == "UP" then
			overlay.bar:SetYAxis(overlay.bar:GetYAxis() + .1 * overlay.microadjust)
		elseif key == "DOWN" then
			overlay.bar:SetYAxis(overlay.bar:GetYAxis() - .1 * overlay.microadjust)
		elseif key == "LEFT" then
			overlay.bar:SetXAxis(overlay.bar:GetXAxis() - .1 * overlay.microadjust)
		elseif key == "RIGHT" then
			overlay.bar:SetXAxis(overlay.bar:GetXAxis() + .1 * overlay.microadjust)
		else
			BarEditor.microadjust(overlay, 0)
		end

		overlay.bar:SetPosition()
		overlay.bar:UpdateBarStatus()

		updateAppearance(overlay)
end


---@param overlay BarOverlay
local function onLeave(overlay)
	updateAppearance(overlay)
end

---@param overlay BarOverlay
---@param button string
---@param down boolean
local function onClick(overlay, button, down)
	overlay.onClick(overlay, button, down)
end

---@param bar Bar
---@param onClickCallback fun(overlay: BarOverlay, button: string, down: boolean): nil
---@param onExitCallback fun(overlay: BarOverlay): nil
---@return BarOverlay
BarEditor.allocate = function (bar, onClickCallback, onExitCallback)
	---@type BarOverlay
	local overlay = {
		active = false,
		bar = bar,
		frame = -- try to pop a frame off the stack, otherwise make a new one
			table.remove(framePool) or
			CreateFrame("CheckButton", nil, UIParent, "NeuronBarTemplate") --[[@as NeuronBarFrame]],
		microadjust = 0,
		onClick = onClickCallback,
		onExit = onExitCallback
	}
	overlay.frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		tile = true,
		tileSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4}
	})

	overlay.frame.Text:SetText(bar:GetBarName())

	overlay.frame:EnableKeyboard(false)
	overlay.frame:RegisterForClicks("AnyUp", "AnyDown")
	overlay.frame:RegisterForDrag("LeftButton")
	overlay.frame:SetScript("OnDragStart", function(_, button) onDragStart(overlay, button) end)
	overlay.frame:SetScript("OnDragStop", function(_) onDragStop(overlay) end)
	overlay.frame:SetScript("OnKeyDown", function(_, key) onKeyDown(overlay, key) end)
	overlay.frame:SetScript("OnEnter", function() onEnter(overlay) end)
	overlay.frame:SetScript("OnLeave", function() onLeave(overlay) end)
	overlay.frame:SetScript("OnClick", function(_, button, down) onClick(overlay, button, down) end)

	overlay.frame.Text:Show()
	overlay.frame:Show()
	updateAppearance(overlay)

	return overlay
end

---@param overlay BarOverlay
BarEditor.activate = function(overlay)
	overlay.active = true
	BarEditor.microadjust(overlay, overlay.microadjust)
	updateAppearance(overlay)
end

---@param overlay BarOverlay
BarEditor.deactivate = function(overlay)
	overlay.active = false
	BarEditor.microadjust(overlay, 0)

	updateAppearance(overlay)
end

---@param overlay BarOverlay
BarEditor.free = function (overlay)
	overlay.frame:SetScript("OnDragStart", nil)
	overlay.frame:SetScript("OnDragStop", nil)
	overlay.frame:SetScript("OnEnter", nil)
	overlay.frame:SetScript("OnLeave", nil)
	overlay.frame:SetScript("OnClick", nil)
	overlay.frame:EnableKeyboard(false)
	overlay.frame:RegisterForDrag()
	overlay.frame:RegisterForClicks()
	overlay.frame:Hide()
	table.insert(framePool, overlay.frame)

	-- just for good measure to make sure nothing else can mess with
	-- the frame after we put it back into the pool
	overlay.frame = nil
end

---if no value is passed in for microadjust then make it a toggle
---@param overlay BarOverlay
---@param microadjust number|nil
BarEditor.microadjust = function(overlay, microadjust)
	if microadjust ~= nil then
		overlay.microadjust = microadjust
	elseif overlay.microadjust == 0 then
		overlay.microadjust = 1
	else
		overlay.microadjust = 0
	end

	if microadjust == 0 then
		overlay.frame:EnableKeyboard(false)
	else
		overlay.frame:EnableKeyboard(true)
	end

	updateAppearance(overlay)
end

addonTable.overlay.BarEditor = BarEditor
