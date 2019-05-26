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

---**NOTE** values assigned with empty quotes, i.e. name = "", basically don't exist. Lua treats them as nil

local genericButtonData = {
	btnType = "macro",
}


local genericSpecData = {
	actionID = false,

	macro_Text = "",
	macro_Icon = false,
	macro_Name = "",
	macro_Auto = false,
	macro_Watch = false,
	macro_Equip = false,
	macro_Note = "",
	macro_UseNote = false,
}

local genericXPBtnData= {

	curXPType = "player_xp",

	width = 450,
	height = 18,
	scale = 1,
	XOffset = 0,
	YOffset = 0,
	texture = 7,
	border = 1,

	orientation = 1,

	cIndex = 2,
	cColor = {1,1,1,1},

	lIndex = 6,
	lColor = {1,1,1,1},

	rIndex = 4,
	rColor = {1,1,1,1},

	mIndex = 3,
	mColor = {1,1,1,1},

	tIndex = 1,
	tColor = {1,1,1,1},

	bordercolor = {1,1,1,1},

	norestColor = {1,0,1,1},
	restColor = {0,0,1,1},
}

local genericRepBtnData= {

	repID = 2,
	autoWatch = 2,
	unit = 2,

	width = 450,
	height = 18,
	scale = 1,
	XOffset = 0,
	YOffset = 0,
	texture = 7,
	border = 1,

	orientation = 1,

	cIndex = 3,
	cColor = {1,1,1,1},

	lIndex = 2,
	lColor = {1,1,1,1},

	rIndex = 4,
	rColor = {1,1,1,1},

	mIndex = 6,
	mColor = {1,1,1,1},

	tIndex = 1,
	tColor = {1,1,1,1},

	bordercolor = {1,1,1,1},
}

local genericCastBtnData= {

	width = 250,
	height = 18,
	scale = 1,
	XOffset = 0,
	YOffset = 0,
	texture = 7,
	border = 1,

	orientation = 1,

	cIndex = 1,
	cColor = {1,1,1,1},

	lIndex = 2,
	lColor = {1,1,1,1},

	rIndex = 3,
	rColor = {1,1,1,1},

	mIndex = 1,
	mColor = {1,1,1,1},

	tIndex = 1,
	tColor = {1,1,1,1},

	bordercolor = {1,1,1,1},

	castColor = {1,0.7,0,1},
	channelColor = {0,1,0,1},
	successColor = {0,1,0,1},
	failColor = {1,0,0,1},

	showIcon = true,
}

local genericMirrorBtnData= {

	width = 250,
	height = 18,
	scale = 1,
	XOffset = 0,
	YOffset = 0,
	texture = 7,
	border = 1,

	orientation = 1,

	cIndex = 1,
	cColor = {1,1,1,1},

	lIndex = 2,
	lColor = {1,1,1,1},

	rIndex = 3,
	rColor = {1,1,1,1},

	mIndex = 1,
	mColor = {1,1,1,1},

	tIndex = 1,
	tColor = {1,1,1,1},

	bordercolor = {1,1,1,1},

}


local genericKeyData = {
	hotKeyLock = false,
	hotKeyPri = false,
	hotKeyText = ":",
	hotKeys = ":"
}


local genericBarData = {
	name = ":",

	buttons = {
		['*'] = {
			['config'] = CopyTable(genericButtonData),
			['keys'] = CopyTable(genericKeyData),
			['data'] = {},
		}
	},

	hidestates = ":",

	point = "BOTTOM",
	x = 0,
	y = 190,

	scale = 1,
	shape = 1,
	columns = false,

	alpha = 1,
	alphaUp = 1,
	alphaMax = 1,
	fadeSpeed = 0.5,

	strata = 3,

	padH = 0,
	padV = 0,
	arcStart = 0,
	arcLength = 359,

	snapTo = false,
	snapToPad = 0,
	snapToPoint = false,
	snapToFrame = false,

	autoHide = false,
	showGrid = true,

	bindColor = {1,1,1,1},
	macroColor = {1,1,1,1},
	countColor = {1,1,1,1},
	cdcolor1 = {1,0.82,0,1},
	cdcolor2 = {1,0.1,0.1,1},
	buffcolor = {0,0.8,0,1},
	debuffcolor = {0.8,0,0,1},
	rangecolor = {0.7,0.15,0.15,1},
	manacolor = {0.5,0.5,1.0,1},

	border = true,

	upClicks = true,
	downClicks = false,

	conceal = false,

	multiSpec = false,

	spellGlow = "default",

	barLock = false,

	tooltips = true,
	tooltipsEnhanced = true,
	tooltipsCombat = false,

	bindText = true,
	macroText = true,
	countText = true,
	rangeInd = true,

	cdText = false,
	cdAlpha = 1,
	auraInd = false,

	showBorderStyle = true,

	homestate = true,
	paged = false,
	stance = false,
	stealth = false,
	reaction = false,
	combat = false,
	group = false,
	pet = false,
	fishing = false,
	vehicle = false,
	possess = false,
	override = false,
	extrabar = false,
	alt = false,
	ctrl = false,
	shift = false,
	target = false,

	selfCast = false,
	focusCast = false,
	rightClickTarget = false,
	mouseOverCast = false,

	custom = false,
	customRange = false,
	customNames = false,

	remap = false,
}



------------------------------------------------------------------------
----------------------MAIN TABLE----------------------------------------
------------------------------------------------------------------------

NeuronDefaults = {
	profile = {
		blizzbar = false,

		mouseOverMod= "NONE",

		firstRun = true,

		NeuronItemCache = {},
		NeuronSpellCache = {},
		NeuronCollectionCache = {},
		NeuronToyCache = {},

		NeuronIcon = {hide = false,},

		ActionBar = {
			['*'] = CopyTable(genericBarData)
		},

		ExtraBar = {
			['*'] = CopyTable(genericBarData)
		},

		ExitBar ={
			['*'] = CopyTable(genericBarData)
		},

		BagBar = {
			['*'] = CopyTable(genericBarData)
		},

		ZoneAbilityBar = {
			['*'] = CopyTable(genericBarData)
		},

		MenuBar = {
			['*'] = CopyTable(genericBarData)
		},

		PetBar = {
			['*'] = CopyTable(genericBarData)
		},

		XPBar = {
			['*'] = CopyTable(genericBarData)
		},

		RepBar = {
			['*'] = CopyTable(genericBarData)
		},

		CastBar = {
			['*'] = CopyTable(genericBarData)
		},

		MirrorBar = {
			['*'] = CopyTable(genericBarData)
		},
	}
}

------------------------------------------------------------------------------


NeuronDefaults.profile.ActionBar['*'].buttons = {
	['*'] = {
		['config'] = CopyTable(genericButtonData),
		['keys'] = CopyTable(genericKeyData),
		[1] = {['**'] = CopyTable(genericSpecData), ['homestate'] = {}},
		[2] = {['**'] = CopyTable(genericSpecData), ['homestate'] = {}},
		[3] = {['**'] = CopyTable(genericSpecData), ['homestate'] = {}},
		[4] = {['**'] = CopyTable(genericSpecData), ['homestate'] = {}},
	}
}

NeuronDefaults.profile.RepBar['*'].buttons ={
	['*'] = {
		['config'] = CopyTable(genericRepBtnData),
		['keys'] = CopyTable(genericKeyData),
	}
}

NeuronDefaults.profile.XPBar['*'].buttons ={
	['*'] = {
		['config'] = CopyTable(genericXPBtnData),
		['keys'] = CopyTable(genericKeyData),
	}
}

NeuronDefaults.profile.CastBar['*'].buttons ={
	['*'] = {
		['config'] = CopyTable(genericCastBtnData),
		['keys'] = CopyTable(genericKeyData),
	}
}

NeuronDefaults.profile.MirrorBar['*'].buttons ={
	['*'] = {
		['config'] = CopyTable(genericMirrorBtnData),
		['keys'] = CopyTable(genericKeyData),
	}
}