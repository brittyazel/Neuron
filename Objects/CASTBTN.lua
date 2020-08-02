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

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class CASTBTN : STATUSBTN @define class CASTBTN inherits from class STATUSBTN
local CASTBTN = setmetatable({}, { __index = Neuron.STATUSBTN })
Neuron.CASTBTN = CASTBTN

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local castWatch = {}

CASTBTN.sbStrings = {
	[1] = { L["None"], function(self) return "" end },
	[2] = { L["Spell"], function(self) if castWatch[self:GetUnit()] then return castWatch[self:GetUnit()].spell end end },
	[3] = { L["Timer"], function(self) if castWatch[self:GetUnit()] then return castWatch[self:GetUnit()].timer end end },
}

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return CASTBTN @ A newly created STATUSBTN object
function CASTBTN.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.STATUSBTN.new(bar, buttonID, defaults, CASTBTN, "CastBar", "Cast Button")

	return newButton
end


function CASTBTN:InitializeButton()
	self:RegisterEvent("UNIT_SPELLCAST_START", "OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED", "OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_DELAYED", "OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", "OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "OnEvent")

	if not Neuron.isWoWClassic then
		self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "OnEvent")
		self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "OnEvent")
	end

	self.holdTime = 0

	self:SetScript("OnUpdate", function(self, elapsed) self:OnUpdate(elapsed) end)

	self.elements.SB:Hide()
	self.typeString = L["Cast Bar"]

	self:InitializeButtonSettings()
end

function CASTBTN:OnEvent(event,...)
	local unit = select(1, ...)
	local eventCastID = select(2,...) --return payload is "unitTarget", "castGUID", spellID

	if unit ~= self:GetUnit() then
		return
	end

	if not castWatch[unit] then
		castWatch[unit] = {}
	end

	if event == "UNIT_SPELLCAST_START" then
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible
		if not Neuron.isWoWClassic then
			name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
		else
			name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = CastingInfo() --classic doesn't have UnitCastingInfo()
		end

		if not name then
			self:Reset()
			return
		end

		self.elements.SB:SetStatusBarColor(self.config.castColor[1], self.config.castColor[2], self.config.castColor[3], self.config.castColor[4])

		self.elements.SB.spark:SetTexture("Interface\\AddOns\\Neuron\\Images\\CastingBar_Spark_"..self.orientation)
		self.elements.SB.spark:Show()


		self.value = (GetTime()-(startTime/1000))
		self.maxValue = (endTime-startTime)/1000
		self.elements.SB:SetMinMaxValues(0, self.maxValue)
		self.elements.SB:SetValue(self.value)

		self.elements.SB.totalTime = self.maxValue - self.elements.SB:GetValue()

		castWatch[unit].spell = text

		if self:GetShowIcon() then
			self.elements.SB.icon:SetTexture(texture)
			self.elements.SB.icon:Show()

			if notInterruptible then
				self.elements.SB.shield:Show()
			else
				self.elements.SB.shield:Hide()
			end
		else
			self.elements.SB.icon:Hide()
			self.elements.SB.shield:Hide()
		end

		self.elements.SB:SetAlpha(1.0)
		self.holdTime = 0
		self.casting = true
		self.castID = castID
		self.channeling = nil
		self.fadeout = nil

		self.elements.SB:Show()

	elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)

		if not name then
			self:Reset()
			return
		end

		self.elements.SB:SetStatusBarColor(self.config.channelColor[1], self.config.channelColor[2], self.config.channelColor[3], self.config.channelColor[4])

		self.value = ((endTime/1000)-GetTime())
		self.maxValue = (endTime - startTime) / 1000;
		self.elements.SB:SetMinMaxValues(0, self.maxValue);
		self.elements.SB:SetValue(self.value)

		castWatch[unit].spell = text

		if self:GetShowIcon() then

			self.elements.SB.icon:SetTexture(texture)
			self.elements.SB.icon:Show()

			if notInterruptible then
				self.elements.SB.shield:Show()
			else
				self.elements.SB.shield:Hide()
			end
		else
			self.elements.SB.icon:Hide()
			self.elements.SB.shield:Hide()
		end

		self.elements.SB.spark:Hide()
		
		self.elements.SB:SetAlpha(1.0)
		self.holdTime = 0
		self.casting = nil
		self.channeling = true
		self.fadeout = nil

		self.elements.SB:Show()

	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and not self.channeling then --don't do anything with this event when channeling as it fires at each pulse of a spell channel
		self.elements.SB:SetStatusBarColor(self.config.successColor[1], self.config.successColor[2], self.config.successColor[3], self.config.successColor[4])

	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and self.channeling then
		-- do nothing (when Tranquility is channeling if reports UNIT_SPELLCAST_SUCCEEDED many times during the duration)

	elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") and self.castID == eventCastID or event == "UNIT_SPELLCAST_CHANNEL_STOP"  then
		if self.elements.SB:IsShown() and (self.casting or self.channeling) and not self.fadeout then
			self.elements.SB:SetValue(self.maxValue)
			self.elements.SB:SetStatusBarColor(self.config.failColor[1], self.config.failColor[2], self.config.failColor[3], self.config.failColor[4])
			self.elements.SB.spark:Hide()

			if event == "UNIT_SPELLCAST_FAILED" then
				castWatch[unit].spell = FAILED
			elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
				-- empty --
			else
				castWatch[unit].spell = INTERRUPTED
			end

			self.casting = nil
			self.channeling = nil
			self.fadeout = true
			self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
		end

	elseif event == "UNIT_SPELLCAST_DELAYED" then
		if self.elements.SB:IsShown() then
			local name, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)
			if not name then
				self:Reset()
				return
			end

			self.value = (GetTime()-(startTime/1000))
			self.maxValue = (endTime-startTime)/1000
			self.elements.SB:SetMinMaxValues(0, self.maxValue)

			if not self.casting then
				self.elements.SB:SetStatusBarColor(self.config.castColor[1], self.config.castColor[2], self.config.castColor[3], self.config.castColor[4])
				self.elements.SB.spark:Show()
				self.elements.SB.barflash:SetAlpha(0.0)
				self.elements.SB.barflash:Hide()

				self.casting = true
				self.channeling = nil
				self.flash = nil
				self.fadeout = nil
			end
		end

	elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
		if self.elements.SB:IsShown() then
			local name, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit)
			if not name then
				self:Reset()
				return
			end
			self.value = ((endTime/1000)-GetTime())
			self.maxValue = (endTime-startTime)/1000
			self.elements.SB:SetMinMaxValues(0, self.maxValue)
			self.elements.SB:SetValue(self.value)
		end

	elseif self.elements.SB.showShield and event == "UNIT_SPELLCAST_INTERRUPTIBLE"  then
		self.elements.SB.shield:Hide()

	elseif self.elements.SB.showShield and event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"  then
		self.elements.SB.shield:Show()
	end

	if not Neuron.barEditMode and not Neuron.buttonEditMode then
		self.elements.SB.cText:SetText(self:cFunc())
		self.elements.SB.lText:SetText(self:lFunc())
		self.elements.SB.rText:SetText(self:rFunc())
		self.elements.SB.mText:SetText(self:mFunc())

	end
end

function CASTBTN:OnUpdate(elapsed)
	--bail out if these values don't exist. Otherwise we will error later on
	if not self.value and not self.maxValue then
		self:Reset()
		return
	end

	if self.maxValue then
		castWatch[self:GetUnit()].timer = string.format("%0.1f", self.value).."/"..format("%0.1f", self.maxValue)
	else
		castWatch[self:GetUnit()].timer = string.format("%0.1f", self.value)
	end

	if self.casting then
		self.value = self.value + elapsed
		if self.value >= self.maxValue then
			self.elements.SB:SetValue(self.maxValue)
			self:FinishCast()
			return
		end

		self.elements.SB:SetValue(self.value)
		self.elements.SB.barflash:Hide()

		if self.orientation == 1 then
			local sparkPosition = (self.value/self.maxValue)*self.elements.SB:GetWidth()
			if sparkPosition < 0 then
				sparkPosition = 0
			end
			self.elements.SB.spark:SetPoint("CENTER", self.elements.SB, "LEFT", sparkPosition, 0)
		else
			local sparkPosition = (self.value/self.maxValue) * self.elements.SB:GetHeight()
			if  sparkPosition < 0 then
				sparkPosition = 0
			end
			self.elements.SB.spark:SetPoint("CENTER", self.elements.SB, "BOTTOM", 0, sparkPosition)
		end

	elseif self.channeling then
		self.value = self.value - elapsed
		if self.value <= 0 then
			self:FinishCast()
			return
		end

		self.elements.SB:SetValue(self.value)
		self.elements.SB.barflash:Hide()

	elseif GetTime() < self.holdTime then
		return

	elseif self.flash then
		local alpha = self.elements.SB.barflash:GetAlpha() + CASTING_BAR_FLASH_STEP or 0
		if alpha < 1 then
			self.elements.SB.barflash:SetAlpha(alpha)
		else
			self.elements.SB.barflash:SetAlpha(1.0)
			self.flash = nil
		end

	elseif self.fadeout and (not Neuron.barEditMode and not Neuron.buttonEditMode) then
		local alpha = self.elements.SB:GetAlpha() - CASTING_BAR_ALPHA_STEP
		if alpha > 0 then
			self.elements.SB:SetAlpha(alpha)
		else
			self:Reset()
		end
	else
		self:Reset()
	end

	if not Neuron.barEditMode and not Neuron.buttonEditMode then
		self.elements.SB.cText:SetText(self:cFunc())
		self.elements.SB.lText:SetText(self:lFunc())
		self.elements.SB.rText:SetText(self:rFunc())
		self.elements.SB.mText:SetText(self:mFunc())
	end
end

function CASTBTN:FinishCast()
	self.elements.SB.spark:Hide()
	self.elements.SB.barflash:SetAlpha(1.0)
	self.elements.SB.barflash:Show()
	self.flash = true
	self.fadeout = true
	self.casting = nil
	self.channeling = nil
end

function CASTBTN:Reset()
	self.fadeout = true
	self.casting = nil
	self.channeling = nil
	self.elements.SB:SetStatusBarColor(self.config.castColor[1], self.config.castColor[2], self.config.castColor[3], self.config.castColor[4])

	if not Neuron.barEditMode and not Neuron.buttonEditMode then
		self.elements.SB:Hide()
	end
end

-----------------------------------------------------
-------------------Sets and Gets---------------------
-----------------------------------------------------

function CASTBTN:SetUnit(unit)
	--possible types are "player", "pet", "target", "targettarget", "focus", "mouseover", "party1", "party2", "party3", or "party4"
	if unit then
		self.config.unit = unit
	else
		unit = "player"
	end
end

function CASTBTN:GetUnit()
	return self.config.unit
end

function CASTBTN:SetShowIcon(show)
	self.config.showIcon = show
end

function CASTBTN:GetShowIcon()
	return self.config.showIcon
end