--Neuron, a World of Warcraft® user interface addon.

---@class EXITBTN : BUTTON @define class EXITBTN inherits from class BUTTON
local EXITBTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.EXITBTN = EXITBTN



local SKIN = LibStub("Masque", true)
local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")




---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return EXITBTN @ A newly created EXITBTN object
function EXITBTN:new(name)
	local object = CreateFrame("CheckButton", name, UIParent, "NeuronActionButtonTemplate")
	setmetatable(object, {__index = EXITBTN})
	return object
end



function EXITBTN:LoadData(spec, state)

	local DB = Neuron.db.profile

	local id = self.id

	if not DB.exitbtn[id] then
		DB.exitbtn[id] = {}
	end

	self.DB = DB.exitbtn[id]

	self.config = self.DB.config
	self.keys = self.DB.keys
	self.data = self.DB.data
end


function EXITBTN:SetObjectVisibility(show)

	if CanExitVehicle() or show then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat

		self:SetAlpha(1)
		self:SetExitButtonIcon()

	elseif not Neuron.ButtonEditMode and not Neuron.BarEditMode and not Neuron.BindingMode then
		self:SetAlpha(0)
	end

end

function EXITBTN:SetExitButtonIcon()

	local texture

	if UnitOnTaxi("player") then
		texture = Neuron.SpecialActions.taxi
	else
		texture = Neuron.SpecialActions.vehicle
	end

	self.iconframeicon:SetTexture(texture)
end

function EXITBTN:SetType(save)

	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	self:RegisterEvent("UPDATE_POSSESS_BAR");
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	self:RegisterEvent("VEHICLE_UPDATE")

	self:SetScript("OnEvent", function(self, event, ...) self:OnEvent(event, ...) end)
	self:SetScript("OnClick", function(self) self:OnClick() end)
	self:SetScript("OnEnter", function(self) self:OnEnter() end)
	self:SetScript("OnLeave", GameTooltip_Hide)

	local objects = Neuron:GetParentKeys(self)

	for k,v in pairs(objects) do
		local name = (v):gsub(self:GetName(), "")
		self[name:lower()] = _G[v]
	end

	self:SetExitButtonIcon()

	self:SetFrameLevel(4)
	self.iconframe:SetFrameLevel(2)
	self.iconframecooldown:SetFrameLevel(3)

	self:SetObjectVisibility()
end


function EXITBTN:OnEvent(event, ...)

	self:SetObjectVisibility()

end


function EXITBTN:OnEnter()
	if ( UnitOnTaxi("player") ) then

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:ClearLines()
		GameTooltip:SetText(TAXI_CANCEL, 1, 1, 1);
		GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
end

function EXITBTN:OnClick()
	if ( UnitOnTaxi("player") ) then
		TaxiRequestEarlyLanding();
	else
		VehicleExit();
	end
end