-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local NeuronGUI = {}
Neuron.NeuronGUI = NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

local currentTab = "bar" --remember which tab we were using between refreshes

-----------------------------------------------------------------------------
--------------------------Main Window----------------------------------------
-----------------------------------------------------------------------------

function NeuronGUI:RefreshEditor(defaultTab)
	addonTable.NeuronEditor:ReleaseChildren()

	if defaultTab then
		currentTab = defaultTab
	end

	--re-add all the stuff to the editor window
	NeuronGUI:PopulateEditorWindow()

	if Neuron.currentBar then
		addonTable.NeuronEditor:SetStatusText("|cffffd200" .. Neuron.currentBar:GetBarName().."|cFFFFFFFF is currently selected. Left-click a different bar to change your selection.")
	else
		addonTable.NeuronEditor:SetStatusText("|cFFFFFFFFWelcome to the Neuron editor, please select a bar to begin")
	end
end


function NeuronGUI:CreateEditor(defaultTab)
	addonTable.NeuronEditor = AceGUI:Create("Frame") --add it to our base addon table to reference later

	addonTable.NeuronEditor:SetTitle("Neuron Editor")
	addonTable.NeuronEditor:EnableResize(true)
	if addonTable.NeuronEditor.frame.SetResizeBounds then -- WoW 10.0
		addonTable.NeuronEditor.frame:SetResizeBounds(760,600)
	else
		addonTable.NeuronEditor.frame:SetMinResize(760,600)
	end
	addonTable.NeuronEditor:SetWidth("760")
	addonTable.NeuronEditor:SetHeight("840")
	if Neuron.currentBar then
		addonTable.NeuronEditor:SetStatusText("|cffffd200" .. Neuron.currentBar:GetBarName().."|cFFFFFFFF is currently selected. Left-click a different bar to change your selection.")
	else
		addonTable.NeuronEditor:SetStatusText("|cFFFFFFFFWelcome to the Neuron editor, please select a bar to begin")
	end
	addonTable.NeuronEditor:SetCallback("OnClose", function() NeuronGUI:DestroyEditor() end)
	addonTable.NeuronEditor:SetLayout("Fill")

	if defaultTab then
		currentTab = defaultTab
	end
	--add all the stuff to the editor window
	NeuronGUI:PopulateEditorWindow()
end

function NeuronGUI:DestroyEditor()
	if addonTable.NeuronEditor then
		AceGUI:Release(addonTable.NeuronEditor)
		addonTable.NeuronEditor = nil
	end

	Neuron:ToggleBarEditMode()
	Neuron:ToggleButtonEditMode()
end

function NeuronGUI:PopulateEditorWindow()
	--Tab group that will contain all of our settings to configure
	local tabFrame = AceGUI:Create("TabGroup")
	tabFrame:SetLayout("Flow")
	tabFrame:SetTabs({{text="Bar Settings", value="bar"}, {text="Button Settings", value="button"}})
	tabFrame:SetCallback("OnGroupSelected", function(self, _, value) NeuronGUI:SelectTab(self, _, value) end)
	addonTable.NeuronEditor:AddChild(tabFrame)
	tabFrame:SelectTab(currentTab)
end


function NeuronGUI:SelectTab(tabFrame, _, value)
	tabFrame:ReleaseChildren()
	if value == "bar" then
		NeuronGUI:BarEditPanel(tabFrame)
		currentTab = "bar"
	elseif value == "button" then
		NeuronGUI:ButtonEditPanel(tabFrame)
		currentTab = "button"
	end
end