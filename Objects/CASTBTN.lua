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

---@class CASTBTN : STATUSBTN @define class CASTBTN inherits from class STATUSBTN
local CASTBTN = setmetatable({}, { __index = Neuron.STATUSBTN })
Neuron.CASTBTN = CASTBTN


local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


local CastWatch = {}

CASTBTN.sbStrings = {
	[1] = { L["None"], function(sb) return "" end },
	[2] = { L["Spell"], function(sb) if (CastWatch[sb.unit]) then return CastWatch[sb.unit].spell end end },
	[3] = { L["Timer"], function(sb) if (CastWatch[sb.unit]) then return CastWatch[sb.unit].timer end end },
}


local BarUnits = {
	[1] = "-none-",
	[2] = "player",
	[3] = "pet",
	[4] = "target",
	[5] = "targettarget",
	[6] = "focus",
	[7] = "mouseover",
	[8] = "party1",
	[9] = "party2",
	[10] = "party3",
	[11] = "party4",
}
Neuron.BarUnits = BarUnits

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


function CASTBTN:SetType()

	if InCombatLockdown() then return end

	self:RegisterEvent("UNIT_SPELLCAST_START", "CastBar_OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "CastBar_OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_STOP", "CastBar_OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED", "CastBar_OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "CastBar_OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_DELAYED", "CastBar_OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", "CastBar_OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "CastBar_OnEvent")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "CastBar_OnEvent")

	if not Neuron.isWoWClassic then
		self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "CastBar_OnEvent")
		self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "CastBar_OnEvent")
	end

	self.sb.unit = BarUnits[self.config.unit]

	self.sb.showIcon = self.config.showIcon

	self.sb.casting = false
	self.sb.channeling = false
	self.sb.holdTime = 0

	self:SetScript("OnUpdate", function(self, elapsed) self:CastBar_OnUpdate(elapsed) end)

	if (not self.sb.cbtimer.castInfo) then
		self.sb.cbtimer.castInfo = {}
	else
		wipe(self.sb.cbtimer.castInfo)
	end

	self.sb:Hide()

	local typeString = L["Cast Bar"]

	self.fbframe.feedback.text:SetText(typeString)

	self:SetData(self.bar)

end


function CASTBTN:CastBar_FinishSpell()

	self.sb.spark:Hide()
	self.sb.barflash:SetAlpha(0.0)
	self.sb.barflash:Show()
	self.sb.flash = 1
	self.sb.fadeOut = 1
	self.sb.casting = false
	self.sb.channeling = false
end





function CASTBTN:CastBar_Reset()

	self.sb.fadeOut = 1
	self.sb.casting = false
	self.sb.channeling = false
	self.sb:SetStatusBarColor(self.config.castColor[1], self.config.castColor[2], self.config.castColor[3], self.config.castColor[4])

	if (not self.editmode) then
		self.sb:Hide()
	end
end





function CASTBTN:CastBar_OnEvent(event, unit, ...)

	if (unit ~= self.sb.unit) then
		return
	end

	if (not CastWatch[unit] ) then
		CastWatch[unit] = {}
	end

	if (event == "UNIT_SPELLCAST_START") then

		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible

		if not Neuron.isWoWClassic then
			name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
		else
			name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = CastingInfo() --classic doesn't have UnitCastingInfo()
		end

		if (not name) then
			self:CastBar_Reset()
			return
		end

		self.sb:SetStatusBarColor(self.config.castColor[1], self.config.castColor[2], self.config.castColor[3], self.config.castColor[4])

		if (self.sb.spark) then
			self.sb.spark:SetTexture("Interface\\AddOns\\Neuron\\Images\\CastingBar_Spark_"..self.sb.orientation)
			self.sb.spark:Show()
		end

		self.sb.value = (GetTime()-(startTime/1000))
		self.sb.maxValue = (endTime-startTime)/1000
		self.sb:SetMinMaxValues(0, self.sb.maxValue)
		self.sb:SetValue(self.sb.value)

		self.sb.totalTime = self.sb.maxValue - self.sb:GetValue()

		CastWatch[unit].spell = text

		if (self.sb.showIcon) then

			self.sb.icon:SetTexture(texture)
			self.sb.icon:Show()

			if (notInterruptible) then
				self.sb.shield:Show()
			else
				self.sb.shield:Hide()
			end

		else
			self.sb.icon:Hide()
			self.sb.shield:Hide()
		end

		self.sb:SetAlpha(1.0)
		self.sb.holdTime = 0
		self.sb.casting = true
		self.sb.castID = castID
		self.sb.channeling = false
		self.sb.fadeOut = nil

		self.sb:Show()

		--update castbar text
		if (not self.sb.cbtimer.castInfo[unit]) then
			self.sb.cbtimer.castInfo[unit] = {}
		end

		self.sb.cbtimer.castInfo[unit][1] = text
		self.sb.cbtimer.castInfo[unit][2] = "%0.1f"

	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and not self.sb.channeling) then

		self.sb:SetStatusBarColor(self.config.successColor[1], self.config.successColor[2], self.config.successColor[3], self.config.successColor[4])

	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and self.sb.channeling) then

		-- do nothing (when Tranquility is channeling if reports UNIT_SPELLCAST_SUCCEEDED many times during the duration)

	elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then

		if ((self.sb.casting and event == "UNIT_SPELLCAST_STOP") or
				(self.sb.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP")) then

			self.sb.spark:Hide()
			self.sb.barflash:SetAlpha(0.0)
			self.sb.barflash:Show()

			self.sb:SetValue(self.sb.maxValue)

			if (event == "UNIT_SPELLCAST_STOP") then
				self.sb.casting = false
			else
				self.sb.channeling = false
			end

			self.sb.flash = 1
			self.sb.fadeOut = 1
			self.sb.holdTime = 0
		end

	elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then

		if (self.sb:IsShown() and (self.sb.casting) and not self.sb.fadeOut) then

			self.sb:SetValue(self.sb.maxValue)

			self.sb:SetStatusBarColor(self.config.failColor[1], self.config.failColor[2], self.config.failColor[3], self.config.failColor[4])

			if (self.sb.spark) then
				self.sb.spark:Hide()
			end

			if (event == "UNIT_SPELLCAST_FAILED") then
				CastWatch[unit].spell = FAILED
			else
				CastWatch[unit].spell = INTERRUPTED
			end

			self.sb.casting = false
			self.sb.channeling = false
			self.sb.fadeOut = 1
			self.sb.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
		end

	elseif (event == "UNIT_SPELLCAST_DELAYED") then

		if (self.sb:IsShown()) then

			local name, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)

			if (not name) then
				self:CastBar_Reset()
				return
			end

			self.sb.value = (GetTime()-(startTime/1000))
			self.sb.maxValue = (endTime-startTime)/1000
			self.sb:SetMinMaxValues(0, self.sb.maxValue)

			if (not self.sb.casting) then

				self.sb:SetStatusBarColor(self.config.castColor[1], self.config.castColor[2], self.config.castColor[3], self.config.castColor[4])

				self.sb.spark:Show()
				self.sb.barflash:SetAlpha(0.0)
				self.sb.barflash:Hide()

				self.sb.casting = true
				self.sb.channeling = false
				self.sb.flash = 0
				self.sb.fadeOut = 0
			end
		end

	elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then

		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit)

		if (not name) then
			self:CastBar_Reset()
			return
		end

		self.sb:SetStatusBarColor(self.config.channelColor[1], self.config.channelColor[2], self.config.channelColor[3], self.config.channelColor[4])

		self.sb.value = ((endTime/1000)-GetTime())
		self.sb.maxValue = (endTime - startTime) / 1000;
		self.sb:SetMinMaxValues(0, self.sb.maxValue);
		self.sb:SetValue(self.sb.value)

		CastWatch[unit].spell = text

		if (self.sb.showIcon) then

			self.sb.icon:SetTexture(texture)
			self.sb.icon:Show()

			if (notInterruptible) then
				self.sb.shield:Show()
			else
				self.sb.shield:Hide()
			end

		else
			self.sb.icon:Hide()
			self.sb.shield:Hide()
		end

		if (self.sb.spark) then
			self.sb.spark:Hide()
		end

		self.sb:SetAlpha(1.0)
		self.sb.holdTime = 0
		self.sb.casting = false
		self.sb.channeling = true
		self.sb.fadeOut = nil

		self.sb:Show()

		--update text on castbar
		if (not self.sb.cbtimer.castInfo[unit]) then
			self.sb.cbtimer.castInfo[unit] = {}
		end

		self.sb.cbtimer.castInfo[unit][1] = text
		self.sb.cbtimer.castInfo[unit][2] = "%0.1f"

	elseif (event == "UNIT_SPELLCAST_CHANNEL_UPDATE") then

		if (self.sb:IsShown()) then

			local name, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit)

			if (not name) then
				self:CastBar_Reset()
				return
			end

			self.sb.value = ((endTime/1000)-GetTime())
			self.sb.maxValue = (endTime-startTime)/1000
			self.sb:SetMinMaxValues(0, self.sb.maxValue)
			self.sb:SetValue(self.sb.value)
		end

	elseif (self.sb.showShield and event == "UNIT_SPELLCAST_INTERRUPTIBLE" ) then

		self.sb.shield:Hide()

	elseif (self.sb.showShield and event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then

		self.sb.shield:Show()

	else
		self:CastBar_Reset()
	end

	self.sb.cText:SetText(self.sb.cFunc(self.sb))
	self.sb.lText:SetText(self.sb.lFunc(self.sb))
	self.sb.rText:SetText(self.sb.rFunc(self.sb))
	self.sb.mText:SetText(self.sb.mFunc(self.sb))

end





function CASTBTN:CastBar_OnUpdate(elapsed)

	local unit = self.sb.unit
	local sparkPosition, alpha

	if (unit) then

		if (self.sb.cbtimer.castInfo[unit]) then

			local displayName, numFormat = self.sb.cbtimer.castInfo[unit][1], self.sb.cbtimer.castInfo[unit][2]

			if (self.sb.maxValue) then
				CastWatch[self.sb.unit].timer = string.format(numFormat, self.sb.value).."/"..format(numFormat, self.sb.maxValue)
			else
				CastWatch[self.sb.unit].timer = string.format(numFormat, self.sb.value)
			end
		end

		if (self.sb.casting) then

			self.sb.value = self.sb.value + elapsed

			if (self.sb.value >= self.sb.maxValue) then
				self.sb:SetValue(self.sb.maxValue)
				self:CastBar_FinishSpell()
				return
			end

			self.sb:SetValue(self.sb.value)

			self.sb.barflash:Hide()

			if (self.sb.orientation == 1) then

				sparkPosition = (self.sb.value/self.sb.maxValue)*self.sb:GetWidth()

				if (sparkPosition < 0) then
					sparkPosition = 0
				end

				self.sb.spark:SetPoint("CENTER", self.sb, "LEFT", sparkPosition, 0)

			else
				sparkPosition = (self.sb.value / self.sb.maxValue) * self.sb:GetHeight()

				if ( sparkPosition < 0 ) then
					sparkPosition = 0
				end

				self.sb.spark:SetPoint("CENTER", self.sb, "BOTTOM", 0, sparkPosition)
			end

		elseif (self.sb.channeling) then

			self.sb.value = self.sb.value - elapsed

			if (self.sb.value <= 0) then
				self:CastBar_FinishSpell()
				return
			end

			self.sb:SetValue(self.sb.value)

			self.sb.barflash:Hide()

		elseif (GetTime() < self.sb.holdTime) then

			return

		elseif (self.sb.flash) then

			alpha = self.sb.barflash:GetAlpha() + CASTING_BAR_FLASH_STEP or 0

			if (alpha < 1) then
				self.sb.barflash:SetAlpha(alpha)
			else
				self.sb.barflash:SetAlpha(1.0)
				self.sb.flash = nil
			end

		elseif (self.sb.fadeOut and not self.sb.editmode) then

			alpha = self.sb:GetAlpha() - CASTING_BAR_ALPHA_STEP

			if (alpha > 0) then
				self.sb:SetAlpha(alpha)
			else
				self:CastBar_Reset()
			end
		end
	end

	self.sb.cText:SetText(self.sb.cFunc(self.sb))
	self.sb.lText:SetText(self.sb.lFunc(self.sb))
	self.sb.rText:SetText(self.sb.rFunc(self.sb))
	self.sb.mText:SetText(self.sb.mFunc(self.sb))
end

function CASTBTN:UpdateUnit(command, gui, query)

	if (query) then
		return BarUnits[self.config.unit]
	end

	local index = tonumber(command)

	if (index) then

		self.config.unit = index

		self.sb.unit = BarUnits[self.config.unit]

	end
end




function CASTBTN:UpdateCastIcon(frame, checked)

	if (checked) then
		self.config.showIcon = true
	else
		self.config.showIcon = false
	end

	self.sb.showIcon = self.config.showIcon

end