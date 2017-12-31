--Neuron, a World of Warcraft® user interface addon.
--Copyright© 2006-2014 Connor H. Chenoweth, aka Maul - All rights reserved.
--Copyright© 2017 Britt W. Yazel, aka Soyier - All rights reserved.

-------------------------------------------------------------------------------
-- Localized Lua globals.
-------------------------------------------------------------------------------
local addonName = ...

local _G = getfenv(0)

-- Functions
local next = _G.next
local pairs = _G.pairs
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type

-- Libraries
local string = _G.string
local table = _G.table

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
NeuronProfile = LibStub("AceAddon-3.0"):NewAddon("NeuronProfile") --This should be merged into the "NeuronBase" addon eventually.
NeuronBase = LibStub("AceAddon-3.0"):NewAddon("Neuron", "AceConsole-3.0")


-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------

local latestVersionNum = "0.9.8" --this variable is set to popup a welcome message upon updating/installing. Only change it if you want to pop up a message after the users next update

local Install_Message = [[Thank's for installing Neuron.

Neuron is currently in a "|cffffff00release|r" state.

If you have any questions or concerns please direct all inquirires our github page listed in the FAQ.

Cheers,

-Soyier]]

local Update_Message = [[Thanks for updating Neuron!

Today's update is making it such that the menubar and the bagbar are finally saved per-character, rather than per account, which was hugely annoying.

Unfortunately, you will need to manually re-position these bars.

-Soyier]]


Neuron = {
	sIndex = {},
	iIndex = {[1] = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"},
	cIndex = {},
	tIndex = {},
	StanceIndex = {},
	ShowGrids = {},
	HideGrids = {},
	BARIndex = {},
	BARNameIndex = {},
	BTNIndex = {},
	EDITIndex = {},
	BINDIndex = {},
	SKINIndex = {},
	ModuleIndex = 0,
	RegisteredBarData = {},
	RegisteredGUIData = {},
	MacroDrag = {},
	StartDrag = false,
	maxActionID = 132,
	maxPetID = 10,
	maxStanceID = _G.NUM_STANCE_SLOTS, --(10)
}

NeuronGDB = {
	bars = {},
	buttons = {},

	xbars = {},
	xbtns = {},

	sbars = {},
	sbtns = {},

	zoneabilitybars = {},
	zoneabilitybtns = {},

	buttonLoc = {-0.85, -111.45},
	buttonRadius = 87.5,

	throttle = 0.2,
	timerLimit = 4,
	snapToTol = 28,

	mainbar = false,
	zoneabilitybar = false,
	vehicle = false,

	firstRun = true,
	xbarFirstRun = true,
	sbarFirstRun = true,
	zoneabilitybarFirstRun = true,

	betaWarning = false,

	animate = true,
	showmmb = true,
}

NeuronCDB = {
	bars = {},
	buttons = {},

	xbars = {},
	xbtns = {},

	sbars = {},
	sbtns = {},

	zoneabilitybars = {},
	zoneabilitybtns = {},

	selfCast = false,
	focusCast = false,
	mouseOverMod= "NONE",

	layOut = 1,

	perCharBinds = false,

	fix07312012 = false,
	fix03312014 = false,

	firstRun = true,

}

NeuronSpec = {cSpec = 1}

NeuronItemCache = {}

local NEURON = Neuron
local BAR --gets set to NEURON.BAR in the OnEvent method

local BARIndex, BARNameIndex, BTNIndex, ICONS = NEURON.BARIndex, NEURON.BARNameIndex, NEURON.BTNIndex, NEURON.iIndex

local icons = {}

NEURON.GameVersion, NEURON.GameBuild, NEURON.GameDate, NEURON.TOCVersion = GetBuildInfo()

NEURON.GameVersion = tonumber(NEURON.GameVersion); NEURON.TOCVersion = tonumber(NEURON.TOCVersion)

NEURON.Points = {R = "RIGHT", L = "LEFT", T = "TOP", B = "BOTTOM", TL = "TOPLEFT", TR = "TOPRIGHT", BL = "BOTTOMLEFT", BR = "BOTTOMRIGHT", C = "CENTER", RIGHT = "RIGHT", LEFT = "LEFT", TOP = "TOP", BOTTOM = "BOTTOM", TOPLEFT = "TOPLEFT", TOPRIGHT = "TOPRIGHT", BOTTOMLEFT = "BOTTOMLEFT", BOTTOMRIGHT = "BOTTOMRIGHT", CENTER = "CENTER"}

NEURON.Stratas = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP"}


--why are there two of some of these states?
NEURON.STATES = {
	homestate = L.HOMESTATE,
	laststate = L.LASTSTATE,
	paged1 = L.PAGED1,
	paged2 = L.PAGED2,
	paged3 = L.PAGED3,
	paged4 = L.PAGED4,
	paged5 = L.PAGED5,
	paged6 = L.PAGED6,
	--pet0 = L.PET0,
	--pet1 = L.PET1,
	alt0 = L.ALT0,
	alt1 = L.ALT1,
	ctrl0 = L.CTRL0,
	ctrl1 = L.CTRL1,
	shift0 = L.SHIFT0,
	shift1 = L.SHIFT1,
	stealth0 = L.STEALTH0,
	stealth1 = L.STEALTH1,
	reaction0 = L.REACTION0,
	reaction1 = L.REACTION1,
	combat0 = L.COMBAT0,
	combat1 = L.COMBAT1,
	group0 = L.GROUP0,
	group1 = L.GROUP1,
	group2 = L.GROUP2,
	fishing0 = L.FISHING0,
	fishing1 = L.FISHING1,
	vehicle0 = L.VEHICLE0,
	vehicle1 = L.VEHICLE1,
	possess0 = L.POSSESS0,
	possess1 = L.POSSESS1,
	override0 = L.OVERRIDE0,
	override1 = L.OVERRIDE1,
	--extrabar0 = L.EXTRABAR0,
	--extrabar1 = L.EXTRABAR1,
	custom0 = L.CUSTOM0,
	target0 = L.TARGET0,
	target1 = L.TARGET1,
}

NEURON.STATEINDEX = {
	paged = "paged",
	stance = "stance",
	stance = "stance",
	pet = "pet",
	alt = "alt",
	ctrl = "ctrl",
	shift = "shift",
	stealth = "stealth",
	reaction = "reaction",
	combat = "vehicle",
	group = "group",
	fishing = "fishing",
	vehicle = "custom",
	possess = "possess",
	override = "override",
	extrabar = "extrabar",
	custom = "custom",
	target = "target",
}

local handler = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")

local level, stanceStringsUpdated, PEW



--ACE GUI OPTION TABLE
local options = {
	name = "Neuron",
	type = 'group',
	args = {
		moreoptions={
			name = "Options",
			type = "group",
			order = 0,
			args={
				AnimateIcon = {
					order = 0,
					name = "Animate Icon",
					desc = "Toggles the Animation of the Neuron Icon",
					type = "toggle",
					set = function() NEURON:Animate() end,
					get = function() return NeuronGDB.animate end,
					width = "full",
				},
				BlizzardBar = {
					order = 1,
					name = "Display Blizzard Bar",
					desc = "Shows / Hides the Default Blizzard Bar",
					type = "toggle",
					set = function() NEURON:BlizzBar() end,
					get = function() return NeuronGDB.mainbar end,
					width = "full",
				},
				MMbutton = {
					order = 2,
					name = "Display Minimap Button",
					desc = "Toggles the minimap button.",
					type = "toggle",
					set =  function() NEURON:toggleMMB() end,
					get = function() return NeuronGDB.showmmb end,
					width = "full"
				},
			},
		},

		changelog = {
			name = L.CHANGELOG_TITLE,
			type = "group",
			order = 1000,
			args = {
				line1 = {
					type = "description",
					name = L.CHANGELOG,
				},
			},
		},

		faq = {
			name = L.FAQ_TITLE,
			desc = L.FAQ_TITLE_LONG,
			type = "group",
			order = 1001,
			args = {

				line1 = {
					type = "description",
					name = L.FAQ,
				},

				g1 = {
					type = "group",
					name =L.FAQ_BAR_CONFIGURE_TITLE,
					order = 1,
					args = {

						line1 = {
							type = "description",
							name =L.FAQ_BAR_CONFIGURE,
							order = 1,
						},

						g1 = {
							type = "group",
							name =L.FAQ_BAR_CONFIGURE_GENERAL_OPTIONS_TITLE,
							order = 1,
							args = {
								line1 = {
									type = "description",
									name = L.FAQ_BAR_CONFIGURE_GENERAL_OPTIONS ,
									order = 1,
								},
							},
						},

						g2 = {
							type = "group",
							name =L.FAQ_BAR_CONFIGURE_BAR_STATES_TITLE,
							order = 2,
							args = {
								line1 = {
									type = "description",
									name = L.FAQ_BAR_CONFIGURE_BAR_STATES ,
									order = 1,
								},
							},
						},

						g3 = {
							type = "group",
							name = L.FAQ_BAR_CONFIGURE_SPELL_TARGET_TITLE,
							order = 3,
							args = {
								line1 = {
									type = "description",
									name = L.FAQ_BAR_CONFIGURE_SPELL_TARGET ,
									order = 1,
								},
							},
						},
					},
				},

				g2 = {
					type = "group",
					name = L.FLYOUT,
					order = 3,
					args = {
						line1a = {
							type = "description",
							name = L.FLYOUT_FAQ ,
							order = 1,
						},
					},
				},

			},
		},
	},
}

local defaults = {
	profile = {
		NeuronGDB = {
			bars = {},
			buttons = {},

			xbars = {},
			xbtns = {},

			sbars = {},
			sbtns = {},

			zoneabilitybars = {},
			zoneabilitybtns = {},

			buttonLoc = {-0.85, -111.45},
			buttonRadius = 87.5,

			throttle = 0.2,
			timerLimit = 4,
			snapToTol = 28,

			mainbar = false,
			zoneabilitybar = true,
			vehicle = false,

			firstRun = true,
			xbarFirstRun = true,
			sbarFirstRun = true,
			zoneabilitybarFirstRun = true,

			betaWarning = true,

			animate = true,
			showmmb = true,
		},
		NeuronCDB = {

			bars = {},
			buttons = {},

			xbars = {},
			xbtns = {},

			sbars = {},
			sbtns = {},

			zoneabilitybars = {},
			zoneabilitybtns = {},

			selfCast = false,
			focusCast = false,
			mouseOverMod= "NONE",

			layOut = 1,

			perCharBinds = false,

			fix07312012 = false,
			fix03312014 = false,

			firstRun = true,

		},
		NeuronSpec = {cSpec = 1},
	},
}

local defGDB, GDB, defCDB, CDB, defSPEC, SPEC = CopyTable(NeuronGDB), CopyTable(NeuronGDB), CopyTable(NeuronCDB), CopyTable(NeuronCDB), CopyTable(NeuronSpec), CopyTable(NeuronSpec)


--------------------------------------------
--------------Slash Functions --------------
--------------------------------------------

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
	{L["Animate"], L["Animate_Description"], "Animate"},
	--{L["MoveSpecButtons"], L["MoveSpecButtons_Description"], "MoveSpecButtons"},
}
---New Slash functionality using Ace3
NeuronBase:RegisterChatCommand("neuron", "slashHandler")

function NeuronBase:slashHandler(input)

	if (strlen(input)==0 or input:lower() == "help") then
		printSlashHelp()
		return
	end

	local commandAndArgs = {strsplit(" ", input)} --split the input into the command and the arguments
	local command = commandAndArgs[1]
	local args = {}
	for i = 2,#commandAndArgs do
		args[i-1] = commandAndArgs[i]
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
				print(L.SELECT_BAR)
			end
		end
	end



end

function printSlashHelp()

	NeuronBase:Print(L["Command List"]..":")
	for i = 1,#slashFunctions do
		--formats the output to be the command name and then the description
		NeuronBase:Print(slashFunctions[i][1]:lower().." - " .."("..slashFunctions[i][2]..")")
	end

end


-------------------------------------------------------------------------
--------------------Start of Functions-----------------------------------
-------------------------------------------------------------------------

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

	for i=1,8 do
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
end


--- Adds pet spells & abilities to the spell list index
function NEURON:UpdatePetSpellIndex()
	local numPetSpells = HasPetSpells() or 0

	for i=1,numPetSpells do
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
			--if (icon and not icons[icon:upper()]) then
			--	ICONS[#ICONS+1] = icon:upper(); icons[icon:upper()] = true
			--end
		end

		i = i + 1
	end

	-- a lot of work to associate the Call Pet spell with the pet's name so that tooltips work on Call Pet spells. /sigh
	local _, _, numSlots, isKnown = GetFlyoutInfo(9)
	--local petIndex, petName

	for i=1, numSlots do
		local spellID, isKnown = GetFlyoutSlotInfo(9, i)
		local petIndex, petName = GetCallPetSpellInfo(spellID)

		if (isKnown and petIndex and petName and #petName > 0) then
			local spellName = GetSpellInfo(spellID)
			--local spellData = SetSpellInfo(v.index, v.booktype, v.spellName, nil, v.subName, spellID, spellID_Alt, v.spellType, v.spellLvl, v.isPassive, v.icon)

			for k,v in pairs(NEURON.sIndex) do
				if (v.spellName:find(petName.."$")) then
					local spellData = SetSpellInfo(v.index, v.booktype, v.spellName, nil, v.subName, spellID, spellID_Alt, v.spellType, v.spellLvl, v.isPassive, v.icon)

					NEURON.sIndex[(spellName):lower()] = spellData
					NEURON.sIndex[(spellName):lower().."()"] = spellData
					NEURON.sIndex[spellID] = spellData
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
	--_G.C_PetJournal.ClearAllPetSourcesFilter()
	--_G.C_PetJournal.ClearAllPetTypesFilter()

	_G.C_PetJournal.ClearSearchFilter()

	--_G.C_PetJournal.AddAllPetSourcesFilter()
	--_G.C_PetJournal.AddAllPetTypesFilter()

	_G.C_PetJournal.SetAllPetSourcesChecked(true)
	_G.C_PetJournal.SetAllPetTypesChecked(true)
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

local temp = {}

local TempTexture = (CreateFrame("Button", nil, UIParent)):CreateTexture()
--textf:Hide()

--- Creates a table of the available spell icon filenames for use in macros
function NEURON:UpdateIconIndex()
	local icon

	wipe(temp)
	GetMacroIcons(temp)

	for k,icon in ipairs(temp) do
		if (not icons[icon]) then
			ICONS[#ICONS+1] = icon; icons[icon] = true
		end

	end

end

function NEURON:UpdateStanceStrings()
	if (NEURON.class == "DRUID" or
			NEURON.class == "MONK" or
			NEURON.class == "PRIEST" or
			NEURON.class == "ROGUE" or
			NEURON.class == "WARRIOR" or
			NEURON.class == "WARLOCK") then

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

					if (NEURON.class == "DRUID" and spellID == 768) then
						NEURON.kitty = i
					end
				end

				NEURON.STATES["stance"..i] = name
				states = states.."[stance:"..i.."] stance"..i.."; "
			end
		end

		--Adds Shadow Dance State for Subelty Rogues
		if (NEURON.class == "ROGUE" and GetSpecialization() == 3 ) then
			NEURON.STATES["stance2"] = L.ROGUE_SHADOW_DANCE
			NEURON.StanceIndex[2] = 185313
			states = states.."[stance:2] stance2; "
		end

		states = states:gsub("; $", "")

		if (not stanceStringsUpdated) then
			if (NEURON.class == "DRUID") then
				NEURON.STATES.stance0 = L.DRUID_CASTER
			end

			if (NEURON.class == "MONK") then
				NEURON.STATES.stance0 = ATTRIBUTE_NOOP
				NEURON.MAS.stance.homestate = "stance1"
			end

			if (NEURON.class == "PRIEST") then
				NEURON.STATES.stance0 = L.PRIEST_HEALER
			end

			if (NEURON.class == "ROGUE") then
				NEURON.STATES.stance0 = L.ROGUE_MELEE
			end

			if (NEURON.class == "WARLOCK") then
				NEURON.STATES.stance0 = L.WARLOCK_CASTER
			end

			if (NEURON.class == "WARRIOR") then
				NEURON.STATES.stance0 = ATTRIBUTE_NOOP
				NEURON.MAS.stance.homestate = "stance1"
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


--From http://www.wowpedia.org/GetMinimapShape
local minimapShapes = {
	-- quadrant booleans (same order as SetTexCoord)
	-- {upper-left, lower-left, upper-right, lower-right}
	-- true = rounded, false = squared
	["ROUND"] 				= {true, true, true, true},
	["SQUARE"] 				= {false, false, false, false},
	["CORNER-TOPLEFT"] 			= {true, false, false, false},
	["CORNER-TOPRIGHT"] 		= {false, false, true, false},
	["CORNER-BOTTOMLEFT"] 		= {false, true, false, false},
	["CORNER-BOTTOMRIGHT"]		= {false, false, false, true},
	["SIDE-LEFT"] 				= {true, true, false, false},
	["SIDE-RIGHT"] 			= {false, false, true, true},
	["SIDE-TOP"] 				= {true, false, true, false},
	["SIDE-BOTTOM"] 			= {false, true, false, true},
	["TRICORNER-TOPLEFT"]		= {true, true, true, false},
	["TRICORNER-TOPRIGHT"] 		= {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"]		= {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"]	= {false, true, true, true},
}

local function updatePoint(self, elapsed)
	if (GDB.animate) then
		self.elapsed = self.elapsed + elapsed

		if (self.elapsed > 0.025) then
			self.l = self.l + 0.0625
			self.r = self.r + 0.0625

			if (self.r > 1) then
				self.l = 0
				self.r = 0.0625
				self.b = self.b + 0.0625
			end

			if (self.b > 1) then
				self.l = 0
				self.r = 0.0625
				self.b = 0.0625
			end

			self.t = self.b - (0.0625 * self.tadj)

			if (self.t < 0) then self.t = 0 end
			if (self.t > 1) then self.t = 1 end

			self.texture:SetTexCoord(self.l, self.r, self.t, self.b)
			self.elapsed = 0
		end
	end
end


local function createMiniOrb(parent, index, prefix)
	local point = CreateFrame("Frame", prefix..index, parent, "NeuronMiniOrbTemplate")

	point:SetScript("OnUpdate", updatePoint)
	point.tadj = 1
	point.elapsed = 0

	local row, col = random(0,15), random(0,15)

	point.l = 0.0625 * row; point.r = point.l + 0.0625
	point.t = 0.0625 * col; point.b = point.t + 0.0625

	point.texture:SetTexture("Interface\\AddOns\\Neuron\\Images\\seq_smoke")
	point.texture:SetTexCoord(point.l, point.r, point.t, point.b)

	return point
end


function NEURON:DragFrame_OnUpdate(x, y)
	local pos, quad, round, radius = nil, nil, nil, GDB.buttonRadius - NeuronMinimapButton:GetWidth()/math.pi
	local sqRad = sqrt(2*(radius)^2)
	local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = minimapShapes[minimapShape]
	local xpos, ypos = x, y

	if (not xpos or not ypos) then
		xpos, ypos = GetCursorPosition()
	end

	xpos = xmin - xpos / Minimap:GetEffectiveScale() + radius
	ypos = ypos / Minimap:GetEffectiveScale() - ymin - radius

	pos = math.deg(math.atan2(ypos,xpos))

	xpos = cos(pos)
	ypos = sin(pos)

	if (xpos > 0 and ypos > 0) then
		quad = 1 --topleft
	elseif (xpos > 0 and ypos < 0) then
		quad = 2 --bottomleft
	elseif (xpos < 0 and ypos > 0) then
		quad = 3 --topright
	elseif (xpos < 0 and ypos < 0) then
		quad = 4 --bottomright
	end

	round = quadTable[quad]

	if (round) then
		xpos = xpos * radius
		ypos = ypos * radius
	else
		xpos = max(-radius, min(xpos * sqRad, radius))
		ypos = max(-radius, min(ypos * sqRad, radius))
	end

	NeuronMinimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52-xpos, ypos-55)
	GDB.buttonLoc = {52-xpos, ypos-55}
end


function NEURON:MinimapButton_OnLoad(minimap)
	minimap:RegisterForClicks("AnyUp")
	minimap:RegisterForDrag("LeftButton")
	minimap:RegisterEvent("PLAYER_LOGIN")
	minimap.elapsed = 0
	minimap.x = 0
	minimap.y = 0
	minimap.count = 1
	minimap.angle = 0
	minimap:SetFrameStrata(MinimapCluster:GetFrameStrata())
	minimap:SetFrameLevel(MinimapCluster:GetFrameLevel()+3)
	minimap:GetHighlightTexture():SetAlpha(0.3)
end


function NEURON:MinimapButton_OnEvent(minimap)
	minimap.orb = createMiniOrb(minimap, 1, "NeuronMinimapOrb")
	minimap.orb:SetPoint("CENTER", minimap, "CENTER", 0.5, 0.5)
	minimap.orb:SetScale(2)
	minimap.orb:SetFrameLevel(minimap:GetFrameLevel())
	minimap.orb.texture:SetVertexColor(0,.54,.54)
	NEURON:MinimapButton_OnDragStop(minimap)
end


function NEURON:MinimapButton_OnDragStart(minimap)
	minimap:LockHighlight()
	minimap:StartMoving()
	NeuronMinimapButtonDragFrame:Show()
end


function NEURON:MinimapButton_OnDragStop(minimap)
	if (minimap) then
		minimap:UnlockHighlight()
		minimap:StopMovingOrSizing()
		minimap:SetUserPlaced(false)
		minimap:ClearAllPoints()
		if (GDB and GDB.buttonLoc) then
			minimap:SetPoint("TOPLEFT", "Minimap","TOPLEFT", GDB.buttonLoc[1], GDB.buttonLoc[2])
		end
		NeuronMinimapButtonDragFrame:Hide()
	end
end


function NEURON:MinimapButton_OnShow(minimap)

	if (GDB) then
		NEURON:MinimapButton_OnDragStop(minimap)
	end
end


function NEURON:MinimapButton_OnHide(minimap)
	minimap:UnlockHighlight()
	NeuronMinimapButtonDragFrame:Hide()
end

function NEURON:MinimapButton_OnEnter(minimap)
	GameTooltip_SetDefaultAnchor(GameTooltip, minimap)
	GameTooltip:SetText("Neuron", 1, 1, 1)
	GameTooltip:AddLine(L.MINIMAP_TOOLTIP1, 1, 1, 1)
	GameTooltip:AddLine(L.MINIMAP_TOOLTIP2, 1, 1, 1)
	GameTooltip:AddLine(L.MINIMAP_TOOLTIP3, 1, 1, 1)
	GameTooltip:AddLine(L.MINIMAP_TOOLTIP4, 1, 1, 1)
	GameTooltip:Show()
end


function NEURON:MinimapButton_OnLeave(minimap)
	GameTooltip:Hide()
end


function NEURON:MinimapButton_OnClick(minimap, button)
	PlaySound(SOUNDKIT.IG_CHAT_SCROLL_DOWN)

	if (InCombatLockdown()) then return end

	if (button == "RightButton") then
		NEURON:ToggleEditFrames()
	elseif (IsShiftKeyDown()) then
		NEURON:ToggleMainMenu()
	elseif (IsAltKeyDown() or button == "MiddleButton") then
		NEURON:ToggleBindings()
	else
		NEURON:ToggleBars()
	end
end


function NEURON:MinimapMenuClose()
	NeuronMinimapButton.popup:Hide()
end

function NEURON:toggleMMB()
	if not NeuronGDB.showmmb then
		NeuronMinimapButton:Hide()
	else
		NeuronMinimapButton:Show()
	end
	NeuronGDB.showmmb = not NeuronGDB.showmmb
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

		if (not CDB.fix07312012 and key == "actionID") then
			data.actionID = false
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

function NEURON:Animate()
	if (GDB.animate) then
		GDB.animate = false
	else
		GDB.animate = true
	end

end


local function is_valid_spec_id(id, num_specs)
	return id and id > 0 and id <= num_specs
end


local function get_profile()
	local char_name = UnitName("player")
	local realm_name = GetRealmName()
	local char_and_realm_name = string.format("%s - %s", char_name, realm_name)

	local profile_key = _G.NeuronProfilesDB.profileKeys[char_and_realm_name]
	local profile = _G.NeuronProfilesDB.profiles[profile_key]

	return profile
end


function  NEURON:MoveSpecButtons(msg)
	local num_specs = GetNumSpecializations()
	local spec_1_id, spec_2_id = msg:match("^(%d+)%s+(%d+)")
	spec_1_id = tonumber(spec_1_id)
	spec_2_id = tonumber(spec_2_id)

	if (not is_valid_spec_id(spec_1_id, num_specs)
			or not is_valid_spec_id(spec_2_id, num_specs)) then

		return print(string.format("%s <spec 1 id> <spec 2 id>", "/neuron MoveSpecButtons"))
	end

	local char_db = _G.NeuronCDB
	local profile = get_profile(profile_name)

	for idx, val in ipairs(char_db['buttons']) do
		val[spec_2_id] = val[spec_1_id]
	end

	_G.NeuronCDB = char_db
	profile.NeuronCDB = char_db
	print("Buttons for layout "..spec_1_id.." copied to layout "..spec_2_id)
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

	if (PEW) then

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
	if (PEW) then
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

	if (NEURON.BarsShown)then
		NeuronMinimapButton:SetFrameStrata("TOOLTIP")
		NeuronMinimapButton:SetFrameLevel(MinimapCluster:GetFrameLevel()+3)
	else
		NeuronMinimapButton:SetFrameStrata(MinimapCluster:GetFrameStrata())
		NeuronMinimapButton:SetFrameLevel(MinimapCluster:GetFrameLevel()+3)
	end
end


function NEURON:ToggleButtonGrid(show, hide)
	for id,btn in pairs(BTNIndex) do
		btn[1]:SetGrid(show, hide)
	end
end




function NEURON:ToggleMainMenu(show, hide)
	if (not IsAddOnLoaded("Neuron-GUI")) then
		LoadAddOn("Neuron-GUI")
	end
	--[[
        if ((NeuronMainMenu:IsVisible() or hide) and not show) then
            NeuronMainMenu:Hide()
        else
            NeuronMainMenu:Show()
        end
        ]]--
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
			list = L.VALIDSTATES..v
		else
			list = list..", "..v
		end
	end

	print(list..L.CUSTOM_OPTION)
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

	print(L.BARTYPES_USAGE)
	print(L.BARTYPES_TYPES)

	for k,v in ipairs(data) do
		if (type(v) == "table") then
			print("       |cff00ff00"..v[1].."|r: "..format(L.BARTYPES_LINE, v[2]))
		end
	end

end


function NEURON:RegisterBarClass(class, ...)

	NEURON.ModuleIndex = NEURON.ModuleIndex + 1

	NEURON.RegisteredBarData[class] = {
		barType = select(1,...):gsub("%s+", ""),
		barLabel = select(1,...),
		barReverse = select(11,...),
		barCreateMore = select(15,...),
		GDB = select(3,...),
		CDB = select(4,...),
		gDef = select(13,...),
		cDef = select(14,...),
		objTable = select(5,...),
		objGDB = select(6,...),
		objPrefix = "Neuron"..select(2,...):gsub("%s+", ""),
		objFrameT = select(7,...),
		objTemplate = select(8,...),
		objMetaT = select(9,...),
		objType = select(2,...),
		objMax = select(10,...),
		objStorage = select(12,...),
		createMsg = NEURON.ModuleIndex..select(2,...),
	}
end


function NEURON:RegisterGUIOptions(class, ...)
	NEURON.RegisteredGUIData[class] = {
		chkOpt = select(1,...),
		stateOpt = select(2,...),
		adjOpt = select(3,...),
	}
end


function NEURON:SetTimerLimit(msg)
	local limit = tonumber(msg:match("%d+"))

	if (limit and limit > 0) then
		GDB.timerLimit = limit
		print(format(L.TIMERLIMIT_SET, GDB.timerLimit))
	else
		print(L.TIMERLIMIT_INVALID)
	end
end


local function runUpdater(self, elapsed)

	self.elapsed = elapsed

	if (self.elapsed > 0) then

		NEURON:UpdateSpellIndex()
		NEURON:UpdateStanceStrings()

		self:Hide()
	end
end

local updater = CreateFrame("Frame", nil, UIParent)
updater:SetScript("OnUpdate", runUpdater)
updater.elapsed = 0
updater:Hide()

local function control_OnEvent(self, event, ...)
	NEURON.CurrEvent = event

	if (event == "PLAYER_REGEN_DISABLED") then

		if (NEURON.EditFrameShown) then
			NEURON:ToggleEditFrames(nil, true)
		end

		if (NEURON.BindingMode) then
			NEURON:ToggleBindings(nil, true)
		end

		if (NEURON.BarsShown) then
			NEURON:ToggleBars(nil, true)
		end

	elseif (event == "ADDON_LOADED" and ... == "Neuron") then
		NEURON.MAS = Neuron.MANAGED_ACTION_STATES
		NEURON.MBS = Neuron.MANAGED_BAR_STATES

		BAR = NEURON.BAR

		NEURON.player, NEURON.class, NEURON.level, NEURON.realm = UnitName("player"), select(2, UnitClass("player")), UnitLevel("player"), GetRealmName()

		GDB = NeuronGDB; CDB = NeuronCDB; SPEC = NeuronSpec

		for k,v in pairs(defGDB) do
			if (GDB[k] == nil) then
				GDB[k] = v
			end
		end

		for k,v in pairs(defCDB) do
			if (CDB[k] == nil) then
				CDB[k] = v
			end
		end

		for k,v in pairs(defSPEC) do
			if (SPEC[k] == nil) then
				SPEC[k] = v
			end
		end

		NEURON:UpdateStanceStrings()

		GameMenuFrame:HookScript("OnShow", function(self)

			--if (NeuronMainMenu and NeuronMainMenu:IsShown()) then
			--HideUIPanel(self); NEURON:ToggleMainMenu(nil, true)
			--end

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

	elseif (event == "VARIABLES_LOADED") then

		InterfaceOptionsFrame:SetFrameStrata("HIGH")

	elseif (event == "PLAYER_LOGIN") then
		local function hideAlerts(frame)
			if (not GDB.mainbar) then
				frame:Hide()
			end
		end

		if (CompanionsMicroButtonAlert) then
			CompanionsMicroButtonAlert:HookScript("OnShow", hideAlerts)
		end

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then
		GDB.firstRun = false
		CDB.firstRun = false

		NEURON:UpdateSpellIndex()
		NEURON:UpdatePetSpellIndex()
		NEURON:UpdateStanceStrings()
		NEURON:UpdateCompanionData()
		NEURON:UpdateToyData()
		NEURON:UpdateIconIndex()
		--Fix for Titan causing the Main Bar to not be hidden
		if (IsAddOnLoaded("Titan")) then TitanUtils_AddonAdjust("MainMenuBar", true) end
		NEURON:ToggleBlizzBar(GDB.mainbar)
		if not GDB.showmmb then
			NeuronMinimapButton:Hide()
		end

		CDB.fix07312012 = true

		PEW = true

		if (GDB.updateWarning ~= latestVersionNum and GDB.updateWarning~=nil) then
			StaticPopup_Show("NEURON_UPDATE_WARNING")
		elseif(GDB.updateWarning==nil) then
			StaticPopup_Show("NEURON_INSTALL_MESSAGE")
		end

	elseif (event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_TALENT_UPDATE" or event == "PLAYER_LOGOUT" or event == "PLAYER_LEAVING_WORLD") then
		SPEC.cSpec = GetSpecialization()

	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED" or
			event == "LEARNED_SPELL_IN_TAB" or
			event == "CHARACTER_POINTS_CHANGED" or
			event == "SPELLS_CHANGED") then

		updater.elapsed = 0
		updater:Show()

	elseif (event == "PET_UI_CLOSE" or event == "COMPANION_LEARNED" or event == "COMPANION_UPDATE" or event =="PET_JOURNAL_LIST_UPDATE") then
		if not CollectionsJournal or not CollectionsJournal:IsShown() then NEURON:UpdateCompanionData()end
	elseif (event == "UNIT_PET" and ... == "player") then

		if (PEW) then
			NEURON:UpdatePetSpellIndex()
		end

	elseif (event == "UNIT_LEVEL" and ... == "player") then
		NEURON.level = UnitLevel("player")

	elseif ( event == "TOYS_UPDATED" )then

		if not ToyBox or not ToyBox:IsShown() then NEURON:UpdateToyData() end
	end

end

local frame = CreateFrame("Frame", "NeuronControl", UIParent)

frame.elapsed = 0
frame:SetScript("OnEvent", control_OnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frame:RegisterEvent("SPELLS_CHANGED")
frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
frame:RegisterEvent("CURSOR_UPDATE")
frame:RegisterEvent("PET_UI_CLOSE")
frame:RegisterEvent("COMPANION_LEARNED")
frame:RegisterEvent("COMPANION_UPDATE")
frame:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
frame:RegisterEvent("UNIT_LEVEL")
frame:RegisterEvent("UNIT_PET")
--Needed to check to hide the garrison button
frame:RegisterUnitEvent("UNIT_AURA", "player")
frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
frame:RegisterEvent("SPELL_UPDATE_USABLE")
frame:RegisterEvent("SPELL_UPDATE_CHARGES")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
frame:RegisterEvent("TOYS_UPDATED")


frame = CreateFrame("GameTooltip", "NeuronTooltipScan", UIParent, "GameTooltipTemplate")
frame:SetOwner(UIParent, "ANCHOR_NONE")
frame:SetFrameStrata("TOOLTIP")
frame:Hide()


StaticPopupDialogs["ReloadUI"] = {
	text = "ReloadUI",
	button1 = "Yes",
	OnAccept = function()
		ReloadUI()
	end,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}


function NeuronProfile:RefreshConfig()
	NeuronCDB = self.db.profile["NeuronCDB"]
	NeuronGDB = self.db.profile["NeuronGDB"]
	NeuronSpec = {cSpec = GetSpecialization()}
	defGDB, GDB, defCDB, CDB, defSPEC, SPEC = CopyTable(NeuronGDB), CopyTable(NeuronGDB), CopyTable(NeuronCDB), CopyTable(NeuronCDB), CopyTable(NeuronSpec), CopyTable(NeuronSpec)
	NEURONButtonProfileUpdate()
	--IONBarProfileUpdate()
	StaticPopup_Show("ReloadUI")
end




function NeuronProfile:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("NeuronProfilesDB", defaults)
	LibStub("AceConfigRegistry-3.0"):ValidateOptionsTable(options, addonName)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options)

	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	self.db.RegisterCallback(self, "OnDatabaseReset", "RefreshConfig")

	--Check to see if character has stored bars/buttons that need to be imported to profile
	if not NeuronProfilesDB["Saved"] then
		NeuronProfilesDB["Saved"] = CopyTable(NeuronGDB)
	end

	if not self.db.char.firstrun then
		self.db.profile["NeuronCDB"] = CopyTable(NeuronCDB)
		self.db.profile["NeuronGDB"] = CopyTable(NeuronProfilesDB["Saved"])

		self.db.char.firstrun = true
	end
	--if not GDB.firstRun and not CDB.firstRun then

	--defaults.profile["NeuronSpec"] = CopyTable(NeuronSpec)
	NeuronCDB = self.db.profile["NeuronCDB"]
	NeuronGDB = self.db.profile["NeuronGDB"]
	NeuronSpec = self.db.profile["NeuronSpec"]

	defGDB, GDB, defCDB, CDB, defSPEC, SPEC = CopyTable(NeuronGDB), CopyTable(NeuronGDB), CopyTable(NeuronCDB), CopyTable(NeuronCDB), CopyTable(NeuronSpec), CopyTable(NeuronSpec)
end