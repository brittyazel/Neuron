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
--copyrights for Neuron are held by Britt Yazel, 2017-2020.

-- Hidden parent frame
local UIHider = CreateFrame("Frame")
UIHider:Hide()


local function disableBarFrame(frame)
	if frame then
		frame:UnregisterAllEvents()
		frame:SetParent(UIHider)
		frame:Hide()
	end
end

local function disableButtonFrame(frame)
	if frame then
		frame:UnregisterAllEvents()
		frame:SetAttribute("statehidden", true)
		frame:Hide()
	end
end

local function disableFrameSlidingAnimation(frame)
	if frame then
		local animation = {frame.slideOut:GetAnimations()}
		animation[1]:SetOffset(0,0)
	end
end

function Neuron:HideBlizzardUI()
	----------------------------
	----- Disable Buttons ------
	----------------------------
	--Hide and disable the individual buttons on most of our bars
	for i=1,12 do
		disableButtonFrame(_G["ActionButton"..i])
		disableButtonFrame(_G["MultiBarBottomLeftButton"..i])
		disableButtonFrame(_G["MultiBarBottomRightButton"..i])
		disableButtonFrame(_G["MultiBarRightButton"..i])
		disableButtonFrame(_G["MultiBarLeftButton"..i])
	end

	for i=1,6 do
		disableButtonFrame(_G["OverrideActionBarButton"..i])
	end

	disableButtonFrame(_G["ExtraActionButton1"])

	----------------------------
	------- Disable Bars -------
	----------------------------
	--disable main blizzard bar and graphics
	disableBarFrame(MainMenuBar)
	disableBarFrame(MainMenuBarArtFrame)
	disableBarFrame(MainMenuBarArtFrameBackground)
	disableFrameSlidingAnimation(MainMenuBar)

	--disable bottom bonus bars
	disableBarFrame(MultiBarBottomLeft)
	disableBarFrame(MultiBarBottomRight)

	--disable side bonus bars
	disableBarFrame(MultiBarLeft)
	disableBarFrame(MultiBarRight)

	--disable all other action bars
	disableBarFrame(MicroButtonAndBagsBar)
	disableBarFrame(StanceBarFrame)
	disableBarFrame(PossessBarFrame)
	disableBarFrame(MultiCastActionBarFrame)
	disableBarFrame(PetActionBarFrame)
	disableBarFrame(ZoneAbilityFrame)
	disableBarFrame(ExtraActionBarFrame)
	disableBarFrame(MainMenuBarVehicleLeaveButton)

	--disable status bars
	disableBarFrame(MainMenuExpBar)
	disableBarFrame(ReputationWatchBar)
	disableBarFrame(MainMenuBarMaxLevelBar)

	--disable override action bars
	disableBarFrame(OverrideActionBar)
	disableFrameSlidingAnimation(OverrideActionBar)

	----------------------------
	------- Disable Misc -------
	----------------------------
	--disable the ActionBarController to avoid potential for taint
	ActionBarController:UnregisterAllEvents()

	--disable the controller for status bars as we're going to handle this ourselves
	if StatusTrackingBarManager then
		StatusTrackingBarManager:Hide()
		StatusTrackingBarManager:UnregisterAllEvents()
	end

	--these two get called when opening the spellbook so it's best to just silence them ahead of time
	if not Neuron:IsHooked("MultiActionBar_ShowAllGrids") then
		Neuron:RawHook("MultiActionBar_ShowAllGrids", function() end, true)
	end
	if not Neuron:IsHooked("MultiActionBar_HideAllGrids") then
		Neuron:RawHook("MultiActionBar_HideAllGrids", function() end, true)
	end


	----------------------------
	----- Disable Tutorial -----
	----------------------------
	--it's important we shut down the tutorial or we will get a ton of errors
	--this cleanly shuts down the tutorial and returns visibility to all UI elements hidden
	if Tutorials then --the Tutorials table is only available during the tutorial scenario, ignore if otherwise
		Tutorials:Shutdown()
	end
end

function Neuron:ToggleBlizzUI()
	local DB = Neuron.db.profile

	if InCombatLockdown() then
		return
	end

	if DB.blizzbar == true then
		DB.blizzbar = false
		Neuron:HideBlizzardUI()
		StaticPopup_Show("ReloadUI")
	else
		DB.blizzbar = true
		StaticPopup_Show("ReloadUI")
	end
end

function Neuron:Overrides()
	local DB = Neuron.db.profile

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

	for _,v in ipairs(Neuron.BARIndex) do

		if v.barType == "StatusBar" then
			for _, button in ipairs(v.buttons) do
				if button.config.sbType == "cast" then
					disableDefaultCast = true
				elseif button.config.sbType == "mirror" then
					disableDefaultMirror = true
				end
			end
		end
	end

	if disableDefaultCast then
		disableBarFrame(CastingBarFrame)
	end

	if disableDefaultMirror then
		UIParent:UnregisterEvent("MIRROR_TIMER_START")
		disableBarFrame(MirrorTimer1)
		disableBarFrame(MirrorTimer2)
		disableBarFrame(MirrorTimer3)
	end

end