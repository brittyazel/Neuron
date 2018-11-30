--Neuron, a World of Warcraft® user interface addon.

local unitAuras = Neuron.unitAuras

local autoCast = { speeds = { 2, 4, 6, 8 }, timers = { 0, 0, 0, 0 }, circle = { 0, 22, 44, 66 }, shines = {}, r = 0.95, g = 0.95, b = 0.32 }

local cooldowns, cdAlphas = {}, {}


------------------------------------------------------------
--------------------Intermediate Functions------------------
------------------------------------------------------------


function Neuron:AutoCastStart(shine, r, g, b)
	autoCast.shines[shine] = shine

	if (not r) then
		r, g, b = autoCast.r, autoCast.g, autoCast.b
	end

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Show()
		sparkle:SetVertexColor(r, g, b)
	end
end


function Neuron:AutoCastStop(shine)
	autoCast.shines[shine] = nil

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Hide()
	end
end


--this function gets called via controlOnUpdate in the main Neuron.lua
---this function controlls the sparkley effects around abilities, if throttled then those effects are throttled down super slow. Be careful.
function Neuron:controlOnUpdate(frame, elapsed)
	local cou_distance, cou_radius, cou_timer, cou_speed, cou_degree, cou_x, cou_y, cou_position

	local alphaTimer, alphaDir = 0, 0

	for i in next,autoCast.timers do
		autoCast.timers[i] = autoCast.timers[i] + elapsed

		if ( autoCast.timers[i] > autoCast.speeds[i]*4 ) then
			autoCast.timers[i] = 0
		end
	end

	for i in next,autoCast.circle do
		autoCast.circle[i] = autoCast.circle[i] - i

		if ( autoCast.circle[i] < 0 ) then
			autoCast.circle[i] = 359
		end
	end

	for shine in next, autoCast.shines do
		cou_distance, cou_radius = shine:GetWidth(), shine:GetWidth()/2.7
		for i=1,4 do
			cou_timer, cou_speed, cou_degree = autoCast.timers[i], autoCast.speeds[i], autoCast.circle[i]

			if ( cou_timer <= cou_speed ) then
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree-90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree-90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree-180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree-180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree-270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree-270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = cou_timer/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
				end

			elseif (cou_timer <= cou_speed*2) then
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = (cou_timer-cou_speed)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
				end

			elseif (cou_timer <= cou_speed*3) then
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = (cou_timer-cou_speed*2)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
				end
			else
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = (cou_timer-cou_speed*3)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
				end
			end
		end
	end

	alphaTimer = alphaTimer + elapsed * 2.5

	if (alphaDir == 1) then
		if (1-alphaTimer <= 0) then
			alphaDir = 0; alphaTimer = 0
		end

	else
		if (alphaTimer >= 1) then
			alphaDir = 1; alphaTimer = 0
		end
	end
end

--this function gets called via controlOnUpdate in the main Neuron.lua
function Neuron:cooldownsOnUpdate(frame, elapsed)


	local coolDown, formatted, size

	for cd in next,cooldowns do

		coolDown = floor(cd.duration-(GetTime()-cd.start))
		formatted, size = coolDown, cd.button:GetWidth()*0.45

		if (coolDown < 1) then
			if (coolDown < 0) then
				cooldowns[cd] = nil

				cd.timer:Hide()
				cd.timer:SetText("")
				cd.timerCD = nil
				cd.expirecolor = nil
				cd.cdsize = nil
				cd.active = nil
				cd.expiry = nil

			elseif (coolDown >= 0) then
				cd.timer:SetAlpha(cd.duration-(GetTime()-cd.start))

				if (cd.alphafade) then
					cd:SetAlpha(cd.duration-(GetTime()-cd.start))
				end
			end

		elseif (cd.timer:IsShown() and coolDown ~= cd.timerCD) then
			if (coolDown >= 86400) then
				formatted = math.ceil(coolDown/86400)
				formatted = formatted.."d"; size = cd.button:GetWidth()*0.3
			elseif (coolDown >= 3600) then
				formatted = math.ceil(coolDown/3600)
				formatted = formatted.."h"; size = cd.button:GetWidth()*0.3
			elseif (coolDown >= 60) then
				formatted = math.ceil(coolDown/60)
				formatted = formatted.."m"; size = cd.button:GetWidth()*0.3
			elseif (coolDown < 6) then
				size = cd.button:GetWidth()*0.6
				if (cd.expirecolor) then
					cd.timer:SetTextColor(cd.expirecolor[1], cd.expirecolor[2], cd.expirecolor[3]); cd.expirecolor = nil
					cd.expiry = true
				end
			end

			if (not cd.cdsize or cd.cdsize ~= size) then
				cd.timer:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE"); cd.cdsize = size
			end

			cd.timerCD = coolDown
			cd.timer:SetAlpha(1)
			cd.timer:SetText(formatted)
		end
	end

	for cd in next,cdAlphas do
		coolDown = ceil(cd.duration-(GetTime()-cd.start))

		if (coolDown < 1) then
			cdAlphas[cd] = nil
			cd.button:SetAlpha(1)
			cd.alphaOn = nil

		elseif (not cd.alphaOn) then
			cd.button:SetAlpha(cd.button.cdAlpha)
			cd.alphaOn = true
		end
	end
end

function Neuron:updateAuraInfo(unit)

	local uai_index, uai_spell, uai_count, uai_duration, uai_timeLeft, uai_caster, uai_spellID, _
	uai_index = 1

	wipe(unitAuras[unit])

	repeat
		uai_spell, _, uai_count, _, uai_duration, uai_timeLeft, uai_caster, _, _, uai_spellID = UnitAura(unit, uai_index, "HELPFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			unitAuras[unit][uai_spell:lower()] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			unitAuras[unit][uai_spell:lower().."()"] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)

	uai_index = 1

	repeat
		uai_spell, _, uai_count, _, uai_duration, uai_timeLeft, uai_caster = UnitAura(unit, uai_index, "HARMFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			unitAuras[unit][uai_spell:lower()] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			unitAuras[unit][uai_spell:lower().."()"] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)
end




function Neuron:SetTimer(frame, start, duration, enable, timer, color1, color2, cdAlpha)

	local DB = Neuron.db.profile

	if ( start and start > 0 and duration > 0 and enable > 0) then
		frame:SetAlpha(1)
		CooldownFrame_Set(frame, start, duration, enable)
		--CooldownFrame_SetTimer(frame, start, duration, enable)

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

			cooldowns[frame] = true

			if (cdAlpha) then
				cdAlphas[frame] = true
			end

		elseif (cooldowns[frame]) then
			frame.duration = 1
		end

	else
		frame.duration = 0
		frame.start = 0
		CooldownFrame_Set(frame, 0, 0, 0)
	end
end



--[[function Neuron:ToggleCollectionsJournal()

	local MountButtonsHookIsSet

	if CollectionsJournal:IsShown() then
		if not MountButtonsHookIsSet then
			for i = 1, 20 do
				local bName = "MountJournalListScrollFrameButton"..i
				local f = _G[bName]
				if f then
					if f.DragButton then
						f.DragButton:HookScript("OnEnter", function(self) ACTIONBUTTON.CurrentMountSpellID = self:GetParent().spellID end)
					end
				end
			end
			MountButtonsHookIsSet = true
		end
	end
end]]



function Neuron:CreateNewObject(class, id, firstRun)
	local data = Neuron.RegisteredBarData[class]

	if (data) then

		--this is the same as 'id', I'm not sure why we need both
		local index = #data.objTable + 1 --sets the current index to 1 greater than the current number of object in the table

		local object = Neuron.BUTTON:new(data.objPrefix..id, data.objFrameT, data.objTemplate, data.objMetaT)

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
			tinsert(button_list, _G["NeuronActionButton"..index])
		end
	else
		local bar = Neuron.CurrentBar
		for i, objID in ipairs(bar.data.objectList) do
			tinsert(button_list, _G["NeuronActionButton"..tostring(objID)])
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
			Neuron.NeuronFlyouts:UpdateFlyout(button)
			button:BuildStateData(button)
			button:SetType()
		end
	end
end

--TODO: THis is the start of the object code



