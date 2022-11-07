-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local ActionButton = Neuron.ActionButton
local Bar = Neuron.Bar

local petIcons = {}

--[[ Item Cache ]]
local bagsToCache = {[0]=true,[1]=true,[2]=true,[3]=true,[4]=true,["Worn"]=true }
local timerTimes = {} -- indexed by arbitrary name, the duration to run the timer
local timersRunning = {} -- indexed numerically, timers that are running

local barsToUpdate = {}

local FOBarIndex, FOBtnIndex, AnchorIndex = {}, {}, {}

Neuron.FOBarIndex = FOBarIndex
Neuron.FOBtnIndex = FOBtnIndex
Neuron.AnchorIndex = AnchorIndex

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
		if array[i] == nil then
			return nil
		else
			return array[i], list[array[i]]
		end
	end

	return sorter
end

local function timerFrame_OnUpdate(frame, elapsed)
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

---@param needles table<number,string>: list of strings
---@param haystack string - a string to check in
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

---@param needles: list of strings
---@param haystack: string - a string to check in
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

---@param index number,
---@param bookType string constant ("spell" or "pet")
---@return string, string, string, number, number name, rank|subType, spellType, spellID, icon
local function getSpellInfo(index, bookType)
	local spellBookSpellName, spellRankOrSubtype = GetSpellBookItemName(index, bookType)
	local spellType,spellIdOrActionId = GetSpellBookItemInfo(index, bookType)
	local _,_, icon = GetSpellInfo(index, spellRankOrSubtype)
	return spellBookSpellName, spellRankOrSubtype, spellType, spellIdOrActionId, icon
end

local function sequence(delim,first,...)
	local head, tail = {first}, {...}
	local switch =
	{
		["string"]=function(c,d,n) return c..(d and d or "")..n end,
		["table"]=function(c,d,n) if #c == 0 then for k,v in pairs(n) do for _k,_v in pairs(d and d or {}) do c[_k] = _v end c[k]=v end else for _,v in ipairs(n) do for _,_v in ipairs(d and d or {}) do table.insert(c,_v) end table.insert(c,v) end end return c end,
		["number"]=function(c,d,n) return c + (d and d or 0) + n end,
		["function"]= function(c,d,n) return function(...) local args = {...} return c(args[1]),d and d(args[2]),n(args[3]) end end,
		--["CFunction"]= function(c,d,n) return function(...) return c(...),d and d(...), n(...) end end,
		["boolean"] = function(c,d,n) return c and ((d or n) and n) end,
		["userdata"]=function(...) print("sequence for type userdata is not implemented") return end,
		["thread"] = function(...) print("sequence for type thread is not implemented") return end,
		["nil"] = function(...) return end,
	}
	while #tail > 0 do
		if type(head[#head])~=type(tail[1]) or (delim and type(delim)~=type(head[#head])) then return end
		head={switch[type(head[#head])](head[#head],delim,tail[1])}
		table.remove(tail,1)
	end
	return table.unpack(head)
end

---Creates a list of Criteria based on user provided keys and the keys prefixes to match against or a default setting if none are provided.
---
---Returns the list of Criteria and the user provided keys, now been sorted, in the form of : ...
---Criteria: { Must:CriteriaRule: { Match:CriteriaMatch: {Key:string,boolean}, MatchCount:CriteriaMatchCount: number},...}, keys: string
---(default rules besides
---
---@overload fun():Criteria,string same as fun(true)
---@overload fun(useDefault:boolean):Criteria,string
---@overload fun(rules:CriteriaRule):Criteria,string
---@overload fun(rules:nil,negativeRules:CriteriaRule):Criteria,string
---@overload fun(rules:CriteriaRule,useDefault:boolean):Criteria,string
---@overload fun(rules:CriteriaRule,negativeRules:CriteriaRule):(Criteria,string)
---@overload fun(rules:CriteriaRule,negativeRules:CriteriaRule,useDefault:boolean):(Criteria,string)
---@return (Criteria, string)
---@param keyPrefixes string|table<number,table<string,Key>> keys as a comma separated string or list of name,value pairs. Matched keys have value: true.
---@param negativeKeyPrefixes string|table<number,table<string,Key>> keys as a comma separated string or list of name,value pairs. Matched keys have value: false.
---@param useDefault boolean flag whether or not to use default rules (table<name:string,value:Key: string> {"MustNot","!"}{"Optional","~"}{"Slot","#"})
function ActionButton:getCriteria(rules,negativeRules, useDefault)
	if type(rules) == "boolean" and negativeRules == nil and useDefault == nil then
		useDefault = rules
		rules = nil
	elseif type(negativeRules) == "boolean" and useDefault == nil then
		useDefault = negativeRules
		negativeRules = nil
	end
	if not (rules == nil and negativeRules == nil and useDefault == nil) then
		local ok = true
		if rules and (not type(rules) == "string" or type(rules) == "table") then
			print("getCriteria expects rules parameter to be a string or a list table")
			ok = false
		end
		if negativeRules and (not type(negativeRules) == "string" or type(negativeRules) == "table") then
			print("getCriteria expects negativeRules parameter to be a string or a list table")
			ok = false
		end
		if useDefault == nil and type(useDefault) ~= "boolean" then
			print("getCriteria expects useDefault parameter to be a boolean")
			ok =false
		end
		if not ok then return end
	end
	---@alias Key string
	---@alias CriteriaMatchCount number
	---@alias CriteriaMatch table<Key,boolean>
	---@alias CriteriaRule string|table<number,table<string,Key>>
	---@alias Criteria table<CriteriaRule,CriteriaMatch|CriteriaMatchCount>
	---@type Criteria
	local result = {}
	function result:TypeCheckOK()
		local ok = not type(self.params[1]) == "string" or (type(self.params[1]) == "table" and type(self.params[1].name) == "string" and type(self.params[1].value) == "string")
		return ok
	end
	function result:defineCriteria(rule, ckey, val)
		self.params = {rule,ckey}
		if not self:TypeCheckOK() then return end
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		arg = arg:lower()
		if not self[rule.name] then
			---@type CriteriaRule
			self[rule.name] = {}
			---@type CriteriaMatchCount
			self[rule.name].MatchCount = 0
		end
		if (rule.value == "" and cmd == "") or (rule.value ~= "" and cmd:match(rule.value)) then
			if not self[rule.name].Match then
				---@type CriteriaMatch
				self[rule.name].Match = {}
				---@type Key
				self[rule.name].Match[arg] = false
			end
			if self[rule.name].Match[arg] then -- added_or_positive ? negate : add.
				self[rule.name].Match[arg] = false
			else
				self[rule.name].Match[arg] = val
				self[rule.name].MatchCount = self[rule.name].MatchCount + 1
			end
		end
	end

	local keys, rulesInOrder, defaultRules = self.flyout.keys, {}, {{name="Optional",value="~"},{name="Slot",value="#"},"break",{name="MustNot",value="!"}}
	if negativeRules and type(rules) == type(negativeRules) then
		rulesInOrder = sequence(type(rules) == "string" and ",break," or {"break"} ,rules,negativeRules)
	elseif negativeRules then
		local toConvert, first, second = type(rules) == "string" and rules or negativeRules, {},{}
		rulesInOrder = {}
		for rule in gmatch(toConvert) do
			table.insert(rulesInOrder,{["name"]=rule,["value"]=rule})
		end
		first = type(rules) == "string" and rulesInOrder or rules
		second = type(rules) == "string" and negativeRules or rulesInOrder
		rulesInOrder = sequence({"break"},first,second)
	end
	for ckey in gmatch(keys, "[^,]+") do -- sort requirements
		local positive = true
		if type(rulesInOrder) == "string" then
			for rule in gmatch(rulesInOrder,"[^,]") do
				if rule == "break" then positive = false else
					result:defineCriteria(rule,ckey,positive)
				end
			end
		else
			for _,rule in ipairs(rulesInOrder) do
				if rule == "break" then positive = false else
					result:defineCriteria(rule,ckey,positive)
				end
			end
		end
		-- defalt behaviour
		if useDefault or (not rules and not negativeRules) then
			for _, rule in ipairs(defaultRules) do
				if rule == "break" then positive = false else
					result:defineCriteria(rule,ckey,positive)
				end
			end
		end
		result:defineCriteria({name="Must",value=""},ckey,true)
	end
	result.params = nil;
	return result, keys
end

---@param Criteria Criteria - Default search criteria, (Rule names: MustNot, Optional and Slot)
---@param haystack string - string to search for
---@param index number - an index number, which Slot # to match against.
local function isMatch(Criteria, haystack, index)
	local hit = false
	if (Criteria.MustNot.MatchCount > 0 and isAnyMatchIn(Criteria.MustNot.Match,haystack:lower())) or (index ~= nil and (Criteria.Slot.MatchCount > 0 and not Criteria.Slot.Match[""..index])) then
		return hit
	end
	if (Criteria.Must.MatchCount == 0 and Criteria.Optional.MatchCount > 0 and isAnyMatchIn(Criteria.Optional.Match, haystack:lower())) then
		hit = true
	end
	if (Criteria.Must.MatchCount > 0 and isAllMatchIn(Criteria.Must.Match,haystack:lower())) then
		if (Criteria.Optional.MatchCount > 0) and not isAnyMatchIn(Criteria.Optional.Match, haystack:lower()) then return false end
		hit = true
	end
	return hit
end

--- Filter handler for items
-- item:id will get all items of that itemID
-- item:name will get all items that contain "name" in its name
function ActionButton:filter_item(tooltip)
	local data, itemTooltips, Criteria = {},{}, self:getCriteria()
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
						itemTooltips[i..":"..j] = "worn "..itemTooltip
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
						itemTooltips[i..":"..j] = itemTooltip
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
					local name,_,_,_,_,_,_,_,equipLoc =  GetItemInfo(itemId)
					if name then
						repeat -- repeat until true gives breaks of the repeat the functionality of a C continue
							if tooltip then
								-- we built the index on the same logic so we know itemTooltips[i..":"..j] exists.
								local findIn = name.." "..itemTooltips[i..":"..j]
								if (isMatch(Criteria,findIn,j)) then
									data[name] = "item"
								end
							else -- match by name
								local findIn = "worn "..name
								if (isMatch(Criteria,findIn,j)) then
									data[name] = "item"
								end
							end
						until true
						if (data[name] and (not Neuron.itemCache[name])) then
							Neuron.itemCache[name] = itemId -- if it isn't in the items cache the icon and tooltip won't show.
						end
					end
				end
			end
		else -- bags
			for j=1, GetContainerNumSlots(i) do
				local itemId = GetContainerItemID(i,j)
				if (itemId) then
					local name =  GetItemInfo(itemId)
					--itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
					--itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID,
					--isCraftingReagent = GetItemInfo(itemID or "itemString" or "itemName" or "itemLink")
					if name then
						repeat -- repeat until true gives breaks of the repeat the functionality of a C continue
							if tooltip then
								-- we built the index on the same logic so we know itemTooltips[i..":"..j] exists.
								local findIn = name.." "..itemTooltips[i..":"..j]
								--TODO: Get item equipable slot, this j is wrong
								if (isMatch(Criteria,findIn,j)) then
									data[name] = "item"
								end
							else -- match by name
								if (isMatch(Criteria,name,j)) then
									data[name] = "item"
								end
							end
						until true
						if (data[name] and not Neuron.itemCache[name]) then
							Neuron.itemCache[name] = itemId -- if it isn't in the items cache the icon and tooltip won't show.
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
function ActionButton:filter_spell(tooltip)
	local data, spellTooltips, Criteria = {},{}, self:getCriteria()
	-- build tooltip table
	if (tooltip) then
		for i=1, GetNumSpellTabs() do
			local _,_,numSpellsInPrevTabs,entries = GetSpellTabInfo(i)
			for j=numSpellsInPrevTabs + 1, numSpellsInPrevTabs + entries do -- go through entries
				local bookType = BOOKTYPE_SPELL
				if i == 5 and HasPetSpells() then
					bookType = BOOKTYPE_PET --assumed a fifth tab is a pet tab.
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
						spellTooltips[i..":"..j] = spellTooltip
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
			end
			local name, rank, spellType, spellID, icon = getSpellInfo(j,bookType)

			local searchName = name
			if rank then
				searchName = searchName.."("..rank..")"
			end

			repeat -- repeat until true gives breaks of the repeat the functionality of a C continue
				if IsPassiveSpell(j,bookType) then break end
				if not IsSpellKnown(spellID,bookType == BOOKTYPE_PET) then break end

				if (("SPELL FUTURESPELL"):match(spellType) and spellID) then
					if tooltip then
						-- we built the index on the same logic so we know itemTooltips[i..":"..j] exists.
						local findIn = searchName.." "..spellTooltips[i..":"..j]
						if (isMatch(Criteria,findIn)) then
							data[name] = "item"
						end
					else -- match by name
						if (isMatch(Criteria,searchName)) then
							data[name:lower()] = "item"
						end
					end
				end
			until true
			if (data[name:lower()] and not (Neuron.spellCache[name:lower()] or Neuron.spellCache[name:lower().."()"])) then
				-- if it isn't in the items cache the icon and tooltip won't show.
				Neuron.spellCache[name:lower()] = { ["booktype"] = bookType,["index"] = j, ["spellType"] = spellType,["spellID"]= spellID, ["icon"]=icon,["spellName"]=name }
				Neuron.spellCache[name:lower().."()"] = { ["booktype"] = bookType,["index"] = j, ["spellType"] = spellType,["spellID"]= spellID, ["icon"]=icon,["spellName"]=name }
			end
		end
	end
	return data
end


---Filter handler for item type
-- type:quest will get all quest items in bags, or those on person with Quest in a type field
-- type:name will get all items that have "name" in its type, subtype or slot name
function ActionButton:filter_type()
	local data, itemTypes, Criteria = {},{}, self:getCriteria()
	itemTypes = nil
	--should this search tooltip by default? does the tooltip contain the type?
	for i,v in pairs(bagsToCache) do -- Go through bags
		if (tostring(i)):match("Worn") and v then -- items worn
			for j=0, 19 do -- go through equip slots
				local itemId = GetInventoryItemID("player",j)
				if (itemId and itemId ~= 0) then
					local name,_,_,_,_,itemType,itemSubType,_,equipLoc =  GetItemInfo(itemId)
					repeat -- repeat until true gives breaks of the repeat the functionality of a C continue
						if (name) then -- match by name
							local findIn = "worn "..itemType.." "..itemSubType
							--TODO: Get item equipable slot, this j is wrong
							if (isMatch(Criteria,findIn,j)) then
								data[name] = "item"
							end
						end
					until true
					if (name and data[name] and (not Neuron.itemCache[name])) then
						Neuron.itemCache[name] = itemId -- if it isn't in the items cache the icon and tooltip won't show.
					end
				end
			end
		else -- bags
			for j=1, GetContainerNumSlots(i) do
				local itemId = GetContainerItemID(i,j)
				if (itemId) then
					local name,_,_,_,_,itemType,itemSubType,_,itemSlot =  GetItemInfo(itemId)
					--itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
					--itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID,
					--isCraftingReagent = GetItemInfo(itemID or "itemString" or "itemName" or "itemLink")
					local isQuestItem, questID, isActive = false,false,false
					if GetContainerItemQuestInfo then
						isQuestItem, questID, isActive = GetContainerItemQuestInfo(i,j)
					end
					if name then
						repeat -- repeat until true gives breaks of the repeat the functionality of a C continue
							local findIn = name.." "..itemType.." "..itemSubType.." "..itemSlot.." "..((isQuestItem or questID or isActive) and "quest" or "")
							if (isMatch(Criteria,findIn)) then
								data[name] = "item"
							end
						until true
						if (data[name] and not Neuron.itemCache[name]) then
							Neuron.itemCache[name] = itemId -- if it isn't in the items cache the icon and tooltip won't show.
						end
					end
				end
			end
		end
	end
	return data
end


--- Filter handler for mounts
-- mount:any, mount:flying, mount:land, mount:favorite, mount:fflying, mount:fland
-- mount:arg filters mounts that include arg in the name or arg="flying" or arg="land" or arg=="any"
function ActionButton:filter_mount()
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
--- not WoW Classic
-- profession:arg filters professions that include arg in the name or arg="primary" or arg="secondary" or arg="all"
function ActionButton:filter_profession()

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
--- not WoW Classic
-- pet:arg filters companion pets that include arg in the name or arg="any" or arg="favorite(s)"
function ActionButton:filter_pet()

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
--- not WoW Classic
-- toy:arg filters items from the toybox; arg="favorite" "any" or partial name
function ActionButton:filter_toy()
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
function ActionButton:GetBlizzData()

	local data = {}

	local visible, spellID, isKnown, petIndex, petName, spell, subName
	local _, _, numSlots = GetFlyoutInfo(self.flyout.keys)

	for i=1, numSlots do
		visible = true

		spellID, _, isKnown = GetFlyoutSlotInfo(self.flyout.keys, i)
		petIndex, petName = GetCallPetSpellInfo(spellID)

		if petIndex and (not petName or petName == "") then
			visible = false
		end

		if isKnown and visible then
			spell = GetSpellInfo(spellID)

			data[spell] = "blizz"
		end
	end
	return data
end


--- Flyout type handler
function ActionButton:GetDataList(options)
	local tooltip

	local scanData = {}

	for types in gmatch(self.flyout.types, "%a+[%+]*") do
		tooltip = types:match("%+")

		if types:find("^b") then  --Blizzard Flyout
			scanData = self:GetBlizzData()
		elseif types:find("^s") then  --Spell
			scanData = self:filter_spell(tooltip)
		elseif types:find("^i") then  --Item
			scanData = self:filter_item(tooltip)
		elseif types:find("^c") and Neuron.isWoWRetail then --Companion
			scanData = self:filter_pet()
		elseif types:find("^f") and Neuron.isWoWRetail then  --toy
			scanData = self:filter_toy()
		elseif types:find("^m") then  --Mount
			scanData = self:filter_mount()
		elseif types:find("^p") and Neuron.isWoWRetail then  --Profession
			scanData = self:filter_profession()
		elseif types:find("^t") then  --Item Type
			scanData = self:filter_type()
		end
	end
	return scanData
end

function ActionButton:updateFlyoutBars()
	if not InCombatLockdown() then  --Workaround for protected taint if UI reload in combat
		local bar = table.remove(barsToUpdate) --this does nothing. It makes bar empty

		if bar then
			bar:SetObjectLoc()
			bar:SetPerimeter()
			bar:SetSize()
		else
			self:Hide()
		end
	end
end

function ActionButton:Flyout_UpdateData(init)
	local slot
	local pet = false

	if self.flyout then
		local count, list = 0, {}
		local button, prefix, macroSet

		local data = self:GetDataList(self.flyout.options)

		for _,val in pairs(self.flyout.buttons) do
			self:Flyout_ReleaseButton(val)
		end

		if data then
			for spell, source in keySort(data) do
				button = self:Flyout_GetButton()
				button.source = source

				if source == "spell" or source =="blizz" then
					if spell:find("%(") then
						button.macroshow = spell
					else
						button.macroshow = spell.."()"
					end
					button:SetAttribute("prefix", "/cast ")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					prefix = "/cast "

				elseif source == "companion" then
					button.macroshow = spell
					button:SetAttribute("prefix", "/summonpet ")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					button:SetMacroName(spell)
					button:SetAttribute("macro_Name", spell)
					prefix = "/summonpet "

				elseif source == "mount" then
					button.macroshow = spell
					button:SetAttribute("prefix", "/summonpet ")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					prefix = "/summonpet "

				elseif source == "item" then
					if IsEquippableItem(spell) then
						if self.flyout.keys:find("#%d+") then
							slot = self.flyout.keys:match("%d+").." "
						end

						if slot then
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
					button:SetMacroName(itemname)

					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")

					if slot then
						button:SetAttribute("showtooltip", "#showtooltip "..slot.."\n")
					else
						button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					end

				elseif source:find("equipset") then
					button.macroshow = spell
					button:SetMacroEquipmentSet(spell)
					button:SetAttribute("prefix", "/equipset ")
					button:SetAttribute("showtooltip", "")

					prefix = "/equipset "

				else
					--should never get here
					button.macroshow = ""
					button:SetAttribute("prefix", "")
					button:SetAttribute("showtooltip", "")
				end

				if slot then
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..slot)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..slot..button.macroshow)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..slot.."\n/stopmacro [nobtn:2]\n/flyout "..self.flyout.options)
				elseif pet then
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..pet)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..pet)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..pet.."\n/stopmacro [nobtn:2]\n/flyout "..self.flyout.options)
				else
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..button.macroshow)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..button.macroshow)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..button.macroshow.."\n/stopmacro [nobtn:2]\n/flyout "..self.flyout.options)
				end

				if not macroSet and not self:GetMacroText():find("nobtn:2") then
					self:SetMacroText(button:GetAttribute("flyoutMacro"))
					macroSet = true
				end

				button:SetMacroText(button:GetAttribute("macro_Text"))
				button:ClearButton()
				button:UpdateAll()

				list[#list+1] = button.id--table.insert(list, button.id)

				count = count + 1
			end
		end

		self.flyout.bar.objCount = count
		self.flyout.bar.data.objectList = list

		if not init then
			table.insert(barsToUpdate, self.flyout.bar)
			self:updateFlyoutBars()
		end
	end
end

function ActionButton:Flyout_UpdateBar()
	self.FlyoutTop:Hide()
	self.FlyoutBottom:Hide()
	self.FlyoutLeft:Hide()
	self.FlyoutRight:Hide()

	local flyout = self.flyout
	local pointA, pointB, hideArrow, shape, columns, pad

	if flyout.shape and flyout.shape:lower():find("^c") then
		shape = 2
	else
		shape = 1
	end

	if flyout.point then
		pointA = flyout.point:match("%a+"):upper() pointA = POINTS[pointA] or "RIGHT"
	end

	if flyout.relPoint then
		pointB = flyout.relPoint:upper() pointB = POINTS[pointB] or "LEFT"
	end

	if flyout.colrad and tonumber(flyout.colrad) then
		if shape == 1 then
			columns = tonumber(flyout.colrad)
		elseif shape == 2 then
			pad = tonumber(flyout.colrad)
		end
	end

	if flyout.mode and flyout.mode:lower():find("^m") then
		flyout.mode = "mouse"
	else
		flyout.mode = "click"
	end

	if flyout.hideArrow and flyout.hideArrow:lower():find("^h") then
		hideArrow = true
	end

	if shape then
		flyout.bar.data.shape = shape
	else
		flyout.bar.data.shape = 1
	end

	if columns then
		flyout.bar.data.columns = columns
	else
		flyout.bar.data.columns = 12
	end

	if pad then
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

	if not hideArrow then
		if pointB == "TOP" then
			self.flyout.arrowPoint = "TOP"
			self.flyout.arrowX = 0
			self.flyout.arrowY = 5
			self.flyout.arrow = self.FlyoutTop
			self.flyout.arrow:Show()
		elseif pointB == "BOTTOM" then
			self.flyout.arrowPoint = "BOTTOM"
			self.flyout.arrowX = 0
			self.flyout.arrowY = -5
			self.flyout.arrow = self.FlyoutBottom
			self.flyout.arrow:Show()
		elseif pointB == "LEFT" then
			self.flyout.arrowPoint = "LEFT"
			self.flyout.arrowX = -5
			self.flyout.arrowY = 0
			self.flyout.arrow = self.FlyoutLeft
			self.flyout.arrow:Show()
		elseif pointB == "RIGHT" then
			self.flyout.arrowPoint = "RIGHT"
			self.flyout.arrowX = 5
			self.flyout.arrowY = 0
			self.flyout.arrow = self.FlyoutRight
			self.flyout.arrow:Show()
		end
	end

	self:Anchor_Update()

	table.insert(barsToUpdate, flyout.bar)

	self:updateFlyoutBars()
end


function ActionButton:Flyout_RemoveButtons()
	for _,button in pairs(self.flyout.buttons) do
		self:Flyout_ReleaseButton(button)
	end
end

function ActionButton:Flyout_RemoveBar()
	self.FlyoutTop:Hide()
	self.FlyoutBottom:Hide()
	self.FlyoutLeft:Hide()
	self.FlyoutRight:Hide()

	self:Anchor_Update(true)

	self:Flyout_ReleaseBar(self.flyout.bar)
end

function ActionButton:UpdateFlyout(init)
	local options

	if self:GetMacroText() then
		options = self:GetMacroText():match("/flyout%s(%C+)")
	end

	if self.flyout then
		self:Flyout_RemoveButtons()
		self:Flyout_RemoveBar()
	end

	if options then
		if not self.flyout then
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

		self:Flyout_UpdateBar()
		self:Flyout_UpdateData(init)

		if not self.bar.watchframes then
			self.bar.watchframes = {}
		end

		self.bar.watchframes[self.flyout.bar.handler] = true

		AnchorIndex[self] = true
	else
		AnchorIndex[self] = nil
		self.flyout = nil
	end
end


function ActionButton:Flyout_ReleaseButton(button)
	self.flyout.buttons[button.id] = nil

	button.stored = true

	button:SetMacroText()
	button:SetMacroEquipmentSet()
	button:SetMacroIcon()

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


function ActionButton:Flyout_InitializeButtonSettings(bar)
	if bar then
		self.bar = bar
		self.bar.data.tooltips = "normal"
	end

	self.Hotkey:Hide()
	self.Name:Hide()
	self:RegisterForClicks("AnyUp")
	self:SetSkinned(true)
end


function ActionButton:Flyout_PostClick()
	local button = self.anchor

	button:SetMacroText(self:GetAttribute("flyoutMacro"))
	button:SetMacroIcon(self:GetAttribute("macro_Icon") or nil)
	button:SetMacroName(self:GetAttribute("macro_Name") or nil)

	button:ClearButton()
	button:UpdateAll()

	self:UpdateStatus()
end

function ActionButton:Flyout_GetButton()
	local id = 1
	for _,button in ipairs(FOBtnIndex) do
		if button.stored then
			button.anchor = self
			button.bar = self.flyout.bar
			button.stored = false

			self.flyout.buttons[button.id] = button

			button:Show()
			return button
		end

		id = id + 1
	end

	local newButton = CreateFrame("CheckButton", self:GetName().."_".."NeuronFlyoutButton"..id, UIParent, "NeuronActionButtonTemplate") --create the new button frame using the desired parameters
	setmetatable(newButton, {__index = ActionButton})

	newButton.elapsed = 0

	newButton.class = "flyout"
	newButton.id = id
	newButton:SetID(0)
	newButton:SetToplevel(true)
	newButton.objTIndex = id
	newButton.objType = "FLYOUTButton"
	newButton.data = { macro_Text = "" }

	newButton.anchor = self
	newButton.bar = self.flyout.bar
	newButton.stored = false

	SecureHandler_OnLoad(newButton)

	newButton:SetAttribute("type1", "macro")
	newButton:SetAttribute("*macrotext1", "")

	newButton:SetScript("PostClick", function(self) self:Flyout_PostClick() end)
	newButton:SetScript("OnEnter", function(self)
		self:UpdateTooltip()
		if self.flyout and self.flyout.arrow then
			self.flyout.arrow:SetPoint(self.flyout.arrowPoint, self.flyout.arrowX/0.625, self.flyout.arrowY/0.625)
		end
	end)
	newButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		if self.flyout and self.flyout.arrow then
			self.flyout.arrow:SetPoint(self.flyout.arrowPoint, self.flyout.arrowX, self.flyout.arrowY)
		end
	end)

	newButton:SetScript("OnShow", function(self) self:UpdateUsable(); self:UpdateIcon(); self:UpdateStatus() end)
	newButton:SetScript("OnHide", function(self) self:UpdateUsable(); self:UpdateIcon(); self:UpdateStatus() end)

	newButton:WrapScript(newButton, "OnClick", [[
			local button = self:GetParent():GetParent()
			button:SetAttribute("macroUpdate", true)
			button:SetAttribute("*macrotext*", self:GetAttribute("flyoutMacro"))
			self:GetParent():Hide()
	]])


	--link objects to their associated functions
	newButton.InitializeButtonSettings = ActionButton.Flyout_InitializeButtonSettings


	newButton:InitializeButtonSettings(self.flyout.bar)

	newButton:Flyout_UpdateData(true)
	newButton:SetSkinned(true)
	newButton:Show()

	self.flyout.buttons[id] = newButton

	FOBtnIndex[id] = newButton

	return newButton
end

function ActionButton:Flyout_ReleaseBar(bar)
	self.flyout.bar = nil

	bar.stored = true
	bar:SetWidth(43)
	bar:SetHeight(43)

	bar:ClearAllPoints()
	bar:SetPoint("CENTER")

	if self.bar.watchframes then
		self.bar.watchframes[bar.handler] = nil
	end
end

function Bar:Flyout_OnEvent()
	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
end

function ActionButton:Flyout_GetBar()
	local id = 1

	for _,bar in ipairs(FOBarIndex) do
		if bar.stored then
			bar.stored = false
			bar:SetParent(UIParent)
			return bar
		end

		id = id + 1
	end

	local bar = CreateFrame("CheckButton", self:GetName().."_".."NeuronFlyoutBar"..id, UIParent, "NeuronBarTemplate")
	setmetatable(bar, {__index = Neuron.Bar})

	bar.class = "FlyoutBar"
	bar.elapsed = 0
	bar.data = { scale = 1 }

	bar.Text:Hide()
	bar.Message:Hide()
	bar.MessageBG:Hide()

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

	FOBarIndex[id] = bar
	return bar
end


function ActionButton:Anchor_RemoveChild()
	local child = self.flyout.bar and self.flyout.bar.handler

	if child then
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

function ActionButton:Anchor_UpdateChild()
	local child = self.flyout.bar and self.flyout.bar.handler

	if child then
		local mode = self.flyout.mode
		local delay

		if mode == "click" then
			self:SetAttribute("click-show", "hide")
			self:WrapScript(self, "OnClick", [[
							if button == "RightButton" then
								if self:GetAttribute("click-show") == "hide" then
									self:SetAttribute("click-show", "show")
								else
									self:SetAttribute("click-show", "hide")
								end
								control:ChildUpdate("onclick", self:GetAttribute("click-show"))
							end
							]])

			child:WrapScript(child, "OnShow", [[
							if self:GetAttribute("timedelay") then
								self:RegisterAutoHide(self:GetAttribute("timedelay"))
							else
								self:UnregisterAutoHide()
							end
							]])

			child:WrapScript(child, "OnHide", [[ self:GetParent():SetAttribute("click-show", "hide") self:UnregisterAutoHide() ]])

			child:SetAttribute("timedelay", tonumber(delay) or 0)
			child:SetAttribute("_childupdate-onclick", [[ if message == "show" then self:Show() else self:Hide() end ]] )

			child:SetParent(self)

		elseif mode == "mouse" then
			self:WrapScript(self, "OnEnter", [[ control:ChildUpdate("onmouse", "enter") ]])
			self:WrapScript(self, "OnLeave", [[ if not self:IsUnderMouse(true) then control:ChildUpdate("onmouse", "leave") end ]])

			child:SetAttribute("timedelay", tonumber(delay) or 0)
			child:SetAttribute("_childupdate-onmouse", [[ if message == "enter" then self:Show() elseif message == "leave" then self:Hide() end ]] )

			child:WrapScript(child, "OnShow", [[
							if self:GetAttribute("timedelay") then
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

function ActionButton:Anchor_Update(remove)
	if remove then
		self:Anchor_RemoveChild()
	else
		self:Anchor_UpdateChild()
	end
end
