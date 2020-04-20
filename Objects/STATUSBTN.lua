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

---@class STATUSBTN : BUTTON @define class STATUSBTN inherits from class BUTTON
local STATUSBTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.STATUSBTN = STATUSBTN


local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local CastWatch, RepWatch, MirrorWatch, MirrorBars = {}, {}, {}, {}

local sbStrings = {
	cast = {
		[1] = { L["None"], function(sb) return "" end },
		[2] = { L["Spell"], function(sb) if CastWatch[sb.unit] then return CastWatch[sb.unit].spell end end },
		[3] = { L["Timer"], function(sb) if CastWatch[sb.unit] then return CastWatch[sb.unit].timer end end },
	},
	xp = {
		[1] = { L["None"], function(sb) return "" end },
		[2] = { L["Current/Next"], function(sb) if sb.XPWatch then return sb.XPWatch.current end end },
		[3] = { L["Rested Levels"], function(sb) if sb.XPWatch then return sb.XPWatch.rested end end },
		[4] = { L["Percent"], function(sb) if sb.XPWatch then return sb.XPWatch.percent end end },
		[5] = { L["Bubbles"], function(sb) if sb.XPWatch then return sb.XPWatch.bubbles end end },
		[6] = { L["Current Level/Rank"], function(sb) if sb.XPWatch then return sb.XPWatch.rank end end },
	},
	rep = {
		[1] = { L["None"], function(sb) return "" end },
		[2] = { L["Faction"], function(sb) if RepWatch[sb.repID] then return RepWatch[sb.repID].name end end }, --TODO:should probably do the same as above here, just in case people have more than 1 rep bar
		[3] = { L["Current/Next"], function(sb) if RepWatch[sb.repID] then return RepWatch[sb.repID].current end end },
		[4] = { L["Percent"], function(sb) if RepWatch[sb.repID] then return RepWatch[sb.repID].percent end end },
		[5] = { L["Bubbles"], function(sb) if RepWatch[sb.repID] then return RepWatch[sb.repID].bubbles end end },
		[6] = { L["Current Level/Rank"], function(sb) if RepWatch[sb.repID] then return RepWatch[sb.repID].standing end end},
	},
	mirror = {
		[1] = { L["None"], function(sb) return "" end },
		[2] = { L["Type"], function(sb) if MirrorWatch[sb.mirror] then return MirrorWatch[sb.mirror].label end end },
		[3] = { L["Timer"], function(sb) if MirrorWatch[sb.mirror] then return MirrorWatch[sb.mirror].timer end end },
	},
}

Neuron.sbStrings = sbStrings


local BarUnits = {
	[1] = "-none-",
	[2] = "player",
	[3] = "pet",
	[4] = "target",
	[5] = "targettarget",
	[6] = "focus",
	[7] = "mouseover",
	[8] = "party1",
	[9] = "party2",
	[10] = "party3",
	[11] = "party4",
}
Neuron.BarUnits = BarUnits


local BarTextures = {
	[1] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Default_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Default_2", L["Default"] },
	[2] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Contrast_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Contrast_2", L["Contrast"] },
	[3] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Carpaint_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Carpaint_2", L["Carpaint"] },
	[4] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Gel_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Gel_2", L["Gel"] },
	[5] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Glassed_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Glassed_2", L["Glassed"] },
	[6] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Soft_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Soft_2", L["Soft"] },
	[7] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Velvet_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Velvet_3", L["Velvet"] },
}
Neuron.BarTextures = BarTextures


local BarBorders = {
	[1] = { L["Tooltip"], "Interface\\Tooltips\\UI-Tooltip-Border", 2, 2, 3, 3, 12, 12, -2, 3, 2, -3 },
	[2] = { L["Slider"], "Interface\\Buttons\\UI-SliderBar-Border", 3, 3, 6, 6, 8, 8 , -1, 5, 1, -5 },
	[3] = { L["Dialog"], "Interface\\AddOns\\Neuron\\Images\\Border_Dialog", 11, 12, 12, 11, 26, 26, -7, 7, 7, -7 },
	[4] = { L["None"], "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}
Neuron.BarBorders = BarBorders

local BarOrientations = {
	[1] = "Horizontal",
	[2] = "Vertical",
}
Neuron.BarOrientations = BarOrientations


---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return STATUSBTN @ A newly created STATUSBTN object
function STATUSBTN.new(bar, buttonID, defaults)

	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.BUTTON.new(bar, buttonID, STATUSBTN, "StatusBar", "StatusBar", "NeuronStatusBarTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	if Neuron.NeuronGUI then
		Neuron.NeuronGUI:SB_CreateEditFrame(newButton)
	end

	return newButton
end

----------------------------------
--------XP Bar--------------------
----------------------------------

---TODO: right now we are using DB.statusbtn to assign settins ot the status buttons, but I think our indexes are bar specific
function STATUSBTN:xpstrings_Update() --handles updating all the strings for the play XP watch bar

	local currXP, nextXP, restedXP, percentXP, bubbles, rank

	--player xp option
	if self.elements.SB.curXPType == "player_xp" then

		currXP, nextXP, restedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()

		local playerLevel = UnitLevel("player")

		if playerLevel == MAX_PLAYER_LEVEL then
			currXP = nextXP
		end

		percentXP = (currXP/nextXP)*100;

		bubbles = tostring(math.floor(currXP/(nextXP/20))).." / 20 "..L["Bubbles"]
		percentXP = string.format("%.2f", (percentXP)).."%"


		if restedXP then
			restedXP = string.format("%.2f", (tostring(restedXP/nextXP))).." "..L["Levels"]
		else
			restedXP = "0".." "..L["Levels"]
		end

		rank = L["Level"].." "..tostring(playerLevel)

		--heart of azeroth option
	elseif self.elements.SB.curXPType == "azerite_xp" then

		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

		if azeriteItemLocation then

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
	elseif self.elements.SB.curXPType == "honor_points" then
		currXP = UnitHonor("player"); -- current value for level
		nextXP = UnitHonorMax("player"); -- max value for level
		restedXP = tostring(0).." "..L["Levels"]

		local level = UnitHonorLevel("player");

		percentXP = (currXP/nextXP)*100


		bubbles = tostring(math.floor(percentXP/5)).." / 20 "..L["Bubbles"];
		percentXP = string.format("%.2f", percentXP).."%"; --format


		rank = L["Level"] .. " " .. tostring(level)

	end

	if not self.elements.SB.XPWatch then --make sure we make the table for us to store our data so we aren't trying to index a non existant table
		self.elements.SB.XPWatch = {}
	end

	self.elements.SB.XPWatch.current = BreakUpLargeNumbers(currXP).." / "..BreakUpLargeNumbers(nextXP)
	self.elements.SB.XPWatch.rested = restedXP
	self.elements.SB.XPWatch.percent = percentXP
	self.elements.SB.XPWatch.bubbles = bubbles
	self.elements.SB.XPWatch.rank = rank


	local isRested
	if restedXP ~= "0" then
		isRested = true
	else
		isRested = false
	end

	return currXP, nextXP, isRested
end



function STATUSBTN:XPBar_OnEvent(event, ...)

	if not self.DB.curXPType then
		self.DB.curXPType = "player_xp" --sets the default state of the XP bar to be player_xp
	end

	self.elements.SB.curXPType = self.DB.curXPType

	local currXP, nextXP, isRested
	local hasChanged = false;


	if self.elements.SB.curXPType == "player_xp" and (event=="PLAYER_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event=="UPDATE_EXHAUSTION" or event =="changed_curXPType") then

		currXP, nextXP, isRested = self:xpstrings_Update()

		if isRested then
			self.elements.SB:SetStatusBarColor(self.elements.SB.restColor[1], self.elements.SB.restColor[2], self.elements.SB.restColor[3], self.elements.SB.restColor[4])
		else
			self.elements.SB:SetStatusBarColor(self.elements.SB.norestColor[1], self.elements.SB.norestColor[2], self.elements.SB.norestColor[3], self.elements.SB.norestColor[4])
		end

		hasChanged = true;
	end


	if self.elements.SB.curXPType == "azerite_xp" and (event =="AZERITE_ITEM_EXPERIENCE_CHANGED" or event =="PLAYER_ENTERING_WORLD" or event =="PLAYER_EQUIPMENT_CHANGED" or event =="changed_curXPType") then

		currXP, nextXP = self:xpstrings_Update()

		self.elements.SB:SetStatusBarColor(1, 1, 0); --set to yellow?

		hasChanged = true;

	end

	if self.elements.SB.curXPType == "honor_points" and (event=="HONOR_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event =="changed_curXPType") then

		currXP, nextXP = self:xpstrings_Update()

		self.elements.SB:SetStatusBarColor(1, .4, .4);

		hasChanged = true;
	end

	if hasChanged == true then
		self.elements.SB:SetMinMaxValues(0, 100) --these are for the bar itself, the progress it has from left to right
		self.elements.SB:SetValue((currXP/nextXP)*100)

		self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
		self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))
		self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))
		self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))
	end

end



function STATUSBTN:switchCurXPType(newXPType)

	self.DB.curXPType = newXPType
	self:XPBar_OnEvent("changed_curXPType")
end


function STATUSBTN:xpDropDown_Initialize() -- initialize the dropdown menu for chosing to watch either XP, azerite XP, or Honor Points

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
		checked = self.elements.SB.curXPType == "player_xp",
	})

	--wow classic doesn't have Honor points nor Azerite, carefull
	if not Neuron.isWoWClassic then

		--add Heart of Azeroth option
		if C_AzeriteItem.FindActiveAzeriteItem() then --only show this button if they player has the Heart of Azeroth
			table.insert(menu, {
				arg1 = self,
				arg2 = "azerite_xp",
				text = L["Track Azerite Power"],
				func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end,
				checked = self.elements.SB.curXPType == "azerite_xp",
			})
		end

		--add PvP Honor option
		table.insert(menu, {
			arg1 = self,
			arg2 = "honor_points",
			text = L["Track Honor Points"],
			func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end,
			checked = self.elements.SB.curXPType == "honor_points",
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


----------------------------------------------
----------------Rep Bar-----------------------
----------------------------------------------


--- Creates a table containing provided data
-- @param name, hasFriendStatus, standing, minrep, maxrep, value, colors
-- @return reptable:  Table containing provided data
function STATUSBTN:SetRepWatch(ID, name, standing, header, minrep, maxrep, value, colors, headerOverride)
	local reptable = {}
	reptable.ID = ID
	reptable.name = name
	reptable.standing = standing
	reptable.header = header
	reptable.current = (value-minrep).." / "..(maxrep-minrep)
	reptable.percent = floor(((value-minrep)/(maxrep-minrep))*100).."%"
	reptable.bubbles = tostring(math.floor(((((value-minrep)/(maxrep-minrep))*100)/5))).." / 20 "..L["Bubbles"]
	reptable.min = minrep
	reptable.max = maxrep
	reptable.value = value
	reptable.hex = string.format("%02x%02x%02x", colors.r*255, colors.g*255, colors.b*255)
	reptable.r = colors.r
	reptable.g = colors.g
	reptable.b = colors.b
	reptable.headerOverride = headerOverride

	return reptable
end


function STATUSBTN:repstrings_Update(repGainedString)

	local BAR_REP_DATA = {
		[0] = { l="Unknown", r=0.5, g=0.5, b=0.5, a=1.0 },
		[1] = { l="Hated", r=0.6, g=0.1, b=0.1, a=1.0 },
		[2] = { l="Hostile", r=0.7, g=0.2, b=0.2, a=1.0 },
		[3] = { l="Unfriendly", r=0.75, g=0.27, b=0, a=1.0 },
		[4] = { l="Neutral", r=0.9, g=0.7, b=0, a=1.0 },
		[5] = { l="Friendly", r=0.5, g=0.6, b=0.1, a=1.0 },
		[6] = { l="Honored", r=0.1, g=0.5, b=0.20, a=1.0 },
		[7] = { l="Revered", r=0.0, g=0.39, b=0.88, a=1.0 },
		[8] = { l="Exalted", r=0.58, g=0.0, b=0.55, a=1.0 },
		[9] = { l="Paragon", r=1, g=0.5, b=0, a=1.0 },
	}

	if GetNumFactions() <= 0 then --quit if for some reason the number of known factions is 0 or less (should never happen, this is just for safety)
		return
	end

	wipe(RepWatch)

	local header --we set this on each header to categorize all the factions that follow

	for i=1, GetNumFactions() do
		local name, _, standingID, min, max, value, _, _, isHeader, _, hasRep, _, isChild, factionID = GetFactionInfo(i)
		local colors = {}
		local headerOverride

		if not standingID then --not sure if we will ever be in a position where standingID comes back as nil, but if so, protect for it.
			standingID = 0
		elseif standingID > 9 then --protect just in case standingID comes back greater than 9. I'm not sure if this will ever trip, but it's a safety thing.
			standingID = 9
		end

		if standingID == 8 then
			min = 0
		end

		if isHeader and not isChild then --set a header variable that will get set on each rep that follows until the next header is set
			header = name
		end

		if (not isHeader or hasRep) and not IsFactionInactive(i) then

			local fID, standing, isParagon
			if not Neuron.isWoWClassic then --classic doesn't have Friendships or Paragon, carefull
				fID, _, _, _, _, _, standing, _, _ = GetFriendshipReputation(factionID)
				isParagon = C_Reputation.IsFactionParagon(factionID)
			end

			if not fID then --not a "Friendship" faction, i.e. Chromie or Brawlers Guild
				if not isParagon then
					colors.r, colors.g, colors.b = BAR_REP_DATA[standingID].r, BAR_REP_DATA[standingID].g, BAR_REP_DATA[standingID].b
					standing = BAR_REP_DATA[standingID].l --convert numerical standingID to text i.e "Exalted" instead of 8
				else
					local para_value, para_max, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
					value = para_value % para_max;
					max = para_max
					if hasRewardPending then
						name = name.." ("..L["Reward"]:upper()..")"
					end
					min = 0
					colors.r, colors.g, colors.b = BAR_REP_DATA[9].r, BAR_REP_DATA[9].g, BAR_REP_DATA[9].b
					standing = BAR_REP_DATA[9].l --set standing text to be "Paragon"
				end
			else --is a "Friendship" faction
				if string.find(name, "Brawl'gar Arena") or string.find(name, "Bizmo's Brawlpub") then
					colors.r, colors.g, colors.b = BAR_REP_DATA[standingID].r, BAR_REP_DATA[standingID].g, BAR_REP_DATA[standingID].b --offset by two, because friendships don't have "hated" or "hostile" ranks
				else
					if standingID + 2 > 8 then
						standingID = 6
					end
					colors.r, colors.g, colors.b = BAR_REP_DATA[standingID+2].r, BAR_REP_DATA[standingID+2].g, BAR_REP_DATA[standingID+2].b --offset by two, because friendships don't have "hated" or "hostile" ranks
				end
				headerOverride = "Other"
			end

			local repData = self:SetRepWatch(i, name, standing, header, min, max, value, colors, headerOverride)

			--repGainedString is a phrase that reads like "Reputation with Zandalari Empire increased by 75.", except on login it's type boolean for some reason
			if repGainedString and type(repGainedString) ~= "boolean" and repGainedString:find(name) or self.data.autoWatch == i then --this line automatically assigns the most recently updated repData to RepWatch[0], and the "auto" option assigns RepWatch[0] to be shown
				RepWatch[0] = repData --RepWatch is what holds all of our Repuation data for all of the factions, and the zeroth element is the Autowatch slot, which is always the latest updated data
				self.data.autoWatch = i

				---safety check in case repData comes back as nil, which happens sometimes for some strange reason
				---this will at the very least keep it from being an ugly, grey, empty bar.
				if not RepWatch[0] then
					RepWatch[0] = CopyTable(RepWatch[2]) -- default to the lowest valid rep (RepWatch[1] is a header)
					self.data.autoWatch = 2
				end

			end

			RepWatch[i] = repData --set current reptable into growing RepWatch table

		end

	end
end


function STATUSBTN:repbar_OnEvent(event,...)

	self:repstrings_Update(...)

	if RepWatch[self.elements.SB.repID] then
		self.elements.SB:SetStatusBarColor(RepWatch[self.elements.SB.repID].r,  RepWatch[self.elements.SB.repID].g, RepWatch[self.elements.SB.repID].b)
		self.elements.SB:SetMinMaxValues(RepWatch[self.elements.SB.repID].min, RepWatch[self.elements.SB.repID].max)
		self.elements.SB:SetValue(RepWatch[self.elements.SB.repID].value)
	else
		self.elements.SB:SetStatusBarColor(0.5,  0.5, 0.5)
		self.elements.SB:SetMinMaxValues(0, 1)
		self.elements.SB:SetValue(1)
	end

	self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
	self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))
	self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))
	self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))
end


function STATUSBTN:repDropDown_Initialize() --Initialize the dropdown menu for choosing a rep

	if not self.elements.SB then
		return
	end

	local repDataTable = {}

	for k,v in pairs(RepWatch) do --insert all factions and percentages into "data"
		if k > 0 then --skip the "0" entry which is our autowatch
			local header
			if v.headerOverride then
				header = v.headerOverride
			else
				header = v.header
				if v.header == "Guild" then --the "Guild" category is kinda stupid to just have alone, so we should override it with "Other"
					header = "Other"
				end
			end

			if not repDataTable[header]then
				repDataTable[header] = {}
			end
			table.insert(repDataTable[header], { ID=v.ID, name=v.name, standing=v.standing, percent=v.percent, hex=v.hex})
		end
	end

	local menuFrame
	if not NeuronRepDropdownMenu then --try to avoid re-creating this over again if we don't have to
		menuFrame = CreateFrame("Frame", "NeuronRepDropdownMenu", self, "UIDropDownMenuTemplate")
	else
		menuFrame = NeuronRepDropdownMenu
	end
	menuFrame:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0)

	local menu = {} --we need to build this table into the EasyMenu data format

	-- Menu Title
	table.insert(menu, {text = L["Select an Option"], isTitle = true, notCheckable=true, justifyH = "CENTER",})

	--this is the Auto Select entry for automatically picking faction to watch based on the latest gained
	table.insert(menu, {
		arg1=self,
		arg2=nil,
		text=L["Auto Select"],
		func= function(dropdown, self) --self is arg1
			self.data.repID = dropdown.value
			self.elements.SB.repID = dropdown.value
			self:repbar_OnEvent()
		end,
		value=0,
		checked=self.data.repID == 0
	})

	--this is a spacer between everything else and close
	table.insert(menu,	{
		arg1=nil,
		arg2=nil,
		text=" ",
		disabled = true,
		func=function() end,
		value=nil,
		justifyH = "CENTER",
		checked=nil,
		notCheckable=true
	})

	local innerMenu = {} --temp table that will hold all of our faction header parents
	--build the rest of the options based on the repDataTable
	for k,v in pairs(repDataTable) do
		local temp = {} --temp table
		temp.menuList = {} --table that holds the sub-tables (factions)

		for _,v2 in pairs(v) do
			table.insert(temp.menuList, {
				arg1=self,
				arg2 = nil,
				text = v2.name .. " - " .. v2.percent .." - ".. v2.standing,
				func = function(dropdown, self) --self is arg1
					self.data.repID = dropdown.value
					self.elements.SB.repID = dropdown.value
					self:repbar_OnEvent()
					menuFrame:Hide()
				end,
				value = v2.ID,
				colorCode="|cff"..v2.hex,
				checked = self.data.repID == v2.ID,
				notClickable = false,
				notCheckable = false
			})
		end

		--sort the list of factions (in a given reputation bracket) alphabetically
		table.sort(temp.menuList, function(a,b)
			return a.text<b.text
		end)

		--insert values into the growing innerMenu table
		table.insert(innerMenu, {text=k, hasArrow=true, notCheckable=true, menuList=temp.menuList})
	end--create a comparison table for our custom sort routine

	--these are the English Strings. It would be good to get these translated
	local SORT_TABLE = {["Battle for Azeroth"]=1, ["Legion"]=2, ["Warlords of Draenor"]=3, ["Mists of Pandaria"]=4, ["Cataclysm"]=5, ["Wrath of the Lich King"]=6, ["The Burning Crusade"]=7, ["Classic"]=8, ["Guild"]=9, ["Other"]=10}
	--sort the list of our reputation brackets according the priority table above
	table.sort(innerMenu, function(a,b)
		if SORT_TABLE[a.text] and SORT_TABLE[b.text] then
			return SORT_TABLE[a.text]<SORT_TABLE[b.text]
		else
			return a.text < b.text
		end
	end)

	--insert each (now sorted) entry individually into our menu table
	for _,v in pairs(innerMenu) do
		table.insert(menu, v)
	end

	--this is a spacer between everything else and close
	table.insert(menu,	{
		arg1=nil,
		arg2=nil,
		text=" ",
		disabled = true,
		func=function() end,
		value=nil,
		justifyH = "CENTER",
		checked=nil,
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
	EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU", 1)

end


----------------------------------------------------
-------------------Mirror Bar-----------------------
----------------------------------------------------


function STATUSBTN: MirrorBar_OnEvent(event, ...)

	if event == "MIRROR_TIMER_START" then
		self:mirrorbar_Start(...)
	elseif event == "MIRROR_TIMER_STOP" then
		self:mirrorbar_Stop(...)
	elseif event == "PLAYER_ENTERING_WORLD" then --this doesn't seem to be working as of 8.0, all report as UNKNOWN

		local type, value, maxvalue, scale, paused, label

		for i=1, MIRRORTIMER_NUMTIMERS do

			type, value, maxvalue, scale, paused, label = GetMirrorTimerInfo(i)

			if type ~= "UNKNOWN" then
				self:mirrorbar_Start(type, value, maxvalue, scale, paused, label)
			end
		end
	end

end



function STATUSBTN:mirrorbar_Start(type, value, maxvalue, scale, paused, label)

	if not MirrorWatch[type] then
		MirrorWatch[type] = { active = false, mbar = nil, label = "", timer = "" }
	end

	if not MirrorWatch[type].active then

		local mbar = table.remove(MirrorBars, 1)

		if mbar then

			MirrorWatch[type].active = true
			MirrorWatch[type].mbar = mbar
			MirrorWatch[type].label = label

			mbar.elements.SB.mirror = type
			mbar.elements.SB.value = (value / 1000)
			mbar.elements.SB.maxvalue = (maxvalue / 1000)
			mbar.elements.SB.scale = scale

			if  paused > 0  then
				mbar.elements.SB.paused = 1
			else
				mbar.elements.SB.paused = nil
			end

			local color = MirrorTimerColors[type]

			mbar.elements.SB:SetMinMaxValues(0, (maxvalue / 1000))
			mbar.elements.SB:SetValue(mbar.elements.SB.value)
			mbar.elements.SB:SetStatusBarColor(color.r, color.g, color.b)

			mbar.elements.SB:SetAlpha(1)
			mbar.elements.SB:Show()
		end
	end
end





function STATUSBTN:mirrorbar_Stop(type)


	if MirrorWatch[type] and MirrorWatch[type].active then

		local mbar = MirrorWatch[type].mbar

		if mbar then

			table.insert(MirrorBars, 1, mbar)

			MirrorWatch[type].active = false
			MirrorWatch[type].mbar = nil
			MirrorWatch[type].label = ""
			MirrorWatch[type].timer = ""

			mbar.elements.SB.mirror = nil
		end
	end
end





function STATUSBTN:CastBar_FinishSpell()

	self.elements.SB.spark:Hide()
	self.elements.SB.barflash:SetAlpha(0.0)
	self.elements.SB.barflash:Show()
	self.elements.SB.flash = 1
	self.elements.SB.fadeOut = 1
	self.elements.SB.casting = false
	self.elements.SB.channeling = false
end





function STATUSBTN:CastBar_Reset()

	self.elements.SB.fadeOut = 1
	self.elements.SB.casting = false
	self.elements.SB.channeling = false
	self.elements.SB:SetStatusBarColor(self.elements.SB.castColor[1], self.elements.SB.castColor[2], self.elements.SB.castColor[3], self.elements.SB.castColor[4])

	if not self.editmode then
		self.elements.SB:Hide()
	end
end





function STATUSBTN:CastBar_OnEvent(event, ...)

	local unit = select(1, ...)
	local eventCastID = select(2,...)--return payload is "unitTarget", "castGUID", spellID

	if unit ~= self.elements.SB.unit then
		return
	end

	if not CastWatch[unit]  then
		CastWatch[unit] = {}
	end

	if event == "UNIT_SPELLCAST_START" then

		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible

		if not Neuron.isWoWClassic then
			name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
		elseif unit == "player" then
			name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = CastingInfo() --classic doesn't have UnitCastingInfo()
		end

		if not name then
			self:CastBar_Reset()
			return
		end

		self.elements.SB:SetStatusBarColor(self.elements.SB.castColor[1], self.elements.SB.castColor[2], self.elements.SB.castColor[3], self.elements.SB.castColor[4])

		if self.elements.SB.spark then
			self.elements.SB.spark:SetTexture("Interface\\AddOns\\Neuron\\Images\\CastingBar_Spark_"..self.elements.SB.orientation)
			self.elements.SB.spark:Show()
		end

		self.elements.SB.value = (GetTime()-(startTime/1000))
		self.elements.SB.maxValue = (endTime-startTime)/1000
		self.elements.SB:SetMinMaxValues(0, self.elements.SB.maxValue)
		self.elements.SB:SetValue(self.elements.SB.value)

		self.elements.SB.totalTime = self.elements.SB.maxValue - self.elements.SB:GetValue()

		CastWatch[unit].spell = text

		if self.elements.SB.showIcon then

			self.elements.SB.icon:SetTexture(texture)
			self.elements.SB.icon:Show()

			if notInterruptible then
				self.elements.SB.shield:Show()
			else
				self.elements.SB.shield:Hide()
			end

		else
			self.elements.SB.icon:Hide()
			self.elements.SB.shield:Hide()
		end

		self.elements.SB:SetAlpha(1.0)
		self.elements.SB.holdTime = 0
		self.elements.SB.casting = true
		self.elements.SB.castID = castID
		self.elements.SB.channeling = false
		self.elements.SB.fadeOut = nil

		self.elements.SB:Show()

		--update castbar text
		if not self.elements.SB.cbtimer.castInfo[unit] then
			self.elements.SB.cbtimer.castInfo[unit] = {}
		end

		self.elements.SB.cbtimer.castInfo[unit][1] = text
		self.elements.SB.cbtimer.castInfo[unit][2] = "%0.1f"

	elseif event == "UNIT_SPELLCAST_CHANNEL_START" then

		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible

		if not Neuron.isWoWClassic then
			name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)
		elseif unit == "player" then
			name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = ChannelInfo()
		end

		if not name then
			self:CastBar_Reset()
			return
		end

		self.elements.SB:SetStatusBarColor(self.elements.SB.channelColor[1], self.elements.SB.channelColor[2], self.elements.SB.channelColor[3], self.elements.SB.channelColor[4])

		self.elements.SB.value = ((endTime/1000)-GetTime())
		self.elements.SB.maxValue = (endTime - startTime) / 1000;
		self.elements.SB:SetMinMaxValues(0, self.elements.SB.maxValue);
		self.elements.SB:SetValue(self.elements.SB.value)

		CastWatch[unit].spell = text

		if self.elements.SB.showIcon then

			self.elements.SB.icon:SetTexture(texture)
			self.elements.SB.icon:Show()

			if notInterruptible then
				self.elements.SB.shield:Show()
			else
				self.elements.SB.shield:Hide()
			end

		else
			self.elements.SB.icon:Hide()
			self.elements.SB.shield:Hide()
		end

		if self.elements.SB.spark then
			self.elements.SB.spark:Hide()
		end

		self.elements.SB:SetAlpha(1.0)
		self.elements.SB.holdTime = 0
		self.elements.SB.casting = false
		self.elements.SB.channeling = true
		self.elements.SB.fadeOut = nil

		self.elements.SB:Show()

		--update text on castbar
		if not self.elements.SB.cbtimer.castInfo[unit] then
			self.elements.SB.cbtimer.castInfo[unit] = {}
		end

		self.elements.SB.cbtimer.castInfo[unit][1] = text
		self.elements.SB.cbtimer.castInfo[unit][2] = "%0.1f"


	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and not self.elements.SB.channeling then --don't do anything with this event when channeling as it fires at each pulse of a spell channel

		self.elements.SB:SetStatusBarColor(self.elements.SB.successColor[1], self.elements.SB.successColor[2], self.elements.SB.successColor[3], self.elements.SB.successColor[4])

	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and self.elements.SB.channeling then

		-- do nothing (when Tranquility is channeling if reports UNIT_SPELLCAST_SUCCEEDED many times during the duration)

	elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") and self.elements.SB.castID == eventCastID or event == "UNIT_SPELLCAST_CHANNEL_STOP"  then

		if self.elements.SB:IsShown() and (self.elements.SB.casting or self.elements.SB.channeling) and not self.elements.SB.fadeOut then

			self.elements.SB:SetValue(self.elements.SB.maxValue)

			self.elements.SB:SetStatusBarColor(self.elements.SB.failColor[1], self.elements.SB.failColor[2], self.elements.SB.failColor[3], self.elements.SB.failColor[4])

			if self.elements.SB.spark then
				self.elements.SB.spark:Hide()
			end

			if event == "UNIT_SPELLCAST_FAILED" then
				CastWatch[unit].spell = FAILED
			else
				CastWatch[unit].spell = INTERRUPTED
			end

			self.elements.SB.casting = false
			self.elements.SB.channeling = false
			self.elements.SB.fadeOut = 1
			self.elements.SB.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
		end

	elseif event == "UNIT_SPELLCAST_DELAYED" then

		if self.elements.SB:IsShown() then

			local name, text, texture, startTime, endTime, isTradeSkill

			if not Neuron.isWoWClassic then
				name, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)
			elseif unit == "player" then
				name, text, texture, startTime, endTime, isTradeSkill = CastingInfo() --Classic doesn't have UnitCastingInfo()
			end

			if not name then
				self:CastBar_Reset()
				return
			end

			self.elements.SB.value = (GetTime()-(startTime/1000))
			self.elements.SB.maxValue = (endTime-startTime)/1000
			self.elements.SB:SetMinMaxValues(0, self.elements.SB.maxValue)

			if not self.elements.SB.casting then

				self.elements.SB:SetStatusBarColor(self.elements.SB.castColor[1], self.elements.SB.castColor[2], self.elements.SB.castColor[3], self.elements.SB.castColor[4])

				self.elements.SB.spark:Show()
				self.elements.SB.barflash:SetAlpha(0.0)
				self.elements.SB.barflash:Hide()

				self.elements.SB.casting = true
				self.elements.SB.channeling = false
				self.elements.SB.flash = 0
				self.elements.SB.fadeOut = 0
			end
		end

	elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then

		if self.elements.SB:IsShown() then

			local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible

			if not Neuron.isWoWClassic then
				name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)
			elseif unit == "player" then
				name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = ChannelInfo()
			end


			if not name then
				self:CastBar_Reset()
				return
			end

			self.elements.SB.value = ((endTime/1000)-GetTime())
			self.elements.SB.maxValue = (endTime-startTime)/1000
			self.elements.SB:SetMinMaxValues(0, self.elements.SB.maxValue)
			self.elements.SB:SetValue(self.elements.SB.value)
		end

	elseif self.elements.SB.showShield and event == "UNIT_SPELLCAST_INTERRUPTIBLE"  then

		self.elements.SB.shield:Hide()

	elseif self.elements.SB.showShield and event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"  then

		self.elements.SB.shield:Show()

	end

	self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
	self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))
	self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))
	self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))

end





function STATUSBTN:CastBar_OnUpdate(elapsed)

	local unit = self.elements.SB.unit
	local sparkPosition, alpha

	if unit then

		if self.elements.SB.cbtimer.castInfo[unit] then

			local displayName, numFormat = self.elements.SB.cbtimer.castInfo[unit][1], self.elements.SB.cbtimer.castInfo[unit][2]

			if self.elements.SB.maxValue then
				CastWatch[self.elements.SB.unit].timer = string.format(numFormat, self.elements.SB.value).."/"..format(numFormat, self.elements.SB.maxValue)
			else
				CastWatch[self.elements.SB.unit].timer = string.format(numFormat, self.elements.SB.value)
			end
		end

		if self.elements.SB.casting then

			self.elements.SB.value = self.elements.SB.value + elapsed

			if self.elements.SB.value >= self.elements.SB.maxValue then
				self.elements.SB:SetValue(self.elements.SB.maxValue)
				self:CastBar_FinishSpell()
				return
			end

			self.elements.SB:SetValue(self.elements.SB.value)

			self.elements.SB.barflash:Hide()

			if self.elements.SB.orientation == 1 then

				sparkPosition = (self.elements.SB.value/self.elements.SB.maxValue)*self.elements.SB:GetWidth()

				if sparkPosition < 0 then
					sparkPosition = 0
				end

				self.elements.SB.spark:SetPoint("CENTER", self.elements.SB, "LEFT", sparkPosition, 0)

			else
				sparkPosition = (self.elements.SB.value / self.elements.SB.maxValue) * self.elements.SB:GetHeight()

				if  sparkPosition < 0  then
					sparkPosition = 0
				end

				self.elements.SB.spark:SetPoint("CENTER", self.elements.SB, "BOTTOM", 0, sparkPosition)
			end

		elseif self.elements.SB.channeling then

			self.elements.SB.value = self.elements.SB.value - elapsed

			if self.elements.SB.value <= 0 then
				self:CastBar_FinishSpell()
				return
			end

			self.elements.SB:SetValue(self.elements.SB.value)

			self.elements.SB.barflash:Hide()

		elseif GetTime() < self.elements.SB.holdTime then

			return

		elseif self.elements.SB.flash then

			alpha = self.elements.SB.barflash:GetAlpha() + CASTING_BAR_FLASH_STEP or 0

			if alpha < 1 then
				self.elements.SB.barflash:SetAlpha(alpha)
			else
				self.elements.SB.barflash:SetAlpha(1.0)
				self.elements.SB.flash = nil
			end

		elseif self.elements.SB.fadeOut and not self.elements.SB.editmode then

			alpha = self.elements.SB:GetAlpha() - CASTING_BAR_ALPHA_STEP

			if alpha > 0 then
				self.elements.SB:SetAlpha(alpha)
			else
				self:CastBar_Reset()
			end
		end
	end

	self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
	self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))
	self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))
	self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))
end



function STATUSBTN:MirrorBar_OnUpdate(elapsed)

	if self.elements.SB.mirror then

		self.elements.SB.value = GetMirrorTimerProgress(self.elements.SB.mirror)/1000


		if self.elements.SB.value > self.elements.SB.maxvalue then

			self.elements.SB.alpha = self.elements.SB:GetAlpha() - CASTING_BAR_ALPHA_STEP

			if self.elements.SB.alpha > 0 then
				self.elements.SB:SetAlpha(self.elements.SB.alpha)
			else
				self.elements.SB:Hide()
			end

		else

			self.elements.SB:SetValue(self.elements.SB.value)

			if self.elements.SB.value >= 60 then
				self.elements.SB.value = string.format("%0.1f", self.elements.SB.value/60)
				self.elements.SB.value = self.elements.SB.value.."m"
			else
				self.elements.SB.value = string.format("%0.0f", self.elements.SB.value)
				self.elements.SB.value = self.elements.SB.value.."s"
			end

			MirrorWatch[self.elements.SB.mirror].timer = self.elements.SB.value

		end

	elseif not self.editmode then

		self.elements.SB.alpha = self.elements.SB:GetAlpha() - CASTING_BAR_ALPHA_STEP

		if self.elements.SB.alpha > 0 then
			self.elements.SB:SetAlpha(self.elements.SB.alpha)
		else
			self.elements.SB:Hide()
		end
	end

	self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
	self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))
	self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))
	self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))
end




function STATUSBTN:SetBorder(statusbutton, config, bordercolor)

	statusbutton.border:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	                                  edgeFile = BarBorders[config.border][2],
	                                  tile = true,
	                                  tileSize = BarBorders[config.border][7],
	                                  edgeSize = BarBorders[config.border][8],
	                                  insets = { left = BarBorders[config.border][3],
	                                             right = BarBorders[config.border][4],
	                                             top = BarBorders[config.border][5],
	                                             bottom = BarBorders[config.border][6]
	                                  }
	})

	statusbutton.border:SetPoint("TOPLEFT", BarBorders[config.border][9], BarBorders[config.border][10])
	statusbutton.border:SetPoint("BOTTOMRIGHT", BarBorders[config.border][11], BarBorders[config.border][12])

	statusbutton.border:SetBackdropColor(0, 0, 0, 0)
	statusbutton.border:SetBackdropBorderColor(bordercolor[1], bordercolor[2], bordercolor[3], 1)
	statusbutton.border:SetFrameLevel(self:GetFrameLevel()+1)

	statusbutton.bg:SetBackdropColor(0, 0, 0, 1)
	statusbutton.bg:SetBackdropBorderColor(0, 0, 0, 0)
	statusbutton.bg:SetFrameLevel(0)

	if statusbutton.barflash then
		statusbutton.barflash:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		                                    edgeFile = BarBorders[config.border][2],
		                                    tile = true,
		                                    tileSize = BarBorders[config.border][7],
		                                    edgeSize = BarBorders[config.border][8],
		                                    insets = { left = BarBorders[config.border][3],
		                                               right = BarBorders[config.border][4],
		                                               top = BarBorders[config.border][5],
		                                               bottom = BarBorders[config.border][6]
		                                    }
		})
	end
end




function STATUSBTN:OnClick(mousebutton)
	if mousebutton == "RightButton" then
		if self.config.sbType == "xp" then
			self:xpDropDown_Initialize()
		elseif self.config.sbType == "rep" then
			self:repDropDown_Initialize()
		end
	end
end




function STATUSBTN:OnEnter()

	if self.config.mIndex > 1 then
		self.elements.SB.cText:Hide()
		self.elements.SB.lText:Hide()
		self.elements.SB.rText:Hide()
		self.elements.SB.mText:Show()
		self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))
	end

	if self.config.tIndex > 1 then

		if self.bar then

			if self.bar.data.tooltipsCombat and InCombatLockdown() then
				return
			end

			if self.bar.data.tooltips then

				if self.bar.data.tooltipsEnhanced then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				else
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				end

				GameTooltip:SetText(self.elements.SB.tFunc(self.elements.SB) or "", self.tColor[1] or 1, self.tColor[2] or 1, self.tColor[3] or 1, self.tColor[4] or 1)
				GameTooltip:Show()
			end
		end
	end
end




function STATUSBTN:OnLeave()

	if self.config.mIndex > 1 then
		self.elements.SB.cText:Show()
		self.elements.SB.lText:Show()
		self.elements.SB.rText:Show()
		self.elements.SB.mText:Hide()
		self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
		self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))
		self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))
	end

	if self.config.tIndex > 1 then
		GameTooltip:Hide()
	end
end




function STATUSBTN:UpdateWidth(command, gui, query, skipupdate)

	if query then
		return self.config.width
	end

	local width = tonumber(command)

	if width and width >= 10 then

		self.config.width = width

		self:SetWidth(self.config.width)

		self.bar:SetObjectLoc()

		self.bar:SetPerimeter()

		self.bar:SetSize()

		if not skipupdate then
			Neuron.NeuronGUI:Status_UpdateEditor()
			self.bar:Update()
		end
	end
end




function STATUSBTN:UpdateHeight(command, gui, query, skipupdate)

	if query then
		return self.config.height
	end

	local height = tonumber(command)

	if height and height >= 4 then

		self.config.height = height

		self:SetHeight(self.config.height)

		self.bar:SetObjectLoc()

		self.bar:SetPerimeter()

		self.bar:SetSize()

		if not skipupdate then
			Neuron.NeuronGUI:Status_UpdateEditor()
			self.bar:Update()
		end
	end
end




function STATUSBTN:UpdateBarFill(command, gui, query, skipupdate)

	if query then
		return BarTextures[self.config.texture][3]
	end

	local index = tonumber(command)

	if index and BarTextures[index] then

		self.config.texture = index

		self.elements.SB:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.elements.FBFrame.feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])

		if not skipupdate then
			Neuron.NeuronGUI:Status_UpdateEditor()
		end

	end

end




function STATUSBTN:UpdateBorder(command, gui, query, skipupdate)

	if query then
		return BarBorders[self.config.border][1]
	end

	local index = tonumber(command)

	if index and BarBorders[index] then

		self.config.border = index

		self:SetBorder(self.elements.SB, self.config, self.bordercolor)
		self:SetBorder(self.elements.FBFrame.feedback, self.config, self.bordercolor)

		if not skipupdate then
			Neuron.NeuronGUI:Status_UpdateEditor()
		end
	end
end




function STATUSBTN:UpdateOrientation(orientationIndex, gui, query, skipupdate)

	if query then
		return BarOrientations[self.config.orientation]
	end

	orientationIndex = tonumber(orientationIndex)

	if orientationIndex then

		--only update if we're changing, not staying the same
		if self.config.orientation ~= orientationIndex then

			self.config.orientation = orientationIndex
			self.elements.SB.orientation = self.config.orientation

			self.elements.SB:SetOrientation(BarOrientations[self.config.orientation]:lower())
			self.elements.FBFrame.feedback:SetOrientation(BarOrientations[self.config.orientation]:lower())

			if self.config.orientation == 2 then
				self.elements.SB.cText:SetAlpha(0)
				self.elements.SB.lText:SetAlpha(0)
				self.elements.SB.rText:SetAlpha(0)
				self.elements.SB.mText:SetAlpha(0)
			else
				self.elements.SB.cText:SetAlpha(1)
				self.elements.SB.lText:SetAlpha(1)
				self.elements.SB.rText:SetAlpha(1)
				self.elements.SB.mText:SetAlpha(1)
			end


			local newWidth = self.config.height
			local newHeight = self.config.width

			self.config.height = newHeight
			self.config.width = newWidth

			self:SetWidth(self.config.width)

			self:SetHeight(self.config.height)

			self.bar:SetObjectLoc()

			self.bar:SetPerimeter()

			self.bar:SetSize()

			if not skipupdate then
				Neuron.NeuronGUI:Status_UpdateEditor()
				self.bar:Update()
			end

		end
	end
end




function STATUSBTN:UpdateCenterText(command, gui, query)

	if not sbStrings[self.config.sbType] then
		return "---"
	end

	if query then
		return sbStrings[self.config.sbType][self.config.cIndex][1]
	end

	local index = tonumber(command)

	if index then

		self.config.cIndex = index

		if sbStrings[self.config.sbType] then
			self.elements.SB.cFunc = sbStrings[self.config.sbType][self.config.cIndex][2]
		else
			self.elements.SB.cFunc = function() return "" end
		end

		self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
	end
end




function STATUSBTN:UpdateLeftText(command, gui, query)

	if not sbStrings[self.config.sbType] then
		return "---"
	end

	if query then
		return sbStrings[self.config.sbType][self.config.lIndex][1]
	end

	local index = tonumber(command)

	if index then

		self.config.lIndex = index

		if sbStrings[self.config.sbType] then
			self.elements.SB.lFunc = sbStrings[self.config.sbType][self.config.lIndex][2]
		else
			self.elements.SB.lFunc = function() return "" end
		end

		self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))

	end
end




function STATUSBTN:UpdateRightText(command, gui, query)

	if not sbStrings[self.config.sbType] then
		return "---"
	end

	if query then
		return sbStrings[self.config.sbType][self.config.rIndex][1]
	end

	local index = tonumber(command)

	if index then

		self.config.rIndex = index

		if sbStrings[self.config.sbType] and self.config.rIndex then
			self.elements.SB.rFunc = sbStrings[self.config.sbType][self.config.rIndex][2]
		else
			self.elements.SB.rFunc = function() return "" end
		end

		self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))

	end
end




function STATUSBTN:UpdateMouseover(command, gui, query)

	if not sbStrings[self.config.sbType] then
		return "---"
	end

	if query then
		return sbStrings[self.config.sbType][self.config.mIndex][1]
	end

	local index = tonumber(command)

	if index then

		self.config.mIndex = index

		if sbStrings[self.config.sbType] then
			self.elements.SB.mFunc = sbStrings[self.config.sbType][self.config.mIndex][2]
		else
			self.elements.SB.mFunc = function() return "" end
		end

		self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))
	end
end




function STATUSBTN:UpdateTooltip(command, gui, query)

	if not sbStrings[self.config.sbType] then
		return "---"
	end

	if query then
		return sbStrings[self.config.sbType][self.config.tIndex][1]
	end

	local index = tonumber(command)

	if index then

		self.config.tIndex = index

		if sbStrings[self.config.sbType] then
			self.elements.SB.tFunc = sbStrings[self.config.sbType][self.config.tIndex][2]
		else
			self.elements.SB.tFunc = function() return "" end
		end
	end
end




function STATUSBTN:UpdateUnit(command, gui, query)

	if query then
		return BarUnits[self.data.unit]
	end

	local index = tonumber(command)

	if index then

		self.data.unit = index

		self.elements.SB.unit = BarUnits[self.data.unit]

	end
end




function STATUSBTN:UpdateCastIcon(frame, checked)

	if checked then
		self.config.showIcon = true
	else
		self.config.showIcon = false
	end

	self.elements.SB.showIcon = self.config.showIcon

end




function STATUSBTN:ChangeStatusBarType()

	if self.config.sbType == "xp" then
		self.config.sbType = "rep"
		self.config.cIndex = 2
		self.config.lIndex = 1
		self.config.rIndex = 1
	elseif self.config.sbType == "rep" then
		self.config.sbType = "cast"
		self.config.cIndex = 1
		self.config.lIndex = 2
		self.config.rIndex = 3
	elseif self.config.sbType == "cast" then
		self.config.sbType = "mirror"
		self.config.cIndex = 1
		self.config.lIndex = 2
		self.config.rIndex = 3
	else
		self.config.sbType = "xp"
		self.config.cIndex = 2
		self.config.lIndex = 1
		self.config.rIndex = 1
	end

	self:SetType()
end



function STATUSBTN:SetData(bar)

	if bar then

		self.bar = bar
		self.alpha = bar.data.alpha
		self.showGrid = bar.data.showGrid

		self:SetFrameStrata(bar.data.objectStrata)
		self:SetScale(bar.data.scale)

	end

	self:SetWidth(self.config.width)
	self:SetHeight(self.config.height)

	self.bordercolor = { (";"):split(self.config.bordercolor) }

	self.cColor = { (";"):split(self.config.cColor) }
	self.lColor = { (";"):split(self.config.lColor) }
	self.rColor = { (";"):split(self.config.rColor) }
	self.mColor = { (";"):split(self.config.mColor) }
	self.tColor = { (";"):split(self.config.tColor) }

	self.elements.SB.parent = self

	self.elements.SB.cText:SetTextColor(self.cColor[1], self.cColor[2], self.cColor[3], self.cColor[4])
	self.elements.SB.lText:SetTextColor(self.lColor[1], self.lColor[2], self.lColor[3], self.lColor[4])
	self.elements.SB.rText:SetTextColor(self.rColor[1], self.rColor[2], self.rColor[3], self.rColor[4])
	self.elements.SB.mText:SetTextColor(self.mColor[1], self.mColor[2], self.mColor[3], self.mColor[4])

	if sbStrings[self.config.sbType] then

		if not sbStrings[self.config.sbType][self.config.cIndex] then
			self.config.cIndex = 1
		end
		self.elements.SB.cFunc = sbStrings[self.config.sbType][self.config.cIndex][2]

		if not sbStrings[self.config.sbType][self.config.lIndex] then
			self.config.lIndex = 1
		end
		self.elements.SB.lFunc = sbStrings[self.config.sbType][self.config.lIndex][2]

		if not sbStrings[self.config.sbType][self.config.rIndex] then
			self.config.rIndex = 1
		end
		self.elements.SB.rFunc = sbStrings[self.config.sbType][self.config.rIndex][2]

		if not sbStrings[self.config.sbType][self.config.mIndex] then
			self.config.mIndex = 1
		end
		self.elements.SB.mFunc = sbStrings[self.config.sbType][self.config.mIndex][2]

		if not sbStrings[self.config.sbType][self.config.tIndex] then
			self.config.tIndex = 1
		end
		self.elements.SB.tFunc = sbStrings[self.config.sbType][self.config.tIndex][2]

	else
		self.elements.SB.cFunc = function() return "" end
		self.elements.SB.lFunc = function() return "" end
		self.elements.SB.rFunc = function() return "" end
		self.elements.SB.mFunc = function() return "" end
		self.elements.SB.tFunc = function() return "" end
	end

	self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
	self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))
	self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))
	self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))

	self.elements.SB.norestColor = { (";"):split(self.config.norestColor) }
	self.elements.SB.restColor = { (";"):split(self.config.restColor) }

	self.elements.SB.castColor = { (";"):split(self.config.castColor) }
	self.elements.SB.channelColor = { (";"):split(self.config.channelColor) }
	self.elements.SB.successColor = { (";"):split(self.config.successColor) }
	self.elements.SB.failColor = { (";"):split(self.config.failColor) }

	self.elements.SB.orientation = self.config.orientation
	self.elements.SB:SetOrientation(BarOrientations[self.config.orientation]:lower())
	self.elements.FBFrame.feedback:SetOrientation(BarOrientations[self.config.orientation]:lower())

	if self.config.orientation == 2 then
		self.elements.SB.cText:SetAlpha(0)
		self.elements.SB.lText:SetAlpha(0)
		self.elements.SB.rText:SetAlpha(0)
		self.elements.SB.mText:SetAlpha(0)
	else
		self.elements.SB.cText:SetAlpha(1)
		self.elements.SB.lText:SetAlpha(1)
		self.elements.SB.rText:SetAlpha(1)
		self.elements.SB.mText:SetAlpha(1)
	end

	if BarTextures[self.config.texture] then
		self.elements.SB:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.elements.FBFrame.feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
	else
		self.elements.SB:SetStatusBarTexture(BarTextures[1][self.config.orientation])
		self.elements.FBFrame.feedback:SetStatusBarTexture(BarTextures[1][self.config.orientation])
	end

	self:SetBorder(self.elements.SB, self.config, self.bordercolor)
	self:SetBorder(self.elements.FBFrame.feedback, self.config, self.bordercolor)

	self:SetFrameLevel(4)

	self.elements.FBFrame:SetFrameLevel(self:GetFrameLevel()+10)
	self.elements.FBFrame.feedback:SetFrameLevel(self.elements.SB:GetFrameLevel()+10)
	self.elements.FBFrame.feedback.bg:SetFrameLevel(self.elements.SB.bg:GetFrameLevel()+10)
	self.elements.FBFrame.feedback.border:SetFrameLevel(self.elements.SB.border:GetFrameLevel()+10)

end

function STATUSBTN:UpdateObjectVisibility(show)
	if show then
		self.editmode = true
		self.elements.FBFrame:Show()
	else
		self.editmode = nil
		self.elements.FBFrame:Hide()
	end
end

function STATUSBTN:StatusBar_Reset()

	self:RegisterForClicks("")
	self:SetScript("OnClick", function() end)
	self:SetScript("OnEnter", function() end)
	self:SetScript("OnLeave", function() end)
	self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

	self.elements.SB:UnregisterAllEvents()
	self.elements.SB:SetScript("OnUpdate", function() end)
	self.elements.SB:SetScript("OnShow", function() end)
	self.elements.SB:SetScript("OnHide", function() end)

	self.elements.SB.unit = nil
	self.elements.SB.rep = nil
	self.elements.SB.showIcon = nil

	self.elements.SB.cbtimer:UnregisterAllEvents()

	for index, sb in ipairs(MirrorBars) do
		if sb == self.elements.SB then
			table.remove(MirrorBars, index)
		end
	end
end



function STATUSBTN:SetType()

	if InCombatLockdown() then
		return
	end

	self:StatusBar_Reset()

	if self.config.sbType == "cast" then

		self:RegisterEvent("UNIT_SPELLCAST_START", "CastBar_OnEvent")
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "CastBar_OnEvent")
		self:RegisterEvent("UNIT_SPELLCAST_FAILED", "CastBar_OnEvent")
		self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "CastBar_OnEvent")
		self:RegisterEvent("UNIT_SPELLCAST_DELAYED", "CastBar_OnEvent")
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", "CastBar_OnEvent")
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "CastBar_OnEvent")
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "CastBar_OnEvent")

		if not Neuron.isWoWClassic then
			self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "CastBar_OnEvent")
			self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "CastBar_OnEvent")
		end

		self.elements.SB.unit = BarUnits[self.data.unit]
		self.elements.SB.showIcon = self.config.showIcon

		self.elements.SB.casting = false
		self.elements.SB.channeling = false
		self.elements.SB.holdTime = 0

		self:SetScript("OnUpdate", function(self, elapsed) self:CastBar_OnUpdate(elapsed) end)

		if not self.elements.SB.cbtimer.castInfo then
			self.elements.SB.cbtimer.castInfo = {}
		else
			wipe(self.elements.SB.cbtimer.castInfo)
		end

		self.elements.SB:Hide()

	elseif self.config.sbType == "xp" then

		self:SetAttribute("hasaction", true)

		self:RegisterForClicks("RightButtonUp")
		self:SetScript("OnClick", function(self, mousebutton, down) self:OnClick(mousebutton, down) end)
		self:SetScript("OnEnter", function(self) self:OnEnter() end)
		self:SetScript("OnLeave", function(self) self:OnLeave() end)
		self:SetHitRectInsets(0, 0, 0, 0)

		self:RegisterEvent("PLAYER_XP_UPDATE", "XPBar_OnEvent")

		self:RegisterEvent("UPDATE_EXHAUSTION", "XPBar_OnEvent")
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "XPBar_OnEvent")
		self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "XPBar_OnEvent")

		if not Neuron.isWoWClassic then
			self:RegisterEvent("HONOR_XP_UPDATE", "XPBar_OnEvent")
			self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", "XPBar_OnEvent")
		end

		self.elements.SB:Show()

	elseif self.config.sbType == "rep" then

		self.elements.SB.repID = self.data.repID

		self:SetAttribute("hasaction", true)

		self:RegisterForClicks("RightButtonUp")
		self:SetScript("OnClick", function(self, mousebutton, down) self:OnClick(mousebutton, down) end)
		self:SetScript("OnEnter", function(self) self:OnEnter() end)
		self:SetScript("OnLeave", function(self) self:OnLeave() end)
		self:SetHitRectInsets(0, 0, 0, 0)

		self:RegisterEvent("UPDATE_FACTION", "repbar_OnEvent")
		self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "repbar_OnEvent")
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "repbar_OnEvent")

		self.elements.SB:Show()

	elseif self.config.sbType == "mirror" then

		self:RegisterEvent("MIRROR_TIMER_START", "MirrorBar_OnEvent")
		self:RegisterEvent("MIRROR_TIMER_STOP", "MirrorBar_OnEvent")
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "MirrorBar_OnEvent")

		self:SetScript("OnUpdate", function(self, elapsed) self:MirrorBar_OnUpdate(elapsed) end)

		table.insert(MirrorBars, self)

		self.elements.SB:Hide()

	end

	local typeString

	if self.config.sbType == "xp" then
		typeString = L["XP Bar"]
	elseif self.config.sbType == "rep" then
		typeString = L["Rep Bar"]
	elseif self.config.sbType == "cast" then
		typeString = L["Cast Bar"]
	elseif self.config.sbType == "mirror" then
		typeString = L["Mirror Bar"]
	end

	self.elements.FBFrame.feedback.text:SetText(typeString)

	self:SetData(self.bar)
end

--------------------------------------------------------------
---------------------- Overrides -----------------------------
--------------------------------------------------------------

--overrides the parent function so we don't error out
function STATUSBTN:UpdateUsable()
	-- empty --
end

--overrides the parent function so we don't error out
function STATUSBTN:UpdateIcon()
	-- empty --
end

--overrides the parent function so we don't error out
function STATUSBTN:UpdateStatus()
	-- empty --
end

--overrides the parent function so we don't error out
function STATUSBTN:UpdateCount()
	-- empty --
end

--overrides the parent function so we don't error out
function STATUSBTN:UpdateCooldown()
	-- empty --
end