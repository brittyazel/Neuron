--Neuron, a World of Warcraft® user interface addon.
-------------------------------------------------------------------------------
-- Localized Lua globals.
-------------------------------------------------------------------------------
local addonName = ...

local DB

local NeuronFrame = CreateFrame("Frame", nil, UIParent) --this is a frame mostly used to assign OnEvent functions
Neuron = LibStub("AceAddon-3.0"):NewAddon(NeuronFrame, "Neuron", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
--this is the working pointer that all functions act upon, instead of acting directly on Neuron (it was how it was coded before me. Seems unnecessary)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


Neuron.PEW = false --flag that gets set when the player enters the world. It's used primarily for throttling events so that the player doesn't crash on loging with too many processes

-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------

local latestVersionNum = "0.9.36" --this variable is set to popup a welcome message upon updating/installing. Only change it if you want to pop up a message after the users next update

local latestDBVersion = 1.2

--I don't think it's worth localizing these two strings. It's too much effort for messages that are going to change often. Sorry to everyone who doesn't speak English
local Update_Message = [[Thanks for updating Neuron!

**IMPORTANT** Due to some necessary changes, your keybinds have been reset. Sorry for the inconvenience. YOU MUST /reload ONCE MORE BEFORE YOU CAN BIND NEW KEYS!

New: Phase 1 of the full database rewrite has been completed. This new version is MUCH easier to work with going foward. I have also introduced a database versioning scheme, and as of today everyone should be on database version 1.2.

Sorry for the long delay between the last update and this one. With any changed to databases, I wanted to be extra careful to avoid ruining a user's bar layout. This has been a very stressfull release for me.

-Soyier]]


--prepare the Neuron table with some subtables that will be used down the road
Neuron['sIndex'] = {}
Neuron['cIndex'] = {}
Neuron['tIndex'] = {}
Neuron['ShowGrids'] = {}
Neuron['HideGrids'] = {}
Neuron['BARIndex'] = {}
Neuron['BARNameIndex'] = {}
Neuron['BTNIndex'] = {}
Neuron['EDITIndex'] = {}
Neuron['BINDIndex'] = {}
Neuron['SKINIndex'] = {}
Neuron['ModuleIndex'] = 0
Neuron['RegisteredBarData'] = {}
Neuron['RegisteredGUIData'] = {}
Neuron['MacroDrag'] = {}
Neuron['StartDrag'] = false


--working variable pointers
local BARIndex = Neuron.BARIndex
local BARNameIndex = Neuron.BARNameIndex --I'm not sure if we need both BarIndex and BARNameIndex. They're pretty much the same
local BTNIndex = Neuron.BTNIndex

---these are the database tables that are going to hold our data. They are global because every .lua file needs access to them

NeuronItemCache = {} --Stores a cache of all items that have been seen by a Neuron button


--I think this is only used in Neuron-Flyouts
Neuron.Points = {
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

Neuron.Stratas = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP"}


Neuron.STATES = {
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

local handler

local level

Neuron.BarEditMode = false
Neuron.ButtonEditMode = false
Neuron.BindingMode = false

Neuron.SpecialActions = {
	vehicle = "Interface\\AddOns\\Neuron\\Images\\new_vehicle_exit",
	possess = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
	taxi = "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up",
}

Neuron.unitAuras = { player = {}, target = {}, focus = {} }

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

	----DATABASE VERSION CHECKING AND MIGRATING----------

	if not DB.DBVersion then
		--we need to know if a profile doesn't have a DBVersion because it is brand new, or because it pre-dates DB versioning
		--when DB Versioning was introduced we also changed xbars to be called "extrabar", so if xbars exists in the database it means it's an old database, not a fresh one
		--eventually we can get rid of this check and just assume that having no DBVersion means that it is a fresh profile
		if not DB.NeuronCDB then --"NeuronCDB" is just a random table value that no longer exists. It's not important aside from the fact it no longer exists
			DB.DBVersion = latestDBVersion
		else
			DB.DBVersion = 1.0
		end
	end

	if DB.DBVersion ~= latestDBVersion then --checks if the DB version is out of date, and if so it calls the DB Fixer
		Neuron:DBFixer(DB, DB.DBVersion)
		DB.DBVersion = latestDBVersion
	end
	-----------------------------------------------------

	---load saved variables into working variable containers
	NeuronItemCache = DB.NeuronItemCache

	---these are the working pointers to our global database tables. Each class has a local GDB and CDB table that is a pointer to the root of their associated database
	Neuron.MAS = Neuron.MANAGED_ACTION_STATES
	Neuron.MBS = Neuron.MANAGED_BAR_STATES

	Neuron.player = UnitName("player")
	Neuron.class = select(2, UnitClass("player"))
	Neuron.level = UnitLevel("player")
	Neuron.realm = GetRealmName()


	Neuron:RegisterChatCommand("neuron", "slashHandler")


	---TODO:figure out what to do with this
	--[[local frame = CreateFrame("GameTooltip", "NeuronTooltipScan", UIParent, "GameTooltipTemplate")
	frame:SetOwner(UIParent, "ANCHOR_NONE")
	frame:SetFrameStrata("TOOLTIP")
	frame:Hide()]]


	StaticPopupDialogs["ReloadUI"] = {
		text = "ReloadUI",
		button1 = "Yes",
		OnAccept = function()
			ReloadUI()
		end,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}

	StaticPopupDialogs["ReloadUI"] = {
		text = "ReloadUI",
		button1 = "Yes",
		OnAccept = function()
			ReloadUI()
		end,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}


	Neuron:RegisterBarClass("bar", "ActionBar", L["Action Bar"], "Action Button", DB.bars, Neuron.BTNIndex, Neuron.ACTIONBUTTON, 250)

	Neuron:RegisterGUIOptions("bar", {
		AUTOHIDE = true,
		SHOWGRID = true,
		SPELLGLOW = true,
		SNAPTO = true,
		UPCLICKS = true,
		DOWNCLICKS = true,
		MULTISPEC = true,
		HIDDEN = true,
		LOCKBAR = true,
		TOOLTIPS = true,
		BINDTEXT = true,
		MACROTEXT = true,
		COUNTTEXT = true,
		RANGEIND = true,
		CDTEXT = true,
		CDALPHA = true,
		AURATEXT = true,
		AURAIND = true },
			true, 115)


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
	Neuron:RegisterEvent("COMPANION_UPDATE")
	Neuron:RegisterEvent("UNIT_LEVEL")
	Neuron:RegisterEvent("UNIT_PET")
	--Neuron:RegisterEvent("TOYS_UPDATED")
	--Neuron:RegisterEvent("TOYS_UPDATED")
	--Neuron:RegisterEvent("PET_JOURNAL_LIST_UPDATE")

	Neuron:RegisterEvent("PLAYER_TARGET_CHANGED")
	Neuron:RegisterEvent("ACTIONBAR_SHOWGRID")
	Neuron:RegisterEvent("UNIT_AURA")
	Neuron:RegisterEvent("UNIT_SPELLCAST_SENT")
	Neuron:RegisterEvent("UNIT_SPELLCAST_START")
	Neuron:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	Neuron:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")

	Neuron:HookScript(Neuron, "OnUpdate", "controlOnUpdate")


	Neuron:UpdateStanceStrings()

	--[[GameMenuFrame:HookScript("OnShow", function(self)

		if (Neuron.BarEditMode) then
			HideUIPanel(self)
			Neuron:ToggleBarEditMode(false)
		end

		if (Neuron.ButtonEditMode) then
			HideUIPanel(self)
			Neuron:ToggleButtonEditMode(false)
		end

		if (Neuron.BindingMode) then
			HideUIPanel(self)
			Neuron:ToggleBindingMode(false)
		end

	end)]]

	Neuron:LoginMessage()

	for _,bar in pairs(BARIndex) do
		Neuron.NeuronBar:Load(bar)
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

	if (Neuron.ButtonEditMode) then
		Neuron:ToggleButtonEditMode(false)
	end

	if (Neuron.BindingMode) then
		Neuron:ToggleBindingMode(false)
	end

	if (Neuron.BarEditMode) then
		Neuron:ToggleBarEditMode(false)
	end

end


function Neuron:PLAYER_ENTERING_WORLD()
	DB.firstRun = false

	Neuron:UpdateSpellIndex()
	Neuron:UpdatePetSpellIndex()
	Neuron:UpdateStanceStrings()
	Neuron:UpdateCompanionData()
	Neuron:UpdateToyData()

	--Fix for Titan causing the Main Bar to not be hidden
	if (IsAddOnLoaded("Titan")) then
		TitanUtils_AddonAdjust("MainMenuBar", true)
	end

	if (DB.blizzbar == false) then
		Neuron:HideBlizzard()
	end

	Neuron.PEW = true

end

function Neuron:ACTIVE_TALENT_GROUP_CHANGED()
	Neuron:UpdateSpellIndex()
	Neuron:UpdateStanceStrings()
end

function Neuron:LEARNED_SPELL_IN_TAB()
	Neuron:UpdateSpellIndex()
	Neuron:UpdateStanceStrings()
end

function Neuron:CHARACTER_POINTS_CHANGED()
	Neuron:UpdateSpellIndex()
	Neuron:UpdateStanceStrings()
end

function Neuron:SPELLS_CHANGED()
	Neuron:UpdateSpellIndex()
	Neuron:UpdateStanceStrings()
end

function Neuron:COMPANION_LEARNED()
	if not CollectionsJournal or not CollectionsJournal:IsShown() then
		Neuron:UpdateCompanionData()
	end
end

function Neuron:COMPANION_UPDATE()
	if not CollectionsJournal or not CollectionsJournal:IsShown() then
		Neuron:UpdateCompanionData()
	end
end

function Neuron:PET_JOURNAL_LIST_UPDATE()
	if not CollectionsJournal or not CollectionsJournal:IsShown() then
		Neuron:UpdateCompanionData()
	end
end


function Neuron:UNIT_PET(eventName, ...)
	if ... == "player" then
		if (Neuron.PEW) then
			Neuron:UpdatePetSpellIndex()
		end
	end
end

function Neuron:UNIT_LEVEL(eventName, ...)
	if ... == "player" then
		Neuron.level = UnitLevel("player")
	end
end

function Neuron:TOYS_UPDATED()
	if not ToyBox or not ToyBox:IsShown() then
		Neuron:UpdateToyData()
	end
end

function Neuron:PLAYER_TARGET_CHANGED()
	for k in pairs(Neuron.unitAuras) do
		Neuron.ACTIONBUTTON.updateAuraInfo(k)
	end
end

function Neuron:ACTIONBAR_SHOWGRID()
	Neuron.StartDrag = true
end

function Neuron:UNIT_AURA(eventname, ...)
	if (Neuron.unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		Neuron.ACTIONBUTTON.updateAuraInfo(select(1,...))
	end
end

function Neuron:UNIT_SPELLCAST_SENT(eventname, ...)
	if (Neuron.unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		Neuron.ACTIONBUTTON.updateAuraInfo(select(1,...))
	end
end

function Neuron:UNIT_SPELLCAST_START(eventname, ...)
	if (Neuron.unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		Neuron.ACTIONBUTTON.updateAuraInfo(select(1,...))
	end
end

function Neuron:UNIT_SPELLCAST_SUCCEEDED(eventname, ...)
	if (Neuron.unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		Neuron.ACTIONBUTTON.updateAuraInfo(select(1,...))
	end
end

function Neuron:UNIT_SPELLCAST_CHANNEL_START(eventname, ...)
	if (Neuron.unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		Neuron.ACTIONBUTTON.updateAuraInfo(select(1,...))
	end
end

function Neuron:UNIT_SPELLCAST_SUCCEEDED(eventname, ...)
	if (Neuron.unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		Neuron.ACTIONBUTTON.updateAuraInfo(select(1,...))
	end
end

-------------------------------------------------------------------------
--------------------Profiles---------------------------------------------
-------------------------------------------------------------------------

function Neuron:RefreshConfig()
	DB = Neuron.db.profile
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
	{L["Config"], L["Config_Description"], "ToggleBarEditMode"},
	{L["Add"], L["Add_Description"], "AddObjectsToBar"},
	{L["Remove"], L["Remove_Description"], "RemoveObjectsFromBar"},
	{L["Edit"], L["Edit_Description"], "ToggleButtonEditMode"},
	{L["Bind"], L["Bind_Description"], "ToggleBindingMode"},
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
	{L["BlizzUI"], L["BlizzUI_Description"], "ToggleBlizzUI"},
}


---New Slash functionality
function Neuron:slashHandler(input)

	if (strlen(input)==0 or input:lower() == "help") then
		Neuron:printSlashHelp()
		return
	end

	local commandAndArgs = {strsplit(" ", input)} --split the input into the command and the arguments
	local command = commandAndArgs[1]:lower()
	local args = {}
	for i = 2,#commandAndArgs do
		args[i-1] = commandAndArgs[i]:lower()
	end


	--somewhat of a hack to insert a "true" as an arg if trying to toggle the edit modes
	if command == "config" and Neuron.BarEditMode == false then
		args[1] = true
	end
	if command == "edit" and Neuron.ButtonEditMode == false then
		args[1] = true
	end
	if command == "bind" and Neuron.BindingMode == false then
		args[1] = true
	end



	for i = 1,#slashFunctions do

		if (command == slashFunctions[i][1]:lower()) then
			local func = slashFunctions[i][3]
			local bar = Neuron.CurrentBar

			if (Neuron[func]) then
				Neuron[func](Neuron, args[1])
			elseif (bar and Neuron.NeuronBar[func]) then
				---because we're calling a variable func name, we can't use the ":" notation, so we have to explicitely state the parent object as the first param
				Neuron.NeuronBar[func](Neuron.NeuronBar, bar, args[1]) --not sure what to do for more than 1 arg input
			else
				Neuron:Print(L["No bar selected or command invalid"])
			end
			return
		end
	end



end

function Neuron:printSlashHelp()

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

---TODO: we need to fix the throttling so that we don't bombard a single frame with ALL the processing, but instead spread out the processing on multiple frames

---this is the new controlOnUpdate function that will control all the other onUpdate functions.
function Neuron:controlOnUpdate(frame, elapsed)
	if not Neuron.elapsed then
		Neuron.elapsed = 0
	end

	Neuron.elapsed = Neuron.elapsed + elapsed

	---Throttled OnUpdate calls
	if (Neuron.elapsed > DB.throttle and Neuron.PEW) then

		Neuron.ACTIONBUTTON.cooldownsOnUpdate(elapsed)

		Neuron.PETBTN.controlOnUpdate(frame, elapsed)

		Neuron.elapsed = 0
	end

	---UnThrottled OnUpdate calls
	if(Neuron.PEW) then
		Neuron.ACTIONBUTTON.controlOnUpdate(elapsed) --this one needs to not be throttled otherwise spell button glows won't operate at 60fps
		Neuron.NeuronBar:controlOnUpdate(frame, elapsed)
	end
end

-----------------------------------------------------------------


function Neuron:LoginMessage()

	StaticPopupDialogs["Neuron_UPDATE_WARNING"] = {
		text = Update_Message,
		button1 = OKAY,
		timeout = 0,
		OnAccept = function() DB.updateWarning = latestVersionNum end
	}

	---displays a info window on login for either fresh installs or updates
	if (not DB.updateWarning or DB.updateWarning ~= latestVersionNum ) then
		StaticPopup_Show("Neuron_UPDATE_WARNING")

		Neuron:ChatMessage()
	end

end

function Neuron:ChatMessage()
	---TODO: Remove this eventually

	if UnitFactionGroup('player') == "Horde" then
		Neuron.Print("Click the following link to join the Neuron in-game community")
		Neuron.Print("https://bit.ly/2Lu72NZ")
	end
end


--I'm not sure what this function does, but it returns a table of all the names of children of a given frame
function Neuron:GetParentKeys(frame)
	if (frame == nil) then
		return
	end

	local data, childData = {}, {}
	local children = {frame:GetChildren()}
	local regions = {frame:GetRegions()}

	for k,v in pairs(children) do
		table.insert(data, v:GetName())
		childData = Neuron:GetParentKeys(v)
		for key,value in pairs(childData) do
			table.insert(data, value)
		end
	end

	for k,v in pairs(regions) do
		table.insert(data, v:GetName())
	end

	return data
end



--- Creates a table containing provided data
-- @param index, bookType, spellName, altName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon
-- @return curSpell:  Table containing provided data
function Neuron:SetSpellInfo(index, bookType, spellName, altName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)
	local curSpell = {}

	curSpell.index = index
	curSpell.booktype = bookType
	curSpell.spellName = spellName
	curSpell.altName = altName
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
function Neuron:UpdateSpellIndex()
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

			local altName, _, icon, castTime, minRange, maxRange = GetSpellInfo(spellID)
			if spellID ~= spellID_Alt then
				altName = GetSpellInfo(spellID_Alt)
			end

			local spellData = Neuron:SetSpellInfo(i, BOOKTYPE_SPELL, spellName, altName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)

			Neuron.sIndex[(spellName):lower()] = spellData
			Neuron.sIndex[(spellName):lower().."()"] = spellData


			if (altName and altName ~= spellName) then
				Neuron.sIndex[(altName):lower()] = spellData
				Neuron.sIndex[(altName):lower().."()"] = spellData
			end

			if (spellID) then
				Neuron.sIndex[spellID] = spellData
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
					local altName, _, icon, castTime, minRange, maxRange = GetSpellInfo(spellID)
					local spellData = Neuron:SetSpellInfo(offsetIndex, BOOKTYPE_PROFESSION, spellName, altName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)

					Neuron.sIndex[(spellName):lower()] = spellData
					Neuron.sIndex[(spellName):lower().."()"] = spellData


					if (altName and altName ~= spellName) then
						Neuron.sIndex[(altName):lower()] = spellData
						Neuron.sIndex[(altName):lower().."()"] = spellData

					end

					if (spellID) then
						Neuron.sIndex[spellID] = spellData
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

				local altName, _, icon, castTime, minRange, maxRange = GetSpellInfo(spellName)

				for k,v in pairs(Neuron.sIndex) do

					if (v.spellName:find(petName.."$")) then
						local spellData = Neuron:SetSpellInfo(v.index, v.booktype, v.spellName, nil, spellID, v.spellID_Alt, v.spellType, v.spellLvl, v.isPassive, v.icon)

						Neuron.sIndex[(spellName):lower()] = spellData
						Neuron.sIndex[(spellName):lower().."()"] = spellData
						Neuron.sIndex[spellID] = spellData
					end
				end
			end
		end
	end

end


--- Adds pet spells & abilities to the spell list index
function Neuron:UpdatePetSpellIndex()

	if (HasPetSpells()) then
		for i=1,HasPetSpells() do
			local spellName, _ = GetSpellBookItemName(i, BOOKTYPE_PET)
			local spellType, _ = GetSpellBookItemInfo(i, BOOKTYPE_PET)
			local spellLvl = GetSpellAvailableLevel(i, BOOKTYPE_PET)
			local isPassive = IsPassiveSpell(i, BOOKTYPE_PET)

			if (spellName and spellType ~= "FUTURESPELL") then
				local altName, _, icon, castTime, minRange, maxRange, spellID = GetSpellInfo(spellName)
				local spellID_Alt = spellID

				local spellData = Neuron:SetSpellInfo(i, BOOKTYPE_PET, spellName, altName, spellID, spellID_Alt, spellType, spellLvl, isPassive, icon)

				Neuron.sIndex[(spellName):lower()] = spellData
				Neuron.sIndex[(spellName):lower().."()"] = spellData


				if (spellID) then
					Neuron.sIndex[spellID] = spellData
				end


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
function Neuron:UpdateToyData()

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
			Neuron.tIndex[name:lower()] = itemID
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
function Neuron:UpdateCompanionData()
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
				local companionData = Neuron:SetCompanionData("CRITTER", i, speciesID, speciesName, petID, icon)
				Neuron.cIndex[spell:lower()] = companionData
				Neuron.cIndex[spell:lower().."()"] = companionData
				Neuron.cIndex[petID] = companionData

			end
		end
	end

	local mountIDs = C_MountJournal.GetMountIDs()
	for i,id in pairs(mountIDs) do
		local creatureName , spellID = C_MountJournal.GetMountInfoByID(id) --, creatureID, _, active, summonable, source, isFavorite, isFactionSpecific, faction, unknown, owned = C_MountJournal.GetMountInfoByID(i)

		if (spellID) then
			local spell, _, icon = GetSpellInfo(spellID)
			if (spell) then
				local companionData = Neuron:SetCompanionData("MOUNT", i, spellID, creatureName, spellID, icon)
				Neuron.cIndex[spell:lower()] = companionData
				Neuron.cIndex[spell:lower().."()"] = companionData
				Neuron.cIndex[spellID] = companionData

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

				local druidFormTable = {
					{"Bear Form", 5487},
					{"Cat Form", 768},
					{"Travel Form", 783},
					{"Moonkin Form", 24858},
					{"Treant Form", 114282},
					{"Stag Form", 210053},
				}

				--compare the current i's Shapeshift Form spellID to the ones in the druidFormTable, and choose the appropriate string
				for j=1,#druidFormTable do
					if spellID == druidFormTable[j][2] then
						Neuron.STATES["stance"..i] = druidFormTable[j][1]
						states = states.."[stance:"..i.."] stance"..i.."; "
					end
				end

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

		local states = states:gsub("; $", "")

		Neuron.MAS.stance.states = states
	end
end


---this is taken from Bartender4, thanks guys!
function Neuron:HideBlizzard()
	if (InCombatLockdown()) then
		return
	end

	-- Hidden parent frame
	local UIHider = CreateFrame("Frame")
	UIHider:Hide()

	if MultiBarBottomLeft then
		MultiBarBottomLeft:Hide()
		MultiBarBottomLeft:SetParent(UIHider)
	end

	if MultiBarBottomRight then
		MultiBarBottomRight:Hide()
		MultiBarBottomRight:SetParent(UIHider)
	end

	if MultiBarLeft then
		MultiBarLeft:Hide()
		MultiBarLeft:SetParent(UIHider)
	end

	if MultiBarRight then
		MultiBarRight:Hide()
		MultiBarRight:SetParent(UIHider)
	end


	MainMenuBar:UnregisterAllEvents()
	MainMenuBar:SetParent(UIHider)
	MainMenuBar:Hide()
	MainMenuBar:EnableMouse(false)
	MainMenuBar:UnregisterEvent("DISPLAY_SIZE_CHANGED")
	MainMenuBar:UnregisterEvent("UI_SCALE_CHANGED")


	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(UIHider)


	if MicroButtonAndBagsBar then
		MicroButtonAndBagsBar:Hide()
		MicroButtonAndBagsBar:SetParent(UIHider)
	end

	if MainMenuExpBar then
		MainMenuExpBar:UnregisterAllEvents()
		MainMenuExpBar:Hide()
		MainMenuExpBar:SetParent(UIHider)
		MainMenuExpBar:SetDeferAnimationCallback(nil)
	end

	if MainMenuBarMaxLevelBar then
		MainMenuBarMaxLevelBar:Hide()
		MainMenuBarMaxLevelBar:SetParent(UIHider)
	end

	if ReputationWatchBar then
		ReputationWatchBar:UnregisterAllEvents()
		ReputationWatchBar:Hide()
		ReputationWatchBar:SetParent(UIHider)
	end

	if ArtifactWatchBar then
		ArtifactWatchBar:SetParent(UIHider)
		ArtifactWatchBar.StatusBar:SetDeferAnimationCallback(nil)
	end

	if HonorWatchBar then
		HonorWatchBar:SetParent(UIHider)
		HonorWatchBar.StatusBar:SetDeferAnimationCallback(nil)
	end

	OverrideActionBar_OnLoad(OverrideActionBar)
	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar:Hide()
	OverrideActionBar:SetParent(UIHider)

	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(UIHider)

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(UIHider)

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(UIHider)


end

function Neuron:ToggleBlizzUI()
	if (DB.blizzbar == true) then
		DB.blizzbar = false
		Neuron:HideBlizzard()
		StaticPopup_Show("ReloadUI")
	else
		DB.blizzbar = true
		StaticPopup_Show("ReloadUI")
	end
end



function Neuron:ToggleButtonGrid(show)
	for id,btn in pairs(Neuron.BTNIndex) do
		btn:SetObjectVisibility(show)
	end
end



function Neuron:ToggleMainMenu(show, hide)
	---need to run the command twice for some reason. The first one only seems to open the Interface panel
	InterfaceOptionsFrame_OpenToCategory("Neuron");
	InterfaceOptionsFrame_OpenToCategory("Neuron");
end

function Neuron:ToggleBarEditMode(show)

	if show and Neuron.BarEditMode == false then

		Neuron.BarEditMode = true

		Neuron:ToggleButtonEditMode(false)
		Neuron:ToggleBindingMode(false)

		for index, bar in pairs(BARIndex) do
			bar:Show() --this shows the transparent overlay over a bar
			Neuron.NeuronBar:Update(bar, true)
			Neuron.NeuronBar:UpdateObjectVisibility(bar, true)
		end

	else

		Neuron.BarEditMode = false

		for index, bar in pairs(BARIndex) do
			bar:Hide()
			Neuron.NeuronBar:Update(bar, nil, true)
			Neuron.NeuronBar:UpdateObjectVisibility(bar)
		end

		Neuron.NeuronBar:ChangeBar(nil)

		if (NeuronBarEditor)then
			NeuronBarEditor:Hide()
		end

	end

end

function Neuron:ToggleButtonEditMode(show)

	if show and Neuron.ButtonEditMode == false then

		Neuron.ButtonEditMode = true

		Neuron:ToggleBarEditMode(false)
		Neuron:ToggleBindingMode(false)


		for index, editor in pairs(Neuron.EDITIndex) do
			editor:Show()
			editor.object.editmode = true

			if (editor.object.bar) then
				editor:SetFrameStrata(editor.object.bar:GetFrameStrata())
				editor:SetFrameLevel(editor.object.bar:GetFrameLevel()+4)
			end
		end

		for _,bar in pairs(BARIndex) do
			Neuron.NeuronBar:UpdateObjectVisibility(bar, true)
		end

	else

		Neuron.ButtonEditMode = false

		for index, editor in pairs(Neuron.EDITIndex) do
			editor:Hide()
			editor.object.editmode = false
			editor:SetFrameStrata("LOW")
		end

		for _,bar in pairs(BARIndex) do
			Neuron.NeuronBar:UpdateObjectVisibility(bar)

			if (bar.handler:GetAttribute("assertstate")) then
				bar.handler:SetAttribute("state-"..bar.handler:GetAttribute("assertstate"), bar.handler:GetAttribute("activestate") or "homestate")
			end
		end

		Neuron:ChangeObject()

	end
end


function Neuron:ToggleBindingMode(show)

	if show and Neuron.BindingMode == false then

		Neuron.BindingMode = true

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

		for _,bar in pairs(BARIndex) do
			Neuron.NeuronBar:UpdateObjectVisibility(bar, true)
		end

	else

		Neuron.BindingMode = false

		for _, binder in pairs(Neuron.BINDIndex) do
			binder:Hide()
			binder.button.editmode = false

			binder:SetFrameStrata("LOW")

		end

		for _,bar in pairs(BARIndex) do
			Neuron.NeuronBar:UpdateObjectVisibility(bar)
		end
	end
end



function Neuron:PrintStateList()
	local data = {}
	local list

	for k,v in pairs(Neuron.MANAGED_ACTION_STATES) do
		if (Neuron.STATEINDEX[k]) then
			data[v.order] = Neuron.STATEINDEX[k]
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


function Neuron:PrintBarTypes()
	local data, index, high = {}, 1, 0

	for k,v in pairs(Neuron.RegisteredBarData) do

		local barType;
		index = tonumber(v.createMsg:match("%d+"))
		barType = v.createMsg:gsub("%d+","")

		if (index and barType) then
			data[index] = {k, barType}
			if (index > high) then high = index end
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
function Neuron:RegisterBarClass(class, barType, barLabel, objType, barDB, objTable, objTemplate, objMax)

	Neuron.ModuleIndex = Neuron.ModuleIndex + 1

	Neuron.RegisteredBarData[class] = {
		barType = barType,
		barLabel = barLabel,
		barDB = barDB,
		objTable = objTable, --this is all the buttons associated with a given bar
		objPrefix = "Neuron"..objType:gsub("%s+", ""),
		objType = objType,
		objTemplate = objTemplate,
		objMax = objMax,
		createMsg = Neuron.ModuleIndex..objType,
	}
end


function Neuron:RegisterGUIOptions(class, chkOpt, stateOpt, adjOpt)
	Neuron.RegisteredGUIData[class] = {
		chkOpt = chkOpt,
		stateOpt = stateOpt,
		adjOpt = adjOpt,
	}
end


function Neuron:SetTimerLimit(msg)
	local limit = tonumber(msg:match("%d+"))

	if (limit and limit > 0) then
		DB.timerLimit = limit
		Neuron:Print(format(L["Timer_Limit_Set_Message"], DB.timerLimit))
	else
		Neuron:Print(L["Timer_Limit_Invalid_Message"])
	end
end
