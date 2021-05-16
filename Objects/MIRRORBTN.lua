-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class MIRRORBTN : STATUSBTN @define class REPBTN inherits from class STATUSBTN
local MIRRORBTN = setmetatable({}, { __index = Neuron.STATUSBTN })
Neuron.MIRRORBTN = MIRRORBTN

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local mirrorWatch, mirrorBars = {}, {}

MIRRORBTN.sbStrings = {
	[1] = { L["None"], function(self) return "" end },
	[2] = { L["Type"], function(self) if mirrorWatch[self.mirror] then return mirrorWatch[self.mirror].label end end },
	[3] = { L["Timer"], function(self) if mirrorWatch[self.mirror] then return mirrorWatch[self.mirror].timer end end },
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

function MIRRORBTN:InitializeButton()
	self:RegisterEvent("MIRROR_TIMER_START", "OnEvent")
	self:RegisterEvent("MIRROR_TIMER_STOP", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")

	self:SetScript("OnUpdate", function() self:OnUpdate() end)

	table.insert(mirrorBars, self)
	self.StatusBar:Hide()
	self.typeString = L["Mirror Bar"]
	
	self:InitializeButtonSettings()
end

function MIRRORBTN:OnEvent(event, ...)
	if event == "MIRROR_TIMER_START" then
		self:Start(...)

	elseif event == "MIRROR_TIMER_STOP" then
		self:Stop(...)

	elseif event == "PLAYER_ENTERING_WORLD" then --this doesn't seem to be working as of 8.0, all report as UNKNOWN
		local type, value, maxvalue, scale, paused, label
		for i=1, MIRRORTIMER_NUMTIMERS do
			type, value, maxvalue, scale, paused, label = GetMirrorTimerInfo(i)
			if type ~= "UNKNOWN" then
				self:Start(type, value, maxvalue, scale, paused, label)
			end
		end
	end
end

function MIRRORBTN:Start(type, value, maxvalue, scale, paused, label)

	if not mirrorWatch[type] then
		mirrorWatch[type] = { active = false, mbar = nil, label = "", timer = "" }
	end

	if not mirrorWatch[type].active then
		local mbar = table.remove(mirrorBars, 1)

		if mbar then
			mirrorWatch[type].active = true
			mirrorWatch[type].mbar = mbar
			mirrorWatch[type].label = label

			mbar.mirror = type
			mbar.value = (value / 1000)
			mbar.maxvalue = (maxvalue / 1000)

			local color = MirrorTimerColors[type]

			mbar.StatusBar:SetMinMaxValues(0, (maxvalue / 1000))
			mbar.StatusBar:SetValue(mbar.value)
			mbar.StatusBar:SetStatusBarColor(color.r, color.g, color.b)

			mbar.StatusBar:SetAlpha(1)
			mbar.StatusBar:Show()
		end
	end
end

function MIRRORBTN:Stop(type)
	if mirrorWatch[type] and mirrorWatch[type].active then

		local mbar = mirrorWatch[type].mbar
		if mbar then
			table.insert(mirrorBars, 1, mbar)
			mirrorWatch[type].active = false
			mirrorWatch[type].mbar = nil
			mirrorWatch[type].label = ""
			mirrorWatch[type].timer = ""
			mbar.mirror = nil
		end
	end
end

function MIRRORBTN:OnUpdate()
	if self.mirror then
		self.value = GetMirrorTimerProgress(self.mirror)/1000

		if self.value > self.maxvalue then
			self.alpha = self.StatusBar:GetAlpha() - CASTING_BAR_ALPHA_STEP
			if self.alpha > 0 then
				self.StatusBar:SetAlpha(self.alpha)
			else
				self.StatusBar:Hide()
			end

		else
			self.StatusBar:SetValue(self.value)
			if self.value >= 60 then
				self.value = string.format("%0.1f", self.value/60)
				self.value = self.value.."m"
			else
				self.value = string.format("%0.0f", self.value)
				self.value = self.value.."s"
			end

			mirrorWatch[self.mirror].timer = self.value
		end

	elseif not Neuron.barEditMode and not Neuron.buttonEditMode then
		self.alpha = self.StatusBar:GetAlpha() - CASTING_BAR_ALPHA_STEP
		if self.alpha > 0 then
			self.StatusBar:SetAlpha(self.alpha)
		else
			self.StatusBar:Hide()
		end
	end

	if not Neuron.barEditMode and not Neuron.buttonEditMode then
		self.StatusBar.CenterText:SetText(self:cFunc())
		self.StatusBar.LeftText:SetText(self:lFunc())
		self.StatusBar.RightText:SetText(self:rFunc())
		self.StatusBar.MouseoverText:SetText(self:mFunc())
	end
end