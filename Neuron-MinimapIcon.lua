-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

---@type EditMode
local EditMode = addonTable.controller.EditMode

--Neuron MinimapIcon makes use of LibDBIcon and LibDataBroker to make sure we play
--nicely with LDB addons and to simplify dramatically the minimap button

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local DB
local neuronIconLDB
local icon

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function Neuron:Minimap_IconInitialize()
	DB = Neuron.db.profile

	neuronIconLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Neuron", {
		type = "launcher",
		text = "Neuron",
		icon = "Interface\\AddOns\\Neuron\\Images\\static_icon",
		OnClick = function(_, button) Neuron:Minimap_OnClickHandler(button) end,
		OnTooltipShow = function(tooltip) Neuron:Minimap_TooltipHandler(tooltip) end,
	})

	icon = LibStub("LibDBIcon-1.0")
	icon:Register("Neuron", neuronIconLDB, DB.NeuronIcon)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function Neuron:Minimap_OnClickHandler(button)
	if InCombatLockdown() then
		return
	end

	PlaySound(SOUNDKIT.IG_CHAT_SCROLL_DOWN)

	if button == "LeftButton" and IsShiftKeyDown() then
		if not Neuron.bindingMode then
			Neuron:ToggleBindingMode(true)
		else
			Neuron:ToggleBindingMode(false)
		end
	elseif button == "LeftButton" and not IsShiftKeyDown() then
		Neuron.state = EditMode.enterBarMode(Neuron.state, false, false)
	elseif button == "RightButton" and IsShiftKeyDown() then
		if SettingsPanel and SettingsPanel:IsShown() then
			SettingsPanel:Hide()
		elseif InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown() then --this is for pre-dragonflight compatibility
			InterfaceOptionsFrame:Hide();
		else
			Neuron:ToggleMainMenu()
		end
	elseif button == "RightButton" and not IsShiftKeyDown() then
		if not Neuron.buttonEditMode then
			Neuron:ToggleButtonEditMode(true)
			if not addonTable.NeuronEditor then
				Neuron.NeuronGUI:CreateEditor("button")
			else
				Neuron.NeuronGUI:RefreshEditor("button")
			end
		else
			Neuron:ToggleButtonEditMode(false)
			if addonTable.NeuronEditor then
				Neuron.NeuronGUI:DestroyEditor()
			end
		end
	end
end

function Neuron:Minimap_TooltipHandler(tooltip)
	tooltip:SetText("Neuron", 1, 1, 1)
	--the formatting for the following strings is such that the key combo is in yellow, and the description is in white. This helps it be more readable at a glance
	--another route would be to use AddDoubleLine, to have a left justified string and a right justified string on the same line
	tooltip:AddLine(L["Left-Click"] .. ": " .. "|cFFFFFFFF"..L["Configure Bars"])
	tooltip:AddLine(L["Right-Click"] .. ": " .. "|cFFFFFFFF"..L["Configure Buttons"])
	tooltip:AddLine(L["Shift"] .. " + " .. L["Left-Click"] .. ": " .. "|cFFFFFFFF"..L["Toggle Keybind Mode"])
	tooltip:AddLine(L["Shift"] .. " + " .. L["Right-Click"] .. ": " .. "|cFFFFFFFF"..L["Open the Interface Menu"])

	tooltip:Show()
end

function Neuron:Minimap_ToggleIcon()
	if DB.NeuronIcon.hide == false then
		icon:Hide("Neuron")
		DB.NeuronIcon.hide = true
	elseif DB.NeuronIcon.hide == true then
		icon:Show("Neuron")
		DB.NeuronIcon.hide = false
	end
end
