--Neuron, a World of Warcraft® user interface addon.

---@class BUTTON : CheckButton
local BUTTON = setmetatable({}, {__index = CreateFrame("CheckButton")}) --this is the metatable for our button object
Neuron.BUTTON = BUTTON




---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@param frameType string @ Type of frame to create
---@param frameTemplate @ Template used for our new frame
---@param objMetaTable  @ Metatable object to be assigned as the template for our new button
---@return BUTTON @ A newly created BUTTON object
function BUTTON:new(name, frameType, frameTemplate, objMetaTable)

	local object = CreateFrame(frameType, name, UIParent, frameTemplate)

	setmetatable(object, objMetaTable)

	return object
end

-------------------------------------------------
-----Base Methods that all buttons have----------
---These will often be overwritten per bar type--
------------------------------------------------

function BUTTON:SetData(bar)
	--empty--
end

function BUTTON:LoadData(spec,state)
	--empty--
end

function BUTTON:SetObjectVisibility(show)
	--empty--
end

function BUTTON:SetAux()
	--empty--
end

function BUTTON:LoadAux()
	--empty--
end

function BUTTON:SetDefaults(config, keys)
	--empty--
end

function BUTTON:GetDefaults()
	--empty--
end

function BUTTON:SetType(save, kill, init)
	--empty--
end

function BUTTON:SetSkinned(flyout)
	--empty--
end

function BUTTON:GetSkinned()
	--empty--
end




function BUTTON:MACRO_UpdateTimers(...)
	self:MACRO_UpdateCooldown()

	for k in pairs(Neuron.unitAuras) do
		self:MACRO_UpdateAuraWatch(k, self.macrospell)
	end
end


function BUTTON:MACRO_UpdateCooldown(update)
	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.actionID) then
		self:ACTION_SetCooldown(self.actionID)
	elseif (show and #show>0) then
		if (NeuronItemCache[show]) then
			self:MACRO_SetItemCooldown(show)
		else
			self:MACRO_SetSpellCooldown(show)
		end

	elseif (spell and #spell>0) then
		self:MACRO_SetSpellCooldown(spell)
	elseif (item and #item>0) then
		self:MACRO_SetItemCooldown(item)
	else
		Neuron:SetTimer(self.iconframecooldown, 0, 0, 0, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end


function BUTTON:MACRO_UpdateAuraWatch(unit, spell)

	local uaw_auraType, uaw_duration, uaw_timeLeft, uaw_count, uaw_color

	if (spell and (unit == self.unit or unit == "player")) then
		spell = spell:gsub("%s*%(.+%)", ""):lower()

		if (Neuron.unitAuras[unit][spell]) then
			uaw_auraType, uaw_duration, uaw_timeLeft, uaw_count = (":"):split(Neuron.unitAuras[unit][spell])

			uaw_duration = tonumber(uaw_duration)
			uaw_timeLeft = tonumber(uaw_timeLeft)

			if (self.auraInd) then
				self.auraBorder = true

				if (uaw_auraType == "buff") then
					self.border:SetVertexColor(self.buffcolor[1], self.buffcolor[2], self.buffcolor[3], 1.0)
				elseif (uaw_auraType == "debuff" and unit == "target") then
					self.border:SetVertexColor(self.debuffcolor[1], self.debuffcolor[2], self.debuffcolor[3], 1.0)
				end

				self.border:Show()
			else
				self.border:Hide()
			end

			uaw_color = self.auracolor1

			if (self.auraText) then

				if (uaw_auraType == "debuff" and (unit == "target" or (unit == "focus" and UnitIsEnemy("player", "focus")))) then
					uaw_color = self.auracolor2
				end

				self.iconframeaurawatch.queueinfo = unit..":"..spell
			else

			end

			if (self.iconframecooldown.timer:IsShown()) then
				self.auraQueue = unit..":"..spell
				self.iconframeaurawatch.uaw_duration = 0
				self.iconframeaurawatch:Hide()

			elseif (self.auraText) then
				Neuron:SetTimer(self.iconframecooldown, 0, 0, 0)
				Neuron:SetTimer(self.iconframeaurawatch, uaw_timeLeft-uaw_duration, uaw_duration, 1, self.auraText, uaw_color)
			else
				Neuron:SetTimer(self.iconframeaurawatch, 0, 0, 0)
			end

			self.auraWatchUnit = unit

		elseif (self.auraWatchUnit == unit) then

			self.iconframeaurawatch.uaw_duration = 0
			self.iconframeaurawatch:Hide()
			self.iconframeaurawatch.timer:SetText("")
			self.border:Hide()
			self.auraBorder = nil
			self.auraWatchUnit = nil
			self.auraTimer = nil
			self.auraQueue = nil
		end
	end
end


function BUTTON:ACTION_SetCooldown(action)

	local DB = Neuron.db.profile

	local actionID = tonumber(action)

	if (actionID) then

		if (HasAction(actionID)) then

			local start, duration, enable = GetActionCooldown(actionID)

			if (duration and duration >= DB.timerLimit and self.iconframeaurawatch.active) then
				self.auraQueue = self.iconframeaurawatch.queueinfo
				self.iconframeaurawatch.duration = 0
				self.iconframeaurawatch:Hide()
			end

			Neuron:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
		end
	end
end

