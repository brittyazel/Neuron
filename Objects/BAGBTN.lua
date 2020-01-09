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

---@class BAGBTN : BUTTON @class BAGBTN inherits from class BUTTON
local BAGBTN = setmetatable({}, {__index = Neuron.BUTTON})
Neuron.BAGBTN = BAGBTN

if Neuron.isWoWClassic then
	Neuron.NUM_BAG_BUTTONS = 6
else
	Neuron.NUM_BAG_BUTTONS = 5
end

local bagElements

if Neuron.isWoWClassic then
	bagElements = {
		KeyRingButton, --wow classic has a keyring button
		CharacterBag3Slot,
		CharacterBag2Slot,
		CharacterBag1Slot,
		CharacterBag0Slot,
		MainMenuBarBackpackButton}
else
	bagElements = {
		CharacterBag3Slot,
		CharacterBag2Slot,
		CharacterBag1Slot,
		CharacterBag0Slot,
		MainMenuBarBackpackButton}
end

---------------------------------------------------------

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return BAGBTN @ A newly created BAGBTN object
function BAGBTN.new(bar, buttonID, defaults)

	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.BUTTON.new(bar, buttonID, BAGBTN, "BagBar", "BagButton", "NeuronAnchorButtonTemplate")

	if (defaults) then
		newButton:SetDefaults(defaults)
	end

	return newButton
end


--------------------------------------------------------

function BAGBTN:SetType()

	if (bagElements[self.id]) then
		self.element = bagElements[self.id]
		self.element:ClearAllPoints()
		self.element:SetParent(self)
		self.element:Show()
		if Neuron.isWoWClassic and self.id==1 then --the keyring button should be aligned to the right because it's only 1/3 the width of the other bag buttons
			self.element:SetPoint("RIGHT", self, "RIGHT")
		else
			self.element:SetPoint("CENTER", self, "CENTER")
		end
	end

	self:SetSkinned()
end

function BAGBTN:SetData(bar)

	if (bar) then
		self.bar = bar
		self:SetFrameStrata(bar.data.objectStrata)
		self:SetScale(bar.data.scale)

		self.isShown = true
	end
end

---simplified SetSkinned for the Bag Buttons. They're unique in that they contain buttons inside of the buttons
function BAGBTN:SetSkinned()

	local SKIN = LibStub("Masque", true)

	if (SKIN) then

		local bar = self.bar

		if (bar) then
			local btnData = {
				Normal = self.element:GetNormalTexture(),
				Icon = self.element.icon,
				Count = self.element.Count,
				Pushed = self.element:GetPushedTexture(),
				Disabled = self.element:GetDisabledTexture(),
				Checked = self.element.SlotHighlightTexture, --blizzard in 8.1.5 took away GetCheckedTexture from the bag buttons for ~some~ reason. This is now the explicit location the element we want
				Highlight = self.element:GetHighlightTexture(),
			}

			SKIN:Group("Neuron", bar.data.name):AddButton(self, btnData, "Item")

			self.skinned = true
		end
	end
end