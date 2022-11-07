-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")

local Spec = addonTable.utilities.Spec

-----------------------------------------------------------------------------
--------------------------Button Editor--------------------------------------
-----------------------------------------------------------------------------

local function buttonEditPanel(specData, update)
	--container to hold all of our widgets, added to our tab frame
	local settingContainer = AceGUI:Create("SimpleGroup")
	settingContainer:SetFullWidth(true)
	settingContainer:SetLayout("Flow")

	-- forward declare the icon preview so we can wrap it in the update
	local previewIconFrame
	local updateAndRefreshIcon = function(data)
		update(data)
		NeuronGUI:RefreshIconPreview(previewIconFrame, specData)
	end

	--icon button that represents the currently selected icon
	previewIconFrame=AceGUI:Create("Icon")
	NeuronGUI:RefreshIconPreview(previewIconFrame, specData)
	previewIconFrame:SetImageSize(60,60)
	previewIconFrame:SetWidth(60)
	previewIconFrame:SetCallback("OnClick", function() NeuronGUI:IconFrame_OnClick() end)
	settingContainer:AddChild(previewIconFrame)

	--reset icon button
	local resetIconButton = AceGUI:Create("Button")
	resetIconButton:SetRelativeWidth(0.15)
	resetIconButton:SetText("Reset Icon")
	resetIconButton:SetCallback("OnClick", function()
		updateAndRefreshIcon{macro_Icon = false}
	end)
	settingContainer:AddChild(resetIconButton)

	--edit box to show the current macro
	local macroEditFrame = AceGUI:Create("MultiLineEditBox")
	macroEditFrame:SetLabel("Edit Macro")
	macroEditFrame:SetWidth(400)
	macroEditFrame:SetHeight(200)
	macroEditFrame:SetText(type(specData.macro_Text) == "string" and specData.macro_Text or "")
	macroEditFrame:DisableButton(true)
	macroEditFrame:SetCallback("OnTextChanged", function(_, _, text)
		updateAndRefreshIcon{macro_Text = text}
	end)
	settingContainer:AddChild(macroEditFrame)

	return settingContainer
end

function NeuronGUI:ButtonsEditPanel(tabContainer)
	Neuron:ToggleButtonEditMode(true)

	if not Neuron.currentButton then
		return
	end

	local multiSpec = Neuron.currentButton.bar:GetMultiSpec()

	for specIndex, specName in ipairs(Spec.names(multiSpec)) do
		-- TODO: Figure out multistate stuff
		local state = "homestate"
		local specData = Neuron.currentButton.DB[specIndex][state]

		local update = function(data)
			for k,v in pairs(data) do
				specData[k] = v
			end

			if Spec.active(multiSpec) ~= specIndex then
				-- don't update the button if the modified spec isn't active
				return
			end

			Neuron.currentButton:LoadDataFromDatabase(specIndex, state)
			Neuron.currentButton:UpdateAll()
		end

		local settingContainer = buttonEditPanel(specData, update)
		local specLabel = AceGUI:Create("Heading")
		specLabel:SetHeight(45)
		specLabel:SetText(specName)
		specLabel:SetFullWidth(true)

		tabContainer:AddChild(specLabel)
		tabContainer:AddChild(settingContainer)
	end
end

function NeuronGUI:RefreshIconPreview(frame, data)
	--try to get the texture currently on the button itself
	local texture = Neuron.currentButton:GetAppearance(data)
	if texture then
		frame:SetImage(texture)
	else --fallback to question mark icon if nothing is found
		frame:SetImage("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
	end
end
