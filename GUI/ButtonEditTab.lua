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
local Array = addonTable.utilities.Array

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

function NeuronGUI:ButtonsEditPanel(topContainer)
	Neuron:ToggleButtonEditMode(true)

	if not Neuron.currentButton then
		return
	end

	topContainer = NeuronGUI:MakeScrollFrame(topContainer)

	local multiSpec = Neuron.currentButton.bar:GetMultiSpec()

	local specs = Spec.names(multiSpec)
	specs[5] =  L["No Spec"]

	for specIndex, specName in pairs(specs) do
		local specData = Neuron.currentButton.DB[specIndex]

		-- these steps happen inside out--reverse
		-- convert specData to key value pairs
		-- convert key value pairs to keys
		-- remove homestate key
		local nonHomeStates =
			Array.filter(function(key) return key ~= "homestate" end,
			Array.map(function(keyValuePair) return keyValuePair[1] end,
			Array.fromIterator(pairs(specData))))

		local buttonTree = {
			value = "homestate",
			text = specName,
			children = Array.map(
				function(state) return {value=state, text=Neuron.STATES[state]} end,
				nonHomeStates
			),
		}

		local specButtonTree = AceGUI:Create("TreeGroup")
		specButtonTree:SetFullWidth(true)
		specButtonTree:SetLayout("Flow")
		specButtonTree:SetTree({buttonTree})
		specButtonTree:SetCallback("OnGroupSelected", function(container, _, joinedState)
			container:ReleaseChildren()

			-- this seems unnecessarily complicated...that moment when you have to
			-- read the source of your library figure out...this? smh
			local splitState = {string.split("\001",joinedState)}
			local state = splitState[#splitState]

			local buttonEditor = buttonEditPanel(specData[state], function(data)
				for k,v in pairs(data) do
					specData[state][k] = v
				end

				if Spec.active(multiSpec) ~= specIndex then
					-- don't update the button if the modified spec isn't active
					return
				end

				-- for some reason we need to do a full bar load or the buttons don't
				-- update. we can investigate further, but note that switching specs
				-- probably needs the same fix
				Neuron.currentButton.bar:Load()
				--Neuron.currentButton:LoadDataFromDatabase(specIndex, state)
				--Neuron.currentButton:UpdateAll()
			end)
			container:AddChild(buttonEditor)
		end)

		topContainer:AddChild(specButtonTree)
		specButtonTree:SelectByValue("homestate")
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

---take a parent frame and fills it with a child scroll frame
---@param parent any @parent frame--we need this because we want to abstract out the parent group, and only return the scroll frame
---@param height? number @the default zero does nothing
---@param layout? "Flow"|"List"|nil @"Flow" is the default
---@return any @the scroll frame
function NeuronGUI:MakeScrollFrame(parent, height, layout)
		local scrollContainer = AceGUI:Create("SimpleGroup")
		scrollContainer:SetFullWidth(true)
	if height then
		scrollContainer:SetHeight(height)
	else
		scrollContainer:SetFullHeight(true)
	end
		scrollContainer:SetLayout("Fill")

		parent:AddChild(scrollContainer)

		local scroll = AceGUI:Create("ScrollFrame")
		scroll:SetLayout(layout or "Flow")
		scrollContainer:AddChild(scroll)

		return scroll
end
