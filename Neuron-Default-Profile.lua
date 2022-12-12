-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local Array = addonTable.utilities.Array

addonTable.defaultProfile = {}

-----------------------------------
--------- Action Bar --------------
-----------------------------------
addonTable.defaultProfile.ActionBar = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 55,
		showGrid = true,
		multiSpec = true,
		vehicle = true,
		possess = true,
		dragonriding = true,
		override = true,

		buttons = Array.map(
			function(key) return { keys = { hotKeys = key, hotKeyText = key,}, } end,
			{ ":1:", ":2:", ":3:", ":4:", ":5:", ":6:", ":7:", ":8:", ":9:", ":0:", ":-:", ":=:",}
		),
	},

	[2] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 100,
		showGrid = true,

		buttons = Array.initialize(12, function() return {} end),
	}
}

-----------------------------------
--------- Zone Ability Bar --------
-----------------------------------
addonTable.defaultProfile.ZoneAbilityBar = {
	[1] = {
		hidestates = ":",
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		showGrid = false,
		point = "BOTTOM",
		x = 425,
		y = 75,
		border = true,

		buttons = Array.initialize(3, function() return {} end),
	}
}

-----------------------------------
--------- Extra Action Bar --------
-----------------------------------
addonTable.defaultProfile.ExtraBar = {
	[1] = {
		hidestates = ":",
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		showGrid = false,
		x = 0,
		y = 205,

		buttons = {
			[1] = {},
		},
	}
}

-----------------------------------
------------- XP Bar --------------
-----------------------------------

addonTable.defaultProfile.XPBar = {
	[1] = {
		showGrid = true,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 24,

		buttons = {
			[1] = {
				config = {cIndex = 2, lIndex = 6, rIndex = 4, mIndex = 3, width = 450},
			},
		},
	},

}

-----------------------------------
------------ Rep Bar --------------
-----------------------------------

addonTable.defaultProfile.RepBar = {

	[1] = {
		showGrid = true,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 7,

		buttons = {
			[1] = {
				config = {cIndex = 3, lIndex = 2, rIndex = 4, mIndex = 6, width = 450},
			},
		},
	},

}

-----------------------------------
----------- Cast Bar --------------
-----------------------------------

addonTable.defaultProfile.CastBar = {
	[1] = {
		showGrid = true,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 385,

		buttons = {
			[1] = {
				config = {cIndex = 1, lIndex = 2, rIndex = 3, showIcon = true},
			}
		},

	},
}

-----------------------------------
--------- Mirror Bar --------------
-----------------------------------

addonTable.defaultProfile.MirrorBar = {

	[1] = {
		showGrid = true,
		columns = 1,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "TOP",
		x = 0,
		y = -123,

		buttons = Array.initialize(
			3,
			function() return { config = {cIndex = 1, lIndex = 2, rIndex = 3}, } end
		),
	}
}

-----------------------------------
----------- Exit Bar --------------
-----------------------------------
addonTable.defaultProfile.ExitBar = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 305,

		buttons = {
			[1] = {},
		},
	}
}

-----------------------------------
------------ Pet Bar --------------
-----------------------------------
addonTable.defaultProfile.PetBar = {
	[1] = {
		hidestates = ":pet0:",
		showGrid = true,
		scale = 0.8,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = -500,
		y = 75,

		buttons = Array.initialize(10, function() return {} end),
	}
}

---For these two bars we have slightly different configs between classic and retail

-----------------------------------
----------- Menu Bar --------------
-----------------------------------
if Neuron.isWoWRetail then
	addonTable.defaultProfile.MenuBar = {
		[1] = {
			snapTo = false,
			snapToFrame = false,
			snapToPoint = false,
			point = "BOTTOMRIGHT",
			x = -357,
			y = 24,
			padH = 0,
			padV = 0,

			buttons = Array.initialize(11, function() return {} end),
		}
	}
else
	addonTable.defaultProfile.MenuBar = {
		[1] = {
			snapTo = false,
			snapToFrame = false,
			snapToPoint = false,
			point = "BOTTOMRIGHT",
			x = -370,
			y = 33,

			buttons = Array.initialize(#MICRO_BUTTONS, function() return {} end),
		}
	}
end

-----------------------------------
------------ Bag Bar --------------
-----------------------------------
if Neuron.isWoWRetail then
	addonTable.defaultProfile.BagBar = {
		[1] = {
			padH = 1,
			scale = 1.1,
			snapTo = false,
			snapToFrame = false,
			snapToPoint = false,
			point = "BOTTOMRIGHT",
			x = -125,
			y = 24,

			buttons = Array.initialize(Neuron.NUM_BAG_BUTTONS, function() return {} end),
		}
	}
else
	addonTable.defaultProfile.BagBar = {
		[1] = {
			padH = 4,
			scale = 1.1,
			snapTo = false,
			snapToFrame = false,
			snapToPoint = false,
			point = "BOTTOMRIGHT",
			x = -133,
			y = 24,

			buttons = Array.initialize(Neuron.NUM_BAG_BUTTONS, function() return {} end),
		}
	}
end
