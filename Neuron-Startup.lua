-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local DB

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

function Neuron:Startup()
	DB = Neuron.db.profile
	Neuron:RegisterBars()
	Neuron:RegisterGUI()
	Neuron:CreateBarsAndButtons()
end

function Neuron:RegisterBars()

	--Neuron Action Bar
	Neuron:RegisterBarClass("ActionBar", "ActionBar", L["Action Bar"], "Action Button", DB.ActionBar, Neuron.ActionButton, 250)

	--Neuron Bag Bar
	Neuron:RegisterBarClass("BagBar", "BagBar", L["Bag Bar"], "Bag Button", DB.BagBar, Neuron.BagButton, Neuron.NUM_BAG_BUTTONS)

	--Neuron Menu Bar
	Neuron:RegisterBarClass("MenuBar", "MenuBar", L["Menu Bar"], "Menu Button", DB.MenuBar, Neuron.MenuButton, 11)

	--Neuron Pet Bar
	Neuron:RegisterBarClass("PetBar", "PetBar", L["Pet Bar"], "Pet Button", DB.PetBar, Neuron.PetButton, 10)

	--Neuron XP Bar
	Neuron:RegisterBarClass("XPBar", "XPBar", L["XP Bar"], "XP Button", DB.XPBar, Neuron.ExpButton, 10)

	--Neuron Rep Bar
	Neuron:RegisterBarClass("RepBar", "RepBar", L["Rep Bar"], "Rep Button", DB.RepBar, Neuron.RepButton, 10)

	--Neuron Cast Bar
	Neuron:RegisterBarClass("CastBar", "CastBar", L["Cast Bar"], "Cast Button", DB.CastBar, Neuron.CastButton, 10)

	--Neuron Mirror Bar
	Neuron:RegisterBarClass("MirrorBar", "MirrorBar", L["Mirror Bar"], "Mirror Button", DB.MirrorBar, Neuron.MirrorButton, 10)

	if Neuron.isWoWRetail then
		--Neuron Zone Ability Bar
		Neuron:RegisterBarClass("ZoneAbilityBar", "ZoneAbilityBar", L["Zone Action Bar"], "Zone Action Button", DB.ZoneAbilityBar, Neuron.ZoneAbilityButton, 5, true)

		--Neuron Extra Bar
		Neuron:RegisterBarClass("ExtraBar", "ExtraBar", L["Extra Action Bar"], "Extra Action Button", DB.ExtraBar, Neuron.ExtraButton, 1)

		--Neuron Exit Bar
		Neuron:RegisterBarClass("ExitBar", "ExitBar", L["Vehicle Exit Bar"], "Vehicle Exit Button", DB.ExitBar, Neuron.ExitButton, 1)
	end

end

function Neuron:RegisterGUI()

	--Neuron Action Bar
	Neuron:RegisterGUIOptions("ActionBar",
			{
				AUTOHIDE = true,
				SHOWGRID = true,
				SNAPTO = true,
				CLICKMODE = true,
				MULTISPEC = true,
				HIDDEN = true,
				LOCKBAR = true,
			},

			{
				BINDTEXT = true,
				BUTTONTEXT = true,
				COUNTTEXT = true,
				RANGEIND = true,
				CDTEXT = true,
				CDALPHA = true,
				SPELLGLOW = true,
				TOOLTIPS = true,
			})

	--Neuron Bag Bar
	Neuron:RegisterGUIOptions("BagBar",
			{
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			})

	--Neuron Menu Bar
	Neuron:RegisterGUIOptions("MenuBar",
			{
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			})

	--Neuron Pet Bar
	Neuron:RegisterGUIOptions("PetBar",
			{
				AUTOHIDE  = true,
				--SHOWGRID  = true,
				SNAPTO    = true,
				CLICKMODE = true,
				HIDDEN    = true,
				LOCKBAR   = true,
			},

			{
				BINDTEXT = true,
				BUTTONTEXT = true,
				RANGEIND = true,
				CDTEXT = true,
				CDALPHA = true,
				TOOLTIPS = true,
			})

	--Neuron XP Bar
	Neuron:RegisterGUIOptions("XPBar",
			{
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			},

			{
				TOOLTIPS = true,
			})

	--Neuron Rep Bar
	Neuron:RegisterGUIOptions("RepBar",
			{
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			},

			{
				TOOLTIPS = true,
			})

	--Neuron Cast Bar
	Neuron:RegisterGUIOptions("CastBar",
			{
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			},

			{
				TOOLTIPS = true,
			})

	--Neuron Mirror Bar
	Neuron:RegisterGUIOptions("MirrorBar",
			{
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			},

			{
				TOOLTIPS = true,
			})

	if Neuron.isWoWRetail then
		--Neuron Zone Ability Bar
		Neuron:RegisterGUIOptions("ZoneAbilityBar",
				{
					AUTOHIDE = true,
					SNAPTO = true,
					CLICKMODE = true,
					HIDDEN = true,
				},

				{
					BINDTEXT = true,
					COUNTTEXT = true,
					CDTEXT = true,
					CDALPHA = true,
					TOOLTIPS = true,
					BORDERSTYLE = true,
				})

		--Neuron Extra Bar
		Neuron:RegisterGUIOptions("ExtraBar",
				{
					AUTOHIDE = true,
					SNAPTO = true,
					CLICKMODE = true,
					HIDDEN = true,
				},

				{
					BINDTEXT = true,
					COUNTTEXT = true,
					CDTEXT = true,
					CDALPHA = true,
					TOOLTIPS = true,
					BORDERSTYLE = true,
				})

		--Neuron Exit Bar
		Neuron:RegisterGUIOptions("ExitBar",
				{
					AUTOHIDE = true,
					SHOWGRID = false,
					SNAPTO = true,
					CLICKMODE = true,
					HIDDEN = true,
					LOCKBAR = false,
				})

	end
end

function Neuron:CreateBarsAndButtons()
	if DB.firstRun then

		for barClass, barDefaults in pairs(addonTable.defaultBarOptions) do
			if Neuron.registeredBarData[barClass] then --only build default bars for registered bars types (Classic doesn't use all the bar types that Retail does)
				for i, defaults in ipairs(barDefaults) do --create the bar objects
					local newBar = Neuron.Bar.new(barClass, i) --this calls the bar constructor

					--create the default button objects for a given bar with the default values
					newBar:SetDefaults(defaults)

					for buttonID=1,#defaults.buttons do
						newBar.objTemplate.new(newBar, buttonID, defaults.buttons[buttonID]) --newBar.objTemplate is something like ActionButton or ExtraButton, we just need to code it agnostic
					end
				end
			end

		end

		DB.firstRun = false

	else

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
