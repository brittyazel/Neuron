--Neuron, a World of Warcraft® user interface addon.


--/flyout command based on Gello's addon "Select"
-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------

local NEURON = Neuron
local DB, SPEC, btnDB, control

local BUTTON = NEURON.BUTTON

NEURON.NeuronFlyouts = NEURON:NewModule("Flyouts", "AceEvent-3.0", "AceHook-3.0")
local NeuronFlyouts = NEURON.NeuronFlyouts

local FOBARIndex, FOBTNIndex, ANCHORIndex = {}, {}, {}


local tIndex = NEURON.tIndex



local tooltipStrings = {}

local itemTooltips, itemLinks, spellTooltips, companionTooltips = {}, {}, {}, {}
local needsUpdate, scanData = {}, {}

local array = {}


local petIcons = {}


local f = {}  --flyout related helpers

--f.rtable = {} -- reusable table where flyout button attributes are accumulated
--local rtable = f.rtable

f.filter = {} -- table of search:keyword search functions (f.filter.item(arg))
--[[ Item Cache ]]

f.itemCache = {}
f.bagsToCache = {[0]=true,[1]=true,[2]=true,[3]=true,[4]=true,["Worn"]=true }
f.timerTimes = {} -- indexed by arbitrary name, the duration to run the timer
f.timersRunning = {} -- indexed numerically, timers that are running

local barsToUpdate = {}

local anchorUpdater
local ANCHOR_LOGIN_Updater
local itemScanner
local flyoutBarUpdater

--local extensions

-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronFlyouts:OnInitialize()

	DB = NEURON.db.profile

	local strings = { NeuronTooltipScan:GetRegions() }

	for k,v in pairs(strings) do
		if (v:GetObjectType() == "FontString") then
			tinsert(tooltipStrings, v)
		end
	end

	anchorUpdater = CreateFrame("Frame", nil, UIParent)
	anchorUpdater:SetScript("OnUpdate", function(self, elapsed) NeuronFlyouts:updateAnchors(self, elapsed) end)
	anchorUpdater:Hide()

	ANCHOR_LOGIN_Updater = CreateFrame("Frame", nil, UIParent)
	ANCHOR_LOGIN_Updater:SetScript("OnUpdate", function(self, elapsed)NeuronFlyouts:ANCHOR_DelayedUpdate(self, elapsed) end)
	ANCHOR_LOGIN_Updater:Hide()
	ANCHOR_LOGIN_Updater.elapsed = 0

	itemScanner = CreateFrame("Frame", nil, UIParent)
	itemScanner:SetScript("OnUpdate", function(self, elapsed) NeuronFlyouts:linkScanOnUpdate(self, elapsed) end)
	itemScanner:Hide()

	flyoutBarUpdater = CreateFrame("Frame", nil, UIParent)
	flyoutBarUpdater:SetScript("OnUpdate", function(self, elapsed) NeuronFlyouts:updateFlyoutBars(self, elapsed) end)
	flyoutBarUpdater:Hide()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronFlyouts:OnEnable()

	--[[ Timer Management ]]
	f.timerFrame = CreateFrame("Frame") -- timer independent of main frame visibility
	f.timerFrame:Hide()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	--self:RegisterEvent("EXECUTE_CHAT_LINE")
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("COMPANION_LEARNED")
	self:RegisterEvent("COMPANION_UPDATE")
	self:RegisterEvent("LEARNED_SPELL_IN_TAB")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED")
	self:RegisterEvent("PET_STABLE_UPDATE")
	self:RegisterEvent("EQUIPMENT_SETS_CHANGED")
	self:RegisterEvent("SPELLS_CHANGED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	--self:RegisterEvent("TOYS_UPDATED")

	NeuronFlyouts:HookScript(f.timerFrame, "OnUpdate", "timerFrame_OnUpdate")

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronFlyouts:OnDisable()

end


------------------------------------------------------------------------------

function NeuronFlyouts:EXECUTE_CHAT_LINE(eventName, ...)

	local command, options = (...):match("(/%a+)%s(.+)")

	--if (extensions[command]) then extensions[command](options) end

end

function NeuronFlyouts:BAG_UPDATE(eventName, ...)

	local bag = ...
	if bag>=0 and bag<=4 then
		f.bagsToCache[bag] = true
		if NEURON.PEW then
			f.StartTimer(0.05,f.CacheBags)
		end
	end

	for anchor in pairs(ANCHORIndex) do
		for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
			if (types:find("^i")) then
				tinsert(needsUpdate, anchor)
			end
		end
	end
	ANCHOR_LOGIN_Updater:Show()
end

function NeuronFlyouts:LEARNED_SPELL_IN_TAB()

	for anchor in pairs(ANCHORIndex) do
		for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
			if (types:find("^s") or types:find("^b")) then
				tinsert(needsUpdate, anchor)
			end
		end
	end

	anchorUpdater:Show()
end

function NeuronFlyouts:SPELLS_CHANGED()

	for anchor in pairs(ANCHORIndex) do
		for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
			if (types:find("^s") or types:find("^b")) then
				tinsert(needsUpdate, anchor)
			end
		end
	end

	anchorUpdater:Show()
end

function NeuronFlyouts:CHARACTER_POINTS_CHANGED()

	for anchor in pairs(ANCHORIndex) do
		for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
			if (types:find("^s") or types:find("^b")) then
				tinsert(needsUpdate, anchor)
			end
		end
	end

	anchorUpdater:Show()
end

function NeuronFlyouts:PET_STABLE_UPDATE()

	for anchor in pairs(ANCHORIndex) do
		for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
			if (types:find("^s") or types:find("^b")) then
				tinsert(needsUpdate, anchor)
			end
		end
	end

	anchorUpdater:Show()
end

function NeuronFlyouts:COMPANION_LEARNED()

	for anchor in pairs(ANCHORIndex) do
		for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
			if (types:find("^c")) then
				tinsert(needsUpdate, anchor)
			end
		end
	end

	anchorUpdater:Show()
end

function NeuronFlyouts:COMPANION_UPDATE()

	for anchor in pairs(ANCHORIndex) do
		for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
			if (types:find("^c")) then
				tinsert(needsUpdate, anchor)
			end
		end
	end

	anchorUpdater:Show()
end


function NeuronFlyouts:EQUIPMENT_SETS_CHANGED()

	for anchor in pairs(ANCHORIndex) do
		for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
			if (types:find("^e")) then
				tinsert(needsUpdate, anchor)
			end
		end
	end

	anchorUpdater:Show()

end

function NeuronFlyouts:PLAYER_ENTERING_WORLD()

	f.CacheBags()

	--extensions = { ["/flyout"] = NeuronFlyouts.command_flyout }

end

function NeuronFlyouts:PLAYER_EQUIPMENT_CHANGED(eventName, ...)

	local slot, equipped = ...
	if equipped then
		f.bagsToCache.Worn = true
		if NEURON.PEW then
			f.StartTimer(0.05,f.CacheBags)
		end
	end

	ANCHOR_LOGIN_Updater:Show()

end

function NeuronFlyouts:TOYS_UPDATED()

	for anchor in pairs(ANCHORIndex) do
		for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
			if (types:find("^f")) then
				tinsert(needsUpdate, anchor)
			end
		end
	end
	ANCHOR_LOGIN_Updater:Show()

end

-------------------------------------------------------------------------------

function NeuronFlyouts:timerFrame_OnUpdate(frame, elapsed)
	if NEURON.PEW then
		local tick
		local times = f.timerTimes
		local timers = f.timersRunning

		for i=#timers,1,-1 do
			local func = timers[i]
			times[func] = times[func] - elapsed
			if times[func] < 0 then
				tremove(timers,i)
				func()
			end
			tick = true
		end

		if not tick then
			frame:Hide()
		end
	end
end


function f.StartTimer(duration,func)
	f.timerTimes[func] = duration
	if not tContains(f.timersRunning,func) then
		tinsert(f.timersRunning,func)
	end
	f.timerFrame:Show()
end


function f.addToCache(itemID)
	if itemID then
		local name = GetItemInfo(itemID)
		if name then
			f.itemCache[format("item:%d",itemID)] = name:lower()
		else
			f.StartTimer(0.05,f.CacheBags)
			return true
		end
	end
end


function f.CacheBags()
	local cacheComplete = true
	if not f.cacheTimeout or f.cacheTimeout < 10 then
		for bag in pairs(f.bagsToCache) do
			if bag=="Worn" then
				for slot=1,19 do
					local itemID = GetInventoryItemID("player",slot)
					if f.addToCache(itemID) then
						cacheComplete = false
					end
				end
			else
				for slot=1,GetContainerNumSlots(bag) do
					local itemID = GetContainerItemID(bag,slot)
					if f.addToCache(itemID) then
						cacheComplete = false
					end
				end
			end
		end
	end
	if cacheComplete then
		f.flyoutsNeedFilled = true
		wipe(f.bagsToCache)
		if f.firstLogin then
			f.firstLogin = nil
			f.FillAttributes()
		end
	else
		f.cacheTimeout = (f.cacheTimeout or 0)+1
	end
end


local exclusions = {}

--- Goes through a data table and removes any items that had been flagged as containing a exclusion keyword.
local function RemoveExclusions(data)
	for spellName,_ in pairs(exclusions) do
		data[spellName] = nil
	end
	wipe(exclusions)
	return data
end

--[[ Filters ]]

-- for arguments without a search, look for items or spells by that name
function f.filter.none(arg)
	-- if a regular item in bags/on person
	if GetItemCount(arg)>0 then
		local _, link = GetItemInfo(arg)
		if link then
			addToTable("item",(link:match("(item:%d+)")))
			return
		end
	end
	-- if a spell
	local spellName = GetSpellInfo(arg)
	if spellName and spellName~="" then
		addToTable("spell",spellName)
		return
	end
	-- if a toy
	local toyName = GetItemInfo(arg)
	if toyName and tIndex[toyName] then
		addToTable("item",toyName)
	end
end




-- ad ds a type/value attribute pair to rtable if it's not already there
local function addToTable(actionType,actionValue)
	--for i=1,#rtable,2 do
	--if rtable[i]==actionType and rtable[i+1]==actionValue then
	--return
	--end
	--end
	--tinsert(rtable,actionType)
	--tinsert(rtable,actionValue)
	scanData[actionValue:lower()] = actionType
end


-- returns true if arg and compareTo match. arg is a [Cc][Aa][Ss][Ee]-insensitive pattern
-- so we can't equate them and to get an exact match we need to append ^ and $ to the pattern
local function compare(arg,compareTo,exact)
	return compareTo:match(format("^%s$",arg)) and true
end


--- Filter handler for items
-- item:id will get all items of that itemID
-- item:name will get all items that contain "name" in its name
function NeuronFlyouts:filter_item(button, data)
	local keys, found, mandatory, optional = button.flyout.keys, 0, 0, 0
	local excluded
	for ckey in gmatch(keys, "[^,]+") do

		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		local itemID = tonumber(arg)
		arg = arg:lower()

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end

		if itemID and GetItemCount(itemID)>0 then
			data[itemID] = "item"---addToTable("item",format("item:%d",itemID))
			return
		end
		-- look for arg in itemCache
		for itemID,name in pairs(f.itemCache) do
			if (name:lower()):match(arg) and GetItemCount(name)>0 then
				data[itemID] = "item"--addToTable("item",itemID)
			end
		end
	end
end


--- Filter Handler for Spells
-- spell:id will get all spells of that spellID
-- spell:name will get all spells that contain "name" in its name or its flyout parent
function NeuronFlyouts:filter_spell(button, data)
	local keys, found, mandatory, optional = button.flyout.keys, 0, 0, 0
	local excluded

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end
		--revisit
		if type(arg)=="number" and IsSpellKnown(arg) then
			local name = GetSpellInfo(arg)
			if name then
				data[name:lower()] = "spell"
				--addToTable("spell",name)
				return
			end
		end
		-- look for arg in the spellbook
		for i=1,2 do
			local _,_,offset,numSpells = GetSpellTabInfo(i)
			for j=offset+1, offset+numSpells do
				local spellType,spellID = GetSpellBookItemInfo(j,"spell")
				local name = (GetSpellBookItemName(j,"spell")):lower()
				local isPassive = IsPassiveSpell(j,"spell")
				if name and name:match(arg) and not isPassive then
					if spellType=="SPELL" and IsSpellKnown(spellID) then
						data[name] = "spell"--addToTable("spell",name)
					elseif spellType=="FLYOUT" then
						local _, _, numFlyoutSlots, isFlyoutKnown = GetFlyoutInfo(spellID)
						if isFlyoutKnown then
							for k=1,numFlyoutSlots do
								local _,_,flyoutSpellKnown,flyoutSpellName = GetFlyoutSlotInfo(spellID,k)
								if flyoutSpellKnown then
									addToTable("spell",flyoutSpellName)
								end
							end
						end
					end
				end
			end
		end
	end
	RemoveExclusions(data)
end


---Filter handler for item type
-- type:quest will get all quest items in bags, or those on person with Quest in a type field
-- type:name will get all items that have "name" in its type, subtype or slot name
function NeuronFlyouts:filter_type(button, data)
	local keys, found, mandatory, optional = button.flyout.keys, 0, 0, 0
	local excluded

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		arg = arg:lower()

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end

		if ("quest"):match(arg) then
			-- many quest items don't have "Quest" in a type field, but GetContainerItemQuestInfo
			-- has them flagged as questf.  check those first
			for i=0,4 do
				for j=1,GetContainerNumSlots(i) do
					local isQuestItem, questID, isActive = GetContainerItemQuestInfo(i,j)
					if isQuestItem or questID or isActive then
						data[(format("item:%d",GetContainerItemID(i,j))):lower()] = "item" --addToTable("item",format("item:%d",GetContainerItemID(i,j)))
					end
				end
			end
		end
		-- some quest items can be marked quest as an item type also
		for itemID,name in pairs(f.itemCache) do
			if GetItemCount(name)>0 then
				local _, _, _, _, _, itemType, itemSubType, _, itemSlot = GetItemInfo(itemID)
				if itemType and ((itemType:lower()):match(arg) or (itemSubType:lower()):match(arg) or (itemSlot:lower()):match(arg)) then
					data[itemID:lower()] = "item" --addToTable("item",itemID)
				end
			end
		end
	end
	RemoveExclusions(data)
end


--- Filter handler for mounts
-- mount:any, mount:flying, mount:land, mount:favorite, mount:fflying, mount:fland
-- mount:arg filters mounts that include arg in the name or arg="flying" or arg="land" or arg=="any"
function NeuronFlyouts:filter_mount(button, data)
	local keys, found, mandatory, optional = button.flyout.keys, 0, 0, 0
	local excluded

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		local any = compare(arg,("Any"))
		local flying = compare(arg,"Flying")
		local land = compare(arg,"Land")
		local fflying = compare(arg,"FFlying") or compare(arg,"FavFlying")
		local fland = compare(arg,"FLand") or compare(arg,"FavLand")
		local favorite = compare(arg,"Favorite") or fflying or fland
		arg = arg:lower()

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end

		for i,mountID in ipairs(C_MountJournal.GetMountIDs()) do
			local mountName, mountSpellId, mountTexture, _, canSummon, _, isFavorite = C_MountJournal.GetMountInfoByID(mountID)
			local spellName = GetSpellInfo(mountSpellId) -- sometimes mount name isn't same as spell name >:O
			mountName = mountName:lower()
			spellName = spellName:lower()
			if mountName and canSummon then
				local _,_,_,_,mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
				local canFly = mountType==247 or mountType==248
				if (mountName:match(arg) or spellName:match(arg)) and excluded then
					exclusions[spellName] = true
				elseif favorite and isFavorite then
					if (fflying and canFly) or (fland and not canFly) or (not fflying and not fland) then
						data[spellName] = "spell"--addToTable("spell",spellName)
					end
				elseif (flying and canFly) or (land and not canFly) then
					data[spellName] = "spell"--addToTable("spell",spellName)
				elseif any or mountName:match(arg) or spellName:match(arg) then
					data[spellName] = "spell"
				end
			end
		end

	end
	RemoveExclusions(data)
end



--- Filter handler for professions
-- profession:arg filters professions that include arg in the name or arg="primary" or arg="secondary" or arg="all"
function NeuronFlyouts:filter_profession(button, data)

	-- runs func for each ...
	local function RunForEach(func,...)
		for i=1,select("#",...) do
			func((select(i,...)))
		end
	end

	f.professions = f.professions or {}
	wipe(f.professions)

	local keys, found, mandatory, optional = button.flyout.keys, 0, 0, 0
	local excluded
	local profSpells = {}

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end

		RunForEach(function(entry) tinsert(f.professions,entry or false) end, GetProfessions())
		local any = compare(arg,"Any")
		local primaryOnly = compare(arg,"Primary")
		local secondaryOnly = compare(arg,"Secondary")
		arg = arg:lower()
		for index,profession in pairs(f.professions) do
			if profession then
				local name, _, _, _, numSpells, offset = GetProfessionInfo(profession)
				if (name:lower()):match(arg) and excluded then
					exclusions[name:lower()] = true

				elseif (index<3 and primaryOnly) or (index>2 and secondaryOnly) or any or (name:lower()):match(arg) then
					for i=1,numSpells do
						local _, spellID = GetSpellBookItemInfo(offset+i,"professions")
						local spellName = GetSpellInfo(spellID)
						local isPassive = IsPassiveSpell(offset+i,"professions")

						if not isPassive then
							tinsert(profSpells, spellName:lower())
							data[spellName:lower()] = "spell"
						end
					end
				end
			end
		end

		--Check exclusions a second time for args that dont trigger earlier.
		for _,name in pairs(profSpells) do
			if (name:lower()):match(arg) and excluded then
				exclusions[name:lower()] = true
			end
		end
	end
	RemoveExclusions(data)
end


--- Filter handler for companion pets
-- pet:arg filters companion pets that include arg in the name or arg="any" or arg="favorite(s)"
function NeuronFlyouts:filter_pet(button, data)
	local keys, found, mandatory, optional = button.flyout.keys, 0, 0, 0
	local excluded
	for ckey in gmatch(keys, "[^,]+") do

		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		local any = compare(arg,"Any")
		local favorite = compare(arg,"Favorite")

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end


		-- the following can create 150-200k of garbage...why? pets are officially unsupported so this is permitted to stay
		for i=1,C_PetJournal.GetNumPets() do
			local petID,_,owned,customName,_,isFavorite,_,realName, icon = C_PetJournal.GetPetInfoByIndex(i)
			if petID and owned then
				if any or (favorite and isFavorite) or (customName and (customName:lower()):match(arg)) or (realName and (realName:lower()):match(arg)) then

					if ((customName and (customName:lower()):match(arg)) or (realName and (realName:lower()):match(arg))) and excluded then
						exclusions[realName] = true
					else
						--addToTable("macro",format("/summonpet %s",customName or realName))
						data[realName] = "companion"
						petIcons[realName] = icon
					end
				end
			end
		end
	end
	RemoveExclusions(data)
end


---Filter handler for toy items
-- toy:arg filters items from the toybox; arg="favorite" "any" or partial name
function NeuronFlyouts:filter_toy(button, data)
	local keys, found, mandatory, optional = button.flyout.keys, 0, 0, 0
	local excluded

	for ckey in gmatch(keys, "[^,]+") do
		local cmd, arg = (ckey):match("%s*(%p*)(%P+)")
		local any = compare(arg,"Any")
		local favorite = compare(arg,"Favorite")
		arg = arg:lower()

		if (cmd == "!") then
			excluded = true
		else
			excluded = false
		end

		if excluded then
			for toyName in pairs(tIndex) do
				if toyName:match(arg) then
					exclusions[toyName:lower()] = true
				end
			end
		elseif favorite then -- toy:favorite
			for toyName,itemID in pairs(tIndex) do
				if C_ToyBox.GetIsFavorite(itemID) then
					data[toyName:lower()] = "item"--addToTable("item",toyName)
				end
			end
		elseif any then -- toy:any
			for toyName in pairs(tIndex) do
				data[toyName:lower()] = "item"--addToTable("item",toyName)
			end
		else -- toy:name
			for toyName in pairs(tIndex) do
				if toyName:match(arg) then
					data[toyName:lower()] = "item"--addToTable("item",toyName)
				end
			end
		end
	end
	RemoveExclusions(data)
end


--- Sorting fuinction
local function keySort(list)
	wipe(array)

	local i = 0

	for n in pairs(list) do
		tinsert(array, n)
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


--- Handler for Blizzard flyout spells
function NeuronFlyouts:GetBlizzData(button, data)
	local visible, spellID, isKnown, petIndex, petName, spell, subName
	local _, _, numSlots = GetFlyoutInfo(button.flyout.keys)

	for i=1, numSlots do
		visible = true

		spellID, _, isKnown = GetFlyoutSlotInfo(button.flyout.keys, i)
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
function NeuronFlyouts:GetDataList(button, options)
	local tooltip

	wipe(scanData)

	for types in gmatch(button.flyout.types, "%a+[%+]*") do
		tooltip = types:match("%+")

		if (types:find("^b")) then  --Blizzard Flyout
			return NeuronFlyouts:GetBlizzData(button, scanData)
		--elseif (types:find("^e")) then  --Equipment set
			--return self:GetEquipSetData(scanData)
		elseif (types:find("^s")) then  --Spell
			NeuronFlyouts:filter_spell(button, scanData)
		elseif (types:find("^i")) then  --Item
			NeuronFlyouts:filter_item(button, scanData)
		elseif (types:find("^c")) then  --Companion
			NeuronFlyouts:filter_pet(button, scanData)
		elseif (types:find("^f")) then  --toy
			NeuronFlyouts:filter_toy(button, scanData)
		elseif (types:find("^m")) then  --Mount
			NeuronFlyouts:filter_mount(button, scanData)
		elseif (types:find("^p")) then  --Profession
			NeuronFlyouts:filter_profession(button, scanData)
		elseif (types:find("^t")) then  --Item Type
			NeuronFlyouts:filter_type(button, scanData)
		end
	end
	return scanData
end

function NeuronFlyouts:updateFlyoutBars(button, elapsed)

	if (not InCombatLockdown() and NEURON.PEW) then  --Workarout for protected taint if UI reload in combat
		local bar = tremove(barsToUpdate) ---this does nothing. It makes bar empty

		if (bar) then
			NEURON.NeuronBar:SetObjectLoc(bar)
			NEURON.NeuronBar:SetPerimeter(bar)
			NEURON.NeuronBar:SetSize(bar)
		else
			button:Hide()
		end
	end
end





function NeuronFlyouts:Flyout_UpdateButtons(fbutton, init)
	local slot
	local pet = false

	if (fbutton.flyout) then
		local flyout, count, list = fbutton.flyout, 0, {}
		local button, prefix, macroSet

		local data = NeuronFlyouts:GetDataList(fbutton, flyout.options)

		for _,button in pairs(flyout.buttons) do
			NeuronFlyouts:Flyout_ReleaseButton(fbutton, button)
		end

		if (data) then
			for spell, source in keySort(data) do
				button = NeuronFlyouts:Flyout_GetButton(fbutton)

				local _, _, icon = GetSpellInfo(spell) --make sure the right icon is applied
				if (icon) then
					button.data.macro_Icon = icon
				end


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
					--button.macroicon = petIcons[spell]
					button:SetAttribute("prefix", "/summonpet ")
					--button:SetAttribute("showtooltip", "")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					--button.data.macro_Icon = petIcons[spell]
					--button.data.macro_Name = spell
					--button:SetAttribute("macro_Icon", petIcons[spell])
					--button:SetAttribute("macro_Name", spell)
					prefix = "/summonpet "
					--pet = spell

				elseif (source == "mount") then
					button.macroshow = spell
					button:SetAttribute("prefix", "/summonpet ")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					prefix = "/summonpet "


				elseif (source == "item") then
					button.macroshow = spell

					if (IsEquippableItem(spell)) then
						if (fbutton.flyout.keys:find("#%d+")) then
							slot = fbutton.flyout.keys:match("%d+").." "
						end

						if (slot) then
							prefix = "/equipslot "
							button:SetAttribute("slot", slot.." ")
						else
							prefix = "/equip "
						end
					else
						prefix = "/use "
					end

					button:SetAttribute("prefix", prefix)

					if (slot) then
						button:SetAttribute("showtooltip", "#showtooltip "..slot.."\n")
					else
						button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					end

				elseif (source:find("equipset")) then
					_, icon = (";"):split(source)
					button.macroshow = spell
					button.data.macro_Equip = spell
					button:SetAttribute("prefix", "/equipset ")
					button:SetAttribute("showtooltip", "")

					prefix = "/equipset "

					if (icon) then
						button.data.macro_Icon = icon
					else
						button.data.macro_Icon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
					end
				else
					--should never get here
					button.macroshow = ""
					button:SetAttribute("prefix", "")
					button:SetAttribute("showtooltip", "")
				end

				if (slot) then
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..slot)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..slot..button.macroshow)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..slot.."\n/stopmacro [nobtn:2]\n/flyout "..flyout.options)
				elseif (pet) then
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..pet)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..pet)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..pet.."\n/stopmacro [nobtn:2]\n/flyout "..flyout.options)
				else
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..button.macroshow)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..button.macroshow)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..button.macroshow.."\n/stopmacro [nobtn:2]\n/flyout "..flyout.options)
				end

				if (not macroSet and not fbutton.data.macro_Text:find("nobtn:2")) then
					fbutton.data.macro_Text = button:GetAttribute("flyoutMacro"); macroSet = true
				end

				button.data.macro_Text = button:GetAttribute("macro_Text")
				NEURON.NeuronButton:MACRO_UpdateParse(button)
				NEURON.NeuronButton:MACRO_Reset(button)
				NEURON.NeuronButton:MACRO_UpdateAll(button, true)

				list[#list+1] = button.id--table.insert(list, button.id)

				count = count + 1
			end
		end

		flyout.bar.objCount = count
		flyout.bar.data.objectList = list

		if (not init) then
			tinsert(barsToUpdate, flyout.bar)
			flyoutBarUpdater:Show()
		end
	end
end



function NeuronFlyouts:Flyout_UpdateBar(button)
	button.flyouttop:Hide()
	button.flyoutbottom:Hide()
	button.flyoutleft:Hide()
	button.flyoutright:Hide()

	local flyout = button.flyout
	local pointA, pointB, hideArrow, shape, columns, pad

	if (flyout.shape and flyout.shape:lower():find("^c")) then
		shape = 2
	else
		shape = 1
	end

	if (flyout.point) then
		pointA = flyout.point:match("%a+"):upper() pointA = NEURON.Points[pointA] or "RIGHT"
	end

	if (flyout.relPoint) then
		pointB = flyout.relPoint:upper() pointB = NEURON.Points[pointB] or "LEFT"
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
	flyout.bar:SetPoint(pointA, button, pointB, 0, 0)
	flyout.bar:SetFrameStrata(button:GetFrameStrata())
	flyout.bar:SetFrameLevel(button:GetFrameLevel()+1)

	if (not hideArrow) then
		if (pointB == "TOP") then
			button.flyout.arrowPoint = "TOP"
			button.flyout.arrowX = 0
			button.flyout.arrowY = 5
			button.flyout.arrow = button.flyouttop
			button.flyout.arrow:Show()
		elseif (pointB == "BOTTOM") then
			button.flyout.arrowPoint = "BOTTOM"
			button.flyout.arrowX = 0
			button.flyout.arrowY = -5
			button.flyout.arrow = button.flyoutbottom
			button.flyout.arrow:Show()
		elseif (pointB == "LEFT") then
			button.flyout.arrowPoint = "LEFT"
			button.flyout.arrowX = -5
			button.flyout.arrowY = 0
			button.flyout.arrow = button.flyoutleft
			button.flyout.arrow:Show()
		elseif (pointB == "RIGHT") then
			button.flyout.arrowPoint = "RIGHT"
			button.flyout.arrowX = 5
			button.flyout.arrowY = 0
			button.flyout.arrow = button.flyoutright
			button.flyout.arrow:Show()
		end
	end

	NeuronFlyouts:Anchor_Update(button)

	tinsert(barsToUpdate, flyout.bar)

	flyoutBarUpdater:Show()
end


function NeuronFlyouts:Flyout_RemoveButtons(fbutton)
	for _,button in pairs(fbutton.flyout.buttons) do
		NeuronFlyouts:Flyout_ReleaseButton(fbutton, button)
	end
end

function NeuronFlyouts:Flyout_RemoveBar(button)
	button.flyouttop:Hide()
	button.flyoutbottom:Hide()
	button.flyoutleft:Hide()
	button.flyoutright:Hide()

	NeuronFlyouts:Anchor_Update(button, true)

	NeuronFlyouts:Flyout_ReleaseBar(button, button.flyout.bar)
end

function NeuronFlyouts:UpdateFlyout(button, init)
	local options = button.data.macro_Text:match("/flyout%s(%C+)")
	if (button.flyout) then
		NeuronFlyouts:Flyout_RemoveButtons(button)
		NeuronFlyouts:Flyout_RemoveBar(button)
	end

	if (options) then
		if (not button.flyout) then
			button.flyout = { buttons = {} }
		end

		local flyout = button.flyout
		flyout.bar = NeuronFlyouts:Flyout_GetBar(button)
		flyout.options = options
		flyout.types = select(1, (":"):split(options))
		flyout.keys = select(2, (":"):split(options))
		flyout.shape = select(3, (":"):split(options))
		flyout.point = select(4, (":"):split(options))
		flyout.relPoint = select(5, (":"):split(options))
		flyout.colrad = select(6, (":"):split(options))
		flyout.mode = select(7, (":"):split(options))
		flyout.hideArrow = select(8, (":"):split(options))

		NeuronFlyouts:Flyout_UpdateButtons(button, init)
		NeuronFlyouts:Flyout_UpdateBar(button)

		if (not button.bar.watchframes) then
			button.bar.watchframes = {}
		end

		button.bar.watchframes[flyout.bar.handler] = true

		ANCHORIndex[button] = true
	else
		ANCHORIndex[button] = nil
		button.flyout = nil
	end
end


function NeuronFlyouts:Flyout_ReleaseButton(fbutton, button)
	fbutton.flyout.buttons[button.id] = nil

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


function NeuronFlyouts:Flyout_SetData(button, bar)
	if (bar) then

		button.bar = bar

		button.tooltips = true
		button.tooltipsEnhanced = true
		--self.tooltipsCombat = bar.data.tooltipsCombat
		--self:SetFrameStrata(bar.data.objectStrata)
		--self:SetScale(bar.data.scale)
	end

	button.hotkey:Hide()
	button.macroname:Hide()
	button:RegisterForClicks("AnyUp")

	button.equipcolor = { 0.1, 1, 0.1, 1 }
	button.cdcolor1 = { 1, 0.82, 0, 1 }
	button.cdcolor2 = { 1, 0.1, 0.1, 1 }
	button.auracolor1 = { 0, 0.82, 0, 1 }
	button.auracolor2 = { 1, 0.1, 0.1, 1 }
	button.buffcolor = { 0, 0.8, 0, 1 }
	button.debuffcolor = { 0.8, 0, 0, 1 }
	button.manacolor = { 0.5, 0.5, 1.0 }
	button.rangecolor = { 0.7, 0.15, 0.15, 1 }

	button:SetFrameLevel(4)
	button.iconframe:SetFrameLevel(2)
	button.iconframecooldown:SetFrameLevel(3)
	button.iconframeaurawatch:SetFrameLevel(3)

	button:GetSkinned(button)
end


function NeuronFlyouts:Flyout_PostClick(fbutton)
	local button = fbutton.anchor
	button.data.macro_Text = fbutton:GetAttribute("flyoutMacro")
	button.data.macro_Icon = fbutton:GetAttribute("macro_Icon") or false
	button.data.macro_Name = fbutton:GetAttribute("macro_Name") or nil

	NEURON.NeuronButton:MACRO_UpdateParse(button)
	NEURON.NeuronButton:MACRO_Reset(button)
	NEURON.NeuronButton:MACRO_UpdateAll(button, true)

	NEURON.NeuronButton:MACRO_UpdateState(fbutton)
end

function NeuronFlyouts:Flyout_GetButton(fbutton)
	local id = 1

	for _,button in ipairs(FOBTNIndex) do
		if (button.stored) then
			button.anchor = fbutton
			button.bar = fbutton.flyout.bar
			button.stored = false

			fbutton.flyout.buttons[button.id] = button

			button:Show()
			return button
		end

		id = id + 1
	end

	local button = CreateFrame("CheckButton", "NeuronFlyoutButton"..id, UIParent, "NeuronActionButtonTemplate")
	setmetatable(button, { __index = BUTTON })

	button.elapsed = 0

	local objects = NEURON:GetParentKeys(button)

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

	button.anchor = fbutton
	button.bar = fbutton.flyout.bar
	button.stored = false

	SecureHandler_OnLoad(button)

	button:SetAttribute("type1", "macro")
	button:SetAttribute("*macrotext1", "")

	button:SetScript("PostClick", function(self) NeuronFlyouts:Flyout_PostClick(self) end)
	button:SetScript("OnEnter", function(self, ...) NEURON.NeuronButton:MACRO_OnEnter(self, ...) end)
	button:SetScript("OnLeave", function(self, ...) NEURON.NeuronButton:MACRO_OnLeave(self, ...) end)
	--button:SetScript("OnEvent", self:GetScript("OnEvent"))
	--button:SetScript("OnUpdate", self:GetScript("OnUpdate"))

	button:HookScript("OnShow", function(self) NEURON.NeuronButton:MACRO_UpdateButton(self) NEURON.NeuronButton:MACRO_UpdateIcon(self); NEURON.NeuronButton:MACRO_UpdateState(self) end)
	button:HookScript("OnHide", function(self) NEURON.NeuronButton:MACRO_UpdateButton(self) NEURON.NeuronButton:MACRO_UpdateIcon(self) NEURON.NeuronButton:MACRO_UpdateState(self) end)

	button:WrapScript(button, "OnClick", [[
			local button = self:GetParent():GetParent()
			button:SetAttribute("macroUpdate", true)
			button:SetAttribute("*macrotext*", self:GetAttribute("flyoutMacro"))
			self:GetParent():Hide()
	]])


	--link objects to their associated functions
	button.SetData = NeuronFlyouts.Flyout_SetData


	button:SetData(button, fbutton.flyout.bar)
	button:SetSkinned(button, true)
	button:Show()

	fbutton.flyout.buttons[id] = button

	FOBTNIndex[id] = button
	return button
end


function NeuronFlyouts:Flyout_ReleaseBar(button, bar)
	button.flyout.bar = nil

	bar.stored = true
	bar:SetWidth(43)
	bar:SetHeight(43)

	bar:ClearAllPoints()
	bar:SetPoint("CENTER")

	button.bar.watchframes[bar.handler] = nil
end


function NeuronFlyouts:Flyout_GetBar(button)
	local id = 1

	for _,bar in ipairs(FOBARIndex) do
		if (bar.stored) then
			bar.stored = false
			bar:SetParent(UIParent)
			return bar
		end

		id = id + 1
	end

	local bar = CreateFrame("CheckButton", "NeuronFlyoutBar"..id, UIParent, "NeuronBarTemplate")

	setmetatable(bar, {__index = CreateFrame("CheckButton")})

	bar.index = id
	bar.class = "bar"
	bar.elapsed = 0
	bar.data = { scale = 1 }
	bar.objPrefix = "NeuronFlyoutButton"

	bar.text:Hide()
	bar.message:Hide()
	bar.messagebg:Hide()

	bar:SetID(id)
	bar:SetWidth(43)
	bar:SetHeight(43)
	bar:SetFrameLevel(2)

	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:SetScript("OnEvent", function(self) NEURON.NeuronBar:SetObjectLoc(self) NEURON.NeuronBar:SetPerimeter(self) NEURON.NeuronBar:SetSize(self) end)

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

	bar.handler:Hide()

	FOBARIndex[id] = bar
	return bar
end


function NeuronFlyouts:Anchor_RemoveChild(button)
	local child = button.flyout.bar and button.flyout.bar.handler

	if (child) then
		button:UnwrapScript(button, "OnEnter")
		button:UnwrapScript(button, "OnLeave")
		button:UnwrapScript(button, "OnClick")
		button:SetAttribute("click-show", nil)

		child:SetAttribute("timedelay", nil)
		child:SetAttribute("_childupdate-onmouse", nil)
		child:SetAttribute("_childupdate-onclick", nil)

		child:UnwrapScript(child, "OnShow")
		child:UnwrapScript(child, "OnHide")
	end
end

function NeuronFlyouts:Anchor_UpdateChild(button)
	local child = button.flyout.bar and button.flyout.bar.handler

	if (child) then
		local mode = button.flyout.mode
		local delay

		if (mode == "click") then
			button:SetAttribute("click-show", "hide")
			button:WrapScript(button, "OnClick", [[
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

			child:SetParent(button)

		elseif (mode == "mouse") then
			button:WrapScript(button, "OnEnter", [[ control:ChildUpdate("onmouse", "enter") ]])
			button:WrapScript(button, "OnLeave", [[ if (not self:IsUnderMouse(true)) then control:ChildUpdate("onmouse", "leave") end ]])

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

			child:SetParent(button)
		end
	end
end


function NeuronFlyouts:Anchor_Update(button, reMove)
	if (reMove) then
		NeuronFlyouts:Anchor_RemoveChild(button)
	else
		NeuronFlyouts:Anchor_UpdateChild(button)
	end
end

function NeuronFlyouts:updateAnchors(button, elapsed)

	if not button then --someone had an error when switching profiles and not reloading fast enough. In that case button didn't exist
		return
	end

	if not button.elapsed then
		button.elapsed = 0
	end

	button.elapsed = button.elapsed + elapsed

	if (button.elapsed > DB.throttle and NEURON.PEW) then

		if (not InCombatLockdown()) then
			local anchor = tremove(needsUpdate)

			if (anchor) then
				NeuronFlyouts:Flyout_UpdateButtons(anchor, nil)
			else

				button:Hide();
			end
		end

		button.elapsed = 0
	end
end


function NeuronFlyouts:linkScanOnUpdate(button, elapsed)

	if not button.elapsed then
		button.elapsed = 0
	end

	button.elapsed = button.elapsed + elapsed

	if (button.elapsed > DB.throttle and NEURON.PEW) then
		-- scan X items per frame draw, where X is the for limit
		for i=1,2 do
			button.link = itemLinks[button.index]
			if (button.link) then
				local name = GetItemInfo(button.link)

				if (name) then
					local tooltip, text = " ", " "
					NeuronTooltipScan:SetOwner(control,"ANCHOR_NONE")
					NeuronTooltipScan:SetHyperlink(button.link)

					for i,string in ipairs(tooltipStrings) do
						text = string:GetText()
						if (text) then
							tooltip = tooltip..text..","
						end
					end

					itemTooltips[name:lower()] = tooltip:lower()
					button.count = button.count + 1
				end
			end

			button.index = next(itemLinks, button.index)

			if not (button.index) then
				--NEURON:Print("Scanned "..button.count.." items in "..button.elapsed.." seconds")
				button:Hide(); anchorUpdater:Show()
			end
		end

		button.elapsed = 0
	end
end


function NeuronFlyouts:command_flyout(options)


	if (InCombatLockdown()) then
		return
	end

	local button = NEURON.ClickedButton

	if (button) then
		if (not button.options or button.options ~= options) then
			NEURON.NeuronFlyouts:UpdateFlyout(button, options)
		end
	end
end



function NeuronFlyouts:ANCHOR_DelayedUpdate(button, elapsed)

	if not button.elapsed then
		button.elapsed = 0
	end

	button.elapsed = button.elapsed + elapsed

	if (button.elapsed > DB.throttle and NEURON.PEW) then

		for anchor in pairs(ANCHORIndex) do
			tinsert(needsUpdate, anchor)
		end

		anchorUpdater:Show()
		button:Hide()

		button.elapsed = 0
	end
end
