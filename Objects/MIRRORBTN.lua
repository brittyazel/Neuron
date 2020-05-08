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

---@class MIRRORBTN : STATUSBTN @define class REPBTN inherits from class STATUSBTN
local MIRRORBTN = setmetatable({}, { __index = Neuron.STATUSBTN })
Neuron.MIRRORBTN = MIRRORBTN

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local MirrorWatch, MirrorBars = {}, {}

MIRRORBTN.sbStrings = {
	[1] = { L["None"], function(sb) return "" end },
	[2] = { L["Type"], function(sb) if MirrorWatch[sb.mirror] then return MirrorWatch[sb.mirror].label end end },
	[3] = { L["Timer"], function(sb) if MirrorWatch[sb.mirror] then return MirrorWatch[sb.mirror].timer end end },
}

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return MIRRORBTN @ A newly created STATUSBTN object
function MIRRORBTN.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.STATUSBTN.new(bar, buttonID, defaults, MIRRORBTN, "MirrorBar", "Mirror Button")

	return newButton
end

function MIRRORBTN:SetType()
	if InCombatLockdown() then
		return
	end

	self:RegisterEvent("MIRROR_TIMER_START", "MirrorBar_OnEvent")
	self:RegisterEvent("MIRROR_TIMER_STOP", "MirrorBar_OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "MirrorBar_OnEvent")

	self:SetScript("OnUpdate", function() self:MirrorBar_OnUpdate() end)

	table.insert(MirrorBars, self)
	self.elements.SB:Hide()
	self.typeString = L["Mirror Bar"]
	self:SetData(self.bar)
end

function MIRRORBTN: MirrorBar_OnEvent(event, ...)
	if event == "MIRROR_TIMER_START" then
		self:mirrorbar_Start(...)

	elseif event == "MIRROR_TIMER_STOP" then
		self:mirrorbar_Stop(...)

	elseif event == "PLAYER_ENTERING_WORLD" then --this doesn't seem to be working as of 8.0, all report as UNKNOWN
		local type, value, maxvalue, scale, paused, label
		for i=1, MIRRORTIMER_NUMTIMERS do
			type, value, maxvalue, scale, paused, label = GetMirrorTimerInfo(i)
			if type ~= "UNKNOWN" then
				self:mirrorbar_Start(type, value, maxvalue, scale, paused, label)
			end
		end
	end
end

function MIRRORBTN:mirrorbar_Start(type, value, maxvalue, scale, paused, label)

	if not MirrorWatch[type] then
		MirrorWatch[type] = { active = false, mbar = nil, label = "", timer = "" }
	end

	if not MirrorWatch[type].active then
		local mbar = table.remove(MirrorBars, 1)

		if mbar then
			MirrorWatch[type].active = true
			MirrorWatch[type].mbar = mbar
			MirrorWatch[type].label = label

			mbar.elements.SB.mirror = type
			mbar.elements.SB.value = (value / 1000)
			mbar.elements.SB.maxvalue = (maxvalue / 1000)

			if  paused > 0 then
				mbar.elements.SB.paused = 1
			else
				mbar.elements.SB.paused = nil
			end

			local color = MirrorTimerColors[type]

			mbar.elements.SB:SetMinMaxValues(0, (maxvalue / 1000))
			mbar.elements.SB:SetValue(mbar.elements.SB.value)
			mbar.elements.SB:SetStatusBarColor(color.r, color.g, color.b)

			mbar.elements.SB:SetAlpha(1)
			mbar.elements.SB:Show()
		end
	end
end

function MIRRORBTN:mirrorbar_Stop(type)
	if MirrorWatch[type] and MirrorWatch[type].active then

		local mbar = MirrorWatch[type].mbar
		if mbar then
			table.insert(MirrorBars, 1, mbar)
			MirrorWatch[type].active = false
			MirrorWatch[type].mbar = nil
			MirrorWatch[type].label = ""
			MirrorWatch[type].timer = ""
			mbar.elements.SB.mirror = nil
		end
	end
end

function MIRRORBTN:MirrorBar_OnUpdate()
	if self.elements.SB.mirror then
		self.elements.SB.value = GetMirrorTimerProgress(self.elements.SB.mirror)/1000

		if self.elements.SB.value > self.elements.SB.maxvalue then
			self.elements.SB.alpha = self.elements.SB:GetAlpha() - CASTING_BAR_ALPHA_STEP
			if self.elements.SB.alpha > 0 then
				self.elements.SB:SetAlpha(self.elements.SB.alpha)
			else
				self.elements.SB:Hide()
			end

		else
			self.elements.SB:SetValue(self.elements.SB.value)
			if self.elements.SB.value >= 60 then
				self.elements.SB.value = string.format("%0.1f", self.elements.SB.value/60)
				self.elements.SB.value = self.elements.SB.value.."m"
			else
				self.elements.SB.value = string.format("%0.0f", self.elements.SB.value)
				self.elements.SB.value = self.elements.SB.value.."s"
			end

			MirrorWatch[self.elements.SB.mirror].timer = self.elements.SB.value
		end

	elseif not Neuron.barEditMode and not Neuron.buttonEditMode then
		self.elements.SB.alpha = self.elements.SB:GetAlpha() - CASTING_BAR_ALPHA_STEP
		if self.elements.SB.alpha > 0 then
			self.elements.SB:SetAlpha(self.elements.SB.alpha)
		else
			self.elements.SB:Hide()
		end
	end

	if not Neuron.barEditMode and not Neuron.buttonEditMode then
		self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
		self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))
		self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))
		self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))
	end
end