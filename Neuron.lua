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


---@class Neuron @define The main addon object for the Neuron Action Bar addon
Neuron = LibStub("AceAddon-3.0"):NewAddon(CreateFrame("Frame", nil, UIParent), "Neuron", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
--this is the working pointer that all functions act upon, instead of acting directly on Neuron (it was how it was coded before me. Seems unnecessary)

local DB

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local LATEST_VERSION_NUM = "1.0.3" --this variable is set to popup a welcome message upon updating/installing. Only change it if you want to pop up a message after the users next update

local LATEST_DB_VERSION = 1.3

Neuron.BARIndex = {} --this table will be our main handle for all of our bars.

--prepare the Neuron table with some sub-tables that will be used down the road
Neuron.EDITIndex = {}
Neuron.BINDIndex = {}

Neuron.numLoadedModules = 0

Neuron.registeredBarData = {}
Neuron.registeredGUIData = {}

Neuron.macroDrag = {}
Neuron.startDrag = false


---these are the database tables that are going to hold our data. They are global because every .lua file needs access to them
NeuronItemCache = {} --Stores a cache of all items that have been seen by a Neuron button
NeuronSpellCache = {} --Stores a cache of all spells that have been seen by a Neuron button
NeuronCollectionCache = {} --Stores a cache of all Mounts and Battle Pets that have been seen by a Neuron button
NeuronToyCache = {} --Stores a cache of all toys that have been seen by a Neuron button


Neuron.STRATAS = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP"}


Neuron.STATES = {
	homestate = L["Home State"],
	laststate = L["Last State"],
	paged1 = L["Page 1"],
	paged2 = L["Page 2"],
	paged3 = L["Page 3"],
	paged4 = L["Page 4"],
	paged5 = L["Page 5"],
	paged6 = L["Page 6"],
	pet0 = L["No Pet"],
	pet1 = L["Pet Exists"],
	alt0 = L["Alt Up"],
	alt1 = L["Alt Down"],
	ctrl0 = L["Control Up"],
	ctrl1 = L["Control Down"],
	shift0 = L["Shift Up"],
	shift1 = L["Shift Down"],
	stealth0 = L["No Stealth"],
	stealth1 = L["Stealth"],
	reaction0 = L["Friendly"],
	reaction1 = L["Hostile"],
	combat0 = L["Out of Combat"],
	combat1 = L["In Combat"],
	group0 = L["No Group"],
	group1 = L["Group: Raid"],
	group2 = L["Group: Party"],
	fishing0 = L["No Fishing Pole"],
	fishing1 = L["Fishing Pole"],
	vehicle0 = L["No Vehicle"],
	vehicle1 = L["Vehicle"],
	possess0 = L["No Possess"],
	possess1 = L["Possess"],
	override0 = L["No Override Bar"],
	override1 = L["Override Bar"],
	extrabar0 = L["No Extra Bar"],
	extrabar1 = L["Extra Bar"],
	custom0 = L["Custom States"],
	target0 = L["Has Target"],
	target1 = L["No Target"],
}

Neuron.STATEINDEX = {
	paged = "paged",
	stance = "stance",
	pet = "pet",
	alt = "alt",
	ctrl = "ctrl",
	shift = "shift",
	stealth = "stealth",
	reaction = "reaction",
	combat = "combat",
	group = "group",
	fishing = "fishing",
	vehicle = "vehicle",
	possess = "possess",
	override = "override",
	extrabar = "extrabar",
	custom = "custom",
	target = "target",
}

Neuron.barEditMode = false
Neuron.buttonEditMode = false
Neuron.bindingMode = false

Neuron.SPECIALACTIONS = {
	vehicle = "Interface\\AddOns\\Neuron\\Images\\new_vehicle_exit",
	possess = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
	taxi = "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up",
}

Neuron.unitAuras = { player = {}, target = {}, focus = {} }

Neuron.THROTTLE = 0.2
Neuron.TIMERLIMIT = 4
Neuron.SNAPTO_TOLLERANCE = 28

Neuron.enteredWorld = false --flag that gets set when the player enters the world. It's used primarily for throttling events so that the player doesn't crash on logging with too many processes

-------------------------------------------------------------------------
--------------------Start of Functions-----------------------------------
-------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function Neuron:OnInitialize()

	Neuron.db = LibStub("AceDB-3.0"):New("NeuronProfilesDB", NeuronDefaults)

	Neuron.db.RegisterCallback(Neuron, "OnProfileChanged", "RefreshConfig")
	Neuron.db.RegisterCallback(Neuron, "OnProfileCopied", "RefreshConfig")
	Neuron.db.RegisterCallback(Neuron, "OnProfileReset", "RefreshConfig")
	Neuron.db.RegisterCallback(Neuron, "OnDatabaseReset", "RefreshConfig")

	DB = Neuron.db.profile

	---Check if the current database needs to be migrated, and attempt the migration
	Neuron:DatabaseMigration()


	---load saved variables into working variable containers
	NeuronItemCache = DB.NeuronItemCache
	NeuronSpellCache = DB.NeuronSpellCache
	NeuronCollectionCache = DB.NeuronCollectionCache
	NeuronToyCache = DB.NeuronToyCache

	---these are the working pointers to our global database tables. Each class has a local GDB and CDB table that is a pointer to the root of their associated database
	Neuron.MAS = Neuron.MANAGED_ACTION_STATES
	Neuron.MBS = Neuron.MANAGED_BAR_STATES


	Neuron.class = select(2, UnitClass("player"))


	StaticPopupDialogs["ReloadUI"] = {
		text = "ReloadUI",
		button1 = "Yes",
		OnAccept = function()
			ReloadUI()
		end,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}

	--Initialize the Minimap Icon
	Neuron:Minimap_IconInitialize()

	--Initialize the chat commands (i.e. /neuron)
	Neuron:RegisterChatCommand("neuron", "slashHandler")

	--Load bars and buttons
	Neuron:Startup()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function Neuron:OnEnable()

	Neuron:RegisterEvent("PLAYER_REGEN_DISABLED")
	Neuron:RegisterEvent("PLAYER_ENTERING_WORLD")
	Neuron:RegisterEvent("SPELLS_CHANGED")
	Neuron:RegisterEvent("CHARACTER_POINTS_CHANGED")
	Neuron:RegisterEvent("LEARNED_SPELL_IN_TAB")
	Neuron:RegisterEvent("COMPANION_LEARNED")
	Neuron:RegisterEvent("UNIT_PET")
	Neuron:RegisterEvent("TOYS_UPDATED")
	Neuron:RegisterEvent("PET_JOURNAL_LIST_UPDATE")

	Neuron:RegisterEvent("ACTIONBAR_SHOWGRID")
	Neuron:RegisterEvent("UNIT_AURA")
	Neuron:RegisterEvent("UNIT_SPELLCAST_SENT")
	Neuron:RegisterEvent("UNIT_SPELLCAST_START")
	Neuron:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	Neuron:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")


	Neuron:UpdateStanceStrings()

	---this allows for the "Esc" key to disable the Edit Mode instead of bringing up the game menu, but only if an edit mode is activated.

	if not Neuron:IsHooked(GameMenuFrame, "OnUpdate") then
		Neuron:HookScript(GameMenuFrame, "OnUpdate", function(self)

			if (Neuron.barEditMode) then
				HideUIPanel(self)
				Neuron:ToggleBarEditMode(false)
			end

			if (Neuron.buttonEditMode) then
				HideUIPanel(self)
				Neuron:ToggleButtonEditMode(false)
			end

			if (Neuron.bindingMode) then
				HideUIPanel(self)
				Neuron:ToggleBindingMode(false)
			end

		end)
	end

	Neuron:LoginMessage()


	for _,bar in pairs(Neuron.BARIndex) do
		bar:Load()
	end

end

--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function Neuron:OnDisable()

end

-------------------------------------------------

function Neuron:PLAYER_REGEN_DISABLED()

	if (Neuron.buttonEditMode) then
		Neuron:ToggleButtonEditMode(false)
	end

	if (Neuron.bindingMode) then
		Neuron:ToggleBindingMode(false)
	end

	if (Neuron.barEditMode) then
		Neuron:ToggleBarEditMode(false)
	end

end


function Neuron:PLAYER_ENTERING_WORLD()
	DB.firstRun = false

	Neuron:UpdateSpellCache()
	Neuron:UpdatePetSpellCache()
	Neuron:UpdateStanceStrings()
	Neuron:UpdateCollectionCache()
	Neuron:UpdateToyCache()

	--Fix for Titan causing the Main Bar to not be hidden
	if (IsAddOnLoaded("Titan")) then
		TitanUtils_AddonAdjust("MainMenuBar", true)
	end

	if (DB.blizzbar == false) then
		Neuron:HideBlizzardUI()
	end

	Neuron.enteredWorld = true

end

function Neuron:ACTIVE_TALENT_GROUP_CHANGED()
	Neuron:UpdateSpellCache()
	Neuron:UpdateStanceStrings()
end

function Neuron:LEARNED_SPELL_IN_TAB()
	Neuron:UpdateSpellCache()
	Neuron:UpdateStanceStrings()
end

function Neuron:CHARACTER_POINTS_CHANGED()
	Neuron:UpdateSpellCache()
	Neuron:UpdateStanceStrings()
end

function Neuron:SPELLS_CHANGED()
	Neuron:UpdateSpellCache()
	Neuron:UpdateStanceStrings()
end

function Neuron:COMPANION_LEARNED()
	Neuron:UpdateCollectionCache()
end

function Neuron:PET_JOURNAL_LIST_UPDATE()
	Neuron:UpdateCollectionCache()
end

function Neuron:TOYS_UPDATED(...)
	Neuron:UpdateToyCache()
end

function Neuron:UNIT_PET(_, ...)
	if ... == "player" then
		if (Neuron.enteredWorld) then
			Neuron:UpdatePetSpellCache()
		end
	end
end

function Neuron:ACTIONBAR_SHOWGRID()
	Neuron.startDrag = true
end

function Neuron:UNIT_AURA(_, ...)
	local unit = select(1,...)
	if (Neuron.unitAuras[unit]) then
		if (... == "player") then
			Neuron.ACTIONBUTTON.updateAuraInfo(unit)
		end
	end
end

function Neuron:UNIT_SPELLCAST_SENT(_, ...)
	local unit = select(1,...)
	if (Neuron.unitAuras[unit]) then
		if (... == "player") then
			Neuron.ACTIONBUTTON.updateAuraInfo(unit)
		end
	end
end

function Neuron:UNIT_SPELLCAST_START(_, ...)
	local unit = select(1,...)
	if (Neuron.unitAuras[unit]) then
		if (... == "player") then
			Neuron.ACTIONBUTTON.updateAuraInfo(unit)
		end
	end
end

function Neuron:UNIT_SPELLCAST_SUCCEEDED(_, ...)
	local unit = select(1,...)
	if (Neuron.unitAuras[unit]) then
		if (... == "player") then
			Neuron.ACTIONBUTTON.updateAuraInfo(unit)
		end
	end
end

function Neuron:UNIT_SPELLCAST_CHANNEL_START(_, ...)
	local unit = select(1,...)
	if (Neuron.unitAuras[unit]) then
		if (... == "player") then
			Neuron.ACTIONBUTTON.updateAuraInfo(unit)
		end
	end
end

function Neuron:UNIT_SPELLCAST_SUCCEEDED(_, ...)
	local unit = select(1,...)
	if (Neuron.unitAuras[unit]) then
		if (... == "player") then
			Neuron.ACTIONBUTTON.updateAuraInfo(unit)
		end
	end
end

-------------------------------------------------------------------------
--------------------Profiles---------------------------------------------
-------------------------------------------------------------------------


function Neuron:DatabaseMigration()
	----DATABASE VERSION CHECKING AND MIGRATING----------

	if not DB.DBVersion then
		--we need to know if a profile doesn't have a DBVersion because it is brand new, or because it pre-dates DB versioning
		--when DB Versioning was introduced we also changed xbars to be called "extrabar", so if xbars exists in the database it means it's an old database, not a fresh one
		--eventually we can get rid of this check and just assume that having no DBVersion means that it is a fresh profile
		if not DB.NeuronCDB then --"NeuronCDB" is just a random table value that no longer exists. It's not important aside from the fact it no longer exists
			DB.DBVersion = LATEST_DB_VERSION
		else
			DB.DBVersion = 1.0
		end
	end

	if DB.DBVersion ~= LATEST_DB_VERSION then --checks if the DB version is out of date, and if so it calls the DB Fixer
		local success = pcall(Neuron.DBFixer, Neuron, DB, DB.DBVersion)

		if not success then

			StaticPopupDialogs["Profile_Migration_Failed"] = {
				text = "We are sorry, but your Neuron profile migration has failed. By clicking accept you agree to reset your current profile to the its default values.",
				button1 = ACCEPT,
				button2 = CANCEL,
				timeout = 0,
				whileDead = true,
				OnAccept = function() Neuron.db:ResetProfile() end,
				OnCancel = function() DisableAddOn("Neuron"); ReloadUI() end,
			}

			StaticPopup_Show("Profile_Migration_Failed")

		else
			DB.DBVersion = LATEST_DB_VERSION
			Neuron.db = LibStub("AceDB-3.0"):New("NeuronProfilesDB", NeuronDefaults) --run again to re-register all of our wildcard ['*'] tables back in the newly shifted DB
		end
	end
	-----------------------------------------------------
end



function Neuron:RefreshConfig()
	DB = Neuron.db.profile
	StaticPopup_Show("ReloadUI")
end


-----------------------------------------------------------------


function Neuron:LoginMessage()

	---displays a info window on login for either fresh installs or updates
	if (not DB.updateWarning or DB.updateWarning ~= LATEST_VERSION_NUM ) then

		print(" ")
		print("         ~~~~~~~~~~NEURON~~~~~~~~~")
		print("    Happy New Year, and welcome to 2019!")
		print("    Neuron is in for an exciting year, thank you so much for your support.")
		print("    Please enjoy the substantial performance improvements made this past week, and please continue reporting any bugs you may find.")
		print("       -Soyier")

		if UnitFactionGroup('player') == "Horde" then
			print(" ")
			print("    Use the following link to join the Neuron (Horde) in-game community")
			print("    https://bit.ly/2Lu72NZ")
		end

		if not IsAddOnLoaded("Masque") then
			print(" ")
			print("    You do not currently have Masque installed or enabled.")
			print("    Please consider using Masque for enhancing the visual appearance of Neuron's action buttons.")
		end

		print(" ")

	end


	DB.updateWarning = LATEST_VERSION_NUM
end


--I'm not sure what this function does, but it returns a table of all the names of children of a given frame
function Neuron:GetParentKeys(frame)
	if (frame == nil) then
		return
	end

	local data, childData = {}, {}
	local children = {frame:GetChildren()}
	local regions = {frame:GetRegions()}

	for _,v in pairs(children) do
		table.insert(data, v:GetName())
		childData = Neuron:GetParentKeys(v)
		for _,value in pairs(childData) do
			table.insert(data, value)
		end
	end

	for _,v in pairs(regions) do
		table.insert(data, v:GetName())
	end

	return data
end



--- Creates a table containing provided data
-- @param index, bookType, spellName, altName, spellID, spellID_Alt, spellType, spellLvl, icon
-- @return curSpell:  Table containing provided data
function Neuron:SetSpellInfo(index, bookType, spellName, altName, spellID, spellID_Alt, spellType, spellLvl, icon)
	local curSpell = {}

	curSpell.index = index
	curSpell.booktype = bookType
	curSpell.spellName = spellName
	curSpell.altName = altName
	curSpell.spellID = spellID
	curSpell.spellID_Alt = spellID_Alt
	curSpell.spellType = spellType
	curSpell.spellLvl = spellLvl
	curSpell.icon = icon

	return curSpell
end

--- "()" indexes added because the Blizzard macro parser uses that to determine the difference of a spell versus a usable item if the two happen to have the same name.
--- I forgot this fact and removed using "()" and it made some macros not represent the right spell /sigh. This note is here so I do not forget again :P - Maul


--- Scans Character Spell Book and creates a table of all known spells.  This table is used to refrence macro spell info to generate tooltips and cooldowns.
---	If a spell is not displaying its tooltip or cooldown, then the spell in the macro probably is not in the database
function Neuron:UpdateSpellCache()
	local sIndexMax = 0
	local numTabs = GetNumSpellTabs()

	for i=1,numTabs do
		local _, _, _, numSlots = GetSpellTabInfo(i)

		sIndexMax = sIndexMax + numSlots
	end

	for i = 1,sIndexMax do
		local spellName, _ = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		local spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
		local spellID_Alt = spellID
		local spellLvl = GetSpellAvailableLevel(i, BOOKTYPE_SPELL)

		if (spellName and spellType ~= "FUTURESPELL") then
			local link = GetSpellLink(spellName)
			if (link) then
				_, spellID = link:match("(spell:)(%d+)")
				local tempID = tonumber(spellID)
				if (tempID) then
					spellID = tempID
				end
			end

			local altName, _, icon = GetSpellInfo(spellID)
			if spellID ~= spellID_Alt then
				altName = GetSpellInfo(spellID_Alt)
			end

			local spellData = Neuron:SetSpellInfo(i, BOOKTYPE_SPELL, spellName, altName, spellID, spellID_Alt, spellType, spellLvl, icon)

			NeuronSpellCache[(spellName):lower()] = spellData
			NeuronSpellCache[(spellName):lower().."()"] = spellData


			if (altName and altName ~= spellName) then
				NeuronSpellCache[(altName):lower()] = spellData
				NeuronSpellCache[(altName):lower().."()"] = spellData
			end

		end
	end

	for i = 1, select("#", GetProfessions()) do
		local index = select(i, GetProfessions())

		if (index) then
			local _, _, _, _, numSpells, spelloffset = GetProfessionInfo(index)

			for j=1,numSpells do

				local offsetIndex = j + spelloffset
				local spellName, _ = GetSpellBookItemName(offsetIndex, BOOKTYPE_PROFESSION)
				local spellType, spellID = GetSpellBookItemInfo(offsetIndex, BOOKTYPE_PROFESSION)
				local spellID_Alt = spellID
				local spellLvl = GetSpellAvailableLevel(offsetIndex, BOOKTYPE_PROFESSION)

				if (spellName and spellType ~= "FUTURESPELL") then
					local altName, _, icon = GetSpellInfo(spellID)
					local spellData = Neuron:SetSpellInfo(offsetIndex, BOOKTYPE_PROFESSION, spellName, altName, spellID, spellID_Alt, spellType, spellLvl, icon)

					NeuronSpellCache[(spellName):lower()] = spellData
					NeuronSpellCache[(spellName):lower().."()"] = spellData


					if (altName and altName ~= spellName) then
						NeuronSpellCache[(altName):lower()] = spellData
						NeuronSpellCache[(altName):lower().."()"] = spellData

					end

				end
			end
		end
	end


	---This code collects the data for the Hunter's "Call Pet" Flyout. It is a mystery why it works, but it does

	if(Neuron.class == 'HUNTER') then
		local _, _, numSlots, _ = GetFlyoutInfo(9)

		for i=1, numSlots do
			local spellID, isKnown = GetFlyoutSlotInfo(9, i)
			local petIndex, petName = GetCallPetSpellInfo(spellID)

			if (isKnown and petIndex and petName and #petName > 0) then
				local spellName = GetSpellInfo(spellID)

				for _,v in pairs(NeuronSpellCache) do

					if (v.spellName:find(petName.."$")) then
						local spellData = Neuron:SetSpellInfo(v.index, v.booktype, v.spellName, nil, spellID, v.spellID_Alt, v.spellType, v.spellLvl, v.icon)

						NeuronSpellCache[(spellName):lower()] = spellData
						NeuronSpellCache[(spellName):lower().."()"] = spellData
					end
				end
			end
		end
	end

end


--- Adds pet spells & abilities to the spell list index
function Neuron:UpdatePetSpellCache()

	if (HasPetSpells()) then
		for i=1,HasPetSpells() do
			local spellName, _ = GetSpellBookItemName(i, BOOKTYPE_PET)
			local spellType, _ = GetSpellBookItemInfo(i, BOOKTYPE_PET)
			local spellLvl = GetSpellAvailableLevel(i, BOOKTYPE_PET)

			if (spellName and spellType ~= "FUTURESPELL") then
				local altName, _, icon, _, _, _, spellID = GetSpellInfo(spellName)
				local spellID_Alt = spellID

				local spellData = Neuron:SetSpellInfo(i, BOOKTYPE_PET, spellName, altName, spellID, spellID_Alt, spellType, spellLvl, icon)

				NeuronSpellCache[(spellName):lower()] = spellData
				NeuronSpellCache[(spellName):lower().."()"] = spellData

			end
		end
	end
end


--- Creates a table containing provided companion & mount data
-- @param index, creatureType, index, creatureID, creatureName, spellID, icon
-- @return curComp:  Table containing provided data
function Neuron:SetCompanionData(creatureType, index, creatureID, creatureName, spellID, icon)
	local curComp = {}
	curComp.creatureType = creatureType
	curComp.index = index
	curComp.creatureID = creatureID
	curComp.creatureName = creatureName
	curComp.spellID = spellID
	curComp.icon = icon
	return curComp
end


--- Compiles a list of toys a player has.  This table is used to refrence macro spell info to generate tooltips and cooldowns.
-- toy cache is backwards due to bugs with secure action buttons' inability to
-- cast a toy by item:id (and inability to SetMacroItem from a name /sigh)
-- cache is indexed by the toyName and equals the itemID
-- the attribValue for toys will be the toyName, and unsecure stuff can pull
-- the itemID from toyCache where needed
function Neuron:UpdateToyCache()

	-- fill cache with itemIDs = name
	for i=1,C_ToyBox.GetNumToys() do
		local itemID = C_ToyBox.GetToyFromIndex(i)
		local name = GetItemInfo(itemID) or "UNKNOWN"
		local known = PlayerHasToy(itemID)
		if known then
			NeuronToyCache[name:lower()] = itemID
		end
	end

end


--- Compiles a list of battle pets & mounts a player has.  This table is used to refrence macro spell info to generate tooltips and cooldowns.
---	If a companion is not displaying its tooltip or cooldown, then the item in the macro probably is not in the database
function Neuron:UpdateCollectionCache()

	local _, numpet = C_PetJournal.GetNumPets()

	for i=1,numpet do

		local petID, speciesID, owned, _, _, _, _, speciesName, icon = C_PetJournal.GetPetInfoByIndex(i)

		if (petID and owned) then
			local spell = speciesName
			if (spell) then
				local companionData = Neuron:SetCompanionData("CRITTER", i, speciesID, speciesName, petID, icon)
				NeuronCollectionCache[spell:lower()] = companionData
				NeuronCollectionCache[spell:lower().."()"] = companionData
			end
		end
	end

	local mountIDs = C_MountJournal.GetMountIDs()
	for i,id in pairs(mountIDs) do
		local creatureName , spellID, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(id)

		if (spellID and collected) then
			local spell, _, icon = GetSpellInfo(spellID)
			if (spell) then
				local companionData = Neuron:SetCompanionData("MOUNT", i, spellID, creatureName, spellID, icon)
				NeuronCollectionCache[spell:lower()] = companionData
				NeuronCollectionCache[spell:lower().."()"] = companionData
			end
		end
	end
end



function Neuron:UpdateStanceStrings()
	if (Neuron.class == "DRUID" or
			Neuron.class == "ROGUE") then

		local icon, active, castable, spellID

		local states = "[stance:0] stance0; "

		if (Neuron.class == "DRUID") then

			Neuron.STATES["stance0"] = L["Caster Form"]

			for i=1,6 do
				Neuron.STATES["stance"..i] = nil
			end

			for i=1,GetNumShapeshiftForms() do
				icon, active, castable, spellID = GetShapeshiftFormInfo(i)
				Neuron.STATES["stance"..i], _, _, _, _, _, _ = GetSpellInfo(spellID) --Get the string name of the shapeshift form (now that shapeshifts are considered spells)
				states = states.."[stance:"..i.."] stance"..i.."; "

			end
		end

		--Adds Shadow Dance State for Subelty Rogues
		if (Neuron.class == "ROGUE") then

			Neuron.STATES["stance0"] = L["Melee"]

			Neuron.STATES["stance1"] = L["Stealth"]
			states = states.."[stance:1] stance1; "

			Neuron.STATES["stance2"] = L["Vanish"]
			states = states.."[stance:2] stance2; "

			if(GetSpecialization() == 3) then
				Neuron.STATES["stance3"] = L["Shadow Dance"]
				states = states.."[stance:3] stance3; "
			end
		end

		states = states:gsub("; $", "")

		Neuron.MAS.stance.states = states
	end
end



function Neuron:ToggleButtonGrid(show)
	for _,bar in pairs(Neuron.BARIndex) do

		if bar.barType == "ActionBar" or bar.barType == "PetBar" then
			for _, button in pairs(bar.buttons) do
				button:SetObjectVisibility(show)
			end
		end
	end
end



function Neuron:ToggleMainMenu()
	---need to run the command twice for some reason. The first one only seems to open the Interface panel
	InterfaceOptionsFrame_OpenToCategory("Neuron");
	InterfaceOptionsFrame_OpenToCategory("Neuron");
end

function Neuron:ToggleBarEditMode(show)

	if show and Neuron.barEditMode == false then

		Neuron.barEditMode = true

		Neuron:ToggleButtonEditMode(false)
		Neuron:ToggleBindingMode(false)

		for _, bar in pairs(Neuron.BARIndex) do
			bar:Show() --this shows the transparent overlay over a bar
			bar:Update(true)
			bar:UpdateObjectVisibility(true)
			bar:UpdateObjects()
		end

	else

		Neuron.barEditMode = false

		for _, bar in pairs(Neuron.BARIndex) do
			bar:Hide()
			bar:Update(nil, true)
			bar:UpdateObjectVisibility()
			bar:UpdateObjects()
		end

		if (NeuronBarEditor)then
			NeuronBarEditor:Hide()
		end

	end

end

function Neuron:ToggleButtonEditMode(show)

	if show and Neuron.buttonEditMode == false then

		Neuron.buttonEditMode = true

		Neuron:ToggleBarEditMode(false)
		Neuron:ToggleBindingMode(false)


		for _, editor in pairs(Neuron.EDITIndex) do
			editor:Show()
			editor.object.editmode = true

			if (editor.object.bar) then
				editor:SetFrameStrata(editor.object.bar:GetFrameStrata())
				editor:SetFrameLevel(editor.object.bar:GetFrameLevel()+4)
			end
		end

		for _,bar in pairs(Neuron.BARIndex) do
			bar:UpdateObjectVisibility(true)
			bar:UpdateObjects()
		end


	else

		Neuron.buttonEditMode = false

		for _, editor in pairs(Neuron.EDITIndex) do
			editor:Hide()
			editor.object.editmode = false
			editor:SetFrameStrata("LOW")
		end

		for _,bar in pairs(Neuron.BARIndex) do
			bar:UpdateObjectVisibility()
			bar:UpdateObjects()

			if (bar.handler:GetAttribute("assertstate")) then
				bar.handler:SetAttribute("state-"..bar.handler:GetAttribute("assertstate"), bar.handler:GetAttribute("activestate") or "homestate")
			end
		end

		Neuron.BUTTON:ChangeObject()

		if (NeuronObjectEditor)then
			NeuronObjectEditor:Hide()
		end

	end
end


function Neuron:ToggleBindingMode(show)

	if show and Neuron.bindingMode == false then

		Neuron.bindingMode = true

		Neuron:ToggleButtonEditMode(false)
		Neuron:ToggleBarEditMode(false)


		for _, binder in pairs(Neuron.BINDIndex) do

			binder:Show()
			binder.button.editmode = true

			if (binder.button.bar) then
				binder:SetFrameStrata(binder.button.bar:GetFrameStrata())
				binder:SetFrameLevel(binder.button.bar:GetFrameLevel()+4)
			end
		end

		for _,bar in pairs(Neuron.BARIndex) do
			bar:UpdateObjectVisibility(true)
			bar:UpdateObjects()
		end

	else

		Neuron.bindingMode = false

		for _, binder in pairs(Neuron.BINDIndex) do
			binder:Hide()
			binder.button.editmode = false

			binder:SetFrameStrata("LOW")

		end

		for _,bar in pairs(Neuron.BARIndex) do
			bar:UpdateObjectVisibility()
			bar:UpdateObjects()
		end
	end
end


---This function is called each and every time a Bar-Module loads. It adds the module to the list of currently avaible bars. If we add new bars in the future, this is the place to start
function Neuron:RegisterBarClass(class, barType, barLabel, objType, barDB, objTemplate, objMax)

	Neuron.numLoadedModules = Neuron.numLoadedModules + 1

	Neuron.registeredBarData[class] = {
		barType = barType,
		barLabel = barLabel,
		barDB = barDB,
		objPrefix = objType:gsub("%s+", ""),
		objType = objType,
		objTemplate = objTemplate,
		objMax = objMax,
		createMsg = Neuron.numLoadedModules..objType,
	}

end


function Neuron:RegisterGUIOptions(class, chkOpt, stateOpt, adjOpt)
	Neuron.registeredGUIData[class] = {
		chkOpt = chkOpt,
		stateOpt = stateOpt,
		adjOpt = adjOpt,
	}
end
