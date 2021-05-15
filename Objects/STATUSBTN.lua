-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

---@class STATUSBTN : BUTTON @define class STATUSBTN inherits from class BUTTON
local STATUSBTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.STATUSBTN = STATUSBTN


local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local CastWatch, RepWatch, MirrorWatch, MirrorBars = {}, {}, {}, {}

local sbStrings = {
	cast = {
		[1] = { L["None"], function() return "" end },
		[2] = { L["Spell"], function(self) if CastWatch[self.unit] then return CastWatch[self.unit].spell end end },
		[3] = { L["Timer"], function(self) if CastWatch[self.unit] then return CastWatch[self.unit].timer end end },
	},
	xp = {
		[1] = { L["None"], function() return "" end },
		[2] = { L["Current/Next"], function(self) if self.XPWatch then return self.XPWatch.current end end },
		[3] = { L["Rested Levels"], function(self) if self.XPWatch then return self.XPWatch.rested end end },
		[4] = { L["Percent"], function(self) if self.XPWatch then return self.XPWatch.percent end end },
		[5] = { L["Bubbles"], function(self) if self.XPWatch then return self.XPWatch.bubbles end end },
		[6] = { L["Current Level/Rank"], function(self) if self.XPWatch then return self.XPWatch.rank end end },
	},
	rep = {
		[1] = { L["None"], function() return "" end },
		[2] = { L["Faction"], function(self) if RepWatch[self.repID] then return RepWatch[self.repID].name end end }, --TODO:should probably do the same as above here, just in case people have more than 1 rep bar
		[3] = { L["Current/Next"], function(self) if RepWatch[self.repID] then return RepWatch[self.repID].current end end },
		[4] = { L["Percent"], function(self) if RepWatch[self.repID] then return RepWatch[self.repID].percent end end },
		[5] = { L["Bubbles"], function(self) if RepWatch[self.repID] then return RepWatch[self.repID].bubbles end end },
		[6] = { L["Current Level/Rank"], function(self) if RepWatch[self.repID] then return RepWatch[self.repID].standing end end},
	},
	mirror = {
		[1] = { L["None"], function() return "" end },
		[2] = { L["Type"], function(self) if MirrorWatch[self.mirror] then return MirrorWatch[self.mirror].label end end },
		[3] = { L["Timer"], function(self) if MirrorWatch[self.mirror] then return MirrorWatch[self.mirror].timer end end },
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

	local currXP, nextXP, restedXP, percentXP, bubbles, rank, isRested

	--player xp option
	if self.curXPType == "player_xp" then

		currXP, nextXP, restedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		local playerLevel = UnitLevel("player")

		if playerLevel == MAX_PLAYER_LEVEL then
			currXP = nextXP
		end

		percentXP = (currXP/nextXP)*100;
		bubbles = tostring(math.floor(currXP/(nextXP/20))).." / 20 "..L["Bubbles"]
		percentXP = string.format("%.2f", (percentXP)).."%"

		if restedXP and restedXP > 0 then
			restedXP = string.format("%.2f", (tostring(restedXP/nextXP))).." "..L["Levels"]
			isRested = true
		else
			restedXP = "0".." "..L["Levels"]
			isRested = false
		end

		rank = L["Level"].." "..tostring(playerLevel)

		--covenant renown
	elseif self.curXPType == "covenant_renown" then
		if C_Covenants.GetActiveCovenantID() ~= 0 then
			local covenantLevel = C_CovenantSanctumUI.GetRenownLevel(C_Covenants.GetActiveCovenantID())
			local covenantName = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID()).name
			rank = covenantName..": "..L["Level"].." "..covenantLevel
		end

		--heart of azeroth option
	elseif self.curXPType == "azerite_xp" then
		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
		if azeriteItemLocation then
			currXP, nextXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
			restedXP = "0".." "..L["Levels"]
			local percent = (currXP/nextXP)*100
			percentXP = string.format("%.2f", percent).."%" --format
			bubbles = tostring(math.floor(percent/5)).." / 20 "..L["Bubbles"]
			rank = L["Level"].." "..tostring(C_AzeriteItem.GetPowerLevel(azeriteItemLocation))
		end

		--honor points option
	elseif self.curXPType == "honor_points" then
		currXP = UnitHonor("player"); -- current value for level
		nextXP = UnitHonorMax("player"); -- max value for level

		local level = UnitHonorLevel("player");
		percentXP = (currXP/nextXP)*100
		bubbles = tostring(math.floor(percentXP/5)).." / 20 "..L["Bubbles"];
		percentXP = string.format("%.2f", percentXP).."%"; --format
		rank = L["Level"].." "..tostring(level)

	end

	if not self.XPWatch then --make sure we make the table for us to store our data so we aren't trying to index a non existent table
		self.XPWatch = {}
	end

	if currXP and nextXP then
		self.XPWatch.current = BreakUpLargeNumbers(currXP).." / "..BreakUpLargeNumbers(nextXP)
	else
		self.XPWatch.current = ""
	end

	if restedXP then
		self.XPWatch.rested = restedXP
	else
		self.XPWatch.rested = ""
	end

	if percentXP then
		self.XPWatch.percent = percentXP
	else
		self.XPWatch.percent = ""
	end

	if bubbles then
		self.XPWatch.bubbles = bubbles
	else
		self.XPWatch.bubbles = ""
	end

	if rank then
		self.XPWatch.rank = rank
	else
		self.XPWatch.rank = ""
	end

	return currXP, nextXP, isRested
end


function STATUSBTN:XPBar_OnEvent(event, ...)

	if not self.DB.curXPType then
		self.DB.curXPType = "player_xp" --sets the default state of the XP bar to be player_xp
	end

	self.curXPType = self.DB.curXPType

	local currXP, nextXP, isRested
	local hasChanged = false;


	if self.curXPType == "player_xp" and (event=="PLAYER_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event=="UPDATE_EXHAUSTION" or event =="changed_curXPType") then
		currXP, nextXP, isRested = self:xpstrings_Update()
		if isRested or UnitLevel("player") == MAX_PLAYER_LEVEL then --don't show rested XP as exhausted if we are max level
			self.StatusBar:SetStatusBarColor(0.0, 0.39, 0.88, 1.0) --blue color
		else
			self.StatusBar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0) --deep purple color
		end
		hasChanged = true;
	end

	if self.curXPType == "covenant_renown" and (event == "COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED" or event =="PLAYER_ENTERING_WORLD" or event =="changed_curXPType") then
		currXP, nextXP = self:xpstrings_Update()
		local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID())
		local covenantColor = COVENANT_COLORS[covenantData.textureKit]
		self.StatusBar:SetStatusBarColor(covenantColor:GetRGB())
		hasChanged = true
	end

	if self.curXPType == "azerite_xp" and (event =="AZERITE_ITEM_EXPERIENCE_CHANGED" or event =="PLAYER_ENTERING_WORLD" or event =="PLAYER_EQUIPMENT_CHANGED" or event =="changed_curXPType") then
		currXP, nextXP = self:xpstrings_Update()
		self.StatusBar:SetStatusBarColor(ARTIFACT_BAR_COLOR:GetRGB()) --set to pale yellow
		hasChanged = true
	end

	if self.curXPType == "honor_points" and (event=="HONOR_XP_UPDATE" or event =="PLAYER_ENTERING_WORLD" or event =="changed_curXPType") then
		currXP, nextXP = self:xpstrings_Update()
		self.StatusBar:SetStatusBarColor(1.0, 0.24, 0) --set to red
		hasChanged = true
	end

	if hasChanged == true then
		self.StatusBar:SetMinMaxValues(0, 100) --these are for the bar itself, the progress it has from left to right
		if currXP and nextXP then
			self.StatusBar:SetValue((currXP/nextXP)*100)
		else
			self.StatusBar:SetValue(100)
		end
		self.StatusBar.CenterText:SetText(self:cFunc())
		self.StatusBar.LeftText:SetText(self:lFunc())
		self.StatusBar.RightText:SetText(self:rFunc())
		self.StatusBar.MouseoverText:SetText(self:mFunc())
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
		checked = self.curXPType == "player_xp",
	})

	--wow classic doesn't have Honor points nor Azerite, carefull
	if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC then

		if C_Covenants.GetActiveCovenantID() ~= 0 then
			table.insert(menu, {
				arg1 = self,
				arg2 = "covenant_renown",
				text = L["Track Covenant Renown"],
				func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end,
				checked = self.curXPType == "covenant_renown",
			})
		end

		--add Heart of Azeroth option
		local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem()
		if azeriteItem and azeriteItem:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItem) then --only show this button if they player has the Heart of Azeroth
			table.insert(menu, {
				arg1 = self,
				arg2 = "azerite_xp",
				text = L["Track Azerite Power"],
				func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end,
				checked = self.curXPType == "azerite_xp",
			})
		end

		--add PvP Honor option
		table.insert(menu, {
			arg1 = self,
			arg2 = "honor_points",
			text = L["Track Honor Points"],
			func = function(dropdown, self, newXPType) self:switchCurXPType(newXPType) end,
			checked = self.curXPType == "honor_points",
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
function STATUSBTN:SetRepWatch(ID, name, standing, header, minrep, maxrep, value, colors)
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
			if header == "Guild" then --the "Guild" category is kinda stupid to just have alone, so we should override it with "Other"
				header = "Other"
			end
		end

		if (not isHeader or hasRep) and not IsFactionInactive(i) then

			local friendID, standing, isParagon
			if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC  then --classic doesn't have Friendships or Paragon, carefull
				friendID, _, _, _, _, _, standing, _, _ = GetFriendshipReputation(factionID)
				isParagon = C_Reputation.IsFactionParagon(factionID)
			end

			if not friendID then --not a "Friendship" faction, i.e. Chromie or Brawlers Guild
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
					colors.r, colors.g, colors.b = BAR_REP_DATA[standingID].r, BAR_REP_DATA[standingID].g, BAR_REP_DATA[standingID].b
				else
					if standingID + 2 > 8 then
						standingID = 6
					end
					colors.r, colors.g, colors.b = BAR_REP_DATA[standingID+2].r, BAR_REP_DATA[standingID+2].g, BAR_REP_DATA[standingID+2].b --offset by two, because friendships don't have "hated" or "hostile" ranks
				end
			end

			local repData = self:SetRepWatch(i, name, standing, header, min, max, value, colors)

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

	if RepWatch[self.repID] then
		self.StatusBar:SetStatusBarColor(RepWatch[self.repID].r,  RepWatch[self.repID].g, RepWatch[self.repID].b)
		self.StatusBar:SetMinMaxValues(RepWatch[self.repID].min, RepWatch[self.repID].max)
		self.StatusBar:SetValue(RepWatch[self.repID].value)
	else
		self.StatusBar:SetStatusBarColor(0.5,  0.5, 0.5)
		self.StatusBar:SetMinMaxValues(0, 1)
		self.StatusBar:SetValue(1)
	end

	self.StatusBar.CenterText:SetText(self:cFunc())
	self.StatusBar.LeftText:SetText(self:lFunc())
	self.StatusBar.RightText:SetText(self:rFunc())
	self.StatusBar.MouseoverText:SetText(self:mFunc())
end


function STATUSBTN:repDropDown_Initialize() --Initialize the dropdown menu for choosing a rep

	if not self.StatusBar then
		return
	end

	local repDataTable = {}

	for k,v in pairs(RepWatch) do --insert all factions and percentages into "data"
		if k > 0 then --skip the "0" entry which is our autowatch
			if not repDataTable[v.header]then
				repDataTable[v.header] = {}
			end
			table.insert(repDataTable[v.header], { ID=v.ID, name=v.name, standing=v.standing, percent=v.percent, hex=v.hex})
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
			self.repID = dropdown.value
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
					self.repID = dropdown.value
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
	local SORT_TABLE = {
		["Shadowlands"] = 1,
		["Battle for Azeroth"]=2,
		["Legion"]=3,
		["Warlords of Draenor"]=4,
		["Mists of Pandaria"]=5,
		["Cataclysm"]=6,
		["Wrath of the Lich King"]=7,
		["The Burning Crusade"]=8,
		["Classic"]=9,
		["Guild"]=10,
		["Other"]=11
	}
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

			mbar.mirror = type
			mbar.value = (value / 1000)
			mbar.maxvalue = (maxvalue / 1000)
			mbar.scale = scale

			if  paused > 0  then
				mbar.paused = 1
			else
				mbar.paused = nil
			end

			local color = MirrorTimerColors[type]

			mbar.StatusBar:SetMinMaxValues(0, (maxvalue / 1000))
			mbar.StatusBar:SetValue(mbar.value)
			mbar.StatusBar:SetStatusBarColor(color.r, color.g, color.b)

			mbar.StatusBar:SetAlpha(1)
			mbar.StatusBar:Show()
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

			mbar.mirror = nil
		end
	end
end





function STATUSBTN:CastBar_FinishSpell()

	self.StatusBar.Spark:Hide()
	self.StatusBar.BarFlash:SetAlpha(0.0)
	self.StatusBar.BarFlash:Show()
	self.flash = 1
	self.fadeOut = 1
	self.casting = false
	self.channeling = false
end





function STATUSBTN:CastBar_Reset()

	self.fadeOut = 1
	self.casting = false
	self.channeling = false
	self.StatusBar:SetStatusBarColor(self.castColor[1], self.castColor[2], self.castColor[3], self.castColor[4])

	if not self.editmode then
		self.StatusBar:Hide()
	end
end





function STATUSBTN:CastBar_OnEvent(event, ...)

	local unit = select(1, ...)
	local eventCastID = select(2,...)--return payload is "unitTarget", "castGUID", spellID

	if unit ~= self.unit then
		return
	end

	if not CastWatch[unit]  then
		CastWatch[unit] = {}
	end

	if event == "UNIT_SPELLCAST_START" then

		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible

		if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC then
			name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
		elseif unit == "player" then
			name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = CastingInfo() --classic doesn't have UnitCastingInfo()
		end

		if not name then
			self:CastBar_Reset()
			return
		end

		self.StatusBar:SetStatusBarColor(self.castColor[1], self.castColor[2], self.castColor[3], self.castColor[4])

		if self.StatusBar.Spark then
			self.StatusBar.Spark:SetTexture("Interface\\AddOns\\Neuron\\Images\\CastingBar_Spark_"..self.orientation)
			self.StatusBar.Spark:Show()
		end

		self.value = (GetTime()-(startTime/1000))
		self.maxValue = (endTime-startTime)/1000
		self.StatusBar:SetMinMaxValues(0, self.maxValue)
		self.StatusBar:SetValue(self.value)

		self.totalTime = self.maxValue - self.StatusBar:GetValue()

		CastWatch[unit].spell = text

		if self.showIcon then

			self.StatusBar.Icon:SetTexture(texture)
			self.StatusBar.Icon:Show()

			if notInterruptible then
				self.StatusBar.Shield:Show()
			else
				self.StatusBar.Shield:Hide()
			end

		else
			self.StatusBar.Icon:Hide()
			self.StatusBar.Shield:Hide()
		end

		self.StatusBar:SetAlpha(1.0)
		self.holdTime = 0
		self.casting = true
		self.castID = castID
		self.channeling = false
		self.fadeOut = nil

		self.StatusBar:Show()

		--update castbar text
		if not self.castInfo[unit] then
			self.castInfo[unit] = {}
		end

		self.castInfo[unit][1] = text
		self.castInfo[unit][2] = "%0.1f"

	elseif event == "UNIT_SPELLCAST_CHANNEL_START" then

		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible

		if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC then
			name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)
		elseif unit == "player" then
			name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = ChannelInfo()
		end

		if not name then
			self:CastBar_Reset()
			return
		end

		self.StatusBar:SetStatusBarColor(self.channelColor[1], self.channelColor[2], self.channelColor[3], self.channelColor[4])

		self.value = ((endTime/1000)-GetTime())
		self.maxValue = (endTime - startTime) / 1000;
		self.StatusBar:SetMinMaxValues(0, self.maxValue);
		self.StatusBar:SetValue(self.value)

		CastWatch[unit].spell = text

		if self.showIcon then

			self.StatusBar.Icon:SetTexture(texture)
			self.StatusBar.Icon:Show()

			if notInterruptible then
				self.StatusBar.Shield:Show()
			else
				self.StatusBar.Shield:Hide()
			end

		else
			self.StatusBar.Icon:Hide()
			self.StatusBar.Shield:Hide()
		end

		if self.StatusBar.Spark then
			self.StatusBar.Spark:Hide()
		end

		self.StatusBar:SetAlpha(1.0)
		self.holdTime = 0
		self.casting = false
		self.channeling = true
		self.fadeOut = nil

		self.StatusBar:Show()

		--update text on castbar
		if not self.castInfo[unit] then
			self.castInfo[unit] = {}
		end

		self.castInfo[unit][1] = text
		self.castInfo[unit][2] = "%0.1f"


	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and not self.channeling then --don't do anything with this event when channeling as it fires at each pulse of a spell channel

		self.StatusBar:SetStatusBarColor(self.successColor[1], self.successColor[2], self.successColor[3], self.successColor[4])

	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and self.channeling then

		-- do nothing (when Tranquility is channeling if reports UNIT_SPELLCAST_SUCCEEDED many times during the duration)

	elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") and self.castID == eventCastID or event == "UNIT_SPELLCAST_CHANNEL_STOP"  then

		if self.StatusBar:IsShown() and (self.casting or self.channeling) and not self.fadeOut then

			self.StatusBar:SetValue(self.maxValue)

			self.StatusBar:SetStatusBarColor(self.failColor[1], self.failColor[2], self.failColor[3], self.failColor[4])

			if self.StatusBar.Spark then
				self.StatusBar.Spark:Hide()
			end

			if event == "UNIT_SPELLCAST_FAILED" then
				CastWatch[unit].spell = FAILED
			else
				CastWatch[unit].spell = INTERRUPTED
			end

			self.casting = false
			self.channeling = false
			self.fadeOut = 1
			self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
		end

	elseif event == "UNIT_SPELLCAST_DELAYED" then

		if self.StatusBar:IsShown() then

			local name, text, texture, startTime, endTime, isTradeSkill

			if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC then
				name, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)
			elseif unit == "player" then
				name, text, texture, startTime, endTime, isTradeSkill = CastingInfo() --Classic doesn't have UnitCastingInfo()
			end

			if not name then
				self:CastBar_Reset()
				return
			end

			self.value = (GetTime()-(startTime/1000))
			self.maxValue = (endTime-startTime)/1000
			self.StatusBar:SetMinMaxValues(0, self.maxValue)

			if not self.casting then

				self.StatusBar:SetStatusBarColor(self.castColor[1], self.castColor[2], self.castColor[3], self.castColor[4])

				self.StatusBar.Spark:Show()
				self.StatusBar.BarFlash:SetAlpha(0.0)
				self.StatusBar.BarFlash:Hide()

				self.casting = true
				self.channeling = false
				self.flash = 0
				self.fadeOut = 0
			end
		end

	elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then

		if self.StatusBar:IsShown() then

			local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible

			if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC then
				name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)
			elseif unit == "player" then
				name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = ChannelInfo()
			end


			if not name then
				self:CastBar_Reset()
				return
			end

			self.value = ((endTime/1000)-GetTime())
			self.maxValue = (endTime-startTime)/1000
			self.StatusBar:SetMinMaxValues(0, self.maxValue)
			self.StatusBar:SetValue(self.value)
		end

	elseif self.showShield and event == "UNIT_SPELLCAST_INTERRUPTIBLE"  then

		self.StatusBar.Shield:Hide()

	elseif self.showShield and event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"  then

		self.StatusBar.Shield:Show()

	end


	self.StatusBar.CenterText:SetText(self:cFunc())
	self.StatusBar.LeftText:SetText(self:lFunc())
	self.StatusBar.RightText:SetText(self:rFunc())
	self.StatusBar.MouseoverText:SetText(self:mFunc())

end





function STATUSBTN:CastBar_OnUpdate(elapsed)

	local unit = self.unit
	local sparkPosition, alpha

	if unit then

		if self.castInfo[unit] then

			local displayName, numFormat = self.castInfo[unit][1], self.castInfo[unit][2]

			if self.maxValue then
				CastWatch[self.unit].timer = string.format(numFormat, self.value).."/"..format(numFormat, self.maxValue)
			else
				CastWatch[self.unit].timer = string.format(numFormat, self.value)
			end
		end

		if self.casting then

			self.value = self.value + elapsed

			if self.value >= self.maxValue then
				self.StatusBar:SetValue(self.maxValue)
				self:CastBar_FinishSpell()
				return
			end

			self.StatusBar:SetValue(self.value)

			self.StatusBar.BarFlash:Hide()

			if self.orientation == 1 then

				sparkPosition = (self.value/self.maxValue)*self.StatusBar:GetWidth()

				if sparkPosition < 0 then
					sparkPosition = 0
				end

				self.StatusBar.Spark:SetPoint("CENTER", self.StatusBar, "LEFT", sparkPosition, 0)

			else
				sparkPosition = (self.value / self.maxValue) * self.StatusBar:GetHeight()

				if  sparkPosition < 0  then
					sparkPosition = 0
				end

				self.StatusBar.Spark:SetPoint("CENTER", self.StatusBar, "BOTTOM", 0, sparkPosition)
			end

		elseif self.channeling then

			self.value = self.value - elapsed

			if self.value <= 0 then
				self:CastBar_FinishSpell()
				return
			end

			self.StatusBar:SetValue(self.value)

			self.StatusBar.BarFlash:Hide()

		elseif GetTime() < self.holdTime then

			return

		elseif self.flash then

			alpha = self.StatusBar.BarFlash:GetAlpha() + CASTING_BAR_FLASH_STEP or 0

			if alpha < 1 then
				self.StatusBar.BarFlash:SetAlpha(alpha)
			else
				self.StatusBar.BarFlash:SetAlpha(1.0)
				self.flash = nil
			end

		elseif self.fadeOut and not self.editmode then

			alpha = self.StatusBar:GetAlpha() - CASTING_BAR_ALPHA_STEP

			if alpha > 0 then
				self.StatusBar:SetAlpha(alpha)
			else
				self:CastBar_Reset()
			end
		end
	end

	self.StatusBar.CenterText:SetText(self:cFunc())
	self.StatusBar.LeftText:SetText(self:lFunc())
	self.StatusBar.RightText:SetText(self:rFunc())
	self.StatusBar.MouseoverText:SetText(self:mFunc())
end



function STATUSBTN:MirrorBar_OnUpdate(elapsed)

	if self.mirror then

		self.value = GetMirrorTimerProgress(self.mirror)/1000


		if self.value > self.maxvalue then

			self.alpha = self.StatusBar:GetAlpha() - CASTING_BAR_ALPHA_STEP

			if self.alpha > 0 then
				self.StatusBar:SetAlpha(self.alpha)
			else
				self.StatusBar:Hide()
			end

		else

			self.StatusBar:SetValue(self.value)

			if self.value >= 60 then
				self.value = string.format("%0.1f", self.value/60)
				self.value = self.value.."m"
			else
				self.value = string.format("%0.0f", self.value)
				self.value = self.value.."s"
			end

			MirrorWatch[self.mirror].timer = self.value

		end

	elseif not self.editmode then

		self.alpha = self.StatusBar:GetAlpha() - CASTING_BAR_ALPHA_STEP

		if self.alpha > 0 then
			self.StatusBar:SetAlpha(self.alpha)
		else
			self.StatusBar:Hide()
		end
	end

	self.StatusBar.CenterText:SetText(self:cFunc())
	self.StatusBar.LeftText:SetText(self:lFunc())
	self.StatusBar.RightText:SetText(self:rFunc())
	self.StatusBar.MouseoverText:SetText(self:mFunc())
end




function STATUSBTN:SetBorder(statusbutton, config, bordercolor)

	statusbutton.Border:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
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

	statusbutton.Border:SetPoint("TOPLEFT", BarBorders[config.border][9], BarBorders[config.border][10])
	statusbutton.Border:SetPoint("BOTTOMRIGHT", BarBorders[config.border][11], BarBorders[config.border][12])

	statusbutton.Border:SetBackdropColor(0, 0, 0, 0)
	statusbutton.Border:SetBackdropBorderColor(bordercolor[1], bordercolor[2], bordercolor[3], 1)
	statusbutton.Border:SetFrameLevel(self:GetFrameLevel()+1)

	statusbutton.Background:SetBackdropColor(0, 0, 0, 1)
	statusbutton.Background:SetBackdropBorderColor(0, 0, 0, 0)
	statusbutton.Background:SetFrameLevel(0)

	if statusbutton.BarFlash then
		statusbutton.BarFlash:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
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
		self.StatusBar.CenterText:Hide()
		self.StatusBar.LeftText:Hide()
		self.StatusBar.RightText:Hide()
		self.StatusBar.MouseoverText:Show()
		self.StatusBar.MouseoverText:SetText(self:mFunc())
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

				GameTooltip:SetText(self.tFunc(self.StatusBar) or "", self.tColor[1] or 1, self.tColor[2] or 1, self.tColor[3] or 1, self.tColor[4] or 1)
				GameTooltip:Show()
			end
		end
	end
end




function STATUSBTN:OnLeave()

	if self.config.mIndex > 1 then
		self.StatusBar.CenterText:Show()
		self.StatusBar.LeftText:Show()
		self.StatusBar.RightText:Show()
		self.StatusBar.MouseoverText:Hide()
		self.StatusBar.CenterText:SetText(self:cFunc())
		self.StatusBar.LeftText:SetText(self:lFunc())
		self.StatusBar.RightText:SetText(self:rFunc())
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

		self.StatusBar:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.Feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])

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

		self:SetBorder(self.StatusBar, self.config, self.bordercolor)
		self:SetBorder(self.Feedback, self.config, self.bordercolor)

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
			self.orientation = self.config.orientation

			self.StatusBar:SetOrientation(BarOrientations[self.config.orientation]:lower())
			self.Feedback:SetOrientation(BarOrientations[self.config.orientation]:lower())

			if self.config.orientation == 2 then
				self.StatusBar.CenterText:SetAlpha(0)
				self.StatusBar.LeftText:SetAlpha(0)
				self.StatusBar.RightText:SetAlpha(0)
				self.StatusBar.MouseoverText:SetAlpha(0)
			else
				self.StatusBar.CenterText:SetAlpha(1)
				self.StatusBar.LeftText:SetAlpha(1)
				self.StatusBar.RightText:SetAlpha(1)
				self.StatusBar.MouseoverText:SetAlpha(1)
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
			self.cFunc = sbStrings[self.config.sbType][self.config.cIndex][2]
		else
			self.cFunc = function() return "" end
		end

		self.StatusBar.CenterText:SetText(self:cFunc())
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
			self.lFunc = sbStrings[self.config.sbType][self.config.lIndex][2]
		else
			self.lFunc = function() return "" end
		end

		self.StatusBar.LeftText:SetText(self:lFunc())

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
			self.rFunc = sbStrings[self.config.sbType][self.config.rIndex][2]
		else
			self.rFunc = function() return "" end
		end

		self.StatusBar.RightText:SetText(self:rFunc())

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
			self.mFunc = sbStrings[self.config.sbType][self.config.mIndex][2]
		else
			self.mFunc = function() return "" end
		end

		self.StatusBar.MouseoverText:SetText(self:mFunc())
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
			self.tFunc = sbStrings[self.config.sbType][self.config.tIndex][2]
		else
			self.tFunc = function() return "" end
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

		self.unit = BarUnits[self.data.unit]

	end
end




function STATUSBTN:UpdateCastIcon(frame, checked)

	if checked then
		self.config.showIcon = true
	else
		self.config.showIcon = false
	end

	self.showIcon = self.config.showIcon

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


	self.StatusBar.CenterText:SetTextColor(self.cColor[1], self.cColor[2], self.cColor[3], self.cColor[4])
	self.StatusBar.LeftText:SetTextColor(self.lColor[1], self.lColor[2], self.lColor[3], self.lColor[4])
	self.StatusBar.RightText:SetTextColor(self.rColor[1], self.rColor[2], self.rColor[3], self.rColor[4])
	self.StatusBar.MouseoverText:SetTextColor(self.mColor[1], self.mColor[2], self.mColor[3], self.mColor[4])

	if sbStrings[self.config.sbType] then

		if not sbStrings[self.config.sbType][self.config.cIndex] then
			self.config.cIndex = 1
		end
		self.cFunc = sbStrings[self.config.sbType][self.config.cIndex][2]

		if not sbStrings[self.config.sbType][self.config.lIndex] then
			self.config.lIndex = 1
		end
		self.lFunc = sbStrings[self.config.sbType][self.config.lIndex][2]

		if not sbStrings[self.config.sbType][self.config.rIndex] then
			self.config.rIndex = 1
		end
		self.rFunc = sbStrings[self.config.sbType][self.config.rIndex][2]

		if not sbStrings[self.config.sbType][self.config.mIndex] then
			self.config.mIndex = 1
		end
		self.mFunc = sbStrings[self.config.sbType][self.config.mIndex][2]

		if not sbStrings[self.config.sbType][self.config.tIndex] then
			self.config.tIndex = 1
		end
		self.tFunc = sbStrings[self.config.sbType][self.config.tIndex][2]

	else
		self.cFunc = function() return "" end
		self.lFunc = function() return "" end
		self.rFunc = function() return "" end
		self.mFunc = function() return "" end
		self.tFunc = function() return "" end
	end

	self.StatusBar.CenterText:SetText(self:cFunc())
	self.StatusBar.LeftText:SetText(self:lFunc())
	self.StatusBar.RightText:SetText(self:rFunc())
	self.StatusBar.MouseoverText:SetText(self:mFunc())

	self.castColor = { (";"):split(self.config.castColor) }
	self.channelColor = { (";"):split(self.config.channelColor) }
	self.successColor = { (";"):split(self.config.successColor) }
	self.failColor = { (";"):split(self.config.failColor) }

	self.orientation = self.config.orientation
	self.StatusBar:SetOrientation(BarOrientations[self.config.orientation]:lower())
	self.Feedback:SetOrientation(BarOrientations[self.config.orientation]:lower())

	if self.config.orientation == 2 then
		self.StatusBar.CenterText:SetAlpha(0)
		self.StatusBar.LeftText:SetAlpha(0)
		self.StatusBar.RightText:SetAlpha(0)
		self.StatusBar.MouseoverText:SetAlpha(0)
	else
		self.StatusBar.CenterText:SetAlpha(1)
		self.StatusBar.LeftText:SetAlpha(1)
		self.StatusBar.RightText:SetAlpha(1)
		self.StatusBar.MouseoverText:SetAlpha(1)
	end

	if BarTextures[self.config.texture] then
		self.StatusBar:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.Feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
	else
		self.StatusBar:SetStatusBarTexture(BarTextures[1][self.config.orientation])
		self.Feedback:SetStatusBarTexture(BarTextures[1][self.config.orientation])
	end

	self:SetBorder(self.StatusBar, self.config, self.bordercolor)
	self:SetBorder(self.Feedback, self.config, self.bordercolor)

	self:SetFrameLevel(4)

	self.Feedback:SetFrameLevel(self.StatusBar:GetFrameLevel()+10)
	self.Feedback.Background:SetFrameLevel(self.StatusBar.Background:GetFrameLevel()+10)
	self.Feedback.Border:SetFrameLevel(self.StatusBar.Border:GetFrameLevel()+10)

end

function STATUSBTN:UpdateObjectVisibility(show)
	if show then
		self.editmode = true
		self.Feedback:Show()
	else
		self.editmode = nil
		self.Feedback:Hide()
	end
end

function STATUSBTN:StatusBar_Reset()

	self:RegisterForClicks("")
	self:SetScript("OnClick", function() end)
	self:SetScript("OnEnter", function() end)
	self:SetScript("OnLeave", function() end)
	self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

	self.StatusBar:UnregisterAllEvents()
	self.StatusBar:SetScript("OnUpdate", function() end)
	self.StatusBar:SetScript("OnShow", function() end)
	self.StatusBar:SetScript("OnHide", function() end)

	self.unit = nil
	self.rep = nil
	self.showIcon = nil

	for index, sb in ipairs(MirrorBars) do
		if sb == self.StatusBar then
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

		if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC then
			self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "CastBar_OnEvent")
			self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "CastBar_OnEvent")
		end

		self.unit = BarUnits[self.data.unit]
		self.showIcon = self.config.showIcon

		self.casting = false
		self.channeling = false
		self.holdTime = 0

		self:SetScript("OnUpdate", function(self, elapsed) self:CastBar_OnUpdate(elapsed) end)

		if not self.castInfo then
			self.castInfo = {}
		else
			wipe(self.castInfo)
		end

		self.StatusBar:Hide()

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

		if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC then
			self:RegisterEvent("HONOR_XP_UPDATE", "XPBar_OnEvent")
			self:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED", "XPBar_OnEvent")
			self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", "XPBar_OnEvent")
		end

		self.StatusBar:Show()

	elseif self.config.sbType == "rep" then

		self.repID = self.data.repID

		self:SetAttribute("hasaction", true)

		self:RegisterForClicks("RightButtonUp")
		self:SetScript("OnClick", function(self, mousebutton, down) self:OnClick(mousebutton, down) end)
		self:SetScript("OnEnter", function(self) self:OnEnter() end)
		self:SetScript("OnLeave", function(self) self:OnLeave() end)
		self:SetHitRectInsets(0, 0, 0, 0)

		self:RegisterEvent("UPDATE_FACTION", "repbar_OnEvent")
		self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "repbar_OnEvent")
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "repbar_OnEvent")

		self.StatusBar:Show()

	elseif self.config.sbType == "mirror" then

		self:RegisterEvent("MIRROR_TIMER_START", "MirrorBar_OnEvent")
		self:RegisterEvent("MIRROR_TIMER_STOP", "MirrorBar_OnEvent")
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "MirrorBar_OnEvent")

		self:SetScript("OnUpdate", function(self, elapsed) self:MirrorBar_OnUpdate(elapsed) end)

		table.insert(MirrorBars, self)

		self.StatusBar:Hide()

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

	self.Feedback.Text:SetText(typeString)

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