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


local addonName = ...

local DB

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

local iconSelector

local iconList = {}

-----------------------------------------------------------------------------
--------------------------Button Editor--------------------------------------
-----------------------------------------------------------------------------


function NeuronGUI:ButtonEditPanel(tabContainer)

	Neuron:ToggleButtonEditMode(true)

	if Neuron.currentButton then
		local settingContainer = AceGUI:Create("SimpleGroup")
		settingContainer:SetFullWidth(true)
		settingContainer:SetLayout("Flow")
		tabContainer:AddChild(settingContainer)

		local iconFrame=AceGUI:Create("Icon")
		iconFrame:SetImage("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		iconFrame:SetImageSize(40,40)
		iconFrame:SetWidth(50)
		iconFrame:SetCallback("OnClick", function() NeuronGUI:IconFrame_OnClick() end)
		settingContainer:AddChild(iconFrame)
	end
end


-----------------------------------------------------------------------------
--------------------------Icon Selector--------------------------------------
-----------------------------------------------------------------------------

function NeuronGUI:IconFrame_OnClick()
	if not iconSelector then
		NeuronGUI:CreateIconSelector()
	else
		iconSelector:Show()
	end
end




function NeuronGUI:CreateIconSelector()
	iconSelector = AceGUI:Create("Frame")
	iconSelector:SetTitle("Select and icon")
	iconSelector:SetCallback("OnClose", function() iconSelector:Hide() end)
	iconSelector:SetWidth(660)
	iconSelector:SetHeight(500)
	iconSelector:SetLayout("Fill") -- important!

	local scrollContainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	scrollContainer:SetLayout("Fill") -- important!
	iconSelector:AddChild(scrollContainer)

	local iconScroll = AceGUI:Create("ScrollFrame")
	iconScroll:SetLayout("Flow") -- probably?
	scrollContainer:SetFullWidth(true)
	scrollContainer:SetFullHeight(true)
	scrollContainer:AddChild(iconScroll)

	--this is temporary. We need to populate a list of icons here

	NeuronGUI:RefreshPlayerSpellIconInfo()

	for i=1,#iconList do
		local iconFrame=AceGUI:Create("Icon")
		iconFrame:SetImage(iconList[i])
		iconFrame:SetImageSize(40,40)
		iconFrame:SetWidth(50)
		iconScroll:AddChild(iconFrame)
	end
end

function NeuronGUI:RefreshPlayerSpellIconInfo()

	wipe(iconList)

	--we need a quick function to check if a table contains a value already
	local function tContains(table, item)
		local index = 1;
		while table[index] do
			if item == table[index] then
				return 1;
			end
			index = index + 1;
		end
		return nil;
	end

	for _,v in pairs(NeuronSpellCache) do
		if v.icon and not tContains(iconList, v.icon) then
			table.insert(iconList, v.icon)
		end
	end

	for _,v in pairs(NeuronItemCache) do
		if v.icon and not tContains(iconList, v.icon) then
			table.insert(iconList, v.icon)
		end
	end

end