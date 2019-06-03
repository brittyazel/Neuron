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

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

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
		states = "[stance:0] stance0; [stance:1] stance1; [stance:2] stance2; [stance:3] stance3; [stance:4] stance4; [stance:5] stance5; [stance:6] stance6;",
		rangeStart = 1,
		rangeStop = 8,
		order = 2,
		localizedName = L["Stance"],
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
		modifier = "Vehicle",
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
		order = 20,
		localizedName = L["Outdoors"],
	},
	mounted = {
		modifier = "mounted",
		states = "[mounted] mounted1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 21,
		localizedName = L["Mounted"],
	},
	flying = {
		modifier = "flying",
		states = "[flying] flying1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 22,
		localizedName = L["Flying"],
	},
	help = {
		modifier = "help",
		states = "[help] help1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 23,
		localizedName = L["Help"],
	},
	harm = {
		modifier = "harm",
		states = "[harm] harm1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 24,
		localizedName = L["Harm"],
	},
	resting = {
		modifier = "resting",
		states = "[resting] resting1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 25,
		localizedName = L["Resting"],
	},
	swimming = {
		modifier = "swimming",
		states = "[swimming] swimming1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 26,
		localizedName = L["Swimming"],
	},
}
