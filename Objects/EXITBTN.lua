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
--along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2018.

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


function EXITBTN:SetObjectVisibility(show)

	if CanExitVehicle() or show then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		self:SetAlpha(1)
		self:SetExitButtonIcon()
	elseif not Neuron.buttonEditMode and not Neuron.barEditMode and not Neuron.bindingMode then
		self:SetAlpha(0)
	end

end

function EXITBTN:SetExitButtonIcon()

	local texture

	if UnitOnTaxi("player") then
		texture = Neuron.SPECIALACTIONS.taxi
	else
		texture = Neuron.SPECIALACTIONS.vehicle
	end

	self.iconframeicon:SetTexture(texture)
end

function EXITBTN:SetType(save)

	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "OnEvent")
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", "OnEvent")
	self:RegisterEvent("UPDATE_POSSESS_BAR", "OnEvent");
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", "OnEvent");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "OnEvent")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "OnEvent")
	self:RegisterEvent("VEHICLE_UPDATE", "OnEvent")

	self:SetScript("OnClick", function(self) self:OnClick() end)
	self:SetScript("OnEnter", function(self) self:OnEnter() end)
	self:SetScript("OnLeave", GameTooltip_Hide)

	local objects = Neuron:GetParentKeys(self)

	for k,v in pairs(objects) do
		local name = (v):gsub(self:GetName(), "")
		self[name:lower()] = _G[v]
	end

	self:SetExitButtonIcon()

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
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:ClearLines()
		GameTooltip:SetText(CANCEL);
		GameTooltip:Show();
	end
end

function EXITBTN:OnClick()
	if ( UnitOnTaxi("player") ) then
		TaxiRequestEarlyLanding()
	else
		VehicleExit()
	end
end