--Neuron, a World of Warcraft® user interface addon.

--This file is part of Neuron.
--
--Neuron is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--Neuron is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2018.

---@class BUTTON : CheckButton @define BUTTON as inheriting from CheckButton
local BUTTON = setmetatable({}, {__index = CreateFrame("CheckButton")}) --this is the metatable for our button object
Neuron.BUTTON = BUTTON

local SKIN = LibStub("Masque", true)
local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

LibStub("AceBucket-3.0"):Embed(BUTTON)
LibStub("AceEvent-3.0"):Embed(BUTTON)
LibStub("AceTimer-3.0"):Embed(BUTTON)


---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return BUTTON @ A newly created BUTTON object
function BUTTON:new(name)
	--must be overwritten in extended classes!
end

-------------------------------------------------
-----Base Methods that all buttons have----------
---These will often be overwritten per bar type--
------------------------------------------------

function BUTTON:SetTimer(start, duration, enable, cooldownTimer, color1, color2, cooldownAlpha, charges)

	if ( start and start > 0 and duration > 0 and enable > 0) then

		CooldownFrame_Set(self.iconframecooldown, start, duration, enable) --set clock style cooldown animation

		self.iconframecooldown.timer:Show() --show the element that holds the cooldown animation

		if (duration >= Neuron.TIMERLIMIT) then --if spells have a cooldown less than 4sec then don't show a full cooldown

			if (cooldownTimer or cooldownAlpha) then --only set a timer if we explicitely want to (this saves CPU for a lot of people)

				--set a local variable to the boolean state of either Timer or the Alpha
				self.iconframecooldown.cooldownTimer = cooldownTimer
				self.iconframecooldown.cooldownAlpha = cooldownAlpha

				self.iconframecooldown.charges = charges --used to know if we should set alpha on the button (if cdAlpha is enabled) immediately, or if we need to wait for charges to run out

				--Get the remaining time left so when we re-call the timer when switching back to a state it has the correct time left instead of the full time
				local timeleft = duration-(GetTime()-start)
				--set timer that is both our cooldown counter, but also the cancles the repeating updating timer at the end
				self.iconframecooldown.spellTimer = self:ScheduleTimer(function() self:CancelTimer(self.iconframecooldown.countdownTimer) end, timeleft)

				--schedule a repeating timer that is physically keeping track of the countdown and switching the alpha and count text
				self.iconframecooldown.countdownTimer = self:ScheduleRepeatingTimer("CooldownCounterUpdate", 0.20)
				self.iconframecooldown.normalcolor = color1
				self.iconframecooldown.expirecolor = color2
			else
				self.iconframecooldown.cooldownTimer = false
				self.iconframecooldown.cooldownAlpha = false
			end

		else
			--Cancel Timers as they're unnecessary
			self:CancelTimer(self.iconframecooldown.countdownTimer)
			self.iconframecooldown.timer:SetText("")
			self.iconframecooldown.cooldownTimer = false
			self.iconframecooldown.cooldownAlpha = false
		end
	else
		--cleanup so on state changes the cooldowns don't persist
		self:CancelTimer(self.iconframecooldown.countdownTimer)
		CooldownFrame_Set(self.iconframecooldown, 0, 0, 0)
		self.iconframecooldown.timer:SetText("")
		self.iconframecooldown.timer:Hide()
		self.iconframecooldown.button:SetAlpha(1)
		self.iconframecooldown.cooldownTimer = false
		self.iconframecooldown.cooldownAlpha = false
	end
end


--this function runs in real time and is controlled from the OnUpdate function in Neuron.lua
function BUTTON:CooldownCounterUpdate()

	local coolDown, formatted, size

	local normalcolor = self.iconframecooldown.normalcolor
	local expirecolor = self.iconframecooldown.expirecolor

	coolDown = self:TimeLeft(self.iconframecooldown.spellTimer)

	if self.iconframecooldown.cooldownTimer then --check if flag is set, otherwise skip

		if (coolDown < 1) then
			if (coolDown <= 0) then
				self.iconframecooldown.timer:Hide()
				self.iconframecooldown.timer:SetText("")
				self.iconframecooldown.expirecolor = nil
				self.iconframecooldown.cdsize = nil

			elseif (coolDown > 0) then
				if (self.iconframecooldown.alphafade) then
					self.iconframecooldown:SetAlpha(coolDown)
				end
			end

		elseif (self.iconframecooldown.timer:IsShown()) then
			if (coolDown >= 86400) then
				formatted = string.format( "%.0f", coolDown/86400)
				formatted = formatted.."d"
				size = self.iconframecooldown.button:GetWidth()*0.3
				self.iconframecooldown.timer:SetTextColor(normalcolor[1], normalcolor[2], normalcolor[3])
			elseif (coolDown >= 3600) then
				formatted = string.format( "%.0f",coolDown/3600)
				formatted = formatted.."h"
				size = self.iconframecooldown.button:GetWidth()*0.3
				self.iconframecooldown.timer:SetTextColor(normalcolor[1], normalcolor[2], normalcolor[3])
			elseif (coolDown >= 60) then
				formatted = string.format( "%.0f",coolDown/60)
				formatted = formatted.."m"
				size = self.iconframecooldown.button:GetWidth()*0.3
				self.iconframecooldown.timer:SetTextColor(normalcolor[1], normalcolor[2], normalcolor[3])
			elseif (coolDown >=6) then
				formatted = string.format( "%.0f",coolDown)
				size = self.iconframecooldown.button:GetWidth()*0.45
				self.iconframecooldown.timer:SetTextColor(normalcolor[1], normalcolor[2], normalcolor[3])
			elseif (coolDown < 6) then
				formatted = string.format( "%.0f",coolDown)
				size = self.iconframecooldown.button:GetWidth()*0.6
				if (expirecolor) then
					self.iconframecooldown.timer:SetTextColor(expirecolor[1], expirecolor[2], expirecolor[3])
					expirecolor = nil
				end
			end

			if (not self.iconframecooldown.cdsize or self.iconframecooldown.cdsize ~= size) then
				self.iconframecooldown.timer:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
				self.iconframecooldown.cdsize = size
			end

			self.iconframecooldown.timer:Show()
			self.iconframecooldown.timer:SetText(formatted)

		end

	end

	if self.iconframecooldown.cooldownAlpha and (not self.iconframecooldown.charges or self.iconframecooldown.charges == 0) then --check if flag is set and if charges are nil or zero, otherwise skip

		if (coolDown > 0) then
			self.iconframecooldown.button:SetAlpha(self.iconframecooldown.button.cdAlpha)
		else
			self.iconframecooldown.button:SetAlpha(1)
		end
	end

end


function BUTTON:SetData(bar)
	if (bar) then

		self.bar = bar

		self.barLock = bar.data.barLock
		self.barLockAlt = bar.data.barLockAlt
		self.barLockCtrl = bar.data.barLockCtrl
		self.barLockShift = bar.data.barLockShift

		self.tooltips = bar.data.tooltips
		self.tooltipsEnhanced = bar.data.tooltipsEnhanced
		self.tooltipsCombat = bar.data.tooltipsCombat

		self.spellGlow = bar.data.spellGlow
		self.spellGlowDef = bar.data.spellGlowDef
		self.spellGlowAlt = bar.data.spellGlowAlt

		self.bindText = bar.data.bindText
		self.macroText = bar.data.macroText
		self.countText = bar.data.countText

		self.cdText = bar.data.cdText

		if (bar.data.cdAlpha) then
			self.cdAlpha = 0.2
		else
			self.cdAlpha = 1
		end

		self.auraText = bar.data.auraText
		self.auraInd = bar.data.auraInd

		self.rangeInd = bar.data.rangeInd

		self.upClicks = bar.data.upClicks
		self.downClicks = bar.data.downClicks

		self.showGrid = bar.data.showGrid
		self.multiSpec = bar.data.multiSpec

		self.bindColor = bar.data.bindColor
		self.macroColor = bar.data.macroColor
		self.countColor = bar.data.countColor

		self.macroname:SetText(self.data.macro_Name) --custom macro's weren't showing the name

		if (not self.cdcolor1) then
			self.cdcolor1 = { (";"):split(bar.data.cdcolor1) }
		else
			self.cdcolor1[1], self.cdcolor1[2], self.cdcolor1[3], self.cdcolor1[4] = (";"):split(bar.data.cdcolor1)
		end

		if (not self.cdcolor2) then
			self.cdcolor2 = { (";"):split(bar.data.cdcolor2) }
		else
			self.cdcolor2[1], self.cdcolor2[2], self.cdcolor2[3], self.cdcolor2[4] = (";"):split(bar.data.cdcolor2)
		end

		if (not self.auracolor1) then
			self.auracolor1 = { (";"):split(bar.data.auracolor1) }
		else
			self.auracolor1[1], self.auracolor1[2], self.auracolor1[3], self.auracolor1[4] = (";"):split(bar.data.auracolor1)
		end

		if (not self.auracolor2) then
			self.auracolor2 = { (";"):split(bar.data.auracolor2) }
		else
			self.auracolor2[1], self.auracolor2[2], self.auracolor2[3], self.auracolor2[4] = (";"):split(bar.data.auracolor2)
		end

		if (not self.buffcolor) then
			self.buffcolor = { (";"):split(bar.data.buffcolor) }
		else
			self.buffcolor[1], self.buffcolor[2], self.buffcolor[3], self.buffcolor[4] = (";"):split(bar.data.buffcolor)
		end

		if (not self.debuffcolor) then
			self.debuffcolor = { (";"):split(bar.data.debuffcolor) }
		else
			self.debuffcolor[1], self.debuffcolor[2], self.debuffcolor[3], self.debuffcolor[4] = (";"):split(bar.data.debuffcolor)
		end

		if (not self.rangecolor) then
			self.rangecolor = { (";"):split(bar.data.rangecolor) }
		else
			self.rangecolor[1], self.rangecolor[2], self.rangecolor[3], self.rangecolor[4] = (";"):split(bar.data.rangecolor)
		end

		self:SetFrameStrata(bar.data.objectStrata)

		self:SetScale(bar.data.scale)
	end

	if (self.bindText) then
		self.hotkey:Show()
		if (self.bindColor) then
			self.hotkey:SetTextColor((";"):split(self.bindColor))
		end
	else
		self.hotkey:Hide()
	end

	if (self.macroText) then
		self.macroname:Show()
		if (self.macroColor) then
			self.macroname:SetTextColor((";"):split(self.macroColor))
		end
	else
		self.macroname:Hide()
	end

	if (self.countText) then
		self.count:Show()
		if (self.countColor) then
			self.count:SetTextColor((";"):split(self.countColor))
		end
	else
		self.count:Hide()
	end

	local down, up = "", ""

	if (self.upClicks) then up = up.."AnyUp" end
	if (self.downClicks) then down = down.."AnyDown" end

	self:RegisterForClicks(down, up)
	self:RegisterForDrag("LeftButton", "RightButton")

	if (not self.equipcolor) then
		self.equipcolor = { 0.1, 1, 0.1, 1 }
	else
		self.equipcolor[1], self.equipcolor[2], self.equipcolor[3], self.equipcolor[4] = 0.1, 1, 0.1, 1
	end

	if (not self.manacolor) then
		self.manacolor = { 0.5, 0.5, 1.0, 1 }
	else
		self.manacolor[1], self.manacolor[2], self.manacolor[3], self.manacolor[4] = 0.5, 0.5, 1.0, 1
	end

	self:SetFrameLevel(4)
	self.iconframe:SetFrameLevel(2)
	self.iconframecooldown:SetFrameLevel(3)
	self.iconframeaurawatch:SetFrameLevel(3)

	self:GetSkinned()

	self:UpdateTimers()
end


--TODO: This should be consolodated as each child has a VERY similar function
function BUTTON:LoadData(spec, state)

	self.config = self.DB.config
	self.keys = self.DB.keys
	self.data = self.DB.data

end

function BUTTON:SetObjectVisibility(show)
	--empty--
end

function BUTTON:SetAux()
	self:SetSkinned()
end

function BUTTON:LoadAux()
	--empty--
end

function BUTTON:SetDefaults(defaults)
	if defaults then
		for k,v in pairs(defaults) do

			if defaults.config then
				for k2, v2 in pairs(defaults.config) do
					self.config[k2] = v2
				end
			end

			if defaults.keys then
				for k2, v2 in pairs(defaults.keys) do
					self.keys[k2] = v2
				end
			end

		end


	end
end

function BUTTON:SetType(save, kill, init)
	--empty--
end

function BUTTON:SetSkinned(flyout)

	if (SKIN) then

		local bar = self.bar

		if (bar) then
			local btnData = {
				Normal = self.normaltexture,
				Icon = self.iconframeicon,
				Cooldown = self.iconframecooldown,
				HotKey = self.hotkey,
				Count = self.count,
				Name = self.name,
				Border = self.border,
				AutoCast = false,
			}

			if (flyout) then
				SKIN:Group("Neuron", self.anchor.bar.data.name):AddButton(self, btnData)
			else
				SKIN:Group("Neuron", bar.data.name):AddButton(self, btnData)
			end

			self.skinned = true

			Neuron.SKINIndex[self] = true
		end
	end
end

function BUTTON:GetSkinned()
	if (self.__MSQ_NormalTexture) then
		local Skin = self.__MSQ_NormalSkin

		if (Skin) then
			self.hasAction = Skin.Texture or false
			self.noAction = Skin.EmptyTexture or false

			if (self.__MSQ_Shape) then
				self.shape = self.__MSQ_Shape:lower()
			else
				self.shape = "square"
			end
		else
			self.hasAction = false
			self.noAction = false
			self.shape = "square"
		end

		return true
	else
		self.hasAction = "Interface\\Buttons\\UI-Quickslot2"
		self.noAction = "Interface\\Buttons\\UI-Quickslot"

		return false
	end
end




function BUTTON:UpdateTimers(...)
	self:UpdateCooldown()

	for k in pairs(Neuron.unitAuras) do
		self:UpdateAuraWatch(k, self.macrospell)
	end
end


function BUTTON:UpdateCooldown(update)
	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.actionID) then
		self:ACTION_SetCooldown(self.actionID)
	elseif (show and #show>0) then
		if (NeuronItemCache[show]) then
			self:SetItemCooldown(show)
		else
			self:SetSpellCooldown(show)
		end

	elseif (spell and #spell>0) then
		self:SetSpellCooldown(spell)
	elseif (item and #item>0) then
		self:SetItemCooldown(item)
	end
end

function BUTTON:ACTION_SetCooldown(action)

	local actionID = tonumber(action)

	if (actionID) then

		if (HasAction(actionID)) then

			local start, duration, enable = GetActionCooldown(actionID)

			self:SetTimer(start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
		end
	end
end


function BUTTON:UpdateAuraWatch(unit, spell)

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

			--[[if (self.auraText) then
				self:SetTimer(uaw_timeLeft-uaw_duration, uaw_duration, 1, self.auraText, uaw_color, _, _,true)
			else
				self:SetTimer(0, 0, 0)
			end]]

			self.auraWatchUnit = unit

		elseif (self.auraWatchUnit == unit) then

			self.iconframeaurawatch.uaw_duration = 0
			self.iconframeaurawatch.timer:SetText("")
			self.border:Hide()
			self.auraBorder = nil
			self.auraWatchUnit = nil
			self.auraTimer = nil
			self.auraQueue = nil
		end
	end
end


function BUTTON:UpdateButton()
	--empty--
end
