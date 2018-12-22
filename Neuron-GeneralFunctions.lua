--Neuron, a World of Warcraft® user interface addon.


------------------------------------------------------------
---------------Button and Bar General Functions-------------
------------------------------------------------------------

function Neuron:SetTimer(frame, start, duration, enable, timer, color1, color2, cdAlpha)

	if ( start and start > 0 and duration > 0 and enable > 0) then
		frame:SetAlpha(1)
		CooldownFrame_Set(frame, start, duration, enable)

		if (duration >= Neuron.TIMERLIMIT) then
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


--- This will itterate through a set of buttons. For any buttons that have the #autowrite flag in its macro, that
-- macro will then be updated to via AutoWriteMacro to include selected target macro option, or via AutoUpdateMacro
-- to update a current target macro's toggle mofifier.
-- @param global(boolean): if true will go though all buttons, else it will just update the button set for the current bar
function Neuron:UpdateMacroCastTargets(global_update)

	local DB = Neuron.db.profile

	local button_list = {}

	if global_update then

		for _,bar in ipairs(Neuron.BARIndex) do
			for _, object in ipairs(bar.buttons) do
				table.insert(button_list, object)
			end
		end

	else
		local bar = Neuron.CurrentBar
		for i, object in ipairs(bar.buttons) do
			table.insert(button_list, object)
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

	if (Neuron.enteredWorld) then

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



function Neuron:CreateNewObject(class, id, bar, defaults)
	local data = Neuron.registeredBarData[class]

	if (data) then

		--calls new object constructor for the appropriate class type
		local object = data.objTemplate:new(bar:GetName().."_"..data.objPrefix..id)


		--returns a table of the names of all the child objects for a given frame
		local objects = Neuron:GetParentKeys(object)
		--populates the button with all the Icon,Shine,Cooldown frame references
		for k,v in pairs(objects) do
			local name = (v):gsub(object:GetName(), "")
			object[name:lower()] = _G[v]
		end

		bar.buttons[id] = object --add this object to our buttons table for this bar

		if not bar.DB.buttons[id] then --if the database for a bar doesn't exist (because it's a new bar) make a new table
			bar.DB.buttons[id] = {}
		end
		object.DB = bar.DB.buttons[id] --set our button database table as the DB for our object

		object.bar = bar

		object.class = class
		object.id = id
		--object:SetID(id)
		object.objType = data.objType:gsub("%s", ""):upper()
		object:LoadData(GetActiveSpecGroup(), "homestate")

		object.elapsed = 0

		if (defaults) then
			object:SetDefaults(defaults)
		end

		--this is a hack to add some unique information to an object so it doesn't get wiped from the database
		if object.DB.config then
			object.DB.config.date = date("%m/%d/%y %H:%M:%S")
		end

		object:LoadAux()

		return object
	end
end



function Neuron:CreateNewBar(class, id, defaults)

	if (class and Neuron.registeredBarData[class]) then

		local bar, newBar = Neuron:CreateBar(class, id)

		if (defaults) then
			bar:SetDefaults(defaults)

			for i=1,#defaults.buttons do
				Neuron:CreateNewObject(class, i, bar, defaults.buttons[i])
			end

		else
			for i=1,#bar.DB.buttons do
				Neuron:CreateNewObject(class, i, bar)
			end
		end

		if (newBar) then
			bar:Load()
			bar:ChangeBar()

			---------------------------------
			if (class == "ExtraBar") then --this is a hack to get around an issue where the extrabar wasn't autohiding due to bar visibility states. There most likely a way better way to do this in the future. FIX THIS!
				bar.data.hidestates = ":extrabar0:"
				bar.vischanged = true
				bar:Update()
			end
			if (class == "PetBar") then --this is a hack to get around an issue where the extrabar wasn't autohiding due to bar visibility states. There most likely a way better way to do this in the future. FIX THIS!
				bar.data.hidestates = ":pet0:"
				bar.vischanged = true
				bar:Update()
			end
			-----------------------------------
		end

		return bar
	else
		Neuron.PrintBarTypes()
	end
end

function Neuron:CreateBar(class, id)
	local data = Neuron.registeredBarData[class]
	local newBar

	local index = #Neuron.BARIndex + 1

	if (data) then
		if (not id) then
			id = #data.barDB + 1
			newBar = true
		end

		---this is the create of our bar object frame
		local bar = Neuron.BAR:new("Neuron"..data.barType..id)

		for key,value in pairs(data) do
			bar[key] = value
		end

		if not data.barDB[id] then --if the database for a bar doesn't exist (because it's a new bar?
			data.barDB[id] = {}
		end
		bar.DB = data.barDB[id]

		bar.buttons = {}

		bar.index = index
		bar.id = id
		bar.class = class
		bar.stateschanged = true
		bar.vischanged =true
		bar.elapsed = 0
		bar.click = nil
		bar.dragged = false
		bar.selected = false
		bar.toggleframe = bar
		bar.microAdjust = false
		bar.vis = {}
		bar.text:Hide()
		bar.message:Hide()
		bar.messagebg:Hide()

		bar:SetID(id)
		bar:SetWidth(375)
		bar:SetHeight(40)
		bar:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		                 edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		                 tile = true, tileSize = 16, edgeSize = 12,
		                 insets = {left = 4, right = 4, top = 4, bottom = 4}})
		bar:SetBackdropColor(0,0,0,0.4)
		bar:SetBackdropBorderColor(0,0,0,0)
		bar:SetFrameLevel(2)
		bar:RegisterForClicks("AnyDown", "AnyUp")
		bar:RegisterForDrag("LeftButton")
		bar:SetMovable(true)
		bar:EnableKeyboard(false)
		bar:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

		bar:SetScript("OnClick", function(self, ...) self:OnClick(...) end)
		bar:SetScript("OnDragStart", function(self, ...) self:OnDragStart(...) end)
		bar:SetScript("OnDragStop", function(self, ...) self:OnDragStop(...) end)
		bar:SetScript("OnEnter", function(self, ...) self:OnEnter(...) end)
		bar:SetScript("OnLeave", function(self, ...) self:OnLeave(...) end)
		bar:SetScript("OnEvent", function(self, event, ...) self:OnEvent(event, ...) end)
		bar:SetScript("OnKeyDown", function(self, key, onupdate) self:OnKeyDown(key, onupdate) end)
		bar:SetScript("OnKeyUp", function(self, key) self:OnKeyUp(key) end)
		bar:SetScript("OnShow", function(self) self:OnShow() end)
		bar:SetScript("OnHide", function(self) self:OnHide() end)
		bar:SetScript("OnUpdate", function(self, elapsed) self:OnUpdate(elapsed) end)


		bar:CreateDriver()
		bar:CreateHandler()
		bar:CreateWatcher()

		bar:LoadData()

		if (not newBar) then
			bar:Hide()
		end

		Neuron.BARIndex[index] = bar

		return bar, newBar
	end
end
