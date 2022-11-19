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

function Neuron:CreateBarsAndButtons(profileData)
	local neuronBars =
		Array.filter(
			function (barPair)
				local bar, _ = unpack(barPair)
			  return not profileData.blizzBars[bar]
			end,
		Array.fromIterator(pairs(Neuron.registeredBarData)))

	for _, barData in pairs (neuronBars) do
		local barClass, barClassData = unpack(barData)
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
