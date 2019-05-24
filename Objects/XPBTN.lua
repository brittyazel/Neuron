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
	[1] = { L["None"], function(sb) return "" end },
	[2] = { L["Current/Next"], function(sb) if (sb.XPWatch) then return sb.XPWatch.current end end },
	[3] = { L["Rested Levels"], function(sb) if (sb.XPWatch) then return sb.XPWatch.rested end end },
	[4] = { L["Percent"], function(sb) if (sb.XPWatch) then return sb.XPWatch.percent end end },
	[5] = { L["Bubbles"], function(sb) if (sb.XPWatch) then return sb.XPWatch.bubbles end end },
	[6] = { L["Current Level/Rank"], function(sb) if (sb.XPWatch) then return sb.XPWatch.rank end end },
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

	if InCombatLockdown() then return end

	self:SetAttribute("hasaction", true)

	self:RegisterForClicks("RightButtonUp")
	self:SetScript("OnClick", function(self, mousebutton) self:OnClick(mousebutton) end)
	self:SetScript("OnEnter", function(self) self:OnEnter() end)
	self:SetScript("OnLeave", function(self) self:OnLeave() end)
	self:SetHitRectInsets(0, 0, 0, 0)

	self:RegisterEvent("PLAYER_XP_UPDATE", "XPBar_OnEvent")
	self:RegisterEvent("HONOR_XP_UPDATE", "XPBar_OnEvent")
	self:RegisterEvent("UPDATE_EXHAUSTION", "XPBar_OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "XPBar_OnEvent")
	self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", "XPBar_OnEvent")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "XPBar_OnEvent")

	self.sb:Show()

	local typeString = L["XP Bar"]

	self.fbframe.feedback.text:SetText(typeString)

	self:SetData(self.bar)

end



---TODO: right now we are using DB.statusbtn to assign settings ot the status buttons, but I think our indexes are bar specific
function XPBTN:xpstrings_Update() --handles updating all the strings for the play XP watch bar

	local currXP, nextXP, restedXP, percentXP, bubbles, rank

	--player xp option
	if (self.sb.curXPType == "player_xp") then

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
	elseif(self.sb.curXPType == "azerite_xp") then

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
	elseif(self.sb.curXPType == "honor_points") then
		currXP = UnitHonor("player"); -- current value for level
		nextXP = UnitHonorMax("player"); -- max value for level
		restedXP = tostring(0).." "..L["Levels"]

		local level = UnitHonorLevel("player");

		percentXP = (currXP/nextXP)*100


		bubbles = tostring(math.floor(percentXP/5)).." / 20 "..L["Bubbles"];
		percentXP = string.format("%.2f", percentXP).."%"; --format


		rank = L["Level"] .. " " .. tostring(level)

	end

	if (not self.sb.XPWatch) then --make sure we make the table for us to store our data so we aren't trying to index a non existant table
		self.sb.XPWatch = {}
	end

	self.sb.XPWatch.current = BreakUpLargeNumbers(currXP).." / "..BreakUpLargeNumbers(nextXP)
	self.sb.XPWatch.rested = restedXP
	self.sb.XPWatch.percent = percentXP
	self.sb.XPWatch.bubbles = bubbles
	self.sb.XPWatch.rank = rank


	local isRested
	if(restedXP ~= "0") then
		isRested = true
	else
		isRested = false
	end

	return currXP, nextXP, isRested
end



function XPBTN:XPBar_OnEvent(event, ...)

	if (not self.DB.curXPType) then
		self.DB.curXPType = "player_xp" --sets the default state of the XP bar to be player_xp
	end

	self.sb.curXPType = self.DB.curXPType

	local currXP, nextXP, isRested
	local hasChanged = false;


	if(self.sb.curXPType == "player_xp" and (event=="PLAYER_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event=="UPDATE_EXHAUSTION" or event =="changed_curXPType")) then

		currXP, nextXP, isRested = self:xpstrings_Update()

		if (isRested) then
			self.sb:SetStatusBarColor(self.sb.restColor[1], self.sb.restColor[2], self.sb.restColor[3], self.sb.restColor[4])
		else
			self.sb:SetStatusBarColor(self.sb.norestColor[1], self.sb.norestColor[2], self.sb.norestColor[3], self.sb.norestColor[4])
		end

		hasChanged = true;
	end


	if(self.sb.curXPType == "azerite_xp" and (event =="AZERITE_ITEM_EXPERIENCE_CHANGED" or event =="PLAYER_ENTERING_WORLD" or event =="PLAYER_EQUIPMENT_CHANGED" or event =="changed_curXPType"))then

		currXP, nextXP = self:xpstrings_Update()

		self.sb:SetStatusBarColor(1, 1, 0); --set to yellow?

		hasChanged = true;

	end

	if(self.sb.curXPType == "honor_points" and (event=="HONOR_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event =="changed_curXPType")) then

		currXP, nextXP = self:xpstrings_Update()

		self.sb:SetStatusBarColor(1, .4, .4);

		hasChanged = true;
	end

	if (hasChanged == true) then
		self.sb:SetMinMaxValues(0, 100) --these are for the bar itself, the progress it has from left to right
		self.sb:SetValue((currXP/nextXP)*100)

		self.sb.cText:SetText(self.sb.cFunc(self.sb))
		self.sb.lText:SetText(self.sb.lFunc(self.sb))
		self.sb.rText:SetText(self.sb.rFunc(self.sb))
		self.sb.mText:SetText(self.sb.mFunc(self.sb))
	end

end



function XPBTN:switchCurXPType(newXPType)

	self.DB.curXPType = newXPType
	self:XPBar_OnEvent("changed_curXPType")
end


function XPBTN:xpDropDown_Initialize() -- initialize the dropdown menu for chosing to watch either XP, azerite XP, or Honor Points

	local info = UIDropDownMenu_CreateInfo()

	info.arg1 = self
	info.arg2 = "player_xp"
	info.text = L["Track Character XP"]
	info.func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end

	if (self.sb.curXPType == "player_xp") then
		info.checked = 1
	else
		info.checked = nil
	end

	UIDropDownMenu_AddButton(info)
	wipe(info)

	if(C_AzeriteItem.FindActiveAzeriteItem()) then --only show this button if they player has the Heart of Azeroth
		info.arg1 = self
		info.arg2 = "azerite_xp"
		info.text = L["Track Azerite Power"]
		info.func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end

		if (self.sb.curXPType == "azerite_xp") then
			info.checked = 1
		else
			info.checked = nil
		end

		UIDropDownMenu_AddButton(info)
		wipe(info)
	end


	info.arg1 = self
	info.arg2 = "honor_points"
	info.text = L["Track Honor Points"]
	info.func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end

	if (self.sb.curXPType == "honor_points") then
		info.checked = 1
	else
		info.checked = nil
	end

	UIDropDownMenu_AddButton(info)
	wipe(info)

end


function XPBTN:XPBar_DropDown_OnLoad()

	UIDropDownMenu_Initialize(self.dropdown, function() self:xpDropDown_Initialize() end, "MENU")
	self.dropdown_init = true
end


function XPBTN:OnClick(mousebutton)

	if (mousebutton == "RightButton") then

		if not self.dropdown_init then
			self:XPBar_DropDown_OnLoad()
		end


		self:xpstrings_Update()

		ToggleDropDownMenu(1, nil, self.dropdown, self, 0, 0)

		DropDownList1:ClearAllPoints()
		DropDownList1:SetPoint("LEFT", self, "RIGHT", 3, 0)
		DropDownList1:SetClampedToScreen(true)

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

	end

end