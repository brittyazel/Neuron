-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

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
	self.Icon:SetDesaturated(false)
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
	self.Icon:SetTexture("Interface\\AddOns\\Neuron\\Images\\new_vehicle_exit")

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
		self.Icon:SetDesaturated(true);
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