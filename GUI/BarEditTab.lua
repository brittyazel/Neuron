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

local currentTab = "tab1" --remember which tab we were using between refreshes


-----------------------------------------------------------------------------
--------------------------Bar Editor-----------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:BarEditPanel(tabFrame)

	if Neuron.CurrentBar then
		--Tab group that will contain all of our settings to configure
		local innerTabFrame = AceGUI:Create("TabGroup")
		innerTabFrame:SetLayout("Flow")
		innerTabFrame:SetFullWidth(true)
		innerTabFrame:SetFullHeight(true)
		innerTabFrame:SetTabs({{text="General Configuration", value="tab1"}, {text="Bar States", value="tab2"}, {text="Bar Visibility", value="tab3"}, {text="Spell Target Options", value="tab4"}})
		innerTabFrame:SetCallback("OnGroupSelected", function(self, _, tab) NeuronGUI:SelectInnerTab(self, _, tab) end)
		innerTabFrame:SelectTab(currentTab)
		tabFrame:AddChild(innerTabFrame)
	else
		local selectBarMessage = AceGUI:Create("Label")
		selectBarMessage:SetFullWidth(true)
		selectBarMessage:SetFullHeight(true)
		selectBarMessage:SetText("Please select a bar to continue")
		selectBarMessage:SetFont("Fonts\\FRIZQT__.TTF", 30)
		tabFrame:AddChild(selectBarMessage)
	end

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