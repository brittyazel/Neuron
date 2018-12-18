--Neuron, a World of Warcraft® user interface addon.

NeuronDefaultBarOptions = {}

NeuronDefaultBarOptions.ActionBar = {
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

		numButtons = 12,
	},

	[2] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 100,
		showGrid = true,

		numButtons = 12,
	}
}

NeuronDefaultBarOptions.ZoneAbilityBar = {
	[1] = {
		hidestates = ":",
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		showGrid = false,
		point = "BOTTOM",
		x = 350,
		y = 75,
		border = true,

		numButtons = 1,
	}
}

NeuronDefaultBarOptions.ExtraBar = {
	[1] = {
		hidestates = ":",
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 205,

		numButtons = 1,
	}
}

NeuronDefaultBarOptions.BagBar = {
	[1] = {
		padH = 0,
		scale = 1.1,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOMRIGHT",
		x = -102,
		y = 24,

		numButtons = 5,
	}
}

NeuronDefaultBarOptions.StatusBar = {
	[1] = {
		showGrid = true,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 385,

		numButtons = 1,
	},

	[2] = {
		showGrid = true,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 24,

		numButtons = 1,
	},

	[3] = {
		showGrid = true,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 7,

		numButtons = 1,
	},

	[4] = {
		showGrid = true,
		columns = 1,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "TOP",
		x = 0,
		y = -123,

		numButtons = 1,
	}
}

NeuronDefaultBarOptions.ExitBar = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 305,

		numButtons = 1,
	}
}

NeuronDefaultBarOptions.MenuBar = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOMRIGHT",
		x = -348,
		y = 24,

		numButtons = 11,
	}
}

NeuronDefaultBarOptions.PetBar = {
	[1] = {
		hidestates = ":pet0:",
		showGrid = true,
		scale = 0.8,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = -440,
		y = 75,

		numButtons = 10,
	}
}