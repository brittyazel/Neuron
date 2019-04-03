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


---The functions in this file are part of the ACTIONBUTTON class.
---It was just easier to put them all in their own file for organization.

local ACTIONBUTTON = Neuron.ACTIONBUTTON

local macroDrag = {} --this is a table that holds onto the contents of the  current macro being dragged

local macroCache = {} --this will hold onto any previous contents of our button

--------------------------------------
--------------------------------------

--this is the function that fires when you begin dragging an item
function ACTIONBUTTON:OnDragStart()
	if InCombatLockdown() or not self.bar or self.actionID then
		return
	end

	self.drag = nil --flag that says if it's ok to drag or not

	if (not self.barLock) then
		self.drag = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		self.drag = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		self.drag = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		self.drag = true
	end

	if (self.drag) then

		ClearCursor()

		--This is all just to put an icon on the mousecursor. Sadly we can't use SetCursor, because once you leave the frame the icon goes away. PickupSpell seems to work, but we need a valid spellID
		--This trick here is that we ignore what is 'actually' and are just using it for the icon and the sound effects
		self:SetMouseCursor()

		self:PickUpMacro()

		self:SetType()
		self:UpdateAll()
		self:UpdateCooldown() --clear any cooldowns that may be on the button now that the button is empty

	end

	Neuron:ToggleButtonGrid(true) --show the button grid if we have something picked up (i.e if macroDrag contains something)
end

--This is the function that fires when a button is receiving a dragged item
function ACTIONBUTTON:OnReceiveDrag()
	if InCombatLockdown() then --don't allow moving or changing macros while in combat. This will cause taint
		return
	end

	local cursorType, action1, action2, spellID = GetCursorInfo()

	if (self:HasAction()) then --if our button being dropped onto already has content, we need to cache that content
		macroCache[1] = self:GetDragAction()
		macroCache[2] = self.data.macro_Text
		macroCache[3] = self.data.macro_Icon
		macroCache[4] = self.data.macro_Name
		macroCache[5] = self.data.macro_Auto
		macroCache[6] = self.data.macro_Watch
		macroCache[7] = self.data.macro_Equip
		macroCache[8] = self.data.macro_Note
		macroCache[9] = self.data.macro_UseNote
	else
		wipe(macroCache)
	end


	if (macroDrag[1]) then --checks to see if the thing we are placing is a Neuron created macro vs something from the spellbook
		self:PlaceMacro()
	elseif (cursorType == "spell") then
		self:PlaceSpell(action1, action2, spellID)

	elseif (cursorType == "item") then
		self:PlaceItem(action1, action2)

	elseif (cursorType == "macro") then
		self:PlaceBlizzMacro(action1)

	elseif (cursorType == "equipmentset") then
		self:PlaceBlizzEquipSet(action1)

	elseif (cursorType == "mount") then
		self:PlaceMount(action1, action2)

	elseif (cursorType == "flyout") then
		self:PlaceFlyout(action1, action2)

	elseif (cursorType == "battlepet") then
		self:PlaceBattlePet(action1, action2)
	elseif(cursorType == "companion") then
		self:PlaceCompanion(action1, action2)
	elseif (cursorType == "petaction") then
		self:PlacePetAbility(action1, action2)
	end

	wipe(macroDrag)

	self:SetType()
	self:UpdateAll()
	self:UpdateCooldown() --clear any cooldowns that may be on the button now that the button is empty

	if (macroCache[1]) then
		self:OnDragStart(macroCache) --If we picked up a new ability after dropping this one we have to manually call OnDragStart
		Neuron:ToggleButtonGrid(true)
	else
		SetCursor(nil)
		ClearCursor() --if we did not pick up a new spell, clear the cursor
	end

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		Neuron.NeuronGUI:UpdateObjectGUI()
	end
end


function ACTIONBUTTON:PostClick() --this is necessary because if you are daisy-chain dragging spells to the bar you wont be able to place the last one due to it not firing an OnReceiveDrag
	if macroDrag[1] then
		self:OnReceiveDrag()
	end
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

	local pickup

	if (not self.barLock) then
		pickup = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		pickup = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		pickup = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		pickup = true
	end

	if (pickup) then

		if macroCache[1] then  --triggers when picking up an existing button with a button in the cursor

			macroDrag = CopyTable(macroCache)
			wipe(macroCache) --once macroCache is loaded into macroDrag, wipe it

		elseif (self:HasAction()) then

			macroDrag[1] = self:GetDragAction()
			macroDrag[2] = self.data.macro_Text
			macroDrag[3] = self.data.macro_Icon
			macroDrag[4] = self.data.macro_Name
			macroDrag[5] = self.data.macro_Auto
			macroDrag[6] = self.data.macro_Watch
			macroDrag[7] = self.data.macro_Equip
			macroDrag[8] = self.data.macro_Note
			macroDrag[9] = self.data.macro_UseNote

			self.data.macro_Text = ""
			self.data.macro_Icon = false
			self.data.macro_Name = ""
			self.data.macro_Auto = false
			self.data.macro_Watch = false
			self.data.macro_Equip = false
			self.data.macro_Note = ""
			self.data.macro_UseNote = false

			self.macrospell = nil
			self.spellID = nil
			self.macroitem = nil
			self.macroshow = nil
			self.macroicon = nil

			self:SetType()
		end

	end
end


function ACTIONBUTTON:PlaceMacro()
	self.data.macro_Text = macroDrag[2]
	self.data.macro_Icon = macroDrag[3]
	self.data.macro_Name = macroDrag[4]
	self.data.macro_Auto = macroDrag[5]
	self.data.macro_Watch = macroDrag[6]
	self.data.macro_Equip = macroDrag[7]
	self.data.macro_Note = macroDrag[8]
	self.data.macro_UseNote = macroDrag[9]

end

function ACTIONBUTTON:PlaceSpell(action1, action2, spellID)
	local spell

	if (action1 == 0) then
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


	local spellInfoName, icon

	if (NeuronSpellCache[spell]) then
		spellInfoName = NeuronSpellCache[spell].spellName
		icon = GetSpellTexture(spell) --try getting a new texture first (this is important for things like Wild Charge that has different icons per spec
		if not icon then --if you don't find a new icon (meaning the spell isn't currently learned) default to icon in the database
			icon = NeuronSpellCache[spell].icon
		end
	else
		spellInfoName , _, icon = GetSpellInfo(spellID)
	end


	self.data.macro_Text = self:AutoWriteMacro(spell)
	self.data.macro_Auto = spell

	self.data.macro_Icon = icon  --also set later in SetSpellIcon
	self.data.macro_Name = spellInfoName
	self.data.macro_Watch = false
	self.data.macro_Equip = false
	self.data.macro_Note = ""
	self.data.macro_UseNote = false

end

function ACTIONBUTTON:PlacePetAbility(action1, action2)

	local spellID = action1
	local spellIndex = action2

	if spellIndex then --if the ability doesn't have a spellIndex, i.e (passive, follow, defensive, etc, print a warning)
		local spellInfoName , _, icon = GetSpellInfo(spellID)

		self.data.macro_Text = self:AutoWriteMacro(spellInfoName)

		self.data.macro_Auto = spellInfoName


		self.data.macro_Icon = icon --also set later in SetSpellIcon
		self.data.macro_Name = spellInfoName
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false
		self.data.macro_isPetSpell = true

	else
		Neuron:Print("Sorry, you cannot place that ability at this time.")
	end

end


function ACTIONBUTTON:PlaceItem(action1, action2)
	local item, link = GetItemInfo(action2)

	if link and not NeuronItemCache[item] then --add the item to the itemcache if it isn't otherwise in it
		local _, itemID = link:match("(item:)(%d+)")
		NeuronItemCache[item] = itemID
	end

	if (IsEquippableItem(item)) then
		self.data.macro_Text = "/equip "..item.."\n/use "..item
	else
		self.data.macro_Text = "/use "..item
	end

	self.data.macro_Icon = false
	self.data.macro_Name = item
	self.data.macro_Auto = false
	self.data.macro_Watch = false
	self.data.macro_Equip = false
	self.data.macro_Note = ""
	self.data.macro_UseNote = false

end


function ACTIONBUTTON:PlaceBlizzMacro(action1)
	if (action1 == 0) then
		return
	else

		local name, icon, body = GetMacroInfo(action1)

		if (body) then

			self.data.macro_Text = body
			self.data.macro_Name = name
			self.data.macro_Watch = name
			self.data.macro_Icon = icon
		else
			self.data.macro_Text = ""
			self.data.macro_Name = ""
			self.data.macro_Watch = false
			self.data.macro_Icon = false
		end

		self.data.macro_Equip = false
		self.data.macro_Auto = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

	end
end


function ACTIONBUTTON:PlaceBlizzEquipSet(equipmentSetName)
	if (equipmentSetName == 0) then
		return
	else

		local equipsetNameIndex = 0 --cycle through the equipment sets to find the index of the one with the right name

		for i = 1,C_EquipmentSet.GetNumEquipmentSets() do
			if equipmentSetName == C_EquipmentSet.GetEquipmentSetInfo(i) then
				equipsetNameIndex = i
			end
		end


		local name, icon = C_EquipmentSet.GetEquipmentSetInfo(equipsetNameIndex)
		if (texture) then
			self.data.macro_Text = "/equipset "..equipmentSetName
			self.data.macro_Equip = equipmentSetName
			self.data.macro_Name = name
			self.data.macro_Icon = icon
		else
			self.data.macro_Text = ""
			self.data.macro_Equip = false
			self.data.macro_Name = ""
			self.data.macro_Icon = false
		end

		self.data.macro_Name = ""
		self.data.macro_Watch = false
		self.data.macro_Auto = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

	end
end


--Hooks mount journal mount buttons on enter to pull spellid from tooltip--
--Based on discussion thread http://www.wowinterface.com/forums/showthread.php?t=49599&page=2
--More dynamic than the manual list that was originally implement




function ACTIONBUTTON:PlaceMount(action1, action2)


	local mountName, mountSpellID, mountIcon = C_MountJournal.GetMountInfoByID(action1)

	if (action1 == 0) then
		return
	else
		--The Summon Random Mount from the Mount Journal
		if action1 == 268435455 then
			self.data.macro_Text = "#autowrite\n/run C_MountJournal.SummonByID(0);"
			self.data.macro_Auto = "Random Mount;"
			self.data.macro_Icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_MOUNTUP"
			self.data.macro_Name = "Random Mount"
			--Any other mount from the Journal
		else

			self.data.macro_Text = "#autowrite\n/cast "..mountName..";"
			self.data.macro_Auto = mountName..";"
			self.data.macro_Icon = mountIcon
			self.data.macro_Name = mountName
		end

		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

	end
end


function ACTIONBUTTON:PlaceCompanion(action1, action2)

	if (action1 == 0) then
		return

	else
		local _, _, spellID, icon = GetCompanionInfo(action2, action1)
		local name = GetSpellInfo(spellID)

		if (name) then
			self.data.macro_Name = name
			self.data.macro_Text = self:AutoWriteMacro(name)
			self.data.macro_Auto = name
		else
			self.data.macro_Name = ""
			self.data.macro_Text = ""
			self.data.macro_Auto = false
		end

		self.data.macro_Icon = icon
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

	end
end

function ACTIONBUTTON:PlaceBattlePet(action1, action2)
	local petName, petIcon

	if (action1 == 0) then
		return
	else
		_, _, _, _, _, _, _,petName, petIcon= C_PetJournal.GetPetInfoByPetID(action1)

		self.data.macro_Text = "#autowrite\n/summonpet "..petName
		self.data.macro_Auto = petName..";"
		self.data.macro_Icon = petIcon
		self.data.macro_Name = petName
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

	end
end


function ACTIONBUTTON:PlaceFlyout(action1, action2)
	if (action1 == 0) then
		return
	else
		local count = #self.bar.buttons
		local columns = self.bar.data.columns or count
		local rows = count/columns

		local point = self:GetPosition(UIParent)

		if (columns/rows > 1) then

			if ((point):find("BOTTOM")) then
				point = "b:t:1"
			elseif ((point):find("TOP")) then
				point = "t:b:1"
			elseif ((point):find("RIGHT")) then
				point = "r:l:12"
			elseif ((point):find("LEFT")) then
				point = "l:r:12"
			else
				point = "r:l:12"
			end
		else
			if ((point):find("RIGHT")) then
				point = "r:l:12"
			elseif ((point):find("LEFT")) then
				point = "l:r:12"
			elseif ((point):find("BOTTOM")) then
				point = "b:t:1"
			elseif ((point):find("TOP")) then
				point = "t:b:1"
			else
				point = "r:l:12"
			end
		end

		self.data.macro_Text = "/flyout blizz:"..action1..":l:"..point..":c"
		self.data.macro_Icon = false
		self.data.macro_Name = ""
		self.data.macro_Auto = false
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		self:UpdateFlyout(true)

	end
end


function ACTIONBUTTON:SetMouseCursor()


	if self.macroshow then
		local spellID
		_,_,_,_,_,_,spellID = GetSpellInfo(self.macroshow)
		if spellID then
			PickupSpell(spellID) --this is to try to catch any stragglers that might not have a spellID on the button. Things like mounts and such
		end
		if GetCursorInfo() then --if this isn't a normal spell (like a flyout) or it is a pet abiity, revert to a question mark symbol
			return
		end
	end

	if self.macrospell then
		local spellID
		_,_,_,_,_,_,spellID = GetSpellInfo(self.macrospell)
		if spellID then
			PickupSpell(spellID) --this is to try to catch any stragglers that might not have a spellID on the button. Things like mounts and such
		end
		if GetCursorInfo() then --if this isn't a normal spell (like a flyout) or it is a pet abiity, revert to a question mark symbol
			return
		end
	end

	if self.macroitem then
		PickupItem(self.macroitem) --this is to try to catch any stragglers that might not have a spellID on the button. Things like mounts and such. This only works on currently available items

		if GetCursorInfo() then --if this isn't a normal spell (like a flyout) or it is a pet abiity, revert to a question mark symbol
			return
		end
	end

	--failsafe so there is 'something' on the mouse cursor
	PickupItem(1217) --questionmark symbol




end