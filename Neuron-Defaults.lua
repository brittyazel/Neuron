-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

Neuron.DefaultBarOptions = {}

addonTable.defaultBarOptions = {}

-----------------------------------
--------- Action Bar --------------
-----------------------------------
addonTable.defaultBarOptions.ActionBar = {
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
		override = true,

		buttons = {
			[1] = {
				keys = { hotKeys = ":1:", hotKeyText = ":1:",},
			},
			[2] = {
				keys = { hotKeys = ":2:", hotKeyText = ":2:",},
			},
			[3] = {
				keys = { hotKeys = ":3:", hotKeyText = ":3:",},
			},
			[4] = {
				keys = { hotKeys = ":4:", hotKeyText = ":4:",},
			},
			[5] = {
				keys = { hotKeys = ":5:", hotKeyText = ":5:",},
			},
			[6] = {
				keys = { hotKeys = ":6:", hotKeyText = ":6:",},
			},
			[7] = {
				keys = { hotKeys = ":7:", hotKeyText = ":7:",},
			},
			[8] = {
				keys = { hotKeys = ":8:", hotKeyText = ":8:",},
			},
			[9] = {
				keys = { hotKeys = ":9:", hotKeyText = ":9:",},
			},
			[10] = {
				keys = { hotKeys = ":0:", hotKeyText = ":0:",},
			},
			[11] = {
				keys = { hotKeys = ":-:", hotKeyText = ":-:",},
			},
			[12] = {
				keys = { hotKeys = ":=:", hotKeyText = ":=:",},
			},
		},
	},

	[2] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 100,
		showGrid = true,

		buttons = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {},
			[5] = {},
			[6] = {},
			[7] = {},
			[8] = {},
			[9] = {},
			[10] = {},
			[11] = {},
			[12] = {},
		},
	}
}

-----------------------------------
--------- Zone Ability Bar --------
-----------------------------------
addonTable.defaultBarOptions.ZoneAbilityBar = {
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

		buttons = {
			[1] = {},
			[2] = {},
			[3] = {},
		},
	}
}

-----------------------------------
--------- Extra Action Bar --------
-----------------------------------
addonTable.defaultBarOptions.ExtraBar = {
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

addonTable.defaultBarOptions.XPBar = {
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

addonTable.defaultBarOptions.RepBar = {

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

addonTable.defaultBarOptions.CastBar = {
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

addonTable.defaultBarOptions.MirrorBar = {

	[1] = {
		showGrid = true,
		columns = 1,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "TOP",
		x = 0,
		y = -123,

		buttons = {
			[1] = {
				config = {cIndex = 1, lIndex = 2, rIndex = 3},
			},
			[2] = {
				config = {cIndex = 1, lIndex = 2, rIndex = 3},
			},
			[3] = {
				config = {cIndex = 1, lIndex = 2, rIndex = 3},
			},
		},


	}
}

-----------------------------------
----------- Exit Bar --------------
-----------------------------------
addonTable.defaultBarOptions.ExitBar = {
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
addonTable.defaultBarOptions.PetBar = {
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

		buttons = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {},
			[5] = {},
			[6] = {},
			[7] = {},
			[8] = {},
			[9] = {},
			[10] = {},
		},
	}
}

---For these two bars we have slightly different configs between classic and retail

-----------------------------------
----------- Menu Bar --------------
-----------------------------------
if not Neuron.isWoWClassicEra and not Neuron.isWoWClassic then
	addonTable.defaultBarOptions.MenuBar = {
		[1] = {
			snapTo = false,
			snapToFrame = false,
			snapToPoint = false,
			point = "BOTTOMRIGHT",
			x = -357,
			y = 24,
			padH = 0,
			padV = 0,

			buttons = {
				[1] = {},
				[2] = {},
				[3] = {},
				[4] = {},
				[5] = {},
				[6] = {},
				[7] = {},
				[8] = {},
				[9] = {},
				[10] = {},
				[11] = {},
			},
		}
	}
else
	addonTable.defaultBarOptions.MenuBar = {
		[1] = {
			snapTo = false,
			snapToFrame = false,
			snapToPoint = false,
			point = "BOTTOMRIGHT",
			x = -370,
			y = 33,

			buttons = {},
		}
	}
	for i = 1,#MICRO_BUTTONS do
		addonTable.defaultBarOptions.MenuBar[1].buttons[i] = {}
	end
end

-----------------------------------
------------ Bag Bar --------------
-----------------------------------
if not Neuron.isWoWClassicEra and not Neuron.isWoWClassic then
	addonTable.defaultBarOptions.BagBar = {
		[1] = {
			padH = 1,
			scale = 1.1,
			snapTo = false,
			snapToFrame = false,
			snapToPoint = false,
			point = "BOTTOMRIGHT",
			x = -108,
			y = 24,

			buttons = {},
		}
	}
else
	addonTable.defaultBarOptions.BagBar = {
		[1] = {
			padH = 4,
			scale = 1.1,
			snapTo = false,
			snapToFrame = false,
			snapToPoint = false,
			point = "BOTTOMRIGHT",
			x = -133,
			y = 24,

			buttons = {},
		}
	}
end
for i = 1,Neuron.NUM_BAG_BUTTONS do
	addonTable.defaultBarOptions.BagBar[1].buttons[i] = {}
end