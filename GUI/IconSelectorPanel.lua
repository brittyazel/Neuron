-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

local iconSelector
local iconList = {}

local MAX_ICONS_PER_PAGE = 168
local curIconPage = 1

-----------------------------------------------------------------------------
--------------------------Icon Selector--------------------------------------
-----------------------------------------------------------------------------

function NeuronGUI:IconFrame_OnClick()
	NeuronGUI:CreateIconSelector()
end

function NeuronGUI:CreateIconSelector()
	iconSelector = AceGUI:Create("Frame")
	iconSelector:SetTitle("Select and icon")
	iconSelector:SetCallback("OnClose", function() iconSelector:Release() end)
	iconSelector:SetWidth(660)
	iconSelector:SetHeight(500)
	iconSelector:EnableResize(true)
	iconSelector:SetLayout("Flow") -- important!

	NeuronGUI:RefreshPlayerSpellIconInfo()

	NeuronGUI:CreateIconSelectorInternals()

end

function NeuronGUI:RefreshIconSelector()
	iconSelector:ReleaseChildren()
	NeuronGUI:CreateIconSelectorInternals()
end

function NeuronGUI:CreateIconSelectorInternals()

	--------------------------------------------------
	------------------- Pagination -------------------
	--------------------------------------------------

	local paginationSlider = AceGUI:Create("Slider")
	paginationSlider:SetFullWidth(true)
	paginationSlider:SetSliderValues(1,ceil(#iconList/MAX_ICONS_PER_PAGE),1)
	paginationSlider:SetLabel("Page")
	paginationSlider:SetValue(curIconPage)
	paginationSlider:SetCallback("OnValueChanged", function(self)
		curIconPage = self:GetValue()
		NeuronGUI:RefreshIconSelector()
	end)
	iconSelector:AddChild(paginationSlider)

	--------------------------------------------------
	--------------- Icon Scroll Frame ----------------
	--------------------------------------------------
	local scrollContainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	scrollContainer:SetLayout("Fill") -- important!
	scrollContainer:SetFullWidth(true)
	scrollContainer:SetFullHeight(true)
	iconSelector:AddChild(scrollContainer)

	local iconScroll = AceGUI:Create("ScrollFrame")
	iconScroll:SetLayout("Flow") -- probably?
	scrollContainer:AddChild(iconScroll)

	--this is temporary. We need to populate a list of icons here

	local start = (curIconPage*MAX_ICONS_PER_PAGE)-(MAX_ICONS_PER_PAGE-1)
	local stop = (curIconPage*MAX_ICONS_PER_PAGE)

	for i=start,stop do
		local iconFrame=AceGUI:Create("Icon")
		iconFrame:SetImage(iconList[i])
		iconFrame:SetImageSize(40,40)
		iconFrame:SetWidth(50)
		iconFrame:SetCallback("OnClick", function()
			Neuron.currentButton.data.macro_Icon = iconList[i]
			Neuron.currentButton:UpdateIcon()
			NeuronGUI:RefreshIconPreview()
		end)
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

	for _,v in pairs(Neuron.spellCache) do
		if v.icon and not tContains(iconList, v.icon) then
			table.insert(iconList, v.icon)
		end
	end

	for _,v in pairs(Neuron.itemCache) do
		if v.icon and not tContains(iconList, v.icon) then
			table.insert(iconList, v.icon)
		end
	end

	GetLooseMacroIcons( iconList );
	GetLooseMacroItemIcons( iconList );
	GetMacroIcons( iconList );
	GetMacroItemIcons( iconList );
end