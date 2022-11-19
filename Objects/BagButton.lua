-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class BagButton : Button @class BagButton inherits from class Button
local BagButton = setmetatable({}, {__index = Neuron.Button})
Neuron.BagButton = BagButton

Neuron.NUM_BAG_BUTTONS = 6

local blizzBagButtons = {
	--wow classic has a keyring button
	Neuron.isWoWRetail and CharacterReagentBag0Slot or KeyRingButton,
	CharacterBag3Slot,
	CharacterBag2Slot,
	CharacterBag1Slot,
	CharacterBag0Slot,
	MainMenuBarBackpackButton,
}

---------------------------------------------------------

---Constructor: Create a new Neuron Button object (this is the base object for all Neuron button types)
---@param bar Bar @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return BagButton @ A newly created BagButton object
function BagButton.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.Button.new(bar, buttonID, BagButton, "BagBar", "BagButton", "NeuronAnchorButtonTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	return newButton
end

--------------------------------------------------------

function BagButton:InitializeButton()
	if blizzBagButtons[self.id] then
		self.hookedButton = blizzBagButtons[self.id]
		self.hookedButton:ClearAllPoints()
		self.hookedButton:SetParent(self)
		self.hookedButton:Show()
		if not Neuron.isWoWRetail and self.id==1 then --the keyring button should be aligned to the right because it's only 1/3 the width of the other bag buttons
			self.hookedButton:SetPoint("RIGHT", self, "RIGHT")
		else
			self.hookedButton:SetPoint("CENTER", self, "CENTER")
		end
	end

	self:InitializeButtonSettings()
end

function BagButton:InitializeButtonSettings()
	self:SetFrameStrata(Neuron.STRATAS[self.bar:GetStrata()-1])
	self:SetScale(self.bar:GetBarScale())
	self:SetSkinned()
	self.isShown = true
end

---simplified SetSkinned for the Bag Buttons. They're unique in that they contain buttons inside of the buttons
--[[function BagButton:SetSkinned()
	local SKIN = LibStub("Masque", true)
	if SKIN then
		local btnData = {
			Normal = self.hookedButton:GetNormalTexture(),
			Icon = self.hookedButton.icon,
			Count = self.hookedButton.Count,
			Pushed = self.hookedButton:GetPushedTexture(),
			Disabled = self.hookedButton:GetDisabledTexture(),
			Checked = self.hookedButton.SlotHighlightTexture, --blizzard in 8.1.5 took away GetCheckedTexture from the bag buttons for ~some~ reason. This is now the explicit location the element we want
			Highlight = self.hookedButton:GetHighlightTexture(),
		}
		SKIN:Group("Neuron", self.bar.data.name):AddButton(self, btnData, "Item")
	end
end]]


-----------------------------------------------------
--------------------- Overrides ---------------------
-----------------------------------------------------

--overwrite function in parent class Button
function BagButton:UpdateStatus()
	-- empty --
end
--overwrite function in parent class Button
function BagButton:UpdateIcon()
	-- empty --
end
--overwrite function in parent class Button
function BagButton:UpdateUsable()
	-- empty --
end
--overwrite function in parent class Button
function BagButton:UpdateCount()
	-- empty --
end
--overwrite function in parent class Button
function BagButton:UpdateCooldown()
	-- empty --
end
--overwrite function in parent class Button
function BagButton:UpdateTooltip()
	-- empty --
end
