-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
addonTable.utilities = addonTable.utilities or {}

local LATEST_DB_VERSION = 1.4

------------------------------------------------------------
--------------------Data Fixing Functions-------------------
------------------------------------------------------------

---@return number @returns the database version number
local function dbVersion(db)
	if db.DBVersion then
		return db.DBVersion
	end

	--we need to know if a profile doesn't have a DBVersion because it is brand new, or because it pre-dates DB versioning
	--if it predates versioning, then we assign it to be 1.0, if it's new, then 0
	--"NeuronCDB" is just a random table value that no longer exists. It's not important aside from the fact it no longer exists
	if db.NeuronCDB then
		return 1.0
	else
		return 0
	end
end

---this function does everything in place, so give it a copy of the database
---to work with, instead of the original. and don't bikeshed this code! it
---works as far as we know and will be annoying to test.
local function ogFixer(profile)
	local oldDBVersion = profile.DBVersion
	-- this file loads before we setup the addon with ace, so don't init at file level
	local Neuron = addonTable.Neuron
	---Added on 8/25/2018. Remove at some point in the future
	---The purpose of this migration was to rename many of the DB tables to values that make more sense
	if oldDBVersion < 1.1 then --this is the first of many DB fixes. This should be run first before the rest to migrate us into the DBVersion 1.1 state

		local barDBLocationsName = {"bagbar", "menubar", "petbar", "statusbar", "extrabar", "zoneabilitybar", "exitbar" }
		local btnDBLocationsName = {"bagbtn", "menubtn", "petbtn", "statusbtn", "extrabtn", "zoneabilitybtn", "exitbtn" }

		local old_barDBLocationsName = {"bagbars", "menubars", "petbars", "statusbars", "xbars", "zoneabilitybars", "exitbars" }
		local old_btnDBLocationsName = {"bagbtns", "menubtns", "petbtns", "statusbtns", "xbtns", "zoneabilitybtns", "exitbtns" }

		for i = 1,7 do
			if profile["NeuronCDB"][old_barDBLocationsName[i]] then
				profile["NeuronCDB"][barDBLocationsName[i]] = CopyTable(profile["NeuronCDB"][old_barDBLocationsName[i]])
				profile["NeuronCDB"][old_barDBLocationsName[i]] = nil
			end

			if profile["NeuronCDB"][old_btnDBLocationsName[i]] then
				profile["NeuronCDB"][btnDBLocationsName[i]] = CopyTable(profile["NeuronCDB"][old_btnDBLocationsName[i]])
				profile["NeuronCDB"][old_btnDBLocationsName[i]] = nil
			end
		end

		profile["NeuronCDB"]["extrabarFirstRun"] = profile["NeuronCDB"]["xbarFirstRun"]
		profile["NeuronCDB"]["xbarFirstRun"] = nil

		oldDBVersion = 1.1 --increment oldDBVersion up to the latest that this set of code fixes
		Neuron:Print("Neuron database migrated to version " .. 1.1)
	end


	---Added on 8/26/2018. Remove at some point in the future
	---The purpose of this migrate is to get rid of the GDB/CDB divide
	---this code takes everything that was in the NeuronCDB and NeuronGDB databases and merges them with all their contents taking the top level
	if oldDBVersion < 1.2 then
		for k1,v1 in pairs(profile.NeuronGDB) do
			if k1 == "bars" or k1 == "buttons" or k1 == "throttle" or k1 == "timerLimit" or k1 == "snapToTol" or k1 == "blizzbar" or k1 == "firstRun" or k1 == "NeuronIcon" then
				profile[k1] = v1
			end
		end

		for k1,v1 in pairs(profile.NeuronCDB) do
			if k1 ~= "bars" and k1 ~= "buttons" then
				profile[k1] = v1
			end
		end

		if not profile.bars then
			profile.bars = {}
		end

		for k1,v1 in pairs(profile.NeuronCDB.bars) do
			if not profile.bars[k1] then
				profile.bars[k1] = {}
			end

			for k2,v2 in pairs(v1) do
				profile.bars[k1][k2] = v2
			end
		end

		if not profile.buttons then
			profile.buttons = {}
		end

		for k1,v1 in pairs(profile.NeuronCDB.buttons) do
			if not profile.buttons[k1] then
				profile.buttons[k1] = {}
			end

			for k2,v2 in pairs(v1) do
				profile.buttons[k1][k2] = v2
			end
		end

		oldDBVersion = 1.2 --increment oldDBVersion up to the latest that this set of code fixes
		Neuron:Print("Neuron database migrated to version " .. 1.2)
	end


	---Added on 12/19/2018. Remove at some point in the future
	---The purpose of this migrate is to get rid of the GDB/CDB divide
	---this code takes separate bar and button tables, and nests the buttons into their corresponding bars
	if oldDBVersion < 1.3 then
		local oldBarDBNames = {"bars", "zoneabilitybar", "extrabar", "bagbar", "statusbar", "exitbar", "menubar", "petbar"}
		local oldBtnDBNames = {"buttons", "zoneabilitybtn", "extrabtn", "bagbtn", "statusbtn", "exitbtn", "menubtn", "petbtn"}
		local NewBarDBNames = {"ActionBar", "ZoneAbilityBar", "ExtraBar", "BagBar", "StatusBar", "ExitBar", "MenuBar", "PetBar"}

		--copy over all the bar data into the new bar tables
		for i, barDBName in ipairs(oldBarDBNames) do
			if profile[barDBName] then
				for k,v in pairs(profile[barDBName]) do
					if not profile[NewBarDBNames[i]] then
						profile[NewBarDBNames[i]] = {}
					end

					profile[NewBarDBNames[i]][k] = v
				end
			end
		end

		--copy over all of the button data to their corresponding bars
		for i, barDBName in ipairs(NewBarDBNames) do
			if profile[oldBarDBNames[i]] then
				for j, v2 in ipairs(profile[barDBName]) do
					for k, v3 in ipairs(v2.objectList) do
						if not profile[barDBName][j].buttons then
							profile[barDBName][j].buttons = {}
						end

						if profile[oldBtnDBNames[i]][v3] then
							table.insert(profile[barDBName][j].buttons, CopyTable(profile[oldBtnDBNames[i]][v3]))
						end
					end
				end
			end
		end

		oldDBVersion = 1.3 --increment oldDBVersion up to the latest that this set of code fixes
		Neuron:Print("Neuron database migrated to version " .. 1.3)
	end

	profile.DBVersion = 1.3
	return profile
end

-- this is when we made enabling/disabling neuron/blizzard ui
-- components more granular--eg, enable cast bar but not rep bar
local function migrate1_3To1_4(profile)
	local newProfile = CopyTable(profile)
	local blizzbar = profile.blizzbar
	newProfile.blizzBars = {
		ActionBar = blizzbar,
		ExtraBar = blizzbar,
		ExitBar = blizzbar,
		BagBar = blizzbar,
		ZoneAbilityBar = blizzbar,
		MenuBar = blizzbar,
		PetBar = blizzbar,
		XPBar = blizzbar,
		RepBar = blizzbar,
		CastBar = blizzbar,
		MirrorBar = blizzbar,
	}

	newProfile.blizzBar = nil
	newProfile.DBVersion = 1.4
	return newProfile
end

local function profileMigrate(profileDatabase)
	if profileDatabase.DBVersion < 1.3 then
		-- we need to copy the table for the og fixer, since it modifies in place
		return profileMigrate(ogFixer(CopyTable(profileDatabase)))
	elseif profileDatabase.DBVersion == 1.3 then
		-- TODO: call this recursively, once we actually bump the database version
		return migrate1_3To1_4(profileDatabase)
	else
		return profileDatabase
	end
end

local function loadingDatabaseFailed(DB)
	StaticPopupDialogs["Profile_Migration_Failed"] = {
		text = "We are sorry, but your Neuron profile migration has failed. By clicking accept you agree to reset your current profile to the its default values.",
		button1 = ACCEPT,
		button2 = CANCEL,
		timeout = 0,
		whileDead = true,
		OnAccept = function() DB:ResetProfile() end,
		OnCancel = function() DisableAddOn("Neuron"); ReloadUI() end,
	}
	StaticPopup_Show("Profile_Migration_Failed")
end

local function databaseMigration(DB)
	local currentVersion = dbVersion(DB.profile)

	-- make sure that the database has a version, even if it predates them
	DB.profile.DBVersion = DB.profile.DBVersion or currentVersion

	if currentVersion == 0 then
		DB:ResetProfile()
		DB.profile.DBVersion = LATEST_DB_VERSION
	elseif currentVersion < LATEST_DB_VERSION then
		local success, newProfile = pcall(profileMigrate, DB.profile)
		if success then
			DB.profile = newProfile
		else
			loadingDatabaseFailed(DB)
		end
	end

	--run again to re-register all of our wildcard ['*'] tables back in the newly shifted DB
	return LibStub("AceDB-3.0"):New("NeuronProfilesDB", addonTable.databaseDefaults)
end

addonTable.utilities.DBFixer = {databaseMigration=databaseMigration}
