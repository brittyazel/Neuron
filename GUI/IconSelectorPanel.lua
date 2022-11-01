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

local MAX_ICONS_PER_PAGE = 120
local curIconPage = 1

-----------------------------------------------------------------------------
--------------------------Icon Selector--------------------------------------
-----------------------------------------------------------------------------

function NeuronGUI:IconFrame_OnClick()
	NeuronGUI:CreateIconSelector()
end

function NeuronGUI:CreateIconSelector()
	iconSelector = AceGUI:Create("Frame")
	iconSelector:SetTitle("Select an icon")
	iconSelector:SetCallback("OnClose", function() iconSelector:Release() end)
	iconSelector:SetWidth(610)
	iconSelector:SetHeight(500)
	iconSelector:EnableResize(true)
	if iconSelector.frame.SetResizeBounds then -- WoW 10.0
		iconSelector.frame:SetResizeBounds(610,450)
	else
		iconSelector.frame:SetMinResize(610,450)
	end
	iconSelector:SetLayout("Flow") -- important!

	NeuronGUI:GenerateIconList()

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

	--container group for pagination
	local paginationContainer = AceGUI:Create("SimpleGroup")
	paginationContainer:SetLayout("Flow") -- important!
	paginationContainer:SetFullWidth(true)
	paginationContainer:SetHeight(80)
	iconSelector:AddChild(paginationContainer)

	--back button
	local backButton = AceGUI:Create("Button")
	backButton:SetRelativeWidth(0.15)
	backButton:SetText("Previous")
	backButton:SetCallback("OnClick", function()
		if curIconPage > 1 then
			curIconPage = curIconPage-1
		end
		NeuronGUI:RefreshIconSelector()
	end)
	--disable button if we are on th first page
	if curIconPage > 1 then
		backButton:SetDisabled(false)
	else
		backButton:SetDisabled(true)
	end
	paginationContainer:AddChild(backButton)

	--pagination slider
	local paginationSlider = AceGUI:Create("Slider")
	paginationSlider:SetRelativeWidth(0.68)
	paginationSlider:SetSliderValues(1,ceil(#iconList/MAX_ICONS_PER_PAGE),1)
	paginationSlider:SetLabel("Page")
	paginationSlider:SetValue(curIconPage)
	paginationSlider:SetCallback("OnValueChanged", function(self)
		curIconPage = self:GetValue()
		NeuronGUI:RefreshIconSelector()
	end)
	paginationContainer:AddChild(paginationSlider)

	--forward button
	local forwardButton = AceGUI:Create("Button")
	forwardButton:SetRelativeWidth(0.15)
	forwardButton:SetText("Next")
	forwardButton:SetCallback("OnClick",function()
		if curIconPage < ceil(#iconList/MAX_ICONS_PER_PAGE) then
			curIconPage = curIconPage + 1
		end
		NeuronGUI:RefreshIconSelector()
	end)
	--disable button if we are on the last page
	if curIconPage < ceil(#iconList/MAX_ICONS_PER_PAGE) then
		forwardButton:SetDisabled(false)
	else
		forwardButton:SetDisabled(true)
	end
	paginationContainer:AddChild(forwardButton)

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
			Neuron.currentButton:SetMacroIcon(iconList[i])
			Neuron.currentButton:UpdateIcon()
			NeuronGUI:RefreshIconPreview()
		end)
		iconScroll:AddChild(iconFrame)
	end
end

-----------------------------------------------------------
-----------------------------------------------------------

function NeuronGUI:GenerateIconList()
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