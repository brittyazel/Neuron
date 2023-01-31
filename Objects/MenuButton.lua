-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron
local Array = addonTable.utilities.Array


---@class MenuButton : Button @define class MenuButton inherits from class Button
local MenuButton = setmetatable({}, {__index = Neuron.Button})
Neuron.MenuButton = MenuButton

local blizzMenuButtons = not Neuron.isWoWRetail
	and Array.initialize(#MICRO_BUTTONS, function(i) return _G[MICRO_BUTTONS[i]] end)
	or {
		CharacterMicroButton,
		SpellbookMicroButton,
		TalentMicroButton,
		AchievementMicroButton,
		QuestLogMicroButton,
		GuildMicroButton,
		LFDMicroButton,
		CollectionsMicroButton,
		EJMicroButton,
		StoreMicroButton,
		MainMenuMicroButton,
	}

---------------------------------------------------------

---Constructor: Create a new Neuron Button object (this is the base object for all Neuron button types)
---@param bar Bar @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return MenuButton @ A newly created MenuButton object
function MenuButton.new(bar, buttonID, defaults)
	---call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.Button.new(bar, buttonID, MenuButton, "MenuBar", "MenuButton", "NeuronAnchorButtonTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	return newButton
end

---------------------------------------------------------

function MenuButton:InitializeButton()
	--TODO: Pet battles and anything using the vehicle bar will be missing these menu buttons.

	if blizzMenuButtons[self.id] then
		self:SetWidth(blizzMenuButtons[self.id]:GetWidth()-2)
		self:SetHeight(blizzMenuButtons[self.id]:GetHeight()-2)

		self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

		self.hookedButton = blizzMenuButtons[self.id]

		self.hookedButton:ClearAllPoints()
		self.hookedButton:SetParent(self)
		self.hookedButton:Show()
		self.hookedButton:SetPoint("CENTER", self, "CENTER")
		self.hookedButton:SetScale(1)
	end

	self:InitializeButtonSettings()
end

function MenuButton:InitializeButtonSettings()
	self:SetFrameStrata(Neuron.STRATAS[self.bar:GetStrata()-1])
	self:SetScale(self.bar:GetBarScale())
	self.isShown = true
end

-----------------------------------------------------
--------------------- Overrides ---------------------
-----------------------------------------------------

--overwrite function in parent class Button
function MenuButton:UpdateStatus()
	-- empty --
end
--overwrite function in parent class Button
function MenuButton:UpdateIcon()
	-- empty --
end
--overwrite function in parent class Button
function MenuButton:UpdateUsable()
	-- empty --
end
--overwrite function in parent class Button
function MenuButton:UpdateCount()
	-- empty --
end
--overwrite function in parent class Button
function MenuButton:UpdateCooldown()
	-- empty --
end
--overwrite function in parent class Button
function MenuButton:UpdateTooltip()
	-- empty --
end
