-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local Spec = addonTable.utilities.Spec

---@class ActionButton : Button @define class ActionButton inherits from class Button
local ActionButton = setmetatable({}, {__index = Neuron.Button}) --this is the metatable for our button object
Neuron.ActionButton = ActionButton

---------------------------------------------------------
-------------------declare globals-----------------------
---------------------------------------------------------

local COMMAND_LIST = {
	[SLASH_CAST1] = true,
	[SLASH_CAST2] = true,
	[SLASH_CAST3] = true,
	[SLASH_CAST4] = true,
	[SLASH_CASTRANDOM1] = true,
	[SLASH_CASTRANDOM2] = true,
	[SLASH_CASTSEQUENCE1] = true,
	[SLASH_CASTSEQUENCE2] = true,
	[SLASH_EQUIP1] = true,
	[SLASH_EQUIP2] = true,
	[SLASH_EQUIP3] = true,
	[SLASH_EQUIP4] = true,
	[SLASH_EQUIP_TO_SLOT1] = true,
	[SLASH_EQUIP_TO_SLOT2] = true,
	[SLASH_USE1] = true,
	[SLASH_USE2] = true,
	[SLASH_USERANDOM1] = true,
	[SLASH_USERANDOM2] = true,
	["/cast"] = true,
	["/castrandom"] = true,
	["/castsequence"] = true,
	["/spell"] = true,
	["/equip"] = true,
	["/eq"] = true,
	["/equipslot"] = true,
	["/use"] = true,
	["/userandom"] = true,
	["/summonpet"] = true,
	["/click"] = true,
	["#showtooltip"] = true,
}

---Constructor: Create a new Neuron Button object (this is the base object for all Neuron button types)
---@param bar Bar @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return ActionButton @ A newly created ActionButton object
function ActionButton.new(bar, buttonID, defaults)
	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.Button.new(bar, buttonID, ActionButton, "ActionBar", "ActionButton", "NeuronActionButtonTemplate")

	if defaults then
		newButton:SetDefaults(defaults)
	end

	newButton:EditorOverlay_CreateEditFrame()
	newButton:KeybindOverlay_CreateEditFrame()

	return newButton
end

function ActionButton:InitializeButton()
	self:ClearButton(true)

	SecureHandler_OnLoad(self)

	if self.class ~= "flyout" then
		self:SetupEvents()
	end

	self:SetAttribute("type", "macro")
	self:SetAttribute("*macrotext*", self.SanitizedMacro(self:GetMacroText()))

	self:SetAttribute("hotkeypri", self.keys.hotKeyPri)
	self:SetAttribute("hotkeys", self.keys.hotKeys)

	self:SetScript("PostClick", function(_, mousebutton) self:PostClick(mousebutton) end)
	self:SetScript("OnReceiveDrag", function(_, preclick) self:OnReceiveDrag(preclick) end)
	self:SetScript("OnDragStart", function(_, mousebutton) self:OnDragStart(mousebutton) end)

	--this is to allow for the correct releasing of the button when dragging icons off of the bar
	--we need to hook to the WorldFrame OnReceiveDrag and OnMouseDown so that we can "let go" of the spell when we drag it off the bar
	if not Neuron:IsHooked(WorldFrame, "OnReceiveDrag") then
		Neuron:HookScript(WorldFrame, "OnReceiveDrag", function() ActionButton:WorldFrame_OnReceiveDrag() end)
	end
	if not Neuron:IsHooked(WorldFrame, "OnMouseDown") then
		Neuron:HookScript(WorldFrame, "OnMouseDown", function() ActionButton:WorldFrame_OnReceiveDrag() end)
	end

	self:SetScript("OnAttributeChanged", function(_, name, value) self:OnAttributeChanged(name, value) end)
	self:SetScript("OnEnter", function() self:UpdateTooltip() end)
	self:SetScript("OnLeave", function() GameTooltip:Hide() end)

	if Neuron.isWoWRetail then
		self:SetAttribute("overrideID_Offset", 204)
		self:SetAttribute("vehicleID_Offset", 180)
	else
		self:SetAttribute("overrideID_Offset", 156)
		self:SetAttribute("vehicleID_Offset", 132)
	end

	--This is so that hotkeypri works properly with priority/locked buttons
	self:WrapScript(self, "OnShow", [[
			for i=1,select('#',(":"):split(self:GetAttribute("hotkeys"))) do
				self:SetBindingClick(self:GetAttribute("hotkeypri"), select(i,(":"):split(self:GetAttribute("hotkeys"))), self:GetName())
			end
			]])

	self:SetFrameRef("uiparent", UIParent)
	self:WrapScript(self, "OnHide", [[
            UIParent = self:GetFrameRef("uiparent")
			if (not self:GetParent():GetAttribute("concealed")) and (not UIParent:IsShown() == false) then
				for key in gmatch(self:GetAttribute("hotkeys"), "[^:]+") do
					self:ClearBinding(key)
				end
			end
			]])

	self:SetAttribute("_childupdate",
			[[
				if message then
					local msg = (":"):split(message)

					if msg:find("vehicle") then
						if not self:GetAttribute(msg.."-actionID") then
							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))
						end
						self:SetAttribute("HasActionID", true)
						self:Show()

					elseif msg:find("possess") then
						if not self:GetAttribute(msg.."-actionID") then
							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))
						end
						self:SetAttribute("HasActionID", true)
						self:Show()

					elseif msg:find("override") then
						if not self:GetAttribute(msg.."-actionID") then
							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("overrideID_Offset"))
							self:SetAttribute("HasActionID", true)
						end
						self:SetAttribute("HasActionID", true)
						self:Show()

					else
						if not self:GetAttribute(msg.."-actionID") then
							self:SetAttribute("type", "macro")
							self:SetAttribute("*macrotext*", self:GetAttribute(msg.."-macro_Text"))

							--if there is a macro present, or if showGrid is enabled, show the button. If not, hide it. This works in combat.
							if (self:GetAttribute("*macrotext*") and #self:GetAttribute("*macrotext*") > 0) or self:GetAttribute("showGrid") then
								self:Show()
							else
								self:Hide()
							end
							self:SetAttribute("HasActionID", false)

						else
							self:SetAttribute("HasActionID", true)
						end
					end
					self:SetAttribute("activestate", msg)
				end
			]])

	--this is our rangecheck timer for each button. Every 0.5 seconds it queries if the button is usable
	--this doubles our CPU usage, but it really helps usability quite a bit
	--this is a direct replacement to the old "onUpdate" code that did this job

	if self:TimeLeft(self.rangeTimer) == 0 then
		self.rangeTimer = self:ScheduleRepeatingTimer("UpdateUsable", 0.5)
	end

	self:UpdateAll()
	self:UpdateFlyout(true)

	self:InitializeButtonSettings()
end

function ActionButton:InitializeButtonSettings()
	self:SetFrameStrata(Neuron.STRATAS[self.bar:GetStrata()-1])
	self:SetScale(self.bar:GetBarScale())

	if self.bar:GetShowBindText() then
		self.Hotkey:Show()
		self.Hotkey:SetTextColor(self.bar:GetBindColor()[1],self.bar:GetBindColor()[2],self.bar:GetBindColor()[3])
	else
		self.Hotkey:Hide()
	end

	if self.bar:GetShowButtonText() then
		self.Name:Show()
		self.Name:SetTextColor(self.bar:GetMacroColor()[1],self.bar:GetMacroColor()[2],self.bar:GetMacroColor()[3])
	else
		self.Name:Hide()
	end

	if self.bar:GetShowCountText() then
		self.Count:Show()
		self.Count:SetTextColor(self.bar:GetCountColor()[1],self.bar:GetCountColor()[2],self.bar:GetCountColor()[3])
	else
		self.Count:Hide()
	end

	--[[
	if self.bar:GetClickMode() == "UpClick" then
		self:RegisterForClicks("AnyUp")
	elseif self.bar:GetClickMode() == "DownClick" then
		self:RegisterForClicks("AnyDown")
	end
	]]
	self:RegisterForClicks("AnyUp")

	self:RegisterForDrag("LeftButton", "RightButton")
	self:SetSkinned()
end


function ActionButton:SetupEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:RegisterEvent("UPDATE_MACROS")

	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", "UpdateAll")
	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", "UpdateCooldown")

	self:RegisterEvent("SPELL_UPDATE_CHARGES", "UpdateCount")

	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdateAll")

	self:RegisterEvent("SPELLS_CHANGED", "UpdateAll")
	self:RegisterEvent("MODIFIER_STATE_CHANGED", "UpdateAll")

	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED")

	self:RegisterEvent("BAG_UPDATE_COOLDOWN", "UpdateStatus")
	self:RegisterEvent("BAG_UPDATE", "UpdateStatus")

	self:RegisterEvent("PLAYER_STARTED_MOVING", "UpdateUsable")
	self:RegisterEvent("PLAYER_STOPPED_MOVING", "UpdateUsable")

	self:RegisterEvent("ACTIONBAR_UPDATE_USABLE", "UpdateUsable")

	self:RegisterEvent("ACTIONBAR_UPDATE_STATE", "UpdateAll")
	self:RegisterEvent("TRADE_SKILL_SHOW", "UpdateAll")
	self:RegisterEvent("TRADE_SKILL_CLOSE", "UpdateAll")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateAll")
	self:RegisterEvent("UNIT_PET", "UpdateAll")

	if Neuron.isWoWRetail then
		self:RegisterEvent("EQUIPMENT_SETS_CHANGED")

		self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UpdateAll")
		self:RegisterEvent("UNIT_ENTERING_VEHICLE", "UpdateAll")
		self:RegisterEvent("UNIT_EXITED_VEHICLE", "UpdateAll")
		self:RegisterEvent("PLAYER_FOCUS_CHANGED", "UpdateAll")
		self:RegisterEvent("COMPANION_UPDATE", "UpdateAll")

		self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW", "UpdateGlow")
		self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE", "UpdateGlow")

		self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", "UpdateAll")
		self:RegisterEvent("UPDATE_POSSESS_BAR", "UpdateAll")
		self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", "UpdateAll")
		self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "UpdateAll")
	end
end

function ActionButton:OnAttributeChanged(name, value)

	if value and self.data then
		if name == "activestate" then
			--Part 2 of Druid Prowl overwrite fix (part 1 below)
			-----------------------------------------------------
			--breaks out of the loop due to flag set below
			if Neuron.class == "DRUID" and self.ignoreNextOverrideStance == true and value == "homestate" then
				self.ignoreNextOverrideStance = nil
				self.bar:SetState("stealth") --have to add this in otherwise the button icons change but still retain the homestate ability actions
				return
			else
				self.ignoreNextOverrideStance = nil
			end
			-----------------------------------------------------
			-----------------------------------------------------

			if self:GetAttribute("HasActionID") then
				self.actionID = self:GetAttribute("*action*")
			else
				--clear any actionID that has been set
				self.actionID = nil

				--this is a safety check in case the state we're switching into doesn't have table set up for it yet
				-- i.e. stealth1 or stance2
				if not self.statedata[value] then
					self.statedata[value] = {}
				end

				--Part 1 of Druid Prowl overwrite fix
				---------------------------------------------------
				--druids have an issue where once stance will get immediately overwritten by another. I.E. stealth immediately getting overwritten by homestate if they go immediately into prowl from caster form
				--this conditional sets a flag to ignore the next most stance flag, as that one is most likely in error and should be ignored
				if Neuron.class == "DRUID" and value == "stealth1" then
					self.ignoreNextOverrideStance = true
				end
				------------------------------------------------------
				------------------------------------------------------

				--swap out our data with the data stored for the particular state
				self.data = self.statedata[value]
				self:ClearButton()
			end

			--This will remove any old button state data from the saved variable's memory
			for id,data in pairs(self.statedata) do
				if (self.bar.data[id:match("%a+")] or id == "") and self.bar.data["custom"] then
				elseif not self.bar.data[id:match("%a+")] then
					self.statedata[id]= nil
				end
			end

			self:UpdateAll()
		end

		if name == "update" then
			self:UpdateAll()
		end
	end
end


function ActionButton:OnLeave(...)
	GameTooltip:Hide()

	if self.flyout and self.flyout.arrow then
		self.flyout.arrow:SetPoint(self.flyout.arrowPoint, self.flyout.arrowX, self.flyout.arrowY)
	end
end

------------------------------------------------------------
--------------General Button Methods------------------------
------------------------------------------------------------

function ActionButton:GetDragAction()
	return "macro"
end

function ActionButton:ClearButton(clearAttributes)
	self.spell = nil
	self.spellID = nil
	self.item = nil
	self.unit = nil

	if not InCombatLockdown() and clearAttributes then
		self:SetAttribute("unit", nil)
		self:SetAttribute("type", nil)
		self:SetAttribute("type1", nil)
		self:SetAttribute("type2", nil)
		self:SetAttribute("*action*", nil)
		self:SetAttribute("*macrotext*", nil)
		self:SetAttribute("*action1", nil)
		self:SetAttribute("*macrotext2", nil)
	end
end

function ActionButton:UpdateGlow()
	if self.bar:GetSpellGlow() and self.spellID then
		--druid fix for thrash glow not showing for feral druids.
		--Thrash Guardian: 77758
		--Thrash Feral: 106832
		--But the joint thrash is 106830 (this is the one that results true when the ability is procced)

		--Swipe(Bear): 213771
		--Swipe(Cat): 106785
		--Swipe(NoForm): 213764

		if self.spell and self.spell:lower() == "thrash()" and IsSpellOverlayed(106830) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
			self:StartGlow()
		elseif self.spell and self.spell:lower() == "swipe()" and IsSpellOverlayed(106785) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
			self:StartGlow()
		elseif IsSpellOverlayed(self.spellID) then --this is the default "true" condition
			self:StartGlow()
		else --this is the default "false" condition
			self:StopGlow()
		end
	else --this stops the glow on buttons that have no spellID's, i.e. when switching states and a procced ability is overlapping an empty button
		self:StopGlow()
	end
end


function ActionButton:StartGlow()
	if self.bar:GetSpellGlow() == "default" then
		ActionButton_ShowOverlayGlow(self)
	else
		self.Shine:Show()
		AutoCastShine_AutoCastStart(self.Shine);
	end
end

function ActionButton:StopGlow()
	if self.bar:GetSpellGlow() == "default" then
		ActionButton_HideOverlayGlow(self)
	else
		self.Shine:Hide()
		AutoCastShine_AutoCastStop(self.Shine);
	end
end

------------------------------------------------------------------------------
---------------------Event Functions------------------------------------------
------------------------------------------------------------------------------

function ActionButton:PLAYER_ENTERING_WORLD()
	self:UpdateAll()
	self:KeybindOverlay_ApplyBindings()

	if self.flyout then --this is a hack to get around CallPet not working on initial login. (weirdly it worked on /reload, but not login)
		self:ScheduleTimer(function() self:InitializeButton() end, 1)
	end
end

function ActionButton:UNIT_SPELLCAST_INTERRUPTED(unit)
	if (unit == "player" or unit == "pet") and self.spell then
		self:UpdateCooldown()
	end
end


function ActionButton:UPDATE_MACROS()
	if not InCombatLockdown() and self:GetMacroBlizzMacro() then
		self:PlaceBlizzMacro(self:GetMacroBlizzMacro())
	end
end

function ActionButton:EQUIPMENT_SETS_CHANGED()
	if not InCombatLockdown() and self:GetMacroEquipmentSet() then
		self:PlaceBlizzEquipSet(self:GetMacroEquipmentSet())
	end
end

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

function ActionButton.SanitizedMacro(macro)
	if type(macro) == "string" and #macro > 0 then
		--adds an empty line above and below the macro
		macro = "\n"..macro.."\n"
		--I'm not sure what this line does, but it adds spaces before control characters.
		--Maybe it's adding spaces before newlines?
		return macro:gsub("(%c+)", " %1")
	else
		return nil
	end
end

function ActionButton:UpdateButtonSpec()
	local spec = Spec.active(self.bar:GetMultiSpec())

	self:LoadDataFromDatabase(spec, self.bar.handler:GetAttribute("activestate") or "homestate")
	self:InitializeButtonSettings()
	self:UpdateFlyout()
	self:UpdateAll()
end

--this function is used to "fake" a state change in the button editor so you can see what each state will look like
function ActionButton:FakeStateChange(state)
	if state then

		local msg = (":"):split(state)

		if msg:find("vehicle") then

			if not self:GetAttribute(msg.."-actionID") then
				self:SetAttribute("type", "action")
				self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))
			end

			self:SetAttribute("HasActionID", true)
			self:Show()

		elseif msg:find("possess") then

			if not self:GetAttribute(msg.."-actionID") then
				self:SetAttribute("type", "action")
				self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))
			end

			self:SetAttribute("HasActionID", true)
			self:Show()

		elseif msg:find("override") then

			if not self:GetAttribute(msg.."-actionID") then
				self:SetAttribute("type", "action")
				self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("overrideID_Offset"))
				self:SetAttribute("HasActionID", true)
			end

			self:SetAttribute("HasActionID", true)
			self:Show()

		else

			if not self:GetAttribute(msg.."-actionID") then
				self:SetAttribute("type", "macro")
				self:SetAttribute("*self*", self:GetAttribute(msg.."-macro_Text"))

				--if there is a macro present, or if showGrid is enabled, show the button. If not, hide it. This works in combat.
				if self:GetAttribute("*macrotext*") and #self:GetAttribute("*macrotext*") > 0 or self:GetAttribute("showGrid") then
					self:Show()
				else
					self:Hide()
				end

				self:SetAttribute("HasActionID", false)
			else
				self:SetAttribute("HasActionID", true)
			end

		end

		self:SetAttribute("activestate", msg)
	end
end

--this will generate a spell macro
--spell: name of spell to use
--subname: subname of spell to use (optional)
--return: macro text
function ActionButton:AutoWriteMacro(spell)
	local DB = Neuron.db.profile

	local spellName
	local spellID

	local altName
	local altSpellID

	--if there is an alt name associated with a given ability, and the alt name is known (i.e. the base spell) use the alt name instead
	--This is important because a macro written with the base name "/cast Roll()" will work for talented abilities, but "/cast Chi Torpedo" won't work for base abilities
	if Neuron.spellCache[spell:lower()] then
		spellName = Neuron.spellCache[spell:lower()].spellName
		spellID = Neuron.spellCache[spell:lower()].spellID

		altName = Neuron.spellCache[spell:lower()].altName
		altSpellID = Neuron.spellCache[spell:lower()].altSpellID

		if altSpellID and IsSpellKnown(altSpellID) then
			spell = altName
		else
			spell = spellName
		end
	else
		_,_,_,_,_,_,spellID = GetSpellInfo(spell)
	end

	local modifier, modKey = " ", nil
	local bar = Neuron.currentBar or self.bar

	if bar.data.mouseOverCast and DB.mouseOverMod ~= "NONE"  then
		modKey = DB.mouseOverMod
		modifier = modifier.."[@mouseover,mod:"..modKey.."]"
	elseif bar.data.mouseOverCast and DB.mouseOverMod == "NONE"  then
		modifier = modifier.."[@mouseover,exists]"
	end

	if bar.data.selfCast and GetModifiedClick("SELFCAST") ~= "NONE"  then
		modKey = GetModifiedClick("SELFCAST")
		modifier = modifier.."[@player,mod:"..modKey.."]"
	end

	if bar.data.focusCast and GetModifiedClick("FOCUSCAST") ~= "NONE"  then
		modKey = GetModifiedClick("FOCUSCAST")
		modifier = modifier.."[@focus,exists,mod:"..modKey.."]"
	end

	if bar.data.rightClickTarget then
		modKey = ""
		modifier = modifier.."[@player"..modKey..",btn:2]"
	end

	if modifier ~= " "  then --(modKey then
		modifier = modifier.."[] "
	end

	return "#autowrite\n/cast"..modifier..spell.."()"
end

function ActionButton:GetPosition(relFrame)
	local point

	if not relFrame then
		relFrame = self:GetParent()
	end

	local s = self:GetScale()
	local w, h = relFrame:GetWidth()/s, relFrame:GetHeight()/s
	local x, y = self:GetCenter()
	local vert = (y>h/1.5) and "TOP" or (y>h/3) and "CENTER" or "BOTTOM"
	local horz = (x>w/1.5) and "RIGHT" or (x>w/3) and "CENTER" or "LEFT"

	if vert == "CENTER" then
		point = horz
	elseif horz == "CENTER" then
		point = vert
	else
		point = vert..horz
	end

	if vert:find("CENTER") then y = y - h/2 end
	if horz:find("CENTER") then x = x - w/2 end
	if point:find("RIGHT") then x = x - w end
	if point:find("TOP") then y = y - h end

	return point, x, y
end


--This will update the modifier value in a macro when a bar is set with a target conditional
--@spell:  this is hte macro text to be updated
--return: updated macro text
--[[function ActionButton:AutoUpdateMacro(macro)

	local DB = Neuron.db.profile

	if GetModifiedClick("SELFCAST") ~= "NONE"  then
		macro = macro:gsub("%[@player,mod:%u+%]", "[@player,mod:"..GetModifiedClick("SELFCAST").."]")
	else
		macro = macro:gsub("%[@player,mod:%u+%]", "")
	end

	if GetModifiedClick("FOCUSCAST") ~= "NONE"  then
		macro = macro:gsub("%[@focus,mod:%u+%]", "[@focus,exists,mod:"..GetModifiedClick("FOCUSCAST").."]")
	else
		macro = macro:gsub("%[@focus,mod:%u+%]", "")
	end

	if DB.mouseOverMod ~= "NONE"  then
		macro = macro:gsub("%[@mouseover,mod:%u+%]", "[@mouseover,mod:"..DB.mouseOverMod .."]")
		macro = macro:gsub("%[@mouseover,exists]", "[@mouseover,mod:"..DB.mouseOverMod .."]")
	else
		macro = macro:gsub("%[@mouseover,mod:%u+%]", "[@mouseover,exists]")
	end

	return macro
end


-- This will iterate through a set of buttons. For any buttons that have the #autowrite flag in its macro, that
-- macro will then be updated to via AutoWriteMacro to include selected target macro option, or via AutoUpdateMacro
-- to update a current target macro's toggle modifier.
-- @param global(boolean): if true will go though all buttons, else it will just update the button set for the current bar
function ActionButton:UpdateMacroCastTargets(global_update)

	local button_list = {}

	if global_update then

		for _,bar in ipairs(Neuron.bars) do
			for _, object in ipairs(bar.buttons) do
				table.insert(button_list, object)
			end
		end

	else
		local bar = Neuron.currentBar
		for i, object in ipairs(bar.buttons) do
			table.insert(button_list, object)
		end
	end

	for index, button in pairs(button_list) do
		local cur_button = button.DB
		local macro_update = false

		for i = 1,2 do
			for state, info in pairs(cur_button[i]) do
				if info:GetMacroText() and info:GetMacroText():find("#autowrite\n/cast") then
					local spell = ""

					spell = info:GetMacroText():gsub("%[.*%]", "")
					spell = spell:match("#autowrite\n/cast%s*(.+)%((.*)%)")

					if spell then
						if global_update then
							info:SetMacroText(button:AutoUpdateMacro(info.macro_Text))
						else
							info:SetMacroText(button:AutoWriteMacro(spell))
						end

					end
					macro_update = true
				end
			end
		end

		if macro_update then
			button:UpdateFlyout()
			button:InitializeButton()
		end
	end
end]]


-----------------------------------------------------
--------------------- Overrides ---------------------
-----------------------------------------------------

--overwrite function in parent class Button
function ActionButton:UpdateAll()
	--pass to parent UpdateAll function
	Neuron.Button.UpdateAll(self)

	if Neuron.isWoWRetail then
		self:UpdateGlow()
	end
end

function ActionButton.ExtractMacroData(macro)
	if not macro then
		return {}
	end

	-- the results. probably either spell or item will be nil
	local spell, spellID, item, unit

	--extract the parsed contents of a macro and assign them for further processing
	local command, abilityOrItem, target
	for cmd, content in gmatch(macro, "(%c%p%a+)(%C+)") do

		--"cmd" is "/cast" or "/use" or "#autowrite" or "#showtooltip" etc
		--"content" is everything else, like "Chi Torpedo()"

		if cmd then
			cmd = cmd:gsub("^%c+", "") --remove unneeded characters
		end

		if content then
			content = content:gsub("^%s+", "") --remove unneeded characters
		end

		--we only want the first in the list if there is a list, so if the first thing is a "#showtooltip" <ability> then we want to capture the ability
		--if the first line is #showtootltip and it is blank after, we want to ignore this particular loop and jump to the next
		if not abilityOrItem or #abilityOrItem < 1 then
			abilityOrItem, target = SecureCmdOptionParse(content)
			command = cmd
		end
	end

	unit = target or "target"

	if COMMAND_LIST[command] then
		if abilityOrItem and #abilityOrItem > 0 and command:find("/castsequence") then --this always will set the button info the next ability or item in the sequence
			_, item, spell = QueryCastSequence(abilityOrItem) --it will only ever return as either item or spell, never both
		elseif abilityOrItem and #abilityOrItem > 0 then
			if Neuron.itemCache[abilityOrItem:lower()] then --if our abilityOrItem is actually an item in our cache, amend it as such
				item = abilityOrItem
			elseif GetItemInfo(abilityOrItem) then
				item = abilityOrItem
			elseif tonumber(abilityOrItem) and GetInventoryItemLink("player", abilityOrItem) then --in case abilityOrItem is a number and corresponds to a valid inventory item
				item = GetInventoryItemLink("player", abilityOrItem)
			elseif Neuron.spellCache[abilityOrItem:lower()] then
				spell = abilityOrItem
				spellID = Neuron.spellCache[abilityOrItem:lower()].spellID
			elseif GetSpellInfo(abilityOrItem) then
				spell = abilityOrItem
				_,_,_,_,_,_,spellID = GetSpellInfo(abilityOrItem)
			end
		end
	end

	return {spell = spell, spellID = spellID, unit = unit, item = item}
end

--overwrite function in parent class Button
function ActionButton:UpdateData()
	--clear any lingering values before we re-parse and reassign
	self:ClearButton()

	--if we have no macro content then bail immediately
	--if we have an actionID on this button bail immediately
	if self.actionID then
		--don't set any values as they'll get in the way later
		return
	end

	local cleanMacro = self.SanitizedMacro(self:GetMacroText())
	local spellItemUnit = self.ExtractMacroData(cleanMacro)
	self.spell = spellItemUnit.spell
	self.spellID = spellItemUnit.spellID
	self.item = spellItemUnit.item
	self.unit = spellItemUnit.unit
end

--overwrite function in parent class Button
function ActionButton:UpdateVisibility(show)
	if self:HasAction() or Neuron.dragging or show or self.bar:GetShowGrid() or Neuron.buttonEditMode or Neuron.barEditMode or Neuron.bindingMode then
		self.isShown = true
	else
		self.isShown = false
	end

	if not InCombatLockdown() then
		self:SetAttribute("showGrid", self.bar:GetShowGrid()) --this is important because in our state switching code, we can't query self.showGrid directly

		if self.isShown then
			self:Show()
		else
			self:Hide()
		end
	end

	Neuron.Button.UpdateVisibility(self)
end

-----------------------------------------------------------------------------------------
-------------------------------------- Set Icon -----------------------------------------
-----------------------------------------------------------------------------------------


function ActionButton:UpdateIcon()
	local spec = Spec.active(self.bar:GetMultiSpec())
	local state = self.bar.handler:GetAttribute("activestate") or "homestate"

	-- if we have any issues with flyouts or other edge cases, then
	-- then we can build our data from our ActionButton instead of using
	-- the database values. but we need to keep GetAppearance stateless
	-- so that we can use it in other contexts: like the settings dialog
	local data = (
		self.DB
		and self.DB[spec][state]
		or {actionID = self.actionID, macro_Text = self:GetMacroText(), macro_Icon = self:GetMacroIcon()}
	)

	self:ApplyAppearance(self:GetAppearance(data))

	--make sure our button gets the correct Normal texture if we're not using a Masque skin
	self:UpdateNormalTexture()
end

--- @param data genericSpecData: actionID, macro_Text, macro_Icon
--- @return texture, border an icon texture, and an rgb tuple, both nilable
function ActionButton:GetAppearance(data)
	if data.actionID then
		return self.GetActionAppearance(data.actionID)
	end

	local spellItem = self.ExtractMacroData(self.SanitizedMacro(data.macro_Text))
	local spell, item = spellItem.spell, spellItem.item

	local texture, border
	if spell then
		texture, border = self.GetSpellAppearance(spell)
	elseif item then
		texture, border = self.GetItemAppearance(item)
	-- macro must go after spells and items, for blizz macro #showtooltip to work
	elseif data.macro_Icon then
		texture, border = data.macro_Icon, nil
	else
		texture, border = nil, nil
	end

	return texture, border
end

function ActionButton:ApplyAppearance(texture, border)
	if texture then
		self.Icon:SetTexture(texture)
		self.Icon:Show()
	else
		self.Name:SetText("")
		self.Icon:SetTexture("")
		self.Icon:Hide()
	end

	if border then
		self.Border:SetVertexColor(unpack(border))
		self.Border:Show()
	else
		self.Border:Hide()
	end
end

--- @return texture, border an icon texture, and an rgb tuple, both nilable
function ActionButton.GetSpellAppearance(spell)
	--Hide the border in case this button used to have an equipped item in it
	--otherwise it will continue to have a green border until a reload takes place
	local border = nil

	local texture = GetSpellTexture(spell)

	if not texture then
		if Neuron.spellCache[spell:lower()] then
			texture = Neuron.spellCache[spell:lower()].icon
		end
	end

	if not texture then
		texture = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	end

	return texture, border
end

--- @return texture, border an icon texture, and an rgb tuple, both nilable
function ActionButton.GetItemAppearance(item)
	local border = nil
	local texture = GetItemIcon(item)

	if not texture then
		if Neuron.itemCache[item:lower()] then
			texture = GetItemIcon("item:"..Neuron.itemCache[item:lower()]..":0:0:0:0:0:0:0")
		end
	end

	if not texture then
		texture = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	end

	if IsEquippedItem(item) then --makes the border green when item is equipped and dragged to a button
		border = {0, 1.0, 0, 0.2}
	end

	return texture, border
end

--- @return texture, border an icon texture, and an rgb tuple, both nilable
function ActionButton.GetActionAppearance(actionID)
	local texture, border

	if HasAction(actionID) then
		texture = GetActionTexture(actionID) or ""
	end
	return texture, border
end

