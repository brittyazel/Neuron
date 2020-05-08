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

---@class XPBTN: STATUSBTN @define class XPBTN inherits from class STATUSBTN
local XPBTN = setmetatable({}, { __index = Neuron.STATUSBTN })
Neuron.XPBTN = XPBTN

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

XPBTN.sbStrings = {
	[1] = { L["None"], function(self) return "" end },
	[2] = { L["Current/Next"], function(self) if (self.XPWatch) then return self.XPWatch.current end end },
	[3] = { L["Rested Levels"], function(self) if (self.XPWatch) then return self.XPWatch.rested end end },
	[4] = { L["Percent"], function(self) if (self.XPWatch) then return self.XPWatch.percent end end },
	[5] = { L["Bubbles"], function(self) if (self.XPWatch) then return self.XPWatch.bubbles end end },
	[6] = { L["Current Level/Rank"], function(self) if (self.XPWatch) then return self.XPWatch.rank end end },
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

function XPBTN:SetType()
	if InCombatLockdown() then
		return
	end

	self:SetAttribute("hasaction", true)

	self:RegisterForClicks("RightButtonUp")
	self:SetScript("OnClick", function(_, mousebutton) self:OnClick(mousebutton) end)
	self:SetScript("OnEnter", function() self:OnEnter() end)
	self:SetScript("OnLeave", function() self:OnLeave() end)
	self:SetHitRectInsets(0, 0, 0, 0)

	self:RegisterEvent("PLAYER_XP_UPDATE", "XPBar_OnEvent")
	self:RegisterEvent("UPDATE_EXHAUSTION", "XPBar_OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "XPBar_OnEvent")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "XPBar_OnEvent")

	if not Neuron.isWoWClassic then
		self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", "XPBar_OnEvent")
		self:RegisterEvent("HONOR_XP_UPDATE", "XPBar_OnEvent")
	end

	self.elements.SB:Show()
	self.typeString = L["XP Bar"]
	self:SetData(self.bar)
	self:XPBar_OnEvent("changed_curXPType") --we need to put this here to load the bar when first creating it
end

---TODO: right now we are using DB.statusbtn to assign settings ot the status buttons, but I think our indexes are bar specific
function XPBTN:xpstrings_Update() --handles updating all the strings for the play XP watch bar
	local currXP, nextXP, restedXP, percentXP, bubbles, rank

	--player xp option
	if (self.config.curXPType == "player_xp") then
		currXP, nextXP, restedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		local playerLevel = UnitLevel("player")

		if (playerLevel == MAX_PLAYER_LEVEL) then
			currXP = nextXP
		end

		percentXP = (currXP/nextXP)*100;
		bubbles = tostring(math.floor(currXP/(nextXP/20))).." / 20 "..L["Bubbles"]
		percentXP = string.format("%.2f", (percentXP)).."%"

		if (restedXP) then
			restedXP = string.format("%.2f", (tostring(restedXP/nextXP))).." "..L["Levels"]
		else
			restedXP = "0".." "..L["Levels"]
		end

		rank = L["Level"].." "..tostring(playerLevel)

		--heart of azeroth option
	elseif(self.config.curXPType == "azerite_xp") then
		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
		if(azeriteItemLocation) then
			currXP, nextXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
			restedXP = "0".." "..L["Levels"]
			percentXP = (currXP/nextXP)*100
			bubbles = tostring(math.floor(percentXP/5)).." / 20 "..L["Bubbles"]
			rank = L["Level"] .. " " .. tostring(C_AzeriteItem.GetPowerLevel(azeriteItemLocation))
		else
			currXP = 0;
			nextXP = 0;
			percentXP = 0;
			restedXP = "0".." "..L["Levels"]
			bubbles = tostring(0).." / 20 "..L["Bubbles"]
			rank = tostring(0).." "..L["Points"]
		end
		percentXP = string.format("%.2f", percentXP).."%"; --format

		--honor points option
	elseif(self.config.curXPType == "honor_points") then
		currXP = UnitHonor("player"); -- current value for level
		nextXP = UnitHonorMax("player"); -- max value for level
		restedXP = tostring(0).." "..L["Levels"]

		local level = UnitHonorLevel("player");
		percentXP = (currXP/nextXP)*100
		bubbles = tostring(math.floor(percentXP/5)).." / 20 "..L["Bubbles"];
		percentXP = string.format("%.2f", percentXP).."%"; --format
		rank = L["Level"] .. " " .. tostring(level)
	end

	if (not self.XPWatch) then --make sure we make the table for us to store our data so we aren't trying to index a non existant table
		self.XPWatch = {}
	end

	self.XPWatch.current = BreakUpLargeNumbers(currXP).." / "..BreakUpLargeNumbers(nextXP)
	self.XPWatch.rested = restedXP
	self.XPWatch.percent = percentXP
	self.XPWatch.bubbles = bubbles
	self.XPWatch.rank = rank

	local isRested
	if(restedXP ~= "0") then
		isRested = true
	else
		isRested = false
	end

	return currXP, nextXP, isRested
end

function XPBTN:XPBar_OnEvent(event)
	local currXP, nextXP, isRested
	local hasChanged = false;

	if(self.config.curXPType == "player_xp" and (event=="PLAYER_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event=="UPDATE_EXHAUSTION" or event =="changed_curXPType")) then
		currXP, nextXP, isRested = self:xpstrings_Update()
		if (isRested) then
			self.elements.SB:SetStatusBarColor(self.config.restColor[1], self.config.restColor[2], self.config.restColor[3], self.config.restColor[4])
		else
			self.elements.SB:SetStatusBarColor(self.config.norestColor[1], self.config.norestColor[2], self.config.norestColor[3], self.config.norestColor[4])
		end
		hasChanged = true;
	end

	if(self.config.curXPType == "azerite_xp" and (event =="AZERITE_ITEM_EXPERIENCE_CHANGED" or event =="PLAYER_ENTERING_WORLD" or event =="PLAYER_EQUIPMENT_CHANGED" or event =="changed_curXPType"))then
		currXP, nextXP = self:xpstrings_Update()
		self.elements.SB:SetStatusBarColor(1, 1, 0); --set to yellow?
		hasChanged = true;
	end

	if(self.config.curXPType == "honor_points" and (event=="HONOR_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event =="changed_curXPType")) then
		currXP, nextXP = self:xpstrings_Update()
		self.elements.SB:SetStatusBarColor(1, .4, .4);
		hasChanged = true;
	end

	if (hasChanged == true) then
		self.elements.SB:SetMinMaxValues(0, 100) --these are for the bar itself, the progress it has from left to right
		self.elements.SB:SetValue((currXP/nextXP)*100)

		self.elements.SB.cText:SetText(self:cFunc())
		self.elements.SB.lText:SetText(self:lFunc())
		self.elements.SB.rText:SetText(self:rFunc())
		self.elements.SB.mText:SetText(self:mFunc())
	end
end

function XPBTN:switchCurXPType(newXPType)
	self.config.curXPType = newXPType
	self:XPBar_OnEvent("changed_curXPType")
end

function XPBTN:xpDropDown_Initialize() -- initialize the dropdown menu for chosing to watch either XP, azerite XP, or Honor Points
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
		func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end,
		checked = self.config.curXPType == "player_xp",
	})

	--wow classic doesn't have Honor points nor Azerite, carefull
	if not Neuron.isWoWClassic then
		--add Heart of Azeroth option
		if(C_AzeriteItem.FindActiveAzeriteItem()) then --only show this button if they player has the Heart of Azeroth
			table.insert(menu, {
				arg1 = self,
				arg2 = "azerite_xp",
				text = L["Track Azerite Power"],
				func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end,
				checked = self.config.curXPType == "azerite_xp",
			})
		end

		--add PvP Honor option
		table.insert(menu, {
			arg1 = self,
			arg2 = "honor_points",
			text = L["Track Honor Points"],
			func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end,
			checked = self.config.curXPType == "honor_points",
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
		self:xpDropDown_Initialize()
	end
end