-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local Array = addonTable.utilities.Array

--- this function has no business existing
--- database defaults should be in the database
--- but we have them scattered between neuron-defaults and neuron-db-defaults
function Neuron:InitializeEmptyDatabase(DB)
	DB.firstRun = false

	--only build default bars for registered bars types (Classic doesn't use all the bar types that Retail does)
	for barClass, registeredData in pairs(Neuron.registeredBarData) do
		local newBars = Array.map(
			function(bar)
				-- MergeTable modifies in place, so copy first
				local newBar = CopyTable(addonTable.databaseDefaults.profile[barClass]['*'])
				local newButtons = Array.map(
					function(button)
						local newButton = CopyTable(newBar.buttons['*'])
						local newConfig = CopyTable(newButton.config)

						MergeTable(newConfig, button.config or {})
						MergeTable(newButton, button)
						MergeTable(newButton, {config = newConfig})
						return newButton
					end,
					bar.buttons
				)
				MergeTable(newBar, bar)
				MergeTable(newBar, {buttons=newButtons})
				return newBar
			end,
			addonTable.defaultBarOptions[barClass]
		)
		MergeTable(registeredData.barDB, newBars)
	end
end

function Neuron:CreateBarsAndButtons()
	for barClass, barClassData in pairs (Neuron.registeredBarData) do
		for id,data in pairs(barClassData.barDB) do
			if data ~= nil then
				local newBar = Neuron.Bar.new(barClass, id) --this calls the bar constructor

				--create all the saved button objects for a given bar
				for buttonID=1,#newBar.data.buttons do
					newBar.objTemplate.new(newBar, buttonID) --newBar.objTemplate is something like ActionButton or ExtraButton, we just need to code it agnostic
				end
			end
		end
	end
end

function Neuron:Overrides()
	---disabled temporarily for 10.0 porting purposes
	--[[

	--bag bar overrides
	if DB.blizzbar == false then
		--hide the weird color border around bag bars
		CharacterBag0Slot.IconBorder:Hide()
		CharacterBag1Slot.IconBorder:Hide()
		CharacterBag2Slot.IconBorder:Hide()
		CharacterBag3Slot.IconBorder:Hide()

		--overwrite the Show function with a null function because it keeps coming back and won't stay hidden
		if not Neuron:IsHooked(CharacterBag0Slot.IconBorder, "Show") then
			Neuron:RawHook(CharacterBag0Slot.IconBorder, "Show", function() end, true)
		end
		if not Neuron:IsHooked(CharacterBag1Slot.IconBorder, "Show") then
			Neuron:RawHook(CharacterBag1Slot.IconBorder, "Show", function() end, true)
		end
		if not Neuron:IsHooked(CharacterBag2Slot.IconBorder, "Show") then
			Neuron:RawHook(CharacterBag2Slot.IconBorder, "Show", function() end, true)
		end
		if not Neuron:IsHooked(CharacterBag3Slot.IconBorder, "Show") then
			Neuron:RawHook(CharacterBag3Slot.IconBorder, "Show", function() end, true)
		end
	end

	--status bar overrides
	local disableDefaultCast = false
	local disableDefaultMirror = false

	for _,v in ipairs(Neuron.bars) do

		if v.barType == "CastBar" then
			for _, button in ipairs(v.buttons) do
				if button then
					disableDefaultCast = true
				end
			end
		end


		if v.barType == "MirrorBar" then
			for _, button in ipairs(v.buttons) do
				if button then
					disableDefaultMirror = true
				end
			end
		end
	end


	if disableDefaultCast then
		CastingBarFrame:UnregisterAllEvents()
		CastingBarFrame:SetParent(Neuron.hiddenFrame)
	end

	if disableDefaultMirror then
		UIParent:UnregisterEvent("MIRROR_TIMER_START")
		MirrorTimer1:UnregisterAllEvents()
		MirrorTimer1:SetParent(Neuron.hiddenFrame)
		MirrorTimer2:UnregisterAllEvents()
		MirrorTimer2:SetParent(Neuron.hiddenFrame)
		MirrorTimer3:UnregisterAllEvents()
		MirrorTimer3:SetParent(Neuron.hiddenFrame)
	end

	]]
end
