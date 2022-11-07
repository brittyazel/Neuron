-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class RepButton : StatusButton @define class RepButton inherits from class StatusButton
local RepButton = setmetatable({}, { __index = Neuron.StatusButton })
Neuron.RepButton = RepButton

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local RepWatch = {}

RepButton.sbStrings = {
	[1] = { L["None"], function() return "" end },
	[2] = { L["Faction"], function(self) if RepWatch[self.repID] then return RepWatch[self.repID].name end end }, --TODO:should probably do the same as above here, just in case people have more than 1 rep bar
	[3] = { L["Current/Next"], function(self) if RepWatch[self.repID] then return RepWatch[self.repID].current end end },
	[4] = { L["Percent"], function(self) if RepWatch[self.repID] then return RepWatch[self.repID].percent end end },
	[5] = { L["Bubbles"], function(self) if RepWatch[self.repID] then return RepWatch[self.repID].bubbles end end },
	[6] = { L["Current Level/Rank"], function(self) if RepWatch[self.repID] then return RepWatch[self.repID].standing end end },
}


---Constructor: Create a new Neuron Button object (this is the base object for all Neuron button types)
---@param bar Bar @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return RepButton @ A newly created StatusButton object
function RepButton.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.StatusButton.new(bar, buttonID, defaults, RepButton, "RepBar", "Rep Button")

	return newButton
end

function RepButton:InitializeButton()
	self:SetAttribute("hasaction", true)

	self:RegisterForClicks("RightButtonUp")
	self:SetScript("OnClick", function(_, mousebutton, down) self:OnClick(mousebutton, down) end)
	self:SetScript("OnEnter", function() self:OnEnter() end)
	self:SetScript("OnLeave", function() self:OnLeave() end)
	self:SetHitRectInsets(0, 0, 0, 0)

	self:RegisterEvent("UPDATE_FACTION", "OnEvent")
	self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")

	self.repID = self.config.repID

	self.StatusBar:Show()
	self.typeString = L["Rep Bar"]

	self:InitializeButtonSettings()
end

--- Creates a table containing provided data
-- @param name, hasFriendStatus, standing, minrep, maxrep, value, colors
-- @return reptable:  Table containing provided data
local function SetRepWatch(ID, name, standing, header, minrep, maxrep, value, colors)
	local reptable = {}
	reptable.ID = ID
	reptable.name = name
	reptable.standing = standing
	reptable.header = header
	reptable.current = (value-minrep).." / "..(maxrep-minrep)
	if maxrep-minrep > 0 then --avoid divide by zero
		reptable.percent = floor(((value-minrep)/(maxrep-minrep))*100).."%"
		reptable.bubbles = tostring(math.floor(((((value-minrep)/(maxrep-minrep))*100)/5))).." / 20 "..L["Bubbles"]
	else
		reptable.percent = "100%"
		reptable.bubbles = "20 / 20 "..L["Bubbles"]
	end
	reptable.min = minrep
	reptable.max = maxrep
	reptable.value = value
	reptable.hex = string.format("%02x%02x%02x", colors.r*255, colors.g*255, colors.b*255)
	reptable.r = colors.r
	reptable.g = colors.g
	reptable.b = colors.b

	return reptable
end

function RepButton:UpdateData(repGainedString)
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
			if Neuron.isWoWRetail then --classic doesn't have Friendships or Paragon, carefull
				friendID, _, _, _, _, _, standing, _, _ = C_GossipInfo.GetFriendshipReputation(factionID)
				isParagon = C_Reputation.IsFactionParagon(factionID)
			end

			if not isParagon then
				colors.r, colors.g, colors.b = BAR_REP_DATA[standingID].r, BAR_REP_DATA[standingID].g, BAR_REP_DATA[standingID].b
				standing = BAR_REP_DATA[standingID].l --convert numerical standingID to text i.e "Exalted" instead of 8
				--if not friendID then --not a "Friendship" faction, i.e. Chromie or Brawlers Guild
				if friendID then --is a "Friendship" faction
					if not string.find(name, "Brawl'gar Arena") or string.find(name, "Bizmo's Brawlpub") then --these two use the normal 9 rank system, the rest use a 7 rank system
						if standingID + 2 > 8 then
							standingID = 7
						end
						colors.r, colors.g, colors.b = BAR_REP_DATA[standingID+2].r, BAR_REP_DATA[standingID+2].g, BAR_REP_DATA[standingID+2].b --offset by two, because friendships don't have "hated" or "hostile" ranks
					end
				end
			else
				local para_value, para_max, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
				standingID = 9
				value = para_value % para_max;
				max = para_max
				if hasRewardPending then
					name = name.." ("..L["Reward"]:upper()..")"
				end
				min = 0
				colors.r, colors.g, colors.b = BAR_REP_DATA[9].r, BAR_REP_DATA[9].g, BAR_REP_DATA[9].b
				standing = BAR_REP_DATA[9].l --set standing text to be "Paragon"
			end

			local repData = SetRepWatch(i, name, standing, header, min, max, value, colors)

			--repGainedString is a phrase that reads like "Reputation with Zandalari Empire increased by 75.", except on login it's type boolean for some reason
			if repGainedString and type(repGainedString) ~= "boolean" and repGainedString:find(name) or self.config.autoWatch == i then --this line automatically assigns the most recently updated repData to RepWatch[0], and the "auto" option assigns RepWatch[0] to be shown
				RepWatch[0] = repData --RepWatch is what holds all of our Repuation data for all of the factions, and the zeroth element is the Autowatch slot, which is always the latest updated data
				self.config.autoWatch = i

				---safety check in case repData comes back as nil, which happens sometimes for some strange reason
				---this will at the very least keep it from being an ugly, grey, empty bar.
				if not RepWatch[0] then
					RepWatch[0] = CopyTable(RepWatch[2]) -- default to the lowest valid rep (RepWatch[1] is a header)
					self.config.autoWatch = 2
				end

			end

			RepWatch[i] = repData --set current reptable into growing RepWatch table
		end
	end
end

function RepButton:OnEvent(event,...)
	self:UpdateData(...)

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


function RepButton:InitializeDropDown() --Initialize the dropdown menu for choosing a rep
	local repDataTable = {}

	for k,v in pairs(RepWatch) do --insert all factions and percentages into "data"
		if k > 0 then --skip the "0" entry which is our autowatch
			if not repDataTable[v.header]then
				repDataTable[v.header] = {}
			end
			table.insert(repDataTable[v.header], { ID=v.ID, name=v.name, standing=v.standing, percent=v.percent, hex=v.hex})		end
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
			self.config.repID = dropdown.value
			self.config.repID = dropdown.value
			self:OnEvent()
		end,
		value=0,
		checked=self.config.repID == 0
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
					self.config.repID = dropdown.value
					self.repID = dropdown.value
					self:OnEvent()
					menuFrame:Hide()
				end,
				value = v2.ID,
				colorCode="|cff"..v2.hex,
				checked = self.config.repID == v2.ID,
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


function RepButton:OnClick(mousebutton)
	if mousebutton == "RightButton" then
		self:InitializeDropDown()
	end
end
