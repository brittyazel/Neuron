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

local ACTIONBUTTON = Neuron.ACTIONBUTTON

local macroCache = {}
Neuron.macroCache = macroCache

local macroDrag = {}
Neuron.macroDrag = macroDrag

local startDrag = false
Neuron.startDrag = startDrag



--------------------------------------
--------------------------------------

--This is the function that fires when a button is receiving a dragged item
function ACTIONBUTTON:OnReceiveDrag()
	if (InCombatLockdown()) then
		return
	end

	local cursorType, action1, action2, spellID = GetCursorInfo()

	local texture = self.iconframeicon:GetTexture()

	if (self:HasAction()) then
		wipe(macroCache)

		--macroCache holds on to the previos macro's info if you are dropping a new macro on top of an existing macro
		macroCache[1] = self:GetDragAction()
		macroCache[2] = self
		macroCache[3] = self.data.macro_Text
		macroCache[4] = self.data.macro_Icon
		macroCache[5] = self.data.macro_Name
		macroCache[6] = self.data.macro_Auto
		macroCache[7] = self.data.macro_Watch
		macroCache[8] = self.data.macro_Equip
		macroCache[9] = self.data.macro_Note
		macroCache[10] = self.data.macro_UseNote

		macroCache.texture = texture
	end


	if (macroDrag[1]) then
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


	if (startDrag and macroCache[1]) then
		self:PickUpMacro()
		Neuron:ToggleButtonGrid(true)
	end

	self:UpdateAll()

	startDrag = false

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		Neuron.NeuronGUI:UpdateObjectGUI()
	end
end

--this is the function that fires when you begin dragging an item
function ACTIONBUTTON:OnDragStart(mousebutton)

	if (InCombatLockdown() or not self.bar or self.vehicle_edit or self.actionID) then
		startDrag = false
		return
	end

	self.drag = nil

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
		startDrag = self:GetParent():GetAttribute("activestate")

		self.dragbutton = mousebutton
		self:PickUpMacro()

		if (macroDrag[1]) then

			if (macroDrag[2] ~= self) then
				self.dragbutton = nil
			end

			Neuron:ToggleButtonGrid(true)
		else
			self.dragbutton = nil
		end

		self.iconframecooldown.timer:SetText("")

		self.macroname:SetText("")
		self.count:SetText("")

		self.macrospell = nil
		self.spellID = nil
		self.actionID = nil
		self.macroitem = nil
		self.macroshow = nil
		self.macroicon = nil

		self.border:Hide()

		--shows all action bar buttons in the case you have show grid turned off


	else
		startDrag = false
	end

end


function ACTIONBUTTON:OnDragStop()
	self.drag = nil
	self:UpdateAll()
end


---This function will be used to check if we should release the cursor
function ACTIONBUTTON:OnMouseDown()
	if macroDrag[1] then
		PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)
		wipe(macroDrag)

		for _, bar in pairs(Neuron.BARIndex) do
			bar:UpdateObjectVisibility()
		end
	end
end

function ACTIONBUTTON:PreClick(mousebutton)
	self.cursor = nil

	if (not InCombatLockdown() and MouseIsOver(self)) then
		local cursorType = GetCursorInfo()

		if (cursorType or macroDrag[1]) then
			self.cursor = true

			startDrag = self:GetParent():GetAttribute("activestate")

			self:SetType()

			Neuron:ToggleButtonGrid(true)

			self:OnReceiveDrag(true)

		elseif (mousebutton == "MiddleButton") then
			self.middleclick = self:GetAttribute("type")

			self:SetAttribute("type", "")

		end
	end

end


function ACTIONBUTTON:PostClick(mousebutton)
	if (not InCombatLockdown() and MouseIsOver(self)) then

		if (self.cursor) then
			self:SetType()

			self.cursor = nil

		elseif (self.middleclick) then
			self:SetAttribute("type", self.middleclick)

			self.middleclick = nil
		end
	end
	self:UpdateState()
end


--------------------------------------
--------------------------------------


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

	if (not self.cursor) then
		self:SetType()
	end

	macroDrag[1] = false

	ClearCursor()
	SetCursor(nil)

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

		if (not self.cursor) then
			self:SetType()
		end
	else
		Neuron:Print("Sorry, you cannot place that ability at this time.")
	end

	macroDrag[1] = false

	ClearCursor()
	SetCursor(nil)

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

	if (not self.cursor) then
		self:SetType()
	end

	macroDrag[1] = false

	ClearCursor()
	SetCursor(nil)
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

		if (not self.cursor) then
			self:SetType()
		end

		macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
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

		if (not self.cursor) then
			self:SetType()
		end

		macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
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

		if (not self.cursor) then
			self:SetType()
		end

		macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
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

		if (not self.cursor) then
			self:SetType()
		end

		macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
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


		if (not self.cursor) then
			self:SetType()
		end

		macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
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

		if (not self.cursor) then
			self:SetType()
		end

		macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function ACTIONBUTTON:PlaceMacro()
	self.data.macro_Text = macroDrag[3]
	self.data.macro_Icon = macroDrag[4]
	self.data.macro_Name = macroDrag[5]
	self.data.macro_Auto = macroDrag[6]
	self.data.macro_Watch = macroDrag[7]
	self.data.macro_Equip = macroDrag[8]
	self.data.macro_Note = macroDrag[9]
	self.data.macro_UseNote = macroDrag[10]

	if (not self.cursor) then
		self:SetType()
	end

	PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)

	wipe(macroDrag);
	ClearCursor();
	SetCursor(nil);

	self:UpdateFlyout()
	Neuron:ToggleButtonGrid(false)

end


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
		local texture = self.iconframeicon:GetTexture()

		if (macroCache[1]) then  --triggers when picking up an existing button with a button in the cursor

			wipe(macroDrag)

			for k,v in pairs(macroCache) do
				macroDrag[k] = v
			end

			wipe(macroCache)

			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")


		elseif (self:HasAction()) then
			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")

			macroDrag[1] = self:GetDragAction()
			macroDrag[2] = self
			macroDrag[3] = self.data.macro_Text
			macroDrag[4] = self.data.macro_Icon
			macroDrag[5] = self.data.macro_Name
			macroDrag[6] = self.data.macro_Auto
			macroDrag[7] = self.data.macro_Watch
			macroDrag[8] = self.data.macro_Equip
			macroDrag[9] = self.data.macro_Note
			macroDrag[10] = self.data.macro_UseNote
			macroDrag.texture = texture

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

			self:UpdateFlyout()

			self:SetType()

		end

	end
end