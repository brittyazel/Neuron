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


---@class Neuron @define The main addon object for the Neuron Action Bar addon
Neuron = LibStub("AceAddon-3.0"):NewAddon(CreateFrame("Frame", nil, UIParent), "Neuron", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

local DB

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local LATEST_VERSION_NUM = "1.2.3a" --this variable is set to popup a welcome message upon updating/installing. Only change it if you want to pop up a message after the users next update

local LATEST_DB_VERSION = 1.3

--prepare the Neuron table with some sub-tables that will be used down the road
Neuron.BARIndex = {} --this table will be our main handle for all of our bars.
Neuron.EDITIndex = {}
Neuron.BINDIndex = {}

Neuron.registeredBarData = {}
Neuron.registeredGUIData = {}


--these are the database tables that are going to hold our data. They are global because every .lua file needs access to them
NeuronItemCache = {} --Stores a cache of all items that have been seen by a Neuron button
NeuronSpellCache = {} --Stores a cache of all spells that have been seen by a Neuron button


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

Neuron.TIMERLIMIT = 4
Neuron.SNAPTO_TOLLERANCE = 28

Neuron.enteredWorld = false --flag that gets set when the player enters the world. It's used primarily for throttling events so that the player doesn't crash on logging with too many processes

if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then --boolean check to set a flag if the current session is WoW Classic. Retail == 1, Classic == 2
	Neuron.isWoWClassic = true
end

Neuron.activeSpec = 1

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

	--Check if the current database needs to be migrated, and attempt the migration
	Neuron:DatabaseMigration()


	--load saved variables into working variable containers
	NeuronItemCache = DB.NeuronItemCache
	NeuronSpellCache = DB.NeuronSpellCache

	--these are the working pointers to our global database tables. Each class has a local GDB and CDB table that is a pointer to the root of their associated database
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

	--build all bar and button frames and run initial setup
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

	Neuron:UpdateStanceStrings()

	--this allows for the "Esc" key to disable the Edit Mode instead of bringing up the game menu, but only if an edit mode is activated.

	if not Neuron:IsHooked(GameMenuFrame, "OnUpdate") then
		Neuron:HookScript(GameMenuFrame, "OnUpdate", function(self)

			if Neuron.barEditMode then
				HideUIPanel(self)
				Neuron:ToggleBarEditMode(false)
			end

			if Neuron.buttonEditMode then
				HideUIPanel(self)
				Neuron:ToggleButtonEditMode(false)
			end

			if Neuron.bindingMode then
				HideUIPanel(self)
				Neuron:ToggleBindingMode(false)
			end

		end)
	end

	Neuron:LoginMessage()

	if not Neuron.isWoWClassic then
		Neuron.activeSpec = GetSpecialization()
	end

	--Load all bars and buttons
	for i,v in pairs(Neuron.BARIndex) do
		v:Load()
	end

	Neuron:Overrides()

end

--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function Neuron:OnDisable()

end

-------------------------------------------------

function Neuron:PLAYER_REGEN_DISABLED()
	if Neuron.buttonEditMode then
		Neuron:ToggleButtonEditMode(false)
	end

	if Neuron.bindingMode then
		Neuron:ToggleBindingMode(false)
	end

	if Neuron.barEditMode then
		Neuron:ToggleBarEditMode(false)
	end
end


function Neuron:PLAYER_ENTERING_WORLD()
	DB.firstRun = false

	Neuron:UpdateSpellCache()
	Neuron:UpdateStanceStrings()

	--Fix for Titan causing the Main Bar to not be hidden
	if IsAddOnLoaded("Titan") then
		TitanUtils_AddonAdjust("MainMenuBar", true)
	end

	if DB.blizzbar == false then
		Neuron:HideBlizzardUI()
	end

	Neuron.enteredWorld = true
end

function Neuron:ACTIVE_TALENT_GROUP_CHANGED()
	Neuron.activeSpec = GetSpecialization()

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
	StaticPopup_Show("ReloadUI")
end


-----------------------------------------------------------------


function Neuron:LoginMessage()

	--displays a info window on login for either fresh installs or updates
	if not DB.updateWarning or DB.updateWarning ~= LATEST_VERSION_NUM  then

		print(" ")
		print("                  ~~~~~~~~~~NEURON~~~~~~~~~")
		print("    Ladies and Gentlemen,")
		print("    Lots of work is underway on Neuron 2.0, which will include a fully rewritten core, GUI, modules, and more. Likewise, please reach out if you are interested in contributing to Neuron's development, we always need more help coding and translating, and, as always, donations are welcome!")
		print("    In addition, we recently released a custom Masque theme just for Neuron, called Masque: Neuron. You can find it on CurseForge or the Twitch app.")
		print("       -Soyier")

		if not IsAddOnLoaded("Masque") then
			print(" ")
			print("    You do not currently have Masque installed or enabled.")
			print("    Please consider using Masque for enhancing the visual appearance of Neuron's action buttons.")
			print("    We recommend using Masque: Neuron, the theme made by Soyier for use with Neuron.")
		end

		print(" ")

	end

	DB.updateWarning = LATEST_VERSION_NUM
end


--I'm not sure what this function does, but it returns a table of all the names of children of a given frame
function Neuron:GetParentKeys(frame)
	if frame == nil then
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
-- @param index, bookType, spellName, altName, spellID, altSpellID, spellType, icon
-- @return curSpell:  Table containing provided data
function Neuron:SetSpellInfo(index, bookType, spellType, spellName, spellID, icon, altName, altSpellID, altIcon)
	local curSpell = {}

	curSpell.index = index
	curSpell.booktype = bookType

	curSpell.spellType = spellType
	curSpell.spellName = spellName
	curSpell.spellID = spellID
	curSpell.icon = icon

	curSpell.altName = altName
	curSpell.altSpellID = altSpellID
	curSpell.altIcon = altIcon

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
		local spellName, _ = GetSpellBookItemName(i, BOOKTYPE_SPELL) --this returns the baseSpell name, even if it is augmented by talents. I.e. Roll and Chi Torpedo
		local spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
		local isPassive
		if spellName then
			isPassive = IsPassiveSpell(i, BOOKTYPE_SPELL)
		end
		local icon = GetSpellTexture(spellID)

		local altName
		local altSpellID
		local altIcon

		if (spellName and spellType ~= "FUTURESPELL") and not isPassive then

			altName, _, altIcon, _, _, _, altSpellID = GetSpellInfo(spellName)

			if spellID == altSpellID then
				altSpellID = nil
				altName = nil
				altIcon = nil
			end

			local spellData = Neuron:SetSpellInfo(i, BOOKTYPE_SPELL, spellType, spellName, spellID, icon, altName, altSpellID, altIcon)

			NeuronSpellCache[(spellName):lower()] = spellData
			NeuronSpellCache[(spellName):lower().."()"] = spellData


			--reverse main and alt so we can put both in the table accurately
			local altSpellData = Neuron:SetSpellInfo(i, BOOKTYPE_SPELL, spellType, altName, altSpellID, altIcon, spellName, spellID, icon)

			if altName and altName ~= spellName then
				NeuronSpellCache[(altName):lower()] = altSpellData
				NeuronSpellCache[(altName):lower().."()"] = altSpellData
			end

		end
	end

	if not Neuron.isWoWClassic then
		for i = 1, select("#", GetProfessions()) do
			local index = select(i, GetProfessions())

			if index then
				local _, _, _, _, numSpells, spelloffset = GetProfessionInfo(index)

				for j=1,numSpells do

					local offsetIndex = j + spelloffset
					local spellName, _ = GetSpellBookItemName(offsetIndex, BOOKTYPE_PROFESSION)
					local spellType, spellID = GetSpellBookItemInfo(offsetIndex, BOOKTYPE_PROFESSION)
					local icon

					if spellName and spellType ~= "FUTURESPELL" then
						icon = GetSpellTexture(spellID)
						local spellData = Neuron:SetSpellInfo(offsetIndex, BOOKTYPE_PROFESSION, spellType, spellName, spellID, icon,nil,  nil, nil)

						NeuronSpellCache[(spellName):lower()] = spellData
						NeuronSpellCache[(spellName):lower().."()"] = spellData

					end
				end
			end
		end
	end

end


function Neuron:UpdateStanceStrings()
	if Neuron.class == "DRUID" or Neuron.class == "ROGUE" then

		local icon, active, castable, spellID

		local states = "[stance:0] stance0; "

		if Neuron.class == "DRUID" then

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
		if Neuron.class == "ROGUE" then

			Neuron.STATES["stance0"] = L["Melee"]

			Neuron.STATES["stance1"] = L["Stealth"]
			states = states.."[stance:1] stance1; "

			Neuron.STATES["stance2"] = L["Vanish"]
			states = states.."[stance:2] stance2; "

			if Neuron.activeSpec == 3 then
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
				button:UpdateObjectVisibility(show)
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
			bar:UpdateObjectUsability()
			bar:UpdateBarObjectVisibility(true)
		end

	else

		Neuron.barEditMode = false

		for _, bar in pairs(Neuron.BARIndex) do
			bar:Hide()
			bar:Update(nil, true)
			bar:UpdateObjectUsability()
			bar:UpdateBarObjectVisibility()
		end

		if NeuronBarEditor then
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

			if editor.object.bar then
				editor:SetFrameStrata(editor.object.bar:GetFrameStrata())
				editor:SetFrameLevel(editor.object.bar:GetFrameLevel()+4)
			end
		end

		for _,bar in pairs(Neuron.BARIndex) do
			bar:UpdateObjectUsability()
			bar:UpdateBarObjectVisibility(true)
		end


	else

		Neuron.buttonEditMode = false

		for _, editor in pairs(Neuron.EDITIndex) do
			editor:Hide()
			editor.object.editmode = false
			editor:SetFrameStrata("LOW")
		end

		for _,bar in pairs(Neuron.BARIndex) do
			bar:UpdateObjectUsability()
			bar:UpdateBarObjectVisibility()

			if bar.handler:GetAttribute("assertstate") then
				bar.handler:SetAttribute("state-"..bar.handler:GetAttribute("assertstate"), bar.handler:GetAttribute("activestate") or "homestate")
			end
		end

		Neuron.BUTTON:ChangeObject()

		if NeuronObjectEditor then
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

			if binder.button.bar then
				binder:SetFrameStrata(binder.button.bar:GetFrameStrata())
				binder:SetFrameLevel(binder.button.bar:GetFrameLevel()+4)
			end
		end

		for _,bar in pairs(Neuron.BARIndex) do
			bar:UpdateObjectUsability()
			bar:UpdateBarObjectVisibility(true)
		end

	else

		Neuron.bindingMode = false

		for _, binder in pairs(Neuron.BINDIndex) do
			binder:Hide()
			binder.button.editmode = false

			binder:SetFrameStrata("LOW")

		end

		for _,bar in pairs(Neuron.BARIndex) do
			bar:UpdateObjectUsability()
			bar:UpdateBarObjectVisibility()
		end
	end
end


---This function is called each and every time a Bar-Module loads. It adds the module to the list of currently available bars. If we add new bars in the future, this is the place to start
function Neuron:RegisterBarClass(class, barType, barLabel, objType, barDB, objTemplate, objMax, keybindable)

	Neuron.registeredBarData[class] = {
		class = class;
		barType = barType,
		barLabel = barLabel,
		objType = objType,
		barDB = barDB,
		objTemplate = objTemplate,
		objMax = objMax,
		keybindable = keybindable,
	}

end


function Neuron:RegisterGUIOptions(class, chkOpt, stateOpt, adjOpt)
	Neuron.registeredGUIData[class] = {
		class = class;
		chkOpt = chkOpt,
		stateOpt = stateOpt,
		adjOpt = adjOpt,
	}
end
