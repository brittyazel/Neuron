-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local Spec = addonTable.utilities.Spec

---@class Bar : CheckButton @This is our bar object that serves as the container for all of our button objects
local Bar = setmetatable({}, {__index = CreateFrame("CheckButton")}) --this is the metatable for our button object
Neuron.Bar = Bar

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

LibStub("AceTimer-3.0"):Embed(Bar)
LibStub("AceEvent-3.0"):Embed(Bar)

local alphaDir, alphaTimer = 0, 0

local statetable = {}

local Trashcan = CreateFrame("Frame", nil, UIParent)
Trashcan:Hide()

----------------------------------------------------

---Constructor: Create a new Neuron Bar object
---@param class string @The class type of the new bar
---@param barID number @The ID of the new bar object
---@return Bar @ A newly created Button object
function Bar.new(class, barID)
	local data = Neuron.registeredBarData[class]

	local newBar

	--this is the creation of our bar object frame
	if _G["Neuron"..data.barType..barID] then --check to see if our bar already exists on the global namespace
		newBar = CreateFrame("CheckButton", "Neuron"..data.barType..random(1000,10000000), UIParent, "NeuronBarTemplate") --in the case of trying to create a bar on a frame that already exists, create a random frame ID for this session only
		setmetatable(newBar, {__index = Bar})
	else
		newBar = CreateFrame("CheckButton", "Neuron"..data.barType..barID, UIParent, "NeuronBarTemplate")
		setmetatable(newBar, {__index = Bar})
	end

	--load saved data
	for key,value in pairs(data) do
		newBar[key] = value
	end

	--safety check
	if not data.barDB[barID] then --if the database for a bar doesn't exist (because it's a new bar?)
		data.barDB[barID] = {}
	end

	newBar.data = data.barDB[barID]

	--create empty buttons table that will hold onto all of our button object handles
	newBar.buttons = {}

	newBar.id = barID
	newBar.class = class
	newBar.stateschanged = true
	newBar.vischanged =true
	newBar.microAdjust = false
	newBar.vis = {}
	newBar.Text:Hide()
	newBar.Message:Hide()
	newBar.MessageBG:Hide()

	newBar:SetWidth(375)
	newBar:SetHeight(40)
	newBar:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
						edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
						tile = true, tileSize = 16, edgeSize = 12,
						insets = {left = 4, right = 4, top = 4, bottom = 4}})
	newBar:SetBackdropColor(0,0,0,0.4)
	newBar:SetBackdropBorderColor(0,0,0,0)
	newBar:RegisterForClicks("AnyDown", "AnyUp")
	newBar:RegisterForDrag("LeftButton")
	newBar:SetMovable(true)
	newBar:EnableKeyboard(false)
	newBar:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

	newBar:SetScript("OnClick", function(self, ...) self:OnClick(...) end)
	newBar:SetScript("OnDragStart", function(self, ...) self:OnDragStart(...) end)
	newBar:SetScript("OnDragStop", function(self, ...) self:OnDragStop(...) end)
	newBar:SetScript("OnEnter", function(self, ...) self:OnEnter(...) end)
	newBar:SetScript("OnLeave", function(self, ...) self:OnLeave(...) end)
	newBar:SetScript("OnKeyDown", function(self, key, onupdate) self:OnKeyDown(key, onupdate) end)
	newBar:SetScript("OnKeyUp", function(self, key) self:OnKeyUp(key) end)
	newBar:SetScript("OnShow", function(self) self:OnShow() end)
	newBar:SetScript("OnHide", function(self) self:OnHide() end)

	-- TODO: i think that allowing the bars to register themselves with the list
	-- of bars is causing a back write to the DB somewhere which results in
	-- bars whose frame is not created to be deleted from the DB. This is
	-- more of a structural issue I think, and hopefully resolve itself when
	-- we start making separate objects for bar data and bar frames
	table.insert(Neuron.bars, newBar) --insert our new bar at the end of the table

	newBar:CreateDriver()
	newBar:CreateHandler()
	newBar:CreateWatcher()

	--update these times when the bar is first being loaded in
	newBar:UpdateAutoHideTimer()
	newBar:UpdateAlphaUpTimer()

	if not newBar:GetBarName() or newBar:GetBarName() == ":" then
		newBar:SetBarName(newBar.barLabel.." "..newBar.id)
	end

	newBar:InitializeBar()

	newBar:Hide() --hide the transparent blue overlay that we show in the edit mode

	return newBar
end

function Bar:InitializeBar()
	if self.class == "ActionBar" then
		if Neuron.isWoWRetail or Neuron.isWoWWrathClassic then
			self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end
		self:RegisterEvent("ACTIONBAR_SHOWGRID", "ACTIONBAR_SHOWHIDEGRID", true)
		self:RegisterEvent("ACTIONBAR_HIDEGRID", "ACTIONBAR_SHOWHIDEGRID")
	end
end

-----------------------------------
--------- Event Handlers ----------
-----------------------------------

function Bar:ACTIVE_TALENT_GROUP_CHANGED()
	if self.handler:GetAttribute("assertstate") then
		self.handler:SetAttribute("state-"..self.handler:GetAttribute("assertstate"), self.handler:GetAttribute("activestate") or "homestate")
	end

	for _,button in pairs(self.buttons) do
		button:UpdateButtonSpec()
	end
	self:Load()
end

function Bar:ACTIONBAR_SHOWHIDEGRID(show)

	if show then
		Neuron.dragging = true
	else
		Neuron.dragging = false
	end

	--don't show the grid if the bar is locked and the right key isn't pressed
	if self:GetBarLock() == "alt" and not IsAltKeyDown() then
		show = nil
	elseif self:GetBarLock() == "ctrl" and not IsControlKeyDown() then
		show = nil
	elseif self:GetBarLock() == "shift" and not IsShiftKeyDown() then
		show = nil
	end

	for _, button in pairs(self.buttons) do
		button:UpdateVisibility(show)
	end
end

-----------------------------------
-----Bar Add/Remove Functions------
-----------------------------------

---This function is used for creating brand new bars, and it is really just a wrapper for the Bar constructor with a couple of assumptions and checks
function Bar:CreateNewBar(class)

	if not class and Neuron.registeredBarData[class] then --if the class isn't registered, go ahead and bail out.
		Neuron.PrintBarTypes()
		return
	end

	local barID = #Neuron.registeredBarData[class].barDB + 1 --increment 1 higher than the current number of bars in this class of bar's database

	local newBar = Bar.new(class, barID) --create new bar

	newBar.objTemplate.new(newBar, 1) --add at least 1 button to a new bar
	Bar.ChangeSelectedBar(newBar)
	newBar:Load() --load the bar

	newBar:Show() --Show the transparent blue overlay that we show in the edit mode
end
Neuron.CreateNewBar = Bar.CreateNewBar --this is so the slash function works correctly


function Bar:DeleteBar()
	self.handler:SetAttribute("state-current", "homestate")
	self.handler:SetAttribute("state-last", "homestate")
	self.handler:SetAttribute("showstates", "homestate")
	self:ClearStates(self.handler, "homestate")

	for state, values in pairs(Neuron.MANAGED_BAR_STATES) do
		if self.data[state] and self[state] and self[state].registered then
			if state == "custom" and self.data.customRange then
				local start = tonumber(string.match(self.data.customRange, "^%d+"))
				local stop = tonumber(string.match(self.data.customRange, "%d+$"))

				if start and stop then
					self:ClearStates(self.handler, state)--, start, stop)
				end
			else
				self:ClearStates(self.handler, state)--, values.rangeStart, values.rangeStop)
			end
		end
	end

	for i = 1,#self.buttons do
		self:RemoveObjectFromBar()
	end

	self:SetScript("OnClick", function() end)
	self:SetScript("OnDragStart", function() end)
	self:SetScript("OnDragStop", function() end)
	self:SetScript("OnEnter", function() end)
	self:SetScript("OnLeave", function() end)
	self:SetScript("OnKeyDown", function() end)
	self:SetScript("OnKeyUp", function() end)
	self:SetScript("OnShow", function() end)
	self:SetScript("OnHide", function() end)

	self:SetWidth(36)
	self:SetHeight(36)
	self:ClearAllPoints()
	self:SetPoint("CENTER")
	self:Hide()

	table.remove(self.barDB, self.id) --removes the bar from the database, along with all of its buttons

	for k,v in pairs(self.barDB) do

		local oldID = v.id --keep track of the oldID

		v.id = k --update the bar id to match the new index value, this is VERY important

		if v.name == self.barLabel.." "..oldID then --if the name is name according to the oldID, update the name to the new ID (i.e. if they never changed the name, we don't want to overwrite custom names)
			v.name = self.barLabel.." "..v.id
		end
	end

	local index --find the location of our bar in the bar table
	for i,v in ipairs(Neuron.bars) do
		if v == self then
			index = i
		end
	end

	if index then --if our index was found (it should always be found) remove it from the array
		table.remove(Neuron.bars, index)
	end

	Neuron.currentBar = nil

	for i,v in pairs(Neuron.bars) do --update bars to reflect new names, if they have new names
		v:UpdateBarStatus()
	end
end

function Bar:AddObjectToBar() --called from NeuronGUI
	local id = #self.buttons + 1

	if #self.buttons < self.objMax then
		local buttonBaseObject = Neuron.registeredBarData[self.class].objTemplate
		buttonBaseObject.new(self, id)
	end

	self:LoadObjects()
	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:UpdateBarStatus()
	self:UpdateObjectVisibility()
end

function Bar:RemoveObjectFromBar() --called from NeuronGUI

	local id = #self.buttons --always the last button

	local object = self.buttons[id]

	if object then

		object:ClearAllPoints()

		table.remove(self.data.buttons, id) --this is somewhat redundant if deleting a bar, but it doesn't hurt and is important for individual button deletions
		table.remove(self.buttons, id)

		if object.binder then
			object.binder:KeybindOverlay_ClearBindings()
		end

		object:SetParent(Trashcan)
	end

	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:UpdateBarStatus()
end


function Bar:Load()
	self:SetPosition()
	self:LoadObjects()
	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:EnableKeyboard(false)
	self:UpdateBarStatus()
end

function Bar.ChangeSelectedBar(newBar)
	if newBar and Neuron.currentBar ~= newBar then
		Neuron.currentBar = newBar

		if newBar.data.hidden then
			newBar:SetBackdropColor(1,0,0,0.6)
		else
			newBar:SetBackdropColor(0,0,1,0.5)
		end
	end

	if not newBar then
		Neuron.currentBar = nil
	elseif newBar.text then
		newBar.Text:Show()
	end

	for k,v in pairs(Neuron.bars) do
		if v ~= newBar then

			if v:GetBarConceal() then
				v:SetBackdropColor(1,0,0,0.4)
			else
				v:SetBackdropColor(0,0,0,0.4)
			end

			v.microAdjust = false
			v:EnableKeyboard(false)
			v.Text:Hide()
			v.Message:Hide()
			v.MessageBG:Hide()
			v.mousewheelfunc = nil
			v.mousewheelfunc = nil
		end
	end

	if Neuron.currentBar then
		newBar:OnEnter(Neuron.currentBar)
	end
end
-----------------------------------


------------------------------------------------------------
--------------------Helper Functions------------------------
------------------------------------------------------------

local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function Bar.IsMouseOverSelfOrWatchFrame(frame)
	if frame:IsMouseOver() then
		return true
	end

	if frame.watchframes then
		for handler in pairs(frame.watchframes) do
			if handler:IsMouseOver() and handler:IsVisible() then
				return true
			end
		end
	end

	return false
end


---this function is set via a repeating scheduled timer in SetAutoHide()
function Bar:AutoHideUpdate()
	if self:GetAutoHide() and self.handler~=nil then
		if not Neuron.buttonEditMode and not Neuron.barEditMode and not Neuron.bindingMode then
			if self:IsShown() then
				self.handler:SetAlpha(1)
			else
				if Bar.IsMouseOverSelfOrWatchFrame(self) then
					if self.handler:GetAlpha() < self:GetBarAlpha() then
						if self.handler:GetAlpha()+self:GetAlphaUpSpeed() <= 1 then
							self.handler:SetAlpha(self.handler:GetAlpha()+self:GetAlphaUpSpeed())
						else
							self.handler:SetAlpha(1)
						end
					end
				end
				if not Bar.IsMouseOverSelfOrWatchFrame(self) then
					if self.handler:GetAlpha() > 0 then
						if self.handler:GetAlpha()-self:GetAlphaUpSpeed() >= 0 then
							self.handler:SetAlpha(self.handler:GetAlpha()-self:GetAlphaUpSpeed())
						else
							self.handler:SetAlpha(0)
						end
					end
				end
			end
		end
	end
end

function Bar:AlphaUpUpdate()
	if self:GetAlphaUp() == "combat" then
		if InCombatLockdown() then
			if self.handler:GetAlpha() < 1 then
				if self.handler:GetAlpha()+self:GetAlphaUpSpeed() <= 1 then
					self.handler:SetAlpha(self.handler:GetAlpha()+self:GetAlphaUpSpeed())
				else
					self.handler:SetAlpha(1)
				end
			end
		else
			if self.handler:GetAlpha() > self:GetBarAlpha() then
				if self.handler:GetAlpha()-self:GetAlphaUpSpeed() >= self:GetBarAlpha() then
					self.handler:SetAlpha(self.handler:GetAlpha()-self:GetAlphaUpSpeed())
				else
					self.handler:SetAlpha(self:GetBarAlpha())
				end
			end
		end
	elseif self:GetAlphaUp() == "combat + mouseover" then
		if InCombatLockdown() and Bar.IsMouseOverSelfOrWatchFrame(self)  then
			if self.handler:GetAlpha() < 1 then
				if self.handler:GetAlpha()+self:GetAlphaUpSpeed() <= 1 then
					self.handler:SetAlpha(self.handler:GetAlpha()+self:GetAlphaUpSpeed())
				else
					self.handler:SetAlpha(1)
				end
			end
		else
			if self.handler:GetAlpha() > self:GetBarAlpha() then
				if self.handler:GetAlpha()-self:GetAlphaUpSpeed() >= self:GetBarAlpha() then
					self.handler:SetAlpha(self.handler:GetAlpha()-self:GetAlphaUpSpeed())
				else
					self.handler:SetAlpha(self:GetBarAlpha())
				end
			end
		end
	elseif self:GetAlphaUp() == "mouseover" then
		if Bar.IsMouseOverSelfOrWatchFrame(self) then
			if self.handler:GetAlpha() < 1 then
				if self.handler:GetAlpha()+self:GetAlphaUpSpeed() <= 1 then
					self.handler:SetAlpha(self.handler:GetAlpha()+self:GetAlphaUpSpeed())
				else
					self.handler:SetAlpha(1)
				end
			end
		else
			if self.handler:GetAlpha() > self:GetBarAlpha() then
				if self.handler:GetAlpha()-self:GetAlphaUpSpeed() >= self:GetBarAlpha() then
					self.handler:SetAlpha(self.handler:GetAlpha()-self:GetAlphaUpSpeed())
				else
					self.handler:SetAlpha(self:GetBarAlpha())
				end
			end
		end
	end
end

function Bar:UpdateAutoHideTimer()
	if self:GetAutoHide() then
		if self:TimeLeft(self.autoHideTimer) == 0 then --safety check to make sure we don't re-set an already active timer
			self.autoHideTimer = self:ScheduleRepeatingTimer("AutoHideUpdate", 0.05)
		end
	else
		self:CancelTimer(self.autoHideTimer)
	end
end

function Bar:UpdateAlphaUpTimer()
	if self:GetAlphaUp() ~= "off" then
		if self:TimeLeft(self.alphaUpTimer) == 0 then --safety check to make sure we don't re-set an already active timer
			self.alphaUpTimer = self:ScheduleRepeatingTimer("AlphaUpUpdate", 0.05)
		end
	else
		self:CancelTimer(self.alphaUpTimer)
	end
end


function Bar:AddVisibilityDriver(handler, state, conditions)
	if Neuron.MANAGED_BAR_STATES[state] then
		RegisterAttributeDriver(handler, "state-"..state, conditions);

		if handler:GetAttribute("activestates"):find(state) then
			handler:SetAttribute("activestates", handler:GetAttribute("activestates"):gsub(state.."%d+;", handler:GetAttribute("state-"..state)..";"))
		elseif handler:GetAttribute("activestates") and handler:GetAttribute("state-"..state) then
			handler:SetAttribute("activestates", handler:GetAttribute("activestates")..handler:GetAttribute("state-"..state)..";")
		end

		if handler:GetAttribute("state-"..state) then
			handler:SetAttribute("state-"..state, handler:GetAttribute("state-"..state))
		end

		self.vis[state].registered = true
	end
end


function Bar:ClearVisibilityDriver(handler, state)
	UnregisterAttributeDriver(handler, "state-"..state)
	handler:SetAttribute("activestates", handler:GetAttribute("activestates"):gsub(state.."%d+;", ""))
	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")
	self.vis[state].registered = false
end


function Bar:UpdateBarVisibility(driver)
	for state, values in pairs(Neuron.MANAGED_BAR_STATES) do
		if self.data.hidestates:find(":"..state) then
			if not self.vis[state] or not self.vis[state].registered then
				if not self.vis[state] then
					self.vis[state] = {}
				end
				if state == "stance" and self.data.hidestates:find(":stance8") then
					self:AddVisibilityDriver(driver,state, "[stance:2/3,stealth] stance8; "..values.visibility)
				else
					self:AddVisibilityDriver(driver, state, values.visibility)
				end
			end
		elseif self.vis[state] and self.vis[state].registered then
			self:ClearVisibilityDriver(driver, state)
		end
	end
end

function Bar:BuildStateMap(remapState)
	local statemap, state, map, remap, homestate = "", remapState:gsub("paged", "bar")
	for states in gmatch(self.data.remap, "[^;]+") do
		map, remap = (":"):split(states)
		if remapState == "stance" and Neuron.class == "ROGUE" and map == "1" then
			--map = "2"
		end
		if not homestate then
			statemap = statemap.."["..state..":"..map.."] homestate; "; homestate = true
		else
			local newstate = remapState..remap

			if Neuron.MANAGED_BAR_STATES[remapState] and
					Neuron.MANAGED_BAR_STATES[remapState].homestate and
					Neuron.MANAGED_BAR_STATES[remapState].homestate == newstate then
				statemap = statemap.."["..state..":"..map.."] homestate; "
			else
				statemap = statemap.."["..state..":"..map.."] "..newstate.."; "
			end
		end
	end
	statemap = gsub(statemap, "; $", "")
	return statemap
end


function Bar:AddStates(handler, state, conditions)
	if state then
		if Neuron.MANAGED_BAR_STATES[state] then
			RegisterAttributeDriver(handler, "state-"..state, conditions);
		end
		if Neuron.MANAGED_BAR_STATES[state].homestate then
			handler:SetAttribute("handler-homestate", Neuron.MANAGED_BAR_STATES[state].homestate)
		end
		self[state].registered = true
	end
end

function Bar:ClearStates(handler, state)
	if state ~= "homestate" then
		if Neuron.MANAGED_BAR_STATES[state].homestate then
			handler:SetAttribute("handler-homestate", nil)
		end
		handler:SetAttribute("state-"..state, nil)
		UnregisterAttributeDriver(handler, "state-"..state)
		self[state].registered = false
	end
	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")
end


function Bar:UpdateStates(handler)
	for state, values in pairs(Neuron.MANAGED_BAR_STATES) do
		if self.data[state] then
			if not self[state] or not self[state].registered then
				local statemap

				if not self[state] then
					self[state] = {}
				end

				if self.data.remap and (state == "paged" or state == "stance") then
					statemap = self:BuildStateMap(state)
				end

				if state == "custom" and self.data.custom then
					self:AddStates(handler, state, self.data.custom)
				elseif statemap then
					self:AddStates(handler, state, statemap)
				else
					self:AddStates(handler, state, values.states)
				end
			end
		elseif self[state] and self[state].registered then
			self:ClearStates(handler, state)
		end
	end
end


function Bar:CreateDriver()
	--This is the macro base that will be used to set state
	local DRIVER_BASE_ACTION = [[
	local state = self:GetAttribute("state-<MODIFIER>"):match("%a+")

	if state then

		if self:GetAttribute("activestates"):find(state) then
			self:SetAttribute("activestates", self:GetAttribute("activestates"):gsub(state.."%d+;", self:GetAttribute("state-<MODIFIER>")..";"))
		else
			self:SetAttribute("activestates", self:GetAttribute("activestates")..self:GetAttribute("state-<MODIFIER>")..";")
		end

		control:ChildUpdate("<MODIFIER>", self:GetAttribute("activestates"))

	end
	]]

	local driver = CreateFrame("Frame", "NeuronBarDriver"..self.id, UIParent, "SecureHandlerStateTemplate")

	driver:SetID(self.id)
	--Dynamicly builds driver attributes based on stated in Neuron.MANAGED_BAR_STATES using localized attribute text from a above
	for _, stateInfo in pairs(Neuron.MANAGED_BAR_STATES) do
		local action = DRIVER_BASE_ACTION:gsub("<MODIFIER>", stateInfo.modifier)
		driver:SetAttribute("_onstate-"..stateInfo.modifier, action)
	end

	driver:SetAttribute("activestates", "")
	driver:HookScript("OnAttributeChanged", function() end)
	driver:SetAllPoints(self)
	self.driver = driver
	driver.bar = self
end


function Bar:CreateHandler()
	local HANDLER_BASE_ACTION = [[
	if self:GetAttribute("state-<MODIFIER>") == "laststate" then

		if self:GetAttribute("statestack") then

			if self:GetAttribute("statestack"):find("<MODIFIER>") then
				self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("<MODIFIER>%d+;", ""))
			end

			local laststate = (";"):split(self:GetAttribute("statestack"))
			self:SetAttribute("state-last", laststate)
		end

		self:SetAttribute("state-current", self:GetAttribute("state-last") or "homestate")

		if self:GetAttribute("state-last") then
			self:SetAttribute("assertstate", self:GetAttribute("state-last"):gsub("%d+", ""))
		else
			self:SetAttribute("assertstate", "homestate")
		end

		if self:GetAttribute("state-priority") then
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-priority"))
		else
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-last") or "homestate")
		end

	elseif self:GetAttribute("state-<MODIFIER>") then

		if self:GetAttribute("statestack") then

			if self:GetAttribute("statestack"):find("<MODIFIER>") then
				self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("<MODIFIER>%d+", self:GetAttribute("state-<MODIFIER>")))
			else
				self:SetAttribute("statestack", self:GetAttribute("state-<MODIFIER>")..";"..self:GetAttribute("statestack"))
			end

		else
			self:SetAttribute("statestack", self:GetAttribute("state-<MODIFIER>"))
		end

		self:SetAttribute("state-current", self:GetAttribute("state-<MODIFIER>"))
		self:SetAttribute("assertstate", "<MODIFIER>")

		if self:GetAttribute("state-priority") then
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-priority"))
		else
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-<MODIFIER>"))
		end

	end
	]]

	local handler = CreateFrame("Frame", "NeuronBarHandler"..self.id, self.driver, "SecureHandlerStateTemplate")

	handler:SetID(self.id)

	--Dynamicly builds handler actions based on states in Neuron.MANAGED_BAR_STATES using Global text
	for _, stateInfo in pairs(Neuron.MANAGED_BAR_STATES) do
		local action = HANDLER_BASE_ACTION:gsub("<MODIFIER>", stateInfo.modifier)
		handler:SetAttribute("_onstate-"..stateInfo.modifier, action)
	end

	handler:SetAttribute("_onstate-paged",
			[[
			if self:GetAttribute("statestack") then

				if self:GetAttribute("statestack"):find("paged") then
					self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("paged%d+", self:GetAttribute("state-paged") or "homestate"))
				elseif self:GetAttribute("statestack"):find("homestate") then
					self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("homestate", self:GetAttribute("state-paged") or "homestate"))
				elseif self:GetAttribute("state-paged") then
					self:SetAttribute("statestack", self:GetAttribute("statestack")..";"..self:GetAttribute("state-paged"))
				end

			else
				self:SetAttribute("statestack", self:GetAttribute("state-paged"))
			end

			if self:GetAttribute("statestack"):find("^paged") or self:GetAttribute("statestack"):find("^homestate") then
				self:SetAttribute("assertstate", "paged")
				self:SetAttribute("state-last", self:GetAttribute("state-paged"))
				self:SetAttribute("state-current", self:GetAttribute("state-paged"))

				if self:GetAttribute("state-priority") then
					control:ChildUpdate("paged", self:GetAttribute("state-priority"))
				elseif self:GetAttribute("state-paged") and self:GetAttribute("state-paged") == self:GetAttribute("handler-homestate") then
					control:ChildUpdate("paged", "homestate:"..self:GetAttribute("state-paged"))
				else
					control:ChildUpdate("paged", self:GetAttribute("state-paged"))
				end

			else

				if self:GetAttribute("state-priority") then
					control:ChildUpdate("homestate", self:GetAttribute("state-priority"))
				else
					control:ChildUpdate("homestate", "homestate")
				end

			end
			]])

	handler:SetAttribute("_onstate-stance",
			[[
			if self:GetAttribute("statestack") then

				if self:GetAttribute("statestack"):find("stance") then
					self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("stance%d+", self:GetAttribute("state-stance") or "homestate"))
				elseif self:GetAttribute("statestack"):find("homestate") then
					self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("homestate", self:GetAttribute("state-stance") or "homestate"))
				elseif self:GetAttribute("state-stance") then
					self:SetAttribute("statestack", self:GetAttribute("statestack")..";"..self:GetAttribute("state-stance"))
				end

			else
				self:SetAttribute("statestack", self:GetAttribute("state-stance"))
			end

			if self:GetAttribute("statestack"):find("^stance") or self:GetAttribute("statestack"):find("^homestate") then
				self:SetAttribute("assertstate", "stance")
				self:SetAttribute("state-last", self:GetAttribute("state-stance"))
				self:SetAttribute("state-current", self:GetAttribute("state-stance"))

				if self:GetAttribute("state-priority") then
					control:ChildUpdate("stance", self:GetAttribute("state-priority"))
				elseif self:GetAttribute("state-stance") and self:GetAttribute("state-stance") == self:GetAttribute("handler-homestate") then
					control:ChildUpdate("stance", "homestate:"..self:GetAttribute("state-stance"))
				else
					control:ChildUpdate("stance", self:GetAttribute("state-stance"))
				end

			else

				if self:GetAttribute("state-priority") then
					control:ChildUpdate("homestate", self:GetAttribute("state-priority"))
				else
					control:ChildUpdate("homestate", "homestate")
				end

			end
			]])

	handler:SetAttribute("_onstate-pet",
			[[
			if self:GetAttribute("statestack") then

				if self:GetAttribute("statestack"):find("pet") then
					self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("pet%d+", self:GetAttribute("state-pet") or "homestate"))
				elseif self:GetAttribute("statestack"):find("homestate") then
					self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("homestate", self:GetAttribute("state-pet" or "homestate")))
				elseif self:GetAttribute("state-pet") then
					self:SetAttribute("statestack", self:GetAttribute("statestack")..";"..self:GetAttribute("state-pet"))
				end

			else
				self:SetAttribute("statestack", self:GetAttribute("state-pet"))
			end

			if self:GetAttribute("statestack"):find("^pet") or self:GetAttribute("statestack"):find("^homestate") then
				self:SetAttribute("assertstate", "pet")
				self:SetAttribute("state-last", self:GetAttribute("state-pet"))
				self:SetAttribute("state-current", self:GetAttribute("state-pet"))

				if self:GetAttribute("state-priority") then
					control:ChildUpdate("stance", self:GetAttribute("state-priority"))
				elseif self:GetAttribute("state-pet") and self:GetAttribute("state-pet") == self:GetAttribute("handler-homestate") then
					control:ChildUpdate("pet", "homestate:"..self:GetAttribute("state-pet"))
				else
					control:ChildUpdate("pet", self:GetAttribute("state-pet"))
				end

			else

				if self:GetAttribute("state-priority") then
					control:ChildUpdate("homestate", self:GetAttribute("state-priority"))
				else
					control:ChildUpdate("homestate", "homestate")
				end

			end
			]])

	handler:SetAttribute("_onstate-custom",
			[[
			self:SetAttribute("assertstate", "custom")
			self:SetAttribute("state-last", self:GetAttribute("state-custom"))
			self:SetAttribute("state-current", self:GetAttribute("state-custom"))
			control:ChildUpdate("alt", self:GetAttribute("state-custom"))
			]])

	handler:SetAttribute("_onstate-current",
			[[
			self:SetAttribute("activestate", self:GetAttribute("state-current") or "homestate")
			]])

	handler:SetAttribute("statestack", "homestate")

	handler:SetAttribute("activestate", "homestate")

	handler:SetAttribute("state-last", "homestate")

	handler:HookScript("OnAttributeChanged", function() end)


	handler:SetAttribute("_childupdate",
			[[
			if not self:GetAttribute("editmode") then
				self:SetAttribute("vishide", false)

				if self:GetAttribute("hidestates") then

					for state in gmatch(message, "[^;]+") do
						for hidestate in gmatch(self:GetAttribute("hidestates"), "[^:]+") do

							if state == hidestate then
								self:Hide()
								self:SetAttribute("vishide", true)
							end

						end
					end
				end

				if not self:IsShown() and not self:GetAttribute("vishide") then
					self:Show()
				end
			end
			]] )
	handler:SetAllPoints(self)
	self.handler = handler;
	handler.bar = self
end


function Bar:CreateWatcher()
	local watcher = CreateFrame("Frame", "NeuronBarWatcher"..self.id, self.handler, "SecureHandlerStateTemplate")

	watcher:SetID(self.id)

	watcher:SetAttribute("_onattributechanged",
			[[ ]])

	watcher:SetAttribute("_onstate-petbattle",
			[[
            if self:GetAttribute("state-petbattle") == "hide" then
                self:GetParent():Hide()
            else

                if not self:GetParent():IsShown() then
                    if not self:GetParent():GetAttribute("vishide") and not self:GetParent():GetAttribute("concealed") then
                        self:GetParent():Show()
                    end
                end

            end
            ]])
	RegisterAttributeDriver(watcher, "state-".."petbattle", "[petbattle] hide; [nopetbattle] show");
end

function Bar:UpdateBarStatus(show)
	if InCombatLockdown() then
		return
	end

	if self.stateschanged then
		self:UpdateStates(self.handler)
		self.stateschanged = false
	end

	if self.vischanged then
		self.handler:SetAttribute("hidestates", self.data.hidestates)
		self:UpdateBarVisibility(self.driver)
		self.vischanged = false
	end

	-- the fix for github #362 goes here: SetHidden conceal concealed
	-- possibly autohide is broken as well and that will go here as well
	self.Text:SetText(self:GetBarName())
	self.handler:SetAlpha(self:GetBarAlpha())
end

-------------------------------------------------------


function Bar:GetPosition(oFrame)
	local relFrame, point

	if oFrame then
		relFrame = oFrame
	else
		relFrame = self:GetParent()
	end

	local s = self:GetScale()
	local w, h = relFrame:GetWidth()/s, relFrame:GetHeight()/s
	local x, y = self:GetCenter()
	local vert = (y>h/1.5) and "TOP" or (y>h/3) and "CENTER" or "BOTTOM"
	local horz = (x>w/1.5) and "RIGHT" or (x>w/3) and "CENTER" or "LEFT"

	if vert == "CENTER" then
		point = horz
	elseif horz == "CENTER" then
		point = vert
	else
		point = vert..horz
	end

	if vert:find("CENTER") then
		y = y - h/2
	end
	if horz:find("CENTER") then
		x = x - w/2
	end
	if point:find("RIGHT") then
		x = x - w
	end
	if point:find("TOP") then
		y = y - h
	end

	return point, x, y
end


function Bar:SetPosition()
	if self.data.snapToPoint and self.data.snapToFrame then
		self:StickToPoint(_G[self.data.snapToFrame], self.data.snapToPoint,self:GetHorizontalPad(), self:GetVerticalPad())
	else

		local point, x, y = self.data.point, self:GetXAxis(), self:GetYAxis()

		if point:find("SnapTo") then
			self.data.point = "CENTER"
			point = "CENTER"
		end

		self:SetUserPlaced(false)
		self:ClearAllPoints()
		self:SetPoint("CENTER", "UIParent", point, x, y)
		self:SetUserPlaced(true)
		self:SetFrameStrata(Neuron.STRATAS[self:GetStrata()])

		if self.Message then
			self.Message:SetText(point:lower().."     x: "..format("%0.2f", x).."     y: "..format("%0.2f", y))
			self.MessageBG:SetWidth(self.Message:GetWidth()*1.05)
			self.MessageBG:SetHeight(self.Message:GetHeight()*1.1)
		end
	end
end

--Fakes a state change for a given bar, calls up the counterpart function in NeuronButton
function Bar:FakeStateChange(state)
	self.handler:SetAttribute("fauxstate", state)

	for i, object in ipairs(self.buttons) do
		object:FakeStateChange(state)
	end

end

--loads all the object stored for a given bar
function Bar:LoadObjects()
	local spec = Spec.active(self:GetMultiSpec())

	for i, object in ipairs(self.buttons) do
		--all of these objects need to stay as "object:****" because which InitializeButtonSettings/LoadDataFromDatabase/etc is bar dependent. Symlinks are made to the asociated bar objects to these class functions
		object:LoadDataFromDatabase(spec, self.handler:GetAttribute("activestate"))
		object:InitializeButton()
		object:UpdateVisibility()
	end
end


function Bar:SetObjectLoc()
	local width, height, num, origCol = 0, 0, 0, self:GetColumns()
	local x, y, placed
	local shape, padH, padV, arcStart, arcLength = self:GetBarShape(), self:GetHorizontalPad(), self:GetVerticalPad(), self:GetArcStart(), self:GetArcLength()
	local cAdjust, rAdjust = 0.5, 1
	local columns, rows


	--This is just for the flyout bar, it should be cleaned in the future
	local count
	if self.class ~= "FlyoutBar" then
		count = #self.buttons
	else
		count = #self.data.objectList
	end

	local buttons = {}
	if self.class ~= "FlyoutBar" then
		buttons = self.buttons
	else
		for k,v in pairs (self.data.objectList) do
			table.insert(buttons, Neuron.FOBTNIndex[v])
		end
	end

	--------------------------------------------------------------------------

	if origCol == 0 then
		origCol = count
		rows = 1
	else
		rows = (round(ceil(count/self:GetColumns()), 1)/2)+0.5
	end

	for i, object in ipairs(buttons) do --once the flyout bars are fixed, this can be changed to ipairs(self.buttons)

		if num < count then
			object:ClearAllPoints()
			object:SetParent(self.handler)
			width = object:GetWidth()
			height = object:GetHeight()

			if count > origCol and mod(count, origCol)~=0 and rAdjust == 1 then
				columns = (mod(count, origCol))/2
			elseif origCol >= count then
				columns = count/2
			else
				columns = origCol/2
			end

			if shape == "circle" then
				if not placed then
					placed = arcStart
				end

				x = ((width+padH)*(count/math.pi))*(cos(placed))
				y = ((width+padV)*(count/math.pi))*(sin(placed))

				object:SetPoint("CENTER", self, "CENTER", x, y)

				placed = placed - (arcLength/count)

			elseif shape == "circle + one" then
				if not placed then
					placed = arcStart
					object:SetPoint("CENTER", self, "CENTER", 0, 0)
					placed = placed - (arcLength/count)

				else
					x = ((width+padH)*(count/math.pi))*(cos(placed))
					y = ((width+padV)*(count/math.pi))*(sin(placed))

					object:SetPoint("CENTER", self, "CENTER", x, y)
					placed = placed - (arcLength/(count-1))
				end
			else
				if not placed then
					placed = 0
				end

				x = -(width + padH) * (columns-cAdjust)
				y = (height + padV) * (rows-rAdjust)

				object:SetPoint("CENTER", self, "CENTER", x, y)
				placed = placed + 1; cAdjust = cAdjust + 1

				if placed >= columns*2 then
					placed = 0
					cAdjust = 0.5
					rAdjust = rAdjust + 1
				end
			end

			num = num + 1
			object:SetAttribute("barPos", num)
			object:InitializeButtonSettings()
		end
	end
end


function Bar:SetPerimeter()
	local num = 0

	--This is just for the flyout bar, it should be cleaned in the future
	local count
	if self.class ~= "FlyoutBar" then
		count = #self.buttons
	else
		count = #self.data.objectList
	end

	local buttons = {}
	if self.class ~= "FlyoutBar" then
		buttons = self.buttons
	else
		for k,v in pairs (self.data.objectList) do
			table.insert(buttons, Neuron.FOBTNIndex[v])
		end
	end
	-----------------------------------------------

	self.top = nil; self.bottom = nil; self.left = nil; self.right = nil

	for i, object in ipairs(buttons) do --once the flyout bars are fixed, this can be changed to ipairs(self.buttons)

		if num < count then
			local objTop, objBottom, objLeft, objRight = object:GetTop(), object:GetBottom(), object:GetLeft(), object:GetRight()
			local scale = 1
			--See if this fixes the ranom position error that happens
			if not objTop then return end

			if self.top then
				if objTop*scale > self.top then self.top = objTop*scale end
			else self.top = objTop*scale end

			if self.bottom then
				if objBottom*scale < self.bottom then self.bottom = objBottom*scale end
			else self.bottom = objBottom*scale end

			if self.left then
				if objLeft*scale < self.left then self.left = objLeft*scale end
			else self.left = objLeft*scale end

			if self.right then
				if objRight*scale > self.right then self.right = objRight*scale end
			else self.right = objRight*scale end

			num = num + 1
		end
	end
end


function Bar:SetDefaults(defaults)
	for k,v in pairs(defaults) do
		if k ~= "buttons" then --ignore this value because it's just used to tell how many buttons should be placed on a bar by default on the first load
			self.data[k] = v
		end
	end
end


function Bar:SetRemap_Paged()
	self.data.remap = ""

	for i=1,6 do
		self.data.remap = self.data.remap..i..":"..i..";"
	end

	self.data.remap = gsub(self.data.remap, ";$", "")
end


function Bar:SetRemap_Stance()
	local start = tonumber(Neuron.MANAGED_BAR_STATES.stance.homestate:match("%d+"))

	if start then
		self.data.remap = ""

		for i=start,GetNumShapeshiftForms() do
			self.data.remap = self.data.remap..i..":"..i..";"
		end

		self.data.remap = gsub(self.data.remap, ";$", "")


		if Neuron.class == "ROGUE" then
			self.data.remap = self.data.remap..";2:2"
		end
	end
end


function Bar:SetSize()
	if self.right then
		self:SetWidth(((self.right-self.left)+5) * self:GetBarScale())
		self:SetHeight(((self.top-self.bottom)+5) * self:GetBarScale())
	else
		self:SetWidth(195)
		self:SetHeight(36 * self:GetBarScale())
	end
end




----------------------------------------------------------------------
------------------------OnEvent Functions-----------------------------
----------------------------------------------------------------------

function Bar:OnClick(...)
	local click, down = select(1, ...), select(2, ...)

	if not down then
		Bar.ChangeSelectedBar(self)
	end

	if IsShiftKeyDown() and not down then

		if self.microAdjust then
			self.microAdjust = false
			self:EnableKeyboard(false)
			self.Message:Hide()
			self.MessageBG:Hide()
		else
			self.microAdjust = 1
			self:EnableKeyboard(true)
			self.Message:Show()
			self.Message:SetText(self.data.point:lower().."     x: "..format("%0.2f", self:GetXAxis()).."     y: "..format("%0.2f", self:GetYAxis()))
			self.MessageBG:Show()
			self.MessageBG:SetWidth(self.Message:GetWidth()*1.05)
			self.MessageBG:SetHeight(self.Message:GetHeight()*1.1)
		end

	elseif click == "MiddleButton" then
		if GetMouseFocus() ~= Neuron.currentBar then
			Bar.ChangeSelectedBar(self)
		end

	elseif click == "RightButton" and not down then
		self.mousewheelfunc = nil
		if not addonTable.NeuronEditor then
			Neuron.NeuronGUI:CreateEditor()
		end
	end

	if addonTable.NeuronEditor then
		Neuron.NeuronGUI:RefreshEditor()
	end
end


function Bar:OnEnter(...)
	if self:GetBarConceal() then
		self:SetBackdropColor(1,0,0,0.6)
	else
		self:SetBackdropColor(0,0,1,0.5)
	end

	self.Text:Show()
end


function Bar:OnLeave(...)
	if self ~= Neuron.currentBar then
		if self:GetBarConceal() then
			self:SetBackdropColor(1,0,0,0.4)
		else
			self:SetBackdropColor(0,0,0,0.4)
		end
	end

	if self ~= Neuron.CurrentBar then
		self.Text:Hide()
		if self ~= Neuron.currentBar then
			self.Text:Hide()
		end
	end

end


function Bar:OnDragStart(...)
	Bar.ChangeSelectedBar(self)

	self:SetFrameStrata(Neuron.STRATAS[self:GetStrata()])
	self:EnableKeyboard(false)

	self.data.snapToPoint = false
	self.data.snapToFrame = false

	self:StartMoving()
end


function Bar:OnDragStop(...)

	local point
	self:StopMovingOrSizing()

	for _,v in pairs(Neuron.bars) do
		if not point and self:GetSnapTo() and v:GetSnapTo() and self ~= v then
			point = self:Stick(v, Neuron.SNAPTO_TOLERANCE, self:GetHorizontalPad(), self:GetVerticalPad())

			if point then
				self.data.snapToPoint = point
				self.data.snapToFrame = v:GetName()
				self.data.point = "SnapTo: "..point
			end
		end
	end

	if not point then
		self.data.snapToPoint = false
		self.data.snapToFrame = false

		local newPoint, x, y = self:GetPosition()
		self.data.point = newPoint
		self:SetXAxis(x)
		self:SetYAxis(y)

		self:SetPosition()
	end

	if self:GetSnapTo() and not self.data.snapToPoint then
		self:StickToEdge()
	end

	self:UpdateBarStatus()
end

function Bar:OnKeyDown(key)
	if self.microAdjust then
		self.keydown = key

		local newPoint, x, y = self:GetPosition()
		self.data.point = newPoint
		self:SetXAxis(x)
		self:SetYAxis(y)

		self:SetUserPlaced(false)
		self:ClearAllPoints()

		if key == "UP" then
			self:SetYAxis(self:GetYAxis() + .1 * self.microAdjust)
		elseif key == "DOWN" then
			self:SetYAxis(self:GetYAxis() - .1 * self.microAdjust)
		elseif key == "LEFT" then
			self:SetXAxis(self:GetXAxis() - .1 * self.microAdjust)
		elseif key == "RIGHT" then
			self:SetXAxis(self:GetXAxis() + .1 * self.microAdjust)
		elseif not key:find("SHIFT") then
			self.microAdjust = false
			self:EnableKeyboard(false)
		end

		self:SetPosition()
	end
end


function Bar:OnKeyUp(key)
	if self.microAdjust and not key:find("SHIFT") then
		self.microAdjust = 1
		self.keydown = nil
	end
end


function Bar:OnShow()
	if self == Neuron.currentBar then
		if self:GetBarConceal() then
			self:SetBackdropColor(1,0,0,0.6)
		else
			self:SetBackdropColor(0,0,1,0.5)
		end
	else
		if self:GetBarConceal() then
			self:SetBackdropColor(1,0,0,0.4)
		else
			self:SetBackdropColor(0,0,0,0.4)
		end
	end

	self.handler:SetAttribute("editmode", true)
	self.handler:Show()
	self:UpdateObjectVisibility()
	self:EnableKeyboard(false)
end


function Bar:OnHide()
	self.handler:SetAttribute("editmode", nil)

	if self.handler:GetAttribute("vishide") then
		self.handler:Hide()
	end

	self:UpdateObjectVisibility()
	self:EnableKeyboard(false)
end


function Bar:Pulse(elapsed)
	alphaTimer = alphaTimer + elapsed * 1.5

	if alphaDir == 1 then
		if 1-alphaTimer <= 0 then
			alphaDir = 0; alphaTimer = 0
		end
	else
		if alphaTimer >= 1 then
			alphaDir = 1; alphaTimer = 0
		end
	end

	if alphaDir == 1 then
		if (1-(alphaTimer)) >= 0 then
			self:SetAlpha(1-(alphaTimer))
		end
	else
		if (alphaTimer) <= 1 then
			self:SetAlpha((alphaTimer))
		end
	end

	self.pulse = true
end


---------------------------------------------------------------------------
---------------------------------------------------------------------------

function Bar:UpdateButtonSettings()
	for _, object in pairs(self.buttons) do
		if object then
			object:InitializeButtonSettings()
		end
	end
end


function Bar:UpdateObjectVisibility(show)
	for _, object in pairs(self.buttons) do
		if object then
			object:UpdateVisibility(show)
		end
	end
end

function Bar:UpdateObjectUsability()
	for _, object in pairs(self.buttons) do
		if object then
			object:UpdateUsable()
		end
	end
end

function Bar:UpdateObjectIcons()
	for _, object in pairs(self.buttons) do
		if object then
			object:UpdateIcon()
		end
	end
end

function Bar:UpdateObjectCooldowns()
	for _, object in pairs(self.buttons) do
		if object then
			object:CancelCooldownTimer(true) --this will reset the text/alpha on the button
			object:UpdateCooldown()
		end
	end
end

function Bar:UpdateObjectCooldowns()
	for _, object in pairs(self.buttons) do
		if object then
			object:CancelCooldownTimer(true) --this will reset the text/alpha on the button
			object:UpdateCooldown()
		end
	end
end

function Bar:UpdateObjectStatus()
	for _, object in pairs(self.buttons) do
		if object then
			object:UpdateStatus()
		end
	end
end

-----------------------------------------------------
-------------------Sets and Gets---------------------
-----------------------------------------------------

function Bar:SetBarName(name)
	if name and name ~= "" then
		self.data.name = name
	end
	self:UpdateBarStatus()
end

function Bar:GetBarName()
	return self.data.name
end

function Bar:GetNumObjects()
	return #self.buttons
end

--TODO: Rewrite this and simplify it
function Bar:SetState(msg, gui, checked)
	if msg then
		local state = msg:match("^%S+")
		local command = msg:gsub(state, "");
		command = command:gsub("^%s+", "")

		if not Neuron.MANAGED_BAR_STATES[state] then
			if not gui then
				Neuron:PrintStateList()
			else
				Neuron:Print("GUI option error")
			end
			return
		end

		if gui then
			self.data[state] = not not checked
		else
			self.data[state] = not self.data[state]
		end

		if state == "paged" then
			self.data.stance = false
			self.data.pet = false

			if self.data.paged then
				self:SetRemap_Paged()
			else
				self.data.remap = false
			end
		end

		if state == "stance" then
			self.data.paged = false
			self.data.pet = false


			if Neuron.class == "ROGUE" and self.data.stealth then
				self.data.stealth = false
			end

			if self.data.stance then
				self:SetRemap_Stance()
			else
				self.data.remap = false
			end
		end

		if state == "custom" then
			if self.data.custom then
				local count, newstates = 0, ""

				self.data.customNames = {}

				for states in gmatch(command, "[^;]+") do
					if string.find(states, "%[(.+)%]") then
						self.data.customRange = "1;"..count

						if count == 0 then
							newstates = states.." homestate;"
							self.data.customNames["homestate"] = states
						else
							newstates = newstates..states.." custom"..count..";"
							self.data.customNames["custom"..count] = states
						end

						count = count + 1
					else
						Neuron:Print(states.." not formated properly and skipped")
					end
				end

				if newstates ~= ""  then
					self.data.custom = newstates
				else
					self.data.custom = false
					self.data.customNames = false
					self.data.customRange = false
				end

			else
				self.data.customNames = false
				self.data.customRange = false
			end

			--Clears any previous set cusom vis settings
			for states in gmatch(self.data.hidestates, "custom%d+") do
				self.data.hidestates = self.data.hidestates:gsub(states..":", "")
			end
			if not self.data.hidestates then Neuron:Print("OOPS")
			end
		end

		if state == "pet" then
			self.data.paged = false
			self.data.stance = false
		end

		self.stateschanged = true
		self:UpdateBarStatus()

	elseif not gui then
		wipe(statetable)

		for k,v in pairs(Neuron.MANAGED_BAR_STATES) do

			if self.data[k] then
				table.insert(statetable, v.localizedName..": on")
			else
				table.insert(statetable, v.localizedName..": off")
			end
		end

		table.sort(statetable)

		for k,v in ipairs(statetable) do
			Neuron:Print(v)
		end
	end

end

--TODO: Rewrite this and simplify it
---@param toggle string
---@param visible boolean
function Bar:SetVisibility(toggle, visible)
	toggle = toggle:lower()

	if not toggle
		or not Neuron.STATES[toggle]
	then
		return
	end

	-- update the preferences - model
	if Neuron.STATES[toggle] or (toggle == "custom" and self.data.customNames) then
		if visible and self.data.hidestates:find(toggle) then
			self.data.hidestates = self.data.hidestates:gsub(toggle..":", "")
		elseif not visible and not self.data.hidestates:find(toggle) then
			self.data.hidestates = self.data.hidestates..toggle..":"
		end
	else
		Neuron:Print(L["Invalid index"]); return
	end

	self.vischanged = true
	self:UpdateBarStatus()
end


function Bar:SetAutoHide(checked)
	if checked then
		self.data.autoHide = true
	else
		self.data.autoHide = false
	end

	self:UpdateAutoHideTimer()
	self:UpdateBarStatus()
end

function Bar:GetAutoHide()
	return self.data.autoHide
end

function Bar:SetShowGrid(checked)
	if checked then
		self.data.showGrid = true
	else
		self.data.showGrid = false
	end

	self:UpdateObjectVisibility()
	self:UpdateBarStatus()
end

function Bar:GetShowGrid()
	return self.data.showGrid
end

function Bar:SetSpellGlow(option)
	if option then
		if option == "default" then
			self.data.spellGlow = "default"
		elseif option == "alternate" then
			self.data.spellGlow = "alternate"
		elseif option == "none" then
			self.data.spellGlow = false
		end
	else
		self.data.spellGlow = false
	end

	self:UpdateBarStatus()
end

function Bar:GetSpellGlow()
	return self.data.spellGlow
end


function Bar:SetSnapTo(checked)
	if checked then
		self.data.snapTo = true
	else
		self.data.snapTo = false

		self.data.snapToPoint = false
		self.data.snapToFrame = false

		self:SetUserPlaced(true)

		local newPoint, x, y = self:GetPosition()

		self.data.point = newPoint
		self:SetXAxis(x)
		self:SetYAxis(y)
		self:SetPosition()
	end

	self:UpdateBarStatus()
end

function Bar:GetSnapTo()
	return self.data.snapTo
end


function Bar:SetClickMode(mode)
	if mode then
		self.data.clickMode = mode
	else
		self.data.clickMode = "UpClick"
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetClickMode()
	return self.data.clickMode
end


function Bar:SetMultiSpec(checked)
	if checked then
		self.data.multiSpec = true
	else
		self.data.multiSpec = false
	end

	for _,object in ipairs(self.buttons) do
		object:UpdateButtonSpec()
	end

	self:UpdateBarStatus()
end

function Bar:GetMultiSpec()
	return self.data.multiSpec
end


function Bar:SetBarConceal(checked)
	if checked then
		self.data.conceal = true
		self:SetBackdropColor(1,0,0,0.4)
	else
		self.data.conceal = false
		self:SetBackdropColor(0,0,0,0.4)
	end

	self:UpdateBarStatus()
end

function Bar:GetBarConceal()
	return self.data.conceal
end

function Bar:SetBarLock(option)
	if option then
		if option == "shift" then
			self.data.barLock = "shift"
		elseif option == "ctrl" then
			self.data.barLock = "ctrl"
		elseif option == "alt" then
			self.data.barLock = "alt"
		elseif option =="none" then
			self.data.barLock = false
		end
	else
		self.data.barLock = false
	end

	self:UpdateBarStatus()
end

function Bar:GetBarLock()
	return self.data.barLock
end


function Bar:SetTooltipOption(option)
	if option then
		if option == "minimal" then
			self.data.tooltips = "minimal"
		elseif option == "normal" then
			self.data.tooltips = "normal"
		elseif option == "off" then
			self.data.tooltips = "off"
		end
	else
		self.data.tooltips = "off"
	end

	self:UpdateBarStatus()
end

function Bar:GetTooltipOption()
	return self.data.tooltips
end

function Bar:SetTooltipCombat(checked)
	if checked then
		self.data.tooltipsCombat = true
	else
		self.data.tooltipsCombat = false
	end

	self:UpdateBarStatus()
end

function Bar:GetTooltipCombat()
	return self.data.tooltipsCombat
end

function Bar:SetBarShape(option)
	if option then
		if option == "linear" or option == "circle" or option == "circle + one" then
			self.data.shape = option
		else
			self.data.shape = "linear"
		end
	else
		self.data.shape = "linear"
	end

	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:UpdateBarStatus()
end

function Bar:GetBarShape()
	return self.data.shape
end

function Bar:SetColumns(option)
	if option then
		if option > 0 then
			self.data.columns = option
		else
			self.data.columns = self:GetNumObjects()
		end
	else
		self.data.columns = 0
	end

	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:UpdateBarStatus()
end

function Bar:GetColumns()
	return self.data.columns
end

function Bar:SetArcStart(option)
	if option then
		self.data.arcStart = option
	else
		self.data.arcStart = 0
	end

	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:UpdateBarStatus()
end

function Bar:GetArcStart()
	return self.data.arcStart
end

function Bar:SetArcLength(option)
	if option then
		self.data.arcLength = option
	else
		self.data.arcLength = 359
	end

	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:UpdateBarStatus()
end

function Bar:GetArcLength()
	return self.data.arcLength
end



function Bar:SetHorizontalPad(option)
	if option then
		self.data.padH = option
	else
		self.data.padH = 0
	end

	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:UpdateBarStatus()
end

function Bar:GetHorizontalPad()
	return self.data.padH
end

function Bar:SetVerticalPad(option)
	if option then
		self.data.padV = option
	else
		self.data.padV = 0
	end

	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:UpdateBarStatus()
end

function Bar:GetVerticalPad()
	return self.data.padV
end


function Bar:SetBarScale(option)
	if option then
		self.data.scale = option
	else
		self.data.scale = 1
	end

	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:UpdateBarStatus()
end

function Bar:GetBarScale()
	return self.data.scale
end

function Bar:SetStrata(option)
	--option should be numeric, and should not ever be lower than 2. In the GUI we should make sure the list starts at 2 and runs until 6
	if option and option >=2 and option <= 6 then
		self.data.strata = option
	else
		self.data.strata = 3
	end

	self:SetPosition()
	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetStrata()
	return self.data.strata
end

function Bar:SetBarAlpha(option)
	if option then
		self.data.alpha = option
	else
		self.data.alpha = 1
	end

	self.handler:SetAlpha(self:GetBarAlpha()) --not sure if this should be here
	self:UpdateBarStatus()
end

function Bar:GetBarAlpha()
	return self.data.alpha
end

function Bar:SetAlphaUp(option)
	if option then
		if option == "off" or option == "mouseover" or option == "combat" or option =="combat + mouseover" then
			self.data.alphaUp = option
		else
			self.data.alphaUp = "off"
		end
	else
		self.data.alphaUp = "off"
	end

	self:UpdateAlphaUpTimer()
	self:UpdateBarStatus()
end

function Bar:GetAlphaUp()
	--TODO: Get rid of :lower() in the future
	return self.data.alphaUp:lower() --shouldn't have to set lower but older databases might have some capital letters
end

function Bar:SetAlphaUpSpeed(option)
	if option then
		if option < 0.01 then
			self.data.fadeSpeed = 0.01
		elseif option > 1 then
			self.data.fadeSpeed = 1
		else
			self.data.fadeSpeed = option
		end
	else
		self.data.fadeSpeed = 0.5
	end

	self:UpdateBarStatus()
end

function Bar:GetAlphaUpSpeed()
	return self.data.fadeSpeed
end

function Bar:SetXAxis(option)
	if option then
		self.data.x = option
	else
		self.data.x = 0
	end

	self:SetPosition()
	self:UpdateBarStatus()
end

function Bar:GetXAxis()
	return self.data.x
end

function Bar:SetYAxis(option)
	if option then
		self.data.y = option
	else
		self.data.y = 190
	end

	self:SetPosition()
	self:UpdateBarStatus()
end

function Bar:GetYAxis()
	return self.data.y
end

function Bar:SetShowBindText(checked)
	if checked then
		self.data.bindText = true
	else
		self.data.bindText = false
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetShowBindText()
	return self.data.bindText
end

function Bar:SetBindColor(option)
	if option then
		self.data.bindColor = option
	else
		self.data.bindColor = {1,1,1,1}
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetBindColor()
	return self.data.bindColor
end

function Bar:SetShowButtonText(checked)
	if checked then
		self.data.buttonText = true
	else
		self.data.buttonText = false
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetShowButtonText()
	return self.data.buttonText
end

function Bar:SetMacroColor(option)
	if option then
		self.data.macroColor = option
	else
		self.data.macroColor = {1,1,1,1}
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetMacroColor()
	return self.data.macroColor
end

function Bar:SetShowCountText(checked)
	if checked then
		self.data.countText = true
	else
		self.data.countText = false
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetShowCountText()
	return self.data.countText
end

function Bar:SetCountColor(option)
	if option then
		self.data.countColor = option
	else
		self.data.countColor = {1,1,1,1}
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetCountColor()
	return self.data.countColor
end

function Bar:SetShowRangeIndicator(checked)
	if checked then
		self.data.rangeInd = true
	else
		self.data.rangeInd = false
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetShowRangeIndicator()
	return self.data.rangeInd
end

function Bar:SetRangeColor(option)
	if option then
		self.data.rangecolor = option
	else
		self.data.rangecolor = {0.7,0.15,0.15,1}
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetRangeColor()
	return self.data.rangecolor
end

function Bar:SetShowCooldownText(checked)
	if checked then
		self.data.cdText = true
	else
		self.data.cdText = false
	end

	self:UpdateObjectCooldowns()
end

function Bar:GetShowCooldownText()
	return self.data.cdText
end

function Bar:SetCooldownColor1(option)
	if option then
		self.data.cdcolor1 = option
	else
		self.data.cdcolor1 = {1,0.82,0}
	end

	self:UpdateObjectCooldowns()
end

function Bar:GetCooldownColor1()
	return self.data.cdcolor1
end

function Bar:SetCooldownColor2(option)
	if option then
		self.data.cdcolor2 = option
	else
		self.data.cdcolor2 = {1,0.1,0.1}
	end

	self:UpdateObjectCooldowns()
end

function Bar:GetCooldownColor2()
	return self.data.cdcolor2
end

function Bar:SetShowCooldownAlpha(checked)
	if checked then
		self.data.cdAlpha = true --hardcoded for now, maybe one day add an option to configure this value
	else
		self.data.cdAlpha = false
	end

	self:UpdateObjectCooldowns()
end

function Bar:GetShowCooldownAlpha()
	return self.data.cdAlpha
end

function Bar:SetShowBorderStyle(checked)
	if checked then
		self.data.showBorderStyle = true
	else
		self.data.showBorderStyle = false
	end

	self:UpdateObjectIcons()
end

function Bar:GetShowBorderStyle()
	return self.data.showBorderStyle
end

function Bar:SetManaColor(option)
	if option then
		self.data.manacolor = option
	else
		self.data.manacolor = {0.5,0.5,1,1}
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function Bar:GetManaColor()
	return self.data.manacolor
end
