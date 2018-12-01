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


function MENUBTN:LoadData(spec, state)

	local DB = Neuron.db.profile

	local id = self.id

	if not DB.menubtn[id] then
		DB.menubtn[id] = {}
	end

	self.DB = DB.menubtn[id]

	self.config = self.DB.config
	self.keys = self.DB.keys
	self.data = self.DB.data

end

function MENUBTN:SetType(save)
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