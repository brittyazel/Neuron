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

local NeuronGUI = Neuron.NeuronGUI

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local AceGUI = LibStub("AceGUI-3.0")


function NeuronGUI:SpellTargetingPanel(tabFrame)

end


--[[
--- ACE GUI OPTION GET & SET FUnctions
-- @param self: macro editor frame
function NeuronGUI:settingGetter(info)
	if Neuron.CurrentBar then
		return Neuron.CurrentBar.data[ info[#info]]--[[

	end
end


function NeuronGUI:SetBarCastTarget(value, toggle)
	if Neuron.CurrentBar then
		Neuron.CurrentBar:SetCastingTarget(value, true, toggle)
	end
end


--TODO:This is the old spell target options code, convert it to our new system
--ACE GUI OPTION TABLE for Bar Targeting
NeuronGUI.target_options = {
	name = "Neuron-GUI",
	type = 'group',
	args = {
		selfCast = {
			order = 10,
			type = "toggle",
			name = L["Self-Cast by modifier"],
			desc = L["Toggle the use of the modifier-based self-cast functionality."],
			get = function(info)  return NeuronGUI:settingGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:SetBarCastTarget("selfCast", value) end,
		},
		setselfcastmod = {
			order = 20,
			type = "select",
			name = L["Self-Cast by modifier"],
			desc = L["Select the Self-Cast Modifier"],
			get = function(info) return GetModifiedClick("SELFCAST") end,
			set = function(info, value)
				SetModifiedClick("SELFCAST", value)
				SaveBindings(GetCurrentBindingSet() or 1)
				Neuron.ACTIONBUTTON:UpdateMacroCastTargets(true)
			end,
			values = { NONE = _G.NONE, ALT = _G.ALT_KEY_TEXT, SHIFT = _G.SHIFT_KEY_TEXT, CTRL = _G.CTRL_KEY_TEXT },
		},
		selfcast_nl = {
			order = 30,
			type = "description",
			name = "",
		},
		focusCast = {
			order = 50,
			type = "toggle",
			name = L["Focus-Cast by modifier"],
			desc = L["Toggle the use of the modifier-based focus-cast functionality."],
			get = function(info)  return NeuronGUI:settingGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:SetBarCastTarget("focusCast", value) end,
		},
		setfocuscastmod = {
			order = 60,
			type = "select",
			name = L["Focus-Cast by modifier"],
			desc = L["Select the Focus-Cast Modifier"],
			get = function(info) return GetModifiedClick("FOCUSCAST") end,
			set = function(info, value)
				SetModifiedClick("FOCUSCAST", value)
				SaveBindings(GetCurrentBindingSet() or 1)
				Neuron.ACTIONBUTTON:UpdateMacroCastTargets(true)
			end,
			values = { NONE = _G.NONE, ALT = _G.ALT_KEY_TEXT, SHIFT = _G.SHIFT_KEY_TEXT, CTRL = _G.CTRL_KEY_TEXT },
		},
		focuscast_nl = {
			order = 70,
			type = "description",
			name = "",
		},
		rightClickTarget = {
			order = 80,
			type = "toggle",
			name = L["Right-click Self-Cast"],
			desc = L["Toggle the use of the right-click self-cast functionality."],
			get = function(info)  return NeuronGUI:settingGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:SetBarCastTarget("rightClickTarget", value) end,
		},
		rightclickselfcast_nl = {
			order = 90,
			type = "description",
			name = "",
		},
		mouseOverCast = {
			order = 180,
			type = "toggle",
			name = L["Mouse-Over Casting"],
			desc = L["Toggle the use of the modifier-based mouse-over cast functionality."],
			get = function(info)  return NeuronGUI:settingGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:SetBarCastTarget("mouseOverCast", value) end,
		},
		mouseovermod = {
			order = 301,
			type = "select",
			name = L["Mouse-Over Casting Modifier"],
			desc = L["Select a modifier for Mouse-Over Casting"],
			get = function() return DB.mouseOverMod end, --getFunc,
			set = function(info, value)
				DB.mouseOverMod = value
				Neuron.ACTIONBUTTON:UpdateMacroCastTargets(true)
			end,
			values = { NONE = _G.NONE, ALT = _G.ALT_KEY_TEXT, SHIFT = _G.SHIFT_KEY_TEXT, CTRL = _G.CTRL_KEY_TEXT },
		},
		mouseovermod_desc = {
			order = 302,
			type = "description",
			name = "\n" .. L["Spell_Targeting_Modifier_None_Reminder"],
		},
	} ,
}]]
