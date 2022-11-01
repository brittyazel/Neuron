-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class BAGBTN : BUTTON @class BAGBTN inherits from class BUTTON
local BAGBTN = setmetatable({}, {__index = Neuron.BUTTON})
Neuron.BAGBTN = BAGBTN

if Neuron.isWoWClassicEra or Neuron.isWoWClassic then
	Neuron.NUM_BAG_BUTTONS = 6
else
	Neuron.NUM_BAG_BUTTONS = 6
end

local blizzBagButtons

if Neuron.isWoWClassicEra or Neuron.isWoWClassic then
	blizzBagButtons = {
		KeyRingButton, --wow classic has a keyring button
		CharacterBag3Slot,
		CharacterBag2Slot,
		CharacterBag1Slot,
		CharacterBag0Slot,
		MainMenuBarBackpackButton}
else
	blizzBagButtons = {
		CharacterReagentBag0Slot,
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

	if defaults then
		newButton:SetDefaults(defaults)
	end

	return newButton
end

--------------------------------------------------------

function BAGBTN:InitializeButton()
	if blizzBagButtons[self.id] then
		self.hookedButton = blizzBagButtons[self.id]
		self.hookedButton:ClearAllPoints()
		self.hookedButton:SetParent(self)
		self.hookedButton:Show()
		if (Neuron.isWoWClassicEra or Neuron.isWoWClassic) and self.id==1 then --the keyring button should be aligned to the right because it's only 1/3 the width of the other bag buttons
			self.hookedButton:SetPoint("RIGHT", self, "RIGHT")
		else
			self.hookedButton:SetPoint("CENTER", self, "CENTER")
		end
	end

	self:InitializeButtonSettings()
end

function BAGBTN:InitializeButtonSettings()
	self:SetFrameStrata(Neuron.STRATAS[self.bar:GetStrata()-1])
	self:SetScale(self.bar:GetBarScale())
	self:SetSkinned()
	self.isShown = true
end

---simplified SetSkinned for the Bag Buttons. They're unique in that they contain buttons inside of the buttons
--[[function BAGBTN:SetSkinned()
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

--overwrite function in parent class BUTTON
function BAGBTN:UpdateStatus()
	-- empty --
end
--overwrite function in parent class BUTTON
function BAGBTN:UpdateIcon()
	-- empty --
end
--overwrite function in parent class BUTTON
function BAGBTN:UpdateUsable()
	-- empty --
end
--overwrite function in parent class BUTTON
function BAGBTN:UpdateCount()
	-- empty --
end
--overwrite function in parent class BUTTON
function BAGBTN:UpdateCooldown()
	-- empty --
end
--overwrite function in parent class BUTTON
function BAGBTN:UpdateTooltip()
	-- empty --
end