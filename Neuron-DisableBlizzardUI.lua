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


local function disableFrame(frame, leaveEvents)
	if frame then
		if not leaveEvents then
			frame:UnregisterAllEvents()
		end

		frame:SetParent(UIHider)
		frame:Hide()
	end
end

local function disableFrameSlidingAnimation(frame)
	if frame then
		local animation = {frame.slideOut:GetAnimations()}
		animation[1]:SetOffset(0,0)
	end
end

---Some of this code logic is adapted from Bartender4 and Dominos and credit should go to those authors.
---The Bartender4 and Dominos logic was slimmed down and modified to fit Neuron.
---Thanks guys! Beer's on us.
function Neuron:HideBlizzardUI()
	--Hide and disable the individual buttons on most of our bars
	for i=1,12 do
		_G["ActionButton"..i]:Hide()
		_G["ActionButton"..i]:UnregisterAllEvents()
		_G["ActionButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomLeftButton"..i]:Hide()
		_G["MultiBarBottomLeftButton"..i]:UnregisterAllEvents()
		_G["MultiBarBottomLeftButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomRightButton"..i]:Hide()
		_G["MultiBarBottomRightButton"..i]:UnregisterAllEvents()
		_G["MultiBarBottomRightButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarRightButton"..i]:Hide()
		_G["MultiBarRightButton"..i]:UnregisterAllEvents()
		_G["MultiBarRightButton"..i]:SetAttribute("statehidden", true)

		_G["MultiBarLeftButton"..i]:Hide()
		_G["MultiBarLeftButton"..i]:UnregisterAllEvents()
		_G["MultiBarLeftButton"..i]:SetAttribute("statehidden", true)
	end

	for i=1,6 do
		_G["OverrideActionBarButton"..i]:Hide()
		_G["OverrideActionBarButton"..i]:UnregisterAllEvents()
		_G["OverrideActionBarButton"..i]:SetAttribute("statehidden", true)
	end

	--disable main blizzard bar and graphics
	disableFrame(MainMenuBar)
	disableFrame(MainMenuBarArtFrame)
	disableFrame(MainMenuBarArtFrameBackground)

	--disable bottom bonus bars
	disableFrame(MultiBarBottomLeft)
	disableFrame(MultiBarBottomRight)

	--disable right-side bonus bars
	disableFrame(MultiBarLeft)
	disableFrame(MultiBarRight)

	--disable all other action bars
	disableFrame(MicroButtonAndBagsBar)
	disableFrame(StanceBarFrame)
	disableFrame(PossessBarFrame)
	disableFrame(MultiCastActionBarFrame)
	disableFrame(PetActionBarFrame)
	disableFrame(ZoneAbilityFrame)
	disableFrame(ExtraActionBarFrame)
	disableFrame(MainMenuBarVehicleLeaveButton)

	--disable status bars
	disableFrame(MainMenuExpBar)
	disableFrame(ReputationWatchBar)
	disableFrame(MainMenuBarMaxLevelBar)

	disableFrameSlidingAnimation(MainMenuBar)
	disableFrameSlidingAnimation(OverrideActionBar)

	--disable the ActionBarController to avoid potential for taint
	ActionBarController:UnregisterAllEvents()

	--disable the controller for status bars as we're going to handle this ourselves
	if StatusTrackingBarManager then
		StatusTrackingBarManager:Hide()
		StatusTrackingBarManager:UnregisterAllEvents()
	end

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

end