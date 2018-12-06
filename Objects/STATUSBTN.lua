--Neuron, a World of Warcraft® user interface addon.

---@class STATUSBTN : BUTTON @define class STATUSBTN inherits from class BUTTON
local STATUSBTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.STATUSBTN = STATUSBTN


local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local BarRepColors = {
	[0] = { l="a_Unknown", r=0.5, g=0.5, b=0.5, a=1.0 },
	[1] = { l="b_Hated", r=0.6, g=0.1, b=0.1, a=1.0 },
	[2] = { l="c_Hostile", r=0.7, g=0.2, b=0.2, a=1.0 },
	[3] = { l="d_Unfriendly", r=0.75, g=0.27, b=0, a=1.0 },
	[4] = { l="e_Neutral", r=0.9, g=0.7, b=0, a=1.0 },
	[5] = { l="f_Friendly", r=0.5, g=0.6, b=0.1, a=1.0 },
	[6] = { l="g_Honored", r=0.1, g=0.5, b=0.20, a=1.0 },
	[7] = { l="h_Revered", r=0.0, g=0.39, b=0.88, a=1.0 },
	[8] = { l="i_Exalted", r=0.58, g=0.0, b=0.55, a=1.0 },
	[9] = { l="i_Exalted2", r=0.58, g=0.0, b=0.55, a=1.0 },
	[10] = { l="i_Exalted3", r=0.58, g=0.0, b=0.55, a=1.0 },
	[11] = { l="p_Paragon", r=1, g=0.5, b=0, a=1.0 },
}

--These factions return fID but have 8 levels instead of 6
local BrawlerGuildFactions = {
	[1419] = true, --Alliance
	[1374] = true, --Horde
}

local CastWatch, RepWatch, MirrorWatch, MirrorBars, Session = {}, {}, {}, {}, {}

local sbStrings = {
	cast = {
		[1] = { L["None"], function(sb) return "" end },
		[2] = { L["Spell"], function(sb) if (CastWatch[sb.unit]) then return CastWatch[sb.unit].spell end end },
		[3] = { L["Timer"], function(sb) if (CastWatch[sb.unit]) then return CastWatch[sb.unit].timer end end },
	},
	xp = {
		[1] = { L["None"], function(sb) return "" end },
		[2] = { L["Current/Next"], function(sb) if (sb.XPWatch) then return sb.XPWatch.current end end },
		[3] = { L["Rested Levels"], function(sb) if (sb.XPWatch) then return sb.XPWatch.rested end end },
		[4] = { L["Percent"], function(sb) if (sb.XPWatch) then return sb.XPWatch.percent end end },
		[5] = { L["Bubbles"], function(sb) if (sb.XPWatch) then return sb.XPWatch.bubbles end end },
		[6] = { L["Current Level/Rank"], function(sb) if (sb.XPWatch) then return sb.XPWatch.rank end end },
	},
	rep = {
		[1] = { L["None"], function(sb) return "" end },
		[2] = { L["Faction"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].rep end end }, ---TODO:should probably do the same as above here, just in case people have more than 1 rep bar
		[3] = { L["Current/Next"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].current end end },
		[4] = { L["Percent"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].percent end end },
		[5] = { L["Bubbles"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].bubbles end end },
		[6] = { L["Current Level/Rank"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].rank end end },
	},
	mirror = {
		[1] = { L["None"], function(sb) return "" end },
		[2] = { L["Type"], function(sb) if (MirrorWatch[sb.mirror]) then return MirrorWatch[sb.mirror].label end end },
		[3] = { L["Timer"], function(sb) if (MirrorWatch[sb.mirror]) then return MirrorWatch[sb.mirror].timer end end },
	},
}

Neuron.sbStrings = sbStrings

local configDefaults = {
	[1] = { sbType = "cast", cIndex = 1, lIndex = 2, rIndex = 3, showIcon = true},
	[2] = { sbType = "xp", cIndex = 2, lIndex = 6, rIndex = 4, mIndex = 3, width = 450},
	[3] = { sbType = "rep", cIndex = 3, lIndex = 2, rIndex = 4, mIndex = 6, width = 450},
	[4] = { sbType = "mirror", cIndex = 1, lIndex = 2, rIndex = 3},
}


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
	[1] = L["Horizontal"],
	[2] = L["Vertical"],
}
Neuron.BarOrientations = BarOrientations






---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return STATUSBTN @ A newly created STATUSBTN object
function STATUSBTN:new(name)
	local object = CreateFrame("Button", name, UIParent, "NeuronStatusBarTemplate")
	setmetatable(object, {__index = STATUSBTN})
	return object
end



function STATUSBTN:SetSkinned()
end

----------------------------------
--------XP Bar--------------------
----------------------------------

---TODO: right now we are using DB.statusbtn to assign settins ot the status buttons, but I think our indexes are bar specific
function STATUSBTN:xpstrings_Update() --handles updating all the strings for the play XP watch bar

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



function STATUSBTN:XPBar_OnEvent(event, ...)

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



function STATUSBTN:switchCurXPType(newXPType)

	self.DB.curXPType = newXPType
	self:XPBar_OnEvent("changed_curXPType")
end


function STATUSBTN:xpDropDown_Initialize() -- initialize the dropdown menu for chosing to watch either XP, azerite XP, or Honor Points

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


function STATUSBTN:XPBar_DropDown_OnLoad()

	UIDropDownMenu_Initialize(self.dropdown, function() self:xpDropDown_Initialize() end, "MENU")
	self.dropdown_init = true
end





----------------------------------------------
----------------Rep Bar-----------------------
----------------------------------------------


--- Creates a table containing provided data
-- @param name, hasFriendStatus, standing, minrep, maxrep, value, colors
-- @return reptable:  Table containing provided data
function STATUSBTN:SetRepWatch(name, hasFriendStatus, standing, minrep, maxrep, value, colors)
	local reptable = {}
	reptable.rep = name
	reptable.rank = standing
	reptable.current = (value-minrep).." / "..(maxrep-minrep)
	reptable.percent = floor(((value-minrep)/(maxrep-minrep))*100).."%"
	reptable.bubbles = tostring(math.floor(((((value-minrep)/(maxrep-minrep))*100)/5))).." / 20 "..L["Bubbles"]
	reptable.rephour = "---"
	reptable.min = minrep
	reptable.max = maxrep
	reptable.value = value
	reptable.hex = string.format("%02x%02x%02x", colors.r*255, colors.g*255, colors.b*255)
	reptable.r = colors.r
	reptable.g = colors.g
	reptable.b = colors.b

	if hasFriendStatus then
		reptable.l = "z"..colors.l
	else
		reptable.l = colors.l
	end
	return reptable
end


function STATUSBTN:repstrings_Update(line)

	local DB = Neuron.db.profile

	if (GetNumFactions() > 0) then
		wipe(RepWatch)

		for i=1, GetNumFactions() do
			local name, _, ID, min, max, value, _, _, isHeader, _, hasRep, _, _, factionID = GetFactionInfo(i)
			local fID, fRep, fMaxRep, fName, fText, fTexture, fTextLevel, fThreshold, nextFThreshold = GetFriendshipReputation(factionID)
			local colors, standing
			local hasFriendStatus = false

			if ID == 8 then
				min = 0
			end

			if ((not isHeader or hasRep) and not IsFactionInactive(i)) then
				if (fID and not BrawlerGuildFactions[fID]) then
					colors = BarRepColors[ID+2]; standing = fTextLevel
					hasFriendStatus = true
				elseif (fID and BrawlerGuildFactions[fID]) then
					colors = BarRepColors[ID]; standing = fTextLevel
					hasFriendStatus = true
				else
					colors = BarRepColors[ID]; standing = (colors.l):gsub("^%a%p", "")
				end

				if (factionID and C_Reputation.IsFactionParagon(factionID)) then
					local para_value, para_max, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
					value = para_value % para_max;
					max = para_max
					if hasRewardPending then
						name = name.." ("..L["Reward"]:upper()..")"
					end
					min = 0
					colors = BarRepColors[11]
				end

				local repData = self:SetRepWatch(name, hasFriendStatus, standing, min, max, value, colors)
				RepWatch[i] = repData --set current reptable into growing RepWatch table

				if (((line and type(line)~= "boolean") and line:find(name)) or DB.AutoWatch == i) then --this line automatically assings the most recently updated repData to RepWatch[0], and the "auto" option assigns RepWatch[0] to be shown
					RepWatch[0] = repData
					DB.AutoWatch = i
				end
			end
		end
	end
end





function STATUSBTN:repbar_OnEvent(event,...)

	self:repstrings_Update(...)

	if (RepWatch[self.sb.repID]) then
		self.sb:SetStatusBarColor(RepWatch[self.sb.repID].r,  RepWatch[self.sb.repID].g, RepWatch[self.sb.repID].b)
		self.sb:SetMinMaxValues(RepWatch[self.sb.repID].min, RepWatch[self.sb.repID].max)
		self.sb:SetValue(RepWatch[self.sb.repID].value)
	else
		self.sb:SetStatusBarColor(0.5,  0.5, 0.5)
		self.sb:SetMinMaxValues(0, 1)
		self.sb:SetValue(1)
	end

	self.sb.cText:SetText(self.sb.cFunc(self.sb))
	self.sb.lText:SetText(self.sb.lFunc(self.sb))
	self.sb.rText:SetText(self.sb.rFunc(self.sb))
	self.sb.mText:SetText(self.sb.mFunc(self.sb))
end


function STATUSBTN:repDropDown_Initialize() --Initialize the dropdown menu for choosing a rep

	if (self.sb) then

		local info = UIDropDownMenu_CreateInfo()
		local checked, repLine, repIndex

		info.arg1 = self
		info.arg2 = nil
		info.text = L["Auto Select"]
		info.func = function(dropdown, self) --self is arg1
			self.data.repID = dropdown.value
			self.sb.repID = dropdown.value
			self:repbar_OnEvent()
		end

		if (self.data.repID == 0) then
			checked = 1
		else
			checked = nil
		end

		info.value = 0
		info.checked = checked

		UIDropDownMenu_AddButton(info)

		wipe(info)

		info.arg1 = nil
		info.arg2 = nil
		info.text = " "
		info.func = function() end
		info.value = nil
		info.checked = nil
		info.notClickable = true
		info.notCheckable = 1

		UIDropDownMenu_AddButton(info) --this is a spacer in the menu between Auto Select and the different factions

		wipe(info)

		local data = {}
		local order, ID, text, friends

		for k,v in pairs(RepWatch) do --insert all factions and percentages into "data"

			if (k > 0) then

				local percent = tonumber(v.percent:match("%d+"))

				if (percent < 10) then
					percent = "0"..percent
				end

				table.insert(data, v.l..percent..";"..k..";".."|cff"..v.hex..v.rep.." - "..v.percent.."|r")
			end
		end

		table.sort(data) --sort data alphabetically

		for k,v in ipairs(data) do

			order, ID, text = (";"):split(v)

			if (order:find("^z") and not friends) then

				info.arg1 = nil
				info.arg2 = nil
				info.text = " "
				info.func = function() end
				info.value = nil
				info.checked = nil
				info.notClickable = true
				info.notCheckable = 1

				UIDropDownMenu_AddButton(info)

				info.arg1 = nil
				info.arg2 = nil
				info.text = "Friends"
				info.func = function() end
				info.value = nil
				info.checked = nil
				info.notClickable = true
				info.notCheckable = 1
				info.leftPadding = 17

				UIDropDownMenu_AddButton(info)

				wipe(info)

				friends = true
			end

			ID = tonumber(ID)

			info.arg1 = self
			info.arg2 = nil
			info.text = text
			info.func = function(dropdown, self) --self is arg1
				self.data.repID = dropdown.value
				self.sb.repID = dropdown.value
				self:repbar_OnEvent()
			end

			if (self.data.repID == ID) then
				checked = 1
			else
				checked = nil
			end

			info.value = ID
			info.checked = checked
			info.notClickable = nil
			info.notCheckable = nil

			UIDropDownMenu_AddButton(info)

			wipe(info)
		end
	end
end


function STATUSBTN:RepBar_DropDown_OnLoad()

	UIDropDownMenu_Initialize(self.dropdown, function() self:repDropDown_Initialize() end, "MENU")
	self.dropdown_init = true
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

			if (type ~= "UNKNOWN") then
				self:mirrorbar_Start(type, value, maxvalue, scale, paused, label)
			end
		end
	end

end



function STATUSBTN:mirrorbar_Start(type, value, maxvalue, scale, paused, label)

	if (not MirrorWatch[type]) then
		MirrorWatch[type] = { active = false, mbar = nil, label = "", timer = "" }
	end

	if (not MirrorWatch[type].active) then

		local mbar = table.remove(MirrorBars, 1)

		if (mbar) then

			MirrorWatch[type].active = true
			MirrorWatch[type].mbar = mbar
			MirrorWatch[type].label = label

			mbar.sb.mirror = type
			mbar.sb.value = (value / 1000)
			mbar.sb.maxvalue = (maxvalue / 1000)
			mbar.sb.scale = scale

			if ( paused > 0 ) then
				mbar.sb.paused = 1
			else
				mbar.sb.paused = nil
			end

			local color = MirrorTimerColors[type]

			mbar.sb:SetMinMaxValues(0, (maxvalue / 1000))
			mbar.sb:SetValue(mbar.sb.value)
			mbar.sb:SetStatusBarColor(color.r, color.g, color.b)

			mbar.sb:SetAlpha(1)
			mbar.sb:Show()
		end
	end
end





function STATUSBTN:mirrorbar_Stop(type)


	if (MirrorWatch[type] and MirrorWatch[type].active) then

		local mbar = MirrorWatch[type].mbar

		if (mbar) then

			table.insert(MirrorBars, 1, mbar)

			MirrorWatch[type].active = false
			MirrorWatch[type].mbar = nil
			MirrorWatch[type].label = ""
			MirrorWatch[type].timer = ""

			mbar.sb.mirror = nil
		end
	end
end





function STATUSBTN:CastBar_FinishSpell()

	self.sb.spark:Hide()
	self.sb.barflash:SetAlpha(0.0)
	self.sb.barflash:Show()
	self.sb.flash = 1
	self.sb.fadeOut = 1
	self.sb.casting = false
	self.sb.channeling = false
end





function STATUSBTN:CastBar_Reset()

	self.sb.fadeOut = 1
	self.sb.casting = false
	self.sb.channeling = false
	self.sb:SetStatusBarColor(self.sb.castColor[1], self.sb.castColor[2], self.sb.castColor[3], self.sb.castColor[4])

	if (not self.editmode) then
		self.sb:Hide()
	end
end





function STATUSBTN:CastBar_OnEvent(event, ...)

	local unit = ...

	if (unit ~= self.sb.unit) then
		return
	end

	if (not CastWatch[unit] ) then
		CastWatch[unit] = {}
	end



	if (event == "UNIT_SPELLCAST_START") then

		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)

		if (not name or (not self.showTradeSkills and isTradeSkill)) then
			self:CastBar_Reset()
			return
		end

		self.sb:SetStatusBarColor(self.sb.castColor[1], self.sb.castColor[2], self.sb.castColor[3], self.sb.castColor[4])

		if (self.sb.spark) then
			self.sb.spark:SetTexture("Interface\\AddOns\\Neuron\\Images\\CastingBar_Spark_"..self.sb.orientation)
			self.sb.spark:Show()
		end

		self.sb.value = (GetTime()-(startTime/1000))
		self.sb.maxValue = (endTime-startTime)/1000
		self.sb:SetMinMaxValues(0, self.sb.maxValue)
		self.sb:SetValue(self.sb.value)

		self.sb.totalTime = self.sb.maxValue - self.sb:GetValue()

		CastWatch[unit].spell = text

		if (self.sb.showIcon) then

			self.sb.icon:SetTexture(texture)
			self.sb.icon:Show()

			if (notInterruptible) then
				self.sb.shield:Show()
			else
				self.sb.shield:Hide()
			end

		else
			self.sb.icon:Hide()
			self.sb.shield:Hide()
		end

		self.sb:SetAlpha(1.0)
		self.sb.holdTime = 0
		self.sb.casting = true
		self.sb.castID = castID
		self.sb.channeling = false
		self.sb.fadeOut = nil

		self.sb:Show()

	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and not self.sb.channeling) then

		self.sb:SetStatusBarColor(self.sb.successColor[1], self.sb.successColor[2], self.sb.successColor[3], self.sb.successColor[4])

	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and self.sb.channeling) then

		-- do nothing (when Tranquility is channeling if reports UNIT_SPELLCAST_SUCCEEDED many times during the duration)

	elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then

		if ((self.sb.casting and event == "UNIT_SPELLCAST_STOP") or
				(self.sb.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP")) then

			self.sb.spark:Hide()
			self.sb.barflash:SetAlpha(0.0)
			self.sb.barflash:Show()

			self.sb:SetValue(self.sb.maxValue)

			if (event == "UNIT_SPELLCAST_STOP") then
				self.sb.casting = false
			else
				self.sb.channeling = false
			end

			self.sb.flash = 1
			self.sb.fadeOut = 1
			self.sb.holdTime = 0
		end

	elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then

		if (self.sb:IsShown() and (self.sb.casting) and not self.sb.fadeOut) then

			self.sb:SetValue(self.sb.maxValue)

			self.sb:SetStatusBarColor(self.sb.failColor[1], self.sb.failColor[2], self.sb.failColor[3], self.sb.failColor[4])

			if (self.sb.spark) then
				self.sb.spark:Hide()
			end

			if (event == "UNIT_SPELLCAST_FAILED") then
				CastWatch[unit].spell = FAILED
			else
				CastWatch[unit].spell = INTERRUPTED
			end

			self.sb.casting = false
			self.sb.channeling = false
			self.sb.fadeOut = 1
			self.sb.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
		end

	elseif (event == "UNIT_SPELLCAST_DELAYED") then

		if (self.sb:IsShown()) then

			local name, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)

			if (not name or (not self.sb.showTradeSkills and isTradeSkill)) then
				self:CastBar_Reset()
				return
			end

			self.sb.value = (GetTime()-(startTime/1000))
			self.sb.maxValue = (endTime-startTime)/1000
			self.sb:SetMinMaxValues(0, self.sb.maxValue)

			if (not self.sb.casting) then

				self.sb:SetStatusBarColor(self.sb.castColor[1], self.sb.castColor[2], self.sb.castColor[3], self.sb.castColor[4])

				self.sb.spark:Show()
				self.sb.barflash:SetAlpha(0.0)
				self.sb.barflash:Hide()

				self.sb.casting = true
				self.sb.channeling = false
				self.sb.flash = 0
				self.sb.fadeOut = 0
			end
		end

	elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then

		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)

		if (not name or (not self.sb.showTradeSkills and isTradeSkill)) then
			self:CastBar_Reset()
			return
		end

		self.sb:SetStatusBarColor(self.sb.channelColor[1], self.sb.channelColor[2], self.sb.channelColor[3], self.sb.channelColor[4])

		self.sb.value = ((endTime/1000)-GetTime())
		self.sb.maxValue = (endTime - startTime) / 1000;
		self.sb:SetMinMaxValues(0, self.sb.maxValue);
		self.sb:SetValue(self.sb.value)

		CastWatch[unit].spell = text

		if (self.sb.showIcon) then

			self.sb.icon:SetTexture(texture)
			self.sb.icon:Show()

			if (notInterruptible) then
				self.sb.shield:Show()
			else
				self.sb.shield:Hide()
			end

		else
			self.sb.icon:Hide()
			self.sb.shield:Hide()
		end

		if (self.sb.spark) then
			self.sb.spark:Hide()
		end

		self.sb:SetAlpha(1.0)
		self.sb.holdTime = 0
		self.sb.casting = false
		self.sb.channeling = true
		self.sb.fadeOut = nil

		self.sb:Show()

	elseif (event == "UNIT_SPELLCAST_CHANNEL_UPDATE") then

		if (self.sb:IsShown()) then

			local name, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit)

			if (not name or (not self.sb.showTradeSkills and isTradeSkill)) then
				self:CastBar_Reset()
				return
			end

			self.sb.value = ((endTime/1000)-GetTime())
			self.sb.maxValue = (endTime-startTime)/1000
			self.sb:SetMinMaxValues(0, self.sb.maxValue)
			self.sb:SetValue(self.sb.value)
		end

	elseif (self.sb.showShield and event == "UNIT_SPELLCAST_INTERRUPTIBLE" ) then

		self.sb.shield:Hide()

	elseif (self.sb.showShield and event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then

		self.sb.shield:Show()

	else
		self:CastBar_Reset()
	end

	self.sb.cText:SetText(self.sb.cFunc(self.sb))
	self.sb.lText:SetText(self.sb.lFunc(self.sb))
	self.sb.rText:SetText(self.sb.rFunc(self.sb))
	self.sb.mText:SetText(self.sb.mFunc(self.sb))
end





function STATUSBTN:CastBar_OnUpdate(elapsed)

	local unit = self.sb.unit
	local sparkPosition, alpha

	if (unit) then

		if (self.sb.cbtimer.castInfo[unit]) then

			local displayName, numFormat = self.sb.cbtimer.castInfo[unit][1], self.sb.cbtimer.castInfo[unit][2]

			if (self.sb.maxValue) then
				CastWatch[self.sb.unit].timer = string.format(numFormat, self.sb.value).."/"..format(numFormat, self.sb.maxValue)
			else
				CastWatch[self.sb.unit].timer = string.format(numFormat, self.sb.value)
			end
		end

		if (self.sb.casting) then

			self.sb.value = self.sb.value + elapsed

			if (self.sb.value >= self.sb.maxValue) then
				self.sb:SetValue(self.sb.maxValue)
				self:CastBar_FinishSpell()
				return
			end

			self.sb:SetValue(self.sb.value)

			self.sb.barflash:Hide()

			if (self.sb.orientation == 1) then

				sparkPosition = (self.sb.value/self.sb.maxValue)*self.sb:GetWidth()

				if (sparkPosition < 0) then
					sparkPosition = 0
				end

				self.sb.spark:SetPoint("CENTER", self.sb, "LEFT", sparkPosition, 0)

			else
				sparkPosition = (self.sb.value / self.sb.maxValue) * self.sb:GetHeight()

				if ( sparkPosition < 0 ) then
					sparkPosition = 0
				end

				self.sb.spark:SetPoint("CENTER", self.sb, "BOTTOM", 0, sparkPosition)
			end

		elseif (self.sb.channeling) then

			self.sb.value = self.sb.value - elapsed

			if (self.sb.value <= 0) then
				self:CastBar_FinishSpell()
				return
			end

			self.sb:SetValue(self.sb.value)

			self.sb.barflash:Hide()

		elseif (GetTime() < self.sb.holdTime) then

			return

		elseif (self.sb.flash) then

			alpha = self.sb.barflash:GetAlpha() + CASTING_BAR_FLASH_STEP or 0

			if (alpha < 1) then
				self.sb.barflash:SetAlpha(alpha)
			else
				self.sb.barflash:SetAlpha(1.0)
				self.sb.flash = nil
			end

		elseif (self.sb.fadeOut and not self.sb.editmode) then

			alpha = self.sb:GetAlpha() - CASTING_BAR_ALPHA_STEP

			if (alpha > 0) then
				self.sb:SetAlpha(alpha)
			else
				self:CastBar_Reset()
			end
		end
	end

	self.sb.cText:SetText(self.sb.cFunc(self.sb))
	self.sb.lText:SetText(self.sb.lFunc(self.sb))
	self.sb.rText:SetText(self.sb.rFunc(self.sb))
	self.sb.mText:SetText(self.sb.mFunc(self.sb))
end





function STATUSBTN:CastBarTimer_OnEvent(event, ...)

	local unit = ...

	if (unit) then

		if (event == "UNIT_SPELLCAST_START") then

			local _, text = UnitCastingInfo(unit)

			if (not self.sb.cbtimer.castInfo[unit]) then self.sb.cbtimer.castInfo[unit] = {} end
			self.sb.cbtimer.castInfo[unit][1] = text
			self.sb.cbtimer.castInfo[unit][2] = "%0.1f"

		elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then

			local _, text = UnitChannelInfo(unit)

			if (not self.sb.cbtimer.castInfo[unit]) then self.sb.cbtimer.castInfo[unit] = {} end
			self.sb.cbtimer.castInfo[unit][1] = text
			self.sb.cbtimer.castInfo[unit][2] = "%0.1f"
		end
	end
end




function STATUSBTN:MirrorBar_OnUpdate(elapsed)

	if (self.sb.mirror) then

		self.sb.value = GetMirrorTimerProgress(self.sb.mirror)/1000


		if (self.sb.value > self.sb.maxvalue) then

			self.sb.alpha = self.sb:GetAlpha() - CASTING_BAR_ALPHA_STEP

			if (self.sb.alpha > 0) then
				self.sb:SetAlpha(self.sb.alpha)
			else
				self.sb:Hide()
			end

		else

			self.sb:SetValue(self.sb.value)

			if (self.sb.value >= 60) then
				self.sb.value = string.format("%0.1f", self.sb.value/60)
				self.sb.value = self.sb.value.."m"
			else
				self.sb.value = string.format("%0.0f", self.sb.value)
				self.sb.value = self.sb.value.."s"
			end

			MirrorWatch[self.sb.mirror].timer = self.sb.value

		end

	elseif (not self.editmode) then

		self.sb.alpha = self.sb:GetAlpha() - CASTING_BAR_ALPHA_STEP

		if (self.sb.alpha > 0) then
			self.sb:SetAlpha(self.sb.alpha)
		else
			self.sb:Hide()
		end
	end

	self.sb.cText:SetText(self.sb.cFunc(self.sb))
	self.sb.lText:SetText(self.sb.lFunc(self.sb))
	self.sb.rText:SetText(self.sb.rFunc(self.sb))
	self.sb.mText:SetText(self.sb.mFunc(self.sb))
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

	if (statusbutton.barflash) then
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




function STATUSBTN:OnClick(mousebutton, down)


	if (mousebutton == "RightButton") then
		if (self.config.sbType == "xp" and not self.dropdown_init) then
			self:XPBar_DropDown_OnLoad()
		elseif(self.config.sbType == "rep" and not self.dropdown_init) then
			self:RepBar_DropDown_OnLoad()
		end


		if (DropDownList1:IsVisible()) then
			DropDownList1:Hide()
		else
			self:repstrings_Update()

			ToggleDropDownMenu(1, nil, self.dropdown, self, 0, 0)

			DropDownList1:ClearAllPoints()
			DropDownList1:SetPoint("LEFT", self, "RIGHT", 3, 0)
			DropDownList1:SetClampedToScreen(true)

			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end
end




function STATUSBTN:OnEnter()

	if (self.config.mIndex > 1) then
		self.sb.cText:Hide()
		self.sb.lText:Hide()
		self.sb.rText:Hide()
		self.sb.mText:Show()
		self.sb.mText:SetText(self.sb.mFunc(self.sb))
	end

	if (self.config.tIndex > 1) then

		if (self.bar) then

			if (self.bar.data.tooltipsCombat and InCombatLockdown()) then
				return
			end

			if (self.bar.data.tooltips) then

				if (self.bar.data.tooltipsEnhanced) then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				else
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				end

				GameTooltip:SetText(self.sb.tFunc(self.sb) or "", self.tColor[1] or 1, self.tColor[2] or 1, self.tColor[3] or 1, self.tColor[4] or 1)
				GameTooltip:Show()
			end
		end
	end
end




function STATUSBTN:OnLeave()

	if (self.config.mIndex > 1) then
		self.sb.cText:Show()
		self.sb.lText:Show()
		self.sb.rText:Show()
		self.sb.mText:Hide()
		self.sb.cText:SetText(self.sb.cFunc(self.sb))
		self.sb.lText:SetText(self.sb.lFunc(self.sb))
		self.sb.rText:SetText(self.sb.rFunc(self.sb))
	end

	if (self.config.tIndex > 1) then
		GameTooltip:Hide()
	end
end




function STATUSBTN:UpdateWidth(command, gui, query, skipupdate)

	if (query) then
		return self.config.width
	end

	local width = tonumber(command)

	if (width and width >= 10) then

		self.config.width = width

		self:SetWidth(self.config.width)

		Neuron.NeuronBar:SetObjectLoc(self.bar)

		Neuron.NeuronBar:SetPerimeter(self.bar)

		Neuron.NeuronBar:SetSize(self.bar)

		if (not skipupdate) then
			Neuron.NeuronGUI:Status_UpdateEditor()
			Neuron.NeuronBar:Update(self.bar)
		end
	end
end




function STATUSBTN:UpdateHeight(command, gui, query, skipupdate)

	if (query) then
		return self.config.height
	end

	local height = tonumber(command)

	if (height and height >= 4) then

		self.config.height = height

		self:SetHeight(self.config.height)

		Neuron.NeuronBar:SetObjectLoc(self.bar)

		Neuron.NeuronBar:SetPerimeter(self.bar)

		Neuron.NeuronBar:SetSize(self.bar)

		if (not skipupdate) then
			Neuron.NeuronGUI:Status_UpdateEditor()
			Neuron.NeuronBar:Update(self.bar)
		end
	end
end




function STATUSBTN:UpdateTexture(command, gui, query, skipupdate)

	if (query) then
		return BarTextures[self.config.texture][3]
	end

	local index = tonumber(command)

	if (index and BarTextures[index]) then

		self.config.texture = index

		self.sb:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.fbframe.feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])

		if (not skipupdate) then
			Neuron.NeuronGUI:Status_UpdateEditor()
		end

	end

end




function STATUSBTN:UpdateBorder(command, gui, query, skipupdate)

	if (query) then
		return BarBorders[self.config.border][1]
	end

	local index = tonumber(command)

	if (index and BarBorders[index]) then

		self.config.border = index

		self:SetBorder(self.sb, self.config, self.bordercolor)
		self:SetBorder(self.fbframe.feedback, self.config, self.bordercolor)

		if (not skipupdate) then
			Neuron.NeuronGUI:Status_UpdateEditor()
		end
	end
end




function STATUSBTN:UpdateOrientation(command, gui, query, skipupdate)

	if (query) then
		return BarOrientations[self.config.orientation]
	end

	local index = tonumber(command)

	if (index) then

		self.config.orientation = index
		self.sb.orientation = self.config.orientation

		self.sb:SetOrientation(BarOrientations[self.config.orientation]:upper())
		self.fbframe.feedback:SetOrientation(BarOrientations[self.config.orientation]:upper())

		if (self.config.orientation == 2) then
			self.sb.cText:SetAlpha(0)
			self.sb.lText:SetAlpha(0)
			self.sb.rText:SetAlpha(0)
			self.sb.mText:SetAlpha(0)
		else
			self.sb.cText:SetAlpha(1)
			self.sb.lText:SetAlpha(1)
			self.sb.rText:SetAlpha(1)
			self.sb.mText:SetAlpha(1)
		end

		local width, height = self.config.width,  self.config.height

		self.config.width = height
		self.config.height = width

		self:SetWidth(self.config.width)

		self:SetHeight(self.config.height)

		Neuron.NeuronBar:SetObjectLoc(self.bar)

		Neuron.NeuronBar:SetPerimeter(self.bar)

		Neuron.NeuronBar:SetSize(self.bar)

		if (not skipupdate) then
			Neuron.NeuronGUI:Status_UpdateEditor()
			Neuron.NeuronBar:Update(self.bar)
		end
	end
end




function STATUSBTN:UpdateCenterText(command, gui, query)

	if (not sbStrings[self.config.sbType]) then
		return "---"
	end

	if (query) then
		return sbStrings[self.config.sbType][self.config.cIndex][1]
	end

	local index = tonumber(command)

	if (index) then

		self.config.cIndex = index

		if (sbStrings[self.config.sbType]) then
			self.sb.cFunc = sbStrings[self.config.sbType][self.config.cIndex][2]
		else
			self.sb.cFunc = function() return "" end
		end

		self.sb.cText:SetText(self.sb.cFunc(self.sb))
	end
end




function STATUSBTN:UpdateLeftText(command, gui, query)

	if (not sbStrings[self.config.sbType]) then
		return "---"
	end

	if (query) then
		return sbStrings[self.config.sbType][self.config.lIndex][1]
	end

	local index = tonumber(command)

	if (index) then

		self.config.lIndex = index

		if (sbStrings[self.config.sbType]) then
			self.sb.lFunc = sbStrings[self.config.sbType][self.config.lIndex][2]
		else
			self.sb.lFunc = function() return "" end
		end

		self.sb.lText:SetText(self.sb.lFunc(self.sb))

	end
end




function STATUSBTN:UpdateRightText(command, gui, query)

	if (not sbStrings[self.config.sbType]) then
		return "---"
	end

	if (query) then
		return sbStrings[self.config.sbType][self.config.rIndex][1]
	end

	local index = tonumber(command)

	if (index) then

		self.config.rIndex = index

		if (sbStrings[self.config.sbType] and self.config.rIndex) then
			self.sb.rFunc = sbStrings[self.config.sbType][self.config.rIndex][2]
		else
			self.sb.rFunc = function() return "" end
		end

		self.sb.rText:SetText(self.sb.rFunc(self.sb))

	end
end




function STATUSBTN:UpdateMouseover(command, gui, query)

	if (not sbStrings[self.config.sbType]) then
		return "---"
	end

	if (query) then
		return sbStrings[self.config.sbType][self.config.mIndex][1]
	end

	local index = tonumber(command)

	if (index) then

		self.config.mIndex = index

		if (sbStrings[self.config.sbType]) then
			self.sb.mFunc = sbStrings[self.config.sbType][self.config.mIndex][2]
		else
			self.sb.mFunc = function() return "" end
		end

		self.sb.mText:SetText(self.sb.mFunc(self.sb))
	end
end




function STATUSBTN:UpdateTooltip(command, gui, query)

	if (not sbStrings[self.config.sbType]) then
		return "---"
	end

	if (query) then
		return sbStrings[self.config.sbType][self.config.tIndex][1]
	end

	local index = tonumber(command)

	if (index) then

		self.config.tIndex = index

		if (sbStrings[self.config.sbType]) then
			self.sb.tFunc = sbStrings[self.config.sbType][self.config.tIndex][2]
		else
			self.sb.tFunc = function() return "" end
		end
	end
end




function STATUSBTN:UpdateUnit(command, gui, query)

	if (query) then
		return BarUnits[self.data.unit]
	end

	local index = tonumber(command)

	if (index) then

		self.data.unit = index

		self.sb.unit = BarUnits[self.data.unit]

	end
end




function STATUSBTN:UpdateCastIcon(frame, checked)

	if (checked) then
		self.config.showIcon = true
	else
		self.config.showIcon = false
	end

	self.sb.showIcon = self.config.showIcon

end




function STATUSBTN:ChangeStatusBarType()

	if (self.config.sbType == "xp") then
		self.config.sbType = "rep"
		self.config.cIndex = 2
		self.config.lIndex = 1
		self.config.rIndex = 1
	elseif (self.config.sbType == "rep") then
		self.config.sbType = "cast"
		self.config.cIndex = 1
		self.config.lIndex = 2
		self.config.rIndex = 3
	elseif (self.config.sbType == "cast") then
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

	if (bar) then

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

	self.sb.parent = self

	self.sb.cText:SetTextColor(self.cColor[1], self.cColor[2], self.cColor[3], self.cColor[4])
	self.sb.lText:SetTextColor(self.lColor[1], self.lColor[2], self.lColor[3], self.lColor[4])
	self.sb.rText:SetTextColor(self.rColor[1], self.rColor[2], self.rColor[3], self.rColor[4])
	self.sb.mText:SetTextColor(self.mColor[1], self.mColor[2], self.mColor[3], self.mColor[4])

	if (sbStrings[self.config.sbType]) then

		if (not sbStrings[self.config.sbType][self.config.cIndex]) then
			self.config.cIndex = 1
		end
		self.sb.cFunc = sbStrings[self.config.sbType][self.config.cIndex][2]

		if (not sbStrings[self.config.sbType][self.config.lIndex]) then
			self.config.lIndex = 1
		end
		self.sb.lFunc = sbStrings[self.config.sbType][self.config.lIndex][2]

		if (not sbStrings[self.config.sbType][self.config.rIndex]) then
			self.config.rIndex = 1
		end
		self.sb.rFunc = sbStrings[self.config.sbType][self.config.rIndex][2]

		if (not sbStrings[self.config.sbType][self.config.mIndex]) then
			self.config.mIndex = 1
		end
		self.sb.mFunc = sbStrings[self.config.sbType][self.config.mIndex][2]

		if (not sbStrings[self.config.sbType][self.config.tIndex]) then
			self.config.tIndex = 1
		end
		self.sb.tFunc = sbStrings[self.config.sbType][self.config.tIndex][2]

	else
		self.sb.cFunc = function() return "" end
		self.sb.lFunc = function() return "" end
		self.sb.rFunc = function() return "" end
		self.sb.mFunc = function() return "" end
		self.sb.tFunc = function() return "" end
	end

	self.sb.cText:SetText(self.sb.cFunc(self.sb))
	self.sb.lText:SetText(self.sb.lFunc(self.sb))
	self.sb.rText:SetText(self.sb.rFunc(self.sb))
	self.sb.mText:SetText(self.sb.mFunc(self.sb))

	self.sb.norestColor = { (";"):split(self.config.norestColor) }
	self.sb.restColor = { (";"):split(self.config.restColor) }

	self.sb.castColor = { (";"):split(self.config.castColor) }
	self.sb.channelColor = { (";"):split(self.config.channelColor) }
	self.sb.successColor = { (";"):split(self.config.successColor) }
	self.sb.failColor = { (";"):split(self.config.failColor) }

	self.sb.orientation = self.config.orientation
	self.sb:SetOrientation(BarOrientations[self.config.orientation]:upper())
	self.fbframe.feedback:SetOrientation(BarOrientations[self.config.orientation]:upper())

	if (self.config.orientation == 2) then
		self.sb.cText:SetAlpha(0)
		self.sb.lText:SetAlpha(0)
		self.sb.rText:SetAlpha(0)
		self.sb.mText:SetAlpha(0)
	else
		self.sb.cText:SetAlpha(1)
		self.sb.lText:SetAlpha(1)
		self.sb.rText:SetAlpha(1)
		self.sb.mText:SetAlpha(1)
	end

	if (BarTextures[self.config.texture]) then
		self.sb:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.fbframe.feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
	else
		self.sb:SetStatusBarTexture(BarTextures[1][self.config.orientation])
		self.fbframe.feedback:SetStatusBarTexture(BarTextures[1][self.config.orientation])
	end

	self:SetBorder(self.sb, self.config, self.bordercolor)
	self:SetBorder(self.fbframe.feedback, self.config, self.bordercolor)

	self:SetFrameLevel(4)

	self.fbframe:SetFrameLevel(self:GetFrameLevel()+10)
	self.fbframe.feedback:SetFrameLevel(self.sb:GetFrameLevel()+10)
	self.fbframe.feedback.bg:SetFrameLevel(self.sb.bg:GetFrameLevel()+10)
	self.fbframe.feedback.border:SetFrameLevel(self.sb.border:GetFrameLevel()+10)

end



function STATUSBTN:LoadData(spec, state)

	local DB = Neuron.db.profile

	local id = self.id

	if not DB.statusbtn[id] then
		DB.statusbtn[id] = {}
	end

	self.DB = DB.statusbtn[id]

	self.config = self.DB.config
	self.keys = self.DB.keys
	self.data = self.DB.data
end




function STATUSBTN:SetObjectVisibility(show)

	if (show) then

		self.editmode = true

		self.fbframe:Show()

	else
		self.editmode = nil

		self.fbframe:Hide()
	end

end




function STATUSBTN:LoadAux()

	Neuron.NeuronGUI:SB_CreateEditFrame(self, self.objTIndex)

end


function STATUSBTN:SetDefaults(config)

	if (config) then
		for k,v in pairs(config) do
			self.config[k] = v
		end
	end

end




function STATUSBTN:GetDefaults()

	return configDefaults[self.id]

end




function STATUSBTN:StatusBar_Reset()

	self:RegisterForClicks("")
	self:SetScript("OnClick", function() end)
	self:SetScript("OnEnter", function() end)
	self:SetScript("OnLeave", function() end)
	self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

	self.sb:UnregisterAllEvents()
	self.sb:SetScript("OnEvent", function() end)
	self.sb:SetScript("OnUpdate", function() end)
	self.sb:SetScript("OnShow", function() end)
	self.sb:SetScript("OnHide", function() end)

	self.sb.unit = nil
	self.sb.rep = nil
	self.sb.showIcon = nil

	self.sb.cbtimer:UnregisterAllEvents()
	self.sb.cbtimer:SetScript("OnEvent", nil)

	for index, sb in ipairs(MirrorBars) do
		if (sb == self.sb) then
			table.remove(MirrorBars, index)
		end
	end
end


function STATUSBTN:SetAux()
	--empty--
end


function STATUSBTN:SetType(save)

	if (InCombatLockdown()) then
		return
	end

	self:StatusBar_Reset()

	if (kill) then

		self:SetScript("OnEvent", function() end)
		self:SetScript("OnUpdate", function() end)
	else

		if (self.config.sbType == "cast") then

			self.sb:RegisterEvent("UNIT_SPELLCAST_START")
			self.sb:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
			self.sb:RegisterEvent("UNIT_SPELLCAST_STOP")
			self.sb:RegisterEvent("UNIT_SPELLCAST_FAILED")
			self.sb:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
			self.sb:RegisterEvent("UNIT_SPELLCAST_DELAYED")
			self.sb:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
			self.sb:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			self.sb:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
			self.sb:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
			self.sb:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

			self.sb.unit = BarUnits[self.data.unit]
			self.sb.showIcon = self.config.showIcon

			self.sb.showTradeSkills = true
			self.sb.casting = false
			self.sb.channeling = false
			self.sb.holdTime = 0

			self.sb:SetScript("OnEvent", function(self, event, ...) self:GetParent():CastBar_OnEvent(event, ...) end)
			self.sb:SetScript("OnUpdate", function(self, elapsed) self:GetParent():CastBar_OnUpdate(elapsed) end)

			if (not self.sb.cbtimer.castInfo) then
				self.sb.cbtimer.castInfo = {}
			else
				wipe(self.sb.cbtimer.castInfo)
			end

			self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_START")
			self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
			self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_STOP")
			self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
			self.sb.cbtimer:SetScript("OnEvent", function(self, event, ...) self:GetParent():GetParent():CastBarTimer_OnEvent(event, ...) end)

			self.sb:Hide()

		elseif (self.config.sbType == "xp") then

			self:SetAttribute("hasaction", true)

			self:RegisterForClicks("RightButtonUp")
			self:SetScript("OnClick", function(self, mousebutton, down) self:OnClick(mousebutton, down) end)
			self:SetScript("OnEnter", function(self) self:OnEnter() end)
			self:SetScript("OnLeave", function(self) self:OnLeave() end)
			self:SetHitRectInsets(0, 0, 0, 0)

			self.sb:RegisterEvent("PLAYER_XP_UPDATE")
			self.sb:RegisterEvent("HONOR_XP_UPDATE")
			self.sb:RegisterEvent("UPDATE_EXHAUSTION")
			self.sb:RegisterEvent("PLAYER_ENTERING_WORLD")
			self.sb:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
			self.sb:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

			self.sb:SetScript("OnEvent", function(self, event, ...) self:GetParent():XPBar_OnEvent(event, ...) end)

			self.sb:Show()

		elseif (self.config.sbType == "rep") then

			self.sb.repID = self.data.repID

			self:SetAttribute("hasaction", true)

			self:RegisterForClicks("RightButtonUp")
			self:SetScript("OnClick", function(self, mousebutton, down) self:OnClick(mousebutton, down) end)
			self:SetScript("OnEnter", function(self) self:OnEnter() end)
			self:SetScript("OnLeave", function(self) self:OnLeave() end)
			self:SetHitRectInsets(0, 0, 0, 0)

			self.sb:RegisterEvent("UPDATE_FACTION")
			self.sb:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
			self.sb:RegisterEvent("PLAYER_ENTERING_WORLD")

			self.sb:SetScript("OnEvent", function(self, event, ...) self:GetParent():repbar_OnEvent(event, ...) end)

			self.sb:Show()

		elseif (self.config.sbType == "mirror") then

			self.sb:RegisterEvent("MIRROR_TIMER_START")
			self.sb:RegisterEvent("MIRROR_TIMER_STOP")
			self.sb:RegisterEvent("PLAYER_ENTERING_WORLD")


			self.sb:SetScript("OnEvent", function(self, event, ...) self:GetParent():MirrorBar_OnEvent(event, ...) end)

			self.sb:SetScript("OnUpdate", function(self, elapsed) self:GetParent():MirrorBar_OnUpdate(elapsed) end)

			table.insert(MirrorBars, self)

			self.sb:Hide()

		end


		local typeString

		if (self.config.sbType == "xp") then
			typeString = L["XP Bar"]
		elseif (self.config.sbType == "rep") then
			typeString = L["Rep Bar"]
		elseif (self.config.sbType == "cast") then
			typeString = L["Cast Bar"]
		elseif (self.config.sbType == "mirror") then
			typeString = L["Mirror Bar"]
		end

		self.fbframe.feedback.text:SetText(typeString)

	end

	self:SetData(self.bar)

end