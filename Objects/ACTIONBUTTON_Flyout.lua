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
--copyrights for Neuron are held by Britt Yazel, 2017-2019.


local ACTIONBUTTON = Neuron.ACTIONBUTTON
local BAR = Neuron.BAR

local DEBUG = false

local petIcons = {}

--[[ Item Cache ]]
local itemCache = {}
local bagsToCache = {[0]=true,[1]=true,[2]=true,[3]=true,[4]=true,["Worn"]=true }
local timerTimes = {} -- indexed by arbitrary name, the duration to run the timer
local timersRunning = {} -- indexed numerically, timers that are running
local cacheTimeout
local bindTypeAlternatives = { "on pickup","on equip","on use","quest" }

local flyoutsNeedFilled
local firstLogin


local barsToUpdate = {}


local FOBARIndex, FOBTNIndex, ANCHORIndex = {}, {}, {}

Neuron.FOBARIndex = FOBARIndex
Neuron.FOBTNIndex = FOBTNIndex
Neuron.ANCHORIndex = ANCHORIndex

--[[ Timer Management ]]
local timerFrame


--I think this is only used in Neuron-Flyouts
local POINTS = {
	R = "RIGHT",
	L = "LEFT",
	T = "TOP",
	B = "BOTTOM",
	TL = "TOPLEFT",
	TR = "TOPRIGHT",
	BL = "BOTTOMLEFT",
	BR = "BOTTOMRIGHT",
	C = "CENTER",
	RIGHT = "RIGHT",
	LEFT = "LEFT",
	TOP = "TOP",
	BOTTOM = "BOTTOM",
	TOPLEFT = "TOPLEFT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOMLEFT = "BOTTOMLEFT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
	CENTER = "CENTER"
}

------------------------------------------------------------------------------


-----------------------------
---helper funcs--------------
-----------------------------

local function debugPrint(text)
	if DEBUG then print(text) end
end

-- returns true if arg and compareTo match. arg is a [Cc][Aa][Ss][Ee]-insensitive pattern
-- so we can't equate them and to get an exact match we need to append ^ and $ to the pattern
local function compare(arg,compareTo,exact)
	return compareTo:match(format("^%s$",arg)) and true
end

--- Sorting function
local function keySort(list)

	local array = {}

	local i = 0

	for n in pairs(list) do
		table.insert(array, n)
	end

	table.sort(array)

	local sorter = function()
		i = i + 1

		if (array[i] == nil) then
			return nil
		else
			return array[i], list[array[i]]
		end
	end

	return sorter
end

local function timerFrame_OnUpdate(frame, elapsed)

	if Neuron.enteredWorld then
		local tick
		local times = timerTimes
		local timers = timersRunning

		for i=#timers,1,-1 do
			local func = timers[i]
			times[func] = times[func] - elapsed
			if times[func] < 0 then
				table.remove(timers,i)
				func()
			end
			tick = true
		end

		if not tick then
			frame:Hide()
		end
	end
end

---@needles needles: list of strings
---@haystack haystack: string - a string to check in
---@return boolean
local function isAllMatchIn(needles,haystack)
	if haystack == "" then return false end
	local numNeedles, hit = 0, 0
	for k,_ in pairs(needles) do
		numNeedles = numNeedles + 1
		if haystack:match(k) then
			hit = hit + 1
		end
	end
	return hit == numNeedles
end

---@needles needles: list of strings
---@haystack haystack: string - a string to check in
---@return boolean
local function isAnyMatchIn(needles,haystack)
	if haystack == "" then return false end
	local numNeedles, hit = 0, false
	for k,_ in pairs(needles) do
		numNeedles = numNeedles + 1
		if haystack:match(k) then
			hit = true -- mark as hit
			break
		end
	end
	if numNeedles < 1 then return false end
	return hit
end

---@index index: number,
---@bookType bookType: string constant ("spell" or "pet")
---@return string, string, string, number, number
local function getSpellInfo(index, bookType)
	local spellBookSpellName, spellRankOrSubtype = GetSpellBookItemName(index, bookType)
	local spellType,spellIdOrActionId = GetSpellBookItemInfo(index, bookType)
	local name, rank_testing,icon,_,_,_, spellID = GetSpellInfo(index, spellRankOrSubtype)

	if rank_testing then debugPrint("RANNKKKKKK: "..rank_testing) end

	if spellIdOrActionId ~= spellID then
		local _actionId ,_spellID = "nil","nil"
		if spellIdOrActionId then _actionId = spellIdOrActionId end
		if spellID then _spellID = spellID end
		debugPrint("NEURON flyout - spellID: ".._spellID.." != actionID: ".._actionId)
	end
	local return_name = spellBookSpellName
	if(return_name ~= name) then
		debugPrint("Name mismatch! <"..spellBookSpellName.."> != <"..spellBookSpellName.."> using: "..name)
		return_name = name
	end
	return return_name, spellRankOrSubtype, spellType, spellID, icon
end

---@list list: list of strings
---@return string
local function getKeys(list)
	local txt = ""
	for k,_ in pairs(list) do
		if txt == "" then
			txt = txt..k
		else
			txt = txt..", "..k
		end
	end
	return txt
end

--- Filter handler for items
-- item:id will get all items of that itemID
-- item:name will get all items that contain "name" in its name
function ACTIONBUTTON:filter_item(tooltip)

	local data = {}
	local itemTooltips = {}

	local keys, itemSlotMatch, mandatoryMatch, optionalMatch, notMatching = self.flyout.keys, {}, {}, {}, {}
	local numItemSlotMatch, numMandatory, numOptional, numNotMatching = 0,0,0,0
	-- build key check tables
	for ckey in gmatch(keys, "[^,]+") do -- sort requirements
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		arg = arg:lower()
		if cmd:match("~") then
			optionalMatch[arg] = true
			numOptional = numOptional + 1
		elseif cmd:match("!") then
			notMatching[arg] = false
			numNotMatching = numNotMatching + 1
		elseif cmd:match("#") then
			itemSlotMatch[arg] = true
			numItemSlotMatch = numItemSlotMatch + 1
		else
			mandatoryMatch[arg] = true
			numMandatory = numMandatory + 1
		end
	end
	-- build tooltip table
	if (tooltip) then -- part I of tooltip cache version
		for i,v in pairs(bagsToCache) do
			if (tostring(i)):match("Worn") and v then --items worn
				for j=0, 19 do -- go through equip slots
					local itemId = GetInventoryItemID("player",j)
					if (itemId) then
						GameTooltip:SetOwner(UIParent,"ANCHOR_NONE")
						GameTooltip:SetInventoryItem("player",j)
						local itemTooltip = ""
						for l=GameTooltip:NumLines(),2,-1 do
							local text = _G["GameTooltipTextLeft"..l]:GetText()
							if (text) then
								itemTooltip = text.." "..itemTooltip
							end
						end
						itemTooltips[i..":"..j] = "worn "..itemTooltip:lower()
					end
				end
			else --bags
				for j=1, GetContainerNumSlots(i) do
					local itemId = GetContainerItemID(i,j)
					if (itemId) then
						GameTooltip:SetOwner(UIParent,"ANCHOR_NONE")
						GameTooltip:SetBagItem(i,j)
						local itemTooltip = ""
						for l=GameTooltip:NumLines(),2,-1 do
							local text = _G["GameTooltipTextLeft"..l]:GetText()
							if (text) then
								itemTooltip = text.." "..itemTooltip
							end
						end
						itemTooltips[i..":"..j] = itemTooltip:lower()
					end
				end
			end
		end
	end
	-- perform checks
	for i,v in pairs(bagsToCache) do -- Go through bags
		if (tostring(i)):match("Worn") and v then -- items worn
			for j=0, 19 do -- go through equip slots
				local itemId = GetInventoryItemID("player",j)
				if (itemId and itemId ~= 0) then
					local name,_,_,_,_,_,_,_,equipLoc,_,_,_,_,bindType =  GetItemInfo(itemId)
					repeat -- repeat until true gives breaks of the repeat the functionality of a C continue
						if tooltip then
							-- we built the index on the same logic so we know itemTooltips[i..":"..j] exists.
							if isAnyMatchIn(notMatching,itemTooltips[i..":"..j]) or (numItemSlotMatch > 0 and not itemSlotMatch[""..j]) then
								break
							end
							if numMandatory == 0 and numOptional > 0 and isAnyMatchIn(optionalMatch, itemTooltips[i..":"..j]) then
								data[name] = "item"
								break
							end
							if numMandatory > 0 and isAllMatchIn(mandatoryMatch,itemTooltips[i..":"..j]) then
								if (numOptional > 0) and not isAnyMatchIn(optionalMatch, itemTooltips[i..":"..j]) then break end
								data[name] = "item"
								break
							end
						elseif (name) then -- match by name
							local searchTerm = "worn "..(name:lower())
							if (isAnyMatchIn(notMatching,searchTerm) or (numItemSlotMatch > 0 and not itemSlotMatch[""..j])) then
								break
							end
							if (numMandatory == 0 and numOptional > 0 and isAnyMatchIn(optionalMatch, searchTerm)) then
								data[name] = "item"
								break
							end
							if (numMandatory > 0 and isAllMatchIn(mandatoryMatch,searchTerm)) then
								if (numOptional > 0) and not isAnyMatchIn(optionalMatch, searchTerm) then break end
								data[name] = "item"
								break
							end
						end
					until true
					if (name and data[name] and (not NeuronItemCache[name])) then
						NeuronItemCache[name] = itemId -- if it isn't in the items cache the icon and tooltip won't show.
					end
				end
			end
		else -- bags
			for j=1, GetContainerNumSlots(i) do
				local itemId = GetContainerItemID(i,j)
				if (itemId) then
					local name,_,_,_,_,_,_,_,_,_,_,_,_,bindType =  GetItemInfo(itemId)
					if name then
						repeat -- repeat until true gives breaks of the repeat the functionality of a C continue
							if tooltip then
								-- we built the index on the same logic so we know itemTooltips[i..":"..j] exists.
								if isAnyMatchIn(notMatching,name:lower().." "..itemTooltips[i..":"..j]) or (numItemSlotMatch > 0 and not itemSlotMatch[""..j]) then
									break
								end
								if numMandatory == 0 and numOptional > 0 and isAnyMatchIn(optionalMatch, name:lower().." "..itemTooltips[i..":"..j]) then
									data[name] = "item"
									break
								end
								if numMandatory > 0 and isAllMatchIn(mandatoryMatch,name:lower().." "..itemTooltips[i..":"..j]) then
									if (numOptional > 0) and not isAnyMatchIn(optionalMatch, name:lower().." "..itemTooltips[i..":"..j]) then break end
									data[name] = "item"
									break
								end
							elseif (name) then -- match by name
								if isAnyMatchIn(notMatching,name:lower()) or (numItemSlotMatch > 0 and not itemSlotMatch[""..j]) then
									break
								end
								if (numMandatory == 0 and numOptional > 0 and isAnyMatchIn(optionalMatch, name:lower())) then
									data[name] = "item"
									break
								end
								if (numMandatory > 0 and isAllMatchIn(mandatoryMatch,name:lower())) then
									if (numOptional > 0) and not isAnyMatchIn(optionalMatch, name:lower()) then break end
									data[name] = "item"
									break
								end
							end
						until true
						if (data[name] and not NeuronItemCache[name]) then
							NeuronItemCache[name] = itemId -- if it isn't in the items cache the icon and tooltip won't show.
						end
					end
				end
			end
		end
	end

	return data
end


--- Filter Handler for Spells
-- spell:id will get all spells of that spellID
-- spell:name will get all spells that contain "name" in its name or its flyout parent
function ACTIONBUTTON:filter_spell(tooltip)
	--local keys, found, mandatory, optional = self.flyout.keys, 0, 0, 0

	local data = {}
	local oldData = {}

	local spellTooltips = {}

	local keys, mandatoryMatch, optionalMatch, notMatching = self.flyout.keys, {}, {}, {}
	local numMandatory, numOptional, numNotMatching = 0,0,0,0

	-- build key check tables
	for ckey in gmatch(keys, "[^,]+") do -- sort requirements
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		arg = arg:lower()

		if cmd:match("~") then
			optionalMatch[arg] = true
			numOptional = numOptional + 1
		elseif cmd:match("!") then
			notMatching[arg] = false
			numNotMatching = numNotMatching + 1
		else
			mandatoryMatch[arg] = true
			numMandatory = numMandatory + 1
		end
	end
	-- build tooltip table
	if (tooltip) then
		for i=1, GetNumSpellTabs() do
			local _,_,numSpellsInPrevTabs,entries = GetSpellTabInfo(i)
			for j=numSpellsInPrevTabs + 1, numSpellsInPrevTabs + entries do -- go through entries
				local bookType = BOOKTYPE_SPELL
				if i == 5 and HasPetSpells() then
					bookType = BOOKTYPE_PET --assumed a fifth tab is a pet tab.
					debugPrint("NEURON - spellbook tab 5 is presumed to be a pet spell tab!")
				end
				local name, rank, spellType, spellID, icon = getSpellInfo(j,bookType)

				repeat -- repeat until true gives breaks of the repeat the functionality of a C continue
					if IsPassiveSpell(j,bookType) then break end
					if not IsSpellKnown(spellID,bookType == BOOKTYPE_PET) then break end

					if (("SPELL FUTURESPELL"):match(spellType) and spellID) then
						GameTooltip:SetOwner(UIParent,"ANCHOR_NONE")
						GameTooltip:SetSpellBookItem(j, spellType)
						-- GameTooltip:SetSpellByID(spellIdOrActionId)
						local spellTooltip = ""
						for l=GameTooltip:NumLines(),2,-1 do
							local text = _G["GameTooltipTextLeft"..l]:GetText()
							if (text) then
								spellTooltip = text.." "..spellTooltip
							end
						end
						spellTooltips[i..":"..j] = spellTooltip:lower()
					end
				until true
			end
		end
	end
	-- perform checks
	for i=1, GetNumSpellTabs() do -- Go through spell tabs
		local _,_,numSpellsInPrevTabs,entries = GetSpellTabInfo(i)
		for j=numSpellsInPrevTabs + 1, numSpellsInPrevTabs + entries do -- go through entries
			local bookType = BOOKTYPE_SPELL
			if i == 5 and HasPetSpells() then
				bookType = BOOKTYPE_PET --assumed a fifth tab is a pet tab.
				debugPrint("NEURON - spellbook tab 5 is presumed to be a pet spell tab!")
			end
			local name, rank, spellType, spellID, icon = getSpellInfo(j,bookType)

			local searchTerm = name
			if rank then
				searchTerm = searchTerm.."("..rank..")"
			else
				debugPrint("Spell subtype/rank N/A! <"..name..">")
			end

			repeat -- repeat until true gives breaks of the repeat the functionality of a C continue
				if IsPassiveSpell(j,bookType) then break end
				if not IsSpellKnown(spellID,bookType == BOOKTYPE_PET) then break end

				if (("SPELL FUTURESPELL"):match(spellType) and spellID) then
					if tooltip then
						-- we built the index on the same logic so we know itemTooltips[i..":"..j] exists.
						if isAnyMatchIn(notMatching,searchTerm:lower().." "..spellTooltips[i..":"..j]) then
							break
						end
						if numMandatory == 0 and numOptional > 0 and isAnyMatchIn(optionalMatch, searchTerm:lower().." "..spellTooltips[i..":"..j]) then
							data[searchTerm:lower()] = "spell"
							break
						end
						if numMandatory > 0 and isAllMatchIn(mandatoryMatch,searchTerm:lower().." "..spellTooltips[i..":"..j]) then
							if (numOptional > 0) and not isAnyMatchIn(optionalMatch, searchTerm:lower().." "..spellTooltips[i..":"..j]) then break end
							data[searchTerm:lower()] = "spell"
							break
						end
					else -- match by name
						if isAnyMatchIn(notMatching,searchTerm:lower()) then
							break
						end
						if (numMandatory == 0 and numOptional > 0 and isAnyMatchIn(optionalMatch, searchTerm:lower())) then
							data[searchTerm:lower()] = "spell"
							break
						end
						if (numMandatory > 0 and isAllMatchIn(mandatoryMatch,searchTerm:lower())) then
							if (numOptional > 0) and not isAnyMatchIn(optionalMatch, searchTerm:lower()) then break end
							data[searchTerm:lower()] = "spell"
							break
						end
					end
				else
					debugPrint("spell type: "..spellType)
				end
			until true
			if (data[searchTerm:lower()] and not (NeuronSpellCache[name:lower()] or NeuronSpellCache[name:lower().."()"])) then
				-- if it isn't in the items cache the icon and tooltip won't show.
				NeuronSpellCache[name:lower()] = { ["booktype"] = bookType,["index"] = j, ["spellType"] = spellType,["spellID"]= spellID, ["icon"]=icon,["spellName"]=name }
				NeuronSpellCache[name:lower().."()"] = { ["booktype"] = bookType,["index"] = j, ["spellType"] = spellType,["spellID"]= spellID, ["icon"]=icon,["spellName"]=name }
			end
		end
	end
	return data
end


---Filter handler for item type
-- type:quest will get all quest items in bags, or those on person with Quest in a type field
-- type:name will get all items that have "name" in its type, subtype or slot name
function ACTIONBUTTON:filter_type()
	local keys, found, mandatory, optional = self.flyout.keys, 0, 0, 0

	local data = {}

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		arg = arg:lower()

		if ("quest"):match(arg) then
			-- many quest items don't have "Quest" in a type field, but GetContainerItemQuestInfo
			-- has them flagged as questf.  check those first
			for i=0,4 do
				for j=1,GetContainerNumSlots(i) do
					local isQuestItem, questID, isActive = GetContainerItemQuestInfo(i,j)
					if isQuestItem or questID or isActive then
						data[(format("item:%d",GetContainerItemID(i,j))):lower()] = "item"
					end
				end
			end
		end
		-- some quest items can be marked quest as an item type also
		for itemID,name in pairs(itemCache) do
			if GetItemCount(name)>0 then
				local _, _, _, _, _, itemType, itemSubType, _, itemSlot = GetItemInfo(itemID)
				if itemType and ((itemType:lower()):match(arg) or (itemSubType:lower()):match(arg) or (itemSlot:lower()):match(arg)) then
					data[itemID:lower()] = "item"
				end
			end
		end
	end

	return data
end


--- Filter handler for mounts
-- mount:any, mount:flying, mount:land, mount:favorite, mount:fflying, mount:fland
-- mount:arg filters mounts that include arg in the name or arg="flying" or arg="land" or arg=="any"
function ACTIONBUTTON:filter_mount()
	local keys, found, mandatory, optional = self.flyout.keys, 0, 0, 0

	local data = {}

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		local any = compare(string.lower(arg),"any")
		local flying = compare(string.lower(arg),"flying")
		local land = compare(string.lower(arg),"land")
		local fflying = compare(string.lower(arg),"fflying") or compare(string.lower(arg),"favflying")
		local fland = compare(string.lower(arg),"fland") or compare(string.lower(arg),"favland")
		local favorite = compare(string.lower(arg),"favorite") or fflying or fland
		arg = arg:lower()

		for i,mountID in ipairs(C_MountJournal.GetMountIDs()) do

			local mountName, mountSpellId, mountTexture, _, canSummon, _, isFavorite = C_MountJournal.GetMountInfoByID(mountID)
			local spellName = GetSpellInfo(mountSpellId) -- sometimes mount name isn't same as spell name >:O

			mountName = mountName:lower()
			spellName = spellName:lower()

			if mountName and canSummon then

				local _,_,_,_,mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
				local canFly = mountType==247 or mountType==248

				if favorite and isFavorite then
					if (fflying and canFly) or (fland and not canFly) or (not fflying and not fland) then
						data[spellName] = "spell"
					end
				elseif (flying and canFly) or (land and not canFly) then
					data[spellName] = "spell"
				elseif any or mountName:match(arg) or spellName:match(arg) then
					data[spellName] = "spell"
				end
			end
		end

	end

	return data

end



--- Filter handler for professions
-- profession:arg filters professions that include arg in the name or arg="primary" or arg="secondary" or arg="all"
function ACTIONBUTTON:filter_profession()

	local data = {}

	-- runs func for each ...
	local function RunForEach(func,...)
		for i=1,select("#",...) do
			func((select(i,...)))
		end
	end

	local professions = {}

	local keys, found, mandatory, optional = self.flyout.keys, 0, 0, 0
	local profSpells = {}

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")

		RunForEach(function(entry) table.insert(professions,entry or false) end, GetProfessions())
		local any = compare(string.lower(arg),"any")
		local primaryOnly = compare(string.lower(arg),"primary")
		local secondaryOnly = compare(string.lower(arg),"secondary")
		arg = arg:lower()
		for index,profession in pairs(professions) do
			if profession then
				local name, _, _, _, numSpells, offset = GetProfessionInfo(profession)
				if (index<3 and primaryOnly) or (index>2 and secondaryOnly) or any or (name:lower()):match(arg) then
					for i=1,numSpells do
						local _, spellID = GetSpellBookItemInfo(offset+i,"professions")
						local spellName = GetSpellInfo(spellID)
						local isPassive = IsPassiveSpell(offset+i,"professions")

						if not isPassive then
							table.insert(profSpells, spellName:lower())
							data[spellName:lower()] = "spell"
						end
					end
				end
			end
		end

	end

	return data
end


--- Filter handler for companion pets
-- pet:arg filters companion pets that include arg in the name or arg="any" or arg="favorite(s)"
function ACTIONBUTTON:filter_pet()

	local data = {}

	local keys = self.flyout.keys
	for ckey in gmatch(keys, "[^,]+") do

		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")



		local speciesID, _ = C_PetJournal.FindPetIDByName(arg)


		local speciesName, speciesIcon = C_PetJournal.GetPetInfoBySpeciesID(speciesID)

		if speciesName then
			data[speciesName] = "companion"
			petIcons[speciesName] = speciesIcon
		end

	end

	return data
end


---Filter handler for toy items
-- toy:arg filters items from the toybox; arg="favorite" "any" or partial name
function ACTIONBUTTON:filter_toy()
	local keys, found, mandatory, optional = self.flyout.keys, 0, 0, 0

	local data = {}

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		local any = compare(string.lower(arg),"any")
		local favorite = compare(string.lower(arg),"favorite")
		arg = arg:lower()

		local name= GetItemInfo(arg)

		if name then
			data[name] = "item"
		end

	end

	return data

end


--- Handler for Blizzard flyout spells
function ACTIONBUTTON:GetBlizzData()

	local data = {}

	local visible, spellID, isKnown, petIndex, petName, spell, subName
	local _, _, numSlots = GetFlyoutInfo(self.flyout.keys)

	for i=1, numSlots do
		visible = true

		spellID, _, isKnown = GetFlyoutSlotInfo(self.flyout.keys, i)
		petIndex, petName = GetCallPetSpellInfo(spellID)

		if (petIndex and (not petName or petName == "")) then
			visible = false
		end

		if (isKnown and visible) then
			spell = GetSpellInfo(spellID)

			data[spell] = "blizz"
		end
	end
	return data
end


--- Flyout type handler
function ACTIONBUTTON:GetDataList(options)
	local tooltip

	local scanData = {}

	for types in gmatch(self.flyout.types, "%a+[%+]*") do
		tooltip = types:match("%+")

		if (types:find("^b")) then  --Blizzard Flyout
			scanData = self:GetBlizzData()
		elseif (types:find("^s")) then  --Spell
			scanData = self:filter_spell(tooltip)
		elseif (types:find("^i")) then  --Item
			scanData = self:filter_item(tooltip)
		elseif (types:find("^c")) and not Neuron.isWoWClassic then --Companion
			scanData = self:filter_pet()
		elseif (types:find("^f")) and not Neuron.isWoWClassic then  --toy
			scanData = self:filter_toy()
		elseif (types:find("^m")) then  --Mount
			scanData = self:filter_mount()
		elseif (types:find("^p")) and not Neuron.isWoWClassic then  --Profession
			scanData = self:filter_profession()
		elseif (types:find("^t")) then  --Item Type
			scanData = self:filter_type()
		end
	end
	return scanData
end

function ACTIONBUTTON:updateFlyoutBars(elapsed)

	if (not InCombatLockdown() and Neuron.enteredWorld) then  --Workarout for protected taint if UI reload in combat
		local bar = table.remove(barsToUpdate) ---this does nothing. It makes bar empty

		if (bar) then
			bar:SetObjectLoc()
			bar:SetPerimeter()
			bar:SetSize()
		else
			self:Hide()
		end
	end
end





function ACTIONBUTTON:Flyout_UpdateButtons(init)
	local slot
	local pet = false

	if (self.flyout) then
		local count, list = 0, {}
		local button, prefix, macroSet

		local data = self:GetDataList(self.flyout.options)

		for _,val in pairs(self.flyout.buttons) do
			self:Flyout_ReleaseButton(val)
		end

		if (data) then
			for spell, source in keySort(data) do

				button = self:Flyout_GetButton()

				button.source = source


				if (source == "spell" or source =="blizz") then
					if (spell:find("%(")) then
						button.macroshow = spell
					else
						button.macroshow = spell.."()"
					end

					button:SetAttribute("prefix", "/cast ")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")


					prefix = "/cast "

				elseif (source == "companion") then

					button.macroshow = spell
					button:SetAttribute("prefix", "/summonpet ")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					button.data.macro_Name = spell
					button:SetAttribute("macro_Name", spell)
					prefix = "/summonpet "

				elseif (source == "mount") then
					button.macroshow = spell
					button:SetAttribute("prefix", "/summonpet ")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					prefix = "/summonpet "


				elseif (source == "item") then

					if (IsEquippableItem(spell)) then
						if (self.flyout.keys:find("#%d+")) then
							slot = self.flyout.keys:match("%d+").." "
						end

						if (slot) then
							prefix = "/equipslot "
							button:SetAttribute("slot", slot.." ")
						else
							prefix = "/equip "
							button:SetAttribute("prefix", "/equip ")
						end
					else
						prefix = "/use "
						button:SetAttribute("prefix", "/use ")
					end

					local itemname = GetItemInfo(spell)

					button.macroshow = spell
					button.data.macro_Name = itemname


					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")

					if (slot) then
						button:SetAttribute("showtooltip", "#showtooltip "..slot.."\n")
					else
						button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					end

				elseif (source:find("equipset")) then
					button.macroshow = spell
					button.data.macro_Equip = spell
					button:SetAttribute("prefix", "/equipset ")
					button:SetAttribute("showtooltip", "")

					prefix = "/equipset "

				else
					--should never get here
					button.macroshow = ""
					button:SetAttribute("prefix", "")
					button:SetAttribute("showtooltip", "")
				end

				if (slot) then
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..slot)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..slot..button.macroshow)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..slot.."\n/stopmacro [nobtn:2]\n/flyout "..self.lyout.options)
				elseif (pet) then
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..pet)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..pet)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..pet.."\n/stopmacro [nobtn:2]\n/flyout "..self.flyout.options)
				else
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..button.macroshow)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..button.macroshow)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..button.macroshow.."\n/stopmacro [nobtn:2]\n/flyout "..self.flyout.options)
				end

				if (not macroSet and not self.data.macro_Text:find("nobtn:2")) then
					self.data.macro_Text = button:GetAttribute("flyoutMacro")
					macroSet = true
				end

				button.data.macro_Text = button:GetAttribute("macro_Text")
				button:UpdateParse()
				button:MACRO_Reset()
				button:UpdateAll()

				list[#list+1] = button.id--table.insert(list, button.id)

				count = count + 1
			end
		end

		self.flyout.bar.objCount = count
		self.flyout.bar.data.objectList = list

		if (not init) then
			table.insert(barsToUpdate, self.flyout.bar)
			self:updateFlyoutBars()
		end
	end
end



function ACTIONBUTTON:Flyout_UpdateBar()
	self.flyouttop:Hide()
	self.flyoutbottom:Hide()
	self.flyoutleft:Hide()
	self.flyoutright:Hide()

	local flyout = self.flyout
	local pointA, pointB, hideArrow, shape, columns, pad

	if (flyout.shape and flyout.shape:lower():find("^c")) then
		shape = 2
	else
		shape = 1
	end

	if (flyout.point) then
		pointA = flyout.point:match("%a+"):upper() pointA = POINTS[pointA] or "RIGHT"
	end

	if (flyout.relPoint) then
		pointB = flyout.relPoint:upper() pointB = POINTS[pointB] or "LEFT"
	end

	if (flyout.colrad and tonumber(flyout.colrad)) then
		if (shape == 1) then
			columns = tonumber(flyout.colrad)
		elseif (shape == 2) then
			pad = tonumber(flyout.colrad)
		end
	end

	if (flyout.mode and flyout.mode:lower():find("^m")) then
		flyout.mode = "mouse"
	else
		flyout.mode = "click"
	end

	if (flyout.hideArrow and flyout.hideArrow:lower():find("^h")) then
		hideArrow = true
	end

	if (shape) then
		flyout.bar.data.shape = shape
	else
		flyout.bar.data.shape = 1
	end

	if (columns) then
		flyout.bar.data.columns = columns
	else
		flyout.bar.data.columns = 12
	end

	if (pad) then
		flyout.bar.data.padH = pad
		flyout.bar.data.padV = pad
		flyout.bar.data.arcStart = 0
		flyout.bar.data.arcLength = 359
	else
		flyout.bar.data.padH = 0
		flyout.bar.data.padV = 0
		flyout.bar.data.arcStart = 0
		flyout.bar.data.arcLength = 359
	end
	flyout.bar:ClearAllPoints()
	flyout.bar:SetPoint(pointA, self, pointB, 0, 0)
	flyout.bar:SetFrameStrata(self:GetFrameStrata())
	flyout.bar:SetFrameLevel(self:GetFrameLevel()+1)

	if (not hideArrow) then
		if (pointB == "TOP") then
			self.flyout.arrowPoint = "TOP"
			self.flyout.arrowX = 0
			self.flyout.arrowY = 5
			self.flyout.arrow = self.flyouttop
			self.flyout.arrow:Show()
		elseif (pointB == "BOTTOM") then
			self.flyout.arrowPoint = "BOTTOM"
			self.flyout.arrowX = 0
			self.flyout.arrowY = -5
			self.flyout.arrow = self.flyoutbottom
			self.flyout.arrow:Show()
		elseif (pointB == "LEFT") then
			self.flyout.arrowPoint = "LEFT"
			self.flyout.arrowX = -5
			self.flyout.arrowY = 0
			self.flyout.arrow = self.flyoutleft
			self.flyout.arrow:Show()
		elseif (pointB == "RIGHT") then
			self.flyout.arrowPoint = "RIGHT"
			self.flyout.arrowX = 5
			self.flyout.arrowY = 0
			self.flyout.arrow = self.flyoutright
			self.flyout.arrow:Show()
		end
	end

	self:Anchor_Update()

	table.insert(barsToUpdate, flyout.bar)

	self:updateFlyoutBars()
end


function ACTIONBUTTON:Flyout_RemoveButtons()
	for _,button in pairs(self.flyout.buttons) do
		self:Flyout_ReleaseButton(button)
	end
end

function ACTIONBUTTON:Flyout_RemoveBar()
	self.flyouttop:Hide()
	self.flyoutbottom:Hide()
	self.flyoutleft:Hide()
	self.flyoutright:Hide()

	self:Anchor_Update(true)

	self:Flyout_ReleaseBar(self.flyout.bar)
end

function ACTIONBUTTON:UpdateFlyout(init)
	local options

	if self.data.macro_Text then
		options = self.data.macro_Text:match("/flyout%s(%C+)")
	end

	if (self.flyout) then
		self:Flyout_RemoveButtons()
		self:Flyout_RemoveBar()
	end

	if (options) then
		if (not self.flyout) then
			self.flyout = { buttons = {} }
		end


		self.flyout.bar = self:Flyout_GetBar()
		self.flyout.options = options
		self.flyout.types = select(1, (":"):split(options))
		self.flyout.keys = select(2, (":"):split(options))
		self.flyout.shape = select(3, (":"):split(options))
		self.flyout.point = select(4, (":"):split(options))
		self.flyout.relPoint = select(5, (":"):split(options))
		self.flyout.colrad = select(6, (":"):split(options))
		self.flyout.mode = select(7, (":"):split(options))
		self.flyout.hideArrow = select(8, (":"):split(options))

		self:Flyout_UpdateButtons(init)
		self:Flyout_UpdateBar()

		if (not self.bar.watchframes) then
			self.bar.watchframes = {}
		end

		self.bar.watchframes[self.flyout.bar.handler] = true

		ANCHORIndex[self] = true
	else
		ANCHORIndex[self] = nil
		self.flyout = nil
	end
end


function ACTIONBUTTON:Flyout_ReleaseButton(button)
	self.flyout.buttons[button.id] = nil

	button.stored = true

	button.data.macro_Text = ""
	button.data.macro_Equip = false
	button.data.macro_Icon = false

	button.macrospell = nil
	button.macroitem = nil
	button.macroshow = nil
	button.macroBtn = nil
	button.bar = nil

	button:SetAttribute("*macrotext1", nil)
	button:SetAttribute("flyoutMacro", nil)

	button:ClearAllPoints()
	button:SetPoint("CENTER")
	button:Hide()
end


function ACTIONBUTTON:Flyout_SetData(bar)
	if (bar) then

		self.bar = bar

		self.tooltips = true
		self.tooltipsEnhanced = true
		--self.tooltipsCombat = bar.data.tooltipsCombat
		--self:SetFrameStrata(bar.data.objectStrata)
		--self:SetScale(bar.data.scale)
	end

	self.hotkey:Hide()
	self.macroname:Hide()
	self:RegisterForClicks("AnyUp")

	self.equipcolor = { 0.1, 1, 0.1, 1 }
	self.cdcolor1 = { 1, 0.82, 0, 1 }
	self.cdcolor2 = { 1, 0.1, 0.1, 1 }
	self.auracolor1 = { 0, 0.82, 0, 1 }
	self.auracolor2 = { 1, 0.1, 0.1, 1 }
	self.buffcolor = { 0, 0.8, 0, 1 }
	self.debuffcolor = { 0.8, 0, 0, 1 }
	self.manacolor = { 0.5, 0.5, 1.0 }
	self.rangecolor = { 0.7, 0.15, 0.15, 1 }

	self:GetSkinned()
end


function ACTIONBUTTON:Flyout_PostClick()

	local button = self.anchor

	button.data.macro_Text = self:GetAttribute("flyoutMacro")
	button.data.macro_Icon = self:GetAttribute("macro_Icon") or false
	button.data.macro_Name = self:GetAttribute("macro_Name") or nil

	button:UpdateParse()
	button:MACRO_Reset()
	button:UpdateAll()

	self:UpdateState()
end

function ACTIONBUTTON:Flyout_GetButton()

	local id = 1

	for _,button in ipairs(FOBTNIndex) do
		if (button.stored) then
			button.anchor = self
			button.bar = self.flyout.bar
			button.stored = false

			self.flyout.buttons[button.id] = button

			button:Show()
			return button
		end

		id = id + 1
	end

	local button = CreateFrame("CheckButton", self:GetName().."_".."NeuronFlyoutButton"..id, UIParent, "NeuronActionButtonTemplate") --create the new button frame using the desired parameters
	setmetatable(button, {__index = ACTIONBUTTON})

	button.elapsed = 0

	local objects = Neuron:GetParentKeys(button)

	for k,v in pairs(objects) do
		local name = (v):gsub(button:GetName(), "")
		button[name:lower()] = _G[v]
	end

	button.class = "flyout"
	button.id = id
	button:SetID(0)
	button:SetToplevel(true)
	button.objTIndex = id
	button.objType = "FLYOUTBUTTON"
	button.data = { macro_Text = "" }

	button.anchor = self
	button.bar = self.flyout.bar
	button.stored = false

	SecureHandler_OnLoad(button)

	button:SetAttribute("type1", "macro")
	button:SetAttribute("*macrotext1", "")

	button:SetScript("PostClick", function(self) self:Flyout_PostClick() end)
	button:SetScript("OnEnter", function(self, ...) self:OnEnter(...) end)
	button:SetScript("OnLeave", function(self, ...) self:OnLeave(...) end)

	button:SetScript("OnShow", function(self) self:UpdateButton(); self:UpdateIcon(); self:UpdateState() end)
	button:SetScript("OnHide", function(self) self:UpdateButton(); self:UpdateIcon(); self:UpdateState() end)

	button:WrapScript(button, "OnClick", [[
			local button = self:GetParent():GetParent()
			button:SetAttribute("macroUpdate", true)
			button:SetAttribute("*macrotext*", self:GetAttribute("flyoutMacro"))
			self:GetParent():Hide()
	]])


	--link objects to their associated functions
	button.SetData = ACTIONBUTTON.Flyout_SetData


	button:SetData(self.flyout.bar)

	button:Flyout_UpdateButtons(true)
	button:SetSkinned(true)
	button:Show()

	self.flyout.buttons[id] = button

	FOBTNIndex[id] = button

	return button
end


function ACTIONBUTTON:Flyout_ReleaseBar(bar)
	self.flyout.bar = nil

	bar.stored = true
	bar:SetWidth(43)
	bar:SetHeight(43)

	bar:ClearAllPoints()
	bar:SetPoint("CENTER")

	self.bar.watchframes[bar.handler] = nil
end

function BAR:Flyout_OnEvent()
	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
end


function ACTIONBUTTON:Flyout_GetBar()
	local id = 1

	for _,bar in ipairs(FOBARIndex) do
		if (bar.stored) then
			bar.stored = false
			bar:SetParent(UIParent)
			return bar
		end

		id = id + 1
	end

	local bar = CreateFrame("CheckButton", self:GetName().."_".."NeuronFlyoutBar"..id, UIParent, "NeuronBarTemplate")
	setmetatable(bar, {__index = Neuron.BAR})

	bar.class = "FlyoutBar"
	bar.elapsed = 0
	bar.data = { scale = 1 }

	bar.text:Hide()
	bar.message:Hide()
	bar.messagebg:Hide()

	bar:SetID(id)
	bar:SetWidth(43)
	bar:SetHeight(43)
	bar:SetFrameLevel(2)

	bar:RegisterEvent("PLAYER_ENTERING_WORLD", "Flyout_OnEvent")

	if not bar.data.objectList then
		bar.data.objectList = {}
	end

	bar:Hide()

	bar.handler = CreateFrame("Frame", "NeuronFlyoutHandler"..id, UIParent, "SecureHandlerStateTemplate, SecureHandlerShowHideTemplate")
	bar.handler:SetAttribute("state-current", "homestate")
	bar.handler:SetAttribute("state-last", "homestate")
	bar.handler:SetAttribute("showstates", "homestate")
	bar.handler:SetScript("OnShow", function() end)
	bar.handler:SetAllPoints(bar)
	bar.handler.bar = bar
	bar.handler.elapsed = 0

	--bar.handler:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
	--bar.handler:SetBackdropColor(0,0,0,1)
	--bar.handler:SetBackdropBorderColor(0,0,0,1)

	----we need to activate all of these frames at least once. This place is as good as any I guess

	--[[ Timer Management ]]
	if not timerFrame then
		timerFrame = CreateFrame("Frame") -- timer independent of main frame visibility
		timerFrame:Hide()
		timerFrame:SetScript("OnUpdate", timerFrame_OnUpdate)
	end

	bar.handler:Hide()

	FOBARIndex[id] = bar
	return bar
end


function ACTIONBUTTON:Anchor_RemoveChild()
	local child = self.flyout.bar and self.flyout.bar.handler

	if (child) then
		self:UnwrapScript(self, "OnEnter")
		self:UnwrapScript(self, "OnLeave")
		self:UnwrapScript(self, "OnClick")
		self:SetAttribute("click-show", nil)

		child:SetAttribute("timedelay", nil)
		child:SetAttribute("_childupdate-onmouse", nil)
		child:SetAttribute("_childupdate-onclick", nil)

		child:UnwrapScript(child, "OnShow")
		child:UnwrapScript(child, "OnHide")
	end
end

function ACTIONBUTTON:Anchor_UpdateChild()
	local child = self.flyout.bar and self.flyout.bar.handler

	if (child) then
		local mode = self.flyout.mode
		local delay

		if (mode == "click") then
			self:SetAttribute("click-show", "hide")
			self:WrapScript(self, "OnClick", [[
							if (button == "RightButton") then
								if (self:GetAttribute("click-show") == "hide") then
									self:SetAttribute("click-show", "show")
								else
									self:SetAttribute("click-show", "hide")
								end
								control:ChildUpdate("onclick", self:GetAttribute("click-show"))
							end
							]])

			child:WrapScript(child, "OnShow", [[
							if (self:GetAttribute("timedelay")) then
								self:RegisterAutoHide(self:GetAttribute("timedelay"))
							else
								self:UnregisterAutoHide()
							end
							]])

			child:WrapScript(child, "OnHide", [[ self:GetParent():SetAttribute("click-show", "hide") self:UnregisterAutoHide() ]])

			child:SetAttribute("timedelay", tonumber(delay) or 0)
			child:SetAttribute("_childupdate-onclick", [[ if (message == "show") then self:Show() else self:Hide() end ]] )

			child:SetParent(self)

		elseif (mode == "mouse") then
			self:WrapScript(self, "OnEnter", [[ control:ChildUpdate("onmouse", "enter") ]])
			self:WrapScript(self, "OnLeave", [[ if (not self:IsUnderMouse(true)) then control:ChildUpdate("onmouse", "leave") end ]])

			child:SetAttribute("timedelay", tonumber(delay) or 0)
			child:SetAttribute("_childupdate-onmouse", [[ if (message == "enter") then self:Show() elseif (message == "leave") then self:Hide() end ]] )

			child:WrapScript(child, "OnShow", [[
							if (self:GetAttribute("timedelay")) then
								self:RegisterAutoHide(self:GetAttribute("timedelay"))
							else
								self:UnregisterAutoHide()
							end
							]])

			child:WrapScript(child, "OnHide", [[ self:UnregisterAutoHide() ]])

			child:SetParent(self)
		end
	end
end


function ACTIONBUTTON:Anchor_Update(remove)

	if (remove) then
		self:Anchor_RemoveChild()
	else
		self:Anchor_UpdateChild()
	end
end



--[[function ACTIONBUTTON.addToCache(itemID)
	if itemID then
		local name = GetItemInfo(itemID)
		if name then
			itemCache[format("item:%d",itemID)] = name:lower()
		else
			self:ScheduleTimer("CacheBags", 0.05)
			return true
		end
	end
end


function ACTIONBUTTON.CacheBags()
	local cacheComplete = true

	for bag in pairs(bagsToCache) do
		if not cacheTimeout or cacheTimeout < 10 then
			if bag=="Worn" then
				for slot=1,19 do
					local itemID = GetInventoryItemID("player",slot)
					if ACTIONBUTTON.addToCache(itemID) then
						cacheComplete = false
					end
				end
			else
				for slot=1,GetContainerNumSlots(bag) do
					local itemID = GetContainerItemID(bag,slot)
					if ACTIONBUTTON.addToCache(itemID) then
						cacheComplete = false
					end
				end
			end

		end
	end

	if cacheComplete then
		flyoutsNeedFilled = true
		wipe(bagsToCache)
		if firstLogin then
			firstLogin = nil
			--f.FillAttributes()
		end
	else
		cacheTimeout = (cacheTimeout or 0)+1
	end
end]]