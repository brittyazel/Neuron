-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---The functions in this file are part of the ACTIONBUTTON class.
---It was just easier to put them all in their own file for organization.

local ACTIONBUTTON = Neuron.ACTIONBUTTON

local macroDrag = {} --this is a table that holds onto the contents of the  current macro being dragged
local macroCache = {} --this will hold onto any previous contents of our button

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

--------------------------------------
--------------------------------------

--this is the function that fires when you begin dragging an item
function ACTIONBUTTON:OnDragStart()
	if InCombatLockdown() or not self.bar or self.actionID then
		return
	end

	local drag

	if not self.bar:GetBarLock() then
		drag = true
	elseif self.bar:GetBarLock() == "alt" and IsAltKeyDown() then
		drag = true
	elseif self.bar:GetBarLock() == "ctrl" and IsControlKeyDown() then
		drag = true
	elseif self.bar:GetBarLock() == "shift" and IsShiftKeyDown() then
		drag = true
	else
		drag = false
	end

	if drag and self:GetMacroText() ~= "" then

		ClearCursor()

		--This is all just to put an icon on the mousecursor. Sadly we can't use SetCursor, because once you leave the frame the icon goes away. PickupSpell seems to work, but we need a valid spellID
		--This trick here is that we ignore what is 'actually' and are just using it for the icon and the sound effects
		self:SetMouseCursor()

		self:PickUpMacro()

		self:InitializeButton()
		self:UpdateAll()
		self:UpdateCooldown() --clear any cooldowns that may be on the button now that the button is empty

	end

	for _,bar in pairs(Neuron.bars) do
		if bar.class == "ActionBar" then
			bar:ACTIONBAR_SHOWHIDEGRID(true) --show the button grid if we have something picked up (i.e if macroDrag contains something)
		end
	end
end

--This is the function that fires when a button is receiving a dragged item
function ACTIONBUTTON:OnReceiveDrag()
	if InCombatLockdown() then --don't allow moving or changing macros while in combat. This will cause taint
		return
	end

	local cursorType, action1, action2, spellID = GetCursorInfo()

	if self:HasAction() then --if our button being dropped onto already has content, we need to cache that content
		macroCache[1] = self:GetDragAction()
		macroCache[2] = self:GetMacroText()
		macroCache[3] = self:GetMacroIcon()
		macroCache[4] = self:GetMacroName()
		macroCache[5] = self:GetMacroNote()
		macroCache[6] = self:GetMacroUseNote()
		macroCache[7] = self.data.macro_BlizzMacro
		macroCache[8] = self.data.macro_EquipmentSet
	else
		wipe(macroCache)
	end

	if macroDrag[1] then --checks to see if the thing we are placing is a Neuron created macro vs something from the spellbook
		self:PlaceMacro()
	elseif cursorType == "spell" then
		self:PlaceSpell(action1, action2, spellID)

	elseif cursorType == "item" then
		self:PlaceItem(action1, action2)

	elseif cursorType == "macro" then
		self:PlaceBlizzMacro(action1)

	elseif cursorType == "equipmentset" then
		self:PlaceBlizzEquipSet(action1)

	elseif cursorType == "mount" then
		self:PlaceMount(action1, action2)

	elseif cursorType == "flyout" then
		self:PlaceFlyout(action1, action2)

	elseif cursorType == "battlepet" then
		self:PlaceBattlePet(action1, action2)
	elseif cursorType == "companion" then
		self:PlaceCompanion(action1, action2)
	elseif cursorType == "petaction" then
		self:PlacePetAbility(action1, action2)
	end

	wipe(macroDrag)

	self:InitializeButton()
	self:UpdateAll()
	self:UpdateCooldown() --clear any cooldowns that may be on the button now that the button is empty

	if macroCache[1] then
		self:OnDragStart(macroCache) --If we picked up a new ability after dropping this one we have to manually call OnDragStart
		for _,bar in pairs(Neuron.bars) do
			bar:ACTIONBAR_SHOWHIDEGRID(true) --show the button grid if we have something picked up (i.e if macroDrag contains something)
		end
	else
		SetCursor(nil)
		ClearCursor() --if we did not pick up a new spell, clear the cursor
		for _,bar in pairs(Neuron.bars) do
			bar:ACTIONBAR_SHOWHIDEGRID() --show the button grid if we have something picked up (i.e if macroDrag contains something)
		end
	end
end


function ACTIONBUTTON:PostClick() --this is necessary because if you are daisy-chain dragging spells to the bar you wont be able to place the last one due to it not firing an OnReceiveDrag
	if macroDrag[1] then
		self:OnReceiveDrag()
	end
	self:UpdateStatus()
end

--we need to hook to the WorldFrame OnReceiveDrag and OnMouseDown so that we can "let go" of the spell when we drag it off the bar
function ACTIONBUTTON:WorldFrame_OnReceiveDrag()
	if macroDrag[1] then --only do something if there's currently data in macroDrag. Otherwise it is just for normal Blizzard behavior
		SetCursor(nil)
		ClearCursor()
		wipe(macroDrag)
		wipe(macroCache)
	end
end
--------------------------------------
--------------------------------------


function ACTIONBUTTON:PickUpMacro()

	if macroCache[1] then  --triggers when picking up an existing button with a button in the cursor

		macroDrag = CopyTable(macroCache)
		wipe(macroCache) --once macroCache is loaded into macroDrag, wipe it

	elseif self:HasAction() then

		macroDrag[1] = self:GetDragAction()
		macroDrag[2] = self:GetMacroText()
		macroDrag[3] = self:GetMacroIcon()
		macroDrag[4] = self:GetMacroName()
        macroDrag[5] = self:GetMacroNote()
		macroDrag[6] = self:GetMacroUseNote()
		macroDrag[7] = self.data.macro_BlizzMacro
		macroDrag[8] = self.data.macro_EquipmentSet

		self:SetMacroText()
		self:SetMacroIcon()
		self:SetMacroName()
        self:SetMacroNote()
		self:SetMacroUseNote()
		self.data.macro_BlizzMacro = false
		self.data.macro_EquipmentSet = false

		self.spell = nil
		self.spellID = nil
		self.item = nil

		self:InitializeButton()
	end


end


function ACTIONBUTTON:PlaceMacro()
	self:SetMacroText(macroDrag[2])
	self:SetMacroIcon(macroDrag[3])
	self:SetMacroName(macroDrag[4])
	self:SetMacroNote(macroDrag[5])
	self:SetMacroUseNote(macroDrag[6])
	self.data.macro_BlizzMacro = macroDrag[7]
	self.data.macro_EquipmentSet = macroDrag[8]

end

function ACTIONBUTTON:PlaceSpell(action1, action2, spellID)
	local spell

	if action1 == 0 then
		-- I am unsure under what conditions (if any) we wouldn't have a spell ID
		if not spellID or spellID == 0 then
			return
		else
			spell = GetSpellInfo(spellID)
		end
	else
		spell,_= GetSpellBookItemName(action1, action2):lower()
		_,spellID = GetSpellBookItemInfo(action1, action2)
	end


	local spellName , _, icon = GetSpellInfo(spellID)

	if not spellName then
		if Neuron.spellCache[spell:lower()] then
			spellName = Neuron.spellCache[spell:lower()].spellName
			icon = Neuron.spellCache[spell:lower()].icon
		end
	end


	self:SetMacroText(self:AutoWriteMacro(spell))
	self:SetMacroIcon() --will pull icon automatically unless explicitly overridden
	self:SetMacroName(spellName)
	self:SetMacroNote()
	self:SetMacroUseNote()
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false
end

function ACTIONBUTTON:PlacePetAbility(action1, action2)

	local spellID = action1
	local spellIndex = action2

	if spellIndex then --if the ability doesn't have a spellIndex, i.e (passive, follow, defensive, etc, print a warning)
		local spellInfoName , _, icon = GetSpellInfo(spellID)

		self:SetMacroText(self:AutoWriteMacro(spellInfoName))
		self:SetMacroIcon() --will pull icon automatically unless explicitly overridden
		self:SetMacroName(spellInfoName)
		self:SetMacroNote()
		self:SetMacroUseNote()
		self.data.macro_BlizzMacro = false
		self.data.macro_EquipmentSet = false

	else
		Neuron:Print(L["DragDrop_Error_Message"])
	end
end


function ACTIONBUTTON:PlaceItem(action1, action2)
	local item, link = GetItemInfo(action2)

	if link and not Neuron.itemCache[item:lower()] then --add the item to the itemcache if it isn't otherwise in it
		local _, itemID = link:match("(item:)(%d+)")
		Neuron.itemCache[item:lower()] = itemID
	end

	if IsEquippableItem(item) then
		self:SetMacroText("/equip "..item.."\n/use "..item)
	else
		self:SetMacroText("/use "..item)
	end

	self:SetMacroIcon() --will pull icon automatically unless explicitly overridden
	self:SetMacroName(item)
	self:SetMacroNote()
	self:SetMacroUseNote()
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false

end


function ACTIONBUTTON:PlaceBlizzMacro(action1)
	if action1 == 0 then
		return
	end

	local name, texture, body = GetMacroInfo(action1)

	if body then
		self:SetMacroText(body)
		self:SetMacroName(name)
		self:SetMacroIcon(texture)
		self.data.macro_BlizzMacro = name
	else
		self:SetMacroText()
		self:SetMacroName()
		self:SetMacroIcon()
		self.data.macro_BlizzMacro = false
	end

	self:SetMacroNote()
	self:SetMacroUseNote()
	self.data.macro_EquipmentSet = false
end


function ACTIONBUTTON:PlaceBlizzEquipSet(equipmentSetName)
	if equipmentSetName == 0 then
		return
	end

	local equipsetNameIndex --cycle through the equipment sets to find the index of the one with the right name

	for i = 0,C_EquipmentSet.GetNumEquipmentSets()-1 do
		if equipmentSetName == C_EquipmentSet.GetEquipmentSetInfo(i) then
			equipsetNameIndex = i
			break
		end
	end

	if not equipsetNameIndex then --bail out of we don't find an equipset index (should never happen but just in case
		return
	end

	local name, texture = C_EquipmentSet.GetEquipmentSetInfo(equipsetNameIndex)

	if texture then
		self:SetMacroText("/equipset "..equipmentSetName)
		self:SetMacroName(name)
		self:SetMacroIcon(texture)
		self.data.macro_EquipmentSet = equipmentSetName
	else
		self:SetMacroText()
		self:SetMacroName()
		self:SetMacroIcon()
		self.data.macro_EquipmentSet = false
	end

	self:SetMacroNote()
	self:SetMacroUseNote()
	self.data.macro_BlizzMacro = false
end


--Hooks mount journal mount buttons on enter to pull spellid from tooltip--
--Based on discussion thread http://www.wowinterface.com/forums/showthread.php?t=49599&page=2
--More dynamic than the manual list that was originally implement

function ACTIONBUTTON:PlaceMount(action1, action2)
	local mountName, mountSpellID, mountIcon = C_MountJournal.GetMountInfoByID(action1)

	if action1 == 0 then
		return
	end

	--The Summon Random Mount from the Mount Journal
	if action1 == 268435455 then
		self:SetMacroText("#autowrite\n/run C_MountJournal.SummonByID(0);")
		self:SetMacroIcon("Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_MOUNTUP")
		self:SetMacroName("Random Mount")
	else
		self:SetMacroText("#autowrite\n/cast "..mountName..";")
		self:SetMacroIcon() --will pull icon automatically unless explicitly overridden
		self:SetMacroName(mountName)
	end
	self:SetMacroNote()
	self:SetMacroUseNote()
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false

end


function ACTIONBUTTON:PlaceCompanion(action1, action2)
	if action1 == 0 then
		return
	end

	local _, _, spellID, icon = GetCompanionInfo(action2, action1)
	local name = GetSpellInfo(spellID)

	if name then
		self:SetMacroName(name)
		self:SetMacroText(self:AutoWriteMacro(name))
	else
		self:SetMacroName()
		self:SetMacroText()
	end

	self:SetMacroIcon(icon) --need to set icon here, it won't pull it automatically
	self:SetMacroNote()
	self:SetMacroUseNote()
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false
end

function ACTIONBUTTON:PlaceBattlePet(action1, action2)
	if action1 == 0 then
		return
	end

	local _, _, _, _, _, _, _,petName, petIcon= C_PetJournal.GetPetInfoByPetID(action1)

	self:SetMacroText("#autowrite\n/summonpet "..petName)
	self:SetMacroIcon(petIcon) --need to set icon here, it won't pull it automatically
	self:SetMacroName(petName)
	self:SetMacroNote()
	self:SetMacroUseNote()
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false
end


function ACTIONBUTTON:PlaceFlyout(action1, action2)
	if action1 == 0 then
		return
	end

	local count = #self.bar.buttons
	local columns = self.bar.data.columns or count
	local rows = count/columns

	local point = self:GetPosition(UIParent)

	if columns/rows > 1 then

		if point:find("BOTTOM") then
			point = "b:t:1"
		elseif point:find("TOP") then
			point = "t:b:1"
		elseif point:find("RIGHT") then
			point = "r:l:12"
		elseif point:find("LEFT") then
			point = "l:r:12"
		else
			point = "r:l:12"
		end
	else
		if point:find("RIGHT") then
			point = "r:l:12"
		elseif point:find("LEFT") then
			point = "l:r:12"
		elseif point:find("BOTTOM") then
			point = "b:t:1"
		elseif point:find("TOP") then
			point = "t:b:1"
		else
			point = "r:l:12"
		end
	end

	self:SetMacroText("/flyout blizz:"..action1..":l:"..point..":c")
	self:SetMacroIcon()
	self:SetMacroName()
	self:SetMacroNote()
	self:SetMacroUseNote()
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false

	self:UpdateFlyout(true)
end


function ACTIONBUTTON:SetMouseCursor()
	if self.spell and self.spellID then
		PickupSpell(self.spellID)
		if GetCursorInfo() then
			return
		end
	end

	if self.item then
		PickupItem(self.item) --this is to try to catch any stragglers that might not have a spellID on the button. Things like mounts and such. This only works on currently available items
		if GetCursorInfo() then --if this isn't a normal spell (like a flyout) or it is a pet abiity, revert to a question mark symbol
			return
		end

		PickupItem(GetItemInfoInstant(self.item))
		if GetCursorInfo() then
			return
		end

		if Neuron.itemCache[self.item:lower()] then --try to pull the spellID from our ItemCache as a last resort
			PickupItem(Neuron.itemCache[self.item:lower()])
			if GetCursorInfo() then
				return
			end
		end
	end

	--failsafe so there is 'something' on the mouse cursor
	PickupItem(1217) --questionmark symbol
end