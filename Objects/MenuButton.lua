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
	if Neuron.isWoWRetail then
		if not self:IsEventRegistered("PET_BATTLE_CLOSE") then --only run this code on the first InitializeButton, not the reloads after pet battles and such
			self:RegisterEvent("PET_BATTLE_CLOSE")
		end

		if not Neuron:IsHooked("MoveMicroButtons") then --we need to intercept MoveMicroButtons for during pet battles
			Neuron:RawHook("MoveMicroButtons", function(...) MenuButton.ModifiedMoveMicroButtons(...) end, true)
		end
	end

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

function MenuButton:PET_BATTLE_CLOSE()
	---we have to reload InitializeButton to put the buttons back at the end of the pet battle
	self:InitializeButton()
end

---this overwrites the default MoveMicroButtons and basically just extends it to reposition all the other buttons as well, not just the 1st and 6th.
---This is necessary for petbattles, otherwise there's no menubar
function MenuButton.ModifiedMoveMicroButtons(anchor, anchorTo, relAnchor, x, y, isStacked)
	blizzMenuButtons[1]:ClearAllPoints();
	blizzMenuButtons[1]:SetPoint(anchor, anchorTo, relAnchor, x-3, y-1);

	for i=2,#blizzMenuButtons do
		blizzMenuButtons[i]:ClearAllPoints();
		blizzMenuButtons[i]:SetPoint("BOTTOMLEFT", blizzMenuButtons[i-1], "BOTTOMRIGHT", -1,0)
		if isStacked and i == 7 then
			blizzMenuButtons[7]:ClearAllPoints();
			blizzMenuButtons[7]:SetPoint("TOPLEFT", blizzMenuButtons[1], "BOTTOMLEFT", 0,2)
		end
	end

	UpdateMicroButtons();
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
