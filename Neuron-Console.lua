-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

--------------------------------------------
--------------Slash Functions --------------
--------------------------------------------

--large table that contains the localized name, localized description, and internal setting name for each slash function
local slashFunctions = {
	{L["Menu"], L["Menu_Description"], "ToggleMainMenu"},
	{L["Create"], L["Create_Description"], "CreateNewBar"},
	{L["Select"], L["Select_Description"], "ChangeBar"},
	{L["Delete"], L["Delete_Description"], "DeleteBar"},
	{L["Config"], L["Config_Description"], "ToggleBarEditMode"},
	{L["Add"], L["Add_Description"], "AddObjectToBar"},
	{L["Remove"], L["Remove_Description"], "RemoveObjectFromBar"},
	{L["Edit"], L["Edit_Description"], "ToggleButtonEditMode"},
	{L["Bind"], L["Bind_Description"], "ToggleBindingMode"},
	{L["Scale"], L["Scale_Description"], "SetBarScale"},
	{L["SnapTo"], L["SnapTo_Description"], "SetSnapTo"},
	{L["AutoHide"], L["AutoHide_Description"], "SetAutoHide"},
	{L["Conceal"], L["Conceal_Description"], "SetBarConceal"},
	{L["Shape"], L["Shape_Description"], "SetBarShape"},
	{L["Name"], L["Name_Description"], "SetName"},
	{L["Strata"], L["Strata_Description"], "SetStrata"},
	{L["Alpha"], L["Alpha_Description"], "SetBarAlpha"},
	{L["AlphaUp"], L["AlphaUp_Description"], "SetAlphaUp"},
	{L["ArcStart"], L["ArcStart_Description"], "SetArcStart"},
	{L["ArcLen"], L["ArcLen_Description"], "SetArcLength"},
	{L["Columns"], L["Columns_Description"], "SetColumns"},
	{L["PadH"], L["PadH_Description"], "SetHorizontalPad"},
	{L["PadV"], L["PadV_Description"], "SetVerticalPad"},
	{L["X"], L["X_Description"], "SetXAxis"},
	{L["Y"], L["Y_Description"], "SetYAxis"},
	{L["State"], L["State_Description"], "SetState"},
	{L["StateList"], L["StateList_Description"], "PrintStateList"},
	{L["Vis"], L["Vis_Description"], "SetVisibility"},
	{L["ShowGrid"], L["ShowGrid_Description"], "ShowGridSet"},
	{L["Lock"], L["Lock_Description"], "LockSet"},
	{L["Tooltips"], L["Tooltips_Description"], "ToolTipSet"},
	{L["SpellGlow"], L["SpellGlow_Description"], "SpellGlowSet"},
	{L["BindText"], L["BindText_Description"], "BindTextSet"},
	{L["MacroText"], L["MacroText_Description"], "MacroTextSet"},
	{L["CountText"], L["CountText_Description"], "CountTextSet"},
	{L["CDText"], L["CDText_Description"], "CDTextSet"},
	{L["CDAlpha"], L["CDAlpha_Description"], "CDAlphaSet"},
	{L["UpClick"], L["UpClick_Description"], "UpClicksSet"},
	{L["DownClick"], L["DownClick_Description"], "DownClicksSet"},
	{L["BarTypes"], L["BarTypes_Description"], "PrintBarTypes"},
	{L["BlizzUI"], L["BlizzUI_Description"], "ToggleBlizzUI"},
}

--New Slash functionality
function Neuron:slashHandler(input)
	if string.len(input)==0 or input:lower() == "help" then
		Neuron:printSlashHelp()
		return
	end

	local commandAndArgs = {Neuron:GetArgs(input, 3, 1)} --split the input into the command and the arguments
	local command = commandAndArgs[1]:lower()
	local args = {}
	for i = 2,#commandAndArgs do
		args[i-1] = commandAndArgs[i]
	end

	--somewhat of a hack to insert a "true" as an arg if trying to toggle the edit modes
	if command == "config" and Neuron.state.kind ~= "bar" then
		args[1] = true
	end
	if command == "edit" and Neuron.buttonEditMode == false then
		args[1] = true
	end
	if command == "bind" and Neuron.bindingMode == false then
		args[1] = true
	end

	for i = 1,#slashFunctions do

		if command == slashFunctions[i][1]:lower() then
			local func = slashFunctions[i][3]
			local bar = Neuron.currentBar

			if func == "ChangeBar" then --intercept our bar assignment and reassign to the new bar, if it exists
				local newBar
				for _,v in pairs(Neuron.BarIndex) do
					if v.data.name == args[1] then
						newBar = v
						break
					end
				end
				if newBar then
					bar = newBar --swap out the current bar with the new bar
				else
					bar = nil --unassign bar if the entered one doesn't exists
				end
			end

			if Neuron[func] then
				Neuron[func](Neuron, args[1])
			elseif bar and bar[func] then
				--because we're calling a variable func name, we can't use the ":" notation, so we have to explicitly state the parent object as the first param
				bar[func](bar, args[1]) --not sure what to do for more than 1 arg input
			else
				Neuron:Print(L["No bar selected or command invalid"])
			end
			return
		end
	end
end

function Neuron:printSlashHelp()

	Neuron:Print("---------------------------------------------------")
	Neuron:Print(L["How to use"]..":   ".."/neuron".." <"..L["Command"]:lower().."> <"..L["Option"]:lower()..">")
	Neuron:Print(L["Command List"]..":")
	Neuron:Print("---------------------------------------------------")

	for i = 1,#slashFunctions do
		--formats the output to be the command name and then the description
		Neuron:Print(slashFunctions[i][1].." - " .."("..slashFunctions[i][2]..")")
	end

end

function Neuron:PrintStateList()
	local data = {}
	local list

	local count = 1
	for _,v in pairs(Neuron.MANAGED_BAR_STATES) do
		data[count] = v.localizedName
		count = count + 1
	end

	for _,v in ipairs(data) do

		if not list then
			list = L["Valid States"]..":"..v
		else
			list = list..", "..v
		end
	end

	Neuron:Print(list..L["Custom_Option"])
end

function Neuron:PrintBarTypes()
	Neuron:Print("---------------------------------------------------")
	Neuron:Print("     "..L["How to use"]..":   ".."/neuron".." "..L["Create"]:lower().." <"..L["Option"]:lower()..">")
	Neuron:Print("---------------------------------------------------")

	for k,v in pairs(Neuron.registeredBarData) do
		Neuron:Print("    |cff00ff00"..k..":|r "..v.barLabel)
	end
end
