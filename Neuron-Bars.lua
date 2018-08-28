--Neuron, a World of Warcraft® user interface addon.

local NEURON = Neuron
local DB, SPEC, player, realm

NEURON.NeuronBar = NEURON:NewModule("Bar", "AceEvent-3.0", "AceHook-3.0")
local NeuronBar = NEURON.NeuronBar

local handlerMT = setmetatable({}, { __index = CreateFrame("Frame") })

NEURON.BAR = setmetatable({}, {__index = CreateFrame("CheckButton")}) --Bar object template
local BAR = NEURON.BAR

local TRASHCAN = CreateFrame("Frame", nil, UIParent)
TRASHCAN:Hide()

local BUTTON = NEURON.BUTTON

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local BARIndex = NEURON.BARIndex
local BARNameIndex = NEURON.BARNameIndex
local BTNIndex = NEURON.BTNIndex

local MAS = NEURON.MANAGED_ACTION_STATES
local MBS = NEURON.MANAGED_BAR_STATES

local alphaDir, alphaTimer = 0, 0

local autoHideIndex, alphaupIndex = {}, {}

NEURON.AlphaUps = {
	L["Off"],
	L["Mouseover"],
	L["Combat"],
	L["Combat + Mouseover"],
	L["Retreat"],
	L["Retreat + Mouseover"],
}
local alphaUps = NEURON.AlphaUps


NEURON.BarShapes = {
	L["Linear"],
	L["Circle"],
	L["Circle + One"],
}
local barShapes = NEURON.BarShapes


NEURON.barDEF = {
	name = "",

	objectList = {},

	hidestates = ":",

	point = "BOTTOM",
	x = 0,
	y = 190,

	scale = 1,
	shape = 1,
	columns = false,

	alpha = 1,
	alphaUp = 1,
	alphaMax = 1,
	fadeSpeed = 0.5,

	barStrata = "MEDIUM",
	objectStrata = "LOW",

	padH = 0,
	padV = 0,
	arcStart = 0,
	arcLength = 359,

	snapTo = false,
	snapToPad = 0,
	snapToPoint = false,
	snapToFrame = false,

	autoHide = false,
	showGrid = true,

	bindColor = "1;1;1;1",
	macroColor = "1;1;1;1",
	countColor = "1;1;1;1",
	cdcolor1 = "1;0.82;0;1",
	cdcolor2 = "1;0.1;0.1;1",
	auracolor1 = "0;0.82;0;1",
	auracolor2 = "1;0.1;0.1;1",
	buffcolor = "0;0.8;0;1",
	debuffcolor = "0.8;0;0;1",
	rangecolor = "0.7;0.15;0.15;1",
	border = true,

	upClicks = true,
	downClicks = false,

	conceal = false,

	multiSpec = false,

	spellGlow = true,
	spellGlowDef = true,
	spellGlowAlt = false,

	barLock = false,
	barLockAlt = false,
	barLockCtrl = false,
	barLockShift = false,

	tooltips = true,
	tooltipsEnhanced = true,
	tooltipsCombat = false,

	bindText = true,
	macroText = true,
	countText = true,
	rangeInd = true,

	cdText = false,
	cdAlpha = false,
	auraText = false,
	auraInd = false,

	homestate = true,
	paged = false,
	stance = false,
	stealth = false,
	reaction = false,
	combat = false,
	group = false,
	pet = false,
	fishing = false,
	vehicle = false,
	possess = false,
	override = false,
	extrabar = false,
	alt = false,
	ctrl = false,
	shift = false,
	target = false,

	selfCast = false,
	focusCast = false,
	rightClickTarget = false,
	mouseOverCast = false,

	custom = false,
	customRange = false,
	customNames = false,

	remap = false,
}



local defaultBarOptions = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 55,
		showGrid = true,
		multiSpec = true,
		vehicle = true,
		possess = true,
		override = true,
	},

	[2] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 100,
		showGrid = true,
	},
}

local statetable = {}

local barStack = {}


-----------------------

-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronBar:OnInitialize()

	DB = NEURON.db.profile

	NEURON:RegisterBarClass("bar", "ActionBar", L["Action Bar"], "Action Button", DB.bars, BTNIndex, DB.buttons, "CheckButton", "NeuronActionButtonTemplate", { __index = BUTTON }, 1000, true)

	NEURON:RegisterGUIOptions("bar", {
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
		AURAIND = true
	}, true, 115)

	if NEURON.NeuronZoneAbilityBar then
		NeuronBar.HideZoneAbilityBorder = NEURON.NeuronZoneAbilityBar.HideZoneAbilityBorder --this is so the slash function has access to this function
	end
	NEURON.CreateNewBar = NeuronBar.CreateNewBar --temp just so slash functions still work

	NeuronBar:CreateBarsAndButtons()
end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronBar:OnEnable()

	local stackWatch = CreateFrame("Frame", nil, UIParent)
	stackWatch:SetScript("OnUpdate", function(self) self.bar = GetMouseFocus():GetName() if (not BARNameIndex[self.bar]) then wipe(barStack); self:Hide() end end)
	stackWatch:Hide()

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronBar:OnDisable()

end


------------------------------------------------------------------------------

-------------------------------------------------------------------------------
------------------------------------------------------------
--------------------Helper Functions------------------------
------------------------------------------------------------

local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function tFind(table, value)
	local index = 1;
	while table[index] do
		if ( value == table[index] ) then
			return index;
		end
		index = index + 1;
	end
	return 0;
end

------------------------------------------------------------
--------------------Intermediate Functions------------------
------------------------------------------------------------

function NeuronBar:CreateBarsAndButtons()

	---TODO: clean up the onload part of this addon. This way of creating all the objects is terribly clunky
	if (DB.firstRun) then
		local offset = 0

		for id, defaults in ipairs(defaultBarOptions) do

			local bar = NeuronBar:CreateNewBar("bar", id, true) --this calls the bar constructor

			for	k,v in pairs(defaults) do
				bar.data[k] = v
			end

			local object

			for i=1+offset, 12+offset do
				object = NEURON.NeuronButton:CreateNewObject("bar", i, true) --this calls the object (button) constructor
				NeuronBar:AddObjectToList(bar, object)
			end

			offset = offset + 12
		end

	else
		for id,data in pairs(DB.bars) do
			if (data ~= nil) then
				NeuronBar:CreateNewBar("bar", id) --this calls the bar constructor
			end

		end

		for id,data in pairs(DB.buttons) do
			if (data ~= nil) then
				NEURON.NeuronButton:CreateNewObject("bar", id) --this calls the object (button) constructor
			end
		end
	end

end


function NeuronBar:IsMouseOverSelfOrWatchFrame(frame)
	if (frame:IsMouseOver()) then
		return true
	end

	if (frame.watchframes) then
		for handler in pairs(frame.watchframes) do
			if (handler:IsMouseOver() and handler:IsVisible()) then
				return true
			end
		end
	end

	return false
end

--this function gets called via controlOnUpdate in the main Neuron.lua
function NeuronBar:controlOnUpdate(frame, elapsed)
	for k,v in pairs(autoHideIndex) do
		if (v~=nil) then

			if (k:IsShown()) then
				v:SetAlpha(1)
			else

				if (NeuronBar:IsMouseOverSelfOrWatchFrame(k)) then
					if (v:GetAlpha() < k.alpha) then
						if (v:GetAlpha()+v.fadeSpeed <= 1) then
							v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
						else
							v:SetAlpha(1)
						end
					else
						k.seen = 1;
					end

				end

				if (not NeuronBar:IsMouseOverSelfOrWatchFrame(k)) then
					if (v:GetAlpha() > 0) then
						if (v:GetAlpha()-v.fadeSpeed >= 0) then
							v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
						else
							v:SetAlpha(0)
						end
					else
						k.seen = 0;
					end
				end
			end
		end
	end

	for k,v in pairs(alphaupIndex) do
		if (v~=nil) then

			if (k:IsShown()) then
				v:SetAlpha(1)
			else

				if (k.alphaUp == alphaUps[3] or k.alphaUp == alphaUps[4]) then

					if (InCombatLockdown()) then

						if (v:GetAlpha() < 1) then
							if (v:GetAlpha()+v.fadeSpeed <= 1) then
								v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
							else
								v:SetAlpha(1)
							end
						else
							k.seen = 1;
						end

					else
						if (k.alphaUp == alphaUps[4]) then

							if (NeuronBar:IsMouseOverSelfOrWatchFrame(k)) then
								if (v:GetAlpha() < 1) then
									if (v:GetAlpha()+v.fadeSpeed <= 1) then
										v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
									else
										v:SetAlpha(1)
									end
								else
									k.seen = 1;
								end
							else
								if (v:GetAlpha() > k.alpha) then
									if (v:GetAlpha()-v.fadeSpeed >= k.alpha) then
										v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
									else
										v:SetAlpha(k.alpha)
									end
								else
									k.seen = 0;
								end
							end
						else
							if (v:GetAlpha() > k.alpha) then
								if (v:GetAlpha()-v.fadeSpeed >= k.alpha) then
									v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
								else
									v:SetAlpha(k.alpha)
								end
							else
								k.seen = 0;
							end
						end
					end

				elseif (k.alphaUp == alphaUps[5] or k.alphaUp == alphaUps[6]) then

					if (not InCombatLockdown()) then

						if (v:GetAlpha() < 1) then
							if (v:GetAlpha()+v.fadeSpeed <= 1) then
								v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
							else
								v:SetAlpha(1)
							end
						else
							k.seen = 1;
						end

					else
						if (k.alphaUp == alphaUps[6]) then

							if (NeuronBar:IsMouseOverSelfOrWatchFrame(k)) then
								if (v:GetAlpha() < 1) then
									if (v:GetAlpha()+v.fadeSpeed <= 1) then
										v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
									else
										v:SetAlpha(1)
									end
								else
									k.seen = 1;
								end
							else
								if (v:GetAlpha() > k.alpha) then
									if (v:GetAlpha()-v.fadeSpeed >= k.alpha) then
										v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
									else
										v:SetAlpha(k.alpha)
									end
								else
									k.seen = 0;
								end
							end
						else
							if (v:GetAlpha() > k.alpha) then
								if (v:GetAlpha()-v.fadeSpeed >= k.alpha) then
									v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
								else
									v:SetAlpha(k.alpha)
								end
							else
								k.seen = 0;
							end
						end
					end

				elseif (k.alphaUp == alphaUps[2]) then

					if (NeuronBar:IsMouseOverSelfOrWatchFrame(k)) then
						if (v:GetAlpha() < 1) then
							if (v:GetAlpha()+v.fadeSpeed <= 1) then
								v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
							else
								v:SetAlpha(1)
							end
						else
							k.seen = 1;
						end
					else
						if (v:GetAlpha() > k.alpha) then
							if (v:GetAlpha()-v.fadeSpeed >= k.alpha) then
								v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
							else
								v:SetAlpha(k.alpha)
							end
						else
							k.seen = 0;
						end
					end
				end
			end
		end
	end
end


function NeuronBar:SetHidden(handler, bar, show, hide)

	for k,v in pairs(bar.vis) do
		if (v.registered) then
			return
		end
	end

	local isAnchorChild = handler:GetAttribute("isAnchorChild")

	if (not hide and not isAnchorChild and (show or bar:IsVisible())) then

		handler:Show()
	else
		if (bar.data.conceal) then
			handler:SetAttribute("concealed", true)
			handler:Hide()
		elseif (not bar.data.barLink and not isAnchorChild) then
			handler:SetAttribute("concealed", nil)
			handler:Show()
		end
	end
end

function NeuronBar:SetAutoHide(handler, bar)

	if (bar.data.autoHide) then
		autoHideIndex[bar] = handler
		handler.fadeSpeed = (bar.data.fadeSpeed*bar.data.fadeSpeed)
	else
		autoHideIndex[bar] = nil
	end

	if (bar.data.alphaUp == L["Off"]) then
		alphaupIndex[bar] = nil
	else
		alphaupIndex[bar] = handler
		handler.fadeSpeed = (bar.data.fadeSpeed*bar.data.fadeSpeed)
	end
end


function NeuronBar:AddVisibilityDriver(handler, bar, state, conditions)

	if (MBS[state]) then

		RegisterStateDriver(handler, state, conditions)

		if (handler:GetAttribute("activestates"):find(state)) then
			handler:SetAttribute("activestates", handler:GetAttribute("activestates"):gsub(state.."%d+;", handler:GetAttribute("state-"..state)..";"))
		elseif (handler:GetAttribute("activestates") and handler:GetAttribute("state-"..state)) then
			handler:SetAttribute("activestates", handler:GetAttribute("activestates")..handler:GetAttribute("state-"..state)..";")
		end

		if (handler:GetAttribute("state-"..state)) then
			handler:SetAttribute("state-"..state, handler:GetAttribute("state-"..state))
		end

		bar.vis[state].registered = true
	end
end


function NeuronBar:ClearVisibilityDriver(handler, bar, state)

	UnregisterStateDriver(handler, state)

	handler:SetAttribute("activestates", handler:GetAttribute("activestates"):gsub(state.."%d+;", ""))
	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")

	bar.vis[state].registered = false
end


function NeuronBar:UpdateVisibility(driver, bar)

	for state, values in pairs(MBS) do

		if (bar.data.hidestates:find(":"..state)) then

			if (not bar.vis[state] or not bar.vis[state].registered) then

				if (not bar.vis[state]) then
					bar.vis[state] = {}
				end

				if (state == "stance" and bar.data.hidestates:find(":stance8")) then
					NeuronBar:AddVisibilityDriver(driver, bar, state, "[stance:2/3,stealth] stance8; "..values.states)
					--elseif (state == "custom" and bar.data.custom) then
					--handler:AddVisibilityDriver(bar, state, bar.data.custom)
				else
					NeuronBar:AddVisibilityDriver(driver, bar, state, values.states)
				end
			end

		elseif (bar.vis[state] and bar.vis[state].registered) then

			NeuronBar:ClearVisibilityDriver(driver, bar, state)

		end
	end
end

function NeuronBar:BuildStateMap(bar, remapState)

	local statemap, state, map, remap, homestate = "", remapState:gsub("paged", "bar")

	for states in gmatch(bar.data.remap, "[^;]+") do

		map, remap = (":"):split(states)

		if (remapState == "stance" and NEURON.class == "ROGUE" and map == "1") then
			--map = "2"
		end

		if (not homestate) then
			statemap = statemap.."["..state..":"..map.."] homestate; "; homestate = true
		else
			local newstate = remapState..remap

			if (MAS[remapState] and
					MAS[remapState].homestate and
					MAS[remapState].homestate == newstate) then
				statemap = statemap.."["..state..":"..map.."] homestate; "
			else
				statemap = statemap.."["..state..":"..map.."] "..newstate.."; "
			end
		end
	end

	statemap = gsub(statemap, "; $", "")

	return statemap
end


function NeuronBar:AddStates(handler, bar, state, conditions)

	if (state) then

		if (MAS[state]) then
			RegisterStateDriver(handler, state, conditions)
		end

		if (MAS[state].homestate) then
			handler:SetAttribute("handler-homestate", MAS[state].homestate)
		end

		bar[state].registered = true
	end

end

function NeuronBar:ClearStates(handler, bar, state)

	if (state ~= "homestate") then

		if (MAS[state].homestate) then
			handler:SetAttribute("handler-homestate", nil)
		end

		handler:SetAttribute("state-"..state, nil)

		UnregisterStateDriver(handler, state)

		bar[state].registered = false
	end

	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")
end


function NeuronBar:UpdateStates(handler, bar)
	for state, values in pairs(MAS) do

		if (bar.data[state]) then

			if (not bar[state] or not bar[state].registered) then

				local statemap

				if (not bar[state]) then
					bar[state] = {}
				end

				if (bar.data.remap and (state == "paged" or state == "stance")) then
					statemap = NeuronBar:BuildStateMap(bar, state)
				end


				if (state == "custom" and bar.data.custom) then

					NeuronBar:AddStates(handler, bar, state, bar.data.custom)

				elseif (statemap) then

					NeuronBar:AddStates(handler, bar, state, statemap)

				else
					NeuronBar:AddStates(handler, bar, state, values.states)

				end
			end

		elseif (bar[state] and bar[state].registered) then

			NeuronBar:ClearStates(handler, bar, state)

		end
	end
end


function NeuronBar:CreateDriver(bar)

	--This is the macro base that will be used to set state
	local DRIVER_BASE_ACTION = [[
	local state = self:GetAttribute("state-<MODIFIER>"):match("%a+")

	if (state) then

		if (self:GetAttribute("activestates"):find(state)) then
			self:SetAttribute("activestates", self:GetAttribute("activestates"):gsub(state.."%d+;", self:GetAttribute("state-<MODIFIER>")..";"))
		else
			self:SetAttribute("activestates", self:GetAttribute("activestates")..self:GetAttribute("state-<MODIFIER>")..";")
		end

		control:ChildUpdate("<MODIFIER>", self:GetAttribute("activestates"))
	end
	]]

	local driver = CreateFrame("Frame", "NeuronBarDriver"..bar:GetID(), UIParent, "SecureHandlerStateTemplate")

	setmetatable(driver, { __index = handlerMT })

	driver:SetID(bar:GetID())
	--Dynamicly builds driver attributes based on stated in NEURON.STATEINDEX using localized attribute text from a above
	for _, modifier in pairs(NEURON.STATEINDEX) do
		local action = DRIVER_BASE_ACTION:gsub("<MODIFIER>", modifier)
		driver:SetAttribute("_onstate-"..modifier, action)
	end

	driver:SetAttribute("activestates", "")

	driver:HookScript("OnAttributeChanged",

		function(self,name,value)

		end)

	driver:SetAllPoints(bar)

	bar.driver = driver
	driver.bar = bar
end


function NeuronBar:CreateHandler(bar)

	local HANDLER_BASE_ACTION = [[
	if (self:GetAttribute("state-<MODIFIER>") == "laststate") then

		if (self:GetAttribute("statestack")) then

			if (self:GetAttribute("statestack"):find("<MODIFIER>")) then
				self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("<MODIFIER>%d+;", ""))
			end

			local laststate = (";"):split(self:GetAttribute("statestack"))

			self:SetAttribute("state-last", laststate)

		end

		self:SetAttribute("state-current", self:GetAttribute("state-last") or "homestate")

		if (self:GetAttribute("state-last")) then
			self:SetAttribute("assertstate", self:GetAttribute("state-last"):gsub("%d+", ""))
		else
			self:SetAttribute("assertstate", "homestate")
		end

		if (self:GetAttribute("state-priority")) then
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-priority"))
		else
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-last") or "homestate")
		end

	elseif (self:GetAttribute("state-<MODIFIER>")) then

		if (self:GetAttribute("statestack")) then
			if (self:GetAttribute("statestack"):find("<MODIFIER>")) then
				self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("<MODIFIER>%d+", self:GetAttribute("state-<MODIFIER>")))
			else
				self:SetAttribute("statestack", self:GetAttribute("state-<MODIFIER>")..";"..self:GetAttribute("statestack"))
			end
		else
			self:SetAttribute("statestack", self:GetAttribute("state-<MODIFIER>"))
		end

		self:SetAttribute("state-current", self:GetAttribute("state-<MODIFIER>"))

		self:SetAttribute("assertstate", "<MODIFIER>")

		if (self:GetAttribute("state-priority")) then
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-priority"))
		else
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-<MODIFIER>"))
		end
	end
	]]

	local handler = CreateFrame("Frame", "NeuronBarHandler"..bar:GetID(), bar.driver, "SecureHandlerStateTemplate")

	setmetatable(handler, { __index = handlerMT })

	handler:SetID(bar:GetID())

	--Dynamicly builds handler actions based on states in NEURON.STATEINDEX using Global text
	for _, modifier in pairs(NEURON.STATEINDEX) do
		local action = HANDLER_BASE_ACTION:gsub("<MODIFIER>", modifier)
		handler:SetAttribute("_onstate-"..modifier, action)
	end

	handler:SetAttribute("_onstate-paged", [[

						if (self:GetAttribute("statestack")) then
							if (self:GetAttribute("statestack"):find("paged")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("paged%d+", self:GetAttribute("state-paged") or "homestate"))
							elseif (self:GetAttribute("statestack"):find("homestate")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("homestate", self:GetAttribute("state-paged") or "homestate"))
							elseif (self:GetAttribute("state-paged")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack")..";"..self:GetAttribute("state-paged"))
							end
						else
							self:SetAttribute("statestack", self:GetAttribute("state-paged"))
						end

						if (self:GetAttribute("statestack"):find("^paged") or self:GetAttribute("statestack"):find("^homestate")) then

							self:SetAttribute("assertstate", "paged")

							self:SetAttribute("state-last", self:GetAttribute("state-paged"))

							self:SetAttribute("state-current", self:GetAttribute("state-paged"))

							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("paged", self:GetAttribute("state-priority"))
							elseif (self:GetAttribute("state-paged") and self:GetAttribute("state-paged") == self:GetAttribute("handler-homestate")) then
								control:ChildUpdate("paged", "homestate:"..self:GetAttribute("state-paged"))
							else
								control:ChildUpdate("paged", self:GetAttribute("state-paged"))
							end
						else
							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("homestate", self:GetAttribute("state-priority"))
							else
								control:ChildUpdate("homestate", "homestate")
							end
						end

						]])

	handler:SetAttribute("_onstate-stance", [[

						if (self:GetAttribute("statestack")) then
							if (self:GetAttribute("statestack"):find("stance")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("stance%d+", self:GetAttribute("state-stance") or "homestate"))
							elseif (self:GetAttribute("statestack"):find("homestate")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("homestate", self:GetAttribute("state-stance") or "homestate"))
							elseif (self:GetAttribute("state-stance")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack")..";"..self:GetAttribute("state-stance"))
							end
						else
							self:SetAttribute("statestack", self:GetAttribute("state-stance"))
						end

						if (self:GetAttribute("statestack"):find("^stance") or self:GetAttribute("statestack"):find("^homestate")) then

							self:SetAttribute("assertstate", "stance")

							self:SetAttribute("state-last", self:GetAttribute("state-stance"))

							self:SetAttribute("state-current", self:GetAttribute("state-stance"))

							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("stance", self:GetAttribute("state-priority"))
							elseif (self:GetAttribute("state-stance") and self:GetAttribute("state-stance") == self:GetAttribute("handler-homestate")) then
								control:ChildUpdate("stance", "homestate:"..self:GetAttribute("state-stance"))
							else
								control:ChildUpdate("stance", self:GetAttribute("state-stance"))
							end
						else
							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("homestate", self:GetAttribute("state-priority"))
							else
								control:ChildUpdate("homestate", "homestate")
							end
						end

						]])

	handler:SetAttribute("_onstate-pet", [[

						if (self:GetAttribute("statestack")) then
							if (self:GetAttribute("statestack"):find("pet")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("pet%d+", self:GetAttribute("state-pet") or "homestate"))
							elseif (self:GetAttribute("statestack"):find("homestate")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("homestate", self:GetAttribute("state-pet" or "homestate")))
							elseif (self:GetAttribute("state-pet")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack")..";"..self:GetAttribute("state-pet"))
							end
						else
							self:SetAttribute("statestack", self:GetAttribute("state-pet"))
						end

						if (self:GetAttribute("statestack"):find("^pet") or self:GetAttribute("statestack"):find("^homestate")) then

							self:SetAttribute("assertstate", "pet")

							self:SetAttribute("state-last", self:GetAttribute("state-pet"))

							self:SetAttribute("state-current", self:GetAttribute("state-pet"))

							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("stance", self:GetAttribute("state-priority"))
							elseif (self:GetAttribute("state-pet") and self:GetAttribute("state-pet") == self:GetAttribute("handler-homestate")) then
								control:ChildUpdate("pet", "homestate:"..self:GetAttribute("state-pet"))
							else
								control:ChildUpdate("pet", self:GetAttribute("state-pet"))
							end
						else
							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("homestate", self:GetAttribute("state-priority"))
							else
								control:ChildUpdate("homestate", "homestate")
							end
						end

						]])

	handler:SetAttribute("_onstate-custom", [[

						self:SetAttribute("assertstate", "custom")

						self:SetAttribute("state-last", self:GetAttribute("state-custom"))

						self:SetAttribute("state-current", self:GetAttribute("state-custom"))

						control:ChildUpdate("alt", self:GetAttribute("state-custom"))

						]])

	handler:SetAttribute("_onstate-current", [[ self:SetAttribute("activestate", self:GetAttribute("state-current") or "homestate") ]])

	handler:SetAttribute("statestack", "homestate")

	handler:SetAttribute("activestate", "homestate")

	handler:SetAttribute("state-last", "homestate")

	handler:HookScript("OnAttributeChanged",

		function(self,name,value)

		end)

	--handler:SetAttribute("_onshow", [[ control:ChildUpdate("onshow", "show") ]])

	--handler:SetAttribute("_onhide", [[ control:ChildUpdate("onshow", "hide") ]])

	handler:SetAttribute("_childupdate", [[

			if (not self:GetAttribute("editmode")) then

				self:SetAttribute("vishide", false)

				if (self:GetAttribute("hidestates")) then
					for state in gmatch(message, "[^;]+") do
						for hidestate in gmatch(self:GetAttribute("hidestates"), "[^:]+") do
							if (state == hidestate) then
								self:Hide(); self:SetAttribute("vishide", true)
							end
						end
					end
				end

				if (not self:IsShown() and not self:GetAttribute("vishide")) then
					self:Show()
				end
			end

	]] )

	handler:SetAllPoints(bar)

	bar.handler = handler;
	handler.bar = bar

end


function NeuronBar:CreateWatcher(bar)
	local watcher = CreateFrame("Frame", "NeuronBarWatcher"..bar:GetID(), bar.handler, "SecureHandlerStateTemplate")

	setmetatable(watcher, { __index = handlerMT })

	watcher:SetID(bar:GetID())

	watcher:SetAttribute("_onattributechanged", [[ ]])

	watcher:SetAttribute("_onstate-petbattle", [[

            if (self:GetAttribute("state-petbattle") == "hide") then
                self:GetParent():Hide()
            else
                if (not self:GetParent():IsShown()) then
                    if (not self:GetParent():GetAttribute("vishide") and not self:GetParent():GetAttribute("concealed")) then
                        self:GetParent():Show()
                    end
                end
            end
    ]])

	RegisterStateDriver(watcher, "petbattle", "[petbattle] hide; [nopetbattle] show")

end


function NeuronBar:Update(bar, show, hide)

	if(InCombatLockdown()) then
		return
	end

	local handler, driver = bar.handler, bar.driver

	bar.elapsed = 0;
	bar.alpha = bar.data.alpha;
	bar.alphaUp = bar.data.alphaUp

	if (bar.stateschanged) then

		NeuronBar:UpdateStates(handler, bar)

		bar.stateschanged = nil
	end

	if (bar.vischanged) then

		handler:SetAttribute("hidestates", bar.data.hidestates)

		NeuronBar:UpdateVisibility(driver, bar)

		bar.vischanged = nil
	end

	if (bar.countChanged) then

		NeuronBar:UpdateObjectData(bar)

		bar.countChanged = nil

	end

	NeuronBar:SetHidden(handler, bar, show, hide)
	NeuronBar:SetAutoHide(handler, bar)
	bar.text:SetText(bar.data.name)
	handler:SetAlpha(bar.data.alpha)
	NeuronBar:SaveData(bar)

	if (not hide and NeuronBarEditor and NeuronBarEditor:IsVisible()) then
		NEURON.NeuronGUI:UpdateBarGUI()
	end
end


function NeuronBar:GetPosition(bar, oFrame)
	local relFrame, point

	if (oFrame) then
		relFrame = oFrame
	else
		relFrame = bar:GetParent()
	end

	local s = bar:GetScale()
	local w, h = relFrame:GetWidth()/s, relFrame:GetHeight()/s
	local x, y = bar:GetCenter()
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


function NeuronBar:SetPosition(bar)
	if (bar.data.snapToPoint and bar.data.snapToFrame) then
		NeuronBar:StickToPoint(bar, _G[bar.data.snapToFrame], bar.data.snapToPoint, bar.data.padH, bar.data.padV)
	else

		local point, x, y = bar.data.point, bar.data.x, bar.data.y

		if (point:find("SnapTo")) then
			bar.data.point = "CENTER"; point = "CENTER"
		end

		bar:SetUserPlaced(false)
		bar:ClearAllPoints()
		bar:SetPoint("CENTER", "UIParent", point, x, y)
		bar:SetUserPlaced(true)
		bar:SetFrameStrata(bar.data.barStrata)

		if (bar.message) then
			bar.message:SetText(point:lower().."     x: "..format("%0.2f", x).."     y: "..format("%0.2f", y))
			bar.messagebg:SetWidth(bar.message:GetWidth()*1.05)
			bar.messagebg:SetHeight(bar.message:GetHeight()*1.1)
		end

		bar.posSet = true
	end
end


function NeuronBar:SetFauxState(bar, state)
	local object

	bar.objCount = 0
	bar.handler:SetAttribute("fauxstate", state)

	--for objID in gmatch(bar.data.objectList, "[^;]+") do
	for i, objID in ipairs(bar.data.objectList) do

		object = _G[bar.objPrefix..tostring(objID)]

		if (object) then
			NEURON.NeuronButton:SetFauxState(object, state)
		end
	end

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		NEURON.NeuronGUI:UpdateObjectGUI()
	end
end


---loads all the object stored for a given bar
function NeuronBar:LoadObjects(bar, init)
	local object, spec

	if (bar.data.multiSpec) then
		spec = GetSpecialization()
	else
		spec = 1
	end

	bar.objCount = 0


	--for objID in gmatch(bar.data.objectList, "[^;]+") do
	for i, objID in ipairs(bar.data.objectList) do
		object = _G[bar.objPrefix..tostring(objID)]


		if (object) then

			---all of these objects need to stay as "object:****" because which SetData/LoadData/etc is bar dependent. Symlinks are made to the asociated bar objects to these class functions
			object:SetData(object, bar)
			object:LoadData(object, spec, bar.handler:GetAttribute("activestate"))
			object:SetAux(object)
			object:SetType(object, nil, nil, init)

			object:SetObjectVisibility(object)

			bar.objCount = bar.objCount + 1
			bar.countChanged = true
		end
	end
end


function NeuronBar:SetObjectLoc(bar)
	local width, height, num, count, origCol = 0, 0, 0, bar.objCount, bar.data.columns
	local x, y, object, lastObj, placed
	local shape, padH, padV, arcStart, arcLength = bar.data.shape, bar.data.padH, bar.data.padV, bar.data.arcStart, bar.data.arcLength
	local cAdjust, rAdjust = 0.5, 1
	local columns, rows

	if (not origCol) then
		origCol = count; rows = 1
	else
		rows = (round(ceil(count/bar.data.columns), 1)/2)+0.5
	end

	--for objID in gmatch(bar.data.objectList, "[^;]+") do
	for i, objID in ipairs(bar.data.objectList) do
		object = _G[bar.objPrefix..tostring(objID)]

		if (object and num < count) then
			object:ClearAllPoints()
			object:SetParent(bar.handler)
			object:SetAttribute("lastPos", nil)
			width = object:GetWidth(); height = object:GetHeight()

			if (count > origCol and mod(count, origCol)~=0 and rAdjust == 1) then
				columns = (mod(count, origCol))/2
			elseif (origCol >= count) then
				columns = count/2
			else
				columns = origCol/2
			end

			if (shape == 2) then
				if (not placed) then
					placed = arcStart
				end

				x = ((width+padH)*(count/math.pi))*(cos(placed))
				y = ((width+padV)*(count/math.pi))*(sin(placed))

				object:SetPoint("CENTER", bar, "CENTER", x, y)

				placed = placed - (arcLength/count)

			elseif (shape == 3) then
				if (not placed) then
					placed = arcStart
					object:SetPoint("CENTER", bar, "CENTER", 0, 0)
					placed = placed - (arcLength/count)

				else
					x = ((width+padH)*(count/math.pi))*(cos(placed))
					y = ((width+padV)*(count/math.pi))*(sin(placed))

					object:SetPoint("CENTER", bar, "CENTER", x, y)
					placed = placed - (arcLength/(count-1))
				end
			else
				if (not placed) then
					placed = 0
				end

				x = -(width + padH) * (columns-cAdjust)
				y = (height + padV) * (rows-rAdjust)

				object:SetPoint("CENTER", bar, "CENTER", x, y)
				placed = placed + 1; cAdjust = cAdjust + 1

				if (placed >= columns*2) then
					placed = 0
					cAdjust = 0.5
					rAdjust = rAdjust + 1
				end
			end

			lastObj = object
			num = num + 1
			object:SetAttribute("barPos", num)
			object:SetData(object, bar)
		end
	end

	if (lastObj) then
		lastObj:SetAttribute("lastPos", true)
	end
end


function NeuronBar:SetPerimeter(bar)
	local num, count = 0, bar.objCount
	local object

	bar.objCount = 0
	bar.top = nil; bar.bottom = nil; bar.left = nil; bar.right = nil

	--for objID in gmatch(bar.data.objectList, "[^;]+") do
	for i, objID in ipairs(bar.data.objectList) do
		object = _G[bar.objPrefix..tostring(objID)]

		if (object and num < count) then
			local objTop, objBottom, objLeft, objRight = object:GetTop(), object:GetBottom(), object:GetLeft(), object:GetRight()
			local scale = 1
			--See if this fixes the ranom position error that happens
			if not objTop then return end

			bar.objCount = bar.objCount + 1

			if (bar.top) then
				if (objTop*scale > bar.top) then bar.top = objTop*scale end
			else bar.top = objTop*scale end

			if (bar.bottom) then
				if (objBottom*scale < bar.bottom) then bar.bottom = objBottom*scale end
			else bar.bottom = objBottom*scale end

			if (bar.left) then
				if (objLeft*scale < bar.left) then bar.left = objLeft*scale end
			else bar.left = objLeft*scale end

			if (bar.right) then
				if (objRight*scale > bar.right) then bar.right = objRight*scale end
			else bar.right = objRight*scale end

			num = num + 1
		end
	end
end


function NeuronBar:SetDefaults(bar, defaults)
	if (defaults) then
		for k,v in pairs(defaults) do
			bar.data[k] = v
		end
	end

	NeuronBar:SaveData(bar)
end


function NeuronBar:SetRemap_Paged(bar)
	bar.data.remap = ""

	for i=1,6 do
		bar.data.remap = bar.data.remap..i..":"..i..";"
	end

	bar.data.remap = gsub(bar.data.remap, ";$", "")
end


function NeuronBar:SetRemap_Stance(bar)
	local start = tonumber(MAS.stance.homestate:match("%d+"))

	if (start) then
		bar.data.remap = ""

		for i=start,GetNumShapeshiftForms() do
			bar.data.remap = bar.data.remap..i..":"..i..";"
		end

		bar.data.remap = gsub(bar.data.remap, ";$", "")


		if (NEURON.class == "ROGUE") then
			bar.data.remap = bar.data.remap..";2:2"
		end
	end
end


function NeuronBar:SetSize(bar)
	if (bar.right) then
		bar:SetWidth(((bar.right-bar.left)+5)*(bar.data.scale))
		bar:SetHeight(((bar.top-bar.bottom)+5)*(bar.data.scale))
	else
		bar:SetWidth(195)
		bar:SetHeight(36*(bar.data.scale))
	end
end

----------------------------------------------------------------------
----------------------------------------------------------------------
------------------------Event Handlers __-----------------------------
---TODO:I need to figure out what to do with this
function NeuronBar:ACTIONBAR_SHOWGRID(bar, ...)
	if (not InCombatLockdown() and bar:IsVisible()) then
		bar:Hide()
		bar.showgrid = true
	end
end

function NeuronBar:ACTIONBAR_HIDEGRID(bar, ...)
	if (not InCombatLockdown() and bar.showgrid) then
		bar:Show()
		bar.showgrid = nil
	end
end

function NeuronBar:ACTIVE_TALENT_GROUP_CHANGED(bar, ...)
	if (NEURON.PEW) then
		bar.stateschanged = true
		bar.vischanged = true
		NEURON.NeuronBar:Update(bar)
	end
end
----------------------------------------------------------------------
----------------------------------------------------------------------




----------------------------------------------------------------------
----------------------------------------------------------------------
------------------------OnEvent Functions-----------------------------
---this function brokers the on event call to the correct bar
function NeuronBar:OnEvent(bar,event, ...)
	if (NeuronBar[event]) then
		NeuronBar[event](NeuronBar, bar, ...)
	end
end


function NeuronBar:OnClick(bar, ...)
	local click, down, newBar = select(1, ...), select(2, ...)

	if (not down) then
		newBar = NeuronBar:ChangeBar(bar)
	end

	bar.click = click
	bar.dragged = false
	bar.elapsed = 0
	bar.pushed = 0

	if (IsShiftKeyDown() and not down) then

		if (bar.microAdjust) then
			bar.microAdjust = false
			bar:EnableKeyboard(false)
			bar.message:Hide()
			bar.messagebg:Hide()
		else
			bar.data.snapTo = false
			bar.data.snapToPoint = false
			bar.data.snapToFrame = false
			bar.microAdjust = 1
			bar:EnableKeyboard(true)
			bar.message:Show()
			bar.message:SetText(bar.data.point:lower().."     x: "..format("%0.2f", bar.data.x).."     y: "..format("%0.2f", bar.data.y))
			bar.messagebg:Show()
			bar.messagebg:SetWidth(bar.message:GetWidth()*1.05)
			bar.messagebg:SetHeight(bar.message:GetHeight()*1.1)
		end

	elseif (click == "MiddleButton") then
		if (GetMouseFocus() ~= NEURON.CurrentBar) then
			newBar = NeuronBar:ChangeBar(bar)
		end

		if (down) then
			--NEURON:ConcealBar(nil, true)
		end

	elseif (click == "RightButton" and not bar.action and not down) then
		bar.mousewheelfunc = nil

		if (NeuronBarEditor) then
			if (not newBar and NeuronBarEditor:IsVisible()) then
				NeuronBarEditor:Hide()
			else
				NeuronBarEditor:Show()
			end
		end

	elseif (not down) then
		if (not newBar) then
			--updateState(bar, 1)
		end
	end

	if (not down and NeuronBarEditor and NeuronBarEditor:IsVisible()) then
		NEURON.NeuronGUI:UpdateBarGUI(newBar)
	end
end


function NeuronBar:OnEnter(bar, ...)
	if (bar.data.conceal) then
		bar:SetBackdropColor(1,0,0,0.6)
	else
		bar:SetBackdropColor(0,0,1,0.5)
	end

	bar.text:Show()
end


function NeuronBar:OnLeave(bar, ...)
	if (bar ~= NEURON.CurrentBar) then
		if (bar.data.conceal) then
			bar:SetBackdropColor(1,0,0,0.4)
		else
			bar:SetBackdropColor(0,0,0,0.4)
		end
	end

	if (bar ~= NEURON.CurrentBar) then
		bar.text:Hide()
	end
end


function NeuronBar:OnDragStart(bar, ...)
	NeuronBar:ChangeBar(bar)

	bar:SetFrameStrata(bar.data.barStrata)
	bar:EnableKeyboard(false)

	bar.adjusting = true
	bar.selected = true
	bar.isMoving = true

	bar.data.snapToPoint = false
	bar.data.snapToFrame = false

	bar:StartMoving()
end


function NeuronBar:OnDragStop(bar, ...)
	local point
	bar:StopMovingOrSizing()

	for _,thisbar in pairs(BARIndex) do
		if (not point and bar.data.snapTo and thisbar.data.snapTo and bar ~= thisbar) then
			point = NeuronBar:Stick(bar, thisbar, DB.snapToTol, bar.data.padH, bar.data.padV)

			if (point) then
				bar.data.snapToPoint = point
				bar.data.snapToFrame = thisbar:GetName()
				bar.data.point = "SnapTo: "..point
				bar.data.x = 0
				bar.data.y = 0
			end
		end
	end

	if (not point) then
		bar.data.snapToPoint = false
		bar.data.snapToFrame = false
		bar.data.point, bar.data.x, bar.data.y = NeuronBar:GetPosition(bar)
		NeuronBar:SetPosition(bar)
	end

	if (bar.data.snapTo and not bar.data.snapToPoint) then
		NeuronBar:StickToEdge(bar)
	end

	bar.isMoving = false
	bar.dragged = true
	bar.elapsed = 0
	NeuronBar:Update(bar)
end

function NeuronBar:OnKeyDown(bar, key, onupdate)
	if (bar.microAdjust) then
		bar.keydown = key

		if (not onupdate) then
			bar.elapsed = 0
		end

		bar.data.point, bar.data.x, bar.data.y = NeuronBar:GetPosition(bar)
		bar:SetUserPlaced(false)
		bar:ClearAllPoints()

		if (key == "UP") then
			bar.data.y = bar.data.y + .1 * bar.microAdjust
		elseif (key == "DOWN") then
			bar.data.y = bar.data.y - .1 * bar.microAdjust
		elseif (key == "LEFT") then
			bar.data.x = bar.data.x - .1 * bar.microAdjust
		elseif (key == "RIGHT") then
			bar.data.x = bar.data.x + .1 * bar.microAdjust
		elseif (not key:find("SHIFT")) then
			bar.microAdjust = false
			bar:EnableKeyboard(false)
		end

		NeuronBar:SetPosition(bar)
		NeuronBar:SaveData(bar)
	end
end


function NeuronBar:OnKeyUp(bar, key)
	if (bar.microAdjust and not key:find("SHIFT")) then
		bar.microAdjust = 1
		bar.keydown = nil
		bar.elapsed = 0
	end
end


function NeuronBar:OnMouseWheel(delta)
	stackWatch:Show()

	NeuronTooltipScan:SetOwner(UIParent, "ANCHOR_NONE")
	NeuronTooltipScan:SetFrameStack()

	local objects = NEURON:GetParentKeys(NeuronTooltipScan)
	local _, bar, level, text, added

	for k,v in pairs(objects) do

		if (_G[v]:IsObjectType("FontString")) then
			text = _G[v]:GetText()

			if (text and text:find("%p%d+%p")) then
				_, level, text = (" "):split(text)

				if (text and BARNameIndex[text]) then
					level = tonumber(level:match("%d+"))

					if (level and level < 3) then
						added = nil
						bar = BARNameIndex[text]

						for k,v in pairs(barStack) do
							if (bar == v) then
								added = true
							end
						end

						if (not added) then
							tinsert(barStack, bar)
						end
					end
				end
			end
		end
	end

	bar = tremove(barStack, 1)

	if (bar) then
		NeuronBar:ChangeBar(bar)
	end
end


function NeuronBar:OnShow(bar)
	if (bar == NEURON.CurrentBar) then

		if (bar.data.conceal) then
			bar:SetBackdropColor(1,0,0,0.6)
		else
			bar:SetBackdropColor(0,0,1,0.5)
		end

	else
		if (bar.data.conceal) then
			bar:SetBackdropColor(1,0,0,0.4)
		else
			bar:SetBackdropColor(0,0,0,0.4)
		end
	end

	bar.handler:SetAttribute("editmode", true)
	bar.handler:Show()
	NeuronBar:UpdateObjectVisibility(bar)
	bar:EnableKeyboard(false)
end


function NeuronBar:OnHide(bar)
	bar.handler:SetAttribute("editmode", nil)

	if (bar.handler:GetAttribute("vishide")) then
		bar.handler:Hide()
	end

	NeuronBar:UpdateObjectVisibility(bar)
	bar:EnableKeyboard(false)
end


function NeuronBar:Pulse(bar, elapsed)
	alphaTimer = alphaTimer + elapsed * 1.5

	if (alphaDir == 1) then
		if (1-alphaTimer <= 0) then
			alphaDir = 0; alphaTimer = 0
		end
	else
		if (alphaTimer >= 1) then
			alphaDir = 1; alphaTimer = 0
		end
	end

	if (alphaDir == 1) then
		if ((1-(alphaTimer)) >= 0) then
			bar:SetAlpha(1-(alphaTimer))
		end
	else
		if ((alphaTimer) <= 1) then
			bar:SetAlpha((alphaTimer))
		end
	end

	bar.pulse = true
end

---TODO: This is probably a source of inefficiency
function NeuronBar:OnUpdate(bar, elapsed)
	if (NEURON.PEW) then

		if (bar.elapsed) then
			bar.elapsed = bar.elapsed + elapsed

			if (bar.elapsed > 10) then
				bar.elapsed = 0.75
			end

			if (bar.microAdjust and not bar.action) then
				NeuronBar:Pulse(bar, elapsed)

				if (bar.keydown and bar.elapsed >= 0.5) then
					bar.microAdjust = bar.microAdjust + 1
					bar:OnKeyDown(bar.keydown, bar.microAdjust)
				end

			elseif (bar.pulse) then
				bar:SetAlpha(1)
				bar.pulse = nil
			end

			if (bar.hover) then
				bar.elapsed = 0
			end
		end

		if (GetMouseFocus() == bar) then
			if (not bar.wheel) then
				bar:EnableMouseWheel(true); bar.wheel = true
			end
		elseif (bar.wheel) then
			bar:EnableMouseWheel(false); bar.wheel = nil
		end

	end
end


---------------------------------------------------------------------------
---------------------------------------------------------------------------

function NeuronBar:SaveData(bar)
	local id = bar:GetID()

	if (bar.barDB[id]) then
		for key,value in pairs(bar.data) do
			bar.barDB[id][key] = value
		end
	else
		NEURON:Print("DEBUG: Bad Global Save Data for "..bar:GetName().." ?")
	end

	if (bar.barDB[id]) then
		for key,value in pairs(bar.data) do
			bar.barDB[id][key] = value
		end
	else
		NEURON:Print("DEBUG: Bad Character Save Data for "..bar:GetName().." ?")
	end
end


function NeuronBar:LoadData(bar)
	local id = bar:GetID()

	if (not bar.barDB[id]) then
		bar.barDB[id] = CopyTable(NEURON.barDEF)
	end

	bar.data = CopyTable(bar.barDB[id])

	if (#bar.data.name < 1) then
		bar.data.name = bar.barLabel.." "..bar:GetID()
	end
end


function NeuronBar:UpdateObjectData(bar)
	local object

	--for objID in gmatch(bar.data.objectList, "[^;]+") do
	for _, objID in pairs(bar.data.objectList) do
		object = _G[bar.objPrefix..tostring(objID)]

		if (object) then
			object:SetData(object, bar)
		end
	end
end


function NeuronBar:UpdateObjectVisibility(bar, show)
	local object
	for i, objID in ipairs(bar.data.objectList) do
		object = _G[bar.objPrefix..tostring(objID)]

		if (object) then
			object:SetObjectVisibility(object, show)
		end
	end
end



function NeuronBar:CreateBar(index, class, id)
	local data = NEURON.RegisteredBarData[class]
	local newBar

	if (data) then
		if (not id) then
			id = 1

			for _ in ipairs(data.DB) do
				id = id + 1
			end

			newBar = true
		end

		local bar

		if (_G["Neuron"..data.barType..id]) then
			bar = _G["Neuron"..data.barType..id]
		else
			---this is the create of our bar object frame
			bar = CreateFrame("CheckButton", "Neuron"..data.barType..id, UIParent, "NeuronBarTemplate")
			---this is assigning the metatable of a CheckButton to our new bar object, giving it all a CheckButtons features, and thus finishing the object construction
			setmetatable(bar, { __index = BAR })
		end

		for key,value in pairs(data) do
			bar[key] = value
		end

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

		bar:SetScript("OnClick", function(self, ...) NeuronBar:OnClick(self, ...) end)
		bar:SetScript("OnDragStart", function(self, ...) NeuronBar:OnDragStart(self, ...) end)
		bar:SetScript("OnDragStop", function(self, ...) NeuronBar:OnDragStop(self, ...) end)
		bar:SetScript("OnEnter", function(self, ...) NeuronBar:OnEnter(self, ...) end)
		bar:SetScript("OnLeave", function(self, ...) NeuronBar:OnLeave(self, ...) end)
		bar:SetScript("OnEvent", function(self, event, ...) NeuronBar:OnEvent(self, event, ...) end)
		bar:SetScript("OnKeyDown", function(self, key, onupdate) NeuronBar:OnKeyDown(self, key, onupdate) end)
		bar:SetScript("OnKeyUp", function(self, key) NeuronBar:OnKeyUp(self, key) end)
		bar:SetScript("OnMouseWheel", function(delta) NeuronBar:OnMouseWheel(delta) end)
		bar:SetScript("OnShow", function(self) NeuronBar:OnShow(self) end)
		bar:SetScript("OnHide", function(self) NeuronBar:OnHide(self) end)
		bar:SetScript("OnUpdate", function(self, elapsed) NeuronBar:OnUpdate(self, elapsed) end)

		bar:RegisterEvent("ACTIONBAR_SHOWGRID")
		bar:RegisterEvent("ACTIONBAR_HIDEGRID")
		bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")


		NeuronBar:CreateDriver(bar)
		NeuronBar:CreateHandler(bar)
		NeuronBar:CreateWatcher(bar)

		NEURON.NeuronBar:LoadData(bar)

		if (not newBar) then
			bar:Hide()
		end

		BARIndex[index] = bar

		BARNameIndex[bar:GetName()] = bar

		return bar, newBar
	end
end


function NeuronBar:CreateNewBar(class, id, firstRun)
	if (class and NEURON.RegisteredBarData[class]) then
		local index = 1

		for _ in ipairs(BARIndex) do
			index = index + 1
		end

		local bar, newBar = NeuronBar:CreateBar(index, class, id)

		if (firstRun) then
			NeuronBar:SetDefaults(bar, bar.Def)
		end

		if (newBar) then
			NeuronBar:Load(bar)
			NeuronBar:ChangeBar(bar)

			---------------------------------
			 if (class == "extrabar") then --this is a hack to get around an issue where the extrabar wasn't autohiding due to bar visibility states. There most likely a way better way to do this in the future. FIX THIS!
				bar.data.hidestates = ":extrabar0:"
				bar.vischanged = true
				NeuronBar:Update(bar)
			end
			if (class == "pet") then --this is a hack to get around an issue where the extrabar wasn't autohiding due to bar visibility states. There most likely a way better way to do this in the future. FIX THIS!
				bar.data.hidestates = ":pet0:"
				bar.vischanged = true
				NeuronBar:Update(bar)
			end
			-----------------------------------
		end

		return bar
	else
		NEURON.PrintBarTypes()
	end
end

function NeuronBar:ChangeBar(bar)
	local newBar = false

	if (NEURON.PEW) then

		if (bar and NEURON.CurrentBar ~= bar) then
			NEURON.CurrentBar = bar

			bar.selected = true
			bar.action = nil

			bar:SetFrameLevel(3)

			if (bar.data.hidden) then
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

				if (v.data.conceal) then
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
			NeuronBar:OnEnter(NEURON.CurrentBar)
		end
	end

	return newBar
end

function NeuronBar:DeleteBar(bar)
	local handler = bar.handler

	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")
	handler:SetAttribute("showstates", "homestate")
	NeuronBar:ClearStates(handler, bar, "homestate")

	for state, values in pairs(MAS) do
		if (bar.data[state] and bar[state] and bar[state].registered) then
			if (state == "custom" and bar.data.customRange) then
				local start = tonumber(string.match(bar.data.customRange, "^%d+"))
				local stop = tonumber(string.match(bar.data.customRange, "%d+$"))

				if (start and stop) then
					NeuronBar:ClearStates(handler, bar, state)--, start, stop)
				end
			else
				NeuronBar:ClearStates(handler, bar, state)--, values.rangeStart, values.rangeStop)
			end
		end
	end

	NeuronBar:RemoveObjectsFromBar(bar, bar.objCount)

	bar:SetScript("OnClick", function() end)
	bar:SetScript("OnDragStart", function() end)
	bar:SetScript("OnDragStop", function() end)
	bar:SetScript("OnEnter", function() end)
	bar:SetScript("OnLeave", function() end)
	bar:SetScript("OnEvent", function() end)
	bar:SetScript("OnKeyDown", function() end)
	bar:SetScript("OnKeyUp", function() end)
	bar:SetScript("OnMouseWheel", function() end)
	bar:SetScript("OnShow", function() end)
	bar:SetScript("OnHide", function() end)
	bar:SetScript("OnUpdate", function() end)

	bar:UnregisterEvent("ACTIONBAR_SHOWGRID")
	bar:UnregisterEvent("ACTIONBAR_HIDEGRID")
	bar:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

	bar:SetWidth(36)
	bar:SetHeight(36)
	bar:ClearAllPoints()
	bar:SetPoint("CENTER")
	bar:Hide()

	BARIndex[bar.index] = nil
	BARNameIndex[bar:GetName()] = nil

	bar.barDB[bar:GetID()] = nil

	if (NeuronBarEditor and NeuronBarEditor:IsVisible()) then
		NEURON.NeuronGUI:UpdateBarGUI()
	end
end


function NeuronBar:AddObjectToList(bar, object)

	if (not bar.data.objectList or bar.data.objectList == {}) then
		bar.data.objectList[1] = object.id
	elseif (self.class == "bag") then
		table.insert(bar.data.objectList, 1, object.id) --for bag bars insert the object to the start of the list
	else
		bar.data.objectList[#bar.data.objectList +1] = object.id
	end

	object["bar"] = bar
end


function NeuronBar:AddObjectsToBar(bar, num)

	num = tonumber(num)

	if (not num) then
		num = 1
	end

	for i=1,num do

		local object
		local id = 1

		for index in ipairs(bar.objTable) do
			if bar.objTable[index]["bar"] then
				id = index + 1
			end
		end

		if (bar.objCount < bar.objMax) then

			if bar.objTable[id] and not bar.objTable[id]["bar"] then --checks to see if the object exists in the object table, and if the object belongs to a bar
				object = bar.objTable[id]
			else
				object = NEURON.NeuronButton:CreateNewObject(bar.class, id)
			end
			NeuronBar:AddObjectToList(bar, object)
		end

	end

	NeuronBar:LoadObjects(bar)
	NeuronBar:SetObjectLoc(bar)
	NeuronBar:SetPerimeter(bar)
	NeuronBar:SetSize(bar)
	NeuronBar:Update(bar)
	NeuronBar:UpdateObjectVisibility(bar)

end


function NeuronBar:RemoveObject(bar, object, objID)
	object:ClearAllPoints()

	object.config.scale = 1
	object.config.XOffset = 0
	object.config.YOffset = 0
	object.config.target = "none"

	object.config.mouseAnchor = false
	object.config.clickAnchor = false
	object.config.anchorDelay = false
	object.config.anchoredBar = false

	if (object.binder) then
		NEURON.NeuronBinder:ClearBindings(object)
	end

	NeuronBar:RemoveObjectFromList(bar, object, objID)

	object:SetParent(TRASHCAN)

end


function NeuronBar:RemoveObjectFromList(bar, object, objID)

	local index = tFind(bar.data.objectList, objID)

	if index == 0 then --objectID not contained in the list. This shouldn't even trip, but just in case
		return
	end

	table.remove(bar.data.objectList, index)
	object["bar"] = nil

end


function NeuronBar:RemoveObjectsFromBar(bar, num)

	if (not num) then
		num = 1
	end


	for i=1,num do

		local objID

		if bar.class ~= "bag" then
			objID = bar.data.objectList[#bar.data.objectList]
		else
			objID = bar.data.objectList[1] --for bag bars, remove from the front of the list
		end

		if (objID) then
			local object = _G[bar.objPrefix..tostring(objID)]
			if (object) then
				NeuronBar:RemoveObject(bar, object, objID)

				bar.objCount = bar.objCount - 1
				bar.countChanged = true
			end

			NeuronBar:SetObjectLoc(bar)
			NeuronBar:SetPerimeter(bar)
			NeuronBar:SetSize(bar)
			NeuronBar:Update(bar)
		end
	end


end


function NeuronBar:SetState(bar, msg, gui, checked, query)
	if (msg) then
		local state = msg:match("^%S+")
		local command = msg:gsub(state, "");
		command = command:gsub("^%s+", "")

		if (not MAS[state]) then
			if (not gui) then
				NEURON:PrintStateList()
			else
				NEURON:Print("GUI option error")
			end

			return
		end

		if (gui) then
			if (checked) then
				bar.data[state] = true
			else
				bar.data[state] = false
			end
		else
			local toggle = bar.data[state]

			if (toggle) then
				bar.data[state] = false
			else
				bar.data[state] = true
			end
		end

		if (state == "paged") then
			bar.data.stance = false
			bar.data.pet = false

			if (bar.data.paged) then
				NeuronBar:SetRemap_Paged(bar)
			else
				bar.data.remap = false
			end
		end

		if (state == "stance") then
			bar.data.paged = false
			bar.data.pet = false


			if (NEURON.class == "ROGUE" and bar.data.stealth) then
				bar.data.stealth = false
			end

			if (bar.data.stance) then
				NeuronBar:SetRemap_Stance(bar)
			else
				bar.data.remap = false
			end
		end

		if (state == "custom") then
			if (bar.data.custom) then
				local count, newstates = 0, ""

				bar.data.customNames = {}

				for states in gmatch(command, "[^;]+") do
					if string.find(states, "%[(.+)%]") then
						bar.data.customRange = "1;"..count

						if (count == 0) then
							newstates = states.." homestate;"
							bar.data.customNames["homestate"] = states
						else
							newstates = newstates..states.." custom"..count..";"
							bar.data.customNames["custom"..count] = states
						end

						count = count + 1
					else
						NEURON:Print(states.." not formated properly and skipped")
					end
				end

				if (newstates ~= "" ) then
					bar.data.custom = newstates
				else
					bar.data.custom = false
					bar.data.customNames = false
					bar.data.customRange = false
				end

			else
				bar.data.customNames = false
				bar.data.customRange = false
			end

			--Clears any previous set cusom vis settings
			for states in gmatch(bar.data.hidestates, "custom%d+") do
				bar.data.hidestates = bar.data.hidestates:gsub(states..":", "")
			end
			if not bar.data.hidestates then NEURON:Print("OOPS")
			end
		end

		if (state == "pet") then
			bar.data.paged = false
			bar.data.stance = false
		end

		bar.stateschanged = true
		NeuronBar:Update(bar)

	elseif (not gui) then
		wipe(statetable)

		for k,v in pairs(NEURON.STATEINDEX) do

			if (bar.data[k]) then
				tinsert(statetable, k..": on")
			else
				tinsert(statetable, k..": off")
			end
		end

		table.sort(statetable)

		for k,v in ipairs(statetable) do
			NEURON:Print(v)
		end
	end

end


--I have no clue what or how any of this works. I took out the annoying print statements, but for now I'll just leave it. -Soyier

function NeuronBar:SetVisibility(bar, msg, gui, checked, query)
	if (msg) then
		wipe(statetable)
		local toggle, index, num = (" "):split(msg)
		toggle = toggle:lower()

		if (toggle and NEURON.STATEINDEX[toggle]) then
			if (index) then
				num = index:match("%d+")

				if (num) then
					local hidestate = NEURON.STATEINDEX[toggle]..num
					if (NEURON.STATES[hidestate]) or (toggle == "custom" and bar.data.customNames) then
						if (bar.data.hidestates:find(hidestate)) then
							bar.data.hidestates = bar.data.hidestates:gsub(hidestate..":", "")
						else
							bar.data.hidestates = bar.data.hidestates..hidestate..":"
						end
					else
						NEURON:Print(L["Invalid index"]); return
					end

				elseif (index == L["Show"]) then
					local hidestate = NEURON.STATEINDEX[toggle].."%d+"
					bar.data.hidestates = bar.data.hidestates:gsub(hidestate..":", "")
				elseif (index == L["Hide"]) then
					local hidestate = NEURON.STATEINDEX[toggle]

					for state in pairs(NEURON.STATES) do
						if (state:find("^"..hidestate) and not bar.data.hidestates:find(state)) then
							bar.data.hidestates = bar.data.hidestates..state..":"
						end
					end
				end
			end

			if (not silent) then
				local hidestates = bar.data.hidestates
				local desc, showhide

				local highindex = 0

				for state,desc in pairs(NEURON.STATES) do
					index = state:match("%d+$")

					if (index) then
						index = tonumber(index)

						if (index and state:find("^"..toggle)) then
							if (hidestates:find(state)) then
								statetable[index] = desc..":".."Hide:"..state
							else
								statetable[index] = desc..":".."Show:"..state
							end

							if (index > highindex) then
								highindex = index
							end
						end
					end
				end

				for i=1,highindex do
					if (not statetable[i]) then
						statetable[i] = "ignore"
					end
				end

				if (#statetable > 0) then
					--[[if (statetable[0]) then
						desc, showhide = (":"):split(statetable[0])
					end]]

					for k,v in ipairs(statetable) do
						if (v ~= "ignore") then
							desc, showhide = (":"):split(v)
						end
					end
				end
			end

			bar.vischanged = true
			NeuronBar:Update(bar)
		else
			NEURON:PrintStateList()
		end
	else
	end
end


function NeuronBar:AutoHideBar(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.autoHide
	end

	if (gui) then
		if (checked) then
			bar.data.autoHide = true
		else
			bar.data.autoHide = false
		end

	else
		local toggle = bar.data.autoHide

		if (toggle) then
			bar.data.autoHide = false
		else
			bar.data.autoHide = true
		end
	end

	NeuronBar:Update(bar)
end


function NeuronBar:ShowGridSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.showGrid
	end

	if (gui) then
		if (checked) then
			bar.data.showGrid = true
		else
			bar.data.showGrid = false
		end
	else
		if (bar.data.showGrid) then
			bar.data.showGrid = false
		else
			self.data.showGrid = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:UpdateObjectVisibility(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:spellGlowMod(bar, msg, gui)
	if (msg:lower() == "default") then
		if (bar.data.spellGlowDef) then
			bar.data.spellGlowDef = false
		else
			bar.data.spellGlowDef = true
			bar.data.spellGlowAlt = false
		end

		if (not bar.data.spellGlowDef and not bar.data.spellGlowAlt) then
			bar.data.spellGlowDef = true
		end

	elseif (msg:lower() == "alt") then
		if (bar.data.spellGlowAlt) then
			bar.data.spellGlowAlt = false
		else
			bar.data.spellGlowAlt = true
			bar.data.spellGlowDef = false
		end

		if (not bar.data.spellGlowDef and not bar.data.spellGlowAlt) then
			bar.data.spellGlowDef = true
		end

	elseif (not gui) then
		NEURON:Print(L["Spellglow_Instructions"])
	end
end


function NeuronBar:SpellGlowSet(bar, msg, gui, checked, query)
	if (query) then
		if (msg == "default") then
			return bar.data.spellGlowDef
		elseif(msg == "alt") then
			return bar.data.spellGlowAlt
		else
			return bar.data.spellGlow
		end
	end

	if (gui) then
		if (msg) then
			NeuronBar:spellGlowMod(bar, msg, gui)
		elseif (checked) then
			bar.data.spellGlow = true
		else
			bar.data.spellGlow = false
		end

	else
		if (msg) then
			NeuronBar:spellGlowMod(bar, msg, gui)
		elseif (bar.data.spellGlow) then
			bar.data.spellGlow = false
		else
			bar.data.spellGlow = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:SnapToBar(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.snapTo
	end

	if (gui) then
		if (checked) then
			bar.data.snapTo = true
		else
			bar.data.snapTo = false
		end
	else
		local toggle = bar.data.snapTo

		if (toggle) then
			bar.data.snapTo = false
			bar.data.snapToPoint = false
			bar.data.snapToFrame = false

			bar:SetUserPlaced(true)
			bar.data.point, bar.data.x, bar.data.y = NeuronBar:GetPosition(bar)
			NeuronBar:SetPosition(bar)
		else
			bar.data.snapTo = true
		end
	end

	NeuronBar:Update(bar)
end

function NeuronBar:UpClicksSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.upClicks
	end

	if (gui) then
		if (checked) then
			bar.data.upClicks = true
		else
			bar.data.upClicks = false
		end

	else
		if (bar.data.upClicks) then
			bar.data.upClicks = false
		else
			bar.data.upClicks = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:DownClicksSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.downClicks
	end

	if (gui) then
		if (checked) then
			bar.data.downClicks = true
		else
			bar.data.downClicks = false
		end

	else
		if (bar.data.downClicks) then
			bar.data.downClicks = false
		else
			bar.data.downClicks = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:MultiSpecSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.multiSpec
	end

	if (gui) then
		if (checked) then
			bar.data.multiSpec = true
		else
			bar.data.multiSpec = false
		end
	else
		local toggle = bar.data.multiSpec

		if (toggle) then
			bar.data.multiSpec = false
		else
			bar.data.multiSpec = true
		end
	end

	NEURON.NeuronButton:UpdateObjectSpec(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:ConcealBar(bar, msg, gui, checked, query)
	if (InCombatLockdown()) then return end

	if (query) then
		return bar.data.conceal
	end

	if (gui) then
		if (checked) then
			bar.data.conceal = true
		else
			bar.data.conceal = false
		end

	else
		local toggle = bar.data.conceal

		if (toggle) then
			bar.data.conceal = false
		else
			bar.data.conceal = true
		end
	end

	if (bar.data.conceal) then
		if (bar.selected) then
			bar:SetBackdropColor(1,0,0,0.6)
		else
			bar:SetBackdropColor(1,0,0,0.4)
		end
	else
		if (bar.selected) then
			bar:SetBackdropColor(0,0,1,0.5)
		else
			bar:SetBackdropColor(0,0,0,0.4)
		end
	end

	NeuronBar:Update(bar)
end


function NeuronBar:barLockMod(bar, msg, gui)
	if (msg:lower() == "alt") then
		if (bar.data.barLockAlt) then
			bar.data.barLockAlt = false
		else
			bar.data.barLockAlt = true
		end

	elseif (msg:lower() == "ctrl") then
		if (bar.data.barLockCtrl) then
			bar.data.barLockCtrl = false
		else
			bar.data.barLockCtrl = true
		end

	elseif (msg:lower() == "shift") then
		if (bar.data.barLockShift) then
			bar.data.barLockShift = false
		else
			bar.data.barLockShift = true
		end

	elseif (not gui) then
		NEURON:Print(L["Bar_Lock_Modifier_Instructions"])
	end
end

function NeuronBar:LockSet(bar, msg, gui, checked, query)
	if (query) then
		if (msg == "shift") then
			return bar.data.barLockShift
		elseif(msg == "ctrl") then
			return bar.data.barLockCtrl
		elseif(msg == "alt") then
			return bar.data.barLockAlt
		else
			return bar.data.barLock
		end
	end

	if (gui) then
		if (msg) then
			NeuronBar:barLockMod(bar, msg, gui)
		elseif (checked) then
			bar.data.barLock = true
		else
			bar.data.barLock = false
		end

	else
		if (msg) then
			NeuronBar:barLockMod(bar, msg, gui)
		else
			if (bar.data.barLock) then
				bar.data.barLock = false
			else
				bar.data.barLock = true
			end
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:toolTipMod(bar, msg, gui)
	if (msg:lower() == "enhanced") then
		if (bar.data.tooltipsEnhanced) then
			bar.data.tooltipsEnhanced = false
		else
			bar.data.tooltipsEnhanced = true
		end

	elseif (msg:lower() == "combat") then
		if (bar.data.tooltipsCombat) then
			bar.data.tooltipsCombat = false
		else
			bar.data.tooltipsCombat = true
		end

	elseif (not gui) then
		NEURON:Print(L["Tooltip_Instructions"])
	end
end


function NeuronBar:ToolTipSet(bar, msg, gui, checked, query)
	if (query) then
		if (msg == "enhanced") then
			return bar.data.tooltipsEnhanced
		elseif(msg == "combat") then
			return bar.data.tooltipsCombat
		else
			return bar.data.tooltips
		end
	end

	if (gui) then
		if (msg) then
			NeuronBar:toolTipMod(bar, msg, gui)
		elseif (checked) then
			bar.data.tooltips = true
		else
			bar.data.tooltips = false
		end

	else
		if (msg) then
			NeuronBar:toolTipMod(bar, msg, gui)
		else
			if (bar.data.tooltips) then
				bar.data.tooltips = false
			else
				bar.data.tooltips = true
			end
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:NameBar(bar, name, gui)
	if (name) then
		bar.data.name = name
		NeuronBar:Update(bar)
	end
end


function NeuronBar:ShapeBar(bar, shape, gui, query)
	if (query) then
		return barShapes[bar.data.shape]
	end

	shape = tonumber(shape)

	if (shape and barShapes[shape]) then
		bar.data.shape = shape
		NeuronBar:SetObjectLoc(bar)
		NeuronBar:SetPerimeter(bar)
		NeuronBar:SetSize(bar)
		NeuronBar:Update(bar)
	elseif (not gui) then
		NEURON:Print(L["Bar_Shapes_List"])
	end
end


function NeuronBar:ColumnsSet(bar, command, gui, query, skipupdate)
	if (query) then
		if (bar.data.columns) then
			return bar.data.columns
		else
			return L["Off"]
		end
	end

	local columns = tonumber(command)

	if (columns and columns > 0) then
		bar.data.columns = round(columns, 0)
		NeuronBar:SetObjectLoc(bar)
		NeuronBar:SetPerimeter(bar)
		NeuronBar:SetSize(bar)

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end

	elseif (not columns or columns <= 0) then
		bar.data.columns = false
		NeuronBar:SetObjectLoc(bar)
		NeuronBar:SetPerimeter(bar)
		NeuronBar:SetSize(bar)

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end

	elseif (not gui) then
		NEURON:Print(L["Bar_Column_Instructions"])
	end
end


function NeuronBar:ArcStartSet(bar, command, gui, query, skipupdate)
	if (query) then
		return bar.data.arcStart
	end

	local start = tonumber(command)

	if (start and start>=0 and start<=359) then
		bar.data.arcStart = start
		NeuronBar:SetObjectLoc(bar)
		NeuronBar:SetPerimeter(bar)
		NeuronBar:SetSize(bar)

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end

	elseif (not gui) then
		NEURON:Print(L["Bar_ArcStart_Instructions"])
	end
end


function NeuronBar:ArcLengthSet(bar, command, gui, query, skipupdate)
	if (query) then
		return bar.data.arcLength
	end

	local length = tonumber(command)

	if (length and length>=0 and length<=359) then
		bar.data.arcLength = length
		NeuronBar:SetObjectLoc(bar)
		NeuronBar:SetPerimeter(bar)
		NeuronBar:SetSize(bar)

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end

	elseif (not gui) then
		NEURON:Print(L["Bar_ArcLength_Instructions"])
	end
end


function NeuronBar:PadHSet(bar, command, gui, query, skipupdate)
	if (query) then
		return bar.data.padH
	end

	local padh = tonumber(command)

	if (padh) then
		bar.data.padH = round(padh, 1)
		NeuronBar:SetObjectLoc(bar)
		NeuronBar:SetPerimeter(bar)
		NeuronBar:SetSize(bar)

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end

	elseif (not gui) then
		NEURON:Print(L["Horozontal_Padding_Instructions"])
	end
end


function NeuronBar:PadVSet(bar, command, gui, query, skipupdate)
	if (query) then
		return bar.data.padV
	end

	local padv = tonumber(command)

	if (padv) then
		bar.data.padV = round(padv, 1)
		NeuronBar:SetObjectLoc(bar)
		NeuronBar:SetPerimeter(bar)
		NeuronBar:SetSize(bar)

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end

	elseif (not gui) then
		NEURON:Print(L["Vertical_Padding_Instructions"])
	end
end


function NeuronBar:PadHVSet(bar, command, gui, query, skipupdate)
	if (query) then
		return "---"
	end

	local padhv = tonumber(command)

	if (padhv) then
		bar.data.padH = round(bar.data.padH + padhv, 1)
		bar.data.padV = round(bar.data.padV + padhv, 1)

		NeuronBar:SetObjectLoc(bar)
		NeuronBar:SetPerimeter(bar)
		NeuronBar:SetSize(bar)

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end

	elseif (not gui) then
		NEURON:Print(L["Horozontal_and_Vertical_Padding_Instructions"])
	end
end


function NeuronBar:ScaleBar(bar, scale, gui, query, skipupdate)
	if (query) then
		return bar.data.scale
	end

	scale = tonumber(scale)

	if (scale) then
		bar.data.scale = round(scale, 2)
		NeuronBar:SetObjectLoc(bar)
		NeuronBar:SetPerimeter(bar)
		NeuronBar:SetSize(bar)

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end
	end
end


function NeuronBar:StrataSet(bar, command, gui, query)
	if (query) then
		return bar.data.objectStrata
	end

	local strata = tonumber(command)

	if (strata and NEURON.Stratas[strata] and NEURON.Stratas[strata+1]) then
		bar.data.barStrata = NEURON.Stratas[strata+1]
		bar.data.objectStrata = NEURON.Stratas[strata]

		NeuronBar:SetPosition(bar)
		NeuronBar:UpdateObjectData(bar)
		NeuronBar:Update(bar)

	elseif (not gui) then
		NEURON:Print(L["Bar_Strata_List"])
	end
end


function NeuronBar:AlphaSet(bar, command, gui, query, skipupdate)
	if (query) then
		return bar.data.alpha
	end

	local alpha = tonumber(command)

	if (alpha and alpha>=0 and alpha<=1) then
		bar.data.alpha = round(alpha, 2)
		bar.handler:SetAlpha(bar.data.alpha)

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end

	elseif (not gui) then
		NEURON:Print(L["Bar_Alpha_Instructions"])
	end
end

function NeuronBar:AlphaUpSet(bar, command, gui, query)
	if (query) then
		--temp fix
		if (bar.data.alphaUp == "none" or bar.data.alphaUp == 1) then
			bar.data.alphaUp = alphaUps[1]
		end

		return bar.data.alphaUp
	end

	local alphaUp = tonumber(command)

	if (alphaUp and alphaUps[alphaUp]) then
		bar.data.alphaUp = alphaUps[alphaUp]
		NeuronBar:Update(bar)
	elseif (not gui) then
		local text = ""

		for k,v in ipairs(alphaUps) do
			text = text.."\n"..k.."="..v
		end
	end
end


function NeuronBar:AlphaUpSpeedSet(bar, command, gui, query, skipupdate)
	if (query) then
		return bar.data.fadeSpeed
	end

	local speed = tonumber(command)

	if (speed) then
		bar.data.fadeSpeed = round(speed, 2)

		if (bar.data.fadeSpeed > 1) then
			bar.data.fadeSpeed = 1
		end

		if (bar.data.fadeSpeed < 0.01) then
			bar.data.fadeSpeed = 0.01
		end

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end

	elseif (not gui) then
	end
end

function NeuronBar:XAxisSet(bar, command, gui, query, skipupdate)
	if (query) then
		return bar.data.x
	end

	local x = tonumber(command)

	if (x) then
		bar.data.x = round(x, 2)
		bar.data.snapTo = false
		bar.data.snapToPoint = false
		bar.data.snapToFrame = false
		NeuronBar:SetPosition(bar)
		bar.data.point, bar.data.x, bar.data.y = NeuronBar:GetPosition(bar)

		if (not gui) then
			bar.message:Show()
			bar.messagebg:Show()
		end

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end

	elseif (not gui) then
		NEURON:Print(L["X_Position_Instructions"])
	end
end


function NeuronBar:YAxisSet(bar, command, gui, query, skipupdate)
	if (query) then
		return bar.data.y
	end

	local y = tonumber(command)

	if (y) then
		bar.data.y = round(y, 2)
		bar.data.snapTo = false
		bar.data.snapToPoint = false
		bar.data.snapToFrame = false
		NeuronBar:SetPosition(bar)
		bar.data.point, bar.data.x, bar.data.y = NeuronBar:GetPosition(bar)

		if (not gui) then
			bar.message:Show()
			bar.messagebg:Show()
		end

		if (not skipupdate) then
			NeuronBar:Update(bar)
		end
	elseif (not gui) then
		NEURON:Print(L["Y_Position_Instructions"])
	end
end


function NeuronBar:BindTextSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.bindText, bar.data.bindColor
	end

	if (gui) then
		if (checked) then
			bar.data.bindText = true
		else
			bar.data.bindText = false
		end

	else
		if (bar.data.bindText) then
			bar.data.bindText = false
		else
			bar.data.bindText = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:MacroTextSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.macroText, bar.data.macroColor
	end

	if (gui) then
		if (checked) then
			bar.data.macroText = true
		else
			bar.data.macroText = false
		end

	else
		if (bar.data.macroText) then
			bar.data.macroText = false
		else
			bar.data.macroText = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:CountTextSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.countText, bar.data.countColor
	end

	if (gui) then
		if (checked) then
			bar.data.countText = true
		else
			bar.data.countText = false
		end

	else
		if (bar.data.countText) then
			bar.data.countText = false
		else
			bar.data.countText = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:RangeIndSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.rangeInd, bar.data.rangecolor
	end

	if (gui) then
		if (checked) then
			bar.data.rangeInd = true
		else
			bar.data.rangeInd = false
		end

	else
		if (bar.data.rangeInd) then
			bar.data.rangeInd = false
		else
			bar.data.rangeInd = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:CDTextSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.cdText, bar.data.cdcolor1, bar.data.cdcolor2
	end

	if (gui) then
		if (checked) then
			bar.data.cdText = true
		else
			bar.data.cdText = false
		end

	else
		if (bar.data.cdText) then
			bar.data.cdText = false
		else
			bar.data.cdText = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:CDAlphaSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.cdAlpha
	end

	if (gui) then
		if (checked) then
			bar.data.cdAlpha = true
		else
			bar.data.cdAlpha = false
		end

	else
		if (bar.data.cdAlpha) then
			bar.data.cdAlpha = false
		else
			bar.data.cdAlpha = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:AuraTextSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.auraText, bar.data.auracolor1, bar.data.auracolor2
	end

	if (gui) then
		if (checked) then
			bar.data.auraText = true
		else
			bar.data.auraText = false
		end

	else
		if (bar.data.auraText) then
			bar.data.auraText = false
		else
			bar.data.auraText = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:AuraIndSet(bar, msg, gui, checked, query)
	if (query) then
		return bar.data.auraInd, bar.data.buffcolor, bar.data.debuffcolor
	end

	if (gui) then
		if (checked) then
			bar.data.auraInd = true
		else
			bar.data.auraInd = false
		end

	else
		if (bar.data.auraInd) then
			bar.data.auraInd = false
		else
			bar.data.auraInd = true
		end
	end

	NeuronBar:UpdateObjectData(bar)
	NeuronBar:Update(bar)
end


function NeuronBar:Load(bar)
	NeuronBar:SetPosition(bar)
	NeuronBar:LoadObjects(bar, true)
	NeuronBar:SetObjectLoc(bar)
	NeuronBar:SetPerimeter(bar)
	NeuronBar:SetSize(bar)
	bar:EnableKeyboard(false)
	NeuronBar:Update(bar)
end




--- Sets a Target Casting state for a bar
-- @param value(string): Database refrence value to be set
-- @param gui(Bool): Toggle to determine if call was from the GUI
-- @param checked(Bool) : Used when using a GUI checkbox - It is the box's current state
-- @param query: N/A
function NeuronBar:SetCastingTarget(bar, value, gui, checked, query)
	if (value) then
		if (gui) then

			if (checked) then
				bar.data[value] = true
			else
				bar.data[value] = false
			end

		else

			local toggle = bar.data[value]

			if (toggle) then
				bar.data[value] = false
			else
				bar.data[value] = true
			end
		end

		NEURON.NeuronButton:UpdateMacroCastTargets()
		NeuronBar:Update(bar)
	end
end
