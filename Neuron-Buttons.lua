--Neuron, a World of Warcraft® user interface addon.


local NEURON = Neuron
local DB, player, realm

NEURON.NeuronButton = NEURON:NewModule("Button", "AceEvent-3.0", "AceHook-3.0")
local NeuronButton = NEURON.NeuronButton

local BTNIndex, SKINIndex = NEURON.BTNIndex, NEURON.SKINIndex

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local SKIN = LibStub("Masque", true)

local MacroDrag = NEURON.MacroDrag
local StartDrag = NEURON.StartDrag

local sIndex = NEURON.sIndex  --Spell index
local cIndex = NEURON.cIndex  --Battle pet & Mount index
local iIndex = NEURON.iIndex  --Items Index
local tIndex = NEURON.tIndex  --Toys Index

local ItemCache

local cmdSlash

local macroCache = {}


local configData = {
	btnType = "macro",

	mouseAnchor = false,
	clickAnchor = false,
	anchorDelay = false,
	anchoredBar = false,

	upClicks = true,
	downClicks = false,
	copyDrag = false,
	muteSFX = false,
	clearerrors= false,
	cooldownAlpha = 1,

	bindText = true,
	bindColor = "1;1;1;1",

	countText = true,
	spellCounts = false,
	comboCounts = false,
	countColor = "1;1;1;1",

	macroText = true,
	macroColor = "1;1;1;1",

	cdText = false,
	cdcolor1 = "1;0.82;0;1",
	cdcolor2 = "1;0.1;0.1;1",

	auraText = false,
	auracolor1 = "0;0.82;0;1",
	auracolor2 = "1;0.1;0.1;1",

	auraInd = false,
	buffcolor = "0;0.8;0;1",
	debuffcolor = "0.8;0;0;1",

	rangeInd = true,
	rangecolor = "0.7;0.15;0.15;1",

	skincolor = "1;1;1;1",
	hovercolor = "0.1;0.1;1;1",
	equipcolor = "0.1;1;0.1;1",

	scale = 1,
	alpha = 1,
	XOffset = 0,
	YOffset = 0,
	HHitBox = 0,
	VHitBox = 0,
}


local keyData = {
	hotKeys = ":",
	hotKeyText = ":",
	hotKeyLock = false,
	hotKeyPri = false,
}


local keyDefaults = {
	[1] = { hotKeys = ":1:", hotKeyText = ":1:" },
	[2] = { hotKeys = ":2:", hotKeyText = ":2:" },
	[3] = { hotKeys = ":3:", hotKeyText = ":3:" },
	[4] = { hotKeys = ":4:", hotKeyText = ":4:" },
	[5] = { hotKeys = ":5:", hotKeyText = ":5:" },
	[6] = { hotKeys = ":6:", hotKeyText = ":6:" },
	[7] = { hotKeys = ":7:", hotKeyText = ":7:" },
	[8] = { hotKeys = ":8:", hotKeyText = ":8:" },
	[9] = { hotKeys = ":9:", hotKeyText = ":9:" },
	[10] = { hotKeys = ":0:", hotKeyText = ":0:" },
	[11] = { hotKeys = ":-:", hotKeyText = ":-:" },
	[12] = { hotKeys = ":=:", hotKeyText = ":=:" },
}


local stateData = {
	actionID = false,

	macro_Text = "",
	macro_Icon = false,
	macro_Name = "",
	macro_Auto = false,
	macro_Watch = false,
	macro_Equip = false,
	macro_Note = "",
	macro_UseNote = false,
}


NEURON.SpecialActions = { vehicle = "Interface\\AddOns\\Neuron\\Images\\new_vehicle_exit", possess = "Interface\\Icons\\Spell_Shadow_SacrificialShield", taxi = "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up",}

local SpecialActions = NEURON.SpecialActions

NEURON.PetActions = {
	petattack = { "Interface\\Icons\\Ability_GhoulFrenzy", L["Attack"], { 0, 1, 0, 1 }, "/petattack" },
	petfollow = { "Interface\\Icons\\Ability_Tracking", L["Follow"], { 0, 1, 0, 1 }, "/petfollow" },
	petmoveto = { "Interface\\Icons\\Ability_Hunter_Pet_Goto", L["Move To"], { 0, 1, 0, 1 }, "/petmoveto" },
	petassist = { "Interface\\Icons\\Ability_Hunter_Pet_Assist", L["Assist"], { 0, 1, 0, 1 }, "/petassist" },
	petdefensive = { "Interface\\Icons\\Ability_Defend", L["Defensive"], { 0, 1, 0, 1 }, "/petdefensive" },
	petpassive = { "Interface\\Icons\\Ability_Seal", L["Passive"], { 0, 1, 0, 1 }, "/petpassive" },
}

--local PetActions = NEURON.PetActions


--Spells that need their primary spell name overwritten
local AlternateSpellNameList = {
	[883] = true, --CallPet1
	[83242] = true, --CallPet2
	[83243] = true,  --CallPet3
	[83244] = true,  --CallPet4
	[83245] = true,  --CallPet5
}

local unitAuras = { player = {}, target = {}, focus = {} }

local alphaTimer, alphaDir = 0, 0

local autoCast = { speeds = { 2, 4, 6, 8 }, timers = { 0, 0, 0, 0 }, circle = { 0, 22, 44, 66 }, shines = {}, r = 0.95, g = 0.95, b = 0.32 }

local cooldowns, cdAlphas = {}, {}


local CurrentMountSpellID


NEURON.BUTTON = setmetatable({}, {__index = CreateFrame("CheckButton")}) --this is the metatable for our button object
local BUTTON = NEURON.BUTTON

-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronButton:OnInitialize()
	DB = NEURON.db.profile

	ItemCache = NeuronItemCache

	cmdSlash = {
		[SLASH_CAST1] = true,
		[SLASH_CAST2] = true,
		[SLASH_CAST3] = true,
		[SLASH_CAST4] = true,
		[SLASH_CASTRANDOM1] = true,
		[SLASH_CASTRANDOM2] = true,
		[SLASH_CASTSEQUENCE1] = true,
		[SLASH_CASTSEQUENCE2] = true,
		[SLASH_EQUIP1] = true,
		[SLASH_EQUIP2] = true,
		[SLASH_EQUIP3] = true,
		[SLASH_EQUIP4] = true,
		[SLASH_EQUIP_TO_SLOT1] = true,
		[SLASH_EQUIP_TO_SLOT2] = true,
		[SLASH_USE1] = true,
		[SLASH_USE2] = true,
		[SLASH_USERANDOM1] = true,
		[SLASH_USERANDOM2] = true,
		["/cast"] = true,
		["/castrandom"] = true,
		["/castsequence"] = true,
		["/spell"] = true,
		["/equip"] = true,
		["/eq"] = true,
		["/equipslot"] = true,
		["/use"] = true,
		["/userandom"] = true,
		["/summonpet"] = true,
		["/click"] = true,
	}

	if (SKIN) then
		SKIN:Register("Neuron", NeuronButton:SKINCallback(self, SKIN), true)
	end

	----------------------------------------------------------------
	BUTTON.SetData = NeuronButton.SetData
	BUTTON.LoadData = NeuronButton.LoadData
	BUTTON.SaveData = NeuronButton.SaveData
	BUTTON.SetAux = NeuronButton.SetAux
	BUTTON.LoadAux = NeuronButton.LoadAux
	BUTTON.SetObjectVisibility = NeuronButton.SetObjectVisibility
	BUTTON.SetDefaults = NeuronButton.SetDefaults
	BUTTON.GetDefaults = NeuronButton.GetDefaults
	BUTTON.SetType = NeuronButton.SetType
	BUTTON.GetSkinned = NeuronButton.GetSkinned
	BUTTON.SetSkinned = NeuronButton.SetSkinned
	----------------------------------------------------------------

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronButton:OnEnable()

	NeuronButton:RegisterEvent("PLAYER_TARGET_CHANGED")
	NeuronButton:RegisterEvent("ACTIONBAR_SHOWGRID")
	NeuronButton:RegisterEvent("UNIT_AURA")
	NeuronButton:RegisterEvent("UNIT_SPELLCAST_SENT")
	NeuronButton:RegisterEvent("UNIT_SPELLCAST_START")
	NeuronButton:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	NeuronButton:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")

	for k in pairs(unitAuras) do
		NeuronButton:updateAuraInfo(k)
	end

	---these two hooks are to call a function to check if we dragged an ability off the bar or not
	NeuronButton:SecureHookScript(WorldFrame, "OnMouseDown")


	NeuronButton:SecureHook("ToggleCollectionsJournal")


end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronButton:OnDisable()

end


------------------------------------------------------------------------------

function NeuronButton:PLAYER_TARGET_CHANGED()
	for k in pairs(unitAuras) do
		NeuronButton:updateAuraInfo(k)
	end
end

function NeuronButton:ACTIONBAR_SHOWGRID()
	StartDrag = true
end

function NeuronButton:UNIT_AURA(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		NeuronButton:updateAuraInfo(select(1,...))
	end
end

function NeuronButton:UNIT_SPELLCAST_SENT(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		NeuronButton:updateAuraInfo(select(1,...))
	end
end

function NeuronButton:UNIT_SPELLCAST_START(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		NeuronButton:updateAuraInfo(select(1,...))
	end
end

function NeuronButton:UNIT_SPELLCAST_SUCCEEDED(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		NeuronButton:updateAuraInfo(select(1,...))
	end
end

function NeuronButton:UNIT_SPELLCAST_CHANNEL_START(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		NeuronButton:updateAuraInfo(select(1,...))
	end
end

function NeuronButton:UNIT_SPELLCAST_SUCCEEDED(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		NeuronButton:updateAuraInfo(select(1,...))
	end
end


-------------------------------------------------------------------------------

------------------------------------------------------------
--------------------Intermediate Functions------------------
------------------------------------------------------------




function NeuronButton:AutoCastStart(shine, r, g, b)
	autoCast.shines[shine] = shine

	if (not r) then
		r, g, b = autoCast.r, autoCast.g, autoCast.b
	end

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Show(); sparkle:SetVertexColor(r, g, b)
	end
end


function NeuronButton:AutoCastStop(shine)
	autoCast.shines[shine] = nil

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Hide()
	end
end


--this function gets called via controlOnUpdate in the main Neuron.lua
---this function controlls the sparkley effects around abilities, if throttled then those effects are throttled down super slow. Be careful.
function NeuronButton:controlOnUpdate(frame, elapsed)
	local cou_distance, cou_radius, cou_timer, cou_speed, cou_degree, cou_x, cou_y, cou_position

	for i in next,autoCast.timers do
		autoCast.timers[i] = autoCast.timers[i] + elapsed

		if ( autoCast.timers[i] > autoCast.speeds[i]*4 ) then
			autoCast.timers[i] = 0
		end
	end

	for i in next,autoCast.circle do
		autoCast.circle[i] = autoCast.circle[i] - i

		if ( autoCast.circle[i] < 0 ) then
			autoCast.circle[i] = 359
		end
	end

	for shine in next, autoCast.shines do
		cou_distance, cou_radius = shine:GetWidth(), shine:GetWidth()/2.7
		for i=1,4 do
			cou_timer, cou_speed, cou_degree = autoCast.timers[i], autoCast.speeds[i], autoCast.circle[i]

			if ( cou_timer <= cou_speed ) then
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree-90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree-90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree-180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree-180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree-270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree-270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = cou_timer/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
				end

			elseif (cou_timer <= cou_speed*2) then
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = (cou_timer-cou_speed)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
				end

			elseif (cou_timer <= cou_speed*3) then
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = (cou_timer-cou_speed*2)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
				end
			else
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = (cou_timer-cou_speed*3)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
				end
			end
		end
	end

	alphaTimer = alphaTimer + elapsed * 2.5

	if (alphaDir == 1) then
		if (1-alphaTimer <= 0) then
			alphaDir = 0; alphaTimer = 0
		end

	else
		if (alphaTimer >= 1) then
			alphaDir = 1; alphaTimer = 0
		end
	end
end

--this function gets called via controlOnUpdate in the main Neuron.lua
function NeuronButton:cooldownsOnUpdate(frame, elapsed)
	local coolDown, formatted, size

	for cd in next,cooldowns do

		coolDown = floor(cd.duration-(GetTime()-cd.start))
		formatted, size = coolDown, cd.button:GetWidth()*0.45

		if (coolDown < 1) then
			if (coolDown < 0) then
				cooldowns[cd] = nil

				cd.timer:Hide()
				cd.timer:SetText("")
				cd.timerCD = nil
				cd.expirecolor = nil
				cd.cdsize = nil
				cd.active = nil
				cd.expiry = nil

			elseif (coolDown >= 0) then
				cd.timer:SetAlpha(cd.duration-(GetTime()-cd.start))

				if (cd.alphafade) then
					cd:SetAlpha(cd.duration-(GetTime()-cd.start))
				end
			end

		elseif (cd.timer:IsShown() and coolDown ~= cd.timerCD) then
			if (coolDown >= 86400) then
				formatted = math.ceil(coolDown/86400)
				formatted = formatted.."d"; size = cd.button:GetWidth()*0.3
			elseif (coolDown >= 3600) then
				formatted = math.ceil(coolDown/3600)
				formatted = formatted.."h"; size = cd.button:GetWidth()*0.3
			elseif (coolDown >= 60) then
				formatted = math.ceil(coolDown/60)
				formatted = formatted.."m"; size = cd.button:GetWidth()*0.3
			elseif (coolDown < 6) then
				size = cd.button:GetWidth()*0.6
				if (cd.expirecolor) then
					cd.timer:SetTextColor(cd.expirecolor[1], cd.expirecolor[2], cd.expirecolor[3]); cd.expirecolor = nil
					cd.expiry = true
				end
			end

			if (not cd.cdsize or cd.cdsize ~= size) then
				cd.timer:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE"); cd.cdsize = size
			end

			cd.timerCD = coolDown
			cd.timer:SetAlpha(1)
			cd.timer:SetText(formatted)
		end
	end

	for cd in next,cdAlphas do
		coolDown = ceil(cd.duration-(GetTime()-cd.start))

		if (coolDown < 1) then
			cdAlphas[cd] = nil
			cd.button:SetAlpha(1)
			cd.alphaOn = nil

		elseif (not cd.alphaOn) then
			cd.button:SetAlpha(cd.button.cdAlpha)
			cd.alphaOn = true
		end
	end
end

function NeuronButton:updateAuraInfo(unit)

	local uai_index, uai_spell, uai_count, uai_duration, uai_timeLeft, uai_caster, uai_spellID, _
	uai_index = 1

	wipe(unitAuras[unit])

	repeat
		uai_spell, _, uai_count, _, uai_duration, uai_timeLeft, uai_caster, _, _, uai_spellID = UnitAura(unit, uai_index, "HELPFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			unitAuras[unit][uai_spell:lower()] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			unitAuras[unit][uai_spell:lower().."()"] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)

	uai_index = 1

	repeat
		uai_spell, _, uai_count, _, uai_duration, uai_timeLeft, uai_caster = UnitAura(unit, uai_index, "HARMFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			unitAuras[unit][uai_spell:lower()] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			unitAuras[unit][uai_spell:lower().."()"] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)
end


---TODO: This no longer works in BfA
--[[function NeuronButton:isActiveShapeshiftSpell(spell)

	local shapeshift = spell:match("^[^(]+")
	local texture, isActive

	if (shapeshift) then
		for i=1, GetNumShapeshiftForms() do
			texture, isActive = GetShapeshiftFormInfo(i)
			if (isActive) then
				return texture
			end
		end
	end
end]]



function NeuronButton:SetTimer(cd, start, duration, enable, timer, color1, color2, cdAlpha)
	if ( start and start > 0 and duration > 0 and enable > 0) then
		cd:SetAlpha(1)
		CooldownFrame_Set(cd, start, duration, enable)
		--CooldownFrame_SetTimer(cd, start, duration, enable)

		if (duration >= DB.timerLimit) then
			cd.duration = duration
			cd.start = start
			cd.active = true

			if (timer) then
				cd.timer:Show()
				if (not cd.expiry) then
					cd.timer:SetTextColor(color1[1], color1[2], color1[3])
				end
				cd.expirecolor = color2
			end

			cooldowns[cd] = true

			if (cdAlpha) then
				cdAlphas[cd] = true
			end

		elseif (cooldowns[cd]) then
			cd.duration = 1
		end

	else
		cd.duration = 0; cd.start = 0;
		CooldownFrame_Set(cd, 0, 0, 0)
	end
end


function NeuronButton:MACRO_HasAction(button)
	local hasAction = button.data.macro_Text

	if (button.actionID) then
		if (button.actionID == 0) then
			return true
		else
			return HasAction(button.actionID)
		end

	elseif (hasAction and #hasAction>0) then
		return true
	else
		return false
	end
end


function NeuronButton:MACRO_GetDragAction()
	return "macro"
end


function NeuronButton:MACRO_UpdateData(button, ...)

	local ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_cd, ud_cdcmd, ud_aura, ud_auracmd, ud_item, ud_target, ud__


	if (button.macroparse) then
		ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_cd, ud_cdcmd, ud_aura, ud_auracmd, ud_item, ud_target, ud__ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil

		for cmd, options in gmatch(button.macroparse, "(%c%p%a+)(%C+)") do
			--after gmatch, remove unneeded characters
			if (cmd) then cmd = cmd:gsub("^%c+", "") end
			if (options) then options = options:gsub("^%s+", "") end

			--find #ud_show option!
			if (not ud_show and cmd:find("^#show")) then
				ud_show = SecureCmdOptionParse(options); ud_showcmd = cmd
				--sometimes SecureCmdOptionParse will return "" since that is not what we want, keep looking
			elseif (ud_show and #ud_show < 1 and cmd:find("^#show")) then
				ud_show = SecureCmdOptionParse(options); ud_showcmd = cmd
			end

			--find #cdwatch option!
			if (not ud_cd and cmd:find("^#cdwatch")) then
				ud_cd = SecureCmdOptionParse(options); ud_cdcmd = cmd
			elseif (ud_cd and #ud_cd < 1 and cmd:find("^#cdwatch")) then
				ud_cd = SecureCmdOptionParse(options); ud_cdcmd = cmd
			end

			--find #aurawatch option!
			if (not ud_aura and cmd:find("^#aurawatch")) then
				ud_aura = SecureCmdOptionParse(options); ud_auracmd = cmd
			elseif (ud_aura and #ud_aura < 1 and cmd:find("^#aurawatch")) then
				ud_aura = SecureCmdOptionParse(options); ud_auracmd = cmd
			end

			--find the ud_spell!
			if (not ud_spell and cmdSlash[cmd]) then
				ud_spell, ud_target = SecureCmdOptionParse(options); ud_spellcmd = cmd
			elseif (ud_spell and #ud_spell < 1) then
				ud_spell, ud_target = SecureCmdOptionParse(options); ud_spellcmd = cmd
			end
		end

		if (ud_spell and ud_spellcmd:find("/castsequence")) then

			ud__, ud_item, ud_spell = QueryCastSequence(ud_spell)

		elseif (ud_spell) then

			if (#ud_spell < 1) then
				ud_spell = nil

			elseif(ItemCache[ud_spell]) then

				ud_item = ud_spell
				ud_spell = nil


			elseif(tonumber(ud_spell) and GetInventoryItemLink("player", ud_spell)) then
				ud_item = GetInventoryItemLink("player", ud_spell)
				ud_spell = nil
			end
		end

		button.unit = ud_target or "target"

		if (ud_spell) then
			button.macroitem = nil
			if (ud_spell ~= button.macrospell) then

				ud_spell = ud_spell:gsub("!", "")
				button.macrospell = ud_spell

				if (sIndex[ud_spell:lower()]) then
					button.spellID = sIndex[ud_spell:lower()].spellID
				else
					button.spellID = nil
				end
			end
		else
			button.macrospell = nil; button.spellID = nil
		end

		if (ud_show and ud_showcmd:find("#showicon")) then
			if (ud_show ~= button.macroicon) then
				if(tonumber(ud_show) and GetInventoryItemLink("player", ud_show)) then
					ud_show = GetInventoryItemLink("player", ud_show)
				end
				button.macroicon = ud_show
				button.macroshow = nil
			end
		elseif (ud_show) then
			if (ud_show ~= button.macroshow) then
				if(tonumber(ud_show) and GetInventoryItemLink("player", ud_show)) then
					ud_show = GetInventoryItemLink("player", ud_show)
				end
				button.macroshow = ud_show
				button.macroicon = nil
			end
		else
			button.macroshow = nil
			button.macroicon = nil
		end

		if (ud_cd) then
			if (ud_cd ~= button.macrocd) then
				if(tonumber(ud_aura) and GetInventoryItemLink("player", ud_cd)) then
					ud_aura = GetInventoryItemLink("player", ud_cd)
				end
				button.macrocd = ud_aura
			end
		else
			button.macrocd = nil
		end

		if (ud_aura) then
			if (ud_aura ~= button.macroaura) then
				if(tonumber(ud_aura) and GetInventoryItemLink("player", ud_aura)) then
					ud_aura = GetInventoryItemLink("player", ud_aura)
				end
				button.macroaura = ud_aura
			end
		else
			button.macroaura = nil
		end

		if (ud_item) then
			button.macrospell = nil;
			button.spellID = nil
			if (ud_item ~= button.macroitem) then
				button.macroitem = ud_item
			end
		else
			button.macroitem = nil
		end
	end
end


function NeuronButton:MACRO_SetSpellIcon(button, spell)
	local _, texture

	if (not button.data.macro_Watch and not button.data.macro_Equip) then

		spell = (spell):lower()
		if (sIndex[spell]) then
			local spell_id = sIndex[spell].spellID
			texture = GetSpellTexture(spell_id)

		elseif (cIndex[spell]) then
			texture = cIndex[spell].icon

		elseif (spell) then
			texture = GetSpellTexture(spell)
		end

		if (texture) then
			button.iconframeicon:SetTexture(texture)
			button.iconframeicon:Show()
		else
			--button.iconframeicon:SetTexture("")
			--button.iconframeicon:Hide()
			button.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") --show questionmark instead of empty button to avoid confusion
		end

	else
		if (button.data.macro_Watch) then

			_, texture = GetMacroInfo(button.data.macro_Watch)

			button.data.macro_Icon = texture

		end

		if (texture) then
			button.iconframeicon:SetTexture(texture)
			button.iconframeicon:Show()
		else
			button.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end
	end

	return texture
end


function NeuronButton:MACRO_SetItemIcon(button, item)
	local _,texture, link, itemID

	if (IsEquippedItem(item)) then --makes the border green when item is equipped and dragged to a button
		button.border:SetVertexColor(0, 1.0, 0, 0.2)
		button.border:Show()
	else
		button.border:Hide()
	end

	--There is stored icon and dont want to update icon on fly
	if (((type(button.data.macro_Icon) == "string" and #button.data.macro_Icon > 0) or type(button.data.macro_Icon) == "number")) then
		if (button.data.macro_Icon == "BLANK") then
			button.iconframeicon:SetTexture("")
		else
			button.iconframeicon:SetTexture(button.data.macro_Icon)
		end

	else
		if (ItemCache[item]) then
			texture = GetItemIcon("item:"..ItemCache[item]..":0:0:0:0:0:0:0")
		else
			_,_,_,_,_,_,_,_,_,texture = GetItemInfo(item)
		end

		if (texture) then
			button.iconframeicon:SetTexture(texture)
		else
			button.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end
	end

	button.iconframeicon:Show()

	return button.iconframeicon:GetTexture()
end


function NeuronButton:ACTION_SetIcon(button, action)
	local actionID = tonumber(action)

	if (actionID) then
		if (actionID == 0) then
			if (button.specAction and SpecialActions[button.specAction]) then
				button.iconframeicon:SetTexture(SpecialActions[button.specAction])
			else
				button.iconframeicon:SetTexture(0,0,0)
			end

		else
			button.macroname:SetText(GetActionText(actionID))
			if (HasAction(actionID)) then
				button.iconframeicon:SetTexture(GetActionTexture(actionID))
			else
				button.iconframeicon:SetTexture(0,0,0)
			end
		end

		button.iconframeicon:Show()
	else
		button.iconframeicon:SetTexture("")
		button.iconframeicon:Hide()
	end

	return button.iconframeicon:GetTexture()
end


function NeuronButton:MACRO_UpdateIcon(button, ...)
	button.updateMacroIcon = nil
	button.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")

	local spell, item, show, texture = button.macrospell, button.macroitem, button.macroshow, button.macroicon

	if (button.actionID) then
		texture = NeuronButton:ACTION_SetIcon(button, button.actionID)
	elseif (show and #show>0) then
		if(ItemCache[show]) then
			texture = NeuronButton:MACRO_SetItemIcon(button, show)
		else
			texture = NeuronButton:MACRO_SetSpellIcon(button, show)
			NeuronButton:MACRO_SetSpellState(button, show)
		end

	elseif (spell and #spell>0) then
		texture = NeuronButton:MACRO_SetSpellIcon(button, spell)
		NeuronButton:MACRO_SetSpellState(button, spell)
	elseif (item and #item>0) then
		texture = NeuronButton:MACRO_SetItemIcon(button, item)

	elseif (button.data.macro_Icon) then
		button.iconframeicon:SetTexture(button.data.macro_Icon)
		button.iconframeicon:Show()
	else
		button.macroname:SetText("")
		button.iconframeicon:SetTexture("")
		button.iconframeicon:Hide()
		button.border:Hide()
	end


	--druid fix for thrash glow not showing for feral druids.
	--Thrash Guardian: 77758
	--Thrash Feral: 106832
	--But the joint thrash is 106830 (this is the one that results true when the ability is procced)

	--Swipe(Bear): 213771
	--Swipe(Cat): 106785
	--Swipe(NoForm): 213764

	if (button.spellID and IsSpellOverlayed(button.spellID)) then
		NeuronButton:MACRO_StartGlow(button)
	elseif (spell == "Thrash()" and IsSpellOverlayed(106830)) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
		NeuronButton:MACRO_StartGlow(button)
	elseif (spell == "Swipe()" and IsSpellOverlayed(106785)) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
		NeuronButton:MACRO_StartGlow(button)
	elseif (button.glowing) then
		NeuronButton:MACRO_StopGlow(button)
	end

	return texture
end


function NeuronButton:MACRO_StartGlow(button)

	if (button.spellGlowDef) then
		ActionButton_ShowOverlayGlow(button)
	elseif (button.spellGlowAlt) then
		NeuronButton:AutoCastStart(button.shine)
	end

	button.glowing = true
end


function NeuronButton:MACRO_StopGlow(button)
	if (button.spellGlowDef) then
		ActionButton_HideOverlayGlow(button)
	elseif (button.spellGlowAlt) then
		NeuronButton:AutoCastStop(button.shine)
	end

	button.glowing = nil
end


function NeuronButton:MACRO_SetSpellState(button, spell)
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spell)
	if (maxCharges and maxCharges > 1) then
		button.count:SetText(charges)
	else
		button.count:SetText("")
	end

	local count = GetSpellCount(spell)
	if (count and count > 0) then
		button.count:SetText(count)
	end

	if (cIndex[spell:lower()]) then
		spell = cIndex[spell:lower()].spellID

		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell)) then
			button:SetChecked(1)
		else
			button:SetChecked(nil)
		end
	else
		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell)) then --or NeuronButton:isActiveShapeshiftSpell(spell:lower())) then
			button:SetChecked(1)
		else
			button:SetChecked(nil)
		end
	end

	if ((IsAttackSpell(spell) and IsCurrentSpell(spell)) or IsAutoRepeatSpell(spell)) then
		button.mac_flash = true
	else
		button.mac_flash = false
	end

	button.macroname:SetText(button.data.macro_Name)
end


function NeuronButton:MACRO_SetItemState(button, item)

	if (GetItemCount(item,nil,true) and  GetItemCount(item,nil,true) > 1) then
		button.count:SetText(GetItemCount(item,nil,true))
	else
		button.count:SetText("")
	end

	if(IsCurrentItem(item)) then
		button:SetChecked(1)
	else
		button:SetChecked(nil)
	end
	button.macroname:SetText(button.data.macro_Name)
end

function NeuronButton:ACTION_UpdateState(button, action)
	local actionID = tonumber(action)

	button.count:SetText("")

	if (actionID) then
		button.macroname:SetText("")

		if (IsCurrentAction(actionID) or IsAutoRepeatAction(actionID)) then
			button:SetChecked(1)
		else
			button:SetChecked(nil)
		end

		if ((IsAttackAction(actionID) and IsCurrentAction(actionID)) or IsAutoRepeatAction(actionID)) then
			button.mac_flash = true
		else
			button.mac_flash = false
		end
	else
		button:SetChecked(nil)
		button.mac_flash = false
	end
end


function NeuronButton:MACRO_UpdateState(button, ...)

	local spell, item, show = button.macrospell, button.macroitem, button.macroshow


	if (button.actionID) then
		NeuronButton:ACTION_UpdateState(button, button.actionID)

	elseif (show and #show>0) then

		if (ItemCache[show]) then
			NeuronButton:MACRO_SetItemState(button, show)
		else
			NeuronButton:MACRO_SetSpellState(button, show)
		end

	elseif (spell and #spell>0) then

		NeuronButton:MACRO_SetSpellState(button, spell)

	elseif (item and #item>0) then

		NeuronButton:MACRO_SetItemState(button, item)

	elseif (button:GetAttribute("macroShow")) then

		show = button:GetAttribute("macroShow")

		if (ItemCache[show]) then
			NeuronButton:MACRO_SetItemState(button, show)
		else
			NeuronButton:MACRO_SetSpellState(button, show)
		end
	else
		button:SetChecked(nil)
		button.count:SetText("")
	end
end



function NeuronButton:MACRO_UpdateAuraWatch(button, unit, spell)

	local uaw_auraType, uaw_duration, uaw_timeLeft, uaw_count, uaw_color

	if (spell and (unit == button.unit or unit == "player")) then
		spell = spell:gsub("%s*%(.+%)", ""):lower()

		if (unitAuras[unit][spell]) then
			uaw_auraType, uaw_duration, uaw_timeLeft, uaw_count = (":"):split(unitAuras[unit][spell])

			uaw_duration = tonumber(uaw_duration)
			uaw_timeLeft = tonumber(uaw_timeLeft)

			if (button.auraInd) then
				button.auraBorder = true

				if (uaw_auraType == "buff") then
					button.border:SetVertexColor(button.buffcolor[1], button.buffcolor[2], button.buffcolor[3], 1.0)
				elseif (uaw_auraType == "debuff" and unit == "target") then
					button.border:SetVertexColor(button.debuffcolor[1], button.debuffcolor[2], button.debuffcolor[3], 1.0)
				end

				button.border:Show()
			else
				button.border:Hide()
			end

			uaw_color = button.auracolor1

			if (button.auraText) then

				if (uaw_auraType == "debuff" and (unit == "target" or (unit == "focus" and UnitIsEnemy("player", "focus")))) then
					uaw_color = button.auracolor2
				end

				button.iconframeaurawatch.queueinfo = unit..":"..spell
			else

			end

			if (button.iconframecooldown.timer:IsShown()) then
				button.auraQueue = unit..":"..spell
				button.iconframeaurawatch.uaw_duration = 0
				button.iconframeaurawatch:Hide()

			elseif (button.auraText) then
				NeuronButton:SetTimer(button.iconframecooldown, 0, 0, 0)
				NeuronButton:SetTimer(button.iconframeaurawatch, uaw_timeLeft-uaw_duration, uaw_duration, 1, button.auraText, uaw_color)
			else
				NeuronButton:SetTimer(button.iconframeaurawatch, 0, 0, 0)
			end

			button.auraWatchUnit = unit

		elseif (button.auraWatchUnit == unit) then

			button.iconframeaurawatch.uaw_duration = 0
			button.iconframeaurawatch:Hide()
			button.iconframeaurawatch.timer:SetText("")
			button.border:Hide()
			button.auraBorder = nil
			button.auraWatchUnit = nil
			button.auraTimer = nil
			button.auraQueue = nil
		end
	end
end

function NeuronButton:MACRO_SetSpellCooldown(button, spell)
	spell = (spell):lower()
	local spell_id = spell

	if (sIndex[spell]) then
		spell_id = sIndex[spell].spellID
		local ZoneAbilityID = ZoneAbilityFrame.SpellButton.currentSpellID
		local GarrisonAbilityID = 161691

		--Needs work
		if (spell_id == GarrisonAbilityID and ZoneAbilityID) then spell_id = ZoneAbilityID end
	end

	local start, duration, enable = GetSpellCooldown(spell)
	local charges, maxCharges, chStart, chDuration = GetSpellCharges(spell)
	start, duration, enable = GetSpellCooldown(spell)

	if (duration and duration >= DB.timerLimit and button.iconframeaurawatch.active) then
		button.auraQueue = button.iconframeaurawatch.queueinfo
		button.iconframeaurawatch.duration = 0
		button.iconframeaurawatch:Hide()
	end

	if (charges and maxCharges and maxCharges > 0 and charges < maxCharges) then
		StartChargeCooldown(button, chStart, chDuration);
	end

	NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
end

function NeuronButton:MACRO_SetItemCooldown(button, item)

	local id = ItemCache[item]

	if (id) then

		local start, duration, enable = GetItemCooldown(id)

		if (duration and duration >= DB.timerLimit and button.iconframeaurawatch.active) then
			button.auraQueue = button.iconframeaurawatch.queueinfo
			button.iconframeaurawatch.duration = 0
			button.iconframeaurawatch:Hide()
		end

		NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
	end
end

function NeuronButton:ACTION_SetCooldown(button, action)

	local actionID = tonumber(action)

	if (actionID) then

		if (HasAction(actionID)) then

			local start, duration, enable = GetActionCooldown(actionID)

			if (duration and duration >= DB.timerLimit and button.iconframeaurawatch.active) then
				button.auraQueue = button.iconframeaurawatch.queueinfo
				button.iconframeaurawatch.duration = 0
				button.iconframeaurawatch:Hide()
			end

			NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
		end
	end
end


function NeuronButton:MACRO_UpdateCooldown(button, update)
	local spell, item, show = button.macrospell, button.macroitem, button.macroshow

	if (button.actionID) then
		NeuronButton:ACTION_SetCooldown(button, button.actionID)
	elseif (show and #show>0) then
		if (ItemCache[show]) then
			NeuronButton:MACRO_SetItemCooldown(button, show)
		else
			NeuronButton:MACRO_SetSpellCooldown(button, show)
		end

	elseif (spell and #spell>0) then
		NeuronButton:MACRO_SetSpellCooldown(button, spell)
	elseif (item and #item>0) then
		NeuronButton:MACRO_SetItemCooldown(button, item)
	else
		NeuronButton:SetTimer(button.iconframecooldown, 0, 0, 0, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
	end
end

function NeuronButton:MACRO_UpdateTimers(button, ...)
	NeuronButton:MACRO_UpdateCooldown(button)

	for k in pairs(unitAuras) do
		NeuronButton:MACRO_UpdateAuraWatch(button, k, button.macrospell)
	end
end


function NeuronButton:MACRO_UpdateTexture(button, force)
	local hasAction = NeuronButton:MACRO_HasAction(button)

	if (not button:GetSkinned(button)) then
		if (hasAction or force) then
			button:SetNormalTexture(button.hasAction or "")
			button:GetNormalTexture():SetVertexColor(1,1,1,1)
		else
			button:SetNormalTexture(button.noAction or "")
			button:GetNormalTexture():SetVertexColor(1,1,1,0.5)
		end
	end
end


function NeuronButton:MACRO_UpdateAll(button, updateTexture)
	NeuronButton:MACRO_UpdateData(button)
	NeuronButton:MACRO_UpdateButton(button)
	NeuronButton:MACRO_UpdateIcon(button)
	NeuronButton:MACRO_UpdateState(button)
	NeuronButton:MACRO_UpdateTimers(button)

	if (updateTexture) then
		NeuronButton:MACRO_UpdateTexture(button)
	end
end


--local garrisonAbility = GetSpellInfo(161691):lower()
function NeuronButton:MACRO_UpdateUsableSpell(button, spell)
	local isUsable, notEnoughMana, alt_Name
	local spellName = spell:lower()

	if (sIndex[spellName]) and (sIndex[spellName].spellID ~= sIndex[spellName].spellID_Alt) and sIndex[spellName].spellID_Alt then
		alt_Name = GetSpellInfo(sIndex[spellName].spellID_Alt):lower()
		isUsable, notEnoughMana = IsUsableSpell(alt_Name)
		spellName = alt_Name
	else
		isUsable, notEnoughMana = IsUsableSpell(spellName)
	end

	if (spellName == GetSpellInfo(161691):lower()) then
	end

	if (notEnoughMana) then
		button.iconframeicon:SetVertexColor(button.manacolor[1], button.manacolor[2], button.manacolor[3])
		--button.iconframerange:SetVertexColor(button.manacolor[1], button.manacolor[2], button.manacolor[3], 0.5)
		--button.iconframerange:Show()
	elseif (isUsable) then
		if (button.rangeInd and IsSpellInRange(spellName, button.unit) == 0) then
			button.iconframeicon:SetVertexColor(button.rangecolor[1], button.rangecolor[2], button.rangecolor[3])
			--button.iconframerange:SetVertexColor(button.rangecolor[1], button.rangecolor[2], button.rangecolor[3], 0.5)
			--button.iconframerange:Show()
		elseif sIndex[spellName] and (button.rangeInd and IsSpellInRange(sIndex[spellName].index,"spell", button.unit) == 0) then
			button.iconframeicon:SetVertexColor(button.rangecolor[1], button.rangecolor[2], button.rangecolor[3])
		else
			button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
			--button.iconframerange:Hide()
		end

	else
		if (sIndex[(spell):lower()]) then
			button.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
			--button.iconframerange:SetVertexColor(0.4, 0.4, 0.4, 0.5)
			--button.iconframerange:Show()
		else
			button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
			--button.iconframerange:Hide()
		end
	end
end


function NeuronButton:MACRO_UpdateUsableItem(button, item)
	local isUsable, notEnoughMana = IsUsableItem(item)-- or PlayerHasToy(ItemCache[item])
	--local isToy = tIndex[item]
	if tIndex[item:lower()] then isUsable = true end

	if (notEnoughMana and button.manacolor) then
		button.iconframeicon:SetVertexColor(button.manacolor[1], button.manacolor[2], button.manacolor[3])
	elseif (isUsable) then
		if (button.rangeInd and IsItemInRange(spell, button.unit) == 0) then
			button.iconframeicon:SetVertexColor(button.rangecolor[1], button.rangecolor[2], button.rangecolor[3])
		else
			button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end

	else
		button.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end


function NeuronButton:ACTION_UpdateUsable(button, action)
	local actionID = tonumber(action)

	if (actionID) then
		if (actionID == 0) then
			button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		else
			local isUsable, notEnoughMana = IsUsableAction(actionID)

			if (isUsable) then
				if (IsActionInRange(action, button.unit) == 0) then
					button.iconframeicon:SetVertexColor(button.rangecolor[1], button.rangecolor[2], button.rangecolor[3])
				else
					button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
				end

			elseif (notEnoughMana and button.manacolor) then
				button.iconframeicon:SetVertexColor(button.manacolor[1], button.manacolor[2], button.manacolor[3])
			else
				button.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end

	else
		button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end


function NeuronButton:MACRO_UpdateButton(button, ...)

	if (button.editmode) then

		button.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)

	elseif (button.actionID) then

		NeuronButton:ACTION_UpdateUsable(button, button.actionID)

	elseif (button.macroshow and #button.macroshow>0) then

		if(ItemCache[button.macroshow]) then
			NeuronButton:MACRO_UpdateUsableItem(button, button.macroshow)
		else
			NeuronButton:MACRO_UpdateUsableSpell(button, button.macroshow)
		end

	elseif (button.macrospell and #button.macrospell>0) then

		NeuronButton:MACRO_UpdateUsableSpell(button, button.macrospell)

	elseif (button.macroitem and #button.macroitem>0) then

		NeuronButton:MACRO_UpdateUsableItem(button, button.macroitem)

	else
		button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end

---TODO:
---We need to figure out what this function did.
---Update: Seems to be important for range indication (i.e. button going red)
function NeuronButton:MACRO_OnUpdate(button, elapsed) --this function uses A TON of resources

	if (button.elapsed > DB.throttle) then --throttle down this code to ease up on the CPU a bit

		if (button.mac_flash) then

			button.mac_flashing = true

			if (alphaDir == 1) then
				if ((1 - (alphaTimer)) >= 0) then
					button.iconframeflash:Show()
				end
			elseif (alphaDir == 0) then
				if ((alphaTimer) <= 1) then
					button.iconframeflash:Hide()
				end
			end

		elseif (button.mac_flashing) then
			button.iconframeflash:Hide()
			button.mac_flashing = false
		end

		NeuronButton:MACRO_UpdateButton(button)


		if (button.auraQueue and not button.iconframecooldown.active) then
			local unit, spell = (":"):split(button.auraQueue)
			if (unit and spell) then
				button.auraQueue = nil;
				NeuronButton:MACRO_UpdateAuraWatch(button, unit, spell)
			end
		end

		button.elapsed = 0
	end

	button.elapsed = button.elapsed + elapsed

end


function NeuronButton:MACRO_ShowGrid(button)
	if (not InCombatLockdown()) then
		button:Show()
	end

	NeuronButton:MACRO_UpdateState(button)
end


function NeuronButton:MACRO_HideGrid(button)
	if (not InCombatLockdown()) then

		if not button.showGrid and not NeuronButton:MACRO_HasAction(button) and (not NEURON.ButtonEditMode or not NEURON.BarEditMode or not NEURON.BindingMode) then
			button:Hide()
		end
	end

	NeuronButton:MACRO_UpdateState(button)
end

------------------------------------------------------------------------------
---------------------Event Functions------------------------------------------
------------------------------------------------------------------------------

--I'm not sure why all these are here, they don't seem to be used

function NeuronButton:MACRO_ACTIONBAR_UPDATE_COOLDOWN(button, ...)
	NeuronButton:MACRO_UpdateTimers(button, ...)
end

--pointer
NeuronButton.MACRO_RUNE_POWER_UPDATE = NeuronButton.MACRO_ACTIONBAR_UPDATE_COOLDOWN


function NeuronButton:MACRO_ACTIONBAR_UPDATE_STATE(button, ...)
	NeuronButton:MACRO_UpdateState(button, ...)
end

--pointers
NeuronButton.MACRO_COMPANION_UPDATE = NeuronButton.MACRO_ACTIONBAR_UPDATE_STATE
NeuronButton.MACRO_TRADE_SKILL_SHOW = NeuronButton.MACRO_ACTIONBAR_UPDATE_STATE
NeuronButton.MACRO_TRADE_SKILL_CLOSE = NeuronButton.MACRO_ACTIONBAR_UPDATE_STATE
NeuronButton.MACRO_ARCHAEOLOGY_CLOSED = NeuronButton.MACRO_ACTIONBAR_UPDATE_STATE


function NeuronButton:MACRO_ACTIONBAR_UPDATE_USABLE(button, ...)
	-- TODO
end



function NeuronButton:MACRO_BAG_UPDATE_COOLDOWN(button, ...)

	if (button.macroitem) then
		NeuronButton:MACRO_UpdateState(button, ...)
	end
end


NeuronButton.MACRO_BAG_UPDATE = NeuronButton.MACRO_BAG_UPDATE_COOLDOWN


function NeuronButton:MACRO_UNIT_AURA(button, ...)
	local unit = select(1, ...)

	if (unitAuras[unit]) then
		NeuronButton:MACRO_UpdateAuraWatch(button, unit, button.macrospell)

		if (unit == "player") then
			NeuronButton:MACRO_UpdateData(button, ...)
			NeuronButton:MACRO_UpdateIcon(button, ...)
		end
	end
end


NeuronButton.MACRO_UPDATE_MOUSEOVER_UNIT = NeuronButton.MACRO_UNIT_AURA


function NeuronButton:MACRO_UNIT_SPELLCAST_INTERRUPTED(button, ...)

	local unit = select(1, ...)

	if ((unit == "player" or unit == "pet") and spell and button.macrospell) then

		NeuronButton:MACRO_UpdateTimers(button, ...)
	end

end


NeuronButton.MACRO_UNIT_SPELLCAST_FAILED = NeuronButton.MACRO_UNIT_SPELLCAST_INTERRUPTED
NeuronButton.MACRO_UNIT_PET = NeuronButton.MACRO_UNIT_SPELLCAST_INTERRUPTED
NeuronButton.MACRO_UNIT_ENTERED_VEHICLE = NeuronButton.MACRO_UNIT_SPELLCAST_INTERRUPTED
NeuronButton.MACRO_UNIT_ENTERING_VEHICLE = NeuronButton.MACRO_UNIT_SPELLCAST_INTERRUPTED
NeuronButton.MACRO_UNIT_EXITED_VEHICLE = NeuronButton.MACRO_UNIT_SPELLCAST_INTERRUPTED


function NeuronButton:MACRO_SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(button, ...)
	local spellID = select(2, ...)

	if (button.spellGlow and button.spellID and spellID == button.spellID) then

		NeuronButton:MACRO_UpdateTimers(button, ...)

		NeuronButton:MACRO_StartGlow(button)
	end
end


function NeuronButton:MACRO_SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(button, ...)
	local spellID = select(2, ...)

	if ((button.overlay or button.spellGlow) and button.spellID and spellID == button.spellID) then

		NeuronButton:MACRO_StopGlow(button)
	end
end


function NeuronButton:MACRO_ACTIVE_TALENT_GROUP_CHANGED(button, ...)

	if(InCombatLockdown()) then
		return
	end

	local spec

	if (button.multiSpec) then
		spec = GetSpecialization()
	else
		spec = 1
	end

	button:Show()

	button:LoadData(button, spec, button:GetParent():GetAttribute("activestate") or "homestate")
	NEURON.NeuronFlyouts:UpdateFlyout(button)
	button:SetType(button)
	button:SetObjectVisibility(button)

end


function NeuronButton:MACRO_PLAYER_ENTERING_WORLD(button, ...)

	NeuronButton:MACRO_Reset(button)
	NeuronButton:MACRO_UpdateAll(button, true)
	NEURON.NeuronBinder:ApplyBindings(button)
end

---super broken with 8.0
--[[function NeuronButton:MACRO_PET_JOURNAL_LIST_UPDATE(button, ...)
	NeuronButton:MACRO_UpdateAll(button, true)
end]]


function NeuronButton:MACRO_MODIFIER_STATE_CHANGED(button, ...)
	NeuronButton:MACRO_UpdateAll(button, true)
end


NeuronButton.MACRO_SPELL_UPDATE_USABLE = NeuronButton.MACRO_MODIFIER_STATE_CHANGED


function NeuronButton:MACRO_ACTIONBAR_SLOT_CHANGED(button, ...)
	if (button.data.macro_Watch or button.data.macro_Equip) then
		NeuronButton:MACRO_UpdateIcon(button)
	end
end


function NeuronButton:MACRO_PLAYER_TARGET_CHANGED(button, ...)
	NeuronButton:MACRO_UpdateTimers(button)
end


NeuronButton.MACRO_PLAYER_FOCUS_CHANGED = NeuronButton.MACRO_PLAYER_TARGET_CHANGED

function NeuronButton:MACRO_ITEM_LOCK_CHANGED(button, ...)
end


function NeuronButton:MACRO_ACTIONBAR_SHOWGRID(button, ...)
	NeuronButton:MACRO_ShowGrid(button)
end


function NeuronButton:MACRO_ACTIONBAR_HIDEGRID(button, ...)
	NeuronButton:MACRO_HideGrid(button)
end


function NeuronButton:MACRO_UPDATE_MACROS(button, ...)
	if (NEURON.PEW and not InCombatLockdown() and button.data.macro_Watch) then
		NeuronButton:MACRO_PlaceBlizzMacro(button, button.data.macro_Watch)
	end
end


function NeuronButton:MACRO_EQUIPMENT_SETS_CHANGED(button, ...)
	if (NEURON.PEW and not InCombatLockdown() and button.data.macro_Equip) then
		NeuronButton:MACRO_PlaceBlizzEquipSet(button, button.data.macro_Equip)
	end
end


function NeuronButton:MACRO_PLAYER_EQUIPMENT_CHANGED(button, ...)
	if (button.data.macro_Equip) then
		NeuronButton:MACRO_UpdateIcon(button)
	end
end


function NeuronButton:MACRO_UPDATE_VEHICLE_ACTIONBAR(button, ...)

	if (button.actionID) then
		NeuronButton:MACRO_UpdateAll(button, true)
	end
end

NeuronButton.MACRO_UPDATE_POSSESS_BAR = NeuronButton.MACRO_UPDATE_VEHICLE_ACTIONBAR
NeuronButton.MACRO_UPDATE_OVERRIDE_ACTIONBAR = NeuronButton.MACRO_UPDATE_VEHICLE_ACTIONBAR

--for 4.x compatibility
NeuronButton.MACRO_UPDATE_BONUS_ACTIONBAR = NeuronButton.MACRO_UPDATE_VEHICLE_ACTIONBAR


function NeuronButton:MACRO_SPELL_UPDATE_CHARGES(button, ...)

	local spell = button.macrospell
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spell)

	if (maxCharges and maxCharges > 1) then
		button.count:SetText(charges)
	else
		button.count:SetText("")
	end
end


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

---This strips out the "MACRO_" in front of the event name function, and brokers the event to the right object
function NeuronButton:MACRO_OnEvent(button, eventName, ...)
	local event = "MACRO_".. eventName

	if (NeuronButton[event]) then
		NeuronButton[event](NeuronButton, button, ...)
	end
end


function NeuronButton:MACRO_PlaceSpell(button, action1, action2, spellID)
	local modifier, spell, texture, _

	if (action1 == 0) then
		-- I am unsure under what conditions (if any) we wouldn't have a spell ID
		if not spellID or spellID == 0 then
			return
		end
	else
		spell,_= GetSpellBookItemName(action1, action2)
		_,spellID = GetSpellBookItemInfo(action1, action2)
	end
	local spellInfoName , _, icon, castTime, minRange, maxRange= GetSpellInfo(spellID)

	if AlternateSpellNameList[spellID] or not spell then
		button.data.macro_Text = NeuronButton:AutoWriteMacro(button, spellInfoName)
		button.data.macro_Auto = spellInfoName..";"
	else
		button.data.macro_Text = NeuronButton:AutoWriteMacro(button, spell)

		button.data.macro_Auto = spell
	end

	button.data.macro_Icon = false
	button.data.macro_Name = spellInfoName
	button.data.macro_Watch = false
	button.data.macro_Equip = false
	button.data.macro_Note = ""
	button.data.macro_UseNote = false

	if (not button.cursor) then
		button:SetType(button, true)
	end

	MacroDrag[1] = false

	ClearCursor()
	SetCursor(nil)

end


function NeuronButton:MACRO_PlaceItem(button, action1, action2, hasAction)
	local item, link = GetItemInfo(action2)

	if link and not ItemCache[item] then --add the item to the itemcache if it isn't otherwise in it
		local _, itemID = link:match("(item:)(%d+)")
		ItemCache[item] = itemID
	end


	if (IsEquippableItem(item)) then
		button.data.macro_Text = "/equip "..item.."\n/use "..item
	else
		button.data.macro_Text = "/use "..item
	end

	button.data.macro_Icon = false
	button.data.macro_Name = item
	button.data.macro_Auto = false
	button.data.macro_Watch = false
	button.data.macro_Equip = false
	button.data.macro_Note = ""
	button.data.macro_UseNote = false

	if (not button.cursor) then
		button:SetType(button, true)
	end
	MacroDrag[1] = false
	ClearCursor()
	SetCursor(nil)
end


function NeuronButton:MACRO_PlaceBlizzMacro(button, action1)
	if (action1 == 0) then
		return
	else

		local name, icon, body = GetMacroInfo(action1)

		if (body) then

			button.data.macro_Text = body
			button.data.macro_Name = name
			button.data.macro_Watch = name
			button.data.macro_Icon = icon
		else
			button.data.macro_Text = ""
			button.data.macro_Name = ""
			button.data.macro_Watch = false
			button.data.macro_Icon = false
		end

		button.data.macro_Equip = false
		button.data.macro_Auto = false
		button.data.macro_Note = ""
		button.data.macro_UseNote = false

		if (not button.cursor) then
			button:SetType(button, true)
		end

		MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function NeuronButton:MACRO_PlaceBlizzEquipSet(button, equipmentSetName)
	if (equipmentSetName == 0) then
		return
	else

		local equipsetNameIndex = 0 ---cycle through the equipment sets to find the index of the one with the right name
		for i = 1,C_EquipmentSet.GetNumEquipmentSets() do
			if equipmentSetName == C_EquipmentSet.GetEquipmentSetInfo(i) then
				equipsetNameIndex = i end

		end


		local name, texture = C_EquipmentSet.GetEquipmentSetInfo(equipsetNameIndex)
		if (texture) then
			button.data.macro_Text = "/equipset "..equipmentSetName
			button.data.macro_Equip = equipmentSetName
			button.data.macro_Name = name
			button.data.macro_Icon = texture
		else
			button.data.macro_Text = ""
			button.data.macro_Equip = false
			button.data.macro_Name = ""
			button.data.macro_Icon = false
		end

		button.data.macro_Name = ""
		button.data.macro_Watch = false
		button.data.macro_Auto = false
		button.data.macro_Note = ""
		button.data.macro_UseNote = false

		if (not button.cursor) then
			button:SetType(button, true)
		end

		MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


--Hooks mount journal mount buttons on enter to pull spellid from tooltip--
--Based on discusion thread http://www.wowinterface.com/forums/showthread.php?t=49599&page=2
--More dynamic than the manual list that was originally implemente


function NeuronButton:ToggleCollectionsJournal()

	local MountButtonsHookIsSet

	if CollectionsJournal:IsShown() then
		if not MountButtonsHookIsSet then
			for i = 1, 20 do
				local bName = "MountJournalListScrollFrameButton"..i
				local f = _G[bName]
				if f then
					if f.DragButton then
						f.DragButton:HookScript("OnEnter", function(self) CurrentMountSpellID = self:GetParent().spellID end)
					end
				end
			end
			MountButtonsHookIsSet = true
		end
	end
end

function NeuronButton:MACRO_PlaceMount(button, action1, action2, hasAction)
	if (action1 == 0) then
		return
	else
		--The Summon Random Mount from the Mount Journal
		if action1 == 268435455 then
			button.data.macro_Text = "#autowrite\n/run C_MountJournal.SummonByID(0);"
			button.data.macro_Auto = "Random Mount;"
			button.data.macro_Icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_MOUNTUP"
			button.data.macro_Name = "Random Mount"
			--Any other mount from the Journal
		else

			local mountName,_, mountIcon = GetSpellInfo(CurrentMountSpellID)
			button.data.macro_Text = "#autowrite\n/cast "..mountName..";"
			button.data.macro_Auto = mountName..";"
			button.data.macro_Icon = mountIcon
			button.data.macro_Name = mountName
		end

		button.data.macro_Watch = false
		button.data.macro_Equip = false
		button.data.macro_Note = ""
		button.data.macro_UseNote = false

		if (not button.cursor) then
			button:SetType(button, true)
		end

		MacroDrag[1] = false
		CurrentMountSpellID = nil

		ClearCursor()
		SetCursor(nil)
	end
end


function NeuronButton:MACRO_PlaceCompanion(button, action1, action2, hasAction)
	if (action1 == 0) then
		return

	else
		local _, _, spellID = GetCompanionInfo(action2, action1)
		local name = GetSpellInfo(spellID)

		if (name) then
			button.data.macro_Name = name
			button.data.macro_Text = NeuronButton:AutoWriteMacro(button, name)
			button.data.macro_Auto = name
		else
			button.data.macro_Name = ""
			button.data.macro_Text = ""
			button.data.macro_Auto = false
		end

		button.data.macro_Icon = false
		button.data.macro_Watch = false
		button.data.macro_Equip = false
		button.data.macro_Note = ""
		button.data.macro_UseNote = false

		if (not button.cursor) then
			button:SetType(button, true)
		end

		MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function NeuronButton:MACRO_PlaceFlyout(button, action1, action2, hasAction)
	if (action1 == 0) then
		return
	else
		local count = button.bar.objCount
		local columns = button.bar.data.columns or count
		local rows = count/columns

		local point = NeuronButton:GetPosition(button, UIParent)

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

		button.data.macro_Text = "/flyout blizz:"..action1..":l:"..point..":c"
		button.data.macro_Icon = false
		button.data.macro_Name = ""
		button.data.macro_Auto = false
		button.data.macro_Watch = false
		button.data.macro_Equip = false
		button.data.macro_Note = ""
		button.data.macro_UseNote = false

		NEURON.NeuronFlyouts:UpdateFlyout(button, true)

		if (not button.cursor) then
			button:SetType(button, true)
		end

		MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function NeuronButton:MACRO_PlaceBattlePet(button, action1, action2, hasAction)
	local petName, petIcon
	local _ --variable used to discard unwanted return values

	if (action1 == 0) then
		return
	else
		_, _, _, _, _, _, _,petName, petIcon = C_PetJournal.GetPetInfoByPetID(action1)

		button.data.macro_Text = "#autowrite\n/summonpet "..petName
		button.data.macro_Auto = petName..";"
		button.data.macro_Icon = petIcon
		button.data.macro_Name = petName
		button.data.macro_Watch = false
		button.data.macro_Equip = false
		button.data.macro_Note = ""
		button.data.macro_UseNote = false

		if (not button.cursor) then
			button:SetType(button, true)
		end

		MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end

function NeuronButton:MACRO_PlaceMacro(button)
	button.data.macro_Text = MacroDrag[3]
	button.data.macro_Icon = MacroDrag[4]
	button.data.macro_Name = MacroDrag[5]
	button.data.macro_Auto = MacroDrag[6]
	button.data.macro_Watch = MacroDrag[7]
	button.data.macro_Equip = MacroDrag[8]
	button.data.macro_Note = MacroDrag[9]
	button.data.macro_UseNote = MacroDrag[10]

	if (not button.cursor) then
		button:SetType(button, true)
	end

	PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)

	wipe(MacroDrag);
	ClearCursor();
	SetCursor(nil);
	NEURON.NeuronFlyouts:UpdateFlyout(button)
	NEURON:ToggleButtonGrid(false)

end


function NeuronButton:MACRO_PickUpMacro(button)
	local pickup

	if (not button.barLock) then
		pickup = true
	elseif (button.barLockAlt and IsAltKeyDown()) then
		pickup = true
	elseif (button.barLockCtrl and IsControlKeyDown()) then
		pickup = true
	elseif (button.barLockShift and IsShiftKeyDown()) then
		pickup = true
	end

	if (pickup) then
		local texture, move = button.iconframeicon:GetTexture()

		if (macroCache[1]) then  ---triggers when picking up an existing button with a button in the cursor

			wipe(MacroDrag)

			for k,v in pairs(macroCache) do
				MacroDrag[k] = v
			end

			wipe(macroCache)

			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")


		elseif (NeuronButton:MACRO_HasAction(button)) then
			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")

			MacroDrag[1] = NeuronButton:MACRO_GetDragAction()
			MacroDrag[2] = button
			MacroDrag[3] = button.data.macro_Text
			MacroDrag[4] = button.data.macro_Icon
			MacroDrag[5] = button.data.macro_Name
			MacroDrag[6] = button.data.macro_Auto
			MacroDrag[7] = button.data.macro_Watch
			MacroDrag[8] = button.data.macro_Equip
			MacroDrag[9] = button.data.macro_Note
			MacroDrag[10] = button.data.macro_UseNote
			MacroDrag.texture = texture
			button.data.macro_Text = ""
			button.data.macro_Icon = false
			button.data.macro_Name = ""
			button.data.macro_Auto = false
			button.data.macro_Watch = false
			button.data.macro_Equip = false
			button.data.macro_Note = ""
			button.data.macro_UseNote = false

			button.macrospell = nil
			button.spellID = nil
			button.macroitem = nil
			button.macroshow = nil
			button.macroicon = nil

			NEURON.NeuronFlyouts:UpdateFlyout(button)

			button:SetType(button, true)

		end

	end
end

---This is the function that fires when a button is receiving a dragged item
function NeuronButton:MACRO_OnReceiveDrag(button, preclick)
	if (InCombatLockdown()) then
		return
	end

	local cursorType, action1, action2, spellID = GetCursorInfo()

	local texture = button.iconframeicon:GetTexture()

	if (NeuronButton:MACRO_HasAction(button)) then
		wipe(macroCache)

		---macroCache holds on to the previos macro's info if you are dropping a new macro on top of an existing macro
		macroCache[1] = NeuronButton:MACRO_GetDragAction()
		macroCache[2] = button
		macroCache[3] = button.data.macro_Text
		macroCache[4] = button.data.macro_Icon
		macroCache[5] = button.data.macro_Name
		macroCache[6] = button.data.macro_Auto
		macroCache[7] = button.data.macro_Watch
		macroCache[8] = button.data.macro_Equip
		macroCache[9] = button.data.macro_Note
		macroCache[10] = button.data.macro_UseNote

		macroCache.texture = texture
	end


	if (MacroDrag[1]) then
		NeuronButton:MACRO_PlaceMacro(button)
	elseif (cursorType == "spell") then
		NeuronButton:MACRO_PlaceSpell(button, action1, action2, spellID, NeuronButton:MACRO_HasAction(button))

	elseif (cursorType == "item") then
		NeuronButton:MACRO_PlaceItem(button, action1, action2, NeuronButton:MACRO_HasAction(button))

	elseif (cursorType == "macro") then
		NeuronButton:MACRO_PlaceBlizzMacro(button, action1)

	elseif (cursorType == "equipmentset") then
		NeuronButton:MACRO_PlaceBlizzEquipSet(button, action1)

	elseif (cursorType == "mount") then
		NeuronButton:MACRO_PlaceMount(button, action1, action2, NeuronButton:MACRO_HasAction(button))

	elseif (cursorType == "flyout") then
		NeuronButton:MACRO_PlaceFlyout(button, action1, action2, NeuronButton:MACRO_HasAction(button))

	elseif (cursorType == "battlepet") then
		NeuronButton:MACRO_PlaceBattlePet(button, action1, action2, NeuronButton:MACRO_HasAction(button))
	elseif (cursorType == "petaction") then
		NEURON:Print(L["Pet Actions can not be added to Neuron bars at this time."])
	end


	if (StartDrag and macroCache[1]) then
		NeuronButton:MACRO_PickUpMacro(button)
		NEURON:ToggleButtonGrid(true)
	end

	NeuronButton:MACRO_UpdateAll(button, true)

	StartDrag = false

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		NEURON.NeuronGUI:UpdateObjectGUI()
	end
end

---this is the function that fires when you begin dragging an item
function NeuronButton:MACRO_OnDragStart(button, mousebutton)

	if (InCombatLockdown() or not button.bar or button.vehicle_edit or button.actionID) then
		StartDrag = false
		return
	end

	button.drag = nil

	if (not button.barLock) then
		button.drag = true
	elseif (button.barLockAlt and IsAltKeyDown()) then
		button.drag = true
	elseif (button.barLockCtrl and IsControlKeyDown()) then
		button.drag = true
	elseif (button.barLockShift and IsShiftKeyDown()) then
		button.drag = true
	end

	if (button.drag) then
		StartDrag = button:GetParent():GetAttribute("activestate")

		button.dragbutton = mousebutton
		NeuronButton:MACRO_PickUpMacro(button)

		if (MacroDrag[1]) then
			--PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)

			if (MacroDrag[2] ~= button) then
				button.dragbutton = nil
			end

			NEURON:ToggleButtonGrid(true)
		else
			button.dragbutton = nil
		end

		NeuronButton:MACRO_UpdateAll(button)

		button.iconframecooldown.duration = 0
		button.iconframecooldown.timer:SetText("")
		button.iconframecooldown:Hide()

		button.iconframeaurawatch.duration = 0
		button.iconframeaurawatch.timer:SetText("")
		button.iconframeaurawatch:Hide()

		button.macroname:SetText("")
		button.count:SetText("")

		button.macrospell = nil
		button.spellID = nil
		button.actionID = nil
		button.macroitem = nil
		button.macroshow = nil
		button.macroicon = nil

		button.auraQueue = nil

		button.border:Hide()

	---shows all action bar buttons in the case you have show grid turned off


	else
		StartDrag = false
	end

end


function NeuronButton:MACRO_OnDragStop(button)
	button.drag = nil
end


---This function will be used to check if we should release the cursor
function NeuronButton:OnMouseDown()
	if MacroDrag[1] then
		PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)
		wipe(MacroDrag)
	end
end



function NeuronButton:MACRO_PreClick(button, mousebutton)
	button.cursor = nil

	if (not InCombatLockdown() and MouseIsOver(button)) then
		local cursorType = GetCursorInfo()

		if (cursorType or MacroDrag[1]) then
			button.cursor = true

			StartDrag = button:GetParent():GetAttribute("activestate")

			button:SetType(button, true, true)

			NEURON:ToggleButtonGrid(true)

			NeuronButton:MACRO_OnReceiveDrag(button, true)

		elseif (mousebutton == "MiddleButton") then
			button.middleclick = button:GetAttribute("type")

			button:SetAttribute("type", "")

		end
	end

	NEURON.ClickedButton = button
end


function NeuronButton:MACRO_PostClick(button, mousebutton)
	if (not InCombatLockdown() and MouseIsOver(button)) then

		if (button.cursor) then
			button:SetType(button, true)

			button.cursor = nil

		elseif (button.middleclick) then
			button:SetAttribute("type", button.middleclick)

			button.middleclick = nil
		end
	end
	NeuronButton:MACRO_UpdateState(button)
end


function NeuronButton:MACRO_SetSpellTooltip(button, spell)

	if (sIndex[spell]) then

		local spell_id = sIndex[spell].spellID

		if(spell_id) then --double check that the spell_id is valid (for switching specs, other specs abilities won't be valid even though a bar might be bound to one)

			local zoneability_id = ZoneAbilityFrame.SpellButton.currentSpellID

			if spell_id == 161691 and zoneability_id then
				spell_id = zoneability_id
			end


			if (button.UberTooltips) then
				GameTooltip:SetSpellByID(spell_id)
			else
				spell = GetSpellInfo(spell_id)
				GameTooltip:SetText(spell, 1, 1, 1)
			end

			button.UpdateTooltip = macroButton_SetTooltip
		end

	elseif (cIndex[spell]) then

		if (button.UberTooltips and cIndex[spell].creatureType =="MOUNT") then
			GameTooltip:SetHyperlink("spell:"..cIndex[spell].spellID)
		else
			GameTooltip:SetText(cIndex[spell].creatureName, 1, 1, 1)
		end

		button.UpdateTooltip = nil
	end
end


function NeuronButton:MACRO_SetItemTooltip(button, item)
	local name, link = GetItemInfo(item)

	if (tIndex[item:lower()]) then
		if (button.UberTooltips) then
			local itemID = tIndex[item:lower()]
			GameTooltip:ClearLines()
			GameTooltip:SetToyByItemID(itemID)
		else
			GameTooltip:SetText(name, 1, 1, 1)
		end

	elseif (link) then
		if (button.UberTooltips) then
			GameTooltip:SetHyperlink(link)
		else
			GameTooltip:SetText(name, 1, 1, 1)
		end

	elseif (ItemCache[item]) then
		if (button.UberTooltips) then
			GameTooltip:SetHyperlink("item:"..ItemCache[item]..":0:0:0:0:0:0:0")
		else
			GameTooltip:SetText(ItemCache[item], 1, 1, 1)
		end
	end
end


function NeuronButton:ACTION_SetTooltip(button, action)
	local actionID = tonumber(action)

	if (actionID) then

		button.UpdateTooltip = nil

		if (HasAction(actionID)) then
			GameTooltip:SetAction(actionID)
		end
	end
end


function NeuronButton:MACRO_SetTooltip(button, edit)
	button.UpdateTooltip = nil

	local spell, item, show = button.macrospell, button.macroitem, button.macroshow

	if (button.actionID) then
		NeuronButton:ACTION_SetTooltip(button, button.actionID)

	elseif (show and #show>0) then
		if(ItemCache[show]) then
			NeuronButton:MACRO_SetItemTooltip(button, show)
		else
			NeuronButton:MACRO_SetSpellTooltip(button, show:lower())
		end

	elseif (spell and #spell>0) then
		NeuronButton:MACRO_SetSpellTooltip(button, spell:lower())

	elseif (item and #item>0) then
		NeuronButton:MACRO_SetItemTooltip(button, item)

	elseif (button:GetAttribute("macroShow")) then
		show = button:GetAttribute("macroShow")

		if(ItemCache[show]) then
			NeuronButton:MACRO_SetItemTooltip(button, show)
		else
			NeuronButton:MACRO_SetSpellTooltip(button, show:lower())
		end

	elseif (button.data.macro_Text and #button.data.macro_Text > 0) then
		local equipset = button.data.macro_Text:match("/equipset%s+(%C+)")

		if (equipset) then
			equipset = equipset:gsub("%pnobtn:2%p ", "")
			GameTooltip:SetEquipmentSet(equipset)
		elseif (button.data.macro_Name and #button.data.macro_Name>0) then
			GameTooltip:SetText(button.data.macro_Name)
		end
	end
end


function NeuronButton:MACRO_OnEnter(button, ...)
	if (button.bar) then
		if (button.tooltipsCombat and InCombatLockdown()) then
			return
		end

		if(MacroDrag[1]) then ---puts the icon back to the interact icon when moving abilities around and the mouse enteres the WorldFrame
			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")
		end

		if (button.tooltips) then
			if (button.tooltipsEnhanced) then
				button.UberTooltips = true
				GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			else
				button.UberTooltips = false
				GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			end

			NeuronButton:MACRO_SetTooltip(button)

			GameTooltip:Show()
		end

		if (button.flyout and button.flyout.arrow) then
			button.flyout.arrow:SetPoint(button.flyout.arrowPoint, button.flyout.arrowX/0.625, button.flyout.arrowY/0.625)
		end

	end
end


function NeuronButton:MACRO_OnLeave(button, ...)
	button.UpdateTooltip = nil

	GameTooltip:Hide()

	if (button.flyout and button.flyout.arrow) then
		button.flyout.arrow:SetPoint(button.flyout.arrowPoint, button.flyout.arrowX, button.flyout.arrowY)
	end
end


function NeuronButton:MACRO_OnShow(button, ...)
	button:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	button:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	button:RegisterEvent("ACTIONBAR_UPDATE_USABLE")

	button:RegisterEvent("SPELL_UPDATE_CHARGES")
	button:RegisterEvent("SPELL_UPDATE_USABLE")

	button:RegisterEvent("RUNE_POWER_UPDATE")

	button:RegisterEvent("TRADE_SKILL_SHOW")
	button:RegisterEvent("TRADE_SKILL_CLOSE")
	button:RegisterEvent("ARCHAEOLOGY_CLOSED")

	button:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

	button:RegisterEvent("MODIFIER_STATE_CHANGED")

	button:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	button:RegisterEvent("UNIT_SPELLCAST_FAILED")
	button:RegisterEvent("UNIT_PET")
	button:RegisterEvent("UNIT_AURA")
	button:RegisterEvent("UNIT_ENTERED_VEHICLE")
	button:RegisterEvent("UNIT_ENTERING_VEHICLE")
	button:RegisterEvent("UNIT_EXITED_VEHICLE")

	button:RegisterEvent("PLAYER_TARGET_CHANGED")
	button:RegisterEvent("PLAYER_FOCUS_CHANGED")
	button:RegisterEvent("PLAYER_REGEN_ENABLED")
	button:RegisterEvent("PLAYER_REGEN_DISABLED")
	button:RegisterEvent("PLAYER_ENTER_COMBAT")
	button:RegisterEvent("PLAYER_LEAVE_COMBAT")
	button:RegisterEvent("PLAYER_CONTROL_LOST")
	button:RegisterEvent("PLAYER_CONTROL_GAINED")
	button:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	button:RegisterEvent("UNIT_INVENTORY_CHANGED")
	button:RegisterEvent("BAG_UPDATE_COOLDOWN")
	button:RegisterEvent("BAG_UPDATE")
	button:RegisterEvent("COMPANION_UPDATE")
	button:RegisterEvent("PET_STABLE_UPDATE")
	button:RegisterEvent("PET_STABLE_SHOW")

	button:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	button:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

	button:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	button:RegisterEvent("UPDATE_POSSESS_BAR")
	button:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")

	--button:RegisterEvent("PET_JOURNAL_LIST_UPDATE")

end


function NeuronButton:MACRO_OnHide(button, ...)
	button:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
	button:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	button:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
	button:UnregisterEvent("ACTIONBAR_UPDATE_USABLE")

	button:UnregisterEvent("SPELL_UPDATE_CHARGES")
	button:UnregisterEvent("SPELL_UPDATE_USABLE")

	button:UnregisterEvent("RUNE_POWER_UPDATE")

	button:UnregisterEvent("TRADE_SKILL_SHOW")
	button:UnregisterEvent("TRADE_SKILL_CLOSE")
	button:UnregisterEvent("ARCHAEOLOGY_CLOSED")

	button:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")

	button:UnregisterEvent("MODIFIER_STATE_CHANGED")

	button:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	button:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	button:UnregisterEvent("UNIT_PET")
	button:UnregisterEvent("UNIT_AURA")
	button:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	button:UnregisterEvent("UNIT_ENTERING_VEHICLE")
	button:UnregisterEvent("UNIT_EXITED_VEHICLE")

	button:UnregisterEvent("PLAYER_TARGET_CHANGED")
	button:UnregisterEvent("PLAYER_FOCUS_CHANGED")
	button:UnregisterEvent("PLAYER_REGEN_ENABLED")
	button:UnregisterEvent("PLAYER_REGEN_DISABLED")
	button:UnregisterEvent("PLAYER_ENTER_COMBAT")
	button:UnregisterEvent("PLAYER_LEAVE_COMBAT")
	button:UnregisterEvent("PLAYER_CONTROL_LOST")
	button:UnregisterEvent("PLAYER_CONTROL_GAINED")
	button:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")

	button:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	button:UnregisterEvent("BAG_UPDATE_COOLDOWN")
	button:UnregisterEvent("BAG_UPDATE")
	button:UnregisterEvent("COMPANION_UPDATE")
	button:UnregisterEvent("PET_STABLE_UPDATE")
	button:UnregisterEvent("PET_STABLE_SHOW")

	button:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	button:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

	button:UnregisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	button:UnregisterEvent("UPDATE_POSSESS_BAR")
	button:UnregisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	button:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	--button:UnregisterEvent("PET_JOURNAL_LIST_UPDATE")

end


function NeuronButton:MACRO_OnAttributeChanged(button, name, value)

	if (value and button.data) then
		if (name == "activestate") then

			---Part 1 of Druid Prowl overwrite fix
			-----------------------------------------------------
			---breaks out of the loop due to flag set below
			if (NEURON.class == "DRUID" and button.ignoreNextOverrideStance == true and value == "homestate") then
				button.ignoreNextOverrideStance = nil
				NEURON.NeuronBar:SetState(button.bar, "stealth") --have to add this in otherwise the button icons change but still retain the homestate ability actions
				return
			else
				button.ignoreNextOverrideStance = nil
			end
			-----------------------------------------------------
			-----------------------------------------------------

			if (button:GetAttribute("HasActionID")) then
				button.actionID = button:GetAttribute("*action*")
			else

				if (not button.statedata) then
					button.statedata = { homestate = CopyTable(stateData) }
				end

				if (not button.statedata[value]) then
					button.statedata[value] = CopyTable(stateData)
				end

				---Part 2 of Druid Prowl overwrite fix
				---------------------------------------------------
				---druids have an issue where once stance will get immediately overwritten by another. I.E. stealth immediately getting overwritten by homestate if they go immediately into prowl from caster form
				---this conditional sets a flag to ignore the next most stance flag, as that one is most likely in error and should be ignored
				if(NEURON.class == "DRUID" and value == "stealth1") then
					button.ignoreNextOverrideStance = true
				end
				------------------------------------------------------
				------------------------------------------------------


				button.data = button.statedata[value]

				NeuronButton:MACRO_UpdateParse(button)

				NeuronButton:MACRO_Reset(button)

				button.actionID = false
			end
			--This will remove any old button state data from the saved varabiels/memory
			--for id,data in pairs(button.bar.data) do
			for id,data in pairs(button.statedata) do
				if (button.bar.data[id:match("%a+")]) or (id == "" and button.bar.data["custom"])  then
				elseif not button.bar.data[id:match("%a+")] then
					button.statedata[id]= nil
				end
			end

			button.specAction = button:GetAttribute("SpecialAction") --?
			NeuronButton:MACRO_UpdateAll(button, true)
		end

		if (name == "update") then
			NeuronButton:MACRO_UpdateAll(button, true)
		end
	end


end


function NeuronButton:MACRO_build()
	local button = CopyTable(stateData)
	return button
end


function NeuronButton:MACRO_Reset(button)
	button.macrospell = nil
	button.spellID = nil
	button.macroitem = nil
	button.macroshow = nil
	button.macroicon = nil
end


function NeuronButton:MACRO_UpdateParse(button)
	button.macroparse = button.data.macro_Text

	if (#button.macroparse > 0) then
		button.macroparse = "\n"..button.macroparse.."\n"
		button.macroparse = (button.macroparse):gsub("(%c+)", " %1")
	else
		button.macroparse = nil
	end
end


function NeuronButton:SetSkinned(button, flyout)
	if (SKIN) then
		local bar = button.bar

		if (bar) then
			local btnData = {
				Normal = button.normaltexture,
				Icon = button.iconframeicon,
				Cooldown = button.iconframecooldown,
				HotKey = button.hotkey,
				Count = button.count,
				Name = button.name,
				Border = button.border,
				AutoCast = false,
			}

			if (flyout) then
				SKIN:Group("Neuron", button.anchor.bar.data.name):AddButton(button, btnData)
			else
				SKIN:Group("Neuron", bar.data.name):AddButton(button, btnData)
			end

			button.skinned = true

			SKINIndex[button] = true
		end
	end
end


function NeuronButton:GetSkinned(button)
	if (button.__MSQ_NormalTexture) then
		local Skin = button.__MSQ_NormalSkin

		if (Skin) then
			button.hasAction = Skin.Texture or false
			button.noAction = Skin.EmptyTexture or false

			if (button.__MSQ_Shape) then
				button.shape = button.__MSQ_Shape:lower()
			else
				button.shape = "square"
			end
		else
			button.hasAction = false
			button.noAction = false
			button.shape = "square"
		end

		button.shine.shape = button.shape

		return true
	else
		button.hasAction = "Interface\\Buttons\\UI-Quickslot2"
		button.noAction = "Interface\\Buttons\\UI-Quickslot"

		return false
	end
end


function NeuronButton:CreateNewObject(class, id, firstRun)
	local data = NEURON.RegisteredBarData[class]

	if (data) then

		--this is the same as 'id', I'm not sure why we need both
		local index = #data.objTable + 1 --sets the current index to 1 greater than the current number of object in the table

		local object = CreateFrame(data.objFrameT, data.objPrefix..id, UIParent, data.objTemplate)

		setmetatable(object, data.objMetaT)

		object.elapsed = 0

		--returns a table of the names of all the child objects for a given frame
		local objects = NEURON:GetParentKeys(object)

		--I think this is creating a pointer inside the object to where the child object resides in the global namespace
		for k,v in pairs(objects) do
			local name = (v):gsub(object:GetName(), "")
			object[name:lower()] = _G[v]
		end

		object.class = class
		object.id = id
		object:SetID(0)
		object.objTIndex = index
		object.objType = data.objType:gsub("%s", ""):upper()
		object:LoadData(object, GetActiveSpecGroup(), "homestate")

		if (firstRun) then
			object:SetDefaults(object, object:GetDefaults(object))
		end

		object:LoadAux(object)

		data.objTable[index] = object

		return object
	end
end


function NeuronButton:ChangeObject(object)

	if not NEURON.CurrentObject then
		NEURON.CurrentObject = object
	end

	local newObj, newEditor = false, false

	if (NEURON.PEW) then

		if (object and object ~= NEURON.CurrentObject) then

			if (NEURON.CurrentObject and NEURON.CurrentObject.editor.editType ~= object.editor.editType) then
				newEditor = true
			end

			if (NEURON.CurrentObject and NEURON.CurrentObject.bar ~= object.bar) then

				local bar = NEURON.CurrentObject.bar

				if (bar.handler:GetAttribute("assertstate")) then
					bar.handler:SetAttribute("state-"..bar.handler:GetAttribute("assertstate"), bar.handler:GetAttribute("activestate") or "homestate")
				end

				object.bar.handler:SetAttribute("fauxstate", bar.handler:GetAttribute("activestate"))

			end

			NEURON.CurrentObject = object

			object.editor.select:Show()

			object.selected = true
			object.action = nil

			newObj = true
		end

		if (not object) then
			NEURON.CurrentObject = nil
		end

		for k,v in pairs(NEURON.EDITIndex) do
			if (not object or v ~= object.editor) then
				v.select:Hide()
			end
		end
	end

	return newObj, newEditor
end


function NeuronButton:UpdateObjectSpec(bar)
	local object, spec

	--for objID in gmatch(bar.data.objectList, "[^;]+") do
	for i, objID in ipairs(bar.data.objectList) do
		object = _G[bar.objPrefix..tostring(objID)]

		if (object) then
			if (bar.data.multiSpec) then
				spec = GetSpecialization()
			else
				spec = 1
			end

			bar:Show()

			object:SetData(object, bar)
			object:LoadData(object, spec, bar.handler:GetAttribute("activestate"))
			NEURON.NeuronFlyouts:UpdateFlyout(object)
			object:SetType(object)
			object:SetObjectVisibility(object)
		end
	end
end


---TODO refactor this to NeuronButton
function NeuronButton:SetData(button, bar)
	if (bar) then

		button.bar = bar

		button.barLock = bar.data.barLock
		button.barLockAlt = bar.data.barLockAlt
		button.barLockCtrl = bar.data.barLockCtrl
		button.barLockShift = bar.data.barLockShift

		button.tooltips = bar.data.tooltips
		button.tooltipsEnhanced = bar.data.tooltipsEnhanced
		button.tooltipsCombat = bar.data.tooltipsCombat

		button.spellGlow = bar.data.spellGlow
		button.spellGlowDef = bar.data.spellGlowDef
		button.spellGlowAlt = bar.data.spellGlowAlt

		button.bindText = bar.data.bindText
		button.macroText = bar.data.macroText
		button.countText = bar.data.countText

		button.cdText = bar.data.cdText

		if (bar.data.cdAlpha) then
			button.cdAlpha = 0.2
		else
			button.cdAlpha = 1
		end

		button.auraText = bar.data.auraText
		button.auraInd = bar.data.auraInd

		button.rangeInd = bar.data.rangeInd

		button.upClicks = bar.data.upClicks
		button.downClicks = bar.data.downClicks

		button.showGrid = bar.data.showGrid
		button.multiSpec = bar.data.multiSpec

		button.bindColor = bar.data.bindColor
		button.macroColor = bar.data.macroColor
		button.countColor = bar.data.countColor

		button.macroname:SetText(button.data.macro_Name) --custom macro's weren't showing the name

		if (not button.cdcolor1) then
			button.cdcolor1 = { (";"):split(bar.data.cdcolor1) }
		else
			button.cdcolor1[1], button.cdcolor1[2], button.cdcolor1[3], button.cdcolor1[4] = (";"):split(bar.data.cdcolor1)
		end

		if (not button.cdcolor2) then
			button.cdcolor2 = { (";"):split(bar.data.cdcolor2) }
		else
			button.cdcolor2[1], button.cdcolor2[2], button.cdcolor2[3], button.cdcolor2[4] = (";"):split(bar.data.cdcolor2)
		end

		if (not button.auracolor1) then
			button.auracolor1 = { (";"):split(bar.data.auracolor1) }
		else
			button.auracolor1[1], button.auracolor1[2], button.auracolor1[3], button.auracolor1[4] = (";"):split(bar.data.auracolor1)
		end

		if (not button.auracolor2) then
			button.auracolor2 = { (";"):split(bar.data.auracolor2) }
		else
			button.auracolor2[1], button.auracolor2[2], button.auracolor2[3], button.auracolor2[4] = (";"):split(bar.data.auracolor2)
		end

		if (not button.buffcolor) then
			button.buffcolor = { (";"):split(bar.data.buffcolor) }
		else
			button.buffcolor[1], button.buffcolor[2], button.buffcolor[3], button.buffcolor[4] = (";"):split(bar.data.buffcolor)
		end

		if (not button.debuffcolor) then
			button.debuffcolor = { (";"):split(bar.data.debuffcolor) }
		else
			button.debuffcolor[1], button.debuffcolor[2], button.debuffcolor[3], button.debuffcolor[4] = (";"):split(bar.data.debuffcolor)
		end

		if (not button.rangecolor) then
			button.rangecolor = { (";"):split(bar.data.rangecolor) }
		else
			button.rangecolor[1], button.rangecolor[2], button.rangecolor[3], button.rangecolor[4] = (";"):split(bar.data.rangecolor)
		end

		button:SetFrameStrata(bar.data.objectStrata)

		button:SetScale(bar.data.scale)
	end

	if (button.bindText) then
		button.hotkey:Show()
		if (button.bindColor) then
			button.hotkey:SetTextColor((";"):split(button.bindColor))
		end
	else
		button.hotkey:Hide()
	end

	if (button.macroText) then
		button.macroname:Show()
		if (button.macroColor) then
			button.macroname:SetTextColor((";"):split(button.macroColor))
		end
	else
		button.macroname:Hide()
	end

	if (button.countText) then
		button.count:Show()
		if (button.countColor) then
			button.count:SetTextColor((";"):split(button.countColor))
		end
	else
		button.count:Hide()
	end

	local down, up = "", ""

	if (button.upClicks) then up = up.."AnyUp" end
	if (button.downClicks) then down = down.."AnyDown" end

	button:RegisterForClicks(down, up)
	button:RegisterForDrag("LeftButton", "RightButton")
	button:RegisterEvent("PLAYER_ENTERING_WORLD")

	if (not button.equipcolor) then
		button.equipcolor = { 0.1, 1, 0.1, 1 }
	else
		button.equipcolor[1], button.equipcolor[2], button.equipcolor[3], button.equipcolor[4] = 0.1, 1, 0.1, 1
	end

	if (not button.manacolor) then
		button.manacolor = { 0.5, 0.5, 1.0, 1 }
	else
		button.manacolor[1], button.manacolor[2], button.manacolor[3], button.manacolor[4] = 0.5, 0.5, 1.0, 1
	end

	button:SetFrameLevel(4)
	button.iconframe:SetFrameLevel(2)
	button.iconframecooldown:SetFrameLevel(3)
	button.iconframeaurawatch:SetFrameLevel(3)

	button:GetSkinned(button)

	NeuronButton:MACRO_UpdateTimers(button)
end


function NeuronButton:SaveData(button, state)
	local index, spec = button.id, GetSpecialization()

	if (not state) then
		state = button:GetParent():GetAttribute("activestate") or "homestate"
	end

	--Possible fix to keep the home state action from getting overwritten

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		return
	end


	if (index and spec and state) then

		if (not DB.buttons[index].config) then
			DB.buttons[index].config = CopyTable(configData)
		end

		for key,value in pairs(button.config) do
			DB.buttons[index].config[key] = value
		end

		if (not DB.buttons[index].keys) then
			DB.buttons[index].keys = CopyTable(keyData)
		end

		if (DB.perCharBinds) then
			for key,value in pairs(button.keys) do
				DB.buttons[index].keys[key] = value
			end
		end

		if (not DB.buttons[index][spec]) then
			DB.buttons[index][spec] = { homestate = CopyTable(stateData) }
		end

		if (not DB.buttons[index][spec][state]) then
			DB.buttons[index][spec][state] = CopyTable(stateData)
		end

		for key,value in pairs(button.data) do
			DB.buttons[index][spec][state][key] = value
		end

		NeuronButton:BuildStateData(button)

	else
		NEURON:Print("DEBUG: Bad Save Data for "..button:GetName().." ?")
		NEURON:Print(index); NEURON:Print(spec); NEURON:Print(state)
	end
end

---TODO refactor this to NeuronButton
function NeuronButton:LoadData(button, spec, state)
	local id = button.id

	button.DB = DB.buttons

	if (button.DB) then

		if (not button.DB[id]) then
			button.DB[id] = {}
		end

		if (not button.DB[id].config) then
			button.DB[id].config = CopyTable(configData)
		end

		if (not button.DB[id].keys) then
			button.DB[id].keys = CopyTable(keyData)
		end

		for i=1,4 do
			if (not button.DB[id][i]) then
				button.DB[id][i] = { homestate = CopyTable(stateData) }
			end
		end

		if (not button.DB[id].keys) then
			button.DB[id].keys = CopyTable(keyData)
		end

		if (not button.DB[id][spec]) then
			button.DB[id][spec] = { homestate = CopyTable(stateData) }
		end

		if (not button.DB[id][spec][state]) then
			button.DB[id][spec][state] = CopyTable(stateData)
		end


		button.config = button.DB[id].config
		button.keys = button.DB[id].keys
		button.spedata = button.DB[id]
		button.statedata = button.spedata[spec]
		button.data = button.statedata[state]

		NeuronButton:BuildStateData(button)
	end
end


function NeuronButton:BuildStateData(button)
	for state, data in pairs(button.statedata) do
		button:SetAttribute(state.."-macro_Text", data.macro_Text)
		button:SetAttribute(state.."-actionID", data.actionID)
	end
end


function NeuronButton:Reset(button)
	button:SetAttribute("unit", nil)
	button:SetAttribute("useparent-unit", nil)
	button:SetAttribute("type", nil)
	button:SetAttribute("type1", nil)
	button:SetAttribute("type2", nil)
	button:SetAttribute("*action*", nil)
	button:SetAttribute("*macrotext*", nil)
	button:SetAttribute("*action1", nil)
	button:SetAttribute("*macrotext2", nil)

	button:UnregisterEvent("ITEM_LOCK_CHANGED")
	button:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	button:UnregisterEvent("ACTIONBAR_SHOWGRID")
	button:UnregisterEvent("ACTIONBAR_HIDEGRID")
	button:UnregisterEvent("PET_BAR_SHOWGRID")
	button:UnregisterEvent("PET_BAR_HIDEGRID")
	button:UnregisterEvent("PET_BAR_UPDATE")
	button:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN")
	button:UnregisterEvent("UNIT_FLAGS")
	button:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	button:UnregisterEvent("UPDATE_MACROS")
	button:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	button:UnregisterEvent("EQUIPMENT_SETS_CHANGED")

	NeuronButton:MACRO_Reset(button)
end

---TODO refactor this to NeuronButton
function NeuronButton:SetObjectVisibility(button, show)
	if (not InCombatLockdown()) then

		button:SetAttribute("isshown", button.showGrid)
		button:SetAttribute("showgrid", show)

		if (show or button.showGrid) then
			button:Show()
		elseif not NeuronButton:MACRO_HasAction(button) and (not NEURON.ButtonEditMode or not NEURON.BarEditMode or not NEURON.BindingMode) then
			button:Hide()
		end
	end
end


---TODO refactor this to NeuronButton
function NeuronButton:SetAux(button)
	button:SetSkinned(button)
	NEURON.NeuronFlyouts:UpdateFlyout(button, true)
end

---TODO refactor this to NeuronButton
function NeuronButton:LoadAux(button)

	if NEURON.NeuronGUI then
		NEURON.NeuronGUI:ObjEditor_CreateEditFrame(button, button.objTIndex)
	end
	NEURON.NeuronBinder:CreateBindFrame(button, button.objTIndex)

end

---TODO refactor this to NeuronButton
function NeuronButton:SetDefaults(button, config, keys)
	if (config) then
		for k,v in pairs(config) do
			button.config[k] = v
		end
	end

	if (keys) then
		for k,v in pairs(keys) do
			button.keys[k] = v
		end
	end
end

---TODO refactor this to NeuronButton
function NeuronButton:GetDefaults(button)
	return nil, keyDefaults[button.id]
end

---TODO refactor this to NeuronButton
function NeuronButton:SetType(button, save, kill, init)
	local state = button:GetParent():GetAttribute("activestate")

	NeuronButton:Reset(button)

	if (kill) then

		button:SetScript("OnEvent", function() end)
		button:SetScript("OnUpdate", function() end)
		button:SetScript("OnAttributeChanged", function() end)

	else
		SecureHandler_OnLoad(button)

		button:RegisterEvent("ITEM_LOCK_CHANGED")
		button:RegisterEvent("ACTIONBAR_SHOWGRID")
		button:RegisterEvent("ACTIONBAR_HIDEGRID")

		button:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		button:RegisterEvent("UPDATE_MACROS")
		button:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		button:RegisterEvent("EQUIPMENT_SETS_CHANGED")

		NeuronButton:MACRO_UpdateParse(button)

		button:SetAttribute("type", "macro")
		button:SetAttribute("*macrotext*", button.macroparse)

		button:SetScript("OnEvent", function(self, event, ...) NeuronButton:MACRO_OnEvent(self, event, ...) end)
		button:SetScript("PreClick", function(self, mousebutton) NeuronButton:MACRO_PreClick(self, mousebutton) end)
		button:SetScript("PostClick", function(self, mousebutton) NeuronButton:MACRO_PostClick(self, mousebutton) end)
		button:SetScript("OnReceiveDrag", function(self, preclick) NeuronButton:MACRO_OnReceiveDrag(self, preclick) end)
		button:SetScript("OnDragStart", function(self, mousebutton) NeuronButton:MACRO_OnDragStart(self, mousebutton) end)
		button:SetScript("OnDragStop", function(self) NeuronButton:MACRO_OnDragStop(self) end)
		button:SetScript("OnUpdate", function(self, elapsed) NeuronButton:MACRO_OnUpdate(self, elapsed) end)--this function uses A LOT of CPU resources
		button:SetScript("OnShow", function(self, ...) NeuronButton:MACRO_OnShow(self, ...) end)
		button:SetScript("OnHide", function(self, ...) NeuronButton:MACRO_OnHide(self, ...) end)
		button:SetScript("OnAttributeChanged", function(self, name, value)NeuronButton:MACRO_OnAttributeChanged(self, name, value) end)

		button:HookScript("OnEnter", function(self, ...) NeuronButton:MACRO_OnEnter(self, ...) end)
		button:HookScript("OnLeave", function(self, ...) NeuronButton:MACRO_OnLeave(self, ...) end)

		button:WrapScript(button, "OnShow", [[
						for i=1,select('#',(":"):split(self:GetAttribute("hotkeys"))) do
							self:SetBindingClick(self:GetAttribute("hotkeypri"), select(i,(":"):split(self:GetAttribute("hotkeys"))), self:GetName())
						end
						]])

		button:WrapScript(button, "OnHide", [[
						if (not self:GetParent():GetAttribute("concealed")) then
							for key in gmatch(self:GetAttribute("hotkeys"), "[^:]+") do
								self:ClearBinding(key)
							end
						end
						]])

		--new action ID's for vehicle 133-138
		--new action ID's for possess 133-138
		--new action ID's for override 157-162

		button:SetAttribute("overrideID_Offset", 156)
		button:SetAttribute("vehicleID_Offset", 132)

		button:SetAttribute("_childupdate", [=[

				if (message) then

					local msg = (":"):split(message)

					if (msg:find("vehicle")) then

						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))

						end

						self:SetAttribute("SpecialAction", "vehicle")
						self:SetAttribute("HasActionID", true)
						self:Show()

					elseif (msg:find("possess")) then
						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))

						end

						self:SetAttribute("SpecialAction", "possess")
						self:SetAttribute("HasActionID", true)
						self:Show()

					elseif (msg:find("override")) then
						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("overrideID_Offset"))
							self:SetAttribute("HasActionID", true)

						end

						self:SetAttribute("SpecialAction", "override")

						self:SetAttribute("HasActionID", true)

						self:Show()

					else
						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "macro")
							self:SetAttribute("*macrotext*", self:GetAttribute(msg.."-macro_Text"))

							if ((self:GetAttribute("*macrotext*") and #self:GetAttribute("*macrotext*") > 0) or (self:GetAttribute("showgrid"))) then
								self:Show()
							elseif (not self:GetAttribute("isshown")) then
								self:Hide()
							end

							self:SetAttribute("HasActionID", false)
						else
							self:SetAttribute("HasActionID", true)
						end

						self:SetAttribute("SpecialAction", nil)
					end

					self:SetAttribute("useparent-unit", nil)
					self:SetAttribute("activestate", msg)

				end

			]=])

		if (not init) then
			NeuronButton:MACRO_UpdateAll(button, true)
		end

		NeuronButton:MACRO_OnShow(button)

	end

	if (save) then
		button:SaveData(button, state)
	end
end


function NeuronButton:SetFauxState(button, state)
	if (state)  then

		local msg = (":"):split(state)

		if (msg:find("vehicle")) then
			if (not button:GetAttribute(msg.."-actionID")) then

				button:SetAttribute("type", "action")
				button:SetAttribute("*action*", button:GetAttribute("barPos")+button:GetAttribute("vehicleID_Offset"))
				button:SetAttribute("HasActionID", true)

			end

			button:Show()
		elseif (msg:find("possess")) then
			if (not button:GetAttribute(msg.."-actionID")) then

				button:SetAttribute("type", "action")
				button:SetAttribute("*action*", button:GetAttribute("barPos")+button:GetAttribute("vehicleID_Offset"))
				button:SetAttribute("HasActionID", true)

			end

			button:Show()

		elseif (msg:find("override")) then
			if (not button:GetAttribute(msg.."-actionID")) then

				button:SetAttribute("type", "action")
				button:SetAttribute("*action*", button:GetAttribute("barPos")+button:GetAttribute("overrideID_Offset"))
				button:SetAttribute("HasActionID", true)

			end

			button:Show()

		else
			if (not button:GetAttribute(msg.."-actionID")) then

				button:SetAttribute("type", "macro")

				button:SetAttribute("*macrotext*", button:GetAttribute(msg.."-macro_Text"))

				if ((button:GetAttribute("*macrotext*") and #button:GetAttribute("*macrotext*") > 0) or (button:GetAttribute("showgrid"))) then
					button:Show()
				elseif (not button:GetAttribute("isshown")) then
					button:Hide()
				end

				button:SetAttribute("HasActionID", false)
			else
				button:SetAttribute("HasActionID", true)
			end
		end
		button:SetAttribute("activestate", msg)
	end
end


--this will generate a spell macro
--spell: name of spell to use
--subname: subname of spell to use (optional)
--return: macro text
function NeuronButton:AutoWriteMacro(button, spell)
	local modifier, modKey = " ", nil
	local bar = Neuron.CurrentBar or button.bar

	if (bar.data.mouseOverCast and DB.mouseOverMod ~= "NONE" ) then
		modKey = DB.mouseOverMod; modifier = modifier.."[@mouseover,mod:"..modKey.."]"
	elseif (bar.data.mouseOverCast and NeuroDB.mouseOverMod == "NONE" ) then
		modifier = modifier.."[@mouseover,exists]"
	end

	if (bar.data.selfCast and GetModifiedClick("SELFCAST") ~= "NONE" ) then
		modKey = GetModifiedClick("SELFCAST"); modifier = modifier.."[@player,mod:"..modKey.."]"
	end

	if (bar.data.focusCast and GetModifiedClick("FOCUSCAST") ~= "NONE" ) then
		modKey = GetModifiedClick("FOCUSCAST"); modifier = modifier.."[@focus,exists,mod:"..modKey.."]"
	end

	if (bar.data.rightClickTarget) then
		modKey = ""; modifier = modifier.."[@player"..modKey..",btn:2]"
	end

	if (modifier ~= " " ) then --(modKey) then
		modifier = modifier.."[] "
	end

	return "#autowrite\n/cast"..modifier..spell.."()"
end


--This will update the modifier value in a macro when a bar is set twith a target condiional
--@spell:  this is hte macro text to be updated
--return: updated macro text
function NeuronButton:AutoUpdateMacro(button, macro)
	if (GetModifiedClick("SELFCAST") ~= "NONE" ) then
		macro = macro:gsub("%[@player,mod:%u+%]", "[@player,mod:"..GetModifiedClick("SELFCAST").."]")
	else
		macro = macro:gsub("%[@player,mod:%u+%]", "")
	end

	if (GetModifiedClick("FOCUSCAST") ~= "NONE" ) then
		macro = macro:gsub("%[@focus,mod:%u+%]", "[@focus,exists,mod:"..GetModifiedClick("FOCUSCAST").."]")
	else
		macro = macro:gsub("%[@focus,mod:%u+%]", "")
	end

	if (DB.mouseOverMod ~= "NONE" ) then
		macro = macro:gsub("%[@mouseover,mod:%u+%]", "[@mouseover,mod:"..DB.mouseOverMod .."]")
		macro = macro:gsub("%[@mouseover,exists]", "[@mouseover,mod:"..DB.mouseOverMod .."]")
	else
		macro = macro:gsub("%[@mouseover,mod:%u+%]", "[@mouseover,exists]")
	end

	--macro = info.macro_Text:gsub("%[.*%]", "")
	return macro
end


function NeuronButton:GetPosition(button, oFrame)
	local relFrame, point

	if (oFrame) then
		relFrame = oFrame
	else
		relFrame = button:GetParent()
	end

	local s = button:GetScale()
	local w, h = relFrame:GetWidth()/s, relFrame:GetHeight()/s
	local x, y = button:GetCenter()
	local vert = (y>h/1.5) and "TOP" or (y>h/3) and "CENTER" or "BOTTOM"
	local horz = (x>w/1.5) and "RIGHT" or (x>w/3) and "CENTER" or "LEFT"

	if (vert == "CENTER") then
		point = horz
	elseif (horz == "CENTER") then
		point = vert
	else
		point = vert..horz
	end

	if (vert:find("CENTER")) then y = y - h/2 end
	if (horz:find("CENTER")) then x = x - w/2 end
	if (point:find("RIGHT")) then x = x - w end
	if (point:find("TOP")) then y = y - h end

	return point, x, y
end

--callback(arg and arg, Group, SkinID, Gloss, Backdrop, Colors, Fonts)

function NeuronButton:SKINCallback(button, group,...)
	if (group) then
		for btn in pairs(SKINIndex) do
			if (btn.bar and btn.bar.data.name == group) then
				btn:GetSkinned(btn)
			end
		end
	end
end



function NeuronButton.ButtonProfileUpdate()
	DB = NEURON.db.profile
	DB.buttons = DB.buttons
end


--- This will itterate through a set of buttons. For any buttons that have the #autowrite flag in its macro, that
-- macro will then be updated to via AutoWriteMacro to include selected target macro option, or via AutoUpdateMacro
-- to update a current target macro's toggle mofifier.
-- @param global(boolean): if true will go though all buttons, else it will just update the button set for the current bar
function NeuronButton:UpdateMacroCastTargets(global_update)
	local button_list = {}

	if global_update then
		local button_count =(#NeuronDB.buttons)
		for index = 1, button_count, 1 do
			tinsert(button_list, _G["NeuronActionButton"..index])
		end
	else
		local bar = NEURON.CurrentBar
		--for index in gmatch(bar.data.objectList, "[^;]+") do
		for i, objID in ipairs(bar.data.objectList) do
			tinsert(button_list, _G["NeuronActionButton"..tostring(objID)])
		end
	end

	for index, button in pairs(button_list) do
		local cur_button = button.spedata
		local macro_update = false

		for i = 1,2 do
			for state, info in pairs(cur_button[i]) do
				if info.macro_Text and info.macro_Text:find("#autowrite\n/cast") then
					local spell = ""

					spell = info.macro_Text:gsub("%[.*%]", "")
					spell = spell:match("#autowrite\n/cast%s*(.+)%((.*)%)")

					if spell then
						if global_update then
							info.macro_Text = NeuronButton:AutoUpdateMacro(button, info.macro_Text)
						else
							info.macro_Text = NeuronButton:AutoWriteMacro(button, spell)
						end

					end
					macro_update = true
				end
			end
		end

		if macro_update then
			NEURON.NeuronFlyouts:UpdateFlyout(button)
			NeuronButton:BuildStateData(button)
			button:SetType(button)
		end
	end
end
