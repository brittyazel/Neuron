-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

function Neuron:RegisterGUI()
	local allBars = {
		ActionBar = {
			class = "ActionBar",
			generalOptions = {
				AUTOHIDE = true,
				SHOWGRID = true,
				SNAPTO = true,
				CLICKMODE = true,
				MULTISPEC = true,
				HIDDEN = true,
				LOCKBAR = true,
			},
			visualOptions = {
				BINDTEXT = true,
				BUTTONTEXT = true,
				COUNTTEXT = true,
				RANGEIND = true,
				CDTEXT = true,
				CDALPHA = true,
				SPELLGLOW = true,
				TOOLTIPS = true,
			}
		},
		BagBar = {
			class = "BagBar",
			generalOptions = {
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			}
		},
		MenuBar = {
			class = "MenuBar",
			generalOptions = {
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			}
		},
		PetBar = {
			class = "PetBar",
			generalOptions = {
				AUTOHIDE  = true,
				--SHOWGRID  = true,
				SNAPTO    = true,
				CLICKMODE = true,
				HIDDEN    = true,
				LOCKBAR   = true,
			},
			visualOptions = {
				BINDTEXT = true,
				BUTTONTEXT = true,
				RANGEIND = true,
				CDTEXT = true,
				CDALPHA = true,
				TOOLTIPS = true,
			}
		},
		XPBar = {
			class = "XPBar",
			generalOptions = {
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			},
			visualOptions = {
				TOOLTIPS = true,
			}
		},
		RepBar = {
			class = "RepBar",
			generalOptions = {
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			},
			visualOptions = {
				TOOLTIPS = true,
			}
		},
		CastBar = {
			class = "CastBar",
			generalOptions = {
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			},
			visualOptions = {
				TOOLTIPS = true,
			}
		},
		MirrorBar = {
			class = "MirrorBar",
			generalOptions = {
				AUTOHIDE = true,
				SNAPTO = true,
				HIDDEN = true,
			},
			visualOptions = {
				TOOLTIPS = true,
			}
		},
	}
	if Neuron.isWoWRetail then
		MergeTable(allBars, {
			ZoneAbilityBar = {
				class = "ZoneAbilityBar",
				generalOptions = {
					AUTOHIDE = true,
					SNAPTO = true,
					CLICKMODE = true,
					HIDDEN = true,
				},
				visualOptions = {
					BINDTEXT = true,
					COUNTTEXT = true,
					CDTEXT = true,
					CDALPHA = true,
					TOOLTIPS = true,
					BORDERSTYLE = true,
				}
			},
			ExtraBar = {
				class = "ExtraBar",
				generalOptions = {
					AUTOHIDE = true,
					SNAPTO = true,
					CLICKMODE = true,
					HIDDEN = true,
				},
				visualOptions = {
					BINDTEXT = true,
					COUNTTEXT = true,
					CDTEXT = true,
					CDALPHA = true,
					TOOLTIPS = true,
					BORDERSTYLE = true,
				}
			},
			ExitBar = {
				class = "ExitBar",
				generalOptions = {
					AUTOHIDE = true,
					SHOWGRID = false,
					SNAPTO = true,
					CLICKMODE = true,
					HIDDEN = true,
					LOCKBAR = false,
				}
			},
		})
	end
	return allBars
end
