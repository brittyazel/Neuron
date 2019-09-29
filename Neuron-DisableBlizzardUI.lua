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
--along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2018.

local hiddenFrame = CreateFrame('Frame', nil, UIParent, 'SecureFrameTemplate');
Neuron.hiddenFrame = hiddenFrame
hiddenFrame:Hide()



local function disableFrame(frame, unregisterEvents)

	if not frame then
		Neuron:Print('Unknown Frame', frame:GetName())
		return
	end

	frame:SetParent(hiddenFrame)

	if unregisterEvents then
		frame:UnregisterAllEvents()
	end
end

local function disableFrameSlidingAnimation(frame)

	if not frame then
		Neuron:Print('Unknown Frame', frame:GetName())
		return
	end

	local animation = (frame.slideOut:GetAnimations())

	animation:SetOffset(0, 0)
end


function Neuron:HideBlizzardUI()

	---the idea for this code is inspired from Dominos. Thanks Tuller!

	disableFrame(MainMenuBar, true)

	-- disable override bar transition animations
	disableFrameSlidingAnimation(MainMenuBar)
	disableFrame(MultiBarBottomLeft, true)
	disableFrame(MultiBarBottomRight, true)
	disableFrame(MultiBarLeft, true)
	disableFrame(MultiBarRight, true)
	disableFrame(MainMenuBarArtFrame, true)
	disableFrame(StanceBarFrame, true)
	disableFrame(PetActionBarFrame, true)
	disableFrame(MainMenuBarVehicleLeaveButton, true)
	disableFrame(MainMenuBarPerformanceBar)

	if not Neuron.isWoWClassic then
		disableFrameSlidingAnimation(OverrideActionBar)
		disableFrame(PossessBarFrame, true)
		disableFrame(MicroButtonAndBagsBar, true)
		disableFrame(MultiCastActionBarFrame, true)
		disableFrame(ExtraActionBarFrame, true)
		disableFrame(ZoneAbilityFrame, true)

		StatusTrackingBarManager:UnregisterAllEvents()
	end


	ActionBarController:UnregisterAllEvents()


	--this is the equivalent of dropping a sledgehammer on the taint issue. It protects from taint and saves CPU cycles though so....
	if (not Neuron:IsHooked('ActionButton_OnEvent')) then
		Neuron:RawHook('ActionButton_OnEvent', function() end, true)
	end

	if (not Neuron:IsHooked('ActionButton_Update')) then
		Neuron:RawHook('ActionButton_Update', function() end, true)
	end

	if (not Neuron:IsHooked('MultiActionBar_Update')) then
		Neuron:RawHook('MultiActionBar_Update', function() end, true)
	end

	if (not Neuron:IsHooked('ActionButton_HideGrid')) then
		Neuron:RawHook('ActionButton_HideGrid', function() end, true)
	end

	if (not Neuron:IsHooked('ActionButton_ShowGrid')) then
		Neuron:RawHook('ActionButton_ShowGrid', function() end, true)
	end

	if (not Neuron:IsHooked('PetActionBar_Update')) then
		Neuron:RawHook('PetActionBar_Update', function() end, true)
	end

	if not Neuron.isWoWClassic then
		if (not Neuron:IsHooked('OverrideActionBar_UpdateSkin')) then
			Neuron:RawHook('OverrideActionBar_UpdateSkin', function() end, true)
		end
	end

end



function Neuron:ToggleBlizzUI()

	local DB = Neuron.db.profile

	if (InCombatLockdown()) then
		return
	end

	if (DB.blizzbar == true) then
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