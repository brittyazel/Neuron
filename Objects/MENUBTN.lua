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

---@class MENUBTN : BUTTON @define class MENUBTN inherits from class BUTTON
local MENUBTN = setmetatable({}, {__index = Neuron.BUTTON})
Neuron.MENUBTN = MENUBTN

local blizzMenuButtons = {
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
	MainMenuMicroButton}

if Neuron.isWoWClassic then
	wipe(blizzMenuButtons)
	for i=1, #MICRO_BUTTONS do
		blizzMenuButtons[i] = _G[MICRO_BUTTONS[i]]
	end
end
---------------------------------------------------------

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return MENUBTN @ A newly created MENUBTN object
function MENUBTN.new(bar, buttonID, defaults)
	---call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.BUTTON.new(bar, buttonID, MENUBTN, "MenuBar", "MenuButton", "NeuronAnchorButtonTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	return newButton
end

---------------------------------------------------------

function MENUBTN:SetType()
	if not Neuron.isWoWClassic then
		if not self:IsEventRegistered("PET_BATTLE_CLOSE") and not Neuron.isWoWClassic then --only run this code on the first SetType, not the reloads after pet battles and such
			self:RegisterEvent("PET_BATTLE_CLOSE")
		end

		if not Neuron:IsHooked("MoveMicroButtons") then --we need to intercept MoveMicroButtons for during pet battles
			Neuron:RawHook("MoveMicroButtons", function(...) MENUBTN.ModifiedMoveMicroButtons(...) end, true)
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
end

function MENUBTN:SetData(bar)
	if bar then
		self.bar = bar
		self:SetFrameStrata(bar.data.objectStrata)
		self:SetScale(bar.data.scale)

		self.isShown = true
	end
end

function MENUBTN:PET_BATTLE_CLOSE()
	---we have to reload SetType to put the buttons back at the end of the pet battle
	self:SetType()
end

---this overwrites the default MoveMicroButtons and basically just extends it to reposition all the other buttons as well, not just the 1st and 6th.
---This is necessary for petbattles, otherwise there's no menubar
function MENUBTN.ModifiedMoveMicroButtons(anchor, anchorTo, relAnchor, x, y, isStacked)
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

function MENUBTN:UpdateUsable()
	--empty--
end