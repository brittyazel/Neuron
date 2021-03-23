-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)


--Neuron MinimapIcon makes use of LibDBIcon and LibDataBroker to make sure we play
--nicely with LDB addons and to simplify dramatically the minimap button

local DB

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

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
		OnClick = function(frame, button) Neuron:Minimap_OnClickHandler(frame, button) end,
		OnTooltipShow = function(tooltip) Neuron:Minimap_TooltipHandler(tooltip) end,
	})

	icon = LibStub("LibDBIcon-1.0")
	icon:Register("Neuron", neuronIconLDB, DB.NeuronIcon)

end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function Neuron:Minimap_OnClickHandler(frame, button)

	if InCombatLockdown() then
		return
	end

	PlaySound(SOUNDKIT.IG_CHAT_SCROLL_DOWN)

	if button == "LeftButton" then

		if IsShiftKeyDown() then
			Neuron:ToggleBindingMode(true)
		else
			Neuron:ToggleBarEditMode(true)
		end

	elseif button == "RightButton" then

		if IsShiftKeyDown() then
			Neuron:ToggleMainMenu()
		else
			Neuron:ToggleButtonEditMode(true)
		end

	end

end

function Neuron:Minimap_TooltipHandler(tooltip)

	tooltip:SetText("Neuron", 1, 1, 1)
	--the formatting for the following strings is such that the key combo is in yellow, and the description is in white. This helps it be more readable at a glance
	--another route would be to use AddDoubleLine, to have a left justified string and a right justified string on the same line
	tooltip:AddLine(L["Left-Click"] .. ":    " .. "|cFFFFFFFF"..L["Configure Bars"])
	tooltip:AddLine(L["Right-Click"] .. ":    " .. "|cFFFFFFFF"..L["Configure Buttons"])
	tooltip:AddLine(L["Shift"] .. " + " .. L["Left-Click"] .. ":    " .. "|cFFFFFFFF"..L["Toggle Keybind Mode"])
	tooltip:AddLine(L["Shift"] .. " + " .. L["Right-Click"] .. ":    " .. "|cFFFFFFFF"..L["Open the Interface Menu"])

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