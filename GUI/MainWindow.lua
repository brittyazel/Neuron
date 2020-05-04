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
--copyrights for Neuron are held by Britt Yazel, 2017-2019.

local NeuronGUI = {}
Neuron.NeuronGUI = NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

local currentTab = "tab1" --remember which tab we were using between refreshes

-----------------------------------------------------------------------------
--------------------------Main Window----------------------------------------
-----------------------------------------------------------------------------

function NeuronGUI:RefreshEditor(tab)
	NeuronEditor:ReleaseChildren()

	if tab then
		currentTab = tab
	end

	--re-add all the stuff to the editor window
	NeuronGUI:PopulateEditorWindow()

	if Neuron.currentBar then
		NeuronEditor:SetStatusText("The currently selected bar is: " .. Neuron.currentBar:GetBarName())
	else
		NeuronEditor:SetStatusText("Please select a bar from the right to begin")
	end
end


function NeuronGUI:CreateEditor(tab)
	NeuronEditor = AceGUI:Create("Frame")
	NeuronEditor:SetTitle("Neuron Editor")
	NeuronEditor:SetWidth("750")
	NeuronEditor:SetHeight("700")
	if Neuron.currentBar then
		NeuronEditor:SetStatusText("The Currently Selected Bar is: " .. Neuron.currentBar.data.name)
	else
		NeuronEditor:SetStatusText("Welcome to the Neuron editor, please select a bar to begin")
	end
	NeuronEditor:SetCallback("OnClose", function() NeuronGUI:DestroyEditor() end)
	NeuronEditor:SetLayout("Fill")

	if tab then
		currentTab = tab
	end
	--add all the stuff to the editor window
	NeuronGUI:PopulateEditorWindow()
end

function NeuronGUI:DestroyEditor()
	AceGUI:Release(NeuronEditor)
	NeuronEditor = nil

	Neuron:ToggleBarEditMode()
	Neuron:ToggleButtonEditMode()
end

function NeuronGUI:PopulateEditorWindow()
	--Tab group that will contain all of our settings to configure
	local tabFrame = AceGUI:Create("TabGroup")
	tabFrame:SetLayout("Fill")
	tabFrame:SetTabs({{text="Bar Settings", value="tab1"}, {text="Button Settings", value="tab2"}})
	tabFrame:SetCallback("OnGroupSelected", function(self, event, tab) NeuronGUI:SelectTab(self, event, tab) end)

	NeuronEditor:AddChild(tabFrame)

	tabFrame:SelectTab(currentTab)
end


function NeuronGUI:SelectTab(tabFrame, _, tab)
	tabFrame:ReleaseChildren()
	if tab == "tab1" then
		NeuronGUI:BarEditPanel(tabFrame)
		currentTab = "tab1"
	elseif tab == "tab2" then
		NeuronGUI:ButtonEditPanel(tabFrame)
		currentTab = "tab2"
	end
end