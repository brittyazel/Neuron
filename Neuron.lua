-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)


local _, addonTable = ...

local Spec = addonTable.utilities.Spec
local DBFixer = addonTable.utilities.DBFixer

---@class Neuron : AceAddon-3.0 @define The main addon object for the Neuron Action Bar addon
addonTable.Neuron = LibStub("AceAddon-3.0"):NewAddon(CreateFrame("Frame", nil, UIParent), "Neuron", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0", "AceSerializer-3.0")
local Neuron = addonTable.Neuron

local DB

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local LATEST_VERSION_NUM = "1.4.1" --this variable is set to popup a welcome message upon updating/installing. Only change it if you want to pop up a message after the users next update

--prepare the Neuron table with some sub-tables that will be used down the road
Neuron.bars = {} --this table will be our main handle for all of our bars.

Neuron.registeredBarData = {}
Neuron.registeredGUIData = {}

--these are the database tables that are going to hold our data. They are global because every .lua file needs access to them
Neuron.itemCache = {} --Stores a cache of all items that have been seen by a Neuron button
Neuron.spellCache = {} --Stores a cache of all spells that have been seen by a Neuron button

Neuron.barEditMode = false
Neuron.buttonEditMode = false
Neuron.bindingMode = false

Neuron.isWoWClassicEra = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
Neuron.isWoWWrathClassic = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
Neuron.isWoWRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

Neuron.STRATAS = {
	[1] = "BACKGROUND",
	[2] = "LOW",
	[3] = "MEDIUM",
	[4] = "HIGH",
	[5] = "DIALOG",
	[6] = "TOOLTIP"
}

Neuron.TIMERLIMIT = 4
Neuron.SNAPTO_TOLERANCE = 28

Neuron.DEBUG = true

-------------------------------------------------------------------------
--------------------Start of Functions-----------------------------------
-------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function Neuron:OnInitialize()
	Neuron.db = LibStub("AceDB-3.0"):New("NeuronProfilesDB", addonTable.databaseDefaults)

	Neuron.db.RegisterCallback(Neuron, "OnProfileChanged", "RefreshConfig")
	Neuron.db.RegisterCallback(Neuron, "OnProfileCopied", "RefreshConfig")
	Neuron.db.RegisterCallback(Neuron, "OnProfileReset", "RefreshConfig")
	Neuron.db.RegisterCallback(Neuron, "OnDatabaseReset", "RefreshConfig")


	--Check if the current database needs to be migrated, and attempt the migration
	Neuron.db = DBFixer.databaseMigration(Neuron.db)
	DB = Neuron.db.profile


	--load saved variables into working variable containers
	Neuron.itemCache = DB.NeuronItemCache
	Neuron.spellCache = DB.NeuronSpellCache

	Neuron.class = select(2, UnitClass("player"))
	Neuron:UpdateStanceStrings()

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
	--Neuron:RegisterChatCommand("neuron", "slashHandler")

	--build all bar and button frames and run initial setup
	Neuron:Startup()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function Neuron:OnEnable()
	if Neuron.DEBUG then
		_G.Neuron = Neuron
	end

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

	--Load all bars and buttons
	for _,v in pairs(Neuron.bars) do
		v:Load()
	end

	--this is a hack for 10.0. They broke everything with regard to the way addons interface with
	--SecureActionButtons see SecureTemplates.lua SecureActionButton_OnClick() for more information
	SetCVar("ActionButtonUseKeyDown", 0)

	Neuron:Overrides()

	Neuron.NeuronGUI:LoadInterfaceOptions()

end

--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function Neuron:OnDisable()
	SetCVar("ActionButtonUseKeyDown", 1)
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

-------------------------------------------------------------------------
--------------------Profiles---------------------------------------------
-------------------------------------------------------------------------


function Neuron:RefreshConfig()
	StaticPopup_Show("ReloadUI")
end

-----------------------------------------------------------------


function Neuron:LoginMessage()
	--displays a info window on login for either fresh installs or updates
	if not DB.updateWarning or DB.updateWarning ~= LATEST_VERSION_NUM  then
		if not IsAddOnLoaded("Masque") then
			print(" ")
			print("    You do not currently have Masque installed or enabled.")
			print("    Please consider using Masque for enhancing the visual appearance of Neuron's action buttons.")
			print("    We recommend using Masque: Neuron, the theme made by Soyier for use with Neuron.")
			print(" ")
		end
	end

	DB.updateWarning = LATEST_VERSION_NUM

	if Spec.active(true) > 4 then
		print(" ")
		Neuron:Print("Warning: You do not currently have a specialization selected. Changes to any buttons which have 'Multi Spec' set will not persist.")
		print(" ")
	end

	--Shadowlands warning that will show as long as a player has one button on their ZoneAbilityBar for Shadowlands content
	if Neuron.isWoWRetail and UnitLevel("player") >= 50 and Neuron.db.profile.ZoneAbilityBar[1] and #Neuron.db.profile.ZoneAbilityBar[1].buttons == 1 then
		print(" ")
		Neuron:Print(WrapTextInColorCode("IMPORTANT: Shadowlands content now requires multiple Zone Ability Buttons. Please add at least 3 buttons to your Zone Ability Bar to support this new functionality.", "FF00FFEC"))
		print(" ")
	end
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

			Neuron.spellCache[(spellName):lower()] = spellData
			Neuron.spellCache[(spellName):lower().."()"] = spellData


			--reverse main and alt so we can put both in the table accurately
			local altSpellData = Neuron:SetSpellInfo(i, BOOKTYPE_SPELL, spellType, altName, altSpellID, altIcon, spellName, spellID, icon)

			if altName and altName ~= spellName then
				Neuron.spellCache[(altName):lower()] = altSpellData
				Neuron.spellCache[(altName):lower().."()"] = altSpellData
			end

		end
	end

	if Neuron.isWoWRetail then
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

						Neuron.spellCache[(spellName):lower()] = spellData
						Neuron.spellCache[(spellName):lower().."()"] = spellData

					end
				end
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
	if show then
		Neuron.barEditMode = true
		Neuron:ToggleButtonEditMode(false)
		Neuron:ToggleBindingMode(false)

		for _, bar in pairs(Neuron.bars) do
			bar:Show() --this shows the transparent overlay over a bar
			bar:UpdateObjectVisibility(true)
			bar:UpdateBarStatus(true)
			bar:UpdateObjectStatus()
		end

		--if there is no bar selected, default to the first in the BarList
		--TODO: This logic may be unintuitive. Should probably be fixed
		if not Neuron.currentBar then
			Neuron.Bar.ChangeSelectedBar(Neuron.bars[1])
		end
	else
		Neuron.barEditMode = false
		for _, bar in pairs(Neuron.bars) do
			bar:Hide()
			bar:UpdateObjectVisibility()
			bar:UpdateBarStatus()
			bar:UpdateObjectStatus()
		end
	end
end

function Neuron:ToggleButtonEditMode(show)
	if show then
		Neuron.buttonEditMode = true

		Neuron:ToggleBarEditMode(false)
		Neuron:ToggleBindingMode(false)
		
		for _, bar in pairs(Neuron.bars) do
			for _, button in pairs(bar.buttons) do
				if button.editFrame then
					button.editFrame:Show()

					--TODO: This code needs work. This logic is very rudimentary
					if not Neuron.currentButton then
						if Neuron.currentBar then
							if Neuron.currentBar.buttons[1].editFrame then --try to set the selected button to the first button on the selected bar, if it has an edit frame
								Neuron.Button.ChangeSelectedButton(Neuron.currentBar.buttons[1])
							else
								Neuron.Button.ChangeSelectedButton(button) --if there's no edit frame, then just default to the selected button to the first bar in the list
							end
						else
							Neuron.Button.ChangeSelectedButton(button) --default to the selected button to the first bar in the list
						end
					end
				end
			end

			bar:UpdateObjectVisibility(true)
			bar:UpdateBarStatus(true)
			bar:UpdateObjectStatus()
			bar:UpdateObjectUsability()
		end

	else
		Neuron.buttonEditMode = false

		for _, bar in pairs(Neuron.bars) do
			for _, button in pairs(bar.buttons) do
				if button.editFrame then
					button.editFrame:Hide()
				end
			end

			bar:UpdateObjectVisibility()
			bar:UpdateBarStatus()
			bar:UpdateObjectStatus()
			bar:UpdateObjectUsability()
		end
	end
end

function Neuron:ToggleBindingMode(show)
	if show then
		Neuron.bindingMode = true
		Neuron:ToggleButtonEditMode(false)
		Neuron:ToggleBarEditMode(false)

		for _, bar in pairs(Neuron.bars) do
			for _, button in pairs(bar.buttons) do
				if button.keybindFrame then
					button.keybindFrame:Show()
				end
			end

			bar:UpdateObjectVisibility(true)
			bar:UpdateBarStatus(true)
			bar:UpdateObjectStatus()
			bar:UpdateObjectUsability()
		end

	else
		Neuron.bindingMode = false
		for _, bar in pairs(Neuron.bars) do
			for _, button in pairs(bar.buttons) do
				if button.keybindFrame then
					button.keybindFrame:Hide()
				end
			end
			bar:UpdateObjectVisibility()
			bar:UpdateBarStatus()
			bar:UpdateObjectStatus()
			bar:UpdateObjectUsability()
		end
	end
end

---This function is called each and every time a Bar-Module loads. It adds the module to the list of currently available bars. If we add new bars in the future, this is the place to start
function Neuron:RegisterBarClass(class, barType, barLabel, objType, barDB, objTemplate, objMax)
	Neuron.registeredBarData[class] = {
		class = class;
		barType = barType,
		barLabel = barLabel,
		objType = objType,
		barDB = barDB,
		objTemplate = objTemplate,
		objMax = objMax,
	}
end

function Neuron:RegisterGUIOptions(class, generalOptions, visualOptions)
	Neuron.registeredGUIData[class] = {
		class = class;
		generalOptions = generalOptions,
		visualOptions = visualOptions,
	}
end


function Neuron:GetSerializedAndCompressedProfile()
	local uncompressed = Neuron:Serialize(Neuron.db.profile) --serialize the database into a string value
	local compressed = LibDeflate:CompressZlib(uncompressed) --compress the data
	local encoded = LibDeflate:EncodeForPrint(compressed) --encode the data for print for copy+paste
	return encoded
end

function Neuron:SetSerializedAndCompressedProfile(input)
	--check if the input is empty
	if input == "" then
		Neuron:Print(L["No data to import."].." "..L["Aborting."])
		return
	end

	--decode and check if decoding worked properly
	local decoded = LibDeflate:DecodeForPrint(input)
	if decoded == nil then
		Neuron:Print(L["Decoding failed."].." "..L["Aborting."])
		return
	end

	--uncompress and check if uncompresion worked properly
	local uncompressed = LibDeflate:DecompressZlib(decoded)
	if uncompressed == nil then
		Neuron:Print(L["Decompression failed."].." "..L["Aborting."])
		return
	end

	--deserialize the data and return it back into a table format
	local result, newProfile = Neuron:Deserialize(uncompressed)

	if result == true and newProfile then --if we successfully deserialize, load the new table and reload
		for k,v in pairs(newProfile) do
			if type(v) == "table" then
				Neuron.db.profile[k] = CopyTable(v)
			else
				Neuron.db.profile[k] = v
			end
		end
		ReloadUI()
	else
		Neuron:Print(L["Data import Failed."].." "..L["Aborting."])
	end
end
