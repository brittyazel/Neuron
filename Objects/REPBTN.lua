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

---@class REPBTN : STATUSBTN @define class REPBTN inherits from class STATUSBTN
local REPBTN = setmetatable({}, { __index = Neuron.STATUSBTN })
Neuron.REPBTN = REPBTN


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

local RepWatch = {}

REPBTN.sbStrings = {
	[1] = { L["None"], function(sb) return "" end },
	[2] = { L["Faction"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].rep end end }, --TODO:should probably do the same as above here, just in case people have more than 1 rep bar
	[3] = { L["Current/Next"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].current end end },
	[4] = { L["Percent"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].percent end end },
	[5] = { L["Bubbles"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].bubbles end end },
	[6] = { L["Current Level/Rank"], function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].rank end end },
}


---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return REPBTN @ A newly created STATUSBTN object
function REPBTN.new(bar, buttonID, defaults)

	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.STATUSBTN.new(bar, buttonID, defaults, REPBTN, "RepBar", "Rep Button")

	return newButton
end



function REPBTN:SetType()

	if InCombatLockdown() then return end

	self.sb.repID = self.config.repID

	self:SetAttribute("hasaction", true)

	self:RegisterForClicks("RightButtonUp")
	self:SetScript("OnClick", function(self, mousebutton, down) self:OnClick(mousebutton, down) end)
	self:SetScript("OnEnter", function(self) self:OnEnter() end)
	self:SetScript("OnLeave", function(self) self:OnLeave() end)
	self:SetHitRectInsets(0, 0, 0, 0)

	self:RegisterEvent("UPDATE_FACTION", "repbar_OnEvent")
	self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "repbar_OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "repbar_OnEvent")

	self.sb:Show()

	local typeString = L["Rep Bar"]

	self.fbframe.feedback.text:SetText(typeString)

	self:SetData(self.bar)

	self:repbar_OnEvent() --we need this here to load the bar when first creating it

end



--- Creates a table containing provided data
-- @param name, hasFriendStatus, standing, minrep, maxrep, value, colors
-- @return reptable:  Table containing provided data
function REPBTN:SetRepWatch(name, hasFriendStatus, standing, minrep, maxrep, value, colors)
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


function REPBTN:repstrings_Update(line)

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

				if (((line and type(line)~= "boolean") and line:find(name)) or self.config.autoWatch == i) then --this line automatically assigns the most recently updated repData to RepWatch[0], and the "auto" option assigns RepWatch[0] to be shown
					RepWatch[0] = repData --RepWatch is what holds all of our Repuation data for all of the factions, and the zeroth element is the Autowatch slot, which is always the latest updated data
					self.config.autoWatch = i

					---safety check in case repData comes back as nil, which happens sometimes for some strange reason
					---this will at the very least keep it from being an ugly, grey, empty bar.
					if not RepWatch[0] then
						RepWatch[0] = CopyTable(RepWatch[2]) -- default to the lowest valid rep (RepWatch[1] is a header)
						self.config.autoWatch = 2
					end

				end

			end

		end
	end
end





function REPBTN:repbar_OnEvent(event,...)

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


function REPBTN:repDropDown_Initialize() --Initialize the dropdown menu for choosing a rep

	if (self.sb) then

		local info = UIDropDownMenu_CreateInfo()
		local checked, repLine, repIndex

		info.arg1 = self
		info.arg2 = nil
		info.text = L["Auto Select"]
		info.func = function(dropdown, self) --self is arg1
			self.config.repID = dropdown.value
			self.sb.repID = dropdown.value
			self:repbar_OnEvent()
		end

		if (self.config.repID == 0) then
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
				self.config.repID = dropdown.value
				self.sb.repID = dropdown.value
				self:repbar_OnEvent()
			end

			if (self.config.repID == ID) then
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


function REPBTN:RepBar_DropDown_OnLoad()

	UIDropDownMenu_Initialize(self.dropdown, function() self:repDropDown_Initialize() end, "MENU")
	self.dropdown_init = true
end


function REPBTN:OnClick(mousebutton)

	if (mousebutton == "RightButton") then
		if not self.dropdown_init then
			self:RepBar_DropDown_OnLoad()
		end


		self:repstrings_Update()

		ToggleDropDownMenu(1, nil, self.dropdown, self, 0, 0)

		DropDownList1:ClearAllPoints()
		DropDownList1:SetPoint("LEFT", self, "RIGHT", 3, 0)
		DropDownList1:SetClampedToScreen(true)

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

	end

end
