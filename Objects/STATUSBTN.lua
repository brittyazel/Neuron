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
--along with this add-on.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2020.

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class STATUSBTN : BUTTON @define class STATUSBTN inherits from class BUTTON
local STATUSBTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.STATUSBTN = STATUSBTN

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local BAR_TEXTURES = {
	[1] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Default_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Default_2", L["Default"] },
	[2] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Contrast_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Contrast_2", L["Contrast"] },
	[3] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Carpaint_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Carpaint_2", L["Carpaint"] },
	[4] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Gel_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Gel_2", L["Gel"] },
	[5] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Glassed_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Glassed_2", L["Glassed"] },
	[6] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Soft_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Soft_2", L["Soft"] },
	[7] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Velvet_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Velvet_3", L["Velvet"] },
}

local BAR_BORDERS = {
	[1] = { L["Tooltip"], "Interface\\Tooltips\\UI-Tooltip-Border", 2, 2, 3, 3, 12, 12, -2, 3, 2, -3 },
	[2] = { L["Slider"], "Interface\\Buttons\\UI-SliderBar-Border", 3, 3, 6, 6, 8, 8 , -1, 5, 1, -5 },
	[3] = { L["Dialog"], "Interface\\AddOns\\Neuron\\Images\\Border_Dialog", 11, 12, 12, 11, 26, 26, -7, 7, 7, -7 },
	[4] = { L["None"], "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}

local BAR_ORIENTATIONS = {
	[1] = "Horizontal",
	[2] = "Vertical",
}

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return STATUSBTN @ A newly created STATUSBTN object
function STATUSBTN.new(bar, buttonID, defaults, barObj, barType, objType)
	--call the parent object constructor with the provided information specific to this button type
	--local newButton = Neuron.BUTTON.new(bar, buttonID, STATUSBTN, "StatusBar", "StatusBar", "NeuronStatusBarTemplate")
	local newButton = Neuron.BUTTON.new(bar, buttonID, barObj, barType, objType, "NeuronStatusBarTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	newButton:EditorOverlay_CreateEditFrame()

	return newButton
end

function STATUSBTN:InitializeButtonSettings()
	self:SetFrameStrata(Neuron.STRATAS[self.bar:GetStrata()-1])
	self:SetScale(self.bar:GetBarScale())

	self:SetWidth(self.config.width)
	self:SetHeight(self.config.height)

	self.elements.SB.cText:SetTextColor(self.config.cColor[1], self.config.cColor[2], self.config.cColor[3], self.config.cColor[4])
	self.elements.SB.lText:SetTextColor(self.config.lColor[1], self.config.lColor[2], self.config.lColor[3], self.config.lColor[4])
	self.elements.SB.rText:SetTextColor(self.config.rColor[1], self.config.rColor[2], self.config.rColor[3], self.config.rColor[4])
	self.elements.SB.mText:SetTextColor(self.config.mColor[1], self.config.mColor[2], self.config.mColor[3], self.config.mColor[4])

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

	self.elements.SB.cText:SetText(self:cFunc())
	self.elements.SB.lText:SetText(self:lFunc())
	self.elements.SB.rText:SetText(self:rFunc())
	self.elements.SB.mText:SetText(self:mFunc())

	self.orientation = self.config.orientation
	self.elements.SB:SetOrientation(BAR_ORIENTATIONS[self.config.orientation]:lower())

	if self.config.orientation == 2 then
		self.elements.SB.cText:SetAlpha(0)
		self.elements.SB.lText:SetAlpha(0)
		self.elements.SB.rText:SetAlpha(0)
		self.elements.SB.mText:SetAlpha(0)
	else
		self.elements.SB.cText:SetAlpha(1)
		self.elements.SB.lText:SetAlpha(1)
		self.elements.SB.rText:SetAlpha(1)
		self.elements.SB.mText:SetAlpha(1)
	end

	if BAR_TEXTURES[self.config.texture] then
		self.elements.SB:SetStatusBarTexture(BAR_TEXTURES[self.config.texture][self.config.orientation])
	else
		self.elements.SB:SetStatusBarTexture(BAR_TEXTURES[1][self.config.orientation])
	end

	self:SetBorder()
end

function STATUSBTN:SetBorder()
	self.elements.SB.border:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = BAR_BORDERS[self.config.border][2],
		tile = true,
		tileSize = BAR_BORDERS[self.config.border][7],
		edgeSize = BAR_BORDERS[self.config.border][8],
		insets = {
			left = BAR_BORDERS[self.config.border][3],
			right = BAR_BORDERS[self.config.border][4],
			top = BAR_BORDERS[self.config.border][5],
			bottom = BAR_BORDERS[self.config.border][6]
		}
	})

	self.elements.SB.border:SetPoint("TOPLEFT", BAR_BORDERS[self.config.border][9], BAR_BORDERS[self.config.border][10])
	self.elements.SB.border:SetPoint("BOTTOMRIGHT", BAR_BORDERS[self.config.border][11], BAR_BORDERS[self.config.border][12])

	self.elements.SB.border:SetBackdropColor(0, 0, 0, 0)
	self.elements.SB.border:SetBackdropBorderColor(self.config.bordercolor[1], self.config.bordercolor[2], self.config.bordercolor[3], 1)

	self.elements.SB.bg:SetBackdropColor(0, 0, 0, 1)
	self.elements.SB.bg:SetBackdropBorderColor(0, 0, 0, 0)

	self.elements.SB.barflash:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = BAR_BORDERS[self.config.border][2],
		tile = true,
		tileSize = BAR_BORDERS[self.config.border][7],
		edgeSize = BAR_BORDERS[self.config.border][8],
		insets = {
			left = BAR_BORDERS[self.config.border][3],
			right = BAR_BORDERS[self.config.border][4],
			top = BAR_BORDERS[self.config.border][5],
			bottom = BAR_BORDERS[self.config.border][6]
		}
	})
end

function STATUSBTN:OnEnter()
	if self.config.mIndex > 1 then
		self.elements.SB.cText:Hide()
		self.elements.SB.lText:Hide()
		self.elements.SB.rText:Hide()
		self.elements.SB.mText:Show()
		self.elements.SB.mText:SetText(self:mFunc())
	end

	if self.config.tIndex > 1 then
		--if we are in combat and we don't have tooltips enable in-combat, don't go any further
		if InCombatLockdown() and not self.bar:GetTooltipCombat() then
			return
		end

		if self.bar:GetTooltipOption() ~= "off" then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self:tFunc() or "", self.tColor[1] or 1, self.tColor[2] or 1, self.tColor[3] or 1, self.tColor[4] or 1)
			GameTooltip:Show()
		end
	end
end

function STATUSBTN:OnLeave()
	if self.config.mIndex > 1 then
		self.elements.SB.cText:Show()
		self.elements.SB.lText:Show()
		self.elements.SB.rText:Show()
		self.elements.SB.mText:Hide()
		self.elements.SB.cText:SetText(self:cFunc())
		self.elements.SB.lText:SetText(self:lFunc())
		self.elements.SB.rText:SetText(self:rFunc())
	end

	if self.config.tIndex > 1 then
		GameTooltip:Hide()
	end
end

function STATUSBTN:UpdateWidth(command)
	local width = tonumber(command)
	if width and width >= 10 then
		self.config.width = width
		self:SetWidth(self.config.width)
		self.bar:SetObjectLoc()
		self.bar:SetPerimeter()
		self.bar:SetSize()
	end
end

function STATUSBTN:UpdateHeight(command)
	local height = tonumber(command)
	if height and height >= 4 then
		self.config.height = height
		self:SetHeight(self.config.height)
		self.bar:SetObjectLoc()
		self.bar:SetPerimeter()
		self.bar:SetSize()
	end
end

function STATUSBTN:UpdateBarFill(command)
	local index = tonumber(command)
	if index and BAR_TEXTURES[index] then
		self.config.texture = index
		self.elements.SB:SetStatusBarTexture(BAR_TEXTURES[self.config.texture][self.config.orientation])
	end
end

function STATUSBTN:UpdateBorder(command)
	local index = tonumber(command)
	if index and BAR_BORDERS[index] then
		self.config.border = index
		self:SetBorder()
	end
end

function STATUSBTN:UpdateOrientation(command)
	local index = tonumber(command)
	if index then
		--only update if we're changing, not staying the same
		if self.config.orientation ~= index then
			self.config.orientation = index
			self.orientation = self.config.orientation
			self.elements.SB:SetOrientation(BAR_ORIENTATIONS[self.config.orientation]:lower())

			if self.config.orientation == 2 then
				self.elements.SB.cText:SetAlpha(0)
				self.elements.SB.lText:SetAlpha(0)
				self.elements.SB.rText:SetAlpha(0)
				self.elements.SB.mText:SetAlpha(0)
			else
				self.elements.SB.cText:SetAlpha(1)
				self.elements.SB.lText:SetAlpha(1)
				self.elements.SB.rText:SetAlpha(1)
				self.elements.SB.mText:SetAlpha(1)
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

function STATUSBTN:UpdateCenterText(command)
	local index = tonumber(command)
	if index then
		self.config.cIndex = index
		self.cFunc = self.sbStrings[self.config.cIndex][2]
		self.elements.SB.cText:SetText(self:cFunc())
	end
end

function STATUSBTN:UpdateLeftText(command)
	local index = tonumber(command)
	if index then
		self.config.lIndex = index
		self.lFunc = self.sbStrings[self.config.lIndex][2]
		self.elements.SB.lText:SetText(self:lFunc())
	end
end

function STATUSBTN:UpdateRightText(command)
	if not self.sbStrings then
		return "---"
	end

	local index = tonumber(command)
	if index then
		self.config.rIndex = index
		self.rFunc = self.sbStrings[self.config.rIndex][2]
		self.elements.SB.rText:SetText(self:rFunc())
	end
end

function STATUSBTN:UpdateMouseover(command)
	if not self.sbStrings then
		return "---"
	end

	local index = tonumber(command)
	if index then
		self.config.mIndex = index
		self.mFunc = self.sbStrings[self.config.mIndex][2]
		self.elements.SB.mText:SetText(self:mFunc())
	end
end


-----------------------------------------------------
--------------------- Overrides ---------------------
-----------------------------------------------------

--overwrite function in parent class BUTTON
function STATUSBTN:UpdateVisibility()
	if Neuron.barEditMode or Neuron.buttonEditMode then
		self.elements.SB:Show()
		self.elements.SB:SetAlpha(1)
	end
end

--overwrite function in parent class BUTTON
function STATUSBTN:UpdateStatus()
	if Neuron.barEditMode or Neuron.buttonEditMode then
		self.elements.SB.cText:SetText("")
		self.elements.SB.lText:SetText(self.typeString)
		self.elements.SB.rText:SetText("")
		self.elements.SB.mText:SetText("")
	else
		self.elements.SB.cText:SetText(self:cFunc())
		self.elements.SB.lText:SetText(self:lFunc())
		self.elements.SB.rText:SetText(self:rFunc())
		self.elements.SB.mText:SetText(self:mFunc())
	end
end

--overwrite function in parent class BUTTON
function STATUSBTN:UpdateTooltip(command)
	if not self.sbStrings then
		return "---"
	end

	local index = tonumber(command)
	if index then
		self.config.tIndex = index
		self.tFunc = self.sbStrings[self.config.tIndex][2]
	end
end

--overwrite function in parent class BUTTON
function STATUSBTN:UpdateIcon()
	-- empty --
end
--overwrite function in parent class BUTTON
function STATUSBTN:UpdateUsable()
	-- empty --
end
--overwrite function in parent class BUTTON
function STATUSBTN:UpdateCount()
	-- empty --
end
--overwrite function in parent class BUTTON
function STATUSBTN:UpdateCooldown()
	-- empty --
end