--Neuron, a World of Warcraft® user interface addon.

--This file is part of Neuron.
--
--Neuron is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--Neuron is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with this add-on.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2019.

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
	Neuron:RegisterBarClass("ActionBar", "ActionBar", L["Action Bar"], "Action Button", DB.ActionBar, Neuron.ACTIONBUTTON, 250, true)

	--Neuron Bag Bar
	Neuron:RegisterBarClass("BagBar", "BagBar", L["Bag Bar"], "Bag Button", DB.BagBar, Neuron.BAGBTN,5, false)

	--Neuron Status Bar
	Neuron:RegisterBarClass("StatusBar", "StatusBar", L["Status Bar"], "Status Bar", DB.StatusBar, Neuron.STATUSBTN, 20, false)

	--Neuron Menu Bar
	Neuron:RegisterBarClass("MenuBar", "MenuBar", L["Menu Bar"], "Menu Button", DB.MenuBar, Neuron.MENUBTN, 11, false)

	--Neuron Pet Bar
	Neuron:RegisterBarClass("PetBar", "PetBar", L["Pet Bar"], "Pet Button", DB.PetBar, Neuron.PETBTN, 10, true)

	if not Neuron.isWoWClassic then
		--Neuron Zone Ability Bar
		Neuron:RegisterBarClass("ZoneAbilityBar", "ZoneAbilityBar", L["Zone Action Bar"], "Zone Action Button", DB.ZoneAbilityBar, Neuron.ZONEABILITYBTN, 1, true)

		--Neuron Extra Bar
		Neuron:RegisterBarClass("ExtraBar", "ExtraBar", L["Extra Action Bar"], "Extra Action Button", DB.ExtraBar, Neuron.EXTRABTN,1, true)

		--Neuron Exit Bar
		Neuron:RegisterBarClass("ExitBar", "ExitBar", L["Vehicle Exit Bar"], "Vehicle Exit Button", DB.ExitBar, Neuron.EXITBTN,1, false)
	end

end

function Neuron:RegisterGUI()

	--Neuron Action Bar
	Neuron:RegisterGUIOptions("ActionBar", {
		AUTOHIDE = true,
		SHOWGRID = true,
		SPELLGLOW = true,
		SNAPTO = true,
		UPCLICKS = true,
		DOWNCLICKS = true,
		MULTISPEC = true,
		HIDDEN = true,
		LOCKBAR = true,
		TOOLTIPS = true,
		BINDTEXT = true,
		MACROTEXT = true,
		COUNTTEXT = true,
		RANGEIND = true,
		CDTEXT = true,
		CDALPHA = true,
		AURATEXT = true,
		AURAIND = true },
			true, 115)

	--Neuron Bag Bar
	Neuron:RegisterGUIOptions("BagBar", {
		AUTOHIDE = true,
		SHOWGRID = false,
		SPELLGLOW = false,
		SNAPTO = true,
		MULTISPEC = false,
		HIDDEN = true,
		LOCKBAR = false,
		TOOLTIPS = true, },
			false, false)

	--Neuron Status Bar
	Neuron:RegisterGUIOptions("StatusBar", {
		AUTOHIDE = true,
		SNAPTO = true,
		HIDDEN = true,
		TOOLTIPS = true },
			false, false)

	--Neuron Menu Bar
	Neuron:RegisterGUIOptions("MenuBar", {
		AUTOHIDE = true,
		SHOWGRID = false,
		SPELLGLOW = false,
		SNAPTO = true,
		MULTISPEC = false,
		HIDDEN = true,
		LOCKBAR = false,
		TOOLTIPS = true },
			false, false)

	--Neuron Pet Bar
	Neuron:RegisterGUIOptions("PetBar", {
		AUTOHIDE = true,
		SHOWGRID = false,
		SNAPTO = true,
		UPCLICKS = true,
		DOWNCLICKS = true,
		HIDDEN = true,
		LOCKBAR = true,
		TOOLTIPS = true,
		BINDTEXT = true,
		RANGEIND = true,
		CDTEXT = true,
		CDALPHA = true },
			false, 65)

	if not Neuron.isWoWClassic then
		--Neuron Zone Ability Bar
		Neuron:RegisterGUIOptions("ZoneAbilityBar", {
			AUTOHIDE = true,
			SHOWGRID = false,
			SNAPTO = true,
			UPCLICKS = true,
			DOWNCLICKS = true,
			HIDDEN = true,
			LOCKBAR = false,
			TOOLTIPS = true,
			BINDTEXT = true,
			COUNTTEXT = true,
			BORDERSTYLE = true,},
				false, 65)


		--Neuron Extra Bar
		Neuron:RegisterGUIOptions("ExtraBar", {
			AUTOHIDE = true,
			SHOWGRID = false,
			SNAPTO = true,
			UPCLICKS = true,
			DOWNCLICKS = true,
			HIDDEN = true,
			LOCKBAR = false,
			TOOLTIPS = true,
			BINDTEXT = true,
			COUNTTEXT = true,
			BORDERSTYLE = true,},
				false, 65)

		--Neuron Exit Bar
		Neuron:RegisterGUIOptions("ExitBar", {
			AUTOHIDE = true,
			SHOWGRID = false,
			SNAPTO = true,
			UPCLICKS = true,
			DOWNCLICKS = true,
			HIDDEN = true,
			LOCKBAR = false, },
				false, 65)
	end

end

function Neuron:CreateBarsAndButtons()

	if (DB.firstRun) then

		for barClass, barDefaults in pairs(NeuronDefaultBarOptions) do
			if Neuron.registeredBarData[barClass] then --only build default bars for registered bars types (Classic doesn't use all the bar types that Retail does)
				for i, defaults in ipairs(barDefaults) do --create the bar objects
					local newBar = Neuron.BAR.new(barClass, i) --this calls the bar constructor

					--create the default button objects for a given bar with the default values
					newBar:SetDefaults(defaults)

					for buttonID=1,#defaults.buttons do
						newBar.objTemplate.new(newBar, buttonID, defaults.buttons[buttonID]) --newBar.objTemplate is something like ACTIONBUTTON or EXTRABTN, we just need to code it agnostic
					end
				end
			end

		end

		DB.firstRun = false

	else

		for barClass, barClassData in pairs (Neuron.registeredBarData) do
			for id,data in pairs(barClassData.barDB) do
				if (data ~= nil) then
					local newBar = Neuron.BAR.new(barClass, id) --this calls the bar constructor

					--create all the saved button objects for a given bar
					for buttonID=1,#newBar.DB.buttons do
						newBar.objTemplate.new(newBar, buttonID) --newBar.objTemplate is something like ACTIONBUTTON or EXTRABTN, we just need to code it agnostic
					end
				end
			end
		end
	end

end