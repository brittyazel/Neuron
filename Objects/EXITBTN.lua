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

---@class EXITBTN : BUTTON @define class EXITBTN inherits from class BUTTON
local EXITBTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.EXITBTN = EXITBTN


----------------------------------------------------------

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return EXITBTN @ A newly created EXITBTN object
function EXITBTN.new(bar, buttonID, defaults)

	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.BUTTON.new(bar, buttonID, EXITBTN, "ExitBar", "VehicleExitButton", "NeuronActionButtonTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	return newButton
end


----------------------------------------------------------

function EXITBTN:SetType()
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "OnEvent")
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", "OnEvent")
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", "OnEvent");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "OnEvent")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "OnEvent")
	self:RegisterEvent("VEHICLE_UPDATE", "OnEvent")

	self:SetScript("OnClick", function(self) self:OnClick() end)
	self:SetScript("PostClick", function(self) self:UpdateStatus() end)
	self:SetScript("OnEnter", function(self) self:OnEnter() end)
	self:SetScript("OnLeave", GameTooltip_Hide)

	self:SetSkinned()
end


function EXITBTN:OnEvent(event, ...)
	--reset button back to normal in the case of setting a tint on prior taxi trip
	self.elements.IconFrameIcon:SetDesaturated(false)
	if not InCombatLockdown() then
		self:Enable()
	end

	self:UpdateIcon()
	self:UpdateObjectVisibility()
end


function EXITBTN:UpdateObjectVisibility(show)
	if CanExitVehicle() or UnitOnTaxi("player") or show then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		self.isShown = true
	else
		self.isShown = false
	end

	Neuron.BUTTON.UpdateObjectVisibility(self) --call parent function
end

---overwrite function in parent class BUTTON
function EXITBTN:UpdateIcon()
	self.elements.IconFrameIcon:SetTexture("Interface\\AddOns\\Neuron\\Images\\new_vehicle_exit")

	if not self:GetSkinned() then
		if self:HasAction() then
			self:SetNormalTexture(self.hasAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,1)
		else
			self:SetNormalTexture(self.noAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,0.5)
		end
	end
end


function EXITBTN:OnClick()
	if UnitOnTaxi("player") then
		TaxiRequestEarlyLanding()
		--desaturate the button if early landing is requested and disable it
		self.elements.IconFrameIcon:SetDesaturated(true);
		self:Disable()
	else
		VehicleExit()
	end
end


function EXITBTN:OnEnter()
	if not self.isShown then
		return
	end

	if UnitOnTaxi("player") then
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