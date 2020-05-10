--Neuron, a World of Warcraft® user interface addon.

--This file is part of Neuron.
--
--Neuron is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--Neuron is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with this add-on.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2020.

---@class BAR : CheckButton @This is our bar object that serves as the container for all of our button objects
local BAR = setmetatable({}, {__index = CreateFrame("CheckButton")}) --this is the metatable for our button object
Neuron.BAR = BAR

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

LibStub("AceTimer-3.0"):Embed(BAR)
LibStub("AceEvent-3.0"):Embed(BAR)

local alphaDir, alphaTimer = 0, 0

local statetable = {}

local TRASHCAN = CreateFrame("Frame", nil, UIParent)
TRASHCAN:Hide()

----------------------------------------------------

---Constructor: Create a new Neuron BAR object
---@param class string @The class type of the new bar
---@param barID number @The ID of the new bar object
---@return BAR @ A newly created BUTTON object
function BAR.new(class, barID)
	local data = Neuron.registeredBarData[class]

	local newBar

	--this is the creation of our bar object frame
	if _G["Neuron"..data.barType..barID] then --check to see if our bar already exists on the global namespace
		newBar = CreateFrame("CheckButton", "Neuron"..data.barType..random(1000,10000000), UIParent, "NeuronBarTemplate") --in the case of trying to create a bar on a frame that already exists, create a random frame ID for this session only
		setmetatable(newBar, {__index = BAR})
	else
		newBar = CreateFrame("CheckButton", "Neuron"..data.barType..barID, UIParent, "NeuronBarTemplate")
		setmetatable(newBar, {__index = BAR})
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
	newBar.text:Hide()
	newBar.message:Hide()
	newBar.messagebg:Hide()

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

function BAR:InitializeBar()
	if not Neuron.isWoWClassic then
		if self.class == "ActionBar" then
			self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
			self:RegisterEvent("ACTIONBAR_SHOWGRID", "ACTIONBAR_SHOWHIDEGRID", true)
			self:RegisterEvent("ACTIONBAR_HIDEGRID", "ACTIONBAR_SHOWHIDEGRID")
		end
	end
end

-----------------------------------
--------- Event Handlers ----------
-----------------------------------

function BAR:ACTIVE_TALENT_GROUP_CHANGED()
	if self.handler:GetAttribute("assertstate") then
		self.handler:SetAttribute("state-"..self.handler:GetAttribute("assertstate"), self.handler:GetAttribute("activestate") or "homestate")
	end

	for _,button in pairs(self.buttons) do
		button:UpdateButtonSpec()
	end
end

function BAR:ACTIONBAR_SHOWHIDEGRID(show)
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

---This function is used for creating brand new bars, and it is really just a wrapper for the BAR constructor with a couple of assumptions and checks
function BAR:CreateNewBar(class)

	if not class and Neuron.registeredBarData[class] then --if the class isn't registered, go ahead and bail out.
		Neuron.PrintBarTypes()
		return
	end

	local barID = #Neuron.registeredBarData[class].barDB + 1 --increment 1 higher than the current number of bars in this class of bar's database

	local newBar = BAR.new(class, barID) --create new bar

	newBar.objTemplate.new(newBar, 1) --add at least 1 button to a new bar
	BAR.ChangeSelectedBar(newBar)
	newBar:Load() --load the bar

	newBar:Show() --Show the transparent blue overlay that we show in the edit mode
end
Neuron.CreateNewBar = BAR.CreateNewBar --this is so the slash function works correctly


function BAR:DeleteBar()
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

function BAR:AddObjectToBar() --called from NeuronGUI
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

function BAR:RemoveObjectFromBar() --called from NeuronGUI

	local id = #self.buttons --always the last button

	local object = self.buttons[id]

	if object then

		object:ClearAllPoints()

		table.remove(self.data.buttons, id) --this is somewhat redundant if deleting a bar, but it doesn't hurt and is important for individual button deletions
		table.remove(self.buttons, id)

		if object.binder then
			object.binder:KeybindOverlay_ClearBindings()
		end

		object:SetParent(TRASHCAN)
	end

	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:UpdateBarStatus()
end


function BAR:Load()
	self:SetPosition()
	self:LoadObjects()
	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:EnableKeyboard(false)
	self:UpdateBarStatus()
end

function BAR.ChangeSelectedBar(newBar)
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
		newBar.text:Show()
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
			v.text:Hide()
			v.message:Hide()
			v.messagebg:Hide()
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

function BAR.IsMouseOverSelfOrWatchFrame(frame)
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
function BAR:AutoHideUpdate()
	if self:GetAutoHide() and self.handler~=nil then
		if not Neuron.buttonEditMode and not Neuron.barEditMode and not Neuron.bindingMode then
			if self:IsShown() then
				self.handler:SetAlpha(1)
			else
				if BAR.IsMouseOverSelfOrWatchFrame(self) then
					if self.handler:GetAlpha() < self:GetBarAlpha() then
						if self.handler:GetAlpha()+self:GetAlphaUpSpeed() <= 1 then
							self.handler:SetAlpha(self.handler:GetAlpha()+self:GetAlphaUpSpeed())
						else
							self.handler:SetAlpha(1)
						end
					end
				end
				if not BAR.IsMouseOverSelfOrWatchFrame(self) then
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

function BAR:AlphaUpUpdate()
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
		if InCombatLockdown() and BAR.IsMouseOverSelfOrWatchFrame(self)  then
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
		if BAR.IsMouseOverSelfOrWatchFrame(self) then
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

function BAR:UpdateAutoHideTimer()
	if self:GetAutoHide() then
		if self:TimeLeft(self.autoHideTimer) == 0 then --safety check to make sure we don't re-set an already active timer
			self.autoHideTimer = self:ScheduleRepeatingTimer("AutoHideUpdate", 0.05)
		end
	else
		self:CancelTimer(self.autoHideTimer)
	end
end

function BAR:UpdateAlphaUpTimer()
	if self:GetAlphaUp() ~= "off" then
		if self:TimeLeft(self.alphaUpTimer) == 0 then --safety check to make sure we don't re-set an already active timer
			self.alphaUpTimer = self:ScheduleRepeatingTimer("AlphaUpUpdate", 0.05)
		end
	else
		self:CancelTimer(self.alphaUpTimer)
	end
end


function BAR:AddVisibilityDriver(handler, state, conditions)
	if Neuron.MANAGED_BAR_STATES[state] then
		RegisterStateDriver(handler, state, conditions);

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


function BAR:ClearVisibilityDriver(handler, state)
	UnregisterStateDriver(handler, state)
	handler:SetAttribute("activestates", handler:GetAttribute("activestates"):gsub(state.."%d+;", ""))
	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")
	self.vis[state].registered = false
end


function BAR:UpdateBarVisibility(driver)
	for state, values in pairs(Neuron.MANAGED_BAR_STATES) do
		if self.data.hidestates:find(":"..state) then
			if not self.vis[state] or not self.vis[state].registered then
				if not self.vis[state] then
					self.vis[state] = {}
				end
				if state == "stance" and self.data.hidestates:find(":stance8") then
					self:AddVisibilityDriver(driver,state, "[stance:2/3,stealth] stance8; "..values.states)
				else
					self:AddVisibilityDriver(driver, state, values.states)
				end
			end
		elseif self.vis[state] and self.vis[state].registered then
			self:ClearVisibilityDriver(driver, state)
		end
	end
end

function BAR:BuildStateMap(remapState)
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


function BAR:AddStates(handler, state, conditions)
	if state then
		if Neuron.MANAGED_BAR_STATES[state] then
			RegisterStateDriver(handler, state, conditions);
		end
		if Neuron.MANAGED_BAR_STATES[state].homestate then
			handler:SetAttribute("handler-homestate", Neuron.MANAGED_BAR_STATES[state].homestate)
		end
		self[state].registered = true
	end
end

function BAR:ClearStates(handler, state)
	if state ~= "homestate" then
		if Neuron.MANAGED_BAR_STATES[state].homestate then
			handler:SetAttribute("handler-homestate", nil)
		end
		handler:SetAttribute("state-"..state, nil)
		UnregisterStateDriver(handler, state)
		self[state].registered = false
	end
	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")
end


function BAR:UpdateStates(handler)
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


function BAR:CreateDriver()
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


function BAR:CreateHandler()
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


function BAR:CreateWatcher()
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
	RegisterAttributeDriver(watcher, "state-petbattle", "[petbattle] hide; [nopetbattle] show");
end

function BAR:UpdateBarStatus(show)
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

	self.text:SetText(self:GetBarName())
	self.handler:SetAlpha(self:GetBarAlpha())
end

-------------------------------------------------------


function BAR:GetPosition(oFrame)
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


function BAR:SetPosition()
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

		if self.message then
			self.message:SetText(point:lower().."     x: "..format("%0.2f", x).."     y: "..format("%0.2f", y))
			self.messagebg:SetWidth(self.message:GetWidth()*1.05)
			self.messagebg:SetHeight(self.message:GetHeight()*1.1)
		end
	end
end

--Fakes a state change for a given bar, calls up the counterpart function in NeuronButton
function BAR:FakeStateChange(state)
	self.handler:SetAttribute("fauxstate", state)

	for i, object in ipairs(self.buttons) do
		object:FakeStateChange(state)
	end

end

--loads all the object stored for a given bar
function BAR:LoadObjects()
	local spec

	if self:GetMultiSpec() then
		spec = GetSpecialization()
	else
		spec = 1
	end

	for i, object in ipairs(self.buttons) do
		--all of these objects need to stay as "object:****" because which InitializeButtonSettings/LoadDataFromDatabase/etc is bar dependent. Symlinks are made to the asociated bar objects to these class functions
		object:LoadDataFromDatabase(spec, self.handler:GetAttribute("activestate"))
		object:InitializeButton()
		object:UpdateVisibility()
	end
end


function BAR:SetObjectLoc()
	local width, height, num, origCol = 0, 0, 0, self:GetColumns()
	local x, y, lastObj, placed
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


function BAR:SetPerimeter()
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


function BAR:SetDefaults(defaults)
	for k,v in pairs(defaults) do
		if k ~= "buttons" then --ignore this value because it's just used to tell how many buttons should be placed on a bar by default on the first load
			self.data[k] = v
		end
	end
end


function BAR:SetRemap_Paged()
	self.data.remap = ""

	for i=1,6 do
		self.data.remap = self.data.remap..i..":"..i..";"
	end

	self.data.remap = gsub(self.data.remap, ";$", "")
end


function BAR:SetRemap_Stance()
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


function BAR:SetSize()
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

function BAR:OnClick(...)
	local click, down = select(1, ...), select(2, ...)

	if not down then
		BAR.ChangeSelectedBar(self)
	end

	if IsShiftKeyDown() and not down then

		if self.microAdjust then
			self.microAdjust = false
			self:EnableKeyboard(false)
			self.message:Hide()
			self.messagebg:Hide()
		else
			self.microAdjust = 1
			self:EnableKeyboard(true)
			self.message:Show()
			self.message:SetText(self.data.point:lower().."     x: "..format("%0.2f", self:GetXAxis()).."     y: "..format("%0.2f", self:GetYAxis()))
			self.messagebg:Show()
			self.messagebg:SetWidth(self.message:GetWidth()*1.05)
			self.messagebg:SetHeight(self.message:GetHeight()*1.1)
		end

	elseif click == "MiddleButton" then
		if GetMouseFocus() ~= Neuron.currentBar then
			BAR.ChangeSelectedBar(self)
		end

	elseif click == "RightButton" and not down then
		self.mousewheelfunc = nil
		if not NeuronEditor then
			Neuron.NeuronGUI:CreateEditor()
		end
	end

	if NeuronEditor then
		Neuron.NeuronGUI:RefreshEditor()
	end
end


function BAR:OnEnter(...)
	if self:GetBarConceal() then
		self:SetBackdropColor(1,0,0,0.6)
	else
		self:SetBackdropColor(0,0,1,0.5)
	end

	self.text:Show()
end


function BAR:OnLeave(...)
	if self ~= Neuron.currentBar then
		if self:GetBarConceal() then
			self:SetBackdropColor(1,0,0,0.4)
		else
			self:SetBackdropColor(0,0,0,0.4)
		end
	end

	if self ~= Neuron.currentBar then
		self.text:Hide()
	end
end


function BAR:OnDragStart(...)
	BAR.ChangeSelectedBar(self)

	self:SetFrameStrata(Neuron.STRATAS[self:GetStrata()])
	self:EnableKeyboard(false)

	self.data.snapToPoint = false
	self.data.snapToFrame = false

	self:StartMoving()
end


function BAR:OnDragStop(...)

	local point
	self:StopMovingOrSizing()

	for _,v in pairs(Neuron.bars) do
		if not point and self:GetSnapTo() and v:GetSnapTo() and self ~= v then
			point = self:Stick(v, Neuron.SNAPTO_TOLLERANCE, self:GetHorizontalPad(), self:GetVerticalPad())

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

function BAR:OnKeyDown(key)
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


function BAR:OnKeyUp(key)
	if self.microAdjust and not key:find("SHIFT") then
		self.microAdjust = 1
		self.keydown = nil
	end
end


function BAR:OnShow()
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


function BAR:OnHide()
	self.handler:SetAttribute("editmode", nil)

	if self.handler:GetAttribute("vishide") then
		self.handler:Hide()
	end

	self:UpdateObjectVisibility()
	self:EnableKeyboard(false)
end


function BAR:Pulse(elapsed)
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

function BAR:UpdateButtonSettings()
	for _, object in pairs(self.buttons) do
		if object then
			object:InitializeButtonSettings()
		end
	end
end


function BAR:UpdateObjectVisibility(show)
	for _, object in pairs(self.buttons) do
		if object then
			object:UpdateVisibility(show)
		end
	end
end

function BAR:UpdateObjectUsability()
	for _, object in pairs(self.buttons) do
		if object then
			object:UpdateUsable()
		end
	end
end

function BAR:UpdateObjectIcons()
	for _, object in pairs(self.buttons) do
		if object then
			object:UpdateIcon()
		end
	end
end

function BAR:UpdateObjectCooldowns()
	for _, object in pairs(self.buttons) do
		if object then
			object:CancelCooldownTimer(true) --this will reset the text/alpha on the button
			object:UpdateCooldown()
		end
	end
end

function BAR:UpdateObjectCooldowns()
	for _, object in pairs(self.buttons) do
		if object then
			object:CancelCooldownTimer(true) --this will reset the text/alpha on the button
			object:UpdateCooldown()
		end
	end
end

function BAR:UpdateObjectStatus()
	for _, object in pairs(self.buttons) do
		if object then
			object:UpdateStatus()
		end
	end
end

-----------------------------------------------------
-------------------Sets and Gets---------------------
-----------------------------------------------------

function BAR:SetBarName(name)
	if name and name ~= "" then
		self.data.name = name
	end
	self:UpdateBarStatus()
end

function BAR:GetBarName()
	return self.data.name
end

function BAR:GetNumObjects()
	return #self.buttons
end

--TODO: Rewrite this and simplify it
function BAR:SetState(msg, gui, checked)
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
			if checked then
				self.data[state] = true
			else
				self.data[state] = false
			end
		else
			local toggle = self.data[state]

			if toggle then
				self.data[state] = false
			else
				self.data[state] = true
			end
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
function BAR:SetVisibility(msg)
	wipe(statetable)
	local toggle, index, num = (" "):split(msg)
	toggle = toggle:lower()

	if toggle and Neuron.MANAGED_BAR_STATES[toggle] then
		if index then
			num = index:match("%d+")

			if num then
				local hidestate = Neuron.MANAGED_BAR_STATES[toggle].modifier..num
				if Neuron.STATES[hidestate] or (toggle == "custom" and self.data.customNames) then
					if self.data.hidestates:find(hidestate) then
						self.data.hidestates = self.data.hidestates:gsub(hidestate..":", "")
					else
						self.data.hidestates = self.data.hidestates..hidestate..":"
					end
				else
					Neuron:Print(L["Invalid index"]); return
				end

			elseif index == L["Show"] then
				local hidestate = Neuron.MANAGED_BAR_STATES[toggle].modifier.."%d+"
				self.data.hidestates = self.data.hidestates:gsub(hidestate..":", "")
			elseif index == L["Hide"] then
				local hidestate = Neuron.MANAGED_BAR_STATES[toggle].modifier

				for state in pairs(Neuron.STATES) do
					if state:find("^"..hidestate) and not self.data.hidestates:find(state) then
						self.data.hidestates = self.data.hidestates..state..":"
					end
				end
			end
		end


		local hidestates = self.data.hidestates
		local showhide

		local highindex = 0

		for state,desc in pairs(Neuron.STATES) do
			index = state:match("%d+$")

			if index then
				index = tonumber(index)

				if index and state:find("^"..toggle) then
					if hidestates:find(state) then
						statetable[index] = desc..":".."Hide:"..state
					else
						statetable[index] = desc..":".."Show:"..state
					end

					if index > highindex then
						highindex = index
					end
				end
			end
		end

		for i=1,highindex do
			if not statetable[i] then
				statetable[i] = "ignore"
			end
		end

		if #statetable > 0 then

			for k,v in ipairs(statetable) do
				if v ~= "ignore" then
					desc, showhide = (":"):split(v)
				end
			end
		end


		self.vischanged = true
		self:UpdateBarStatus()
	else
		Neuron:PrintStateList()
	end

end


function BAR:SetAutoHide(checked)
	if checked then
		self.data.autoHide = true
	else
		self.data.autoHide = false
	end

	self:UpdateAutoHideTimer()
	self:UpdateBarStatus()
end

function BAR:GetAutoHide()
	return self.data.autoHide
end

function BAR:SetShowGrid(checked)
	if checked then
		self.data.showGrid = true
	else
		self.data.showGrid = false
	end

	self:UpdateObjectVisibility()
	self:UpdateBarStatus()
end

function BAR:GetShowGrid()
	return self.data.showGrid
end

function BAR:SetSpellGlow(option)
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

function BAR:GetSpellGlow()
	return self.data.spellGlow
end


function BAR:SetSnapTo(checked)
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

function BAR:GetSnapTo()
	return self.data.snapTo
end


function BAR:SetClickMode(mode)
	if mode then
		self.data.clickMode = mode
	else
		self.data.clickMode = "UpClick"
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function BAR:GetClickMode()
	return self.data.clickMode
end


function BAR:SetMultiSpec(checked)
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

function BAR:GetMultiSpec()
	return self.data.multiSpec
end


function BAR:SetBarConceal(checked)
	if checked then
		self.data.conceal = true
		self:SetBackdropColor(1,0,0,0.4)
	else
		self.data.conceal = false
		self:SetBackdropColor(0,0,0,0.4)
	end

	self:UpdateBarStatus()
end

function BAR:GetBarConceal()
	return self.data.conceal
end

function BAR:SetBarLock(option)
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

function BAR:GetBarLock()
	return self.data.barLock
end


function BAR:SetTooltipOption(option)
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

function BAR:GetTooltipOption()
	return self.data.tooltips
end

function BAR:SetTooltipCombat(checked)
	if checked then
		self.data.tooltipsCombat = true
	else
		self.data.tooltipsCombat = false
	end

	self:UpdateBarStatus()
end

function BAR:GetTooltipCombat()
	return self.data.tooltipsCombat
end

function BAR:SetBarShape(option)
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

function BAR:GetBarShape()
	return self.data.shape
end

function BAR:SetColumns(option)
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

function BAR:GetColumns()
	return self.data.columns
end

function BAR:SetArcStart(option)
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

function BAR:GetArcStart()
	return self.data.arcStart
end

function BAR:SetArcLength(option)
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

function BAR:GetArcLength()
	return self.data.arcLength
end



function BAR:SetHorizontalPad(option)
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

function BAR:GetHorizontalPad()
	return self.data.padH
end

function BAR:SetVerticalPad(option)
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

function BAR:GetVerticalPad()
	return self.data.padV
end


function BAR:SetBarScale(option)
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

function BAR:GetBarScale()
	return self.data.scale
end

function BAR:SetStrata(option)
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

function BAR:GetStrata()
	return self.data.strata
end

function BAR:SetBarAlpha(option)
	if option then
		self.data.alpha = option
	else
		self.data.alpha = 1
	end

	self.handler:SetAlpha(self:GetBarAlpha()) --not sure if this should be here
	self:UpdateBarStatus()
end

function BAR:GetBarAlpha()
	return self.data.alpha
end

function BAR:SetAlphaUp(option)
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

function BAR:GetAlphaUp()
	--TODO: Get rid of :lower() in the future
	return self.data.alphaUp:lower() --shouldn't have to set lower but older databases might have some capital letters
end

function BAR:SetAlphaUpSpeed(option)
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

function BAR:GetAlphaUpSpeed()
	return self.data.fadeSpeed
end

function BAR:SetXAxis(option)
	if option then
		self.data.x = option
	else
		self.data.x = 0
	end

	self:SetPosition()
	self:UpdateBarStatus()
end

function BAR:GetXAxis()
	return self.data.x
end

function BAR:SetYAxis(option)
	if option then
		self.data.y = option
	else
		self.data.y = 190
	end

	self:SetPosition()
	self:UpdateBarStatus()
end

function BAR:GetYAxis()
	return self.data.y
end

function BAR:SetShowBindText(checked)
	if checked then
		self.data.bindText = true
	else
		self.data.bindText = false
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function BAR:GetShowBindText()
	return self.data.bindText
end

function BAR:SetBindColor(option)
	if option then
		self.data.bindColor = option
	else
		self.data.bindColor = {1,1,1,1}
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function BAR:GetBindColor()
	return self.data.bindColor
end

function BAR:SetShowButtonText(checked)
	if checked then
		self.data.buttonText = true
	else
		self.data.buttonText = false
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function BAR:GetShowButtonText()
	return self.data.buttonText
end

function BAR:SetMacroColor(option)
	if option then
		self.data.macroColor = option
	else
		self.data.macroColor = {1,1,1,1}
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function BAR:GetMacroColor()
	return self.data.macroColor
end

function BAR:SetShowCountText(checked)
	if checked then
		self.data.countText = true
	else
		self.data.countText = false
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function BAR:GetShowCountText()
	return self.data.countText
end

function BAR:SetCountColor(option)
	if option then
		self.data.countColor = option
	else
		self.data.countColor = {1,1,1,1}
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function BAR:GetCountColor()
	return self.data.countColor
end

function BAR:SetShowRangeIndicator(checked)
	if checked then
		self.data.rangeInd = true
	else
		self.data.rangeInd = false
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function BAR:GetShowRangeIndicator()
	return self.data.rangeInd
end

function BAR:SetRangeColor(option)
	if option then
		self.data.rangecolor = option
	else
		self.data.rangecolor = {0.7,0.15,0.15,1}
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function BAR:GetRangeColor()
	return self.data.rangecolor
end

function BAR:SetShowCooldownText(checked)
	if checked then
		self.data.cdText = true
	else
		self.data.cdText = false
	end

	self:UpdateObjectCooldowns()
end

function BAR:GetShowCooldownText()
	return self.data.cdText
end

function BAR:SetCooldownColor1(option)
	if option then
		self.data.cdcolor1 = option
	else
		self.data.cdcolor1 = {1,0.82,0,1}
	end

	self:UpdateObjectCooldowns()
end

function BAR:GetCooldownColor1()
	return self.data.cdcolor1
end

function BAR:SetCooldownColor2(option)
	if option then
		self.data.cdcolor2 = option
	else
		self.data.cdcolor2 = {1,0.1,0.1,1}
	end

	self:UpdateObjectCooldowns()
end

function BAR:GetCooldownColor2()
	return self.data.cdcolor2
end

function BAR:SetShowCooldownAlpha(checked)
	if checked then
		self.data.cdAlpha = true --hardcoded for now, maybe one day add an option to configure this value
	else
		self.data.cdAlpha = false
	end

	self:UpdateObjectCooldowns()
end

function BAR:GetShowCooldownAlpha()
	return self.data.cdAlpha
end

function BAR:SetShowBorderStyle(checked)
	if checked then
		self.data.showBorderStyle = true
	else
		self.data.showBorderStyle = false
	end

	self:UpdateObjectIcons()
end

function BAR:GetShowBorderStyle()
	return self.data.showBorderStyle
end

function BAR:SetManaColor(option)
	if option then
		self.data.manacolor = option
	else
		self.data.manacolor = {0.5,0.5,1,1}
	end

	self:UpdateButtonSettings()
	self:UpdateBarStatus()
end

function BAR:GetManaColor()
	return self.data.manacolor
end