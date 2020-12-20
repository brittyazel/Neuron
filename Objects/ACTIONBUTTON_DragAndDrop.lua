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


---The functions in this file are part of the ACTIONBUTTON class.
---It was just easier to put them all in their own file for organization.

local ACTIONBUTTON = Neuron.ACTIONBUTTON

--this is a table that holds onto the contents of the current CursorInfo or macro being dragged
local macroDrag = {} 
-- DJ: macroCache is local newMacroDrag now that gets copied into macroDrag at end of OnReceiveDrag
local protectDragDataTimeout = 0

--------------------------------------
--------------------------------------

function ACTIONBUTTON:IsDragOk()
	return not self.barLock 
		or (self.barLockAlt and IsAltKeyDown()) 
		or (self.barLockCtrl and IsControlKeyDown()) 
		or (self.barLockShift and IsShiftKeyDown())
end

--this is the function that fires when you begin dragging an item
function ACTIONBUTTON:OnDragStart()
	if InCombatLockdown() or not self.bar or self.actionID then
		return
	end

	--This is all just to put an icon on the mousecursor. Sadly we can't use SetCursor, because once you leave the frame the icon goes away. PickupSpell seems to work, but we need a valid spellID
	--This trick here is that we ignore what is 'actually' and are just using it for the icon and the sound effects
	if self:IsDragOk() and not macroDrag.cursorType then
		macroDrag = self:GetMacroDragData()
		self:SetMouseCursor()
		self:ClearButtonDragData();
		self:SetType()
		self:UpdateAll()
		self:UpdateCooldown() --clear any cooldowns that may be on the button now that the button is empty
	end
end

function ACTIONBUTTON:OnReceiveDrag()
	self:ProcessDrop()
end

--This is the function that fires when a button is receiving a dragged item
function ACTIONBUTTON:ProcessDrop()

	if InCombatLockdown() then --don't allow moving or changing macros while in combat. This will cause taint
		return
	end

	self:GetCursorDragData()
	self:StartDragDataProtectTimeout()

	--we need to have dragData to do something valid here
	if (not macroDrag.cursorType) then
		return;
	end

	local newMacroDrag --this will hold onto any previous contents of our button
	if self:HasAction() then --if our button being dropped onto already has content, we need to cache that content
		newMacroDrag = self:GetMacroDragData();
	end

	if (macroDrag.cursorType == "neuronMacro") then --checks to see if the thing we are placing is a Neuron created macro vs something from the spellbook
		self:PlaceMacro()

	elseif macroDrag.cursorType == "spell" then
		self:PlaceSpell(macroDrag.action1, macroDrag.action2, macroDrag.spellID)

	elseif macroDrag.cursorType == "item" then
		self:PlaceItem(macroDrag.action1, macroDrag.action2)

	elseif macroDrag.cursorType == "macro" then
		self:PlaceBlizzMacro(macroDrag.action1)

	elseif macroDrag.cursorType == "equipmentset" then
		self:PlaceBlizzEquipSet(macroDrag.action1)

	elseif macroDrag.cursorType == "mount" then
		self:PlaceMount(macroDrag.action1, macroDrag.action2)

	elseif macroDrag.cursorType == "flyout" then
		self:PlaceFlyout(macroDrag.action1, macroDrag.action2)

	elseif macroDrag.cursorType == "battlepet" then
		self:PlaceBattlePet(macroDrag.action1, macroDrag.action2)

	elseif macroDrag.cursorType == "companion" then
		self:PlaceCompanion(macroDrag.action1, macroDrag.action2)

	elseif macroDrag.cursorType == "petaction" then
		self:PlacePetAbility(macroDrag.action1, macroDrag.action2)
	end

	wipe(macroDrag)

	self:SetType()
	self:UpdateAll()
	self:UpdateCooldown() --clear any cooldowns that may be on the button now that the button is empty

	--If we picked up a new ability after dropping this one we have to manually call OnDragStart
	if newMacroDrag then
		macroDrag = newMacroDrag
		self:SetMouseCursor()
		self:ACTIONBAR_SHOWGRID() --show the button grid if we have something picked up (i.e if macroDrag contains something)
	else
		SetCursor(nil)
		ClearCursor() --if we did not pick up a new spell, clear the cursor
	end

	if NeuronObjectEditor and NeuronObjectEditor:IsVisible() then
		Neuron.NeuronGUI:UpdateObjectGUI()
	end

	--PostClick handler called this even after nothing happened. Do we need this?
	--self:UpdateStatus()
end

function ACTIONBUTTON:GetCursorDragData()
	if (not macroDrag.cursorType) then
		local cursorType, action1, action2, spellID = GetCursorInfo()
		macroDrag.cursorType = cursorType
		macroDrag.action1 = action1
		macroDrag.action2 = action2
		macroDrag.spellID = spellID
	end
end

--we delete macroDrag data on HIDEGRID event when we press right click, but only after this timeout has passed. 
--A 1/60 of a frame or less should be enough. This only needs to protect the dragData from hidegrid being triggered in the same frame just as we drop the action on a button. Maybe there is an underlying issue in neuron that triggers these extra hide actionbar events that also erase the cursor type data, but for now this works well
function ACTIONBUTTON:StartDragDataProtectTimeout()
	protectDragDataTimeout = GetTime() + 0.001
end

function ACTIONBUTTON:PostClick(mouseButton)
	self:StartDragDataProtectTimeout()
	self:ProcessDrop()
end

function ACTIONBUTTON:OnMouseDown(mouseButton)
	--save crusorInfo into macroDrag
	self:GetCursorDragData()
	self:StartDragDataProtectTimeout()
end

--this is necessary because if you are daisy-chain dragging spells to the bar you wont be able to place the last one due to it not firing an OnReceiveDrag
function ACTIONBUTTON:OnMouseUp() 
	self:StartDragDataProtectTimeout()
end

function ACTIONBUTTON:ACTIONBAR_HIDEGRID()
	if (macroDrag.cursorType and (GetTime() > protectDragDataTimeout)) then
		wipe(macroDrag)
	end
	self:UpdateObjectVisibility()
end

function ACTIONBUTTON:SetMouseCursor()
	ClearCursor() --ClearCursor seems to lead to ACTIONBAR_HIDEGRID
	--DJ: Please review. I'm not sure about the contents of the button self.spell and self.item that gets stored here. Ultimately the data is stored in macroDrag anyways
	if (not macroDrag.item and macroDrag.spellID) then
		PickupSpell(macroDrag.spellID)

	elseif macroDrag.item then
		PickupItem(macroDrag.item) --this is to try to catch any stragglers that might not have a spellID on the button. Things like mounts and such. This only works on currently available items
		if GetCursorInfo() then --if this isn't a normal spell (like a flyout) or it is a pet abiity, revert to a question mark symbol
			return
		end

		PickupItem(GetItemInfoInstant(macroDrag.item))
		if GetCursorInfo() then
			return
		end

		if NeuronItemCache[macroDrag.item:lower()] then 
			PickupItem(NeuronItemCache[macroDrag.item:lower()])
			if GetCursorInfo() then
				return
			end
		end
	end
	
	--DJ: Should this be removed? This leads to empty buttons producing a ? icon when draggin which is confusing
	--if not GetCursorInfo() then
	--	--failsafe so there is 'something' on the mouse cursor
	--	PickupItem(1217) --questionmark symbol
	--end
end

--------------------------------------
--------------------------------------


function ACTIONBUTTON:GetMacroDragData()
	local dragData = {}
	dragData.cursorType = "neuronMacro"
	dragData[2] = self.data.macro_Text
	dragData[3] = self.data.macro_Icon
	dragData[4] = self.data.macro_Name
	dragData[5] = self.data.macro_Note
	dragData[6] = self.data.macro_UseNote
	dragData[7] = self.data.macro_BlizzMacro
	dragData[8] = self.data.macro_EquipmentSet
	dragData.spell = self.spell -- for drag and drop cursor
	dragData.spellID = self.spellID
	dragData.item = self.item
	return dragData;
end

function ACTIONBUTTON:ClearButtonDragData()

	self.data.macro_Text = ""
	self.data.macro_Icon = false
	self.data.macro_Name = ""
	self.data.macro_Note = ""
	self.data.macro_UseNote = false
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false

	self.spell = nil
	self.spellID = nil
	self.item = nil

	self:SetType()
end


function ACTIONBUTTON:PlaceMacro()
	self.data.macro_Text = macroDrag[2]
	self.data.macro_Icon = macroDrag[3]
	self.data.macro_Name = macroDrag[4]
	self.data.macro_Note = macroDrag[5]
	self.data.macro_UseNote = macroDrag[6]
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
		if NeuronSpellCache[spell:lower()] then
			spellName = NeuronSpellCache[spell:lower()].spellName
			icon = NeuronSpellCache[spell:lower()].icon
		end
	end


	self.data.macro_Text = self:AutoWriteMacro(spell)
	self.data.macro_Icon = false --will pull icon automatically unless explicitly overridden
	self.data.macro_Name = spellName
	self.data.macro_Note = ""
	self.data.macro_UseNote = false
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false
end

function ACTIONBUTTON:PlacePetAbility(action1, action2)

	local spellID = action1
	local spellIndex = action2

	if spellIndex then --if the ability doesn't have a spellIndex, i.e (passive, follow, defensive, etc, print a warning)
		local spellInfoName , _, icon = GetSpellInfo(spellID)

		self.data.macro_Text = self:AutoWriteMacro(spellInfoName)
		self.data.macro_Icon = false --will pull icon automatically unless explicitly overridden
		self.data.macro_Name = spellInfoName
		self.data.macro_Note = ""
		self.data.macro_UseNote = false
		self.data.macro_BlizzMacro = false
		self.data.macro_EquipmentSet = false
		self.data.macro_isPetSpell = true

	else
		Neuron:Print("Sorry, you cannot place that ability at this time.")
	end
end


function ACTIONBUTTON:PlaceItem(action1, action2)
	local item, link = GetItemInfo(action2)

	if link and not NeuronItemCache[item:lower()] then --add the item to the itemcache if it isn't otherwise in it
		local _, itemID = link:match("(item:)(%d+)")
		NeuronItemCache[item:lower()] = itemID
	end

	if IsEquippableItem(item) then
		self.data.macro_Text = "/equip "..item.."\n/use "..item
	else
		self.data.macro_Text = "/use "..item
	end

	self.data.macro_Icon = false --will pull icon automatically unless explicitly overridden
	self.data.macro_Name = item
	self.data.macro_Note = ""
	self.data.macro_UseNote = false
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false

end


function ACTIONBUTTON:PlaceBlizzMacro(action1)
	if action1 == 0 then
		return
	end

	local name, texture, body = GetMacroInfo(action1)

	if body then
		self.data.macro_Text = body
		self.data.macro_Name = name
		self.data.macro_Icon = texture
		self.data.macro_BlizzMacro = name
	else
		self.data.macro_Text = ""
		self.data.macro_Name = ""
		self.data.macro_Icon = false
		self.data.macro_BlizzMacro = false
	end

	self.data.macro_Note = ""
	self.data.macro_UseNote = false
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
		self.data.macro_Text = "/equipset "..equipmentSetName
		self.data.macro_Name = name
		self.data.macro_Icon = texture
		self.data.macro_EquipmentSet = equipmentSetName
	else
		self.data.macro_Text = ""
		self.data.macro_Name = ""
		self.data.macro_Icon = false
		self.data.macro_EquipmentSet = false
	end

	self.data.macro_Note = ""
	self.data.macro_UseNote = false
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
		self.data.macro_Text = "#autowrite\n/run C_MountJournal.SummonByID(0);"
		self.data.macro_Icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_MOUNTUP"
		self.data.macro_Name = "Random Mount"
	else
		local mountSpellName = GetSpellInfo(mountSpellID) -- the journal name is not always the same as the spell name (paladin mount and chauffeured mount)		
		self.data.macro_Text = "#autowrite\n/cast "..mountSpellName..";"
		self.data.macro_Icon = false --will pull icon automatically unless explicitly overridden
		self.data.macro_Name = mountName
	end
	self.data.macro_Note = ""
	self.data.macro_UseNote = false
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
		self.data.macro_Name = name
		self.data.macro_Text = self:AutoWriteMacro(name)
	else
		self.data.macro_Name = ""
		self.data.macro_Text = ""
	end

	self.data.macro_Icon = icon --need to set icon here, it won't pull it automatically
	self.data.macro_Note = ""
	self.data.macro_UseNote = false
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false
end

function ACTIONBUTTON:PlaceBattlePet(action1, action2)
	if action1 == 0 then
		return
	end

	local _, _, _, _, _, _, _,petName, petIcon= C_PetJournal.GetPetInfoByPetID(action1)

	self.data.macro_Text = "#autowrite\n/summonpet "..petName
	self.data.macro_Icon = petIcon --need to set icon here, it won't pull it automatically
	self.data.macro_Name = petName
	self.data.macro_Note = ""
	self.data.macro_UseNote = false
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

	self.data.macro_Text = "/flyout blizz:"..action1..":l:"..point..":c"
	self.data.macro_Icon = false
	self.data.macro_Name = ""
	self.data.macro_Note = ""
	self.data.macro_UseNote = false
	self.data.macro_BlizzMacro = false
	self.data.macro_EquipmentSet = false

	self:UpdateFlyout(true)
end
