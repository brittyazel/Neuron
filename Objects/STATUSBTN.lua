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
--copyrights for Neuron are held by Britt Yazel, 2017-2019.

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

	if (defaults) then
		newButton:SetDefaults(defaults)
	end

	return newButton
end




function STATUSBTN:SetBorder(statusbutton, config, bordercolor)

	statusbutton.border:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	                            edgeFile = BarBorders[config.border][2],
	                            tile = true,
	                            tileSize = BarBorders[config.border][7],
	                            edgeSize = BarBorders[config.border][8],
	                            insets = { left = BarBorders[config.border][3],
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

	if (statusbutton.barflash) then
		statusbutton.barflash:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		                              edgeFile = BarBorders[config.border][2],
		                              tile = true,
		                              tileSize = BarBorders[config.border][7],
		                              edgeSize = BarBorders[config.border][8],
		                              insets = { left = BarBorders[config.border][3],
		                                         right = BarBorders[config.border][4],
		                                         top = BarBorders[config.border][5],
		                                         bottom = BarBorders[config.border][6]
		                              }
		})
	end
end




function STATUSBTN:OnEnter()

	if (self.config.mIndex > 1) then
		self.sb.cText:Hide()
		self.sb.lText:Hide()
		self.sb.rText:Hide()
		self.sb.mText:Show()
		self.sb.mText:SetText(self.sb.mFunc(self.sb))
	end

	if (self.config.tIndex > 1) then
		if (not self.bar:GetTooltipCombat() and InCombatLockdown()) then
			return
		end

		if (self.bar:GetTooltipOption()) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.sb.tFunc(self.sb) or "", self.tColor[1] or 1, self.tColor[2] or 1, self.tColor[3] or 1, self.tColor[4] or 1)
			GameTooltip:Show()
		end
	end
end




function STATUSBTN:OnLeave()

	if (self.config.mIndex > 1) then
		self.sb.cText:Show()
		self.sb.lText:Show()
		self.sb.rText:Show()
		self.sb.mText:Hide()
		self.sb.cText:SetText(self.sb.cFunc(self.sb))
		self.sb.lText:SetText(self.sb.lFunc(self.sb))
		self.sb.rText:SetText(self.sb.rFunc(self.sb))
	end

	if (self.config.tIndex > 1) then
		GameTooltip:Hide()
	end
end




function STATUSBTN:UpdateWidth(command, gui, query, skipupdate)

	if (query) then
		return self.config.width
	end

	local width = tonumber(command)

	if (width and width >= 10) then

		self.config.width = width

		self:SetWidth(self.config.width)

		self.bar:SetObjectLoc()

		self.bar:SetPerimeter()

		self.bar:SetSize()

		if (not skipupdate) then
			self.bar:Update()
		end
	end
end




function STATUSBTN:UpdateHeight(command, gui, query, skipupdate)

	if (query) then
		return self.config.height
	end

	local height = tonumber(command)

	if (height and height >= 4) then

		self.config.height = height

		self:SetHeight(self.config.height)

		self.bar:SetObjectLoc()

		self.bar:SetPerimeter()

		self.bar:SetSize()

		if (not skipupdate) then
			self.bar:Update()
		end
	end
end




function STATUSBTN:UpdateBarFill(command, gui, query, skipupdate)

	if (query) then
		return BarTextures[self.config.texture][3]
	end

	local index = tonumber(command)

	if (index and BarTextures[index]) then

		self.config.texture = index

		self.sb:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.fbframe.feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])

	end

end




function STATUSBTN:UpdateBorder(command, gui, query, skipupdate)

	if (query) then
		return BarBorders[self.config.border][1]
	end

	local index = tonumber(command)

	if (index and BarBorders[index]) then

		self.config.border = index

		self:SetBorder(self.sb, self.config, self.bordercolor)
		self:SetBorder(self.fbframe.feedback, self.config, self.bordercolor)

	end
end




function STATUSBTN:UpdateOrientation(orientationIndex, gui, query, skipupdate)

	if (query) then
		return BarOrientations[self.config.orientation]
	end

	orientationIndex = tonumber(orientationIndex)

	if (orientationIndex) then

		--only update if we're changing, not staying the same
		if self.config.orientation ~= orientationIndex then

			self.config.orientation = orientationIndex
			self.sb.orientation = self.config.orientation

			self.sb:SetOrientation(BarOrientations[self.config.orientation]:lower())
			self.fbframe.feedback:SetOrientation(BarOrientations[self.config.orientation]:lower())

			if (self.config.orientation == 2) then
				self.sb.cText:SetAlpha(0)
				self.sb.lText:SetAlpha(0)
				self.sb.rText:SetAlpha(0)
				self.sb.mText:SetAlpha(0)
			else
				self.sb.cText:SetAlpha(1)
				self.sb.lText:SetAlpha(1)
				self.sb.rText:SetAlpha(1)
				self.sb.mText:SetAlpha(1)
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

			if (not skipupdate) then
				self.bar:Update()
			end

		end
	end
end




function STATUSBTN:UpdateCenterText(command, gui, query)

	if (query) then
		return self.sbStrings[self.config.cIndex][1]
	end

	local index = tonumber(command)

	if (index) then

		self.config.cIndex = index

		self.sb.cFunc = self.sbStrings[self.config.cIndex][2]

		self.sb.cText:SetText(self.sb.cFunc(self.sb))
	end
end




function STATUSBTN:UpdateLeftText(command, gui, query)

	if (query) then
		return self.sbStrings[self.config.lIndex][1]
	end

	local index = tonumber(command)

	if (index) then

		self.config.lIndex = index


		self.sb.lFunc = self.sbStrings[self.config.lIndex][2]


		self.sb.lText:SetText(self.sb.lFunc(self.sb))

	end
end




function STATUSBTN:UpdateRightText(command, gui, query)

	if (not self.sbStrings) then
		return "---"
	end

	if (query) then
		return self.sbStrings[self.config.rIndex][1]
	end

	local index = tonumber(command)

	if (index) then

		self.config.rIndex = index

		self.sb.rFunc = self.sbStrings[self.config.rIndex][2]

		self.sb.rText:SetText(self.sb.rFunc(self.sb))

	end
end




function STATUSBTN:UpdateMouseover(command, gui, query)

	if (not self.sbStrings) then
		return "---"
	end

	if (query) then
		return self.sbStrings[self.config.mIndex][1]
	end

	local index = tonumber(command)

	if (index) then

		self.config.mIndex = index

		self.sb.mFunc = self.sbStrings[self.config.mIndex][2]

		self.sb.mText:SetText(self.sb.mFunc(self.sb))
	end
end




function STATUSBTN:UpdateTooltip(command, gui, query)

	if (not self.sbStrings) then
		return "---"
	end

	if (query) then
		return self.sbStrings[self.config.tIndex][1]
	end

	local index = tonumber(command)

	if (index) then

		self.config.tIndex = index

		self.sb.tFunc = self.sbStrings[self.config.tIndex][2]

	end
end



function STATUSBTN:SetData(bar)

	self.bar = bar

	self:SetFrameStrata(Neuron.STRATAS[self.bar:GetStrata()-1])
	self:SetScale(self.bar:GetBarScale())


	self:SetWidth(self.config.width)
	self:SetHeight(self.config.height)

	self.sb.cText:SetTextColor(self.config.cColor[1], self.config.cColor[2], self.config.cColor[3], self.config.cColor[4])
	self.sb.lText:SetTextColor(self.config.lColor[1], self.config.lColor[2], self.config.lColor[3], self.config.lColor[4])
	self.sb.rText:SetTextColor(self.config.rColor[1], self.config.rColor[2], self.config.rColor[3], self.config.rColor[4])
	self.sb.mText:SetTextColor(self.config.mColor[1], self.config.mColor[2], self.config.mColor[3], self.config.mColor[4])


	if (not self.sbStrings[self.config.cIndex]) then
		self.config.cIndex = 1
	end
	self.sb.cFunc = self.sbStrings[self.config.cIndex][2]

	if (not self.sbStrings[self.config.lIndex]) then
		self.config.lIndex = 1
	end
	self.sb.lFunc = self.sbStrings[self.config.lIndex][2]

	if (not self.sbStrings[self.config.rIndex]) then
		self.config.rIndex = 1
	end
	self.sb.rFunc = self.sbStrings[self.config.rIndex][2]

	if (not self.sbStrings[self.config.mIndex]) then
		self.config.mIndex = 1
	end
	self.sb.mFunc = self.sbStrings[self.config.mIndex][2]

	if (not self.sbStrings[self.config.tIndex]) then
		self.config.tIndex = 1
	end
	self.sb.tFunc = self.sbStrings[self.config.tIndex][2]


	self.sb.cText:SetText(self.sb.cFunc(self.sb))
	self.sb.lText:SetText(self.sb.lFunc(self.sb))
	self.sb.rText:SetText(self.sb.rFunc(self.sb))
	self.sb.mText:SetText(self.sb.mFunc(self.sb))

	self.sb.orientation = self.config.orientation
	self.sb:SetOrientation(BarOrientations[self.config.orientation]:lower())
	self.fbframe.feedback:SetOrientation(BarOrientations[self.config.orientation]:lower())

	if (self.config.orientation == 2) then
		self.sb.cText:SetAlpha(0)
		self.sb.lText:SetAlpha(0)
		self.sb.rText:SetAlpha(0)
		self.sb.mText:SetAlpha(0)
	else
		self.sb.cText:SetAlpha(1)
		self.sb.lText:SetAlpha(1)
		self.sb.rText:SetAlpha(1)
		self.sb.mText:SetAlpha(1)
	end

	if (BarTextures[self.config.texture]) then
		self.sb:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.fbframe.feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
	else
		self.sb:SetStatusBarTexture(BarTextures[1][self.config.orientation])
		self.fbframe.feedback:SetStatusBarTexture(BarTextures[1][self.config.orientation])
	end

	self:SetBorder(self.sb, self.config, self.config.bordercolor)
	self:SetBorder(self.fbframe.feedback, self.config, self.config.bordercolor)

	self:SetFrameLevel(4)

	self.fbframe:SetFrameLevel(self:GetFrameLevel()+10)
	self.fbframe.feedback:SetFrameLevel(self.sb:GetFrameLevel()+10)
	self.fbframe.feedback.bg:SetFrameLevel(self.sb.bg:GetFrameLevel()+10)
	self.fbframe.feedback.border:SetFrameLevel(self.sb.border:GetFrameLevel()+10)

end



function STATUSBTN:SetObjectVisibility(show)

	if (show) then

		self.editmode = true

		self.fbframe:Show()

	else
		self.editmode = nil

		self.fbframe:Hide()
	end

end



function STATUSBTN:SetType()

 --empty--

end