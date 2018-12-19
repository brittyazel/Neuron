--Neuron, a World of Warcraft® user interface addon.

---@class MENUBTN : BUTTON @define class MENUBTN inherits from class BUTTON
local MENUBTN = setmetatable({}, {__index = Neuron.BUTTON})
Neuron.MENUBTN = MENUBTN

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local menuElements = {
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
	MainMenuMicroButton
}


---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return MENUBTN @ A newly created MENUBTN object
function MENUBTN:new(name)
	local object = CreateFrame("CheckButton", name, UIParent, "NeuronAnchorButtonTemplate")
	setmetatable(object, {__index = MENUBTN})
	return object
end


function MENUBTN:SetSkinned()
	--empty--
end

function MENUBTN:SetAux()
	--empty--
end

function MENUBTN:SetData( bar)
	if (bar) then

		self.bar = bar

		self:SetFrameStrata(bar.data.objectStrata)
		self:SetScale(bar.data.scale)

	end

	self:SetFrameLevel(4)
end


function MENUBTN:SetType(reload)

	if not reload then --only run this code on the first SetType, not the reloads after pet battles and such
		self:RegisterEvent("PET_BATTLE_CLOSE")
		self:SetScript("OnEvent", function(self, event, ...) self:OnEvent(event, ...) end)

		if not Neuron:IsHooked("MoveMicroButtons") then --we need to intercept MoveMicroButtons for during pet battles
			Neuron:RawHook("MoveMicroButtons", function(...) MENUBTN.ModifiedMoveMicroButtons(...) end, true)
		end
	end

	if (menuElements[self.id]) then

		self:SetWidth(menuElements[self.id]:GetWidth()-2)
		self:SetHeight(menuElements[self.id]:GetHeight()-2)

		self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

		self.element = menuElements[self.id]

		local objects = Neuron:GetParentKeys(self.element)

		for k,v in pairs(objects) do
			local name = v:gsub(self.element:GetName(), "")
			self[name:lower()] = _G[v]
		end

		self.element:ClearAllPoints()
		self.element:SetParent(self)
		self.element:Show()
		self.element:SetPoint("CENTER", self, "CENTER")
		self.element:SetScale(1)
	end

end

function MENUBTN:OnEvent(event, ...)
	---we have to reload SetType to put the buttons back at the end of the pet battle
	self:SetType(true)
end


---this overwrites the default MoveMicroButtons and basically just extends it to reposition all the other buttons as well, not just the 1st and 6th.
---This is necessary for petbattles, otherwise there's no menubar
function MENUBTN.ModifiedMoveMicroButtons(anchor, anchorTo, relAnchor, x, y, isStacked)

	menuElements[1]:ClearAllPoints();
	menuElements[1]:SetPoint(anchor, anchorTo, relAnchor, x-5, y+4);

	for i=2,11 do

		menuElements[i]:ClearAllPoints();
		menuElements[i]:SetPoint("BOTTOMLEFT", menuElements[i-1], "BOTTOMRIGHT", -2,0)

		if isStacked and i == 6 then
			menuElements[6]:ClearAllPoints();
			menuElements[6]:SetPoint("TOPLEFT", menuElements[1], "BOTTOMLEFT", 0,2)
		end

	end

	MainMenuMicroButton_RepositionAlerts();
	UpdateMicroButtons();
end