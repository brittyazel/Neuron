-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2023 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class StatusButton : Button @define class StatusButton inherits from class Button
local StatusButton = setmetatable({}, { __index = Neuron.Button })
Neuron.StatusButton = StatusButton

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

Neuron.BAR_TEXTURES = {
	[1] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Default_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Default_2", L["Default"] },
	[2] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Contrast_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Contrast_2", L["Contrast"] },
	[3] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Carpaint_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Carpaint_2", L["Carpaint"] },
	[4] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Gel_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Gel_2", L["Gel"] },
	[5] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Glassed_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Glassed_2", L["Glassed"] },
	[6] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Soft_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Soft_2", L["Soft"] },
	[7] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Velvet_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Velvet_3", L["Velvet"] },
}

Neuron.BAR_BORDERS = {
	[1] = { L["Tooltip"], "Interface\\Tooltips\\UI-Tooltip-Border", 2, 2, 3, 3, 12, 12, -2, 3, 2, -3 },
	[2] = { L["Slider"], "Interface\\Buttons\\UI-SliderBar-Border", 3, 3, 6, 6, 8, 8 , -1, 5, 1, -5 },
	[3] = { L["Dialog"], "Interface\\AddOns\\Neuron\\Images\\Border_Dialog", 11, 12, 12, 11, 26, 26, -7, 7, 7, -7 },
	[4] = { L["None"], "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}

Neuron.BAR_ORIENTATIONS = {
	[1] = "Horizontal",
	[2] = "Vertical",
}

---Constructor: Create a new Neuron Button object (this is the base object for all Neuron button types)
---@param bar Bar @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return StatusButton @ A newly created StatusButton object
function StatusButton.new(bar, buttonID, defaults, barObj, barType, objType)
	--call the parent object constructor with the provided information specific to this button type
	--local newButton = Neuron.Button.new(bar, buttonID, StatusButton, "StatusBar", "StatusBar", "NeuronStatusBarTemplate")
	local newButton = Neuron.Button.new(bar, buttonID, barObj, barType, objType, "NeuronStatusBarTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	return newButton
end

function StatusButton:InitializeButtonSettings()
	self:SetFrameStrata(Neuron.STRATAS[self.bar:GetStrata()-1])
	self:SetScale(self.bar:GetBarScale())

	self:SetWidth(self.config.width)
	self:SetHeight(self.config.height)

	self.StatusBar.CenterText:SetTextColor(self.config.cColor[1], self.config.cColor[2], self.config.cColor[3])
	self.StatusBar.LeftText:SetTextColor(self.config.lColor[1], self.config.lColor[2], self.config.lColor[3])
	self.StatusBar.RightText:SetTextColor(self.config.rColor[1], self.config.rColor[2], self.config.rColor[3])
	self.StatusBar.MouseoverText:SetTextColor(self.config.mColor[1], self.config.mColor[2], self.config.mColor[3])

	if not self.sbStrings[self.config.cIndex] then
		self.config.cIndex = 1
	end
	self.cFunc = self.sbStrings[self.config.cIndex][2]

	if not self.sbStrings[self.config.lIndex] then
		self.config.lIndex = 1
	end
	self.lFunc = self.sbStrings[self.config.lIndex][2]

	if not self.sbStrings[self.config.rIndex] then
		self.config.rIndex = 1
	end
	self.rFunc = self.sbStrings[self.config.rIndex][2]

	if not self.sbStrings[self.config.mIndex] then
		self.config.mIndex = 1
	end
	self.mFunc = self.sbStrings[self.config.mIndex][2]

	if not self.sbStrings[self.config.tIndex] then
		self.config.tIndex = 1
	end
	self.tFunc = self.sbStrings[self.config.tIndex][2]

	self.StatusBar.CenterText:SetText(self:cFunc())
	self.StatusBar.LeftText:SetText(self:lFunc())
	self.StatusBar.RightText:SetText(self:rFunc())
	self.StatusBar.MouseoverText:SetText(self:mFunc())

	self.orientation = self.config.orientation
	self.StatusBar:SetOrientation(Neuron.BAR_ORIENTATIONS[self.config.orientation]:lower())

	if self.config.orientation == 2 then
		self.StatusBar.CenterText:SetAlpha(0)
		self.StatusBar.LeftText:SetAlpha(0)
		self.StatusBar.RightText:SetAlpha(0)
		self.StatusBar.MouseoverText:SetAlpha(0)
	else
		self.StatusBar.CenterText:SetAlpha(1)
		self.StatusBar.LeftText:SetAlpha(1)
		self.StatusBar.RightText:SetAlpha(1)
		self.StatusBar.MouseoverText:SetAlpha(1)
	end

	if Neuron.BAR_TEXTURES[self.config.texture] then
		self.StatusBar:SetStatusBarTexture(Neuron.BAR_TEXTURES[self.config.texture][self.config.orientation])
	else
		self.StatusBar:SetStatusBarTexture(Neuron.BAR_TEXTURES[1][self.config.orientation])
	end

	self:SetBorder()
end

function StatusButton:SetBorder()
	self.StatusBar.Border:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = Neuron.BAR_BORDERS[self.config.border][2],
		tile = true,
		tileSize = Neuron.BAR_BORDERS[self.config.border][7],
		edgeSize = Neuron.BAR_BORDERS[self.config.border][8],
		insets = {
			left = Neuron.BAR_BORDERS[self.config.border][3],
			right = Neuron.BAR_BORDERS[self.config.border][4],
			top = Neuron.BAR_BORDERS[self.config.border][5],
			bottom = Neuron.BAR_BORDERS[self.config.border][6]
		}
	})

	self.StatusBar.Border:SetPoint("TOPLEFT", Neuron.BAR_BORDERS[self.config.border][9], Neuron.BAR_BORDERS[self.config.border][10])
	self.StatusBar.Border:SetPoint("BOTTOMRIGHT", Neuron.BAR_BORDERS[self.config.border][11], Neuron.BAR_BORDERS[self.config.border][12])

	self.StatusBar.Border:SetBackdropColor(0, 0, 0, 0)
	self.StatusBar.Border:SetBackdropBorderColor(self.config.borderColor[1], self.config.borderColor[2], self.config.borderColor[3], 1)

	self.StatusBar.Background:SetBackdropColor(0, 0, 0, 1)
	self.StatusBar.Background:SetBackdropBorderColor(0, 0, 0, 0)

	self.StatusBar.BarFlash:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = Neuron.BAR_BORDERS[self.config.border][2],
		tile = true,
		tileSize = Neuron.BAR_BORDERS[self.config.border][7],
		edgeSize = Neuron.BAR_BORDERS[self.config.border][8],
		insets = {
			left = Neuron.BAR_BORDERS[self.config.border][3],
			right = Neuron.BAR_BORDERS[self.config.border][4],
			top = Neuron.BAR_BORDERS[self.config.border][5],
			bottom = Neuron.BAR_BORDERS[self.config.border][6]
		}
	})
end

function StatusButton:OnEnter()
	if self.config.mIndex > 1 then
		self.StatusBar.CenterText:Hide()
		self.StatusBar.LeftText:Hide()
		self.StatusBar.RightText:Hide()
		self.StatusBar.MouseoverText:Show()
		self.StatusBar.MouseoverText:SetText(self:mFunc())
	end

	if self.config.tIndex > 1 then
		--if we are in combat and we don't have tooltips enable in-combat, don't go any further
		if InCombatLockdown() and not self.bar:GetTooltipCombat() then
			return
		end

		if self.bar:GetTooltipOption() ~= "off" then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self:tFunc() or "", self.tColor[1] or 1, self.tColor[2] or 1, self.tColor[3] or 1)
			GameTooltip:Show()
		end
	end
end

function StatusButton:OnLeave()
	if self.config.mIndex > 1 then
		self.StatusBar.CenterText:Show()
		self.StatusBar.LeftText:Show()
		self.StatusBar.RightText:Show()
		self.StatusBar.MouseoverText:Hide()
		self.StatusBar.CenterText:SetText(self:cFunc())
		self.StatusBar.LeftText:SetText(self:lFunc())
		self.StatusBar.RightText:SetText(self:rFunc())
	end

	if self.config.tIndex > 1 then
		GameTooltip:Hide()
	end
end

function StatusButton:UpdateWidth(command)
	local width = tonumber(command)
	if width and width >= 10 then
		self.config.width = width
		self:SetWidth(self.config.width)
		self.bar:SetObjectLoc()
		self.bar:SetPerimeter()
		self.bar:SetSize()
	end
end

function StatusButton:UpdateHeight(command)
	local height = tonumber(command)
	if height and height >= 4 then
		self.config.height = height
		self:SetHeight(self.config.height)
		self.bar:SetObjectLoc()
		self.bar:SetPerimeter()
		self.bar:SetSize()
	end
end

function StatusButton:UpdateBarFill(command)
	local index = tonumber(command)
	if index and Neuron.BAR_TEXTURES[index] then
		self.config.texture = index
		self.StatusBar:SetStatusBarTexture(Neuron.BAR_TEXTURES[self.config.texture][self.config.orientation])
	end
end

function StatusButton:UpdateBorder(command)
	local index = tonumber(command)
	if index and Neuron.BAR_BORDERS[index] then
		self.config.border = index
		self:SetBorder()
	end
end

function StatusButton:UpdateOrientation(command)
	local index = tonumber(command)
	if index then
		--only update if we're changing, not staying the same
		if self.config.orientation ~= index then
			self.config.orientation = index
			self.orientation = self.config.orientation
			self.StatusBar:SetOrientation(Neuron.BAR_ORIENTATIONS[self.config.orientation]:lower())

			if self.config.orientation == 2 then
				self.StatusBar.CenterText:SetAlpha(0)
				self.StatusBar.LeftText:SetAlpha(0)
				self.StatusBar.RightText:SetAlpha(0)
				self.StatusBar.MouseoverText:SetAlpha(0)
			else
				self.StatusBar.CenterText:SetAlpha(1)
				self.StatusBar.LeftText:SetAlpha(1)
				self.StatusBar.RightText:SetAlpha(1)
				self.StatusBar.MouseoverText:SetAlpha(1)
			end

			local newWidth = self.config.height
			local newHeight = self.config.width

			self.config.height = newHeight
			self.config.width = newWidth

			self:SetWidth(self.config.width)
			self:SetHeight(self.config.height)
			self.bar:SetObjectLoc()
			self.bar:SetPerimeter()
			self.bar:SetSize()
		end
	end
end

function StatusButton:UpdateCenterText(command)
	local index = tonumber(command)
	if index then
		self.config.cIndex = index
		self.cFunc = self.sbStrings[self.config.cIndex][2]
		self.StatusBar.CenterText:SetText(self:cFunc())
	end
end

function StatusButton:UpdateLeftText(command)
	local index = tonumber(command)
	if index then
		self.config.lIndex = index
		self.lFunc = self.sbStrings[self.config.lIndex][2]
		self.StatusBar.LeftText:SetText(self:lFunc())
	end
end

function StatusButton:UpdateRightText(command)
	if not self.sbStrings then
		return "---"
	end

	local index = tonumber(command)
	if index then
		self.config.rIndex = index
		self.rFunc = self.sbStrings[self.config.rIndex][2]
		self.StatusBar.RightText:SetText(self:rFunc())
	end
end

function StatusButton:UpdateMouseover(command)
	if not self.sbStrings then
		return "---"
	end

	local index = tonumber(command)
	if index then
		self.config.mIndex = index
		self.mFunc = self.sbStrings[self.config.mIndex][2]
		self.StatusBar.MouseoverText:SetText(self:mFunc())
	end
end


-----------------------------------------------------
--------------------- Overrides ---------------------
-----------------------------------------------------

--overwrite function in parent class Button
function StatusButton:UpdateVisibility()
	if Neuron.barEditMode or Neuron.buttonEditMode then
		self.StatusBar:Show()
		self.StatusBar:SetAlpha(1)
	end
end

--overwrite function in parent class Button
function StatusButton:UpdateStatus()
	if Neuron.barEditMode or Neuron.buttonEditMode then
		self.StatusBar.CenterText:SetText("")
		self.StatusBar.LeftText:SetText(self.typeString)
		self.StatusBar.RightText:SetText("")
		self.StatusBar.MouseoverText:SetText("")
	else
		self.StatusBar.CenterText:SetText(self:cFunc())
		self.StatusBar.LeftText:SetText(self:lFunc())
		self.StatusBar.RightText:SetText(self:rFunc())
		self.StatusBar.MouseoverText:SetText(self:mFunc())
	end
end

--overwrite function in parent class Button
function StatusButton:UpdateTooltip(command)
	if not self.sbStrings then
		return "---"
	end

	local index = tonumber(command)
	if index then
		self.config.tIndex = index
		self.tFunc = self.sbStrings[self.config.tIndex][2]
	end
end

--overwrite function in parent class Button
function StatusButton:UpdateIcon()
	-- empty --
end
--overwrite function in parent class Button
function StatusButton:UpdateUsable()
	-- empty --
end
--overwrite function in parent class Button
function StatusButton:UpdateCount()
	-- empty --
end
--overwrite function in parent class Button
function StatusButton:UpdateCooldown()
	-- empty --
end
