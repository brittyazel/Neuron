--Neuron, a World of Warcraft® user interface addon.

local NEURON = Neuron
local GDB, CDB, SPEC, player, realm, barGDB, barCDB

NEURON.NeuronBar = NEURON:NewModule("Bar", "AceEvent-3.0", "AceHook-3.0")
local NeuronBar = NEURON.NeuronBar

NEURON.BAR = setmetatable({}, {__index = CreateFrame("CheckButton")})
local BAR = NEURON.BAR


NEURON.HANDLER = setmetatable({}, { __index = CreateFrame("Frame") })


local BUTTON = NEURON.BUTTON


local HANDLER = NEURON.HANDLER

local STORAGE = CreateFrame("Frame", nil, UIParent)

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


NEURON.barGDEF = {
	name = "",

	objectList = "",

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
	showGrid = false,

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
}


NEURON.barCDEF = {
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

local gDef = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 55,
		showGrid = true,
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

local cDef = {
	[1] = {
		multiSpec = true,
		vehicle = true,
		possess = true,
		override = true,
	},

	[2] = {
	},
}

local statetable = {}

-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronBar:OnInitialize()

	GDB, CDB= NeuronGDB, NeuronCDB
	barGDB = GDB.bars
	barCDB = CDB.bars

	NEURON:RegisterBarClass("bar", "ActionBar", L["Action Bar"], "Action Button", barGDB, barCDB, BTNIndex, GDB.buttons, "CheckButton", "NeuronActionButtonTemplate", { __index = BUTTON }, false, false, STORAGE, nil, nil, true)

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
end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronBar:OnEnable()

	if (GDB.firstRun) then
		local oid, offset = 1, 0

		for id, defaults in ipairs(gDef) do
			NEURON.RegisteredBarData["bar"].gDef = defaults

			local bar, object = NEURON:CreateNewBar("bar", id, true)

			for i=oid+offset,oid+11+offset do
				object = NEURON:CreateNewObject("bar", i, true)
				bar:AddObjectToList(object)
			end

			NEURON.RegisteredBarData["bar"].gDef = nil

			offset = offset + 12
		end

	else
		for id,data in pairs(barGDB) do
			if (data ~= nil) then
				NEURON:CreateNewBar("bar", id)
			end
		end

		for id,data in pairs(GDB.buttons) do
			if (data ~= nil) then
				NEURON:CreateNewObject("bar", id)
			end
		end
	end

	STORAGE:Hide()

	for _,bar in pairs(BARIndex) do
		if (CDB.firstRun) then
			for id, cdefaults in ipairs(cDef) do
				if (id == bar:GetID()) then
					bar:SetDefaults(nil, cdefaults)
				end
			end
		end

		bar:Load()
	end
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
--------------------Intermediate Functions------------------
------------------------------------------------------------

local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end


local function IsMouseOverSelfOrWatchFrame(frame)
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
function NeuronBar.controlOnUpdate(self, elapsed)
	for k,v in pairs(autoHideIndex) do
		if (v~=nil) then

			if (k:IsShown()) then
				v:SetAlpha(1)
			else

				if (IsMouseOverSelfOrWatchFrame(k)) then
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

				if (not IsMouseOverSelfOrWatchFrame(k)) then
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

							if (IsMouseOverSelfOrWatchFrame(k)) then
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

							if (IsMouseOverSelfOrWatchFrame(k)) then
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

					if (IsMouseOverSelfOrWatchFrame(k)) then
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


function HANDLER:SetHidden(bar, show, hide)

	for k,v in pairs(bar.vis) do
		if (v.registered) then
			return
		end
	end

	local isAnchorChild = self:GetAttribute("isAnchorChild")

	if (not hide and not isAnchorChild and (show or bar:IsVisible())) then

		self:Show()
	else
		if (bar.cdata.conceal) then
			self:SetAttribute("concealed", true); self:Hide()
		elseif (not bar.gdata.barLink and not isAnchorChild) then
			self:SetAttribute("concealed", nil); self:Show()
		end
	end
end

function HANDLER:SetAutoHide(bar)

	if (bar.gdata.autoHide) then
		autoHideIndex[bar] = self; self.fadeSpeed = (bar.gdata.fadeSpeed*bar.gdata.fadeSpeed)
	else
		autoHideIndex[bar] = nil
	end

	if (bar.gdata.alphaUp == L["Off"]) then
		alphaupIndex[bar] = nil
	else
		alphaupIndex[bar] = self; self.fadeSpeed = (bar.gdata.fadeSpeed*bar.gdata.fadeSpeed)
	end
end


function HANDLER:AddVisibilityDriver(bar, state, conditions)

	if (MBS[state]) then

		RegisterStateDriver(self, state, conditions)

		if (self:GetAttribute("activestates"):find(state)) then
			self:SetAttribute("activestates", self:GetAttribute("activestates"):gsub(state.."%d+;", self:GetAttribute("state-"..state)..";"))
		elseif (self:GetAttribute("activestates") and self:GetAttribute("state-"..state)) then
			self:SetAttribute("activestates", self:GetAttribute("activestates")..self:GetAttribute("state-"..state)..";")
		end

		if (self:GetAttribute("state-"..state)) then
			self:SetAttribute("state-"..state, self:GetAttribute("state-"..state))
		end

		bar.vis[state].registered = true
	end
end


function HANDLER:ClearVisibilityDriver(bar, state)

	UnregisterStateDriver(self, state)

	self:SetAttribute("activestates", self:GetAttribute("activestates"):gsub(state.."%d+;", ""))
	self:SetAttribute("state-current", "homestate")
	self:SetAttribute("state-last", "homestate")

	bar.vis[state].registered = false
end


function HANDLER:UpdateVisibility(bar)

	for state, values in pairs(MBS) do

		if (bar.gdata.hidestates:find(":"..state)) then

			if (not bar.vis[state] or not bar.vis[state].registered) then

				if (not bar.vis[state]) then
					bar.vis[state] = {}
				end

				if (state == "stance" and bar.gdata.hidestates:find(":stance8")) then
					self:AddVisibilityDriver(bar, state, "[stance:2/3,stealth] stance8; "..values.states)
					--elseif (state == "custom" and bar.cdata.custom) then
					--self:AddVisibilityDriver(bar, state, bar.cdata.custom)
				else
					self:AddVisibilityDriver(bar, state, values.states)
				end
			end

		elseif (bar.vis[state] and bar.vis[state].registered) then

			self:ClearVisibilityDriver(bar, state)

		end
	end
end

function HANDLER:BuildStateMap(bar, remapState)

	local statemap, state, map, remap, homestate = "", remapState:gsub("paged", "bar")

	for states in gmatch(bar.cdata.remap, "[^;]+") do

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


function HANDLER:AddStates(bar, state, conditions)

	if (state) then

		if (MAS[state]) then
			RegisterStateDriver(self, state, conditions)
		end

		if (MAS[state].homestate) then
			self:SetAttribute("handler-homestate", MAS[state].homestate)
		end

		bar[state].registered = true
	end

end

function HANDLER:ClearStates(bar, state)

	if (state ~= "homestate") then

		if (MAS[state].homestate) then
			self:SetAttribute("handler-homestate", nil)
		end

		self:SetAttribute("state-"..state, nil)

		UnregisterStateDriver(self, state)

		bar[state].registered = false
	end

	self:SetAttribute("state-current", "homestate")
	self:SetAttribute("state-last", "homestate")
end


function HANDLER:UpdateStates(bar)
	for state, values in pairs(MAS) do

		if (bar.cdata[state]) then

			if (not bar[state] or not bar[state].registered) then

				local statemap

				if (not bar[state]) then
					bar[state] = {}
				end

				if (bar.cdata.remap and (state == "paged" or state == "stance")) then
					statemap = self:BuildStateMap(bar, state)
				end


				if (state == "custom" and bar.cdata.custom) then

					self:AddStates(bar, state, bar.cdata.custom)

				elseif (statemap) then

					self:AddStates(bar, state, statemap)

				else
					self:AddStates(bar, state, values.states)

				end
			end

		elseif (bar[state] and bar[state].registered) then

			self:ClearStates(bar, state)

		end
	end
end


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


function BAR:CreateDriver()

	local driver = CreateFrame("Frame", "NeuronBarDriver"..self:GetID(), UIParent, "SecureHandlerStateTemplate")

	setmetatable(driver, { __index = HANDLER })

	driver:SetID(self:GetID())
	--Dynamicly builds driver attributes based on stated in NEURON.STATEINDEX using localized attribute text from a above
	for _, modifier in pairs(NEURON.STATEINDEX) do
		local action = DRIVER_BASE_ACTION:gsub("<MODIFIER>", modifier)
		driver:SetAttribute("_onstate-"..modifier, action)
	end

	driver:SetAttribute("activestates", "")

	driver:HookScript("OnAttributeChanged",

		function(self,name,value)

		end)

	driver:SetAllPoints(self)

	self.driver = driver; driver.bar = self
end


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


function BAR:CreateHandler()

	local handler = CreateFrame("Frame", "NeuronBarHandler"..self:GetID(), self.driver, "SecureHandlerStateTemplate")

	setmetatable(handler, { __index = HANDLER })

	handler:SetID(self:GetID())

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

	handler:SetAllPoints(self)

	self.handler = handler; handler.bar = self

end


function BAR:CreateWatcher()
	local watcher = CreateFrame("Frame", "NeuronBarWatcher"..self:GetID(), self.handler, "SecureHandlerStateTemplate")

	setmetatable(watcher, { __index = HANDLER })

	watcher:SetID(self:GetID())

	watcher:SetAttribute("_onattributechanged", [[ ]])

	watcher:SetAttribute("_onstate-petbattle", [[

			if (self:GetAttribute("state-petbattle") == "hide") then
				self:GetParent():Hide()
			elseif (not self:GetParent():IsShown() and not self:GetParent():GetAttribute("vishide")) then
				self:GetParent():Show()
			end
	]])

	RegisterStateDriver(watcher, "petbattle", "[petbattle] hide; [nopetbattle] show")

end


function BAR:Update(show, hide)

	if(InCombatLockdown()) then
		return
	end

	local handler, driver = self.handler, self.driver

	self.elapsed = 0;
	self.alpha = self.gdata.alpha;
	self.alphaUp = self.gdata.alphaUp

	if (self.stateschanged) then

		handler:UpdateStates(self)

		self.stateschanged = nil
	end

	if (self.vischanged) then

		handler:SetAttribute("hidestates", self.gdata.hidestates)

		driver:UpdateVisibility(self)

		self.vischanged = nil
	end

	if (self.countChanged) then

		self:UpdateObjectData()

		self.countChanged = nil

	end

	handler:SetHidden(self, show, hide)
	handler:SetAutoHide(self)
	self.text:SetText(self.gdata.name)
	handler:SetAlpha(self.gdata.alpha)
	self:SaveData()

	if (not hide and NeuronBarEditor and NeuronBarEditor:IsVisible()) then
		NEURON:UpdateBarGUI()
	end
end


function BAR:GetPosition(oFrame)
	local relFrame, point

	if (oFrame) then
		relFrame = oFrame
	else
		relFrame = self:GetParent()
	end

	local s = self:GetScale()
	local w, h = relFrame:GetWidth()/s, relFrame:GetHeight()/s
	local x, y = self:GetCenter()
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


function BAR:SetPosition()
	if (self.gdata.snapToPoint and self.gdata.snapToFrame) then
		self:StickToPoint(_G[self.gdata.snapToFrame], self.gdata.snapToPoint, self.gdata.padH, self.gdata.padV)
	else

		local point, x, y = self.gdata.point, self.gdata.x, self.gdata.y

		if (point:find("SnapTo")) then
			self.gdata.point = "CENTER"; point = "CENTER"
		end

		self:SetUserPlaced(false)
		self:ClearAllPoints()
		self:SetPoint("CENTER", "UIParent", point, x, y)
		self:SetUserPlaced(true)
		self:SetFrameStrata(self.gdata.barStrata)

		if (self.message) then
			self.message:SetText(point:lower().."     x: "..format("%0.2f", x).."     y: "..format("%0.2f", y))
			self.messagebg:SetWidth(self.message:GetWidth()*1.05)
			self.messagebg:SetHeight(self.message:GetHeight()*1.1)
		end

		self.posSet = true
	end
end


function BAR:SetFauxState(state)
	local object

	self.objCount = 0
	self.handler:SetAttribute("fauxstate", state)

	for objID in gmatch(self.gdata.objectList, "[^;]+") do

		object = _G[self.objPrefix..objID]

		if (object) then
			object:SetFauxState(state)
		end
	end

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		NEURON:UpdateObjectGUI()
	end
end


function BAR:LoadObjects(init)
	local object, spec

	if (self.cdata.multiSpec) then
		spec = GetSpecialization()
	else
		spec = 1
	end

	self.objCount = 0

	for objID in gmatch(self.gdata.objectList, "[^;]+") do
		object = _G[self.objPrefix..objID]

		if (object) then
			self.objTable[object.objTIndex][2] = 0
			object:SetData(self)
			object:LoadData(spec, self.handler:GetAttribute("activestate"))
			object:SetAux()
			object:SetType(nil, nil, init)
			object:SetGrid()
			self.objCount = self.objCount + 1
			self.countChanged = true
		end
	end
end


function BAR:SetObjectLoc()
	local width, height, num, count, origCol = 0, 0, 0, self.objCount, self.gdata.columns
	local x, y, object, lastObj, placed
	local shape, padH, padV, arcStart, arcLength = self.gdata.shape, self.gdata.padH, self.gdata.padV, self.gdata.arcStart, self.gdata.arcLength
	local cAdjust, rAdjust = 0.5, 1
	local columns, rows

	if (not origCol) then
		origCol = count; rows = 1
	else
		rows = (round(ceil(count/self.gdata.columns), 1)/2)+0.5
	end

	for objID in gmatch(self.gdata.objectList, "[^;]+") do
		object = _G[self.objPrefix..objID]

		if (object and num < count) then
			object:ClearAllPoints()
			object:SetParent(self.handler)
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

				object:SetPoint("CENTER", self, "CENTER", x, y)

				placed = placed - (arcLength/count)

			elseif (shape == 3) then
				if (not placed) then
					placed = arcStart
					object:SetPoint("CENTER", self, "CENTER", 0, 0)
					placed = placed - (arcLength/count)

				else
					x = ((width+padH)*(count/math.pi))*(cos(placed))
					y = ((width+padV)*(count/math.pi))*(sin(placed))

					object:SetPoint("CENTER", self, "CENTER", x, y)
					placed = placed - (arcLength/(count-1))
				end
			else
				if (not placed) then
					placed = 0
				end

				x = -(width + padH) * (columns-cAdjust)
				y = (height + padV) * (rows-rAdjust)

				object:SetPoint("CENTER", self, "CENTER", x, y)
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
			object:SetData(self)
		end
	end

	if (lastObj) then
		lastObj:SetAttribute("lastPos", true)
	end
end


function BAR:SetPerimeter()
	local num, count = 0, self.objCount
	local object

	self.objectCount = 0
	self.top = nil; self.bottom = nil; self.left = nil; self.right = nil

	for objID in gmatch(self.gdata.objectList, "[^;]+") do
		object = _G[self.objPrefix..objID]

		if (object and num < count) then
			local objTop, objBottom, objLeft, objRight = object:GetTop(), object:GetBottom(), object:GetLeft(), object:GetRight()
			local scale = 1
			--See if this fixes the ranom position error that happens
			if not objTop then return end

			self.objectCount = self.objectCount + 1

			if (self.top) then
				if (objTop*scale > self.top) then self.top = objTop*scale end
			else self.top = objTop*scale end

			if (self.bottom) then
				if (objBottom*scale < self.bottom) then self.bottom = objBottom*scale end
			else self.bottom = objBottom*scale end

			if (self.left) then
				if (objLeft*scale < self.left) then self.left = objLeft*scale end
			else self.left = objLeft*scale end

			if (self.right) then
				if (objRight*scale > self.right) then self.right = objRight*scale end
			else self.right = objRight*scale end

			num = num + 1
		end
	end
end


function BAR:SetDefaults(gdefaults, cdefaults)
	if (gdefaults) then
		for k,v in pairs(gdefaults) do
			self.gdata[k] = v
		end
	end

	if (cdefaults) then
		for k,v in pairs(cdefaults) do
			self.cdata[k] = v
		end
	end

	self:SaveData()
end


function BAR:SetRemap_Paged()
	self.cdata.remap = ""

	for i=1,6 do
		self.cdata.remap = self.cdata.remap..i..":"..i..";"
	end

	self.cdata.remap = gsub(self.cdata.remap, ";$", "")
end


function BAR:SetRemap_Stance()
	local start = tonumber(MAS.stance.homestate:match("%d+"))

	if (start) then
		self.cdata.remap = ""

		for i=start,GetNumShapeshiftForms() do
			self.cdata.remap = self.cdata.remap..i..":"..i..";"
		end

		self.cdata.remap = gsub(self.cdata.remap, ";$", "")


		if (NEURON.class == "ROGUE") then
			self.cdata.remap = self.cdata.remap..";2:2"
		end
	end
end


function BAR:SetSize()
	if (self.right) then
		self:SetWidth(((self.right-self.left)+5)*(self.gdata.scale))
		self:SetHeight(((self.top-self.bottom)+5)*(self.gdata.scale))
	else
		self:SetWidth(195)
		self:SetHeight(36*(self.gdata.scale))
	end
end


function BAR:ACTIONBAR_SHOWGRID(...)
	if (not InCombatLockdown() and self:IsVisible()) then
		self:Hide(); self.showgrid = true
	end

end


function BAR:ACTIONBAR_HIDEGRID(...)
	if (not InCombatLockdown() and self.showgrid) then
		self:Show(); self.showgrid = nil
	end

end


function BAR:ACTIVE_TALENT_GROUP_CHANGED(...)
	if (NEURON.PEW) then
		self.stateschanged = true
		self.vischanged = true

		--if (self.cdata.stance) then
		--	self:SetRemap_Stance()
		--end

		self:Update()
	end
end


function BAR:OnEvent(event, ...)
	if (self[event]) then
		self[event](self, ...)
	end
end


function BAR:OnClick(...)
	local click, down, newBar = select(1, ...), select(2, ...)

	if (not down) then
		newBar = NEURON:ChangeBar(self)
	end

	self.click = click
	self.dragged = false
	self.elapsed = 0
	self.pushed = 0

	if (IsShiftKeyDown() and not down) then

		if (self.microAdjust) then
			self.microAdjust = false
			self:EnableKeyboard(false)
			self.message:Hide()
			self.messagebg:Hide()
		else
			self.gdata.snapTo = false
			self.gdata.snapToPoint = false
			self.gdata.snapToFrame = false
			self.microAdjust = 1
			self:EnableKeyboard(true)
			self.message:Show()
			self.message:SetText(self.gdata.point:lower().."     x: "..format("%0.2f", self.gdata.x).."     y: "..format("%0.2f", self.gdata.y))
			self.messagebg:Show()
			self.messagebg:SetWidth(self.message:GetWidth()*1.05)
			self.messagebg:SetHeight(self.message:GetHeight()*1.1)
		end

	elseif (click == "MiddleButton") then
		if (GetMouseFocus() ~= NEURON.CurrentBar) then
			newBar = NEURON:ChangeBar(self)
		end

		if (down) then
			--NEURON:ConcealBar(nil, true)
		end

	elseif (click == "RightButton" and not self.action and not down) then
		self.mousewheelfunc = nil

		if (not IsAddOnLoaded("Neuron-GUI")) then
			LoadAddOn("Neuron-GUI")
		end

		if (NeuronBarEditor) then
			if (not newBar and NeuronBarEditor:IsVisible()) then
				NeuronBarEditor:Hide()
			else
				NeuronBarEditor:Show()
			end
		end

	elseif (not down) then
		if (not newBar) then
			--updateState(self, 1)
		end
	end

	if (not down and NeuronBarEditor and NeuronBarEditor:IsVisible()) then
		NEURON:UpdateBarGUI(newBar)
	end
end


function BAR:OnEnter(...)
	if (self.cdata.conceal) then
		self:SetBackdropColor(1,0,0,0.6)
	else
		self:SetBackdropColor(0,0,1,0.5)
	end

	self.text:Show()
end


function BAR:OnLeave(...)
	if (self ~= NEURON.CurrentBar) then
		if (self.cdata.conceal) then
			self:SetBackdropColor(1,0,0,0.4)
		else
			self:SetBackdropColor(0,0,0,0.4)
		end
	end

	if (self ~= NEURON.CurrentBar) then
		self.text:Hide()
	end
end


function BAR:OnDragStart(...)
	NEURON:ChangeBar(self)

	self:SetFrameStrata(self.gdata.barStrata)
	self:EnableKeyboard(false)

	self.adjusting = true
	self.selected = true
	self.isMoving = true

	self.gdata.snapToPoint = false
	self.gdata.snapToFrame = false

	self:StartMoving()
end


function BAR:OnDragStop(...)
	local point
	self:StopMovingOrSizing()

	for _,bar in pairs(BARIndex) do
		if (not point and self.gdata.snapTo and bar.gdata.snapTo and self ~= bar) then
			point = self:Stick(bar, GDB.snapToTol, self.gdata.padH, self.gdata.padV)

			if (point) then
				self.gdata.snapToPoint = point
				self.gdata.snapToFrame = bar:GetName()
				self.gdata.point = "SnapTo: "..point
				self.gdata.x = 0
				self.gdata.y = 0
			end
		end
	end

	if (not point) then
		self.gdata.snapToPoint = false
		self.gdata.snapToFrame = false
		self.gdata.point, self.gdata.x, self.gdata.y = self:GetPosition()
		self:SetPosition()
	end

	if (self.gdata.snapTo and not self.gdata.snapToPoint) then
		self:StickToEdge()
	end

	self.isMoving = false
	self.dragged = true
	self.elapsed = 0
	self:Update()
end


local barStack = {}
local stackWatch = CreateFrame("Frame", nil, UIParent)
stackWatch:SetScript("OnUpdate", function(self) self.bar = GetMouseFocus():GetName() if (not BARNameIndex[self.bar]) then wipe(barStack); self:Hide() end end)
stackWatch:Hide()


function BAR:OnKeyDown(key, onupdate)
	if (self.microAdjust) then
		self.keydown = key

		if (not onupdate) then
			self.elapsed = 0
		end

		self.gdata.point, self.gdata.x, self.gdata.y = self:GetPosition()
		self:SetUserPlaced(false)
		self:ClearAllPoints()

		if (key == "UP") then
			self.gdata.y = self.gdata.y + .1 * self.microAdjust
		elseif (key == "DOWN") then
			self.gdata.y = self.gdata.y - .1 * self.microAdjust
		elseif (key == "LEFT") then
			self.gdata.x = self.gdata.x - .1 * self.microAdjust
		elseif (key == "RIGHT") then
			self.gdata.x = self.gdata.x + .1 * self.microAdjust
		elseif (not key:find("SHIFT")) then
			self.microAdjust = false
			self:EnableKeyboard(false)
		end

		self:SetPosition()
		self:SaveData()
	end
end


function BAR:OnKeyUp(key)
	if (self.microAdjust and not key:find("SHIFT")) then
		self.microAdjust = 1
		self.keydown = nil
		self.elapsed = 0
	end
end


function BAR:OnMouseWheel(delta)
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
		NEURON:ChangeBar(bar)
	end
end


function BAR:OnShow()
	if (self == NEURON.CurrentBar) then

		if (self.cdata.conceal) then
			self:SetBackdropColor(1,0,0,0.6)
		else
			self:SetBackdropColor(0,0,1,0.5)
		end

	else
		if (self.cdata.conceal) then
			self:SetBackdropColor(1,0,0,0.4)
		else
			self:SetBackdropColor(0,0,0,0.4)
		end
	end

	self.handler:SetAttribute("editmode", true)
	self.handler:Show()
	self:UpdateObjectGrid(NEURON.BarsShown)
	self:EnableKeyboard(false)
end


function BAR:OnHide()
	self.handler:SetAttribute("editmode", nil)

	if (self.handler:GetAttribute("vishide")) then
		self.handler:Hide()
	end

	self:UpdateObjectGrid()
	self:EnableKeyboard(false)
end


function BAR:Pulse(elapsed)
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
			self:SetAlpha(1-(alphaTimer))
		end
	else
		if ((alphaTimer) <= 1) then
			self:SetAlpha((alphaTimer))
		end
	end

	self.pulse = true
end


function BAR:OnUpdate(elapsed)
	if (NEURON.PEW) then

		if (self.elapsed) then
			self.elapsed = self.elapsed + elapsed

			if (self.elapsed > 10) then
				self.elapsed = 0.75
			end

			if (self.microAdjust and not self.action) then
				self:Pulse(elapsed)

				if (self.keydown and self.elapsed >= 0.5) then
					self.microAdjust = self.microAdjust + 1
					self:OnKeyDown(self.keydown, self.microAdjust)
				end

			elseif (self.pulse) then
				self:SetAlpha(1)
				self.pulse = nil
			end

			if (self.hover) then
				self.elapsed = 0
			end
		end

		if (GetMouseFocus() == self) then
			if (not self.wheel) then
				self:EnableMouseWheel(true); self.wheel = true
			end
		elseif (self.wheel) then
			self:EnableMouseWheel(false); self.wheel = nil
		end

	end
end


function BAR:SaveData()
	local id = self:GetID()

	if (self.GDB[id]) then
		for key,value in pairs(self.gdata) do
			self.GDB[id][key] = value
		end
	else
		Neuron:Print("DEBUG: Bad Global Save Data for "..self:GetName().." ?")
	end

	if (self.CDB[id]) then
		for key,value in pairs(self.cdata) do
			self.CDB[id][key] = value
		end
	else
		Neuron:Print("DEBUG: Bad Character Save Data for "..self:GetName().." ?")
	end
end


function BAR:LoadData()
	local id = self:GetID()

	if (not self.GDB[id]) then
		self.GDB[id] = CopyTable(NEURON.barGDEF)
	end

	NEURON:UpdateData(self.GDB[id], NEURON.barGDEF)
	self.gdata = CopyTable(self.GDB[id])

	if (not self.CDB[id]) then
		self.CDB[id] = CopyTable(NEURON.barCDEF)
	end

	NEURON:UpdateData(self.CDB[id], NEURON.barCDEF)
	self.cdata = CopyTable(self.CDB[id])

	if (#self.gdata.name < 1) then
		self.gdata.name = self.barLabel.." "..self:GetID()
	end
end


function BAR:UpdateObjectData()
	local object

	for objID in gmatch(self.gdata.objectList, "[^;]+") do
		object = _G[self.objPrefix..objID]

		if (object) then
			object:SetData(self)
		end
	end
end


function BAR:UpdateObjectGrid(show)
	local object

	for objID in gmatch(self.gdata.objectList, "[^;]+") do
		object = _G[self.objPrefix..objID]

		if (object) then
			object:SetGrid(show)
		end
	end
end


function BAR:UpdateObjectSpec()
	local object, spec

	for objID in gmatch(self.gdata.objectList, "[^;]+") do
		object = _G[self.objPrefix..objID]

		if (object) then
			if (self.cdata.multiSpec) then
				spec = GetSpecialization()
			else
				spec = 1
			end

			self:Show()

			object:SetData(self)
			object:LoadData(spec, self.handler:GetAttribute("activestate"))
			object:UpdateFlyout()
			object:SetType()
			object:SetGrid()
		end
	end
end


function BAR:DeleteBar()
	local handler = self.handler

	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")
	handler:SetAttribute("showstates", "homestate")
	handler:ClearStates(self, "homestate")

	for state, values in pairs(MAS) do
		if (self.cdata[state] and self[state] and self[state].registered) then
			if (state == "custom" and self.cdata.customRange) then
				local start = tonumber(string.match(self.cdata.customRange, "^%d+"))
				local stop = tonumber(string.match(self.cdata.customRange, "%d+$"))

				if (start and stop) then
					handler:ClearStates(self, state, start, stop)
				end
			else
				handler:ClearStates(self, state, values.rangeStart, values.rangeStop)
			end
		end
	end

	self:RemoveObjects(self.objCount)

	self:SetScript("OnClick", function() end)
	self:SetScript("OnDragStart", function() end)
	self:SetScript("OnDragStop", function() end)
	self:SetScript("OnEnter", function() end)
	self:SetScript("OnLeave", function() end)
	self:SetScript("OnEvent", function() end)
	self:SetScript("OnKeyDown", function() end)
	self:SetScript("OnKeyUp", function() end)
	self:SetScript("OnMouseWheel", function() end)
	self:SetScript("OnShow", function() end)
	self:SetScript("OnHide", function() end)
	self:SetScript("OnUpdate", function() end)

	self:UnregisterEvent("ACTIONBAR_SHOWGRID")
	self:UnregisterEvent("ACTIONBAR_HIDEGRID")
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

	self:SetWidth(36)
	self:SetHeight(36)
	self:ClearAllPoints()
	self:SetPoint("CENTER")
	self:Hide()

	BARIndex[self.index] = nil
	BARNameIndex[self:GetName()] = nil

	self.GDB[self:GetID()] = nil
	self.CDB[self:GetID()] = nil

	if (NeuronBarEditor and NeuronBarEditor:IsVisible()) then
		NEURON:UpdateBarGUI()
	end
end


function BAR:AddObjectToList(object)
	if (not self.gdata.objectList or self.gdata.objectList == "") then
		self.gdata.objectList = tostring(object.id)
	elseif (self.barReverse) then
		self.gdata.objectList = object.id..";"..self.gdata.objectList
	else
		self.gdata.objectList = self.gdata.objectList..";"..object.id
	end
end


function BAR:AddObjects(num)
	num = tonumber(num)

	if (not num) then
		num = 1
	end

	if (num) then
		for i=1,num do
			local object

			for index,data in ipairs(self.objTable) do
				if (not object and data[2] == 1) then
					object = data[1]; data[2] = 0
				end
			end

			if (not object and not self.objMax) then

				local id = 1

				for _ in ipairs(self.objGDB) do
					id = id + 1
				end

				object = NEURON:CreateNewObject(self.class, id)
			end

			if (object) then
				object:Show()
				self:AddObjectToList(object)
			end
		end

		self:LoadObjects()
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()
		self:Update()
		self:UpdateObjectGrid(NEURON.BarsShown)
	end
end


function BAR:StoreObject(object, storage, objTable)
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
		object.binder:ClearBindings(object)
	end

	object:SaveData()

	--NEURON.UpdateAnchor(button, nil, nil, nil, true)

	objTable[object.objTIndex][2] = 1

	object:SetParent(storage)
end


function BAR:RemoveObjectFromList(objID)
	if (self.barReverse) then
		self.gdata.objectList = (self.gdata.objectList):gsub("^"..objID.."[;]*", "")
	else
		self.gdata.objectList = (self.gdata.objectList):gsub("[;]*"..objID.."$", "")
	end

end


function BAR:RemoveObjects(num)
	if (not self.objStorage) then return end

	if (not num) then
		num = 1
	end

	if (num) then
		for i=1,num do
			local objID

			if (self.barReverse) then
				objID = (self.gdata.objectList):match("^%d+")
			else
				objID = (self.gdata.objectList):match("%d+$")
			end

			if (objID) then
				local object = _G[self.objPrefix..objID]
				if (object) then
					self:StoreObject(object, self.objStorage, self.objTable)
					self:RemoveObjectFromList(objID)
					self.objCount = self.objCount - 1
					self.countChanged = true
				end

				self:SetObjectLoc()
				self:SetPerimeter()
				self:SetSize()
				self:Update()
			end
		end
	end
end


function BAR:SetState(msg, gui, checked, query)
	if (msg) then
		local state = msg:match("^%S+")
		local command = msg:gsub(state, "");
		command = command:gsub("^%s+", "")

		if (not MAS[state]) then
			if (not gui) then
				NEURON:PrintStateList()
			else
				Neuron:Print("GUI option error")
			end

			return
		end

		if (gui) then
			if (checked) then
				self.cdata[state] = true
			else
				self.cdata[state] = false
			end
		else
			local toggle = self.cdata[state]

			if (toggle) then
				self.cdata[state] = false
			else
				self.cdata[state] = true
			end
		end

		if (state == "paged") then
			self.cdata.stance = false
			self.cdata.pet = false

			if (self.cdata.paged) then
				self:SetRemap_Paged()
			else
				self.cdata.remap = false
			end
		end

		if (state == "stance") then
			self.cdata.paged = false
			self.cdata.pet = false


			if (NEURON.class == "ROGUE" and self.cdata.stealth) then
				self.cdata.stealth = false
			end

			if (self.cdata.stance) then
				self:SetRemap_Stance()
			else
				self.cdata.remap = false
			end
		end

		if (state == "custom") then
			if (self.cdata.custom) then
				local count, newstates = 0, ""

				self.cdata.customNames = {}

				for states in gmatch(command, "[^;]+") do
					if string.find(states, "%[(.+)%]") then
						self.cdata.customRange = "1;"..count

						if (count == 0) then
							newstates = states.." homestate;"
							self.cdata.customNames["homestate"] = states
						else
							newstates = newstates..states.." custom"..count..";"
							self.cdata.customNames["custom"..count] = states
						end

						count = count + 1
					else
						Neuron:Print(states.." not formated properly and skipped")
					end
				end

				if (newstates ~= "" ) then
					self.cdata.custom = newstates
				else
					self.cdata.custom = false
					self.cdata.customNames = false
					self.cdata.customRange = false
				end

			else
				self.cdata.customNames = false
				self.cdata.customRange = false
			end

			--Clears any previous set cusom vis settings
			for states in gmatch(self.gdata.hidestates, "custom%d+") do
				self.gdata.hidestates = self.gdata.hidestates:gsub(states..":", "")
			end
			if not self.gdata.hidestates then Neuron:Print("OOPS")
			end
		end

		if (state == "pet") then
			self.cdata.paged = false
			self.cdata.stance = false
		end

		self.stateschanged = true
		self:Update()

	elseif (not gui) then
		wipe(statetable)

		for k,v in pairs(NEURON.STATEINDEX) do

			if (self.cdata[k]) then
				tinsert(statetable, k..": on")
			else
				tinsert(statetable, k..": off")
			end
		end

		table.sort(statetable)

		for k,v in ipairs(statetable) do
			Neuron:Print(v)
		end
	end

end


--I have no clue what or how any of this works. I took out the annoying print statements, but for now I'll just leave it. -Soyier

function BAR:SetVisibility(msg, gui, checked, query)
	if (msg) then
		wipe(statetable)
		local toggle, index, num = (" "):split(msg)
		toggle = toggle:lower()

		if (toggle and NEURON.STATEINDEX[toggle]) then
			if (index) then
				num = index:match("%d+")

				if (num) then
					local hidestate = NEURON.STATEINDEX[toggle]..num
					if (NEURON.STATES[hidestate]) or (toggle == "custom" and self.cdata.customNames) then
						if (self.gdata.hidestates:find(hidestate)) then
							self.gdata.hidestates = self.gdata.hidestates:gsub(hidestate..":", "")
						else
							self.gdata.hidestates = self.gdata.hidestates..hidestate..":"
						end
					else
						Neuron:Print(L["Invalid index"]); return
					end

				elseif (index == L["Show"]) then
					local hidestate = NEURON.STATEINDEX[toggle].."%d+"
					self.gdata.hidestates = self.gdata.hidestates:gsub(hidestate..":", "")
				elseif (index == L["Hide"]) then
					local hidestate = NEURON.STATEINDEX[toggle]

					for state in pairs(NEURON.STATES) do
						if (state:find("^"..hidestate) and not self.gdata.hidestates:find(state)) then
							self.gdata.hidestates = self.gdata.hidestates..state..":"
						end
					end
				end
			end

			if (not silent) then
				local hidestates = self.gdata.hidestates
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

			self.vischanged = true
			self:Update()
		else
			NEURON:PrintStateList()
		end
	else
	end
end


function BAR:AutoHideBar(msg, gui, checked, query)
	if (query) then
		return self.gdata.autoHide
	end

	if (gui) then
		if (checked) then
			self.gdata.autoHide = true
		else
			self.gdata.autoHide = false
		end

	else
		local toggle = self.gdata.autoHide

		if (toggle) then
			self.gdata.autoHide = false
		else
			self.gdata.autoHide = true
		end
	end

	self:Update()
end


function BAR:ShowGridSet(msg, gui, checked, query)
	if (query) then
		return self.gdata.showGrid
	end

	if (gui) then
		if (checked) then
			self.gdata.showGrid = true
		else
			self.gdata.showGrid = false
		end
	else
		if (self.gdata.showGrid) then
			self.gdata.showGrid = false
		else
			self.gdata.showGrid = true
		end
	end

	self:UpdateObjectData()
	self:UpdateObjectGrid(NEURON.BarsShown)
	self:Update()
end


local function spellGlowMod(self, msg, gui)
	if (msg:lower() == "default") then
		if (self.cdata.spellGlowDef) then
			self.cdata.spellGlowDef = false
		else
			self.cdata.spellGlowDef = true
			self.cdata.spellGlowAlt = false
		end

		if (not self.cdata.spellGlowDef and not self.cdata.spellGlowAlt) then
			self.cdata.spellGlowDef = true
		end

	elseif (msg:lower() == "alt") then
		if (self.cdata.spellGlowAlt) then
			self.cdata.spellGlowAlt = false
		else
			self.cdata.spellGlowAlt = true
			self.cdata.spellGlowDef = false
		end

		if (not self.cdata.spellGlowDef and not self.cdata.spellGlowAlt) then
			self.cdata.spellGlowDef = true
		end

	elseif (not gui) then
		Neuron:Print(L["Spellglow_Instructions"])
	end
end


function BAR:SpellGlowSet(msg, gui, checked, query)
	if (query) then
		if (msg == "default") then
			return self.cdata.spellGlowDef
		elseif(msg == "alt") then
			return self.cdata.spellGlowAlt
		else
			return self.cdata.spellGlow
		end
	end

	if (gui) then
		if (msg) then
			spellGlowMod(self, msg, gui)
		elseif (checked) then
			self.cdata.spellGlow = true
		else
			self.cdata.spellGlow = false
		end

	else
		if (msg) then
			spellGlowMod(self, msg, gui)
		elseif (self.cdata.spellGlow) then
			self.cdata.spellGlow = false
		else
			self.cdata.spellGlow = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:SnapToBar(msg, gui, checked, query)
	if (query) then
		return self.gdata.snapTo
	end

	if (gui) then
		if (checked) then
			self.gdata.snapTo = true
		else
			self.gdata.snapTo = false
		end
	else
		local toggle = self.gdata.snapTo

		if (toggle) then
			self.gdata.snapTo = false
			self.gdata.snapToPoint = false
			self.gdata.snapToFrame = false

			self:SetUserPlaced(true)
			self.gdata.point, self.gdata.x, self.gdata.y = self:GetPosition()
			self:SetPosition()
		else
			self.gdata.snapTo = true
		end
	end

	self:Update()
end

function BAR:UpClicksSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.upClicks
	end

	if (gui) then
		if (checked) then
			self.cdata.upClicks = true
		else
			self.cdata.upClicks = false
		end

	else
		if (self.cdata.upClicks) then
			self.cdata.upClicks = false
		else
			self.cdata.upClicks = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:DownClicksSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.downClicks
	end

	if (gui) then
		if (checked) then
			self.cdata.downClicks = true
		else
			self.cdata.downClicks = false
		end

	else
		if (self.cdata.downClicks) then
			self.cdata.downClicks = false
		else
			self.cdata.downClicks = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:MultiSpecSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.multiSpec
	end

	if (gui) then
		if (checked) then
			self.cdata.multiSpec = true
		else
			self.cdata.multiSpec = false
		end
	else
		local toggle = self.cdata.multiSpec

		if (toggle) then
			self.cdata.multiSpec = false
		else
			self.cdata.multiSpec = true
		end
	end

	self:UpdateObjectSpec()
	self:Update()
end


function BAR:ConcealBar(msg, gui, checked, query)
	if (InCombatLockdown()) then return end

	if (query) then
		return self.cdata.conceal
	end

	if (gui) then
		if (checked) then
			self.cdata.conceal = true
		else
			self.cdata.conceal = false
		end

	else
		local toggle = self.cdata.conceal

		if (toggle) then
			self.cdata.conceal = false
		else
			self.cdata.conceal = true
		end
	end

	if (self.cdata.conceal) then
		if (self.selected) then
			self:SetBackdropColor(1,0,0,0.6)
		else
			self:SetBackdropColor(1,0,0,0.4)
		end
	else
		if (self.selected) then
			self:SetBackdropColor(0,0,1,0.5)
		else
			self:SetBackdropColor(0,0,0,0.4)
		end
	end

	self:Update()
end


local function barLockMod(self, msg, gui)
	if (msg:lower() == "alt") then
		if (self.cdata.barLockAlt) then
			self.cdata.barLockAlt = false
		else
			self.cdata.barLockAlt = true
		end

	elseif (msg:lower() == "ctrl") then
		if (self.cdata.barLockCtrl) then
			self.cdata.barLockCtrl = false
		else
			self.cdata.barLockCtrl = true
		end

	elseif (msg:lower() == "shift") then
		if (self.cdata.barLockShift) then
			self.cdata.barLockShift = false
		else
			self.cdata.barLockShift = true
		end

	elseif (not gui) then
		Neuron:Print(L["Bar_Lock_Modifier_Instructions"])
	end
end

function BAR:LockSet(msg, gui, checked, query)
	if (query) then
		if (msg == "shift") then
			return self.cdata.barLockShift
		elseif(msg == "ctrl") then
			return self.cdata.barLockCtrl
		elseif(msg == "alt") then
			return self.cdata.barLockAlt
		else
			return self.cdata.barLock
		end
	end

	if (gui) then
		if (msg) then
			barLockMod(self, msg, gui)
		elseif (checked) then
			self.cdata.barLock = true
		else
			self.cdata.barLock = false
		end

	else
		if (msg) then
			barLockMod(self, msg, gui)
		else
			if (self.cdata.barLock) then
				self.cdata.barLock = false
			else
				self.cdata.barLock = true
			end
		end
	end

	self:UpdateObjectData()
	self:Update()
end


local function toolTipMod(self, msg, gui)
	if (msg:lower() == "enhanced") then
		if (self.cdata.tooltipsEnhanced) then
			self.cdata.tooltipsEnhanced = false
		else
			self.cdata.tooltipsEnhanced = true
		end

	elseif (msg:lower() == "combat") then
		if (self.cdata.tooltipsCombat) then
			self.cdata.tooltipsCombat = false
		else
			self.cdata.tooltipsCombat = true
		end

	elseif (not gui) then
		Neuron:Print(L["Tooltip_Instructions"])
	end
end


function BAR:ToolTipSet(msg, gui, checked, query)
	if (query) then
		if (msg == "enhanced") then
			return self.cdata.tooltipsEnhanced
		elseif(msg == "combat") then
			return self.cdata.tooltipsCombat
		else
			return self.cdata.tooltips
		end
	end

	if (gui) then
		if (msg) then
			toolTipMod(self, msg, gui)
		elseif (checked) then
			self.cdata.tooltips = true
		else
			self.cdata.tooltips = false
		end

	else
		if (msg) then
			toolTipMod(self, msg, gui)
		else
			if (self.cdata.tooltips) then
				self.cdata.tooltips = false
			else
				self.cdata.tooltips = true
			end
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:NameBar(name, gui)
	if (name) then
		self.gdata.name = name
		self:Update()
	end
end


function BAR:ShapeBar(shape, gui, query)
	if (query) then
		return barShapes[self.gdata.shape]
	end

	shape = tonumber(shape)

	if (shape and barShapes[shape]) then
		self.gdata.shape = shape
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()
		self:Update()
	elseif (not gui) then
		Neuron:Print(L["Bar_Shapes_List"])
	end
end


function BAR:ColumnsSet(command, gui, query, skipupdate)
	if (query) then
		if (self.gdata.columns) then
			return self.gdata.columns
		else
			return L["Off"]
		end
	end

	local columns = tonumber(command)

	if (columns and columns > 0) then
		self.gdata.columns = round(columns, 0)
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not columns or columns <= 0) then
		self.gdata.columns = false
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Bar_Column_Instructions"])
	end
end


function BAR:ArcStartSet(command, gui, query, skipupdate)
	if (query) then
		return self.gdata.arcStart
	end

	local start = tonumber(command)

	if (start and start>=0 and start<=359) then
		self.gdata.arcStart = start
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Bar_ArcStart_Instructions"])
	end
end


function BAR:ArcLengthSet(command, gui, query, skipupdate)
	if (query) then
		return self.gdata.arcLength
	end

	local length = tonumber(command)

	if (length and length>=0 and length<=359) then
		self.gdata.arcLength = length
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Bar_ArcLength_Instructions"])
	end
end


function BAR:PadHSet(command, gui, query, skipupdate)
	if (query) then
		return self.gdata.padH
	end

	local padh = tonumber(command)

	if (padh) then
		self.gdata.padH = round(padh, 1)
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Horozontal_Padding_Instructions"])
	end
end


function BAR:PadVSet(command, gui, query, skipupdate)
	if (query) then
		return self.gdata.padV
	end

	local padv = tonumber(command)

	if (padv) then
		self.gdata.padV = round(padv, 1)
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Vertical_Padding_Instructions"])
	end
end


function BAR:PadHVSet(command, gui, query, skipupdate)
	if (query) then
		return "---"
	end

	local padhv = tonumber(command)

	if (padhv) then
		self.gdata.padH = round(self.gdata.padH + padhv, 1)
		self.gdata.padV = round(self.gdata.padV + padhv, 1)

		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Horozontal_and_Vertical_Padding_Instructions"])
	end
end


function BAR:ScaleBar(scale, gui, query, skipupdate)
	if (query) then
		return self.gdata.scale
	end

	scale = tonumber(scale)

	if (scale) then
		self.gdata.scale = round(scale, 2)
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end
	end
end


function BAR:StrataSet(command, gui, query)
	if (query) then
		return self.gdata.objectStrata
	end

	local strata = tonumber(command)

	if (strata and NEURON.Stratas[strata] and NEURON.Stratas[strata+1]) then
		self.gdata.barStrata = NEURON.Stratas[strata+1]
		self.gdata.objectStrata = NEURON.Stratas[strata]

		self:SetPosition()
		self:UpdateObjectData()
		self:Update()

	elseif (not gui) then
		Neuron:Print(L["Bar_Strata_List"])
	end
end


function BAR:AlphaSet(command, gui, query, skipupdate)
	if (query) then
		return self.gdata.alpha
	end

	local alpha = tonumber(command)

	if (alpha and alpha>=0 and alpha<=1) then
		self.gdata.alpha = round(alpha, 2)
		self.handler:SetAlpha(self.gdata.alpha)

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Bar_Alpha_Instructions"])
	end
end

function BAR:AlphaUpSet(command, gui, query)
	if (query) then
		--temp fix
		if (self.gdata.alphaUp == "none" or self.gdata.alphaUp == 1) then
			self.gdata.alphaUp = alphaUps[1]
		end

		return self.gdata.alphaUp
	end

	local alphaUp = tonumber(command)

	if (alphaUp and alphaUps[alphaUp]) then
		self.gdata.alphaUp = alphaUps[alphaUp]
		self:Update()
	elseif (not gui) then
		local text = ""

		for k,v in ipairs(alphaUps) do
			text = text.."\n"..k.."="..v
		end
	end
end


function BAR:AlphaUpSpeedSet(command, gui, query, skipupdate)
	if (query) then
		return self.gdata.fadeSpeed
	end

	local speed = tonumber(command)

	if (speed) then
		self.gdata.fadeSpeed = round(speed, 2)

		if (self.gdata.fadeSpeed > 1) then
			self.gdata.fadeSpeed = 1
		end

		if (self.gdata.fadeSpeed < 0.01) then
			self.gdata.fadeSpeed = 0.01
		end

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
	end
end

function BAR:XAxisSet(command, gui, query, skipupdate)
	if (query) then
		return self.gdata.x
	end

	local x = tonumber(command)

	if (x) then
		self.gdata.x = round(x, 2)
		self.gdata.snapTo = false
		self.gdata.snapToPoint = false
		self.gdata.snapToFrame = false
		self:SetPosition()
		self.gdata.point, self.gdata.x, self.gdata.y = self:GetPosition()

		if (not gui) then
			self.message:Show()
			self.messagebg:Show()
		end

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["X_Position_Instructions"])
	end
end


function BAR:YAxisSet(command, gui, query, skipupdate)
	if (query) then
		return self.gdata.y
	end

	local y = tonumber(command)

	if (y) then
		self.gdata.y = round(y, 2)
		self.gdata.snapTo = false
		self.gdata.snapToPoint = false
		self.gdata.snapToFrame = false
		self:SetPosition()
		self.gdata.point, self.gdata.x, self.gdata.y = self:GetPosition()

		if (not gui) then
			self.message:Show()
			self.messagebg:Show()
		end

		if (not skipupdate) then
			self:Update()
		end
	elseif (not gui) then
		Neuron:Print(L["Y_Position_Instructions"])
	end
end


function BAR:BindTextSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.bindText, self.gdata.bindColor
	end

	if (gui) then
		if (checked) then
			self.cdata.bindText = true
		else
			self.cdata.bindText = false
		end

	else
		if (self.cdata.bindText) then
			self.cdata.bindText = false
		else
			self.cdata.bindText = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:MacroTextSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.macroText, self.gdata.macroColor
	end

	if (gui) then
		if (checked) then
			self.cdata.macroText = true
		else
			self.cdata.macroText = false
		end

	else
		if (self.cdata.macroText) then
			self.cdata.macroText = false
		else
			self.cdata.macroText = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:CountTextSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.countText, self.gdata.countColor
	end

	if (gui) then
		if (checked) then
			self.cdata.countText = true
		else
			self.cdata.countText = false
		end

	else
		if (self.cdata.countText) then
			self.cdata.countText = false
		else
			self.cdata.countText = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:RangeIndSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.rangeInd, self.gdata.rangecolor
	end

	if (gui) then
		if (checked) then
			self.cdata.rangeInd = true
		else
			self.cdata.rangeInd = false
		end

	else
		if (self.cdata.rangeInd) then
			self.cdata.rangeInd = false
		else
			self.cdata.rangeInd = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:CDTextSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.cdText, self.gdata.cdcolor1, self.gdata.cdcolor2
	end

	if (gui) then
		if (checked) then
			self.cdata.cdText = true
		else
			self.cdata.cdText = false
		end

	else
		if (self.cdata.cdText) then
			self.cdata.cdText = false
		else
			self.cdata.cdText = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:CDAlphaSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.cdAlpha
	end

	if (gui) then
		if (checked) then
			self.cdata.cdAlpha = true
		else
			self.cdata.cdAlpha = false
		end

	else
		if (self.cdata.cdAlpha) then
			self.cdata.cdAlpha = false
		else
			self.cdata.cdAlpha = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:AuraTextSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.auraText, self.gdata.auracolor1, self.gdata.auracolor2
	end

	if (gui) then
		if (checked) then
			self.cdata.auraText = true
		else
			self.cdata.auraText = false
		end

	else
		if (self.cdata.auraText) then
			self.cdata.auraText = false
		else
			self.cdata.auraText = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:AuraIndSet(msg, gui, checked, query)
	if (query) then
		return self.cdata.auraInd, self.gdata.buffcolor, self.gdata.debuffcolor
	end

	if (gui) then
		if (checked) then
			self.cdata.auraInd = true
		else
			self.cdata.auraInd = false
		end

	else
		if (self.cdata.auraInd) then
			self.cdata.auraInd = false
		else
			self.cdata.auraInd = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:Load()
	self:SetPosition()
	self:LoadObjects(true)
	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:EnableKeyboard(false)
	self:Update()
end




function NEURONBarProfileUpdate()
	GDB, CDB = NeuronGDB, NeuronCDB
	barGDB = GDB.bars
	barCDB = CDB.bars

	if (GDB.firstRun) then
		local oid, offset = 1, 0
		for id, defaults in ipairs(gDef) do
			NEURON.RegisteredBarData["bar"].gDef = defaults

			local bar, object = NEURON:CreateNewBar("bar", id, true)

			for i=oid+offset,oid+11+offset do
				object = NEURON:CreateNewObject("bar", i, true)
				bar:AddObjectToList(object)
			end

			NEURON.RegisteredBarData["bar"].gDef = nil
			offset = offset + 12
		end

	else
		for id,data in pairs(barGDB) do
			if (data ~= nil) then
				NEURON:CreateNewBar("bar", id)
			end
		end

		for id,data in pairs(GDB.buttons) do
			if (data ~= nil) then
				NEURON:CreateNewObject("bar", id)
			end
		end
	end

	STORAGE:Hide()

	for _,bar in pairs(BARIndex) do
		if (CDB.firstRun) then
			for id, cdefaults in ipairs(cDef) do
				if (id == bar:GetID()) then
					bar:SetDefaults(nil, cdefaults)
				end
			end
		end

		bar:Load()
	end
end

--- Sets a Target Casting state for a bar
-- @param value(string): Database refrence value to be set
-- @param gui(Bool): Toggle to determine if call was from the GUI
-- @param checked(Bool) : Used when using a GUI checkbox - It is the box's current state
-- @param query: N/A
function BAR:SetCastingTarget(value, gui, checked, query)
	if (value) then
		if (gui) then

			if (checked) then
				self.cdata[value] = true
			else
				self.cdata[value] = false
			end

		else

			local toggle = self.cdata[value]

			if (toggle) then
				self.cdata[value] = false
			else
				self.cdata[value] = true
			end
		end

		BUTTON:UpdateMacroCastTargets()
		self:Update()
	end
end
