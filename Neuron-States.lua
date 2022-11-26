-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

function Neuron.UpdateStanceStrings()
	Neuron.STATES = {
		homestate = L["Home State"],
		laststate = L["Last State"],
		paged1 = L["Page 1"],
		paged2 = L["Page 2"],
		paged3 = L["Page 3"],
		paged4 = L["Page 4"],
		paged5 = L["Page 5"],
		paged6 = L["Page 6"],
		pet0 = L["No Pet"],
		pet1 = L["Pet Exists"],
		alt0 = L["Alt Up"],
		alt1 = L["Alt Down"],
		ctrl0 = L["Control Up"],
		ctrl1 = L["Control Down"],
		shift0 = L["Shift Up"],
		shift1 = L["Shift Down"],
		stance0 = L["Default"],
		stealth0 = L["No Stealth"],
		stealth1 = L["Stealth"],
		reaction0 = L["Friendly"],
		reaction1 = L["Hostile"],
		combat0 = L["Out of Combat"],
		combat1 = L["In Combat"],
		group0 = L["No Group"],
		group1 = L["Group: Raid"],
		group2 = L["Group: Party"],
		fishing0 = L["No Fishing Pole"],
		fishing1 = L["Fishing Pole"],
		vehicle0 = L["No Vehicle"],
		vehicle1 = L["Vehicle"],
		possess0 = L["No Possess"],
		possess1 = L["Possess"],
		override0 = L["No Override Bar"],
		override1 = L["Override Bar"],
		extrabar0 = L["No Extra Bar"],
		extrabar1 = L["Extra Bar"],
		custom0 = L["Custom States"],
		target0 = L["Has Target"],
		target1 = L["No Target"],
	}


	--- this is actually a lot of classes. rogues stealth, paladins have
	--- devo aura, priests have shadowform, etc
	for i=1,GetNumShapeshiftForms() do
		local _, _, _, spellID = GetShapeshiftFormInfo(i)
		Neuron.STATES["stance"..i] = GetSpellInfo(spellID) --Get the string name of the shapeshift form (now that shapeshifts are considered spells)
	end

	-- Caster Form is special cased just because that's the way it's been historically
	if Neuron.class == "DRUID" then
		Neuron.STATES["stance0"] = L["Caster Form"]
	end

	-- stealth shows up with the GetShapeshiftFormInfo, but not the others
	-- Melee is special cased just because that's the way it's been historically
	if Neuron.class == "ROGUE" then
		Neuron.STATES["stance0"] = L["Melee"]
		Neuron.STATES["stance2"] = L["Vanish"]
		Neuron.STATES["stance3"] = L["Shadow Dance"] --for Subelty Rogues
	end


	-- the "states" field is a macro conditional. it will pass the result of the
	-- conditional as "newstate" into the attribute driver
	-- See "RegisterAttributeDriver" and "SetAttribute"
	-- example: if a priest is in shadowform (stance1) then
	-- "[stance0] noshadow; [stance1] shadow" will make newstate="shadow"
	Neuron.MANAGED_BAR_STATES = {

		paged = {
			modifier = "paged",
			homestate = "paged1",
			states = "[bar:1] paged1; [bar:2] paged2; [bar:3] paged3; [bar:4] paged4; [bar:5] paged5; [bar:6] paged6",
			rangeStart = 2,
			rangeStop = 6,
			order = 1,
			localizedName = L["Paged"],
		},

		stance = {
			modifier = "stance",
			homestate = "stance0",
			-- the class with the maximum "stances" is the druid with 6. no need for more than this
			states = "[stance:0] stance0; [stance:1] stance1; [stance:2] stance2; [stance:3] stance3; [stance:4] stance4; [stance:5] stance5; [stance:6] stance6;",
			rangeStart = 1,
			rangeStop = 8,
			order = 2,
			localizedName =
				(Neuron.class == "ROGUE" and L["Stealth"]) or
				(Neuron.class == "DRUID" and L["Shapeshift"]) or
				(Neuron.class == "SHAMAN" and L["Shapeshift"]) or
				L["Stance"],
		},

		pet = {
			modifier = "pet",
			homestate = "pet1",
			states = "[nopet] pet1; [@pet,exists,nodead] pet2",
			rangeStart = 2,
			rangeStop = 3,
			order = 3,
			localizedName = L["Pet"],
		},

		alt = {
			modifier = "alt",
			states = "[mod:alt] alt1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 4,
			localizedName = L["Alt"],
		},

		ctrl = {
			modifier = "ctrl",
			states = "[mod:ctrl] ctrl1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 5,
			localizedName = L["Ctrl"],
		},

		shift = {
			modifier = "shift",
			states = "[mod:shift] shift1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 6,
			localizedName = L["Shift"],
		},

		stealth = {
			modifier = "stealth",
			states = "[stealth] stealth1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 7,
			localizedName = L["Stealth"],
		},

		reaction = {
			modifier = "reaction",
			states = "[@target,harm] reaction1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 8,
			localizedName = L["Reaction"],
		},

		vehicle = {
			modifier = "vehicle",
			states = "[vehicleui] vehicle1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 9,
			localizedName = L["Vehicle"],
		},

		group = {
			modifier = "group",
			states = "[group:raid] group1; [group:party] group2; laststate",
			rangeStart = 1,
			rangeStop = 2,
			order = 10,
			localizedName = L["Group"],
		},

		fishing = {
			modifier = "fishing",
			states = "[worn:fishing poles] fishing1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 11,
			localizedName = L["Fishing"],
		},

		custom = {
			modifier = "custom",
			states = "",
			rangeStart = 1,
			rangeStop = 1,
			order = 12,
			localizedName = L["Custom"],
		},

		combat = {
			modifier = "combat",
			states = "[combat] combat1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 13,
			localizedName = L["Combat"],
		},

		possess = {
			modifier = "possess",
			states = "[possessbar] possess1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 14,
			localizedName = L["Possess"],
		},

		override = {
			modifier = "override",
			states = "[overridebar] override1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 15,
			localizedName = L["Override"],
		},

		extrabar = {
			modifier = "extrabar",
			states = "[extrabar] extrabar1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 16,
			localizedName = L["Extrabar"],
		},

		target = {
			modifier = "target",
			states = "[exists] target1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 17,
			localizedName = L["Target"],
		},
		indoors = {
			modifier = "indoors",
			states = "[indoors] indoors1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 18,
			localizedName = L["Indoors"],
		},
		outdoors = {
			modifier = "outdoors",
			states = "[outdoors] outdoors1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 19,
			localizedName = L["Outdoors"],
		},
		mounted = {
			modifier = "mounted",
			states = "[mounted] mounted1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 20,
			localizedName = L["Mounted"],
		},
		flying = {
			modifier = "flying",
			states = "[flying] flying1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 21,
			localizedName = L["Flying"],
		},
		help = {
			modifier = "help",
			states = "[help] help1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 22,
			localizedName = L["Help"],
		},
		harm = {
			modifier = "harm",
			states = "[harm] harm1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 23,
			localizedName = L["Harm"],
		},
		resting = {
			modifier = "resting",
			states = "[resting] resting1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 24,
			localizedName = L["Resting"],
		},
		swimming = {
			modifier = "swimming",
			states = "[swimming] swimming1; laststate",
			rangeStart = 1,
			rangeStop = 1,
			order = 25,
			localizedName = L["Swimming"],
		},
	}
end
