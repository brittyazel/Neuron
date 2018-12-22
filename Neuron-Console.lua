--Neuron, a World of Warcraft® user interface addon.

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

--------------------------------------------
--------------Slash Functions --------------
--------------------------------------------

--large table that contains the localized name, localized description, and internal setting name for each slash function
local slashFunctions = {
	{L["Menu"], L["Menu_Description"], "ToggleMainMenu"},
	{L["Create"], L["Create_Description"], "CreateNewBar"},
	{L["Delete"], L["Delete_Description"], "DeleteBar"},
	{L["Config"], L["Config_Description"], "ToggleBarEditMode"},
	{L["Add"], L["Add_Description"], "AddObjectsToBar"},
	{L["Remove"], L["Remove_Description"], "RemoveObjectsFromBar"},
	{L["Edit"], L["Edit_Description"], "ToggleButtonEditMode"},
	{L["Bind"], L["Bind_Description"], "ToggleBindingMode"},
	{L["Scale"], L["Scale_Description"], "ScaleBar"},
	{L["SnapTo"], L["SnapTo_Description"], "SnapToBar"},
	{L["AutoHide"], L["AutoHide_Description"], "AutoHideBar"},
	{L["Conceal"], L["Conceal_Description"], "ConcealBar"},
	{L["Shape"], L["Shape_Description"], "ShapeBar"},
	{L["Name"], L["Name_Description"], "NameBar"},
	{L["Strata"], L["Strata_Description"], "StrataSet"},
	{L["Alpha"], L["Alpha_Description"], "AlphaSet"},
	{L["AlphaUp"], L["AlphaUp_Description"], "AlphaUpSet"},
	{L["ArcStart"], L["ArcStart_Description"], "ArcStartSet"},
	{L["ArcLen"], L["ArcLen_Description"], "ArcLengthSet"},
	{L["Columns"], L["Columns_Description"], "ColumnsSet"},
	{L["PadH"], L["PadH_Description"], "PadHSet"},
	{L["PadV"], L["PadV_Description"], "PadVSet"},
	{L["PadHV"], L["PadHV_Description"], "PadHVSet"},
	{L["X"], L["X_Description"], "XAxisSet"},
	{L["Y"], L["Y_Description"], "YAxisSet"},
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
	{L["AuraText"], L["AuraText_Description"], "AuraTextSet"},
	{L["AuraInd"], L["AuraInd_Description"], "AuraIndSet"},
	{L["UpClick"], L["UpClick_Description"], "UpClicksSet"},
	{L["DownClick"], L["DownClick_Description"], "DownClicksSet"},
	{L["BarTypes"], L["BarTypes_Description"], "PrintBarTypes"},
	{L["BlizzUI"], L["BlizzUI_Description"], "ToggleBlizzUI"},
}


---New Slash functionality
function Neuron:slashHandler(input)

	if (strlen(input)==0 or input:lower() == "help") then
		Neuron:printSlashHelp()
		return
	end

	local commandAndArgs = {strsplit(" ", input)} --split the input into the command and the arguments
	local command = commandAndArgs[1]:lower()
	local args = {}
	for i = 2,#commandAndArgs do
		args[i-1] = commandAndArgs[i]:lower()
	end


	--somewhat of a hack to insert a "true" as an arg if trying to toggle the edit modes
	if command == "config" and Neuron.barEditMode == false then
		args[1] = true
	end
	if command == "edit" and Neuron.buttonEditMode == false then
		args[1] = true
	end
	if command == "bind" and Neuron.bindingMode == false then
		args[1] = true
	end



	for i = 1,#slashFunctions do

		if (command == slashFunctions[i][1]:lower()) then
			local func = slashFunctions[i][3]
			local bar = Neuron.CurrentBar

			if (Neuron[func]) then
				Neuron[func](Neuron, args[1])
			elseif (bar and bar[func]) then
				---because we're calling a variable func name, we can't use the ":" notation, so we have to explicitely state the parent object as the first param
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

	for k,v in pairs(Neuron.MANAGED_ACTION_STATES) do
		if (Neuron.STATEINDEX[k]) then
			data[v.order] = Neuron.STATEINDEX[k]
		end
	end

	for k,v in ipairs(data) do

		if (not list) then
			list = L["Valid States"]..":"..v
		else
			list = list..", "..v
		end
	end

	Neuron:Print(list..L["Custom_Option"])
end


function Neuron:PrintBarTypes()
	local data, index, high = {}, 1, 0

	for k,v in pairs(Neuron.registeredBarData) do

		local barType;
		index = tonumber(v.createMsg:match("%d+"))
		barType = v.createMsg:gsub("%d+","")

		if (index and barType) then
			data[index] = {k, barType}
			if (index > high) then high = index end
		end

	end

	for i=1,high do if (not data[i]) then data[i] = 0 end end


	Neuron:Print("---------------------------------------------------")
	Neuron:Print("     "..L["How to use"]..":   ".."/neuron".." "..L["Create"]:lower().." <"..L["Option"]:lower()..">")
	Neuron:Print("---------------------------------------------------")

	for k,v in ipairs(data) do
		if (type(v) == "table") then
			Neuron:Print("    |cff00ff00"..v[1]..":|r "..v[2])
		end
	end

end