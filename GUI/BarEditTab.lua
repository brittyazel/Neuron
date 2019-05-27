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

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")


--[[local chkOptions = {
	[1] = { "AUTOHIDE", L["AutoHide"], 1, "SetAutoHide" },
	[2] = { "SHOWGRID", L["Show Grid"], 1, "SetShowGrid" },
	[3] = { "SNAPTO", L["SnapTo"], 1, "SetSnapTo" },
	[4] = { "UPCLICKS", L["Up Clicks"], 1, "SetUpClicks" },
	[5] = { "DOWNCLICKS", L["Down Clicks"], 1, "SetDownClicks" },
	[6] = { "MULTISPEC", L["Multi Spec"], 1, "SetMultiSpec" },
	[7] = { "HIDDEN", L["Hidden"], 1, "SetBarConceal" },
	[8] = { "SPELLGLOW", L["Spell Alerts"], 1, "SetSpellGlow" },
	[9] = { "LOCKBAR", L["Lock Actions"], 1, "SetBarLock" },
	[10] = { "LOCKBAR", L["Unlock on SHIFT"], 0.9, "SetBarLock", "shift" },
	[1] = { "LOCKBAR", L["Unlock on CTRL"], 0.9, "SetBarLock", "ctrl" },
	[12] = { "LOCKBAR", L["Unlock on ALT"], 0.9, "SetBarLock", "alt" },
	[13] = { "TOOLTIPS", L["Enable Tooltips"], 1, "SetTooltipEnable" },
	[14] = { "TOOLTIPS", L["Enhanced"], 0.9, "SetTooltipEnhanced" },
	[15] = { "TOOLTIPS", L["Hide in Combat"], 0.9, "SetTooltipCombat" },
	[16] = { "BORDERSTYLE", L["Show Border Style"], 1, "SetShowBorderStyle"},
}

local adjOptions = {
	[1] = { "SCALE", L["Scale"], 1, "SetScale", 0.01, 0.1, 4 },
	[2] = { "SHAPE", L["Shape"], 2, "SetBarShape", nil, nil, nil, Neuron.BarShapes },
	[3] = { "COLUMNS", L["Columns"], 1, "SetColumns", 1 , 0},
	[4] = { "ARCSTART", L["Arc Start"], 1, "SetArcStart", 1, 0, 359 },
	[5] = { "ARCLENGTH", L["Arc Length"], 1, "SetArcLength", 1, 0, 359 },
	[6] = { "HPAD",L["Horiz Padding"], 1, "SetHorizontalPad", 0.5 },
	[7] = { "VPAD", L["Vert Padding"], 1, "SetVerticalPad", 0.5 },
	[9] = { "STRATA", L["Strata"], 2, "SetStrata", nil, nil, nil, Neuron.STRATAS },
	[10] = { "ALPHA", L["Alpha"], 1, "SetBarAlpha", 0.01, 0, 1 },
	[11] = { "ALPHAUP", L["AlphaUp"], 2, "SetAlphaUp", nil, nil, nil, Neuron.AlphaUps },
	[12] = { "ALPHAUP", L["AlphaUp Speed"], 1, "SetAlphaUpSpeed", 0.01, 0.01, 1, nil, "%0.0f", 100, "%" },
	[13] = { "XPOS", L["X Position"], 1, "SetXAxis", 1, nil, nil, nil, "%0.2f", 1, "" },
	[14] = { "YPOS", L["Y Position"], 1, "SetYAxis", 1, nil, nil, nil, "%0.2f", 1, "" },
}

local swatchOptions = {
	[1] = { "BINDTEXT", L["Keybind Label"], 1, "SetShowBindText", true, nil, "bindColor" },
	[2] = { "MACROTEXT", L["Macro Name"], 1, "SetShowMacroText", true, nil, "macroColor" },
	[3] = { "COUNTTEXT", L["Stack/Charge Count Label"], 1, "SetShowCountText", true, nil, "countColor" },
	[4] = { "RANGEIND", L["Out-of-Range Indicator"], 1, "SetShowRangeIndicator", true, nil, "rangecolor" },
	[5] = { "CDTEXT", L["Cooldown Countdown"], 1, "SetShowCooldownText", true, true, "cdcolor1", "cdcolor2" },
	[6] = { "CDALPHA", L["Cooldown Transparency"], 1, "SetShowCooldownAlpha", nil, nil },
	[7] = { "AURAIND", L["Buff/Debuff Aura Border"], 1, "SetShowAuraIndicator", true, true, "buffcolor", "debuffcolor" },
}]]

local currentTab = "tab1" --remember which tab we were using between refreshes

-----------------------------------------------------------------------------
--------------------------Bar Editor-----------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:BarEditPanel(tabFrame)

	--Tab group that will contain all of our settings to configure
	local innerTabFrame = AceGUI:Create("TabGroup")
	innerTabFrame:SetLayout("Flow")
	innerTabFrame:SetFullWidth(true)
	innerTabFrame:SetFullHeight(true)
	innerTabFrame:SetTabs({{text="General Configuration", value="tab1"}, {text="Bar States", value="tab2"}, {text="Bar Visibility", value="tab3"}, {text="Spell Target Options", value="tab4"}})
	innerTabFrame:SetCallback("OnGroupSelected", function(self, _, tab) NeuronGUI:SelectInnerTab(self, _, tab) end)
	innerTabFrame:SelectTab(currentTab)
	tabFrame:AddChild(innerTabFrame)

end

-----------------------------------------------------------------------------
----------------------Inner Tab Frame----------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:SelectInnerTab(tabFrame, _, tab)

	tabFrame:ReleaseChildren()

	if tab == "tab1" then
		NeuronGUI:GeneralConfigPanel(tabFrame)
		currentTab = "tab1"
	elseif tab == "tab2" then
		NeuronGUI:BarStatesPanel(tabFrame)
		currentTab = "tab2"
	elseif tab == "tab3" then
		NeuronGUI:BarVisibilityPanel(tabFrame)
		currentTab = "tab3"
	elseif tab == "tab4" then
		NeuronGUI:SpellTargetingPanel(tabFrame)
		currentTab = "tab4"
	end

end



function NeuronGUI:GeneralConfigPanel(tabFrame)

	local desc = AceGUI:Create("Label")
	if Neuron.CurrentBar then
		desc:SetText("This is a test " .. Neuron.CurrentBar:GetName())
	else
		desc:SetText("No Selected Bar")
	end
	desc:SetFullWidth(true)
	tabFrame:AddChild(desc)
end

function NeuronGUI:BarStatesPanel(tabFrame)

end

function NeuronGUI:BarVisibilityPanel(tabFrame)

end

function NeuronGUI:SpellTargetingPanel(tabFrame)

end