-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2023 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class ExpButton: StatusButton @define class ExpButton inherits from class StatusButton
local ExpButton = setmetatable({}, { __index = Neuron.StatusButton })
Neuron.ExpButton = ExpButton

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

ExpButton.sbStrings = {
	[1] = { L["None"], function(self) return "" end },
	[2] = { L["Current/Next"], function(self) if self.current and self.next then return BreakUpLargeNumbers(self.current).." / "..BreakUpLargeNumbers(self.next) end end },
	[3] = { L["Rested Levels"], function(self) if self.rested then return string.format("%.2f", tostring(self.rested)).." "..L["Levels"] end end },
	[4] = { L["Percent"], function(self) if self.percent then return string.format("%.2f", tostring(self.percent)).."%" end end },
	[5] = { L["Bubbles"], function(self) if self.bubbles then return tostring(self.bubbles).." / 20 "..L["Bubbles"] end end},
	[6] = { L["Current Level/Rank"], function(self) if self.rank then return L["Level"].." "..tostring(self.rank) end end },
}


---Constructor: Create a new Neuron Button object (this is the base object for all Neuron button types)
---@param bar Bar @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return ExpButton @ A newly created StatusButton object
function ExpButton.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.StatusButton.new(bar, buttonID, defaults, ExpButton, "XPBar", "XP Button")

	return newButton
end

function ExpButton:InitializeButton()
	self:SetAttribute("hasaction", true)

	self:RegisterForClicks("RightButtonUp")
	self:SetScript("OnClick", function(_, mousebutton) self:OnClick(mousebutton) end)
	self:SetScript("OnEnter", function() self:OnEnter() end)
	self:SetScript("OnLeave", function() self:OnLeave() end)
	self:SetHitRectInsets(0, 0, 0, 0)

	self:RegisterEvent("PLAYER_XP_UPDATE", "OnEvent")
	self:RegisterEvent("UPDATE_EXHAUSTION", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "OnEvent")

	if Neuron.isWoWRetail then
		self:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED", "OnEvent")
		self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", "OnEvent")
		self:RegisterEvent("HONOR_XP_UPDATE", "OnEvent")
	end

	self.StatusBar:Show()
	self.typeString = L["XP Bar"]

	self:InitializeButtonSettings()
end

---TODO: right now we are using DB.statusbtn to assign settings ot the status buttons, but I think our indexes are bar specific
function ExpButton:UpdateData() --handles updating all the strings for the play XP watch bar
	--player xp option
	if self:GetXPType() == "player_xp" then
		self.current, self.next, self.rested = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		self.rank = UnitLevel("player")

		--at max level we want to show the bar as full, so just max out the current XP
		if self.rank == MAX_PLAYER_LEVEL then
			self.current = self.next
		end

		self.percent = (self.current/self.next)*100
		self.bubbles = math.floor(self.percent/5)

		if self.rested then
			self.rested = self.rested/self.next
		else
			self.rested = 0
		end

	--covenant renown
	elseif self:GetXPType() == "covenant_renown" then
		if C_Covenants.GetActiveCovenantID() ~= 0 then
			local covenantLevel = C_CovenantSanctumUI.GetRenownLevel(C_Covenants.GetActiveCovenantID())
			local covenantName = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID()).name
			self.rank = covenantName..": "..L["Level"].." "..covenantLevel
			self.rested = 0
			self.percent = 100
			self.bubbles = 20
			self.current = 100
			self.next = 100
		else
			self.current = 0
			self.next = 0
			self.percent = 0
			self.rested = 0
			self.bubbles = 0
			self.rank = 0
		end

	--heart of azeroth option
	elseif self:GetXPType() == "azerite_xp" then
		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
		if azeriteItemLocation then
			self.current, self.next = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
			self.rested = 0
			self.percent = (self.current/self.next)*100
			self.bubbles = math.floor(self.percent/5)
			self.rank = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
		else
			self.current = 0
			self.next = 0
			self.percent = 0
			self.rested = 0
			self.bubbles = 0
			self.rank = 0
		end

	--honor points option
	elseif self:GetXPType() == "honor_points" then
		self.current = UnitHonor("player"); -- current value for level
		self.next = UnitHonorMax("player"); -- max value for level
		self.rested = 0

		self.rank = UnitHonorLevel("player");
		self.percent = (self.current/self.next)*100
		self.bubbles = math.floor(self.percent/5)
	end
end

function ExpButton:OnEvent(event)
	self:UpdateData()

	if self:GetXPType() == "player_xp" and (event=="PLAYER_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event=="UPDATE_EXHAUSTION" or event =="changed_curXPType") then
		if self.rested ~= 0 or UnitLevel("player") == MAX_PLAYER_LEVEL then
			self.StatusBar:SetStatusBarColor(0.0, 0.39, 0.88, 1.0) --blue color
		else
			self.StatusBar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0) --deep purple color
		end

	elseif self:GetXPType() == "covenant_renown" and (event == "COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED" or event =="PLAYER_ENTERING_WORLD" or event =="changed_curXPType") then
		local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID())
		local covenantColor = COVENANT_COLORS[covenantData.textureKit]
		self.StatusBar:SetStatusBarColor(covenantColor:GetRGB())

	elseif self:GetXPType() == "azerite_xp" and (event =="AZERITE_ITEM_EXPERIENCE_CHANGED" or event =="PLAYER_ENTERING_WORLD" or event =="PLAYER_EQUIPMENT_CHANGED" or event =="changed_curXPType") then
		self.StatusBar:SetStatusBarColor(ARTIFACT_BAR_COLOR:GetRGB()) --set to pale yellow

	elseif self:GetXPType() == "honor_points" and (event=="HONOR_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event =="changed_curXPType") then
		self.StatusBar:SetStatusBarColor(1.0, 0.24, 0) --set to red
	end

	self.StatusBar:SetMinMaxValues(0, 100) --these are for the bar itself, the progress it has from left to right
	self.StatusBar:SetValue((self.current/self.next)*100)

	self.StatusBar.CenterText:SetText(self:cFunc())
	self.StatusBar.LeftText:SetText(self:lFunc())
	self.StatusBar.RightText:SetText(self:rFunc())
	self.StatusBar.MouseoverText:SetText(self:mFunc())
end

function ExpButton:InitializeDropDown() -- initialize the dropdown menu for chosing to watch either XP, azerite XP, or Honor Points
	--this is the frame that will hold our dropdown menu
	local menuFrame
	if not NeuronXPDropdownMenu then --try to avoid re-creating this over again if we don't have to
		menuFrame = CreateFrame("Frame", "NeuronXPDropdownMenu", self, "UIDropDownMenuTemplate")
	else
		menuFrame = NeuronXPDropdownMenu
	end
	menuFrame:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0)

	local menu = {}

	-- Menu Title
	table.insert(menu, {text = L["Select an Option"], isTitle = true, notCheckable=true, justifyH = "CENTER",})

	--add Player XP option
	table.insert(menu, {
		arg1 = self,
		arg2 = "player_xp",
		text = L["Track Character XP"],
		func = function(dropdown, self, newXPType) self:SetXPType(newXPType) end,
		checked = self:GetXPType() == "player_xp",
	})

	--wow classic doesn't have Honor points nor Azerite, careful
	if Neuron.isWoWRetail then

		--add Renown tracking for Covenants
		if C_Covenants.GetActiveCovenantID() ~= 0 then
			table.insert(menu, {
				arg1 = self,
				arg2 = "covenant_renown",
				text = L["Track Covenant Renown"],
				func = function(dropdown, self, newXPType) self:SetXPType(newXPType) end,
				checked = self:GetXPType() == "covenant_renown",
			})
		end

		--add Heart of Azeroth option
		local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem()
		if azeriteItem and azeriteItem:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItem) then --only show this button if they player has the Heart of Azeroth
			table.insert(menu, {
				arg1 = self,
				arg2 = "azerite_xp",
				text = L["Track Azerite Power"],
				func = function(dropdown, self, newXPType) self:SetXPType(newXPType) end,
				checked = self:GetXPType() == "azerite_xp",
			})
		end

		--add PvP Honor option
		table.insert(menu, {
			arg1 = self,
			arg2 = "honor_points",
			text = L["Track Honor Points"],
			func = function(dropdown, self, newXPType) self:SetXPType(newXPType) end,
			checked = self:GetXPType() == "honor_points",
		})
	end

	--this is a spacer between everything else and close
	table.insert(menu,	{
		arg1=nil,
		arg2=nil,
		text=" ",
		disabled=true,
		func=function() end,
		value=nil,
		checked=nil,
		justifyH = "CENTER",
		notCheckable=true
	})

	--close button in case you don't want to change
	table.insert(menu, {
		arg1=self,
		arg2=nil,
		text=L["Close"],
		func= function() --self is arg1
			menuFrame:Hide()
		end,
		notCheckable = true,
		justifyH = "CENTER",
	})

	--build the EasyMenu with the newly created menu table "menu"
	EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU", 1)
end

function ExpButton:OnClick(mousebutton)
	if (mousebutton == "RightButton") then
		self:InitializeDropDown()
	end
end

-----------------------------------------------------
-------------------Sets and Gets---------------------
-----------------------------------------------------

function ExpButton:SetXPType(newXPType)
	self.config.curXPType = newXPType
	self:OnEvent("changed_curXPType")
end

function ExpButton:GetXPType()
	return self.config.curXPType
end
