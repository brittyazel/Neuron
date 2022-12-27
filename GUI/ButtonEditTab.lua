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

--- @param frame Frame @the icon preview frame
--- @param data GenericSpecData
--- @return nil
local function refreshIconPreview(frame, data)
	--try to get the texture currently on the button itself
	local texture = Neuron.ActionButton.GetAppearance(data)
	if texture then
		frame:SetImage(texture)
	else --fallback to question mark icon if nothing is found
		frame:SetImage("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
	end
end

---take a parent frame and fills it with a child scroll frame
---@param parent Frame @parent frame--we need this because we want to abstract out the parent group, and only return the scroll frame
---@param height? number @the default zero does nothing
---@param layout? "Flow"|"List"|nil @"Flow" is the default
---@return Frame @the scroll frame
local function makeScrollFrame(parent, height, layout)
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

--our states come from the VISIBILITY_STATES but we only show the states that
--are enabled for the bar _and_ that are in the states field of the
--corresponding MANAGED_BAR_STATES entry
---@param barData GenericBarData
---@return string[]
local function getStateList(barData)
	local barStates =
		Array.filter(function(state) return barData[state] end,
		Array.map(function(state) return state[1] end,
		Array.fromIterator(pairs(Neuron.MANAGED_BAR_STATES))))

	local visibilityStates =
		Array.filter(
			function(visibilityState)
				return Array.find(
					function(barState)
						local match = Neuron.MANAGED_BAR_STATES[barState].states:find(visibilityState)
						return not not match and Neuron.MANAGED_BAR_STATES[barState].homestate ~= visibilityState
					end,
					barStates
				)
			end,
		Array.map(function(state) return state[1] end,
		Array.fromIterator(pairs(Neuron.VISIBILITY_STATES))))

	--TODO: custom states? or nah?
	--[[
	if (bar and bar.data.customNames) then
		local i = 0
		for index,state in pairs(bar.data.customNames) do
			stateList[state] = index
			data[count] = state; count = count + 1
		end
	end
	]]

	return visibilityStates
end

---@param specData GenericSpecData
---@param update fun(data: GenericSpecData): nil
---@return Frame
local function buttonEditPanel(specData, update)
	--container to hold all of our widgets, added to our tab frame
	local settingContainer = AceGUI:Create("SimpleGroup")
	settingContainer:SetFullWidth(true)
	settingContainer:SetLayout("Flow")


	--edit box to show the macro label
	local labelEditFrame = AceGUI:Create("EditBox")
	labelEditFrame:SetLabel("Edit Label")
	labelEditFrame:SetRelativeWidth(1)
	labelEditFrame:SetText(type(specData.macro_Text) == "string" and specData.macro_Name or "")
	labelEditFrame:DisableButton(true)
	labelEditFrame:SetCallback("OnTextChanged", function(_, _, text)
		update{macro_Name = text}
	end)
	settingContainer:AddChild(labelEditFrame)

	local mainContainer = AceGUI:Create("SimpleGroup")
	mainContainer:SetFullWidth(true)
	mainContainer:SetLayout("Flow")
	mainContainer:SetHeight(200)

	--icon button that represents the currently selected icon
	local previewIconFrame=AceGUI:Create("Icon")
	refreshIconPreview(previewIconFrame, specData)
	previewIconFrame:SetImageSize(60,60)
	previewIconFrame:SetWidth(60)
	previewIconFrame:SetCallback("OnClick", function() NeuronGUI:IconFrame_OnClick() end)
	mainContainer:AddChild(previewIconFrame)
	local updateAndRefreshIcon = function(data)
		update(data)
		refreshIconPreview(previewIconFrame, specData)
	end

	--edit box to show the current macro
	local macroEditFrame = AceGUI:Create("MultiLineEditBox")
	macroEditFrame:SetLabel("Edit Macro")
	macroEditFrame:SetWidth(420)
	macroEditFrame:SetFullHeight(true)
	macroEditFrame:SetText(type(specData.macro_Text) == "string" and specData.macro_Text or "")
	macroEditFrame:DisableButton(true)
	macroEditFrame:SetCallback("OnTextChanged", function(_, _, text)
		updateAndRefreshIcon{macro_Text = text}
	end)
	mainContainer:AddChild(macroEditFrame)

	settingContainer:AddChild(mainContainer)

	local buttonContainer = AceGUI:Create("SimpleGroup")
	buttonContainer:SetFullWidth(true)
	buttonContainer:SetLayout("Flow")

	--reset icon button
	--disabled or now, until we have a real icon picker
	local resetIconButton = AceGUI:Create("Button")
	--resetIconButton:SetRelativeWidth(0.15)
	resetIconButton:SetText("Reset Icon")
	resetIconButton:SetCallback("OnClick", function()
		updateAndRefreshIcon{macro_Icon = false}
	end)
	buttonContainer:AddChild(resetIconButton)

	settingContainer:AddChild(buttonContainer)

	return settingContainer
end

---@param button ActionButton
---@param topContainer Frame
function NeuronGUI:ButtonsEditPanel(button, topContainer)
	Neuron:ToggleButtonEditMode(true)

	topContainer = makeScrollFrame(topContainer)

	local multiSpec = button.bar:GetMultiSpec()

	local specs = Spec.names(multiSpec)
	specs[5] =  L["No Spec"]

	for specIndex, specName in pairs(specs) do
		local specData = button.DB[specIndex]

		local buttonTree = {
			value = "homestate",
			text = specName,
			children = Array.map(
				function(state) return {value=state, text=Neuron.STATES[state]} end,
				getStateList(button.bar.data)
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

				-- don't update the button if the modified spec isn't active
				if Spec.active(multiSpec) == specIndex then
					-- for some reason we need to do a full bar load or the buttons don't
					-- update. we can investigate further, but note that switching specs
					-- probably needs the same fix
					button.bar:Load()
					--button:LoadDataFromDatabase(specIndex, state)
					--button:UpdateAll()
				end
			end)
			container:AddChild(buttonEditor)
		end)

		specButtonTree:SelectByValue("homestate")

		-- make sure to do this last, or the size of the scroll box
		-- might be smaller than it's contents
		topContainer:AddChild(specButtonTree)
	end
end
