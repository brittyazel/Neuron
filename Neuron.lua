--Neuron, a World of Warcraft® user interface addon.

-------------------------------------------------------------------------------
-- Localized Lua globals.
-------------------------------------------------------------------------------
local addonName = ...

local GDB, CDB

local NeuronFrame = CreateFrame("Frame", nil, UIParent) --this is a frame mostly used to assign OnEvent functions
Neuron = LibStub("AceAddon-3.0"):NewAddon(NeuronFrame, "Neuron", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local NEURON = Neuron --this is the working pointer that all functions act upon, instead of acting directly on Neuron (it was how it was coded before me. Seems unnecessary)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local BAR --gets set to NEURON.BAR in the OnEvent method

local icons = {}

NEURON.PEW = false

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------

local latestVersionNum = "0.9.19" --this variable is set to popup a welcome message upon updating/installing. Only change it if you want to pop up a message after the users next update

--I don't think it's worth localizing these two strings. It's too much effort for messages that are going to change often. Sorry to everyone who doesn't speak English
local Install_Message = [[Thanks for installing Neuron.

Neuron is currently in a "|cffffff00release|r" state.

If you have any questions or concerns please direct all inquirires our Github page or through Curseforge, which are listed in the F.A.Q.

Cheers,

-Soyier]]

local Update_Message = [[Thanks for updating Neuron!

*****IMPORTANT, PLEASE READ!*****
A ton of backend work has been made in this release. An obsurd amount even.

The Stance bar has been retired for good. It really doesn't make sense to have so much code for something that only effects Druids, and can easily be re-created by dragging the druid forms onto a simple action bar.

If you have any strange addon behavior, please delete the addon files from WoW>Interface>addons and reinstall the files (make careful not not to delete your addon settings)

There may be issues with Flyout functionality, please report.

-Soyier]]


NEURON['sIndex'] = {}
NEURON['iIndex'] = {[1] = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK" }
NEURON['cIndex'] = {}
NEURON['tIndex'] = {}
NEURON['StanceIndex'] = {}
NEURON['ShowGrids'] = {}
NEURON['HideGrids'] = {}
NEURON['BARIndex'] = {}
NEURON['BARNameIndex'] = {}
NEURON['BTNIndex'] = {}
NEURON['EDITIndex'] = {}
NEURON['BINDIndex'] = {}
NEURON['SKINIndex'] = {}
NEURON['ModuleIndex'] = 0
NEURON['RegisteredBarData'] = {}
NEURON['RegisteredGUIData'] = {}
NEURON['MacroDrag'] = {}
NEURON['StartDrag'] = false
NEURON['maxActionID'] = 132
NEURON['maxPetID'] = 10
NEURON['maxStanceID'] = NUM_STANCE_SLOTS

local BARIndex = NEURON.BARIndex
local BARNameIndex = NEURON.BARNameIndex
local BTNIndex = NEURON.BTNIndex
local ICONS = NEURON.iIndex

---these are the database tables that are going to hold our data
NeuronGDB = {
	bars = {},
	buttons = {},

	buttonLoc = {-0.85, -111.45},
	buttonRadius = 87.5,

	throttle = 0.2,
	timerLimit = 4,
	snapToTol = 28,

	mainbar = false,
	zoneabilitybar = false,
	vehicle = false,

	firstRun = true,

	NeuronIcon = {hide = false,},
}

NeuronCDB = {
	bars = {},
	buttons = {},

	xbars = {},
	xbtns = {},

	bagbars = {},
	bagbtns = {},

	zoneabilitybars = {},
	zoneabilitybtns = {},

	menubars = {},
	menubtns = {},

	petbars = {},
	petbtns = {},

	statusbars = {},
	statusbtns = {},

	selfCast = false,
	focusCast = false,
	mouseOverMod= "NONE",

	layOut = 1,

	perCharBinds = false,
	firstRun = true,

	AutoWatch = 1,

	xbarFirstRun = true,
	zoneabilitybarFirstRun = true,
	bagbarFirstRun = true,
	menubarFirstRun = true,
	petbarFirstRun = true,
	statusbarFirstRun = true,

}

NeuronItemCache = {}


---this is the Default profile when you "load defaults" in the ace profile window
NeuronDefaults = {}
NeuronDefaults['profile'] = {} --populate the Default profile with globals
NeuronDefaults.profile['NeuronCDB'] = NeuronCDB
NeuronDefaults.profile['NeuronGDB'] = NeuronGDB
NeuronDefaults.profile['NeuronItemCache'] = NeuronItemCache


NEURON.GameVersion, NEURON.GameBuild, NEURON.GameDate, NEURON.TOCVersion = GetBuildInfo()

NEURON.GameVersion = tonumber(NEURON.GameVersion);
NEURON.TOCVersion = tonumber(NEURON.TOCVersion)

NEURON.Points = {R = "RIGHT", L = "LEFT", T = "TOP", B = "BOTTOM", TL = "TOPLEFT", TR = "TOPRIGHT", BL = "BOTTOMLEFT", BR = "BOTTOMRIGHT", C = "CENTER", RIGHT = "RIGHT", LEFT = "LEFT", TOP = "TOP", BOTTOM = "BOTTOM", TOPLEFT = "TOPLEFT", TOPRIGHT = "TOPRIGHT", BOTTOMLEFT = "BOTTOMLEFT", BOTTOMRIGHT = "BOTTOMRIGHT", CENTER = "CENTER"}

NEURON.Stratas = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP"}


NEURON.STATES = {
	homestate = L["Home State"],
	laststate = L["Last State"],
	paged1 = L["Page 1"],
	paged2 = L["Page 2"],
	paged3 = L["Page 3"],
	paged4 = L["Page 4"],
	paged5 = L["Page 5"],
	paged6 = L["Page 6"],
	--pet0 = L["No Pet"],
	--pet1 = L["Pet Exists"],
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
	--extrabar0 = L["No Extra Bar"],
	--extrabar1 = L["Extra Bar"],
	custom0 = L["Custom States"],
	target0 = L["Has Target"],
	target1 = L["No Target"],
}

NEURON.STATEINDEX = {
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

local handler = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")

local level, stanceStringsUpdated

local interfaceOptions

-------------------------------------------------------------------------
--------------------Start of Functions-----------------------------------
-------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NEURON:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("NeuronProfilesDB", NeuronDefaults)
	self:SetupInterfaceOptions()
	LibStub("AceConfigRegistry-3.0"):ValidateOptionsTable(interfaceOptions, addonName)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, interfaceOptions)

	interfaceOptions.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)

	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	self.db.RegisterCallback(self, "OnDatabaseReset", "RefreshConfig")

	if (not Neuron.db.profile["NeuronCDB"]) then
		self.db.profile["NeuronCDB"] = NeuronCDB
	end
	if (not Neuron.db.profile["NeuronGDB"]) then
		self.db.profile["NeuronGDB"] = NeuronGDB
	end
	if (not Neuron.db.profile["NeuronItemCache"]) then
		self.db.profile["NeuronItemCache"] = NeuronItemCache
	end

	---load saved variables into working variable containers
	NeuronCDB = self.db.profile["NeuronCDB"]
	NeuronGDB = self.db.profile["NeuronGDB"]
	NeuronItemCache = self.db.profile["NeuronItemCache"]

	InterfaceOptionsFrame:SetFrameStrata("HIGH")

	NEURON:RegisterChatCommand("neuron", "slashHandler")


	GDB = NeuronGDB; CDB = NeuronCDB;

	NEURON.MAS = Neuron.MANAGED_ACTION_STATES
	NEURON.MBS = Neuron.MANAGED_BAR_STATES

	BAR = NEURON.BAR

	NEURON.player, NEURON.class, NEURON.level, NEURON.realm = UnitName("player"), select(2, UnitClass("player")), UnitLevel("player"), GetRealmName()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NEURON:OnEnable()

	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("SPELLS_CHANGED")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED")
	self:RegisterEvent("LEARNED_SPELL_IN_TAB")
	self:RegisterEvent("PET_UI_CLOSE")
	self:RegisterEvent("COMPANION_LEARNED")
	self:RegisterEvent("COMPANION_UPDATE")
	self:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
	self:RegisterEvent("UNIT_LEVEL")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("TOYS_UPDATED")

	NEURON:HookScript(self, "OnUpdate", "controlOnUpdate")

	local function hideAlerts(frame)
		if (not GDB.mainbar) then
			frame:Hide()
		end
	end

	if (CompanionsMicroButtonAlert) then
		CompanionsMicroButtonAlert:HookScript("OnShow", hideAlerts)
	end


	NEURON:UpdateStanceStrings()

	GameMenuFrame:HookScript("OnShow", function(self)

		if (NEURON.BarsShown) then
			HideUIPanel(self); NEURON:ToggleBars(nil, true)
		end

		if (NEURON.EditFrameShown) then
			HideUIPanel(self); NEURON:ToggleEditFrames(nil, true)
		end

		if (NEURON.BindingMode) then
			HideUIPanel(self); NEURON:ToggleBindings(nil, true)
		end

	end)

	StaticPopupDialogs["NEURON_UPDATE_WARNING"] = {
		text = Update_Message,
		button1 = OKAY,
		timeout = 0,
		OnAccept = function() GDB.updateWarning = latestVersionNum end
	}

	StaticPopupDialogs["NEURON_INSTALL_MESSAGE"] = {
		text = Install_Message,
		button1 = OKAY,
		timeout = 0,
		OnAccept = function() GDB.updateWarning = latestVersionNum end,
	}

end

--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NEURON:OnDisable()

end

-------------------------------------------------

function NEURON:PLAYER_REGEN_DISABLED()

	if (NEURON.EditFrameShown) then
		NEURON:ToggleEditFrames(nil, true)
	end

	if (NEURON.BindingMode) then
		NEURON:ToggleBindings(nil, true)
	end

	if (NEURON.BarsShown) then
		NEURON:ToggleBars(nil, true)
	end

end


function NEURON:PLAYER_ENTERING_WORLD()
	GDB.firstRun = false
	CDB.firstRun = false

	NEURON:UpdateSpellIndex()
	NEURON:UpdatePetSpellIndex()
	NEURON:UpdateStanceStrings()
	NEURON:UpdateCompanionData()
	NEURON:UpdateToyData()
	NEURON:UpdateIconIndex()

	--Fix for Titan causing the Main Bar to not be hidden
	if (IsAddOnLoaded("Titan")) then
		TitanUtils_AddonAdjust("MainMenuBar", true)
	end

	NEURON:ToggleBlizzBar(GDB.mainbar)


	NEURON.PEW = true

	if (GDB.updateWarning ~= latestVersionNum and GDB.updateWarning~=nil) then
		StaticPopup_Show("NEURON_UPDATE_WARNING")
	elseif(GDB.updateWarning==nil) then
		StaticPopup_Show("NEURON_INSTALL_MESSAGE")
	end
end

function NEURON:ACTIVE_TALENT_GROUP_CHANGED()
	NEURON:UpdateSpellIndex()
	NEURON:UpdateStanceStrings()
end

function NEURON:LEARNED_SPELL_IN_TAB()
	NEURON:UpdateSpellIndex()
	NEURON:UpdateStanceStrings()
end

function NEURON:CHARACTER_POINTS_CHANGED()
	NEURON:UpdateSpellIndex()
	NEURON:UpdateStanceStrings()
end

function NEURON:SPELLS_CHANGED()
	NEURON:UpdateSpellIndex()
	NEURON:UpdateStanceStrings()
end

function NEURON:PET_UI_CLOSE()
	if not CollectionsJournal or not CollectionsJournal:IsShown() then
		NEURON:UpdateCompanionData()
	end
end

function NEURON:COMPANION_LEARNED()
	if not CollectionsJournal or not CollectionsJournal:IsShown() then
		NEURON:UpdateCompanionData()
	end
end

function NEURON:COMPANION_UPDATE()
	if not CollectionsJournal or not CollectionsJournal:IsShown() then
		NEURON:UpdateCompanionData()
	end
end

function NEURON:PET_JOURNAL_LIST_UPDATE()
	if not CollectionsJournal or not CollectionsJournal:IsShown() then
		NEURON:UpdateCompanionData()
	end
end


function NEURON:UNIT_PET(eventName, ...)
	if ... == "player" then
		if (NEURON.PEW) then
			NEURON:UpdatePetSpellIndex()
		end
	end
end

function NEURON:UNIT_LEVEL(eventName, ...)
	if ... == "player" then
		NEURON.level = UnitLevel("player")
	end
end

function NEURON:TOYS_UPDATED()
	if not ToyBox or not ToyBox:IsShown() then
		NEURON:UpdateToyData()
	end
end


---TODO:figure out what to do with this
local frame = CreateFrame("GameTooltip", "NeuronTooltipScan", UIParent, "GameTooltipTemplate")
frame:SetOwner(UIParent, "ANCHOR_NONE")
frame:SetFrameStrata("TOOLTIP")
frame:Hide()


-------------------------------------------------------------------------
--------------------Profiles---------------------------------------------
-------------------------------------------------------------------------

function NEURON:RefreshConfig()
	NeuronCDB = self.db.profile["NeuronCDB"]
	NeuronGDB = self.db.profile["NeuronGDB"]

	GDB, CDB =  NeuronGDB, NeuronCDB
	NEURON.NeuronButton.ButtonProfileUpdate()

	StaticPopup_Show("ReloadUI")
end


StaticPopupDialogs["ReloadUI"] = {
	text = "ReloadUI",
	button1 = "Yes",
	OnAccept = function()
		ReloadUI()
	end,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}



--------------------------------------------
--------------Slash Functions --------------
--------------------------------------------

--large table that contains the localized name, localized description, and internal setting name for each slash function
local slashFunctions = {
	{L["Menu"], L["Menu_Description"], "ToggleMainMenu"},
	{L["Create"], L["Create_Description"], "CreateNewBar"},
	{L["Delete"], L["Delete_Description"], "DeleteBar"},
	{L["Config"], L["Config_Description"], "ToggleBars"},
	{L["Add"], L["Add_Description"], "AddObjects"},
	{L["Remove"], L["Remove_Description"], "RemoveObjects"},
	{L["Edit"], L["Edit_Description"], "ToggleEditFrames"},
	{L["Bind"], L["Bind_Description"], "ToggleBindings"},
	{L["Scale"], L["Scale_Description"], "ScaleBar"},
	{L["SnapTo"], L["SnapTo_Description"], "SnapToBar"},
	{L["AutoHide"], L["AutoHide_Description"], "AutoHideBar"},
	{L["Conceal"], L["Conceal_Description"], "ConcealBar"},
	{L["Shape"], L["Shape_Description"], "ShapeBar"},
	{L["Name"], L["Name_Description"], "NameBar"},
	{L["Strata"], L["Strata_Description"], "StrataSet"},
	{L["Alpha"], L["Alpha_Description"], "AlphaSet"},
	{L["AlphaUp"], L["AlphaUp_Description"], "AlphaUpSet"},
	{L["ArcStart"], L["ArcStart_Description"], "ArcStartSet"},
	{L["ArcLen"], L["ArcLen_Description"], "ArcLengthSet"},
	{L["Columns"], L["Columns_Description"], "ColumnsSet"},
	{L["PadH"], L["PadH_Description"], "PadHSet"},
	{L["PadV"], L["PadV_Description"], "PadVSet"},
	{L["PadHV"], L["PadHV_Description"], "PadHVSet"},
	{L["X"], L["X_Description"], "XAxisSet"},
	{L["Y"], L["Y_Description"], "YAxisSet"},
	{L["State"], L["State_Description"], "SetState"},
	{L["StateList"], L["StateList_Description"], "PrintStateList"},
	{L["Vis"], L["Vis_Description"], "SetVisibility"},
	{L["ShowGrid"], L["ShowGrid_Description"], "ShowGridSet"},
	{L["Lock"], L["Lock_Description"], "LockSet"},
	{L["Tooltips"], L["Tooltips_Description"], "ToolTipSet"},
	{L["SpellGlow"], L["SpellGlow_Description"], "SpellGlowSet"},
	{L["BindText"], L["BindText_Description"], "BindTextSet"},
	{L["MacroText"], L["MacroText_Description"], "MacroTextSet"},
	{L["CountText"], L["CountText_Description"], "CountTextSet"},
	{L["CDText"], L["CDText_Description"], "CDTextSet"},
	{L["CDAlpha"], L["CDAlpha_Description"], "CDAlphaSet"},
	{L["AuraText"], L["AuraText_Description"], "AuraTextSet"},
	{L["AuraInd"], L["AuraInd_Description"], "AuraIndSet"},
	{L["UpClick"], L["UpClick_Description"], "UpClicksSet"},
	{L["DownClick"], L["DownClick_Description"], "DownClicksSet"},
	{L["TimerLimit"], L["TimerLimit_Description"], "SetTimerLimit"},
	{L["BarTypes"], L["BarTypes_Description"], "PrintBarTypes"},
	{L["BlizzBar"], L["BlizzBar_Description"], "BlizzBar"},
}


---New Slash functionality using Ace3
function NEURON:slashHandler(input)

	if (strlen(input)==0 or input:lower() == "help") then
		printSlashHelp()
		return
	end

	local commandAndArgs = {strsplit(" ", input)} --split the input into the command and the arguments
	local command = commandAndArgs[1]:lower()
	local args = {}
	for i = 2,#commandAndArgs do
		args[i-1] = commandAndArgs[i]:lower()
	end


	for i = 1,#slashFunctions do

		if (command == slashFunctions[i][1]:lower()) then
			local func = slashFunctions[i][3]
			local bar = NEURON.CurrentBar

			if (NEURON[func]) then
				NEURON[func](NEURON, args[1])
			elseif (bar and bar[func]) then
				bar[func](bar, args[1]) --not sure what to do for more than 1 arg input
			else
				Neuron:Print(L["No bar selected or command invalid"])
			end
			return
		end
	end



end

function printSlashHelp()

	Neuron:Print("---------------------------------------------------")
	Neuron:Print(L["How to use"]..":   ".."/"..addonName:lower().." <"..L["Command"]:lower().."> <"..L["Option"]:lower()..">")
	Neuron:Print(L["Command List"]..":")
	Neuron:Print("---------------------------------------------------")

	for i = 1,#slashFunctions do
		--formats the output to be the command name and then the description
		Neuron:Print(slashFunctions[i][1].." - " .."("..slashFunctions[i][2]..")")
	end

end




------------------------------------------------------------
--------------------Intermediate Functions------------------
------------------------------------------------------------


---this is the new controlOnUpdate function that will control all the other onUpdate functions.
function NEURON:controlOnUpdate(frame, elapsed)
	if not self.elapsed then
		self.elapsed = 0
	end

	self.elapsed = self.elapsed + elapsed

	---Throttled OnUpdate calls
	if (self.elapsed > GDB.throttle and NEURON.PEW) then

		NEURON.NeuronBar.controlOnUpdate(self, elapsed)
		NEURON.NeuronButton.cooldownsOnUpdate(self, elapsed)
		NEURON.NeuronZoneAbilityBar.controlOnUpdate(self, elapsed)
		NEURON.NeuronPetBar.controlOnUpdate(self, elapsed)
		NEURON.NeuronStatusBar:controlOnUpdate(elapsed)

		self.elapsed = 0;
	end

	---UnThrottled OnUpdate calls
	if(NEURON.PEW) then
		NEURON.NeuronButton.controlOnUpdate(self, elapsed) --this one needs to not be throttled otherwise spell button glows won't operate at 60fps
	end

end


function NEURON:GetParentKeys(frame)
	if (frame == nil) then
		return
	end

	local data, childData = {}, {}
	local children, regions = {frame:GetChildren()}, {frame:GetRegions()}

	for k,v in pairs(children) do
		tinsert(data, v:GetName())
		childData = NEURON:GetParentKeys(v)
		for key,value in pairs(childData) do
			tinsert(data, value)
		end
	end

	for k,v in pairs(regions) do
		tinsert(data, v:GetName())
	end

	return data
end



--- Creates a table containing provided data
-- @param index, bookType, spellName, altName, subName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon
-- @return curSpell:  Table containing provided data
local function SetSpellInfo(index, bookType, spellName, altName, subName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)
	local curSpell = {}

	curSpell.index = index
	curSpell.booktype = bookType
	curSpell.spellName = spellName
	curSpell.altName = altName
	curSpell.subName = subName
	curSpell.spellID = spellID
	curSpell.spellID_Alt = spellID_Alt
	curSpell.spellType = spellType
	curSpell.spellLvl = spellLvl
	curSpell.isPassive = isPassive
	curSpell.icon = icon

	return curSpell
end

--- "()" indexes added because the Blizzard macro parser uses that to determine the difference of a spell versus a usable item if the two happen to have the same name.
--- I forgot this fact and removed using "()" and it made some macros not represent the right spell /sigh. This note is here so I do not forget again :P - Maul


--- Scans Character Spell Book and creates a table of all known spells.  This table is used to refrence macro spell info to generate tooltips and cooldowns.
---	If a spell is not displaying its tooltip or cooldown, then the spell in the macro probably is not in the database
function NEURON:UpdateSpellIndex()
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
		local icon = GetSpellBookItemTexture(i, BOOKTYPE_SPELL)
		local isPassive = IsPassiveSpell(i, BOOKTYPE_SPELL)

		if (spellName and spellType ~= "FUTURESPELL") then
			local link = GetSpellLink(spellName)
			if (link) then
				_, spellID = link:match("(spell:)(%d+)")
				local tempID = tonumber(spellID)
				if (tempID) then
					spellID = tempID
				end
			end

			local altName, subName, icon, castTime, minRange, maxRange = GetSpellInfo(spellID)
			if spellID ~= spellID_Alt then
				altName = GetSpellInfo(spellID_Alt)
			end

			local spellData = SetSpellInfo(i, BOOKTYPE_SPELL, spellName, altName, subName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)

			if (subName and #subName > 0) then
				NEURON.sIndex[(spellName.."("..subName..")"):lower()] = spellData
			else
				NEURON.sIndex[(spellName):lower()] = spellData
				NEURON.sIndex[(spellName):lower().."()"] = spellData
			end

			if (altName and altName ~= spellName) then
				if (subName and #subName > 0) then
					NEURON.sIndex[(altName.."("..subName..")"):lower()] = spellData
				else
					NEURON.sIndex[(altName):lower()] = spellData
					NEURON.sIndex[(altName):lower().."()"] = spellData
				end
			end

			if (spellID) then
				NEURON.sIndex[spellID] = spellData
			end

			if (icon and not icons[icon]) then
				ICONS[#ICONS+1] = icon; icons[icon] = true
			end
		end
	end

	for i = 1, select("#", GetProfessions()) do
		local index = select(i, GetProfessions())

		if (index) then
			local _, _, _, _, numSpells, spelloffset = GetProfessionInfo(index)

			for i=1,numSpells do
				local offsetIndex = i + spelloffset
				local spellName, _ = GetSpellBookItemName(offsetIndex, BOOKTYPE_PROFESSION)
				local spellType, spellID = GetSpellBookItemInfo(offsetIndex, BOOKTYPE_PROFESSION)
				local spellID_Alt = spellID
				local spellLvl = GetSpellAvailableLevel(offsetIndex, BOOKTYPE_PROFESSION)
				local icon = GetSpellBookItemTexture(offsetIndex, BOOKTYPE_PROFESSION)
				local isPassive = IsPassiveSpell(offsetIndex, BOOKTYPE_PROFESSION)

				if (spellName and spellType ~= "FUTURESPELL") then
					local altName, subName, icon, castTime, minRange, maxRange = GetSpellInfo(spellID)
					local spellData = SetSpellInfo(offsetIndex, BOOKTYPE_PROFESSION, spellName, altName, subName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)

					if (subName and #subName > 0) then
						NEURON.sIndex[(spellName.."("..subName..")"):lower()] = spellData
					else
						NEURON.sIndex[(spellName):lower()] = spellData
						NEURON.sIndex[(spellName):lower().."()"] = spellData
					end

					if (altName and altName ~= spellName) then
						if (subName and #subName > 0) then
							NEURON.sIndex[(altName.."("..subName..")"):lower()] = spellData
						else
							NEURON.sIndex[(altName):lower()] = spellData
							NEURON.sIndex[(altName):lower().."()"] = spellData
						end
					end

					if (spellID) then
						NEURON.sIndex[spellID] = spellData
					end

					if (icon and not icons[icon]) then
						ICONS[#ICONS+1] = icon; icons[icon] = true
					end
				end
			end
		end
	end


	---This code collects the data for the Hunter's "Call Pet" Flyout. It is a mystery why it works, but it does

	if(NEURON.class == 'HUNTER') then
		local _, _, numSlots, isKnown = GetFlyoutInfo(9)

		for i=1, numSlots do
			local spellID, isKnown = GetFlyoutSlotInfo(9, i)
			local petIndex, petName = GetCallPetSpellInfo(spellID)

			if (isKnown and petIndex and petName and #petName > 0) then
				local spellName = GetSpellInfo(spellID)

				local altName, subName, icon, castTime, minRange, maxRange = GetSpellInfo(spellName)

				for k,v in pairs(NEURON.sIndex) do

					if (v.spellName:find(petName.."$")) then
						local spellData = SetSpellInfo(v.index, v.booktype, v.spellName, nil, v.subName, spellID, v.spellID_Alt, v.spellType, v.spellLvl, v.isPassive, v.icon)

						NEURON.sIndex[(spellName):lower()] = spellData
						NEURON.sIndex[(spellName):lower().."()"] = spellData
						NEURON.sIndex[spellID] = spellData
					end
				end
			end
		end
	end


end


--- Adds pet spells & abilities to the spell list index
function NEURON:UpdatePetSpellIndex()

	if (HasPetSpells()) then
		for i=1,HasPetSpells() do
			local spellName, _ = GetSpellBookItemName(i, BOOKTYPE_PET)
			local spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_PET)
			local spellID_Alt = spellID
			local spellLvl = GetSpellAvailableLevel(i, BOOKTYPE_PET)
			local icon = GetSpellBookItemTexture(i, BOOKTYPE_PET)
			local isPassive = IsPassiveSpell(i, BOOKTYPE_PET)

			if (spellName and spellType ~= "FUTURESPELL") then
				local altName, subName, icon, castTime, minRange, maxRange = GetSpellInfo(spellName)
				local spellData = SetSpellInfo(i, BOOKTYPE_PET, spellName, altName, subName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)
				if (subName and #subName > 0) then
					NEURON.sIndex[(spellName.."("..subName..")"):lower()] = spellData
				else
					NEURON.sIndex[(spellName):lower()] = spellData
					NEURON.sIndex[(spellName):lower().."()"] = spellData
				end

				if (spellID) then
					NEURON.sIndex[spellID] = spellData
				end

				if (icon and not icons[icon]) then
					ICONS[#ICONS+1] = icon; icons[icon] = true
				end
			end
		end
	end
end


--- Creates a table containing provided companion & mount data
-- @param index, creatureType, index, creatureID, creatureName, spellID, icon
-- @return curComp:  Table containing provided data
local function SetCompanionData(creatureType, index, creatureID, creatureName, spellID, icon)
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
function NEURON:UpdateToyData()

	-- note filter settings
	local filterCollected = C_ToyBox.GetCollectedShown()
	local filterUncollected = C_ToyBox.GetUncollectedShown()
	local sources = {}
	for i=1,10 do
		sources[i] = C_ToyBox.IsSourceTypeFilterChecked(i)
	end
	-- set filters to all toys
	C_ToyBox.SetCollectedShown(true)
	C_ToyBox.SetUncollectedShown(true) -- we don't need to uncollected toys
	--C_ToyBox.ClearAllSourceTypesFiltered()
	C_ToyBox.SetAllSourceTypeFilters(true)
	C_ToyBox.SetFilterString("")

	-- fill cache with itemIDs = name
	for i=1,C_ToyBox.GetNumFilteredToys() do
		local itemID = C_ToyBox.GetToyFromIndex(i)
		local name = GetItemInfo(itemID) or "UNKNOWN"
		local known = PlayerHasToy(itemID)
		if known then
			NEURON.tIndex[name:lower()] = itemID
		end
	end

	-- restore filters
	C_ToyBox.SetCollectedShown(filterCollected)
	C_ToyBox.SetUncollectedShown(filterUncollected)
	for i=1,10 do
		C_ToyBox.SetSourceTypeFilter(i, not sources[i])
	end
end


--- Compiles a list of battle pets & mounts a player has.  This table is used to refrence macro spell info to generate tooltips and cooldowns.
---	If a companion is not displaying its tooltip or cooldown, then the item in the macro probably is not in the database
function NEURON:UpdateCompanionData()
	--.C_PetJournal.ClearAllPetSourcesFilter()
	--.C_PetJournal.ClearAllPetTypesFilter()

	C_PetJournal.ClearSearchFilter()

	--.C_PetJournal.AddAllPetSourcesFilter()
	--.C_PetJournal.AddAllPetTypesFilter()

	C_PetJournal.SetAllPetSourcesChecked(true)
	C_PetJournal.SetAllPetTypesChecked(true)
	local numpet = select(1, C_PetJournal.GetNumPets())

	for i=1,numpet do

		local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i)

		if (petID) then
			local spell = speciesName
			if (spell) then
				local companionData = SetCompanionData("CRITTER", i, speciesID, speciesName, petID, icon)
				NEURON.cIndex[spell:lower()] = companionData
				NEURON.cIndex[spell:lower().."()"] = companionData
				NEURON.cIndex[petID] = companionData

				if(type(icon) == "number") then
					if (icon and not icons[icon]) then
						ICONS[#ICONS+1] = icon; icons[icon] = true
					end
				end
			end
		end
	end

	local mountIDs = C_MountJournal.GetMountIDs()
	for i,id in pairs(mountIDs) do
		local creatureName , spellID = C_MountJournal.GetMountInfoByID(id) --, creatureID, _, active, summonable, source, isFavorite, isFactionSpecific, faction, unknown, owned = C_MountJournal.GetMountInfoByID(i)
		local link = GetSpellLink(creatureName)

		if (spellID) then
			local spell, _, icon = GetSpellInfo(spellID)
			if (spell) then
				local companionData = SetCompanionData("MOUNT", i, spellID, creatureName, spellID, icon)
				NEURON.cIndex[spell:lower()] = companionData
				NEURON.cIndex[spell:lower().."()"] = companionData
				NEURON.cIndex[spellID] = companionData

				if (icon and not icons[icon]) then
					ICONS[#ICONS+1] = icon; icons[icon] = true
				end
			end
		end
	end
end




--- Creates a table of the available spell icon filenames for use in macros
function NEURON:UpdateIconIndex()
	local icon
	local temp = {}

	GetMacroIcons(temp)

	for k,icon in ipairs(temp) do
		if (not icons[icon]) then
			ICONS[#ICONS+1] = icon; icons[icon] = true
		end

	end

end

function NEURON:UpdateStanceStrings()
	if (NEURON.class == "DRUID" or
			NEURON.class == "ROGUE") then

		wipe(NEURON.StanceIndex)

		local icon, name, active, castable, spellID, UJU
		local states = "[stance:0] stance0; "

		for i=1,8 do
			NEURON.STATES["stance"..i] = nil
		end

		for i=1,GetNumShapeshiftForms() do
			icon, name, active, castable, spellID = GetShapeshiftFormInfo(i)

			if (name) then
				if (spellID) then
					NEURON.StanceIndex[i] = spellID
				end

				NEURON.STATES["stance"..i] = name
				states = states.."[stance:"..i.."] stance"..i.."; "
			end
		end

		--Adds Shadow Dance State for Subelty Rogues
		if (NEURON.class == "ROGUE" and GetSpecialization() == 3 ) then
			NEURON.STATES["stance2"] = L["Shadow Dance"]
			NEURON.StanceIndex[2] = 185313
			states = states.."[stance:2] stance2; "
		end

		states = states:gsub("; $", "")

		if (not stanceStringsUpdated) then
			if (NEURON.class == "DRUID") then
				NEURON.STATES.stance0 = L["Caster Form"]
			end

			if (NEURON.class == "ROGUE") then
				NEURON.STATES.stance0 = L["Melee"]
			end

			stanceStringsUpdated = true
		end

		NEURON.MAS.stance.states = states
	end
end




function NEURON.EditBox_PopUpInitialize(popupFrame, data)
	popupFrame.func = NEURON.PopUp_Update
	popupFrame.data = data

	NEURON.PopUp_Update(popupFrame)
end

function NEURON.PopUp_Update(popupFrame)
	local data, count, height, width = popupFrame.data, 1, 0, 0
	local option, anchor, last, text

	if (popupFrame.options) then
		for k,v in pairs(popupFrame.options) do
			v.text:SetText(""); v:Hide()
		end
	end

	if (not popupFrame.array) then
		popupFrame.array = {}
	else
		wipe(popupFrame.array)
	end

	if (not data) then
		return
	end

	for k,v in pairs(data) do
		if (type(v) == "string") then
			popupFrame.array[count] = k..","..v
		else
			popupFrame.array[count] = k
		end
		count = count + 1
	end

	table.sort(popupFrame.array)

	for i=1,#popupFrame.array do
		popupFrame.array[i] = gsub(popupFrame.array[i], "%s+", " ")
		popupFrame.array[i] = gsub(popupFrame.array[i], "^%s+", "")

		if (not popupFrame.options[i]) then
			option = CreateFrame("Button", popupFrame:GetName().."Option"..i, popupFrame, "NeuronPopupButtonTemplate")
			option:SetHeight(20)

			popupFrame.options[i] = option
		else
			option = _G[popupFrame:GetName().."Option"..i]
			popupFrame.options[i] = option
		end

		text = popupFrame.array[i]:match("^[^,]+") or ""
		option:SetText(text:gsub("^%d+_", ""))
		option.value = popupFrame.array[i]:match("[^,]+$")

		if (option:GetTextWidth() > width) then
			width = option:GetTextWidth()
		end

		option:ClearAllPoints()

		if (not anchor) then
			option:SetPoint("TOP", popupFrame, "TOP", 0, -5); anchor = option
		else
			option:SetPoint("TOP", last, "BOTTOM", 0, -1)
		end

		last = option
		height = height + 21
		option:Show()
	end

	if (popupFrame.options) then
		for k,v in pairs(popupFrame.options) do
			v:SetWidth(width+40)
		end
	end

	popupFrame:SetWidth(width+40)

	if (height < popupFrame:GetParent():GetHeight()) then
		popupFrame:SetHeight(popupFrame:GetParent():GetHeight())
	else
		popupFrame:SetHeight(height + 10)
	end
end




function NEURON.SubFramePlainBackdrop_OnLoad(self)
	self:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\AddOns\\Neuron\\Images\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 22,
		insets = {left = 5, right = 5, top = 5, bottom = 5},})
	self:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
	self:SetBackdropColor(0,0,0,0)
	self:GetParent().backdrop = self

	self.bg = self:CreateTexture(nil, "BACKGROUND")
	self.bg:SetTexture("Interface\\FriendsFrame\\UI-Toast-Background", true)
	self.bg:SetVertexColor(0.65,0.65,0.65,0.85)
	self.bg:SetPoint("TOPLEFT", 3, -3)
	self.bg:SetPoint("BOTTOMRIGHT", -3, 3)
	self.bg:SetHorizTile(true)
	self.bg:SetVertTile(true)
end


function NEURON.SubFrameBlackBackdrop_OnLoad(self)
	self:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\AddOns\\Neuron\\Images\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 18,
		insets = {left = 5, right = 5, top = 5, bottom = 5},})
	self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
	self:SetBackdropColor(0,0,0,0)
	self:GetParent().backdrop = self

	self.bg = self:CreateTexture(nil, "BACKGROUND")
	self.bg:SetTexture("Interface\\FriendsFrame\\UI-Toast-Background", true)
	self.bg:SetVertexColor(0.65,0.65,0.65,1)
	self.bg:SetPoint("TOPLEFT", 3, -3)
	self.bg:SetPoint("BOTTOMRIGHT", -3, 3)
	self.bg:SetHorizTile(true)
	self.bg:SetVertTile(true)
end


function NEURON.SubFrameBlankBackdrop_OnLoad(self)
	self:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\AddOns\\Neuron\\Images\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 12,
		insets = {left = 5, right = 5, top = 5, bottom = 5},})
	self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
	self:SetBackdropColor(0,0,0,0)
	self:GetParent().backdrop = self
end


function NEURON.SubFrameHoneycombBackdrop_OnLoad(self)
	self:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\AddOns\\Neuron\\Images\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 18,
		insets = {left = 5, right = 5, top = 5, bottom = 5},})
	self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
	self:SetBackdropColor(0,0,0,0)
	self:GetParent().backdrop = self

	self.bg = self:CreateTexture(nil, "BACKGROUND")
	self.bg:SetTexture("Interface\\AddOns\\Neuron\\Images\\honeycomb_small", true)
	self.bg:SetVertexColor(0.65,0.65,0.65,1)
	self.bg:SetPoint("TOPLEFT", 3, -3)
	self.bg:SetPoint("BOTTOMRIGHT", -3, 3)
	self.bg:SetHorizTile(true)
	self.bg:SetVertTile(true)
end


function NEURON.NeuronAdjustOption_AddOnClick(frame, button, down)
	frame.elapsed = 0
	frame.pushed = frame:GetButtonState()

	if (not down) then
		if (frame:GetParent():GetParent().addfunc) then
			frame:GetParent():GetParent().addfunc(frame:GetParent():GetParent())
		end
	end
end


function NEURON.NeuronAdjustOption_AddOnUpdate(frame, elapsed)
	frame.elapsed = frame.elapsed + elapsed

	if (frame.pushed == "NORMAL") then

		if (frame.elapsed > 1 and frame:GetParent():GetParent().addfunc) then
			frame:GetParent():GetParent().addfunc(frame:GetParent():GetParent(), true)
		end
	end
end


function NEURON.NeuronAdjustOption_SubOnClick(frame, button, down)
	frame.elapsed = 0
	frame.pushed = frame:GetButtonState()

	if (not down) then
		if (frame:GetParent():GetParent().subfunc) then
			frame:GetParent():GetParent().subfunc(frame:GetParent():GetParent())
		end
	end
end


function NEURON.NeuronAdjustOption_SubOnUpdate(frame, elapsed)
	frame.elapsed = frame.elapsed + elapsed

	if (frame.pushed == "NORMAL") then

		if (frame.elapsed > 1 and frame:GetParent():GetParent().subfunc) then
			frame:GetParent():GetParent().subfunc(frame:GetParent():GetParent(), true)
		end
	end
end


function NEURON:UpdateData(data, defaults)
	-- Add new vars
	for key,value in pairs(defaults) do

		if (data[key] == nil) then

			if (data[key:lower()] ~= nil) then

				data[key] = data[key:lower()]
				data[key:lower()] = nil
			else
				data[key] = value
			end
		end
	end
	-- Add new vars

	-- Var fixes

	---none

	-- Var fixes

	-- Kill old vars
	for key,value in pairs(data) do

		if (defaults[key] == nil) then
			data[key] = nil
		end

	end
	-- Kill old vars
end


function NEURON:ToggleBlizzBar(on)
	if (InCombatLockdown()) then
		return
	end
	if (on) then
		local button

		for i=1, NUM_OVERRIDE_BUTTONS do
			button = _G["OverrideActionBarButton"..i]
			handler:WrapScript(button, "OnShow", [[
				local key = GetBindingKey("ACTIONBUTTON"..self:GetID())
				if (key) then
					self:SetBindingClick(true, key, self:GetName())
				end
			]])
			handler:WrapScript(button, "OnHide", [[
				local key = GetBindingKey("ACTIONBUTTON"..self:GetID())
				if (key) then
					self:ClearBinding(key)
				end
			]])
		end

		TextStatusBar_Initialize(MainMenuExpBar)
		MainMenuExpBar:RegisterEvent("PLAYER_ENTERING_WORLD")
		MainMenuExpBar:RegisterEvent("PLAYER_XP_UPDATE")
		MainMenuExpBar.textLockable = 1
		MainMenuExpBar.cvar = "xpBarText"
		MainMenuExpBar.cvarLabel = "XP_BAR_TEXT"
		MainMenuExpBar.alwaysPrefix = true
		MainMenuExpBar_SetWidth(1024)

		MainMenuBar_OnLoad(MainMenuBarArtFrame)
		MainMenuBarVehicleLeaveButton_OnLoad(MainMenuBarVehicleLeaveButton)

		MainMenuBar:SetPoint("BOTTOM", 0, 0)
		MainMenuBar:Show()

		OverrideActionBar_OnLoad(OverrideActionBar)
		OverrideActionBar:SetPoint("BOTTOM", 0, 0)

		ExtraActionBarFrame:SetPoint("BOTTOM", 0, 160)

		ActionBarController_OnLoad(ActionBarController)

	else
		local button

		for i=1, NUM_OVERRIDE_BUTTONS do
			button = _G["OverrideActionBarButton"..i]
			handler:UnwrapScript(button, "OnShow")
			handler:UnwrapScript(button, "OnHide")
		end

		MainMenuExpBar:UnregisterAllEvents()
		MainMenuBarArtFrame:UnregisterAllEvents()
		MainMenuBarArtFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
		MainMenuBarArtFrame:RegisterEvent("UNIT_LEVEL")
		MainMenuBarVehicleLeaveButton:UnregisterAllEvents()

		MainMenuBar:SetPoint("BOTTOM", 0, -200)
		MainMenuBar:Hide()

		OverrideActionBar:UnregisterAllEvents()
		OverrideActionBar:SetPoint("BOTTOM", 0, -200)
		OverrideActionBar:Hide()

		ExtraActionBarFrame:SetPoint("BOTTOM", 0, -200)
		ExtraActionBarFrame:Hide()

		ActionBarController:UnregisterAllEvents()
	end
end


function NEURON:BlizzBar()
	if (GDB.mainbar) then
		GDB.mainbar = false
	else
		GDB.mainbar = true
	end
	NEURON:ToggleBlizzBar(GDB.mainbar)

end


local function is_valid_spec_id(id, num_specs)
	return id and id > 0 and id <= num_specs
end


local function get_profile()
	local char_name = UnitName("player")
	local realm_name = GetRealmName()
	local char_and_realm_name = string.format("%s - %s", char_name, realm_name)

	local profile_key = NeuronProfilesDB.profileKeys[char_and_realm_name]
	local profile = NeuronProfilesDB.profiles[profile_key]

	return profile
end


function NEURON:CreateBar(index, class, id)
	local data = NEURON.RegisteredBarData[class]
	local newBar

	if (data) then
		if (not id) then
			id = 1

			for _ in ipairs(data.GDB) do
				id = id + 1
			end

			newBar = true
		end

		local bar

		if (_G["Neuron"..data.barType..id]) then
			bar = _G["Neuron"..data.barType..id]
		else
			bar = CreateFrame("CheckButton", "Neuron"..data.barType..id, UIParent, "NeuronBarTemplate")
		end

		for key,value in pairs(data) do
			bar[key] = value
		end

		setmetatable(bar, {__index = BAR})

		bar.index = index
		bar.class = class
		bar.stateschanged = true
		bar.vischanged =true
		bar.elapsed = 0
		bar.click = nil
		bar.dragged = false
		bar.selected = false
		bar.toggleframe = bar
		bar.microAdjust = false
		bar.vis = {}
		bar.text:Hide()
		bar.message:Hide()
		bar.messagebg:Hide()

		bar:SetID(id)
		bar:SetWidth(375)
		bar:SetHeight(40)
		bar:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true, tileSize = 16, edgeSize = 12,
			insets = {left = 4, right = 4, top = 4, bottom = 4}})
		bar:SetBackdropColor(0,0,0,0.4)
		bar:SetBackdropBorderColor(0,0,0,0)
		bar:SetFrameLevel(2)
		bar:RegisterForClicks("AnyDown", "AnyUp")
		bar:RegisterForDrag("LeftButton")
		bar:SetMovable(true)
		bar:EnableKeyboard(false)
		bar:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

		bar:SetScript("OnClick", BAR.OnClick)
		bar:SetScript("OnDragStart", BAR.OnDragStart)
		bar:SetScript("OnDragStop", BAR.OnDragStop)
		bar:SetScript("OnEnter", BAR.OnEnter)
		bar:SetScript("OnLeave", BAR.OnLeave)
		bar:SetScript("OnEvent", BAR.OnEvent)
		bar:SetScript("OnKeyDown", BAR.OnKeyDown)
		bar:SetScript("OnKeyUp", BAR.OnKeyUp)
		bar:SetScript("OnMouseWheel", BAR.OnMouseWheel)
		bar:SetScript("OnShow", BAR.OnShow)
		bar:SetScript("OnHide", BAR.OnHide)
		bar:SetScript("OnUpdate", BAR.OnUpdate)

		bar:RegisterEvent("ACTIONBAR_SHOWGRID")
		bar:RegisterEvent("ACTIONBAR_HIDEGRID")
		bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

		bar:CreateDriver()
		bar:CreateHandler()
		bar:CreateWatcher()

		bar:LoadData()

		if (not newBar) then
			bar:Hide()
		end

		BARIndex[index] = bar

		BARNameIndex[bar:GetName()] = bar

		return bar, newBar
	end
end


function NEURON:CreateNewBar(class, id, firstRun)
	if (class and NEURON.RegisteredBarData[class]) then
		local index = 1

		for _ in ipairs(BARIndex) do
			index = index + 1
		end

		local bar, newBar = NEURON:CreateBar(index, class, id)

		if (firstRun) then
			bar:SetDefaults(bar.gDef, bar.cDef)
		end

		if (newBar) then
			bar:Load(); NEURON:ChangeBar(bar)

			---------------------------------
			if (class == "extrabar") then --this is a hack to get around an issue where the extrabar wasn't autohiding due to bar visibility states. There most likely a way better way to do this in the future. FIX THIS!
				bar.gdata.hidestates = ":extrabar0:"
				bar.vischanged = true
				bar:Update()
			end
			if (class == "pet") then --this is a hack to get around an issue where the extrabar wasn't autohiding due to bar visibility states. There most likely a way better way to do this in the future. FIX THIS!
				bar.gdata.hidestates = ":pet0:"
				bar.vischanged = true
				bar:Update()
			end
			-----------------------------------
		end

		return bar
	else
		NEURON.PrintBarTypes()
	end
end

function NEURON:CreateNewObject(class, id, firstRun)
	local data = NEURON.RegisteredBarData[class]

	if (data) then
		local index = 1

		for _ in ipairs(data.objTable) do
			index = index + 1
		end

		local object = CreateFrame(data.objFrameT, data.objPrefix..id, UIParent, data.objTemplate)

		setmetatable(object, data.objMetaT)

		object.elapsed = 0

		local objects = NEURON:GetParentKeys(object)

		for k,v in pairs(objects) do
			local name = (v):gsub(object:GetName(), "")
			object[name:lower()] = _G[v]
		end

		object.class = class
		object.id = id
		object:SetID(0)
		object.objTIndex = index
		object.objType = data.objType:gsub("%s", ""):upper()
		--object:LoadData(GetSpecialization(), "homestate")
		object:LoadData(GetActiveSpecGroup(), "homestate")

		if (firstRun) then
			object:SetDefaults(object:GetDefaults())
		end

		object:LoadAux()

		data.objTable[index] = {object, 1}

		return object
	end
end


function NEURON:ChangeBar(bar)
	local newBar = false

	if (NEURON.PEW) then

		if (bar and NEURON.CurrentBar ~= bar) then
			NEURON.CurrentBar = bar

			bar.selected = true
			bar.action = nil

			bar:SetFrameLevel(3)

			if (bar.gdata.hidden) then
				bar:SetBackdropColor(1,0,0,0.6)
			else
				bar:SetBackdropColor(0,0,1,0.5)
			end

			newBar = true
		end

		if (not bar) then
			NEURON.CurrentBar = nil
		elseif (bar.text) then
			bar.text:Show()
		end

		for k,v in pairs(BARIndex) do
			if (v ~= bar) then

				if (v.cdata.conceal) then
					v:SetBackdropColor(1,0,0,0.4)
				else
					v:SetBackdropColor(0,0,0,0.4)
				end

				v:SetFrameLevel(2)
				v.selected = false
				v.microAdjust = false
				v:EnableKeyboard(false)
				v.text:Hide()
				v.message:Hide()
				v.messagebg:Hide()
				v.mousewheelfunc = nil
				v.action = nil
			end
		end

		if (NEURON.CurrentBar) then
			NEURON.CurrentBar:OnEnter()
		end
	end

	return newBar
end


function NEURON:ToggleBars(show, hide)
	if (NEURON.PEW) then
		if ((NEURON.BarsShown or hide) and not show) then

			NEURON.BarsShown = nil

			for index, bar in pairs(BARIndex) do
				bar:Hide(); bar:Update(nil, true)
			end

			NEURON:ChangeBar(nil)

			if (NeuronBarEditor)then
				NeuronBarEditor:Hide()
			end

		else

			--NEURON:ToggleMainMenu(nil, true)
			NEURON:ToggleEditFrames(nil, true)

			NEURON.BarsShown = true

			for index, bar in pairs(BARIndex) do
				bar:Show(); bar:Update(true)
			end
		end
	end

end


function NEURON:ToggleButtonGrid(show, hide)
	for id,btn in pairs(BTNIndex) do
		btn[1]:SetGrid(show, hide)
	end
end




function NEURON:ToggleMainMenu(show, hide)
	---need to run the command twice for some reason. The first one only seems to open the Interface panel
	InterfaceOptionsFrame_OpenToCategory("Neuron");
	InterfaceOptionsFrame_OpenToCategory("Neuron");
end


function NEURON:PrintStateList()
	local data = {}
	local list

	for k,v in pairs(NEURON.MANAGED_ACTION_STATES) do
		if (NEURON.STATEINDEX[k]) then
			data[v.order] = NEURON.STATEINDEX[k]
		end
	end

	for k,v in ipairs(data) do

		if (not list) then
			list = L["Valid States"]..":"..v
		else
			list = list..", "..v
		end
	end

	Neuron:Print(list..L["Custom_Option"])
end


function NEURON:PrintBarTypes()
	local data, index, high = {}, 1, 0

	for k,v in pairs(NEURON.RegisteredBarData) do
		if (v.barCreateMore) then

			local barType;
			index = tonumber(v.createMsg:match("%d+"))
			barType = v.createMsg:gsub("%d+","")

			if (index and barType) then
				data[index] = {k, barType}
				if (index > high) then high = index end
			end
		end
	end

	for i=1,high do if (not data[i]) then data[i] = 0 end end


	Neuron:Print("---------------------------------------------------")
	Neuron:Print("     "..L["How to use"]..":   ".."/"..addonName:lower().." "..L["Create"]:lower().." <"..L["Option"]:lower()..">")
	Neuron:Print("---------------------------------------------------")

	for k,v in ipairs(data) do
		if (type(v) == "table") then
			Neuron:Print("    |cff00ff00"..v[1]..":|r "..v[2])
		end
	end

end

---This function is called each and every time a Bar-Module loads. It adds the module to the list of currently avaible bars. If we add new bars in the future, this is the place to start
function NEURON:RegisterBarClass(class, barType, barLabel, objType, barGDB, barCDB, objTable, objGDB, objFrameType, objTemplate, objMetaTable, objMax, barReverse, objStorage, gDef, cDef, barCreateMore)

	NEURON.ModuleIndex = NEURON.ModuleIndex + 1

	NEURON.RegisteredBarData[class] = {
		barType = barType,
		barLabel = barLabel,
		barReverse = barReverse,
		barCreateMore = barCreateMore,
		GDB = barGDB,
		CDB = barCDB,
		gDef = gDef,
		cDef = cDef,
		objTable = objTable,
		objGDB = objGDB,
		objPrefix = "Neuron"..objType:gsub("%s+", ""),
		objFrameT = objFrameType,
		objTemplate = objTemplate,
		objMetaT = objMetaTable,
		objType = objType,
		objMax = objMax,
		objStorage = objStorage,
		createMsg = NEURON.ModuleIndex..objType,
	}
end


function NEURON:RegisterGUIOptions(class, chkOpt, stateOpt, adjOpt)
	NEURON.RegisteredGUIData[class] = {
		chkOpt = chkOpt,
		stateOpt = stateOpt,
		adjOpt = adjOpt,
	}
end


function NEURON:SetTimerLimit(msg)
	local limit = tonumber(msg:match("%d+"))

	if (limit and limit > 0) then
		GDB.timerLimit = limit
		Neuron:Print(format(L["Timer_Limit_Set_Message"], GDB.timerLimit))
	else
		Neuron:Print(L["Timer_Limit_Invalid_Message"])
	end
end




function Neuron:SetupInterfaceOptions()

	---TODO: Move this to a GUI specific element with the GUI rewrite
	--ACE GUI OPTION TABLE
	interfaceOptions = {
		name = "Neuron",
		type = 'group',
		args = {
			moreoptions={
				name = L["Options"],
				type = "group",
				order = 0,
				args={
					BlizzardBar = {
						order = 1,
						name = L["Display the Blizzard Bar"],
						desc = L["Shows / Hides the Default Blizzard Bar"],
						type = "toggle",
						set = function() NEURON:BlizzBar() end,
						get = function() return NeuronGDB.mainbar end,
						width = "full",
					},
					NeuronMinimapButton = {
						order = 2,
						name = L["Display Minimap Button"],
						desc = L["Toggles the minimap button."],
						type = "toggle",
						set =  function() NEURON.NeuronMinimapIcon:ToggleIcon() end,
						get = function() return not NeuronGDB.NeuronIcon.hide end,
						width = "full"
					},
				},
			},

			changelog = {
				name = L["Changelog"],
				type = "group",
				order = 1000,
				args = {
					line1 = {
						type = "description",
						name = L["Changelog_Latest_Version"],
					},
				},
			},

			faq = {
				name = L["F.A.Q."],
				desc = L["Frequently Asked Questions"],
				type = "group",
				order = 1001,
				args = {

					line1 = {
						type = "description",
						name = L["FAQ_Intro"],
					},

					g1 = {
						type = "group",
						name = L["Bar Configuration"],
						order = 1,
						args = {

							line1 = {
								type = "description",
								name = L["Bar_Configuration_FAQ"],
								order = 1,
							},

							g1 = {
								type = "group",
								name = L["General Options"],
								order = 1,
								args = {
									line1 = {
										type = "description",
										name = L["General_Bar_Configuration_Option_FAQ"] ,
										order = 1,
									},
								},
							},

							g2 = {
								type = "group",
								name = L["Bar States"],
								order = 2,
								args = {
									line1 = {
										type = "description",
										name = L["Bar_State_Configuration_FAQ"],
										order = 1,
									},
								},
							},

							g3 = {
								type = "group",
								name = L["Spell Target Options"],
								order = 3,
								args = {
									line1 = {
										type = "description",
										name = L["Spell_Target_Options_FAQ"],
										order = 1,
									},
								},
							},
						},
					},

					g2 = {
						type = "group",
						name = L["Flyout"],
						order = 3,
						args = {
							line1a = {
								type = "description",
								name = L["Flyout_FAQ"],
								order = 1,
							},
						},
					},

				},
			},
		},
	}

end