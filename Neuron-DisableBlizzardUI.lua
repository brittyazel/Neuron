-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

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
	if frame and frame.slideOut then
		local animation = {frame.slideOut:GetAnimations()}
		animation[1]:SetOffset(0,0)
	end
end

function Neuron:HideBlizzardUI(profileDatabase)
	local blizzBars = profileDatabase.blizzBars
	----------------------------
	----- Disable Buttons ------
	----------------------------
	--Hide and disable the individual buttons on most of our bars
	if not blizzBars.ActionBar then
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
		disableBarFrame(MultiBar5)
		disableBarFrame(MultiBar6)
		disableBarFrame(MultiBar7)

		disableBarFrame(StanceBar)
		disableBarFrame(StanceBarFrame)
		disableBarFrame(PossessBar)
		disableBarFrame(PossessBarFrame)


		disableBarFrame(OverrideActionBar)
		disableFrameSlidingAnimation(OverrideActionBar)

		-- i think this is the shaman bar, it seems like it was deprecated in cata
		-- just leave it on always https://github.com/brittyazel/Neuron/issues/444
		-- disableBarFrame(MultiCastActionBarFrame)

		--disable the ActionBarController to avoid potential for taint
		ActionBarController:UnregisterAllEvents()

		--these two get called when opening the spellbook so it's best to just silence them ahead of time
		if not Neuron:IsHooked("MultiActionBar_ShowAllGrids") then
			Neuron:RawHook("MultiActionBar_ShowAllGrids", function() end, true)
		end
		if not Neuron:IsHooked("MultiActionBar_HideAllGrids") then
			Neuron:RawHook("MultiActionBar_HideAllGrids", function() end, true)
		end
	end
	if not blizzBars.BagBar and not blizzBars.MenuBar then
		-- i think this contains bags and micro buttons?
		-- but it hides them both if it hides one
		disableBarFrame(MicroButtonAndBagsBar)
	end
	if not blizzBars.BagBar then
		--hide the weird color border around bag bars
		--[[
		CharacterReagentBag0Slot.IconBorder:Hide()
		CharacterBag0Slot.IconBorder:Hide()
		CharacterBag1Slot.IconBorder:Hide()
		CharacterBag2Slot.IconBorder:Hide()
		CharacterBag3Slot.IconBorder:Hide()


		--overwrite the Show function with a null function because it keeps coming back and won't stay hidden
		if not Neuron:IsHooked(CharacterReagentBag0Slot.IconBorder, "Show") then
			Neuron:RawHook(CharacterBag0Slot.IconBorder, "Show", function() end, true)
		end
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
		]]
	end
	if not blizzBars.CastBar then
		if Neuron.isWoWRetail then
			PlayerCastingBarFrame:UnregisterAllEvents()
			PlayerCastingBarFrame:SetParent(Neuron.hiddenFrame)
		else
			CastingBarFrame:UnregisterAllEvents()
			CastingBarFrame:SetParent(Neuron.hiddenFrame)
		end
	end
	if not blizzBars.ExitBar then
		disableBarFrame(MainMenuBarVehicleLeaveButton)
	end
	if not blizzBars.ExtraBar then
		disableButtonFrame(_G["ExtraActionButton1"])
		disableBarFrame(ExtraAbilityContainer)
		disableBarFrame(ExtraActionBarFrame)
	end
	if not blizzBars.MenuBar then
		-- we don't actually want to disable these, we will just reparent them

		--[[
		disableButtonFrame(CharacterMicroButton)
		disableButtonFrame(SpellbookMicroButton)
		disableButtonFrame(TalentMicroButton)
		disableButtonFrame(AchievementMicroButton)
		disableButtonFrame(QuestLogMicroButton)
		disableButtonFrame(GuildMicroButton)
		disableButtonFrame(GroupFinderMicroButton)
		disableButtonFrame(CollectionsMicroButton)
		disableButtonFrame(EJMicroButton)
		disableButtonFrame(StoreMicroButton)
		disableButtonFrame(MainMenuMicroButton)
		]]
	end
	if not blizzBars.MirrorBar then
		UIParent:UnregisterEvent("MIRROR_TIMER_START")
		MirrorTimer1:UnregisterAllEvents()
		MirrorTimer1:SetParent(Neuron.hiddenFrame)
		MirrorTimer2:UnregisterAllEvents()
		MirrorTimer2:SetParent(Neuron.hiddenFrame)
		MirrorTimer3:UnregisterAllEvents()
		MirrorTimer3:SetParent(Neuron.hiddenFrame)
	end
	if not blizzBars.PetBar then
		disableBarFrame(PetActionBar)
		disableBarFrame(PetActionBarFrame)
	end
	if not blizzBars.RepBar then
		disableBarFrame(ReputationWatchBar)

		--disable the controller for status bars as we're going to handle this ourselves
		if StatusTrackingBarManager then
			StatusTrackingBarManager:Hide()
			StatusTrackingBarManager:UnregisterAllEvents()
		end
	end
	if not blizzBars.XPBar then
		disableBarFrame(MainMenuExpBar)
		disableBarFrame(MainMenuBarMaxLevelBar)

		--disable the controller for status bars as we're going to handle this ourselves
		if StatusTrackingBarManager then
			StatusTrackingBarManager:Hide()
			StatusTrackingBarManager:UnregisterAllEvents()
		end
	end
	if not blizzBars.ZoneAbilityBar then
		disableBarFrame(ZoneAbilityFrame)
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

function Neuron:ToggleBlizzUI(blizzBars)
	if InCombatLockdown() then
		return
	end

	if blizzBars then
		local DB = Neuron.db.profile
		DB.blizzBars = CopyTable(DB.blizzBars)
		MergeTable(DB.blizzBars, blizzBars)
	end
end
