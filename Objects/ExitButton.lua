-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@class ExitButton : Button @define class ExitButton inherits from class Button
local ExitButton = setmetatable({}, { __index = Neuron.Button })
Neuron.ExitButton = ExitButton


----------------------------------------------------------

---Constructor: Create a new Neuron Button object (this is the base object for all Neuron button types)
---@param bar Bar @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return ExitButton @ A newly created ExitButton object
function ExitButton.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.Button.new(bar, buttonID, ExitButton, "ExitBar", "VehicleExitButton", "NeuronActionButtonTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	return newButton
end

----------------------------------------------------------

function ExitButton:InitializeButton()
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "OnEvent")
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", "OnEvent")
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", "OnEvent");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "OnEvent")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "OnEvent")
	self:RegisterEvent("VEHICLE_UPDATE", "OnEvent")

	self:SetScript("OnClick", function() self:OnClick() end)
	self:SetScript("PostClick", function() self:UpdateStatus() end)
	self:SetScript("OnEnter", function() self:UpdateTooltip() end)
	self:SetScript("OnLeave", GameTooltip_Hide)

	self:InitializeButtonSettings()
end

function ExitButton:InitializeButtonSettings()
	self.bar:SetShowGrid(false)
	self:SetFrameStrata(Neuron.STRATAS[self.bar:GetStrata()-1])
	self:SetSkinned()
end

function ExitButton:OnEvent(event, ...)
	--reset button back to normal in the case of setting a tint on prior taxi trip
	self.Icon:SetDesaturated(false)
	if not InCombatLockdown() then
		self:Enable()
	end

	self:UpdateIcon()
	self:UpdateVisibility()
end

function ExitButton:OnClick()
	if UnitOnTaxi("player") then
		TaxiRequestEarlyLanding()
		--desaturate the button if early landing is requested and disable it
		self.Icon:SetDesaturated(true);
		self:Disable()
	else
		VehicleExit()
	end
end


-----------------------------------------------------
--------------------- Overrides ---------------------
-----------------------------------------------------

--overwrite function in parent class Button
function ExitButton:UpdateVisibility()
	if CanExitVehicle() or UnitOnTaxi("player") then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		self.isShown = true
	else
		self.isShown = false
	end

	Neuron.Button.UpdateVisibility(self) --call parent function
end

--overwrite function in parent class Button
function ExitButton:UpdateIcon()
	self.Icon:SetTexture("Interface\\AddOns\\Neuron\\Images\\new_vehicle_exit")
	--make sure our button gets the correct Normal texture if we're not using a Masque skin
	self:UpdateNormalTexture()
end

--overwrite function in parent class Button
function ExitButton:UpdateTooltip()
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