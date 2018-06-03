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

local icons = {}

NEURON.PEW = false --flag that gets set when the player enters the world. It's used primarily for throttling events so that the player doesn't crash on loging with too many processes

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------

local latestVersionNum = "0.9.25" --this variable is set to popup a welcome message upon updating/installing. Only change it if you want to pop up a message after the users next update

--I don't think it's worth localizing these two strings. It's too much effort for messages that are going to change often. Sorry to everyone who doesn't speak English
local Install_Message = [[Thanks for installing Neuron.

Neuron is currently in a "|cffffff00release|r" state.

If you have any questions or concerns please direct all inquirires our Github page or through Curseforge, which are listed in the F.A.Q.

Cheers,

-Soyier]]

local Update_Message = [[Thanks for updating Neuron!

A ton of work went into this release, and Neuron is now full steam ahead to Battle for Azeroth. There are a couple notes with this version:

1)The bag and menu bars have been completely rewritten, so expect a tiny bit of quirkiness (they're fixed in BfA).

2)Neuron is fully updated for BfA, and you can get a working version from the bfa_beta branch on GitHub.

3)The GUI re-write is well underway, and expect that to also land with the 8.0 update (baring any unforseen events).

Lastly, if you are enjoying Neuron, please consider a small donation to help with development costs.

-Soyier]]


--prepare the NEURON table with some subtables that will be used down the road
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


--working variable pointers
local BARIndex = NEURON.BARIndex
local BARNameIndex = NEURON.BARNameIndex --I'm not sure if we need both BarIndex and BARNameIndex. They're pretty much the same
local BTNIndex = NEURON.BTNIndex
local ICONS = NEURON.iIndex

---these are the database tables that are going to hold our data. They are global because every .lua file needs access to them
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

NeuronItemCache = {} --Not sure the practical benefit of this, it's used a bunch in Neuron-Button and Neuron-FLyout though


---this is the Default profile when you "load defaults" in the ace profile window
NeuronDefaults = {}
NeuronDefaults['profile'] = {} --populate the Default profile with globals
NeuronDefaults.profile['NeuronCDB'] = NeuronCDB
NeuronDefaults.profile['NeuronGDB'] = NeuronGDB
NeuronDefaults.profile['NeuronItemCache'] = NeuronItemCache


--I think this is only used in Neuron-Flyouts
NEURON.Points = {
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

local handler

local level, stanceStringsUpdated

-------------------------------------------------------------------------
--------------------Start of Functions-----------------------------------
-------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NEURON:OnInitialize()

	NEURON.db = LibStub("AceDB-3.0"):New("NeuronProfilesDB", NeuronDefaults)

	NEURON.db.RegisterCallback(NEURON, "OnProfileChanged", "RefreshConfig")
	NEURON.db.RegisterCallback(NEURON, "OnProfileCopied", "RefreshConfig")
	NEURON.db.RegisterCallback(NEURON, "OnProfileReset", "RefreshConfig")
	NEURON.db.RegisterCallback(NEURON, "OnDatabaseReset", "RefreshConfig")


	---These set the profile to be the defaults if there isn't already these values set in the profile
	if (not Neuron.db.profile["NeuronCDB"]) then
		NEURON.db.profile["NeuronCDB"] = NeuronCDB
	end
	if (not Neuron.db.profile["NeuronGDB"]) then
		NEURON.db.profile["NeuronGDB"] = NeuronGDB
	end
	if (not Neuron.db.profile["NeuronItemCache"]) then
		NEURON.db.profile["NeuronItemCache"] = NeuronItemCache
	end
	--------------------------------------------------------------------

	NEURON:fixObjectTable(NEURON.db.profile)

	---load saved variables into working variable containers
	NeuronCDB = NEURON.db.profile["NeuronCDB"]
	NeuronGDB = NEURON.db.profile["NeuronGDB"]
	NeuronItemCache = NEURON.db.profile["NeuronItemCache"]

	---these are the working pointers to our global database tables. Each class has a local GDB and CDB table that is a pointer to the root of their associated database
	GDB = NeuronGDB
	CDB = NeuronCDB

	NEURON.MAS = Neuron.MANAGED_ACTION_STATES
	NEURON.MBS = Neuron.MANAGED_BAR_STATES

	NEURON.player = UnitName("player")
	NEURON.class = select(2, UnitClass("player"))
	NEURON.level = UnitLevel("player")
	NEURON.realm = GetRealmName()


	NEURON:RegisterChatCommand("neuron", "slashHandler")


	---TODO:figure out what to do with this
	local frame = CreateFrame("GameTooltip", "NeuronTooltipScan", UIParent, "GameTooltipTemplate")
	frame:SetOwner(UIParent, "ANCHOR_NONE")
	frame:SetFrameStrata("TOOLTIP")
	frame:Hide()



end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NEURON:OnEnable()

	NEURON:RegisterEvent("PLAYER_REGEN_DISABLED")
	NEURON:RegisterEvent("PLAYER_ENTERING_WORLD")
	NEURON:RegisterEvent("SPELLS_CHANGED")
	NEURON:RegisterEvent("CHARACTER_POINTS_CHANGED")
	NEURON:RegisterEvent("LEARNED_SPELL_IN_TAB")
	NEURON:RegisterEvent("PET_UI_CLOSE")
	NEURON:RegisterEvent("COMPANION_LEARNED")
	NEURON:RegisterEvent("COMPANION_UPDATE")
	NEURON:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
	NEURON:RegisterEvent("UNIT_LEVEL")
	NEURON:RegisterEvent("UNIT_PET")
	NEURON:RegisterEvent("TOYS_UPDATED")

	NEURON:HookScript(NEURON, "OnUpdate", "controlOnUpdate")


	-- --I have no idea what this does
	--[[if (CompanionsMicroButtonAlert) then
		CompanionsMicroButtonAlert:HookScript("OnShow", function(frame)

			if (not GDB.mainbar) then
				frame:Hide()
			end
		end)
	end]]

	NEURON:UpdateStanceStrings()

	GameMenuFrame:HookScript("OnShow", function(self)

		if (NEURON.BarsShown) then
			HideUIPanel(self)
			NEURON.NeuronBar:ToggleBars(nil, true)
		end

		if (NEURON.EditFrameShown) then
			HideUIPanel(self)
			NEURON:ToggleEditFrames(nil, true)
		end

		if (NEURON.BindingMode) then
			HideUIPanel(self)
			NEURON:ToggleBindings(nil, true)
		end

	end)

	NEURON:LoginMessage()


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
		NEURON.NeuronBar:ToggleBars(nil, true)
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





-------------------------------------------------------------------------
--------------------Profiles---------------------------------------------
-------------------------------------------------------------------------

function NEURON:RefreshConfig()
	NeuronCDB = NEURON.db.profile["NeuronCDB"]
	NeuronGDB = NEURON.db.profile["NeuronGDB"]

	GDB, CDB =  NeuronGDB, NeuronCDB
	NEURON.NeuronButton.ButtonProfileUpdate()


	StaticPopupDialogs["ReloadUI"] = {
		text = "ReloadUI",
		button1 = "Yes",
		OnAccept = function()
			ReloadUI()
		end,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}

	StaticPopup_Show("ReloadUI")
end

--------------------------------------------
--------------Slash Functions --------------
--------------------------------------------

--large table that contains the localized name, localized description, and internal setting name for each slash function
local slashFunctions = {
	{L["Menu"], L["Menu_Description"], "ToggleMainMenu"},
	{L["Create"], L["Create_Description"], "CreateNewBar"},
	{L["Delete"], L["Delete_Description"], "DeleteBar"},
	{L["Config"], L["Config_Description"], "ToggleBars"},
	{L["Add"], L["Add_Description"], "AddObjectsToBar"},
	{L["Remove"], L["Remove_Description"], "RemoveObjectsFromBar"},
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


---New Slash functionality
function NEURON:slashHandler(input)

	if (strlen(input)==0 or input:lower() == "help") then
		NEURON:printSlashHelp()
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
			elseif (bar and NEURON.NeuronBar[func]) then
				---because we're calling a variable func name, we can't use the ":" notation, so we have to explicitely state the parent object as the first param
				NEURON.NeuronBar[func](NEURON.NeuronBar, bar, args[1]) --not sure what to do for more than 1 arg input
			else
				NEURON:Print(L["No bar selected or command invalid"])
			end
			return
		end
	end



end

function NEURON:printSlashHelp()

	NEURON:Print("---------------------------------------------------")
	NEURON:Print(L["How to use"]..":   ".."/"..addonName:lower().." <"..L["Command"]:lower().."> <"..L["Option"]:lower()..">")
	NEURON:Print(L["Command List"]..":")
	NEURON:Print("---------------------------------------------------")

	for i = 1,#slashFunctions do
		--formats the output to be the command name and then the description
		NEURON:Print(slashFunctions[i][1].." - " .."("..slashFunctions[i][2]..")")
	end

end


------------------------------------------------------------
--------------------Intermediate Functions------------------
------------------------------------------------------------

---TODO: we need to fix the throttling so that we don't bombard a single frame with ALL the processing, but instead spread out the processing on multiple frames

---this is the new controlOnUpdate function that will control all the other onUpdate functions.
function NEURON:controlOnUpdate(frame, elapsed)
	if not NEURON.elapsed then
		NEURON.elapsed = 0
	end

	NEURON.elapsed = NEURON.elapsed + elapsed

	---Throttled OnUpdate calls
	if (NEURON.elapsed > GDB.throttle and NEURON.PEW) then

		NEURON.NeuronBar:controlOnUpdate(frame, elapsed)
		NEURON.NeuronButton:cooldownsOnUpdate(frame, elapsed)
		NEURON.NeuronZoneAbilityBar:controlOnUpdate(frame, elapsed)
		NEURON.NeuronPetBar:controlOnUpdate(frame, elapsed)
		NEURON.NeuronStatusBar:controlOnUpdate(frame, elapsed)

		NEURON.elapsed = 0;
	end

	---UnThrottled OnUpdate calls
	if(NEURON.PEW) then
		NEURON.NeuronButton:controlOnUpdate(frame, elapsed) --this one needs to not be throttled otherwise spell button glows won't operate at 60fps
	end

end

-----------------------------------------------------------------


function NEURON:LoginMessage()

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

	---displays a info window on login for either fresh installs or updates
	if (GDB.updateWarning ~= latestVersionNum and GDB.updateWarning~=nil) then
		StaticPopup_Show("NEURON_UPDATE_WARNING")
	elseif(GDB.updateWarning==nil) then
		StaticPopup_Show("NEURON_INSTALL_MESSAGE")
	end

end


--I'm not sure what this function does, but it returns a table of all the names of children of a given frame
function NEURON:GetParentKeys(frame)
	if (frame == nil) then
		return
	end

	local data, childData = {}, {}
	local children = {frame:GetChildren()}
	local regions = {frame:GetRegions()}

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
function NEURON:SetSpellInfo(index, bookType, spellName, altName, subName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)
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
		--local icon = GetSpellBookItemTexture(i, BOOKTYPE_SPELL)
		--local isPassive = IsPassiveSpell(i, BOOKTYPE_SPELL)

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

			local spellData = NEURON:SetSpellInfo(i, BOOKTYPE_SPELL, spellName, altName, subName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)

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
				--local icon = GetSpellBookItemTexture(offsetIndex, BOOKTYPE_PROFESSION)
				local isPassive = IsPassiveSpell(offsetIndex, BOOKTYPE_PROFESSION)

				if (spellName and spellType ~= "FUTURESPELL") then
					local altName, subName, icon, castTime, minRange, maxRange = GetSpellInfo(spellID)
					local spellData = NEURON:SetSpellInfo(offsetIndex, BOOKTYPE_PROFESSION, spellName, altName, subName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)

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
		local _, _, numSlots, _ = GetFlyoutInfo(9)

		for i=1, numSlots do
			local spellID, isKnown = GetFlyoutSlotInfo(9, i)
			local petIndex, petName = GetCallPetSpellInfo(spellID)

			if (isKnown and petIndex and petName and #petName > 0) then
				local spellName = GetSpellInfo(spellID)

				local altName, subName, icon, castTime, minRange, maxRange = GetSpellInfo(spellName)

				for k,v in pairs(NEURON.sIndex) do

					if (v.spellName:find(petName.."$")) then
						local spellData = NEURON:SetSpellInfo(v.index, v.booktype, v.spellName, nil, v.subName, spellID, v.spellID_Alt, v.spellType, v.spellLvl, v.isPassive, v.icon)

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
			--local icon = GetSpellBookItemTexture(i, BOOKTYPE_PET)
			local isPassive = IsPassiveSpell(i, BOOKTYPE_PET)

			if (spellName and spellType ~= "FUTURESPELL") then
				local altName, subName, icon, castTime, minRange, maxRange = GetSpellInfo(spellName)
				local spellData = NEURON:SetSpellInfo(i, BOOKTYPE_PET, spellName, altName, subName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)
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
function NEURON:SetCompanionData(creatureType, index, creatureID, creatureName, spellID, icon)
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
				local companionData = NEURON:SetCompanionData("CRITTER", i, speciesID, speciesName, petID, icon)
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
		--local link = GetSpellLink(creatureName)

		if (spellID) then
			local spell, _, icon = GetSpellInfo(spellID)
			if (spell) then
				local companionData = NEURON:SetCompanionData("MOUNT", i, spellID, creatureName, spellID, icon)
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

	if not handler then
		handler = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
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



function NEURON:ToggleButtonGrid(show, hide)
	for id,btn in pairs(BTNIndex) do
		btn:SetGrid(btn, show, hide)
	end
end




function NEURON:ToggleMainMenu(show, hide)
	---need to run the command twice for some reason. The first one only seems to open the Interface panel
	InterfaceOptionsFrame_OpenToCategory("Neuron");
	InterfaceOptionsFrame_OpenToCategory("Neuron");
end


function NEURON:ToggleEditFrames(show, hide)

	if (NEURON.EditFrameShown or hide) then

		NEURON.EditFrameShown = false

		for index, editor in pairs(NEURON.EDITIndex) do
			editor:Hide()
			editor.object.editmode = NEURON.EditFrameShown
			editor:SetFrameStrata("LOW")
		end

		for _,bar in pairs(BARIndex) do
			NEURON.NeuronBar:UpdateObjectGrid(bar, NEURON.EditFrameShown)
			if (bar.handler:GetAttribute("assertstate")) then
				bar.handler:SetAttribute("state-"..bar.handler:GetAttribute("assertstate"), bar.handler:GetAttribute("activestate") or "homestate")
			end
		end

		NEURON.NeuronButton:ChangeObject()

	else

		--NEURON:ToggleMainMenu(nil, true)
		NEURON.NeuronBar:ToggleBars(nil, true)
		NEURON:ToggleBindings(nil, true)

		NEURON.EditFrameShown = true

		for index, editor in pairs(NEURON.EDITIndex) do
			editor:Show(); editor.object.editmode = NEURON.EditFrameShown

			if (editor.object.bar) then
				editor:SetFrameStrata(editor.object.bar:GetFrameStrata())
				editor:SetFrameLevel(editor.object.bar:GetFrameLevel()+4)
			end
		end

		for _,bar in pairs(BARIndex) do
			NEURON.NeuronBar:UpdateObjectGrid(bar, NEURON.EditFrameShown)
		end
	end
end


--- Toggles the displaying of key bindings
-- @param show: True if to be displayed
-- @param hide: True if to be hidden
function NEURON:ToggleBindings(show, hide)
	if (NEURON.BindingMode or hide) then
		NEURON.BindingMode = false

		for _, binder in pairs(NEURON.BINDIndex) do
			binder:Hide(); binder.button.editmode = NEURON.BindingMode
			binder:SetFrameStrata("LOW")
			if (not NEURON.BarsShown) then
				binder.button:SetGrid(binder.button)
			end
		end

	else
		NEURON:ToggleEditFrames(nil, true)

		NEURON.BindingMode = true

		for _, binder in pairs(NEURON.BINDIndex) do
			binder:Show()
			binder.button.editmode = NEURON.BindingMode

			if (binder.button.bar) then
				binder:SetFrameStrata(binder.button.bar:GetFrameStrata())
				binder:SetFrameLevel(binder.button.bar:GetFrameLevel()+4)
				binder.button:SetGrid(binder.button, true)
			end
		end

	end
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

	NEURON:Print(list..L["Custom_Option"])
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


	NEURON:Print("---------------------------------------------------")
	NEURON:Print("     "..L["How to use"]..":   ".."/"..addonName:lower().." "..L["Create"]:lower().." <"..L["Option"]:lower()..">")
	NEURON:Print("---------------------------------------------------")

	for k,v in ipairs(data) do
		if (type(v) == "table") then
			NEURON:Print("    |cff00ff00"..v[1]..":|r "..v[2])
		end
	end

end

---This function is called each and every time a Bar-Module loads. It adds the module to the list of currently avaible bars. If we add new bars in the future, this is the place to start
function NEURON:RegisterBarClass(class, barType, barLabel, objType, barGDB, barCDB, objTable, objGDB, objFrameType, objTemplate, objMetaTable, objMax, gDef, cDef, barCreateMore)

	NEURON.ModuleIndex = NEURON.ModuleIndex + 1

	NEURON.RegisteredBarData[class] = {
		barType = barType,
		barLabel = barLabel,
		barCreateMore = barCreateMore,
		GDB = barGDB,
		CDB = barCDB,
		gDef = gDef,
		cDef = cDef,
		objTable = objTable, --this is all the buttons associated with a given bar
		objGDB = objGDB,
		objPrefix = "Neuron"..objType:gsub("%s+", ""),
		objFrameT = objFrameType,
		objTemplate = objTemplate,
		objMetaT = objMetaTable,
		objType = objType,
		objMax = objMax,
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
		NEURON:Print(format(L["Timer_Limit_Set_Message"], GDB.timerLimit))
	else
		NEURON:Print(L["Timer_Limit_Invalid_Message"])
	end
end