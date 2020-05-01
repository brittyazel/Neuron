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

---@class STATUSBTN : BUTTON @define class STATUSBTN inherits from class BUTTON
local STATUSBTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.STATUSBTN = STATUSBTN


local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


local BarTextures = {
	[1] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Default_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Default_2", L["Default"] },
	[2] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Contrast_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Contrast_2", L["Contrast"] },
	[3] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Carpaint_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Carpaint_2", L["Carpaint"] },
	[4] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Gel_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Gel_2", L["Gel"] },
	[5] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Glassed_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Glassed_2", L["Glassed"] },
	[6] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Soft_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Soft_2", L["Soft"] },
	[7] = { "Interface\\AddOns\\Neuron\\Images\\BarFill_Velvet_1", "Interface\\AddOns\\Neuron\\Images\\BarFill_Velvet_3", L["Velvet"] },
}
Neuron.BarTextures = BarTextures


local BarBorders = {
	[1] = { L["Tooltip"], "Interface\\Tooltips\\UI-Tooltip-Border", 2, 2, 3, 3, 12, 12, -2, 3, 2, -3 },
	[2] = { L["Slider"], "Interface\\Buttons\\UI-SliderBar-Border", 3, 3, 6, 6, 8, 8 , -1, 5, 1, -5 },
	[3] = { L["Dialog"], "Interface\\AddOns\\Neuron\\Images\\Border_Dialog", 11, 12, 12, 11, 26, 26, -7, 7, 7, -7 },
	[4] = { L["None"], "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}
Neuron.BarBorders = BarBorders

local BarOrientations = {
	[1] = "Horizontal",
	[2] = "Vertical",
}
Neuron.BarOrientations = BarOrientations


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

	Neuron.BUTTON:EditorOverlay_CreateEditFrame(newButton)

	return newButton
end




function STATUSBTN:SetBorder(statusbutton, config, bordercolor)

	statusbutton.border:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = BarBorders[config.border][2],
		tile = true,
		tileSize = BarBorders[config.border][7],
		edgeSize = BarBorders[config.border][8],
		insets = {
			left = BarBorders[config.border][3],
			right = BarBorders[config.border][4],
			top = BarBorders[config.border][5],
			bottom = BarBorders[config.border][6]
		}
	})

	statusbutton.border:SetPoint("TOPLEFT", BarBorders[config.border][9], BarBorders[config.border][10])
	statusbutton.border:SetPoint("BOTTOMRIGHT", BarBorders[config.border][11], BarBorders[config.border][12])

	statusbutton.border:SetBackdropColor(0, 0, 0, 0)
	statusbutton.border:SetBackdropBorderColor(bordercolor[1], bordercolor[2], bordercolor[3], 1)
	statusbutton.border:SetFrameLevel(self:GetFrameLevel()+1)

	statusbutton.bg:SetBackdropColor(0, 0, 0, 1)
	statusbutton.bg:SetBackdropBorderColor(0, 0, 0, 0)
	statusbutton.bg:SetFrameLevel(0)

	if statusbutton.barflash then
		statusbutton.barflash:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = BarBorders[config.border][2],
			tile = true,
			tileSize = BarBorders[config.border][7],
			edgeSize = BarBorders[config.border][8],
			insets = {
				left = BarBorders[config.border][3],
				right = BarBorders[config.border][4],
				top = BarBorders[config.border][5],
				bottom = BarBorders[config.border][6]
			}
		})
	end
end




function STATUSBTN:OnEnter()

	if self.config.mIndex > 1 then
		self.elements.SB.cText:Hide()
		self.elements.SB.lText:Hide()
		self.elements.SB.rText:Hide()
		self.elements.SB.mText:Show()
		self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))
	end

	if self.config.tIndex > 1 then
		if not self.bar:GetTooltipCombat() and InCombatLockdown() then
			return
		end

		if self.bar:GetTooltipOption() then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.elements.SB.tFunc(self.elements.SB) or "", self.tColor[1] or 1, self.tColor[2] or 1, self.tColor[3] or 1, self.tColor[4] or 1)
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
		self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
		self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))
		self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))
	end

	if self.config.tIndex > 1 then
		GameTooltip:Hide()
	end
end




function STATUSBTN:UpdateWidth(command, gui, query, skipupdate)

	if query then
		return self.config.width
	end

	local width = tonumber(command)

	if width and width >= 10 then

		self.config.width = width

		self:SetWidth(self.config.width)

		self.bar:SetObjectLoc()

		self.bar:SetPerimeter()

		self.bar:SetSize()

		if not skipupdate then
			self.bar:UpdateBarStatus()
		end
	end
end




function STATUSBTN:UpdateHeight(command, gui, query, skipupdate)

	if query then
		return self.config.height
	end

	local height = tonumber(command)

	if height and height >= 4 then

		self.config.height = height

		self:SetHeight(self.config.height)

		self.bar:SetObjectLoc()

		self.bar:SetPerimeter()

		self.bar:SetSize()

		if not skipupdate then
			self.bar:UpdateBarStatus()
		end
	end
end




function STATUSBTN:UpdateBarFill(command, gui, query, skipupdate)

	if query then
		return BarTextures[self.config.texture][3]
	end

	local index = tonumber(command)

	if index and BarTextures[index] then

		self.config.texture = index

		self.elements.SB:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.elements.FBFrame.feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])

	end

end




function STATUSBTN:UpdateBorder(command, gui, query, skipupdate)

	if query then
		return BarBorders[self.config.border][1]
	end

	local index = tonumber(command)

	if index and BarBorders[index] then

		self.config.border = index

		self:SetBorder(self.elements.SB, self.config, self.bordercolor)
		self:SetBorder(self.elements.FBFrame.feedback, self.config, self.bordercolor)

	end
end




function STATUSBTN:UpdateOrientation(orientationIndex, gui, query, skipupdate)

	if query then
		return BarOrientations[self.config.orientation]
	end

	orientationIndex = tonumber(orientationIndex)

	if orientationIndex then

		--only update if we're changing, not staying the same
		if self.config.orientation ~= orientationIndex then

			self.config.orientation = orientationIndex
			self.elements.SB.orientation = self.config.orientation

			self.elements.SB:SetOrientation(BarOrientations[self.config.orientation]:lower())
			self.elements.FBFrame.feedback:SetOrientation(BarOrientations[self.config.orientation]:lower())

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

			if not skipupdate then
				self.bar:UpdateBarStatus()
			end

		end
	end
end




function STATUSBTN:UpdateCenterText(command, gui, query)

	if query then
		return self.sbStrings[self.config.cIndex][1]
	end

	local index = tonumber(command)

	if index then

		self.config.cIndex = index

		self.elements.SB.cFunc = self.sbStrings[self.config.cIndex][2]

		self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
	end
end




function STATUSBTN:UpdateLeftText(command, gui, query)

	if query then
		return self.sbStrings[self.config.lIndex][1]
	end

	local index = tonumber(command)

	if index then

		self.config.lIndex = index


		self.elements.SB.lFunc = self.sbStrings[self.config.lIndex][2]


		self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))

	end
end




function STATUSBTN:UpdateRightText(command, gui, query)

	if not self.sbStrings then
		return "---"
	end

	if query then
		return self.sbStrings[self.config.rIndex][1]
	end

	local index = tonumber(command)

	if index then

		self.config.rIndex = index

		self.elements.SB.rFunc = self.sbStrings[self.config.rIndex][2]

		self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))

	end
end




function STATUSBTN:UpdateMouseover(command, gui, query)

	if not self.sbStrings then
		return "---"
	end

	if query then
		return self.sbStrings[self.config.mIndex][1]
	end

	local index = tonumber(command)

	if index then

		self.config.mIndex = index

		self.elements.SB.mFunc = self.sbStrings[self.config.mIndex][2]

		self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))
	end
end




function STATUSBTN:UpdateTooltip(command, gui, query)

	if not self.sbStrings then
		return "---"
	end

	if query then
		return self.sbStrings[self.config.tIndex][1]
	end

	local index = tonumber(command)

	if index then

		self.config.tIndex = index

		self.elements.SB.tFunc = self.sbStrings[self.config.tIndex][2]

	end
end



function STATUSBTN:SetData(bar)

	self.bar = bar

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
	self.elements.SB.cFunc = self.sbStrings[self.config.cIndex][2]

	if not self.sbStrings[self.config.lIndex] then
		self.config.lIndex = 1
	end
	self.elements.SB.lFunc = self.sbStrings[self.config.lIndex][2]

	if not self.sbStrings[self.config.rIndex] then
		self.config.rIndex = 1
	end
	self.elements.SB.rFunc = self.sbStrings[self.config.rIndex][2]

	if not self.sbStrings[self.config.mIndex] then
		self.config.mIndex = 1
	end
	self.elements.SB.mFunc = self.sbStrings[self.config.mIndex][2]

	if not self.sbStrings[self.config.tIndex] then
		self.config.tIndex = 1
	end
	self.elements.SB.tFunc = self.sbStrings[self.config.tIndex][2]


	self.elements.SB.cText:SetText(self.elements.SB.cFunc(self.elements.SB))
	self.elements.SB.lText:SetText(self.elements.SB.lFunc(self.elements.SB))
	self.elements.SB.rText:SetText(self.elements.SB.rFunc(self.elements.SB))
	self.elements.SB.mText:SetText(self.elements.SB.mFunc(self.elements.SB))

	self.elements.SB.orientation = self.config.orientation
	self.elements.SB:SetOrientation(BarOrientations[self.config.orientation]:lower())
	self.elements.FBFrame.feedback:SetOrientation(BarOrientations[self.config.orientation]:lower())

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

	if BarTextures[self.config.texture] then
		self.elements.SB:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.elements.FBFrame.feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
	else
		self.elements.SB:SetStatusBarTexture(BarTextures[1][self.config.orientation])
		self.elements.FBFrame.feedback:SetStatusBarTexture(BarTextures[1][self.config.orientation])
	end

	self:SetBorder(self.elements.SB, self.config, self.config.bordercolor)
	self:SetBorder(self.elements.FBFrame.feedback, self.config, self.config.bordercolor)

	self:SetFrameLevel(4)

	self.elements.FBFrame:SetFrameLevel(self:GetFrameLevel()+10)
	self.elements.FBFrame.feedback:SetFrameLevel(self.elements.SB:GetFrameLevel()+10)
	self.elements.FBFrame.feedback.bg:SetFrameLevel(self.elements.SB.bg:GetFrameLevel()+10)
	self.elements.FBFrame.feedback.border:SetFrameLevel(self.elements.SB.border:GetFrameLevel()+10)

end



function STATUSBTN:UpdateObjectVisibility(show)
	if (show) then
		self.editmode = true
		self.elements.FBFrame:Show()
	else
		self.editmode = nil
		self.elements.FBFrame:Hide()
	end
end

--------------------------------------------------------------
---------------------- Overrides -----------------------------
--------------------------------------------------------------

--overrides the parent function so we don't error out
function STATUSBTN:UpdateUsable()
	-- empty --
end

--overrides the parent function so we don't error out
function STATUSBTN:UpdateIcon()
	-- empty --
end

--overrides the parent function so we don't error out
function STATUSBTN:UpdateStatus()
	-- empty --
end

--overrides the parent function so we don't error out
function STATUSBTN:UpdateCount()
	-- empty --
end

--overrides the parent function so we don't error out
function STATUSBTN:UpdateCooldown()
	-- empty --
end