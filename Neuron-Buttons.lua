--Neuron, a World of Warcraft® user interface addon.




------------------------------------------------------------
--------------------Button General Functions----------------
------------------------------------------------------------





function Neuron:SetTimer(frame, start, duration, enable, timer, color1, color2, cdAlpha)

	local DB = Neuron.db.profile

	if ( start and start > 0 and duration > 0 and enable > 0) then
		frame:SetAlpha(1)
		CooldownFrame_Set(frame, start, duration, enable)

		if (duration >= DB.timerLimit) then
			frame.duration = duration
			frame.start = start
			frame.active = true

			if (timer) then
				frame.timer:Show()
				if (not frame.expiry) then
					frame.timer:SetTextColor(color1[1], color1[2], color1[3])
				end
				frame.expirecolor = color2
			end

			Neuron.cooldowns[frame] = true

			if (cdAlpha) then
				Neuron.cdAlphas[frame] = true
			end

		elseif (Neuron.cooldowns[frame]) then
			frame.duration = 1
		end

	else
		frame.duration = 0
		frame.start = 0
		CooldownFrame_Set(frame, 0, 0, 0)
	end
end


function Neuron:CreateNewObject(class, id, firstRun)
	local data = Neuron.RegisteredBarData[class]

	if (data) then

		--this is the same as 'id', I'm not sure why we need both
		local index = #data.objTable + 1 --sets the current index to 1 greater than the current number of object in the table

		local object = data.objTemplate:new(data.objPrefix..id)

		object.elapsed = 0

		--returns a table of the names of all the child objects for a given frame
		local objects = Neuron:GetParentKeys(object)

		--I think this is creating a pointer inside the object to where the child object resides in the global namespace
		for k,v in pairs(objects) do
			local name = (v):gsub(object:GetName(), "")
			object[name:lower()] = _G[v]
		end

		object.class = class
		object.id = id
		object:SetID(0)
		object.objTIndex = index
		object.objType = data.objType:gsub("%s", ""):upper()
		object:LoadData(GetActiveSpecGroup(), "homestate")

		if (firstRun) then
			object:SetDefaults(object:GetDefaults())
		end

		--this is a hack to add some unique information to an object so it doesn't get wiped from the database
		if object.DB.config then
			object.DB.config.date = date("%m/%d/%y %H:%M:%S")
		end

		object:LoadAux()

		data.objTable[index] = object

		return object
	end
end




--- This will itterate through a set of buttons. For any buttons that have the #autowrite flag in its macro, that
-- macro will then be updated to via AutoWriteMacro to include selected target macro option, or via AutoUpdateMacro
-- to update a current target macro's toggle mofifier.
-- @param global(boolean): if true will go though all buttons, else it will just update the button set for the current bar
function Neuron:UpdateMacroCastTargets(global_update)

	local DB = Neuron.db.profile

	local button_list = {}

	if global_update then
		local button_count =(#DB.buttons)
		for index = 1, button_count, 1 do
			table.insert(button_list, _G["NeuronActionButton"..index])
		end
	else
		local bar = Neuron.CurrentBar
		for i, objID in ipairs(bar.data.objectList) do
			table.insert(button_list, _G["NeuronActionButton"..tostring(objID)])
		end
	end

	for index, button in pairs(button_list) do
		local cur_button = button.DB
		local macro_update = false

		for i = 1,2 do
			for state, info in pairs(cur_button[i]) do
				if info.macro_Text and info.macro_Text:find("#autowrite\n/cast") then
					local spell = ""

					spell = info.macro_Text:gsub("%[.*%]", "")
					spell = spell:match("#autowrite\n/cast%s*(.+)%((.*)%)")

					if spell then
						if global_update then
							info.macro_Text = button:AutoUpdateMacro(button, info.macro_Text)
						else
							info.macro_Text = button:AutoWriteMacro(button, spell)
						end

					end
					macro_update = true
				end
			end
		end

		if macro_update then
			button:UpdateFlyout()
			button:BuildStateData(button)
			button:SetType()
		end
	end
end


function Neuron:ChangeObject(object)

	if not Neuron.CurrentObject then
		Neuron.CurrentObject = object
	end

	local newObj, newEditor = false, false

	if (Neuron.PEW) then

		if (object and object ~= Neuron.CurrentObject) then

			if (Neuron.CurrentObject and Neuron.CurrentObject.editor.editType ~= object.editor.editType) then
				newEditor = true
			end

			if (Neuron.CurrentObject and Neuron.CurrentObject.bar ~= object.bar) then

				local bar = Neuron.CurrentObject.bar

				if (bar.handler:GetAttribute("assertstate")) then
					bar.handler:SetAttribute("state-"..bar.handler:GetAttribute("assertstate"), bar.handler:GetAttribute("activestate") or "homestate")
				end

				object.bar.handler:SetAttribute("fauxstate", bar.handler:GetAttribute("activestate"))

			end

			Neuron.CurrentObject = object

			object.editor.select:Show()

			object.selected = true
			object.action = nil

			newObj = true
		end

		if (not object) then
			Neuron.CurrentObject = nil
		end

		for k,v in pairs(Neuron.EDITIndex) do
			if (not object or v ~= object.editor) then
				v.select:Hide()
			end
		end
	end

	return newObj, newEditor
end



