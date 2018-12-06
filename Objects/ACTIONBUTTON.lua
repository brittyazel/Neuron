--Neuron, a World of Warcraft® user interface addon.

---@class ACTIONBUTTON : BUTTON @define class ACTIONBUTTON inherits from class BUTTON
local ACTIONBUTTON = setmetatable({}, {__index = Neuron.BUTTON}) --this is the metatable for our button object
Neuron.ACTIONBUTTON = ACTIONBUTTON


local SKIN = LibStub("Masque", true)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

---------------------------------------------------------
-------------------declare globals-----------------------
---------------------------------------------------------
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

local cmdSlash = {
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

local macroCache = {}


--Spells that need their primary spell name overwritten
local AlternateSpellNameList = {
	[883]   = true, --CallPet1
	[83242] = true, --CallPet2
	[83243] = true, --CallPet3
	[83244] = true, --CallPet4
	[83245] = true, --CallPet5
}

local alphaTimer, alphaDir = 0, 0

local autoCast = { speeds = { 2, 4, 6, 8 }, timers = { 0, 0, 0, 0 }, circle = { 0, 22, 44, 66 }, shines = {}, r = 0.95, g = 0.95, b = 0.32 }

local cooldowns, cdAlphas = {}, {}

Neuron.cooldowns = cooldowns
Neuron.cdAlphas = cdAlphas


---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return ACTIONBUTTON @ A newly created ACTIONBUTTON object
function ACTIONBUTTON:new(name)
	local object = CreateFrame("CheckButton", name, UIParent, "NeuronActionButtonTemplate")
	setmetatable(object, {__index = ACTIONBUTTON})
	return object
end


function ACTIONBUTTON.AutoCastStart(shine, r, g, b)
	autoCast.shines[shine] = shine

	if (not r) then
		r, g, b = autoCast.r, autoCast.g, autoCast.b
	end

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Show()
		sparkle:SetVertexColor(r, g, b)
	end
end


function ACTIONBUTTON.AutoCastStop(shine)
	autoCast.shines[shine] = nil

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Hide()
	end
end


--this function gets called via controlOnUpdate in the main Neuron.lua
function ACTIONBUTTON.cooldownsOnUpdate(elapsed)


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

function ACTIONBUTTON.updateAuraInfo(unit)

	local uai_index, uai_spell, uai_count, uai_duration, uai_timeLeft, uai_caster, uai_spellID, _
	uai_index = 1

	wipe(Neuron.unitAuras[unit])

	repeat
		uai_spell, _, uai_count, _, uai_duration, uai_timeLeft, uai_caster, _, _, uai_spellID = UnitAura(unit, uai_index, "HELPFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			Neuron.unitAuras[unit][uai_spell:lower()] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			Neuron.unitAuras[unit][uai_spell:lower().."()"] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)

	uai_index = 1

	repeat
		uai_spell, _, uai_count, _, uai_duration, uai_timeLeft, uai_caster = UnitAura(unit, uai_index, "HARMFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			Neuron.unitAuras[unit][uai_spell:lower()] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			Neuron.unitAuras[unit][uai_spell:lower().."()"] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)
end









--this function gets called via controlOnUpdate in the main Neuron.lua
---this function controlls the sparkley effects around abilities, if throttled then those effects are throttled down super slow. Be careful.
function ACTIONBUTTON.controlOnUpdate(elapsed)
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


function ACTIONBUTTON:LoadData(spec, state)

	local DB = Neuron.db.profile

	local id = self.id

	if (not DB.buttons[id]) then
		DB.buttons[id] = {}
	end

	self.DB = DB.buttons[id]

	self.config = self.DB.config
	self.keys = self.DB.keys
	self.statedata = self.DB[spec] --all of the states for a given spec
	self.data = self.statedata[state] --loads a single state of a single spec into self.data

	self:BuildStateData()
end




function ACTIONBUTTON:SetObjectVisibility(show)

	if not InCombatLockdown() then
		self:SetAttribute("showGrid", self.showGrid) --this is important because in our state switching code, we can't querry self.showGrid directly
		self:SetAttribute("isshown", show)
	end

	if (show or self.showGrid) then
		self:Show()
	elseif not self:MACRO_HasAction() and (not Neuron.ButtonEditMode or not Neuron.BarEditMode or not Neuron.BindingMode) then
		self:Hide()
	end
end



function ACTIONBUTTON:SetAux()
	self:SetSkinned()
	self:UpdateFlyout(true)
end


function ACTIONBUTTON:LoadAux()

	if Neuron.NeuronGUI then
		Neuron.NeuronGUI:ObjEditor_CreateEditFrame(self, self.objTIndex)
	end
	Neuron.NeuronBinder:CreateBindFrame(self, self.objTIndex)

end


function ACTIONBUTTON:SetDefaults(config, keys)
	if (config) then
		for k,v in pairs(config) do
			self.config[k] = v
		end
	end

	if (keys) then
		for k,v in pairs(keys) do
			self.keys[k] = v
		end
	end
end


function ACTIONBUTTON:GetDefaults()
	return nil, keyDefaults[self.id]
end




function ACTIONBUTTON:SetType(save, kill, init)
	local state = self:GetParent():GetAttribute("activestate")

	self:Reset()

	if (kill) then

		self:SetScript("OnEvent", function() end)
		self:SetScript("OnUpdate", function() end)
		self:SetScript("OnAttributeChanged", function() end)

	else
		SecureHandler_OnLoad(self)

		self:RegisterEvent("ITEM_LOCK_CHANGED")
		self:RegisterEvent("ACTIONBAR_SHOWGRID")
		self:RegisterEvent("ACTIONBAR_HIDEGRID")

		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		self:RegisterEvent("UPDATE_MACROS")
		self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		self:RegisterEvent("EQUIPMENT_SETS_CHANGED")

		self:MACRO_UpdateParse()

		self:SetAttribute("type", "macro")
		self:SetAttribute("*macrotext*", self.macroparse)

		self:SetScript("OnEvent", function(self, event, ...) self:MACRO_OnEvent(event, ...) end)
		self:SetScript("PreClick", function(self, mousebutton) self:MACRO_PreClick(mousebutton) end)
		self:SetScript("PostClick", function(self, mousebutton) self:MACRO_PostClick(mousebutton) end)
		self:SetScript("OnReceiveDrag", function(self, preclick) self:MACRO_OnReceiveDrag(preclick) end)
		self:SetScript("OnDragStart", function(self, mousebutton) self:MACRO_OnDragStart(mousebutton) end)
		self:SetScript("OnDragStop", function(self) self:MACRO_OnDragStop() end)
		self:SetScript("OnUpdate", function(self, elapsed) self:MACRO_OnUpdate(elapsed) end)--this function uses A LOT of CPU resources
		self:SetScript("OnShow", function(self, ...) self:MACRO_OnShow(...) end)
		self:SetScript("OnHide", function(self, ...) self:MACRO_OnHide(...) end)
		self:SetScript("OnAttributeChanged", function(self, name, value) self:MACRO_OnAttributeChanged(name, value) end)

		self:HookScript("OnEnter", function(self, ...) self:MACRO_OnEnter(...) end)
		self:HookScript("OnLeave", function(self, ...) self:MACRO_OnLeave(...) end)

		self:WrapScript(self, "OnShow", [[
						for i=1,select('#',(":"):split(self:GetAttribute("hotkeys"))) do
							self:SetBindingClick(self:GetAttribute("hotkeypri"), select(i,(":"):split(self:GetAttribute("hotkeys"))), self:GetName())
						end
						]])

		self:WrapScript(self, "OnHide", [[
						if (not self:GetParent():GetAttribute("concealed")) then
							for key in gmatch(self:GetAttribute("hotkeys"), "[^:]+") do
								self:ClearBinding(key)
							end
						end
						]])

		--new action ID's for vehicle 133-138
		--new action ID's for possess 133-138
		--new action ID's for override 157-162

		self:SetAttribute("overrideID_Offset", 156)
		self:SetAttribute("vehicleID_Offset", 132)

		self:SetAttribute("_childupdate", [=[

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

							if (self:GetAttribute("*macrotext*") and #self:GetAttribute("*macrotext*") > 0) or self:GetAttribute("isshown") then
								self:Show()
							elseif (not self:GetAttribute("showGrid")) then
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
			self:MACRO_UpdateAll(true)
		end

		self:MACRO_OnShow()

	end

end



------------------------------------------------------------
--------------General Button Methods------------------------
------------------------------------------------------------


function ACTIONBUTTON:MACRO_HasAction()
	local hasAction = self.data.macro_Text

	if (self.actionID) then
		if (self.actionID == 0) then
			return true
		else
			return HasAction(self.actionID)
		end

	elseif (hasAction and #hasAction>0) then
		return true
	else
		return false
	end
end


function ACTIONBUTTON:MACRO_GetDragAction()
	return "macro"
end


function ACTIONBUTTON:MACRO_UpdateData(...)

	local ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_cd, ud_cdcmd, ud_aura, ud_auracmd, ud_item, ud_target, ud__


	if (self.macroparse) then
		ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_cd, ud_cdcmd, ud_aura, ud_auracmd, ud_item, ud_target, ud__ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil

		for cmd, options in gmatch(self.macroparse, "(%c%p%a+)(%C+)") do
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

			elseif(NeuronItemCache[ud_spell]) then

				ud_item = ud_spell
				ud_spell = nil


			elseif(tonumber(ud_spell) and GetInventoryItemLink("player", ud_spell)) then
				ud_item = GetInventoryItemLink("player", ud_spell)
				ud_spell = nil
			end
		end

		self.unit = ud_target or "target"

		if (ud_spell) then
			self.macroitem = nil
			if (ud_spell ~= self.macrospell) then

				ud_spell = ud_spell:gsub("!", "")
				self.macrospell = ud_spell

				if (Neuron.sIndex[ud_spell:lower()]) then
					self.spellID = Neuron.sIndex[ud_spell:lower()].spellID
				else
					self.spellID = nil
				end
			end
		else
			self.macrospell = nil
			self.spellID = nil
		end

		if (ud_show and ud_showcmd:find("#showicon")) then
			if (ud_show ~= self.macroicon) then
				if(tonumber(ud_show) and GetInventoryItemLink("player", ud_show)) then
					ud_show = GetInventoryItemLink("player", ud_show)
				end
				self.macroicon = ud_show
				self.macroshow = nil
			end
		elseif (ud_show) then
			if (ud_show ~= self.macroshow) then
				if(tonumber(ud_show) and GetInventoryItemLink("player", ud_show)) then
					ud_show = GetInventoryItemLink("player", ud_show)
				end
				self.macroshow = ud_show
				self.macroicon = nil
			end
		else
			self.macroshow = nil
			self.macroicon = nil
		end

		if (ud_cd) then
			if (ud_cd ~= self.macrocd) then
				if(tonumber(ud_aura) and GetInventoryItemLink("player", ud_cd)) then
					ud_aura = GetInventoryItemLink("player", ud_cd)
				end
				self.macrocd = ud_aura
			end
		else
			self.macrocd = nil
		end

		if (ud_aura) then
			if (ud_aura ~= self.macroaura) then
				if(tonumber(ud_aura) and GetInventoryItemLink("player", ud_aura)) then
					ud_aura = GetInventoryItemLink("player", ud_aura)
				end
				self.macroaura = ud_aura
			end
		else
			self.macroaura = nil
		end

		if (ud_item) then
			self.macrospell = nil;
			self.spellID = nil
			if (ud_item ~= self.macroitem) then
				self.macroitem = ud_item
			end
		else
			self.macroitem = nil
		end
	end
end


function ACTIONBUTTON:MACRO_SetSpellIcon(spell)
	local _, texture

	if (not self.data.macro_Watch and not self.data.macro_Equip) then

		spell = (spell):lower()
		if (Neuron.sIndex[spell]) then
			local spell_id = Neuron.sIndex[spell].spellID
			texture = GetSpellTexture(spell_id)

		elseif (Neuron.cIndex[spell]) then
			texture = Neuron.cIndex[spell].icon

		elseif (spell) then
			texture = GetSpellTexture(spell)
		end

		if (texture) then
			self.iconframeicon:SetTexture(texture)
			self.iconframeicon:Show()
		else
			self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") --show questionmark instead of empty button to avoid confusion
		end

	else
		if (self.data.macro_Watch) then

			_, texture = GetMacroInfo(self.data.macro_Watch)

			self.data.macro_Icon = texture

		end

		if (texture) then
			self.iconframeicon:SetTexture(texture)
			self.iconframeicon:Show()
		else
			self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end
	end

	return texture
end



function ACTIONBUTTON:MACRO_SetItemIcon(item)
	local _,texture, link, itemID

	if (IsEquippedItem(item)) then --makes the border green when item is equipped and dragged to a button
		self.border:SetVertexColor(0, 1.0, 0, 0.2)
		self.border:Show()
	else
		self.border:Hide()
	end

	--There is stored icon and dont want to update icon on fly
	if (((type(self.data.macro_Icon) == "string" and #self.data.macro_Icon > 0) or type(self.data.macro_Icon) == "number")) then
		if (self.data.macro_Icon == "BLANK") then
			self.iconframeicon:SetTexture("")
		else
			self.iconframeicon:SetTexture(self.data.macro_Icon)
		end

	else
		if (NeuronItemCache[item]) then
			texture = GetItemIcon("item:"..NeuronItemCache[item]..":0:0:0:0:0:0:0")
		else
			_,_,_,_,_,_,_,_,_,texture = GetItemInfo(item)
		end

		if (texture) then
			self.iconframeicon:SetTexture(texture)
		else
			self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end
	end

	self.iconframeicon:Show()

	return self.iconframeicon:GetTexture()
end


function ACTIONBUTTON:ACTION_SetIcon(action)
	local actionID = tonumber(action)

	if (actionID) then
		if (actionID == 0) then
			if (self.specAction and Neuron.SpecialActions[self.specAction]) then
				self.iconframeicon:SetTexture(Neuron.SpecialActions[self.specAction])
			else
				self.iconframeicon:SetTexture(0,0,0)
			end

		else
			self.macroname:SetText(GetActionText(actionID))
			if (HasAction(actionID)) then
				self.iconframeicon:SetTexture(GetActionTexture(actionID))
			else
				self.iconframeicon:SetTexture(0,0,0)
			end
		end

		self.iconframeicon:Show()
	else
		self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
	end

	return self.iconframeicon:GetTexture()
end


function ACTIONBUTTON:MACRO_UpdateIcon(...)
	self.updateMacroIcon = nil

	local spell, item, texture = self.macrospell, self.macroitem, self.data.macro_Icon


	if(texture)then --saves an unnecessary lookup as it was set to self.data.macro_Icon when dragged to the bar initially
		self.iconframeicon:SetTexture(texture)
		self.iconframeicon:Show()
	else
		if (self.actionID) then
			texture = self:ACTION_SetIcon(self.actionID)
		elseif (spell and #spell>0) then
			texture = self:MACRO_SetSpellIcon(spell)
			self:MACRO_SetSpellState(spell)
		elseif (item and #item>0) then
			texture = self:MACRO_SetItemIcon(item)
		else
			self.macroname:SetText("")
			self.iconframeicon:SetTexture("")
			self.iconframeicon:Hide()
			self.border:Hide()
		end
	end

	--druid fix for thrash glow not showing for feral druids.
	--Thrash Guardian: 77758
	--Thrash Feral: 106832
	--But the joint thrash is 106830 (this is the one that results true when the ability is procced)

	--Swipe(Bear): 213771
	--Swipe(Cat): 106785
	--Swipe(NoForm): 213764

	if (self.spellID and IsSpellOverlayed(self.spellID)) then
		self:MACRO_StartGlow()
	elseif (spell == "Thrash()" and IsSpellOverlayed(106830)) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
		self:MACRO_StartGlow()
	elseif (spell == "Swipe()" and IsSpellOverlayed(106785)) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
		self:MACRO_StartGlow()
	elseif (self.glowing) then
		self:MACRO_StopGlow()
	end

	return texture
end



function ACTIONBUTTON:MACRO_StartGlow()

	if (self.spellGlowDef) then
		ActionButton_ShowOverlayGlow(self)
	elseif (self.spellGlowAlt) then
		self.AutoCastStart(self.shine)
	end

	self.glowing = true
end

function ACTIONBUTTON:MACRO_StopGlow()
	if (self.spellGlowDef) then
		ActionButton_HideOverlayGlow(self)
	elseif (self.spellGlowAlt) then
		self.AutoCastStop(self.shine)
	end

	self.glowing = nil
end


function ACTIONBUTTON:MACRO_SetSpellState(spell)
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spell)
	if (maxCharges and maxCharges > 1) then
		self.count:SetText(charges)
	else
		self.count:SetText("")
	end

	local count = GetSpellCount(spell)
	if (count and count > 0) then
		self.count:SetText(count)
	end

	if (Neuron.cIndex[spell:lower()]) then
		spell = Neuron.cIndex[spell:lower()].spellID

		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell)) then
			self:SetChecked(1)
		else
			self:SetChecked(nil)
		end
	else
		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell)) then
			self:SetChecked(1)
		else
			self:SetChecked(nil)
		end
	end

	if ((IsAttackSpell(spell) and IsCurrentSpell(spell)) or IsAutoRepeatSpell(spell)) then
		self.mac_flash = true
	else
		self.mac_flash = false
	end

	self.macroname:SetText(self.data.macro_Name)
end


function ACTIONBUTTON:MACRO_SetItemState(item)

	if (GetItemCount(item,nil,true) and  GetItemCount(item,nil,true) > 1) then
		self.count:SetText(GetItemCount(item,nil,true))
	else
		self.count:SetText("")
	end

	if(IsCurrentItem(item)) then
		self:SetChecked(1)
	else
		self:SetChecked(nil)
	end
	self.macroname:SetText(self.data.macro_Name)
end


function ACTIONBUTTON:ACTION_UpdateState(action)
	local actionID = tonumber(action)

	self.count:SetText("")

	if (actionID) then
		self.macroname:SetText("")

		if (IsCurrentAction(actionID) or IsAutoRepeatAction(actionID)) then
			self:SetChecked(1)
		else
			self:SetChecked(nil)
		end

		if ((IsAttackAction(actionID) and IsCurrentAction(actionID)) or IsAutoRepeatAction(actionID)) then
			self.mac_flash = true
		else
			self.mac_flash = false
		end
	else
		self:SetChecked(nil)
		self.mac_flash = false
	end
end



function ACTIONBUTTON:MACRO_UpdateState(...)

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow


	if (self.actionID) then
		self:ACTION_UpdateState(self.actionID)

	elseif (show and #show>0) then

		if (NeuronItemCache[show]) then
			self:MACRO_SetItemState(show)
		else
			self:MACRO_SetSpellState(show)
		end

	elseif (spell and #spell>0) then

		self:MACRO_SetSpellState(spell)

	elseif (item and #item>0) then

		self:MACRO_SetItemState(item)

	elseif (self:GetAttribute("macroShow")) then

		show = self:GetAttribute("macroShow")

		if (NeuronItemCache[show]) then
			self:MACRO_SetItemState(show)
		else
			self:MACRO_SetSpellState(show)
		end
	else
		self:SetChecked(nil)
		self.count:SetText("")
	end
end

-----------------------

function ACTIONBUTTON:MACRO_SetSpellCooldown(spell)

	local DB = Neuron.db.profile

	spell = (spell):lower()
	local spell_id = spell

	if (Neuron.sIndex[spell]) then
		spell_id = Neuron.sIndex[spell].spellID
		local ZoneAbilityID = ZoneAbilityFrame.SpellButton.currentSpellID
		local GarrisonAbilityID = 161691

		--Needs work
		if (spell_id == GarrisonAbilityID and ZoneAbilityID) then spell_id = ZoneAbilityID end
	end

	local start, duration, enable = GetSpellCooldown(spell)
	local charges, maxCharges, chStart, chDuration = GetSpellCharges(spell)
	start, duration, enable = GetSpellCooldown(spell)

	if (duration and duration >= DB.timerLimit and self.iconframeaurawatch.active) then
		self.auraQueue = self.iconframeaurawatch.queueinfo
		self.iconframeaurawatch.duration = 0
		self.iconframeaurawatch:Hide()
	end

	if (charges and maxCharges and maxCharges > 0 and charges < maxCharges) then
		StartChargeCooldown(self, chStart, chDuration);
	end

	Neuron:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
end



function ACTIONBUTTON:MACRO_SetItemCooldown(item)

	local DB = Neuron.db.profile

	local id = NeuronItemCache[item]

	if (id) then

		local start, duration, enable = GetItemCooldown(id)

		if (duration and duration >= DB.timerLimit and self.iconframeaurawatch.active) then
			self.auraQueue = self.iconframeaurawatch.queueinfo
			self.iconframeaurawatch.duration = 0
			self.iconframeaurawatch:Hide()
		end

		Neuron:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end


function ACTIONBUTTON:MACRO_UpdateTexture(force)
	local hasAction = self:MACRO_HasAction()

	if (not self:GetSkinned()) then
		if (hasAction or force) then
			self:SetNormalTexture(self.hasAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,1)
		else
			self:SetNormalTexture(self.noAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,0.5)
		end
	end
end


function ACTIONBUTTON:MACRO_UpdateAll(updateTexture)
	self:MACRO_UpdateData()
	self:MACRO_UpdateButton()
	self:MACRO_UpdateIcon()
	self:MACRO_UpdateState()
	self:MACRO_UpdateTimers()

	if (updateTexture) then
		self:MACRO_UpdateTexture()
	end
end


function ACTIONBUTTON:MACRO_UpdateUsableSpell(spell)
	local isUsable, notEnoughMana, alt_Name
	local spellName = spell:lower()

	if (Neuron.sIndex[spellName]) and (Neuron.sIndex[spellName].spellID ~= Neuron.sIndex[spellName].spellID_Alt) and Neuron.sIndex[spellName].spellID_Alt then
		alt_Name = GetSpellInfo(Neuron.sIndex[spellName].spellID_Alt):lower()
		isUsable, notEnoughMana = IsUsableSpell(alt_Name)
		spellName = alt_Name
	else
		isUsable, notEnoughMana = IsUsableSpell(spellName)
	end

	if (spellName == GetSpellInfo(161691):lower()) then
	end

	if (notEnoughMana) then
		self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])
	elseif (isUsable) then
		if (self.rangeInd and IsSpellInRange(spellName, self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		elseif Neuron.sIndex[spellName] and (self.rangeInd and IsSpellInRange(Neuron.sIndex[spellName].index,"spell", self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end

	else
		if (Neuron.sIndex[(spell):lower()]) then
			self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end
	end
end


function ACTIONBUTTON:MACRO_UpdateUsableItem(item)
	local isUsable, notEnoughMana = IsUsableItem(item)-- or PlayerHasToy(NeuronItemCache[item])
	--local isToy = Neuron.tIndex[item]
	if Neuron.tIndex[item:lower()] then isUsable = true end

	if (notEnoughMana and self.manacolor) then
		self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])
	elseif (isUsable) then
		if (self.rangeInd and IsItemInRange(spell, self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end

	else
		self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end


function ACTIONBUTTON:ACTION_UpdateUsable(action)
	local actionID = tonumber(action)

	if (actionID) then
		if (actionID == 0) then
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		else
			local isUsable, notEnoughMana = IsUsableAction(actionID)

			if (isUsable) then
				if (IsActionInRange(action, self.unit) == 0) then
					self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
				else
					self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
				end

			elseif (notEnoughMana and self.manacolor) then
				self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])
			else
				self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end

	else
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end


function ACTIONBUTTON:MACRO_UpdateButton(...)

	if (self.editmode) then

		self.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)

	elseif (self.actionID) then

		self:ACTION_UpdateUsable(self.actionID)

	elseif (self.macroshow and #self.macroshow>0) then

		if(NeuronItemCache[self.macroshow]) then
			self:MACRO_UpdateUsableItem(self.macroshow)
		else
			self:MACRO_UpdateUsableSpell(self.macroshow)
		end

	elseif (self.macrospell and #self.macrospell>0) then

		self:MACRO_UpdateUsableSpell(self.macrospell)

	elseif (self.macroitem and #self.macroitem>0) then

		self:MACRO_UpdateUsableItem(self.macroitem)

	else
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end


---TODO:
---We need to figure out what this function did.
---Update: Seems to be important for range indication (i.e. button going red)
function ACTIONBUTTON:MACRO_OnUpdate(elapsed) --this function uses A TON of resources

	local DB = Neuron.db.profile

	if (self.elapsed > DB.throttle) then --throttle down this code to ease up on the CPU a bit

		if (self.mac_flash) then

			self.mac_flashing = true

			if (alphaDir == 1) then
				if ((1 - (alphaTimer)) >= 0) then
					self.iconframeflash:Show()
				end
			elseif (alphaDir == 0) then
				if ((alphaTimer) <= 1) then
					self.iconframeflash:Hide()
				end
			end

		elseif (self.mac_flashing) then
			self.iconframeflash:Hide()
			self.mac_flashing = false
		end

		self:MACRO_UpdateButton()


		if (self.auraQueue and not self.iconframecooldown.active) then
			local unit, spell = (":"):split(self.auraQueue)
			if (unit and spell) then
				self.auraQueue = nil;
				self:MACRO_UpdateAuraWatch(unit, spell)
			end
		end

		self.elapsed = 0
	end

	self.elapsed = self.elapsed + elapsed

end


function ACTIONBUTTON:MACRO_ShowGrid()
	self:SetObjectVisibility(true)
end


function ACTIONBUTTON:MACRO_HideGrid()
	self:SetObjectVisibility()
end



------------------------------------------------------------------------------
---------------------Event Functions------------------------------------------
------------------------------------------------------------------------------

--I'm not sure why all these are here, they don't seem to be used

function ACTIONBUTTON:MACRO_ACTIONBAR_UPDATE_COOLDOWN(...)
	self:MACRO_UpdateTimers(...)
end

--pointer
ACTIONBUTTON.MACRO_RUNE_POWER_UPDATE = ACTIONBUTTON.MACRO_ACTIONBAR_UPDATE_COOLDOWN


function ACTIONBUTTON:MACRO_ACTIONBAR_UPDATE_STATE(...)
	self:MACRO_UpdateState(...)
end

--pointers
ACTIONBUTTON.MACRO_COMPANION_UPDATE = ACTIONBUTTON.MACRO_ACTIONBAR_UPDATE_STATE
ACTIONBUTTON.MACRO_TRADE_SKILL_SHOW = ACTIONBUTTON.MACRO_ACTIONBAR_UPDATE_STATE
ACTIONBUTTON.MACRO_TRADE_SKILL_CLOSE = ACTIONBUTTON.MACRO_ACTIONBAR_UPDATE_STATE
ACTIONBUTTON.MACRO_ARCHAEOLOGY_CLOSED = ACTIONBUTTON.MACRO_ACTIONBAR_UPDATE_STATE


function ACTIONBUTTON:MACRO_ACTIONBAR_UPDATE_USABLE(...)
	-- TODO
end



function ACTIONBUTTON:MACRO_BAG_UPDATE_COOLDOWN(...)

	if (self.macroitem) then
		self:MACRO_UpdateState(...)
	end
end


ACTIONBUTTON.MACRO_BAG_UPDATE = ACTIONBUTTON.MACRO_BAG_UPDATE_COOLDOWN


function ACTIONBUTTON:MACRO_UNIT_AURA(...)
	local unit = select(1, ...)

	if (Neuron.unitAuras[unit]) then
		self:MACRO_UpdateAuraWatch(self, unit, self.macrospell)

		if (unit == "player") then
			self:MACRO_UpdateData(...)
		end
	end
end


ACTIONBUTTON.MACRO_UPDATE_MOUSEOVER_UNIT = ACTIONBUTTON.MACRO_UNIT_AURA


function ACTIONBUTTON:MACRO_UNIT_SPELLCAST_INTERRUPTED(...)

	local unit = select(1, ...)

	if ((unit == "player" or unit == "pet") and spell and self.macrospell) then

		self:MACRO_UpdateTimers(...)
	end

end


ACTIONBUTTON.MACRO_UNIT_SPELLCAST_FAILED = ACTIONBUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
ACTIONBUTTON.MACRO_UNIT_PET = ACTIONBUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
ACTIONBUTTON.MACRO_UNIT_ENTERED_VEHICLE = ACTIONBUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
ACTIONBUTTON.MACRO_UNIT_ENTERING_VEHICLE = ACTIONBUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
ACTIONBUTTON.MACRO_UNIT_EXITED_VEHICLE = ACTIONBUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED


function ACTIONBUTTON:MACRO_SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(...)
	local spellID = select(2, ...)

	if (self.spellGlow and self.spellID and spellID == self.spellID) then

		self:MACRO_UpdateTimers(...)

		self:MACRO_StartGlow()
	end
end


function ACTIONBUTTON:MACRO_SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(...)
	local spellID = select(2, ...)

	if ((self.overlay or self.spellGlow) and self.spellID and spellID == self.spellID) then

		self:MACRO_StopGlow()
	end
end


function ACTIONBUTTON:MACRO_ACTIVE_TALENT_GROUP_CHANGED(...)

	if(InCombatLockdown()) then
		return
	end

	local spec

	if (self.multiSpec) then
		spec = GetSpecialization()
	else
		spec = 1
	end

	self:LoadData(spec, self:GetParent():GetAttribute("activestate") or "homestate")
	self:UpdateFlyout()
	self:SetType()
	self:MACRO_UpdateAll(true)
	self:SetObjectVisibility()

end


function ACTIONBUTTON:MACRO_PLAYER_ENTERING_WORLD(...)

	WorldFrame:SetScript("OnMouseDown", function() self:OnMouseDown() end)

	self:MACRO_Reset()
	self:MACRO_UpdateAll(true)
	Neuron.NeuronBinder:ApplyBindings(self)
end

---super broken with 8.0
--[[function ACTIONBUTTON:MACRO_PET_JOURNAL_LIST_UPDATE(...)
	self:MACRO_UpdateAll(true)
end]]


function ACTIONBUTTON:MACRO_MODIFIER_STATE_CHANGED(...)
	self:MACRO_UpdateAll(true)
end


ACTIONBUTTON.MACRO_SPELL_UPDATE_USABLE = ACTIONBUTTON.MACRO_MODIFIER_STATE_CHANGED


function ACTIONBUTTON:MACRO_ACTIONBAR_SLOT_CHANGED(...)
	if (self.data.macro_Watch or self.data.macro_Equip) then
		self:MACRO_UpdateIcon()
	end
end


function ACTIONBUTTON:MACRO_PLAYER_TARGET_CHANGED(...)
	self:MACRO_UpdateTimers()
end


ACTIONBUTTON.MACRO_PLAYER_FOCUS_CHANGED = ACTIONBUTTON.MACRO_PLAYER_TARGET_CHANGED

function ACTIONBUTTON:MACRO_ITEM_LOCK_CHANGED(...)
end


function ACTIONBUTTON:MACRO_ACTIONBAR_SHOWGRID(...)
	self:MACRO_ShowGrid()
end


function ACTIONBUTTON:MACRO_ACTIONBAR_HIDEGRID(...)
	self:MACRO_HideGrid()
end


function ACTIONBUTTON:MACRO_UPDATE_MACROS(...)
	if (Neuron.PEW and not InCombatLockdown() and self.data.macro_Watch) then
		self:MACRO_PlaceBlizzMacro(self.data.macro_Watch)
	end
end


function ACTIONBUTTON:MACRO_EQUIPMENT_SETS_CHANGED(...)
	if (Neuron.PEW and not InCombatLockdown() and self.data.macro_Equip) then
		self:MACRO_PlaceBlizzEquipSet(self.data.macro_Equip)
	end
end


function ACTIONBUTTON:MACRO_PLAYER_EQUIPMENT_CHANGED(...)
	if (self.data.macro_Equip) then
		self:MACRO_UpdateIcon()
	end
end


function ACTIONBUTTON:MACRO_UPDATE_VEHICLE_ACTIONBAR(...)

	if (self.actionID) then
		self:MACRO_UpdateAll(true)
	end
end

ACTIONBUTTON.MACRO_UPDATE_POSSESS_BAR = ACTIONBUTTON.MACRO_UPDATE_VEHICLE_ACTIONBAR
ACTIONBUTTON.MACRO_UPDATE_OVERRIDE_ACTIONBAR = ACTIONBUTTON.MACRO_UPDATE_VEHICLE_ACTIONBAR

--for 4.x compatibility
ACTIONBUTTON.MACRO_UPDATE_BONUS_ACTIONBAR = ACTIONBUTTON.MACRO_UPDATE_VEHICLE_ACTIONBAR


function ACTIONBUTTON:MACRO_SPELL_UPDATE_CHARGES(...)

	local spell = self.macrospell
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spell)

	if (maxCharges and maxCharges > 1) then
		self.count:SetText(charges)
	else
		self.count:SetText("")
	end
end


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

---This strips out the "MACRO_" in front of the event name function, and brokers the event to the right object
function ACTIONBUTTON:MACRO_OnEvent(eventName, ...)
	local event = "MACRO_".. eventName

	if (self[event]) then
		self[event](self, ...)
	end
end




function ACTIONBUTTON:MACRO_PlaceSpell(action1, action2, spellID)
	local spell

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
		self.data.macro_Text = self:AutoWriteMacro(spellInfoName)
		self.data.macro_Auto = spellInfoName..";"
	else
		self.data.macro_Text = self:AutoWriteMacro(spell)

		self.data.macro_Auto = spell
	end

	self.data.macro_Icon = icon  --also set later in SetSpellIcon
	self.data.macro_Name = spellInfoName
	self.data.macro_Watch = false
	self.data.macro_Equip = false
	self.data.macro_Note = ""
	self.data.macro_UseNote = false

	if (not self.cursor) then
		self:SetType(true)
	end

	Neuron.MacroDrag[1] = false

	ClearCursor()
	SetCursor(nil)

end

function ACTIONBUTTON:MACRO_PlacePetAbility(action1, action2)

	local spellID = action1
	local spellIndex = action2

	if spellIndex then --if the ability doesn't have a spellIndex, i.e (passive, follow, defensive, etc, print a warning)
		local spellInfoName , _, icon, castTime, minRange, maxRange= GetSpellInfo(spellID)

		self.data.macro_Text = self:AutoWriteMacro(spellInfoName)

		self.data.macro_Auto = spellInfoName


		self.data.macro_Icon = icon --also set later in SetSpellIcon
		self.data.macro_Name = spellInfoName
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end
	else
		Neuron:Print("Sorry, you cannot place that ability at this time.")
	end

	Neuron.MacroDrag[1] = false

	ClearCursor()
	SetCursor(nil)

end


function ACTIONBUTTON:MACRO_PlaceItem(action1, action2, hasAction)
	local item, link = GetItemInfo(action2)

	if link and not NeuronItemCache[item] then --add the item to the itemcache if it isn't otherwise in it
		local _, itemID = link:match("(item:)(%d+)")
		NeuronItemCache[item] = itemID
	end

	if (IsEquippableItem(item)) then
		self.data.macro_Text = "/equip "..item.."\n/use "..item
	else
		self.data.macro_Text = "/use "..item
	end

	self.data.macro_Icon = false
	self.data.macro_Name = item
	self.data.macro_Auto = false
	self.data.macro_Watch = false
	self.data.macro_Equip = false
	self.data.macro_Note = ""
	self.data.macro_UseNote = false

	if (not self.cursor) then
		self:SetType(true)
	end

	Neuron.MacroDrag[1] = false

	ClearCursor()
	SetCursor(nil)
end


function ACTIONBUTTON:MACRO_PlaceBlizzMacro(action1)
	if (action1 == 0) then
		return
	else

		local name, icon, body = GetMacroInfo(action1)

		if (body) then

			self.data.macro_Text = body
			self.data.macro_Name = name
			self.data.macro_Watch = name
			self.data.macro_Icon = icon
		else
			self.data.macro_Text = ""
			self.data.macro_Name = ""
			self.data.macro_Watch = false
			self.data.macro_Icon = false
		end

		self.data.macro_Equip = false
		self.data.macro_Auto = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function ACTIONBUTTON:MACRO_PlaceBlizzEquipSet(equipmentSetName)
	if (equipmentSetName == 0) then
		return
	else

		local equipsetNameIndex = 0 ---cycle through the equipment sets to find the index of the one with the right name

		for i = 1,C_EquipmentSet.GetNumEquipmentSets() do
			if equipmentSetName == C_EquipmentSet.GetEquipmentSetInfo(i) then
				equipsetNameIndex = i
			end
		end


		local name, icon = C_EquipmentSet.GetEquipmentSetInfo(equipsetNameIndex)
		if (texture) then
			self.data.macro_Text = "/equipset "..equipmentSetName
			self.data.macro_Equip = equipmentSetName
			self.data.macro_Name = name
			self.data.macro_Icon = icon
		else
			self.data.macro_Text = ""
			self.data.macro_Equip = false
			self.data.macro_Name = ""
			self.data.macro_Icon = false
		end

		self.data.macro_Name = ""
		self.data.macro_Watch = false
		self.data.macro_Auto = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


--Hooks mount journal mount buttons on enter to pull spellid from tooltip--
--Based on discusion thread http://www.wowinterface.com/forums/showthread.php?t=49599&page=2
--More dynamic than the manual list that was originally implemente




function ACTIONBUTTON:MACRO_PlaceMount(action1, action2, hasAction)


	local mountName, mountSpellID, mountIcon = C_MountJournal.GetMountInfoByID(action1)

	if (action1 == 0) then
		return
	else
		--The Summon Random Mount from the Mount Journal
		if action1 == 268435455 then
			self.data.macro_Text = "#autowrite\n/run C_MountJournal.SummonByID(0);"
			self.data.macro_Auto = "Random Mount;"
			self.data.macro_Icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_MOUNTUP"
			self.data.macro_Name = "Random Mount"
			--Any other mount from the Journal
		else

			self.data.macro_Text = "#autowrite\n/cast "..mountName..";"
			self.data.macro_Auto = mountName..";"
			self.data.macro_Icon = mountIcon
			self.data.macro_Name = mountName
		end

		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function ACTIONBUTTON:MACRO_PlaceCompanion(action1, action2, hasAction)

	if (action1 == 0) then
		return

	else
		local _, _, spellID, icon = GetCompanionInfo(action2, action1)
		local name = GetSpellInfo(spellID)

		if (name) then
			self.data.macro_Name = name
			self.data.macro_Text = self:AutoWriteMacro(name)
			self.data.macro_Auto = name
		else
			self.data.macro_Name = ""
			self.data.macro_Text = ""
			self.data.macro_Auto = false
		end

		self.data.macro_Icon = icon
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end

function ACTIONBUTTON:MACRO_PlaceBattlePet(action1, action2, hasAction)
	local petName, petIcon
	local _ --variable used to discard unwanted return values

	if (action1 == 0) then
		return
	else
		_, _, _, _, _, _, _,petName, petIcon= C_PetJournal.GetPetInfoByPetID(action1)

		self.data.macro_Text = "#autowrite\n/summonpet "..petName
		self.data.macro_Auto = petName..";"
		--self.data.macro_Text = self:AutoWriteMacro(petName)
		self.data.macro_Icon = petIcon
		self.data.macro_Name = petName
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false


		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function ACTIONBUTTON:MACRO_PlaceFlyout(action1, action2, hasAction)
	if (action1 == 0) then
		return
	else
		local count = self.bar.objCount
		local columns = self.bar.data.columns or count
		local rows = count/columns

		local point = self:GetPosition(UIParent)

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

		self.data.macro_Text = "/flyout blizz:"..action1..":l:"..point..":c"
		self.data.macro_Icon = false
		self.data.macro_Name = ""
		self.data.macro_Auto = false
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		self:UpdateFlyout(true)

		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function ACTIONBUTTON:MACRO_PlaceMacro()
	self.data.macro_Text = Neuron.MacroDrag[3]
	self.data.macro_Icon = Neuron.MacroDrag[4]
	self.data.macro_Name = Neuron.MacroDrag[5]
	self.data.macro_Auto = Neuron.MacroDrag[6]
	self.data.macro_Watch = Neuron.MacroDrag[7]
	self.data.macro_Equip = Neuron.MacroDrag[8]
	self.data.macro_Note = Neuron.MacroDrag[9]
	self.data.macro_UseNote = Neuron.MacroDrag[10]

	if (not self.cursor) then
		self:SetType(true)
	end

	PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)

	wipe(Neuron.MacroDrag);
	ClearCursor();
	SetCursor(nil);

	self:UpdateFlyout()
	Neuron:ToggleButtonGrid(false)

end


function ACTIONBUTTON:MACRO_PickUpMacro()
	local pickup

	if (not self.barLock) then
		pickup = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		pickup = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		pickup = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		pickup = true
	end

	if (pickup) then
		local texture, move = self.iconframeicon:GetTexture()

		if (macroCache[1]) then  ---triggers when picking up an existing button with a button in the cursor

			wipe(Neuron.MacroDrag)

			for k,v in pairs(macroCache) do
				Neuron.MacroDrag[k] = v
			end

			wipe(macroCache)

			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")


		elseif (self:MACRO_HasAction()) then
			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")

			Neuron.MacroDrag[1] = self:MACRO_GetDragAction()
			Neuron.MacroDrag[2] = self
			Neuron.MacroDrag[3] = self.data.macro_Text
			Neuron.MacroDrag[4] = self.data.macro_Icon
			Neuron.MacroDrag[5] = self.data.macro_Name
			Neuron.MacroDrag[6] = self.data.macro_Auto
			Neuron.MacroDrag[7] = self.data.macro_Watch
			Neuron.MacroDrag[8] = self.data.macro_Equip
			Neuron.MacroDrag[9] = self.data.macro_Note
			Neuron.MacroDrag[10] = self.data.macro_UseNote
			Neuron.MacroDrag.texture = texture

			self.data.macro_Text = ""
			self.data.macro_Icon = false
			self.data.macro_Name = ""
			self.data.macro_Auto = false
			self.data.macro_Watch = false
			self.data.macro_Equip = false
			self.data.macro_Note = ""
			self.data.macro_UseNote = false

			self.macrospell = nil
			self.spellID = nil
			self.macroitem = nil
			self.macroshow = nil
			self.macroicon = nil

			self:UpdateFlyout()

			self:SetType(true)

		end

	end
end

---This is the function that fires when a button is receiving a dragged item
function ACTIONBUTTON:MACRO_OnReceiveDrag(preclick)
	if (InCombatLockdown()) then
		return
	end

	local cursorType, action1, action2, spellID = GetCursorInfo()

	local texture = self.iconframeicon:GetTexture()

	if (self:MACRO_HasAction()) then
		wipe(macroCache)

		---macroCache holds on to the previos macro's info if you are dropping a new macro on top of an existing macro
		macroCache[1] = self:MACRO_GetDragAction()
		macroCache[2] = self
		macroCache[3] = self.data.macro_Text
		macroCache[4] = self.data.macro_Icon
		macroCache[5] = self.data.macro_Name
		macroCache[6] = self.data.macro_Auto
		macroCache[7] = self.data.macro_Watch
		macroCache[8] = self.data.macro_Equip
		macroCache[9] = self.data.macro_Note
		macroCache[10] = self.data.macro_UseNote

		macroCache.texture = texture
	end


	if (Neuron.MacroDrag[1]) then
		self:MACRO_PlaceMacro()
	elseif (cursorType == "spell") then
		self:MACRO_PlaceSpell(action1, action2, spellID, self:MACRO_HasAction())

	elseif (cursorType == "item") then
		self:MACRO_PlaceItem(action1, action2, self:MACRO_HasAction())

	elseif (cursorType == "macro") then
		self:MACRO_PlaceBlizzMacro(action1)

	elseif (cursorType == "equipmentset") then
		self:MACRO_PlaceBlizzEquipSet(action1)

	elseif (cursorType == "mount") then
		self:MACRO_PlaceMount(action1, action2, self:MACRO_HasAction())

	elseif (cursorType == "flyout") then
		self:MACRO_PlaceFlyout(action1, action2, self:MACRO_HasAction())

	elseif (cursorType == "battlepet") then
		self:MACRO_PlaceBattlePet(action1, action2, self:MACRO_HasAction())
	elseif(cursorType == "companion") then
		self:MACRO_PlaceCompanion(action1, action2, self:MACRO_HasAction())
	elseif (cursorType == "petaction") then
		self:MACRO_PlacePetAbility(action1, action2)
	end


	if (Neuron.StartDrag and macroCache[1]) then
		self:MACRO_PickUpMacro()
		Neuron:ToggleButtonGrid(true)
	end

	self:MACRO_UpdateAll(true)

	Neuron.StartDrag = false

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		Neuron.NeuronGUI:UpdateObjectGUI()
	end
end

---this is the function that fires when you begin dragging an item
function ACTIONBUTTON:MACRO_OnDragStart(mousebutton)

	if (InCombatLockdown() or not self.bar or self.vehicle_edit or self.actionID) then
		Neuron.StartDrag = false
		return
	end

	self.drag = nil

	if (not self.barLock) then
		self.drag = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		self.drag = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		self.drag = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		self.drag = true
	end

	if (self.drag) then
		Neuron.StartDrag = self:GetParent():GetAttribute("activestate")

		self.dragbutton = mousebutton
		self:MACRO_PickUpMacro()

		if (Neuron.MacroDrag[1]) then
			--PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)

			if (Neuron.MacroDrag[2] ~= self) then
				self.dragbutton = nil
			end

			Neuron:ToggleButtonGrid(true)
		else
			self.dragbutton = nil
		end

		self:MACRO_UpdateAll()

		self.iconframecooldown.duration = 0
		self.iconframecooldown.timer:SetText("")
		self.iconframecooldown:Hide()

		self.iconframeaurawatch.duration = 0
		self.iconframeaurawatch.timer:SetText("")
		self.iconframeaurawatch:Hide()

		self.macroname:SetText("")
		self.count:SetText("")

		self.macrospell = nil
		self.spellID = nil
		self.actionID = nil
		self.macroitem = nil
		self.macroshow = nil
		self.macroicon = nil

		self.auraQueue = nil

		self.border:Hide()

		---shows all action bar buttons in the case you have show grid turned off


	else
		Neuron.StartDrag = false
	end

end


function ACTIONBUTTON:MACRO_OnDragStop()
	self.drag = nil
end


---This function will be used to check if we should release the cursor
function ACTIONBUTTON:OnMouseDown()
	if Neuron.MacroDrag[1] then
		PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)
		wipe(Neuron.MacroDrag)

		for index, bar in pairs(Neuron.BARIndex) do
			Neuron.NeuronBar:UpdateObjectVisibility(self.bar)
		end

	end
end



function ACTIONBUTTON:MACRO_PreClick(mousebutton)
	self.cursor = nil

	if (not InCombatLockdown() and MouseIsOver(self)) then
		local cursorType = GetCursorInfo()

		if (cursorType or Neuron.MacroDrag[1]) then
			self.cursor = true

			Neuron.StartDrag = self:GetParent():GetAttribute("activestate")

			self:SetType(true)

			Neuron:ToggleButtonGrid(true)

			self:MACRO_OnReceiveDrag(true)

		elseif (mousebutton == "MiddleButton") then
			self.middleclick = self:GetAttribute("type")

			self:SetAttribute("type", "")

		end
	end

	Neuron.ClickedButton = self
end


function ACTIONBUTTON:MACRO_PostClick(mousebutton)
	if (not InCombatLockdown() and MouseIsOver(self)) then

		if (self.cursor) then
			self:SetType(true)

			self.cursor = nil

		elseif (self.middleclick) then
			self:SetAttribute("type", self.middleclick)

			self.middleclick = nil
		end
	end
	self:MACRO_UpdateState()
end


function ACTIONBUTTON:MACRO_SetSpellTooltip(spell)

	if (Neuron.sIndex[spell]) then

		local spell_id = Neuron.sIndex[spell].spellID

		if(spell_id) then --double check that the spell_id is valid (for switching specs, other specs abilities won't be valid even though a bar might be bound to one)

			local zoneability_id = ZoneAbilityFrame.SpellButton.currentSpellID

			if spell_id == 161691 and zoneability_id then
				spell_id = zoneability_id
			end


			if (self.UberTooltips) then
				GameTooltip:SetSpellByID(spell_id)
			else
				spell = GetSpellInfo(spell_id)
				GameTooltip:SetText(spell, 1, 1, 1)
			end

			self.UpdateTooltip = macroButton_SetTooltip
		end

	elseif (Neuron.cIndex[spell]) then

		if (self.UberTooltips and Neuron.cIndex[spell].creatureType =="MOUNT") then
			GameTooltip:SetHyperlink("spell:"..Neuron.cIndex[spell].spellID)
		else
			GameTooltip:SetText(Neuron.cIndex[spell].creatureName, 1, 1, 1)
		end

		self.UpdateTooltip = nil
	end
end


function ACTIONBUTTON:MACRO_SetItemTooltip(item)
	local name, link = GetItemInfo(item)

	if (Neuron.tIndex[item:lower()]) then
		if (self.UberTooltips) then
			local itemID = Neuron.tIndex[item:lower()]
			GameTooltip:ClearLines()
			GameTooltip:SetToyByItemID(itemID)
		else
			GameTooltip:SetText(name, 1, 1, 1)
		end

	elseif (link) then
		if (self.UberTooltips) then
			GameTooltip:SetHyperlink(link)
		else
			GameTooltip:SetText(name, 1, 1, 1)
		end

	elseif (NeuronItemCache[item]) then
		if (self.UberTooltips) then
			GameTooltip:SetHyperlink("item:"..NeuronItemCache[item]..":0:0:0:0:0:0:0")
		else
			GameTooltip:SetText(NeuronItemCache[item], 1, 1, 1)
		end
	end
end


function ACTIONBUTTON:ACTION_SetTooltip(action)
	local actionID = tonumber(action)

	if (actionID) then

		self.UpdateTooltip = nil

		if (HasAction(actionID)) then
			GameTooltip:SetAction(actionID)
		end
	end
end


function ACTIONBUTTON:MACRO_SetTooltip(edit)
	self.UpdateTooltip = nil

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.actionID) then
		self:ACTION_SetTooltip(self.actionID)

	elseif (show and #show>0) then
		if(NeuronItemCache[show]) then
			self:MACRO_SetItemTooltip(show)
		else
			self:MACRO_SetSpellTooltip(show:lower())
		end

	elseif (spell and #spell>0) then
		self:MACRO_SetSpellTooltip(spell:lower())

	elseif (item and #item>0) then
		self:MACRO_SetItemTooltip(item)

	elseif (self:GetAttribute("macroShow")) then
		show = self:GetAttribute("macroShow")

		if(NeuronItemCache[show]) then
			self:MACRO_SetItemTooltip(show)
		else
			self:MACRO_SetSpellTooltip(show:lower())
		end

	elseif (self.data.macro_Text and #self.data.macro_Text > 0) then
		local equipset = self.data.macro_Text:match("/equipset%s+(%C+)")

		if (equipset) then
			equipset = equipset:gsub("%pnobtn:2%p ", "")
			GameTooltip:SetEquipmentSet(equipset)
		elseif (self.data.macro_Name and #self.data.macro_Name>0) then
			GameTooltip:SetText(self.data.macro_Name)
		end
	end
end


function ACTIONBUTTON:MACRO_OnEnter(...)
	if (self.bar) then
		if (self.tooltipsCombat and InCombatLockdown()) then
			return
		end

		if(Neuron.MacroDrag[1]) then ---puts the icon back to the interact icon when moving abilities around and the mouse enteres the WorldFrame
		SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")
		end

		if (self.tooltips) then
			if (self.tooltipsEnhanced) then
				self.UberTooltips = true
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			else
				self.UberTooltips = false
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			end

			self:MACRO_SetTooltip()

			GameTooltip:Show()
		end

		if (self.flyout and self.flyout.arrow) then
			self.flyout.arrow:SetPoint(self.flyout.arrowPoint, self.flyout.arrowX/0.625, self.flyout.arrowY/0.625)
		end

	end
end


function ACTIONBUTTON:MACRO_OnLeave(...)
	self.UpdateTooltip = nil

	GameTooltip:Hide()

	if (self.flyout and self.flyout.arrow) then
		self.flyout.arrow:SetPoint(self.flyout.arrowPoint, self.flyout.arrowX, self.flyout.arrowY)
	end
end


function ACTIONBUTTON:MACRO_OnShow(...)
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	self:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	self:RegisterEvent("ACTIONBAR_UPDATE_USABLE")

	self:RegisterEvent("SPELL_UPDATE_CHARGES")
	self:RegisterEvent("SPELL_UPDATE_USABLE")

	self:RegisterEvent("RUNE_POWER_UPDATE")

	self:RegisterEvent("TRADE_SKILL_SHOW")
	self:RegisterEvent("TRADE_SKILL_CLOSE")
	self:RegisterEvent("ARCHAEOLOGY_CLOSED")

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_ENTERING_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")

	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_ENTER_COMBAT")
	self:RegisterEvent("PLAYER_LEAVE_COMBAT")
	self:RegisterEvent("PLAYER_CONTROL_LOST")
	self:RegisterEvent("PLAYER_CONTROL_GAINED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("COMPANION_UPDATE")
	self:RegisterEvent("PET_STABLE_UPDATE")
	self:RegisterEvent("PET_STABLE_SHOW")

	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	self:RegisterEvent("UPDATE_POSSESS_BAR")
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")

	--self:RegisterEvent("PET_JOURNAL_LIST_UPDATE")

end


function ACTIONBUTTON:MACRO_OnHide(...)
	self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	self:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
	self:UnregisterEvent("ACTIONBAR_UPDATE_USABLE")

	self:UnregisterEvent("SPELL_UPDATE_CHARGES")
	self:UnregisterEvent("SPELL_UPDATE_USABLE")

	self:UnregisterEvent("RUNE_POWER_UPDATE")

	self:UnregisterEvent("TRADE_SKILL_SHOW")
	self:UnregisterEvent("TRADE_SKILL_CLOSE")
	self:UnregisterEvent("ARCHAEOLOGY_CLOSED")

	self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")

	self:UnregisterEvent("MODIFIER_STATE_CHANGED")

	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	self:UnregisterEvent("UNIT_PET")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")

	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_ENTER_COMBAT")
	self:UnregisterEvent("PLAYER_LEAVE_COMBAT")
	self:UnregisterEvent("PLAYER_CONTROL_LOST")
	self:UnregisterEvent("PLAYER_CONTROL_GAINED")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")

	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
	self:UnregisterEvent("BAG_UPDATE")
	self:UnregisterEvent("COMPANION_UPDATE")
	self:UnregisterEvent("PET_STABLE_UPDATE")
	self:UnregisterEvent("PET_STABLE_SHOW")

	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

	self:UnregisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	self:UnregisterEvent("UPDATE_POSSESS_BAR")
	self:UnregisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	--self:UnregisterEvent("PET_JOURNAL_LIST_UPDATE")

end


function ACTIONBUTTON:MACRO_OnAttributeChanged(name, value)

	if (value and self.data) then
		if (name == "activestate") then

			---Part 1 of Druid Prowl overwrite fix
			-----------------------------------------------------
			---breaks out of the loop due to flag set below
			if (Neuron.class == "DRUID" and self.ignoreNextOverrideStance == true and value == "homestate") then
				self.ignoreNextOverrideStance = nil
				Neuron.NeuronBar:SetState(self.bar, "stealth") --have to add this in otherwise the button icons change but still retain the homestate ability actions
				return
			else
				self.ignoreNextOverrideStance = nil
			end
			-----------------------------------------------------
			-----------------------------------------------------

			if (self:GetAttribute("HasActionID")) then
				self.actionID = self:GetAttribute("*action*")
			else

				if (not self.statedata[value]) then
					self.statedata[value] = {}
				end

				---Part 2 of Druid Prowl overwrite fix
				---------------------------------------------------
				---druids have an issue where once stance will get immediately overwritten by another. I.E. stealth immediately getting overwritten by homestate if they go immediately into prowl from caster form
				---this conditional sets a flag to ignore the next most stance flag, as that one is most likely in error and should be ignored
				if(Neuron.class == "DRUID" and value == "stealth1") then
					self.ignoreNextOverrideStance = true
				end
				------------------------------------------------------
				------------------------------------------------------


				self.data = self.statedata[value]

				self:MACRO_UpdateParse()

				self:MACRO_Reset()

				self.actionID = false
			end

			--This will remove any old button state data from the saved varabiels/memory
			--for id,data in pairs(self.bar.data) do
			for id,data in pairs(self.statedata) do
				if (self.bar.data[id:match("%a+")]) or (id == "" and self.bar.data["custom"])  then
				elseif not self.bar.data[id:match("%a+")] then
					self.statedata[id]= nil
				end
			end

			self.specAction = self:GetAttribute("SpecialAction") --?
			self:MACRO_UpdateAll(true)
		end

		if (name == "update") then
			self:MACRO_UpdateAll(true)
		end
	end


end


function ACTIONBUTTON:MACRO_Reset()
	self.macrospell = nil
	self.spellID = nil
	self.macroitem = nil
	self.macroshow = nil
	self.macroicon = nil
end


function ACTIONBUTTON:MACRO_UpdateParse()
	self.macroparse = self.data.macro_Text

	if (#self.macroparse > 0) then
		self.macroparse = "\n"..self.macroparse.."\n"
		self.macroparse = (self.macroparse):gsub("(%c+)", " %1")
	else
		self.macroparse = nil
	end
end



function ACTIONBUTTON:UpdateButtonSpec(bar)
	local spec

	if (bar.data.multiSpec) then
		spec = GetSpecialization()
	else
		spec = 1
	end

	self:SetData(bar)
	self:LoadData(spec, bar.handler:GetAttribute("activestate"))
	self:UpdateFlyout()
	self:SetType()
	self:SetObjectVisibility()

end



function ACTIONBUTTON:BuildStateData()
	for state, data in pairs(self.statedata) do
		self:SetAttribute(state.."-macro_Text", data.macro_Text)
		self:SetAttribute(state.."-actionID", data.actionID)
	end
end


function ACTIONBUTTON:Reset()
	self:SetAttribute("unit", nil)
	self:SetAttribute("useparent-unit", nil)
	self:SetAttribute("type", nil)
	self:SetAttribute("type1", nil)
	self:SetAttribute("type2", nil)
	self:SetAttribute("*action*", nil)
	self:SetAttribute("*macrotext*", nil)
	self:SetAttribute("*action1", nil)
	self:SetAttribute("*macrotext2", nil)

	self:UnregisterEvent("ITEM_LOCK_CHANGED")
	self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:UnregisterEvent("ACTIONBAR_SHOWGRID")
	self:UnregisterEvent("ACTIONBAR_HIDEGRID")
	self:UnregisterEvent("PET_BAR_SHOWGRID")
	self:UnregisterEvent("PET_BAR_HIDEGRID")
	self:UnregisterEvent("PET_BAR_UPDATE")
	self:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN")
	self:UnregisterEvent("UNIT_FLAGS")
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:UnregisterEvent("UPDATE_MACROS")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("EQUIPMENT_SETS_CHANGED")

	self:MACRO_Reset()
end

---This function is used to "fake" a state change in the button editor so you can see what each state will look like
function ACTIONBUTTON:SetFauxState(state)
	if (state) then

		local msg = (":"):split(state)

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
				self:SetAttribute("*self*", button:GetAttribute(msg.."-macro_Text"))

				if (self:GetAttribute("*macrotext*") and #self:GetAttribute("*macrotext*") > 0) or self:GetAttribute("isshown") then
					self:Show()
				elseif (not self:GetAttribute("showGrid")) then
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
end


--this will generate a spell macro
--spell: name of spell to use
--subname: subname of spell to use (optional)
--return: macro text
function ACTIONBUTTON:AutoWriteMacro(spell)

	local DB = Neuron.db.profile

	local modifier, modKey = " ", nil
	local bar = Neuron.CurrentBar or self.bar

	if (bar.data.mouseOverCast and DB.mouseOverMod ~= "NONE" ) then
		modKey = DB.mouseOverMod
		modifier = modifier.."[@mouseover,mod:"..modKey.."]"
	elseif (bar.data.mouseOverCast and DB.mouseOverMod == "NONE" ) then
		modifier = modifier.."[@mouseover,exists]"
	end

	if (bar.data.selfCast and GetModifiedClick("SELFCAST") ~= "NONE" ) then
		modKey = GetModifiedClick("SELFCAST")
		modifier = modifier.."[@player,mod:"..modKey.."]"
	end

	if (bar.data.focusCast and GetModifiedClick("FOCUSCAST") ~= "NONE" ) then
		modKey = GetModifiedClick("FOCUSCAST")
		modifier = modifier.."[@focus,exists,mod:"..modKey.."]"
	end

	if (bar.data.rightClickTarget) then
		modKey = ""
		modifier = modifier.."[@player"..modKey..",btn:2]"
	end

	if (modifier ~= " " ) then --(modKey) then
		modifier = modifier.."[] "
	end

	return "#autowrite\n/cast"..modifier..spell.."()"
end


--This will update the modifier value in a macro when a bar is set with a target conditional
--@spell:  this is hte macro text to be updated
--return: updated macro text
function ACTIONBUTTON:AutoUpdateMacro(macro)

	local DB = Neuron.db.profile

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



function ACTIONBUTTON:GetPosition(oFrame)
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


--callback(arg and arg, Group, SkinID, Gloss, Backdrop, Colors, Fonts)

function ACTIONBUTTON:SKINCallback(group,...)
	if (group) then
		for btn in pairs(Neuron.SKINIndex) do
			if (btn.bar and btn.bar.data.name == group) then
				btn:GetSkinned()
			end
		end
	end
end
