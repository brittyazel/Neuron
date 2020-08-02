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
--along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2018.

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class XPBTN: STATUSBTN @define class XPBTN inherits from class STATUSBTN
local XPBTN = setmetatable({}, { __index = Neuron.STATUSBTN })
Neuron.XPBTN = XPBTN

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

XPBTN.sbStrings = {
	[1] = { L["None"], function(self) return "" end },
	[2] = { L["Current/Next"], function(self) if self.current and self.next then return BreakUpLargeNumbers(self.current).." / "..BreakUpLargeNumbers(self.next) end end },
	[3] = { L["Rested Levels"], function(self) if self.rested then return string.format("%.2f", tostring(self.rested)).." "..L["Levels"] end end },
	[4] = { L["Percent"], function(self) if self.percent then return string.format("%.2f", tostring(self.percent)).."%" end end },
	[5] = { L["Bubbles"], function(self) if self.bubbles then return tostring(self.bubbles).." / 20 "..L["Bubbles"] end end},
	[6] = { L["Current Level/Rank"], function(self) if self.rank then return L["Level"].." "..tostring(self.rank) end end },
}


---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return XPBTN @ A newly created STATUSBTN object
function XPBTN.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.STATUSBTN.new(bar, buttonID, defaults, XPBTN, "XPBar", "XP Button")

	return newButton
end

function XPBTN:InitializeButton()
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

	if not Neuron.isWoWClassic then
		self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", "OnEvent")
		self:RegisterEvent("HONOR_XP_UPDATE", "OnEvent")
	end

	self.elements.SB:Show()
	self.typeString = L["XP Bar"]

	self:InitializeButtonSettings()
end

---TODO: right now we are using DB.statusbtn to assign settings ot the status buttons, but I think our indexes are bar specific
function XPBTN:UpdateData() --handles updating all the strings for the play XP watch bar
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

function XPBTN:OnEvent(event)
	self:UpdateData()

	if self:GetXPType() == "player_xp" and (event=="PLAYER_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event=="UPDATE_EXHAUSTION" or event =="changed_curXPType") then
		if self.rested ~= 0 then
			self.elements.SB:SetStatusBarColor(self.config.restColor[1], self.config.restColor[2], self.config.restColor[3], self.config.restColor[4])
		else
			self.elements.SB:SetStatusBarColor(self.config.norestColor[1], self.config.norestColor[2], self.config.norestColor[3], self.config.norestColor[4])
		end

	elseif self:GetXPType() == "azerite_xp" and (event =="AZERITE_ITEM_EXPERIENCE_CHANGED" or event =="PLAYER_ENTERING_WORLD" or event =="PLAYER_EQUIPMENT_CHANGED" or event =="changed_curXPType") then
		self.elements.SB:SetStatusBarColor(1, 1, 0); --set to yellow?

	elseif self:GetXPType() == "honor_points" and (event=="HONOR_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event =="changed_curXPType") then
		self.elements.SB:SetStatusBarColor(1, .4, .4);
	end

	self.elements.SB:SetMinMaxValues(0, 100) --these are for the bar itself, the progress it has from left to right
	self.elements.SB:SetValue((self.current/self.next)*100)

	self.elements.SB.cText:SetText(self:cFunc())
	self.elements.SB.lText:SetText(self:lFunc())
	self.elements.SB.rText:SetText(self:rFunc())
	self.elements.SB.mText:SetText(self:mFunc())
end

function XPBTN:InitializeDropDown() -- initialize the dropdown menu for chosing to watch either XP, azerite XP, or Honor Points
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

	--wow classic doesn't have Honor points nor Azerite, carefull
	if not Neuron.isWoWClassic then
		--add Heart of Azeroth option
		if(C_AzeriteItem.FindActiveAzeriteItem()) then --only show this button if they player has the Heart of Azeroth
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

function XPBTN:OnClick(mousebutton)
	if (mousebutton == "RightButton") then
		self:InitializeDropDown()
	end
end

-----------------------------------------------------
-------------------Sets and Gets---------------------
-----------------------------------------------------

function XPBTN:SetXPType(newXPType)
	self.config.curXPType = newXPType
	self:OnEvent("changed_curXPType")
end

function XPBTN:GetXPType()
	return self.config.curXPType
end