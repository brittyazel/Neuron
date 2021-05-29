-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

Neuron.previewIconFrame = {}


-----------------------------------------------------------------------------
--------------------------Button Editor--------------------------------------
-----------------------------------------------------------------------------

function NeuronGUI:ButtonEditPanel(tabContainer)
	Neuron:ToggleButtonEditMode(true)

	if Neuron.currentButton then
		--container to hold all of our widgets, added to our tab frame
		local settingContainer = AceGUI:Create("SimpleGroup")
		settingContainer:SetFullWidth(true)
		settingContainer:SetLayout("Flow")
		tabContainer:AddChild(settingContainer)

		--icon button that represents the currently selected icon
		Neuron.previewIconFrame=AceGUI:Create("Icon")
		NeuronGUI:RefreshIconPreview(Neuron.previewIconFrame)
		Neuron.previewIconFrame:SetImageSize(60,60)
		Neuron.previewIconFrame:SetWidth(60)
		Neuron.previewIconFrame:SetCallback("OnClick", function() NeuronGUI:IconFrame_OnClick() end)
		settingContainer:AddChild(Neuron.previewIconFrame)

		--reset icon button
		local resetIconButton = AceGUI:Create("Button")
		resetIconButton:SetRelativeWidth(0.15)
		resetIconButton:SetText("Reset Icon")
		resetIconButton:SetCallback("OnClick", function()
			Neuron.currentButton:SetMacroIcon() --unset the icon
			Neuron.currentButton:UpdateIcon()
			NeuronGUI:RefreshIconPreview()
		end)
		settingContainer:AddChild(resetIconButton)

		--edit box to show the current macro
		local macroEditFrame = AceGUI:Create("MultiLineEditBox")
		macroEditFrame:SetLabel("Edit Macro")
		macroEditFrame:SetWidth(400)
		macroEditFrame:SetHeight(200)
		if Neuron.currentButton:GetMacroText() then
			macroEditFrame:SetText(Neuron.currentButton:GetMacroText())
		else
			macroEditFrame:SetText("")
		end
		settingContainer:AddChild(macroEditFrame)
	end
end


function NeuronGUI:RefreshIconPreview()
	--try to get the texture currently on the button itself
	local texture = Neuron.currentButton.Icon:GetTexture()
	if texture then
		Neuron.previewIconFrame:SetImage(texture)
	else --fallback to question mark icon if nothing is found
		Neuron.previewIconFrame:SetImage("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
	end
end