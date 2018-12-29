--Neuron, a World of Warcraft® user interface addon.

---@class BUTTON : CheckButton @define BUTTON as inheriting from CheckButton
local BUTTON = setmetatable({}, {__index = CreateFrame("CheckButton")}) --this is the metatable for our button object
Neuron.BUTTON = BUTTON

local SKIN = LibStub("Masque", true)
local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

LibStub("AceBucket-3.0"):Embed(BUTTON)
LibStub("AceEvent-3.0"):Embed(BUTTON)


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

function BUTTON:SetTimer(start, duration, enable, timer, color1, color2, cdAlpha)

	local cdFrame = self.iconframecooldown


	if ( start and start > 0 and duration > 0 and enable > 0) then

		CooldownFrame_Set(cdFrame, start, duration, enable)

		cdFrame.timer:Show()

		if (duration >= Neuron.TIMERLIMIT) then
			cdFrame.duration = duration
			cdFrame.start = start

			if (timer) then
				cdFrame.normalcolor = color1
				cdFrame.expirecolor = color2
				Neuron.cooldowns[cdFrame] = true
			end

			if (cdAlpha) then
				Neuron.cdAlphas[cdFrame] = true
			end

		elseif (Neuron.cooldowns[cdFrame]) then
			cdFrame.duration = 1
		end

	else
		cdFrame.duration = 0
		cdFrame.start = 0
		cdFrame.timer:Hide()
	end
end


--this function runs in real time and is controlled from the OnUpdate function in Neuron.lua
function Neuron.Cooldowns_OnUpdate()

	local coolDown, formatted, size

	for cd in next, Neuron.cooldowns do

		coolDown = floor(cd.duration-(GetTime()-cd.start))

		if (coolDown < 1) then
			if (coolDown < 0) then
				Neuron.cooldowns[cd] = nil

				cd.timer:Hide()
				cd.timer:SetText("")
				cd.timerCD = nil
				cd.expirecolor = nil
				cd.cdsize = nil

			elseif (coolDown >= 0) then
				if (cd.alphafade) then
					cd:SetAlpha(cd.duration-(GetTime()-cd.start))
				end
			end

		elseif (cd.timer:IsShown() and coolDown ~= cd.timerCD) then
			if (coolDown >= 86400) then
				formatted = math.ceil(coolDown/86400)
				formatted = formatted.."d"
				size = cd.button:GetWidth()*0.3
				cd.timer:SetTextColor(cd.normalcolor[1], cd.normalcolor[2], cd.normalcolor[3])
			elseif (coolDown >= 3600) then
				formatted = math.ceil(coolDown/3600)
				formatted = formatted.."h"
				size = cd.button:GetWidth()*0.3
				cd.timer:SetTextColor(cd.normalcolor[1], cd.normalcolor[2], cd.normalcolor[3])
			elseif (coolDown >= 60) then
				formatted = math.ceil(coolDown/60)
				formatted = formatted.."m"
				size = cd.button:GetWidth()*0.3
				cd.timer:SetTextColor(cd.normalcolor[1], cd.normalcolor[2], cd.normalcolor[3])
			elseif (coolDown >=6) then
				formatted = coolDown
				size = cd.button:GetWidth()*0.45
				cd.timer:SetTextColor(cd.normalcolor[1], cd.normalcolor[2], cd.normalcolor[3])
			elseif (coolDown < 6) then
				formatted = coolDown
				size = cd.button:GetWidth()*0.6
				if (cd.expirecolor) then
					cd.timer:SetTextColor(cd.expirecolor[1], cd.expirecolor[2], cd.expirecolor[3]); cd.expirecolor = nil
				end
			end

			if (not cd.cdsize or cd.cdsize ~= size) then
				cd.timer:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
				cd.cdsize = size
			end

			cd.timerCD = coolDown
			cd.timer:Show()
			cd.timer:SetText(formatted)
		end
	end

	for cd in next, Neuron.cdAlphas do
		coolDown = ceil(cd.duration-(GetTime()-cd.start))

		if (coolDown < 1) then
			Neuron.cdAlphas[cd] = nil
			cd.button:SetAlpha(1)
			cd.alphaOn = nil

		elseif (not cd.alphaOn) then
			cd.button:SetAlpha(cd.button.cdAlpha)
			cd.alphaOn = true
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

		self.shine.shape = self.shape

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

	if (show and #show>0) then
		if (NeuronItemCache[show]) then
			self:SetItemCooldown(show)
		else
			self:SetSpellCooldown(show)
		end

	elseif (spell and #spell>0) then
		self:SetSpellCooldown(spell)
	elseif (item and #item>0) then
		self:SetItemCooldown(item)
	else
		self:SetTimer(0, 0, 0)
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
