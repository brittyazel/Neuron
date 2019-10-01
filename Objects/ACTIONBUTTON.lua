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
--along with this add-on.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2019.

---@class ACTIONBUTTON : BUTTON @define class ACTIONBUTTON inherits from class BUTTON
local ACTIONBUTTON = setmetatable({}, {__index = Neuron.BUTTON}) --this is the metatable for our button object
Neuron.ACTIONBUTTON = ACTIONBUTTON


---------------------------------------------------------
-------------------declare globals-----------------------
---------------------------------------------------------

local cmdSlash = {
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
}

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return ACTIONBUTTON @ A newly created ACTIONBUTTON object
function ACTIONBUTTON.new(bar, buttonID, defaults)

	--call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.BUTTON.new(bar, buttonID, ACTIONBUTTON, "ActionBar", "ActionButton", "NeuronActionButtonTemplate")

	if (defaults) then
		newButton:SetDefaults(defaults)
	end

	if Neuron.NeuronGUI then
		Neuron.NeuronGUI:ObjEditor_CreateEditFrame(newButton)
	end

	return newButton
end



function ACTIONBUTTON.updateAuraInfo(unit)

	local uai_index, uai_spell, uai_count, uai_duration, uai_timeLeft, uai_caster, uai_spellID, _
	uai_index = 1

	wipe(Neuron.unitAuras[unit])

	repeat
		uai_spell, _, uai_count, _, uai_duration, uai_timeLeft, uai_caster, _, _, uai_spellID = UnitAura(unit, uai_index, "HELPFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			Neuron.unitAuras[unit][uai_spell:lower()] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			Neuron.unitAuras[unit][uai_spell:lower().."()"] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)

	uai_index = 1

	repeat
		uai_spell, _, uai_count, _, uai_duration, uai_timeLeft, uai_caster = UnitAura(unit, uai_index, "HARMFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			Neuron.unitAuras[unit][uai_spell:lower()] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			Neuron.unitAuras[unit][uai_spell:lower().."()"] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)
end




function ACTIONBUTTON:LoadData(spec, state)

	self.config = self.DB.config
	self.keys = self.DB.keys

	self.statedata = self.DB[spec] --all of the states for a given spec
	self.data = self.statedata[state] --loads a single state of a single spec into self.data

	self:BuildStateData()
end




function ACTIONBUTTON:SetObjectVisibility(show)

	if self:HasAction() or show or self.showGrid or Neuron.buttonEditMode or Neuron.barEditMode or Neuron.bindingMode then
		self.isShown = true
	else
		self.isShown = false
	end

	Neuron.BUTTON.SetObjectVisibility(self) --call parent function

end


function ACTIONBUTTON:SetUpEvents()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:RegisterEvent("ACTIONBAR_SHOWGRID")
	self:RegisterEvent("ACTIONBAR_HIDEGRID")

	self:RegisterEvent("UPDATE_MACROS")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")

	self:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	self:RegisterEvent("ACTIONBAR_UPDATE_USABLE")

	self:RegisterEvent("SPELL_UPDATE_CHARGES")
	self:RegisterEvent("SPELLS_CHANGED")


	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self:RegisterEvent("UNIT_PET")


	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("BAG_UPDATE")


	self:RegisterEvent("PLAYER_STARTED_MOVING")
	self:RegisterEvent("PLAYER_STOPPED_MOVING")


	--Makes the action button get checked on and off when opening the trade skill UI widget
	self:RegisterEvent("TRADE_SKILL_SHOW")
	self:RegisterEvent("TRADE_SKILL_CLOSE")

	if not Neuron.isWoWClassic then
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		self:RegisterEvent("EQUIPMENT_SETS_CHANGED")
		self:RegisterEvent("UNIT_ENTERED_VEHICLE")
		self:RegisterEvent("UNIT_ENTERING_VEHICLE")
		self:RegisterEvent("UNIT_EXITED_VEHICLE")
		self:RegisterEvent("PLAYER_FOCUS_CHANGED")

		self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
		self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

		self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
		self:RegisterEvent("UPDATE_POSSESS_BAR")
		self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
		self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")

		--Makes it so the mount icon gets checked on and off appropriately
		self:RegisterEvent("COMPANION_UPDATE")
	end

end


function ACTIONBUTTON:SetType()

	self:Reset()

	SecureHandler_OnLoad(self)

	if self.class ~= "flyout" then
		self:SetUpEvents()
	end

	self:UpdateParse()

	self:SetAttribute("type", "macro")
	self:SetAttribute("*macrotext*", self.macroparse)

	self:SetScript("PostClick", function(self, mousebutton) self:PostClick(mousebutton) end)
	self:SetScript("OnReceiveDrag", function(self, preclick) self:OnReceiveDrag(preclick) end)
	self:SetScript("OnDragStart", function(self, mousebutton) self:OnDragStart(mousebutton) end)

	--this is to allow for the correct releasing of the button when dragging icons off of the bar
	--we need to hook to the WorldFrame OnReceiveDrag and OnMouseDown so that we can "let go" of the spell when we drag it off the bar
	if not Neuron:IsHooked(WorldFrame, "OnReceiveDrag") then
		Neuron:HookScript(WorldFrame, "OnReceiveDrag", function() ACTIONBUTTON:WorldFrame_OnReceiveDrag() end)
	end
	if not Neuron:IsHooked(WorldFrame, "OnMouseDown") then
		Neuron:HookScript(WorldFrame, "OnMouseDown", function() ACTIONBUTTON:WorldFrame_OnReceiveDrag() end)
	end

	self:SetScript("OnAttributeChanged", function(self, name, value) self:OnAttributeChanged(name, value) end)
	self:SetScript("OnEnter", function(self, ...) self:OnEnter(...) end)
	self:SetScript("OnLeave", function(self, ...) self:OnLeave(...) end)

	--This is so that hotkeypri works properly with priority/locked buttons
	self:WrapScript(self, "OnShow", [[
						for i=1,select('#',(":"):split(self:GetAttribute("hotkeys"))) do
							self:SetBindingClick(self:GetAttribute("hotkeypri"), select(i,(":"):split(self:GetAttribute("hotkeys"))), self:GetName())
						end
						]])

	self:WrapScript(self, "OnHide", [[
						if (not self:GetParent():GetAttribute("concealed")) then
							for key in gmatch(self:GetAttribute("hotkeys"), "[^:]+") do
								self:ClearBinding(key)
							end
						end
						]])


	--new action ID's for vehicle 133-138
	--new action ID's for possess 133-138
	--new action ID's for override 157-162

	self:SetAttribute("overrideID_Offset", 156)
	self:SetAttribute("vehicleID_Offset", 132)

	self:SetAttribute("_childupdate", [=[

				if (message) then

					local msg = (":"):split(message)

					if (msg:find("vehicle")) then

						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))
							
						end

						self:SetAttribute("SpecialAction", "vehicle")
						self:SetAttribute("HasActionID", true)
						self:Show()

					elseif (msg:find("possess")) then

						if (not self:GetAttribute(msg.."-actionID")) then
							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))

						end

						self:SetAttribute("SpecialAction", "possess")
						self:SetAttribute("HasActionID", true)
						self:Show()

					elseif (msg:find("override")) then
						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("overrideID_Offset"))
							self:SetAttribute("HasActionID", true)

						end

						self:SetAttribute("SpecialAction", "override")

						self:SetAttribute("HasActionID", true)

						self:Show()

					else
						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "macro")
							self:SetAttribute("*macrotext*", self:GetAttribute(msg.."-macro_Text"))

							if (self:GetAttribute("*macrotext*") and #self:GetAttribute("*macrotext*") > 0) or self:GetAttribute("isshown") then
								self:Show()
							elseif (not self:GetAttribute("showGrid")) then
								self:Hide()
							end

							self:SetAttribute("HasActionID", false)
						else
							self:SetAttribute("HasActionID", true)
						end

						self:SetAttribute("SpecialAction", nil)
					end

					self:SetAttribute("activestate", msg)

				end

			]=])


	--this is our rangecheck timer for each button. Every 0.5 seconds it queries if the button is usable
	--this doubles our CPU usage, but it really helps usability quite a bit
	--this is a direct replacement to the old "onUpdate" code that did this job

	if self:TimeLeft(self.rangeTimer) == 0 then
		self.rangeTimer = self:ScheduleRepeatingTimer("UpdateButton", 0.5)
	end

	self:UpdateAll()

	self:UpdateFlyout(true)

	self:SetSkinned()

end



------------------------------------------------------------
--------------General Button Methods------------------------
------------------------------------------------------------

function ACTIONBUTTON:GetDragAction()
	return "macro"
end


function ACTIONBUTTON:UpdateData(...)

	local ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_item, ud_target


	if (self.macroparse) then
		ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_item, ud_target = nil, nil, nil, nil, nil, nil, nil, nil

		for cmd, options in gmatch(self.macroparse, "(%c%p%a+)(%C+)") do

			--cmd is "/cast" or "/use" etc
			--options is everything else, like "Chi Torpedo()"

			--after gmatch, remove unneeded characters
			if (cmd) then
				cmd = cmd:gsub("^%c+", "")
			end

			if (options) then
				options = options:gsub("^%s+", "")
			end

			--find #ud_show option!
			if (not ud_show and cmd:find("^#show")) then
				ud_show = SecureCmdOptionParse(options)
				ud_showcmd = cmd
				--sometimes SecureCmdOptionParse will return "" since that is not what we want, keep looking
			elseif (ud_show and #ud_show < 1 and cmd:find("^#show")) then
				ud_show = SecureCmdOptionParse(options)
				ud_showcmd = cmd
			end

			--find the ud_spell!
			if (not ud_spell and cmdSlash[cmd]) then
				ud_spell, ud_target = SecureCmdOptionParse(options)
				ud_spellcmd = cmd
			elseif (ud_spell and #ud_spell < 1) then
				ud_spell, ud_target = SecureCmdOptionParse(options)
				ud_spellcmd = cmd
			end
		end

		if (ud_spell and ud_spellcmd:find("/castsequence")) then

			_, ud_item, ud_spell = QueryCastSequence(ud_spell)

		elseif (ud_spell) then

			if (#ud_spell < 1) then
				ud_spell = nil

			elseif(NeuronItemCache[ud_spell]) then

				ud_item = ud_spell
				ud_spell = nil


			elseif(tonumber(ud_spell) and GetInventoryItemLink("player", ud_spell)) then
				ud_item = GetInventoryItemLink("player", ud_spell)
				ud_spell = nil
			end
		end

		self.unit = ud_target or "target"

		if (ud_spell) then
			self.macroitem = nil

			if (ud_spell ~= self.macrospell) then

				ud_spell = ud_spell:gsub("!", "")
				self.macrospell = ud_spell

				if (NeuronSpellCache[ud_spell:lower()]) then
					self.spellID = NeuronSpellCache[ud_spell:lower()].spellID
				else
					self.spellID = nil
				end
			end

		else
			self.macrospell = nil
			self.spellID = nil
		end

		if (ud_show and ud_showcmd:find("#showicon")) then
			if (ud_show ~= self.macroicon) then
				if(tonumber(ud_show) and GetInventoryItemLink("player", ud_show)) then
					ud_show = GetInventoryItemLink("player", ud_show)
				end
				self.macroicon = ud_show
				self.macroshow = nil
			end
		elseif (ud_show) then
			if (ud_show ~= self.macroshow) then
				if(tonumber(ud_show) and GetInventoryItemLink("player", ud_show)) then
					ud_show = GetInventoryItemLink("player", ud_show)
				end
				self.macroshow = ud_show
				self.macroicon = nil
			end
		else
			self.macroshow = nil
			self.macroicon = nil
		end

		if (ud_item) then
			self.macrospell = nil;
			self.spellID = nil
			if (ud_item ~= self.macroitem) then
				self.macroitem = ud_item
			end
		else
			self.macroitem = nil
		end
	end
end


function ACTIONBUTTON:SetSpellIcon(spell)
	local _, texture

	if (not self.data.macro_Watch and not self.data.macro_Equip) then

		spell = (spell):lower()

		if (NeuronSpellCache[spell]) then
			texture = GetSpellTexture(spell) --try getting a new texture first (this is important for things like Wild Charge that has different icons per spec

			if not texture then --if you don't find a new icon (meaning the spell isn't currently learned) default to icon in the database
				texture = NeuronSpellCache[spell].icon
			end

		elseif (NeuronCollectionCache[spell]) then
			texture = NeuronCollectionCache[spell].icon

		elseif (spell) then
			texture = GetSpellTexture(spell)
		end

		if (texture) then
			self.iconframeicon:SetTexture(texture)
			self.iconframeicon:Show()
		else
			self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") --show questionmark instead of empty button to avoid confusion
		end

	else
		if (self.data.macro_Watch) then

			_, texture = GetMacroInfo(self.data.macro_Watch)

			self.data.macro_Icon = texture

		end

		if (texture) then
			self.iconframeicon:SetTexture(texture)
			self.iconframeicon:Show()
		else
			self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end
	end

	return texture
end



function ACTIONBUTTON:SetItemIcon(item)
	local name,texture, link, itemID

	if (IsEquippedItem(item)) then --makes the border green when item is equipped and dragged to a button
		self.border:SetVertexColor(0, 1.0, 0, 0.2)
		self.border:Show()
	else
		self.border:Hide()
	end

	--There is stored icon and dont want to update icon on fly
	if (((type(self.data.macro_Icon) == "string" and #self.data.macro_Icon > 0) or type(self.data.macro_Icon) == "number")) then
		if (self.data.macro_Icon == "BLANK") then
			self.iconframeicon:SetTexture("")
		else
			self.iconframeicon:SetTexture(self.data.macro_Icon)
		end

	else
		if (NeuronItemCache[item]) then
			texture = GetItemIcon("item:"..NeuronItemCache[item]..":0:0:0:0:0:0:0")
		else
			name,_,_,_,_,_,_,_,_,texture = GetItemInfo(item)
		end

		if (texture) then
			self.iconframeicon:SetTexture(texture)
		else
			self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end
	end

	self.iconframeicon:Show()

	return self.iconframeicon:GetTexture()
end


function ACTIONBUTTON:UpdateGlow()
	if (self.spellGlow and self.spellID) then

		--druid fix for thrash glow not showing for feral druids.
		--Thrash Guardian: 77758
		--Thrash Feral: 106832
		--But the joint thrash is 106830 (this is the one that results true when the ability is procced)

		--Swipe(Bear): 213771
		--Swipe(Cat): 106785
		--Swipe(NoForm): 213764

		if (self.macrospell and self.macrospell:lower() == "thrash()" and IsSpellOverlayed(106830)) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
			self:StartGlow()
		elseif (self.macrospell and self.macrospell:lower() == "swipe()" and IsSpellOverlayed(106785)) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
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


function ACTIONBUTTON:StartGlow()

	if self.spellGlow then
		if (self.spellGlowDef) then
			ActionButton_ShowOverlayGlow(self)
		elseif (self.spellGlowAlt) then
			self.shine:Show()
			AutoCastShine_AutoCastStart(self.shine);
		end
	end
end

function ACTIONBUTTON:StopGlow()

	if self.spellGlow then
		if (self.spellGlowDef) then
			ActionButton_HideOverlayGlow(self)
		elseif (self.spellGlowAlt) then
			self.shine:Hide()
			AutoCastShine_AutoCastStop(self.shine);
		end
	end
end


function ACTIONBUTTON:SetSpellState(spell)

	if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell)) then
		self:SetChecked(1)
	else
		self:SetChecked(nil)
	end


	self.macroname:SetText(self.data.macro_Name)

	self:UpdateSpellCount(spell)

	self:UpdateButton()

end


function ACTIONBUTTON:SetItemState(item)

	if(IsCurrentItem(item)) then
		self:SetChecked(1)
	else
		self:SetChecked(nil)
	end

	self.macroname:SetText(self.data.macro_Name)

	self:UpdateItemCount(item)
end


-----------------------


function ACTIONBUTTON:UpdateUsableSpell(spell)
	local isUsable, notEnoughMana
	local spellName = spell:lower()

	isUsable, notEnoughMana = IsUsableSpell(spellName)

	if (notEnoughMana) then
		self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])
	elseif (isUsable) then
		if (self.rangeInd and IsSpellInRange(spellName, self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		elseif NeuronSpellCache[spellName] and NeuronSpellCache[spellName].index and (self.rangeInd and IsSpellInRange(NeuronSpellCache[spellName].index,"spell", self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end

	else
		if (NeuronSpellCache[(spell):lower()]) then
			self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end
	end
end


function ACTIONBUTTON:UpdateUsableItem(item)
	local isUsable, notEnoughMana = IsUsableItem(item)

	if NeuronToyCache[item:lower()] then isUsable = true end

	if (notEnoughMana and self.manacolor) then
		self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])
	elseif (isUsable) then
		if (self.rangeInd and IsItemInRange(spell, self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		else
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end

	else
		self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end


------------------------------------------------------------------------------
---------------------Event Functions------------------------------------------
------------------------------------------------------------------------------

function ACTIONBUTTON:ACTIONBAR_UPDATE_COOLDOWN()
	self:UpdateTimers()
end


function ACTIONBUTTON:ACTIONBAR_UPDATE_STATE(...)
	if not GetCursorInfo() then
		self:UpdateAll()
	end
end

ACTIONBUTTON.ACTIONBAR_UPDATE_USABLE = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE
ACTIONBUTTON.COMPANION_UPDATE = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE

ACTIONBUTTON.TRADE_SKILL_SHOW = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE
ACTIONBUTTON.TRADE_SKILL_CLOSE = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE

ACTIONBUTTON.UNIT_PET = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE
ACTIONBUTTON.UNIT_ENTERED_VEHICLE = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE
ACTIONBUTTON.UNIT_ENTERING_VEHICLE = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE
ACTIONBUTTON.UNIT_EXITED_VEHICLE = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE

ACTIONBUTTON.PLAYER_TARGET_CHANGED = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE
ACTIONBUTTON.PLAYER_FOCUS_CHANGED = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE


--this is mostly for range checking to get super accurate info when starting or stopping if an ability is in range
function ACTIONBUTTON:PLAYER_STARTED_MOVING()
	self:UpdateButton()
end
ACTIONBUTTON.PLAYER_STOPPED_MOVING = ACTIONBUTTON.PLAYER_STARTED_MOVING


function ACTIONBUTTON:BAG_UPDATE_COOLDOWN()

	if (self.macroitem) then
		self:UpdateState()
	end
end


ACTIONBUTTON.BAG_UPDATE = ACTIONBUTTON.BAG_UPDATE_COOLDOWN


function ACTIONBUTTON:UNIT_SPELLCAST_INTERRUPTED(...)

	local unit = select(1, ...)

	if ((unit == "player" or unit == "pet") and self.macrospell) then

		self:UpdateTimers()
	end

end


ACTIONBUTTON.UNIT_SPELLCAST_FAILED = ACTIONBUTTON.UNIT_SPELLCAST_INTERRUPTED


function ACTIONBUTTON:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW()
	self:UpdateGlow()
end

ACTIONBUTTON.SPELL_ACTIVATION_OVERLAY_GLOW_HIDE = ACTIONBUTTON.SPELL_ACTIVATION_OVERLAY_GLOW_SHOW


function ACTIONBUTTON:ACTIVE_TALENT_GROUP_CHANGED(...)
	Neuron.activeSpec = GetSpecialization()

	if(InCombatLockdown()) then
		return
	end

	local spec

	if (self.multiSpec) then
		spec = Neuron.activeSpec
	else
		spec = 1
	end

	self:LoadData(spec, self:GetParent():GetAttribute("activestate") or "homestate")
	self:UpdateFlyout()
	self:SetType()
	self:UpdateAll()
	self:SetObjectVisibility()

end


function ACTIONBUTTON:PLAYER_ENTERING_WORLD(...)

	self:MACRO_Reset()
	self:UpdateAll()

	self:SetObjectVisibility()

	self.binder:ApplyBindings()


	if self.flyout then --this is a hack to get around CallPet not working on initial login. (weirdly it worked on /reload, but not login)
		self:ScheduleTimer(function() self:SetType() end, 1)
	end

end


function ACTIONBUTTON:SPELLS_CHANGED(...)
	self:UpdateAll()

	if not Neuron.isWoWClassic then
		self:UpdateGlow()
	end
end

ACTIONBUTTON.MODIFIER_STATE_CHANGED = ACTIONBUTTON.SPELLS_CHANGED



function ACTIONBUTTON:ACTIONBAR_SLOT_CHANGED(...)
	if (self.data.macro_Watch or self.data.macro_Equip) then
		self:UpdateIcon()
	end
end


function ACTIONBUTTON:ACTIONBAR_SHOWGRID(...)
	Neuron:ToggleButtonGrid(true)
end


function ACTIONBUTTON:ACTIONBAR_HIDEGRID(...)
	Neuron:ToggleButtonGrid()
end


function ACTIONBUTTON:UPDATE_MACROS(...)
	if (Neuron.enteredWorld and not InCombatLockdown() and self.data.macro_Watch) then
		self:PlaceBlizzMacro(self.data.macro_Watch)
	end
end


function ACTIONBUTTON:EQUIPMENT_SETS_CHANGED(...)
	if (Neuron.enteredWorld and not InCombatLockdown() and self.data.macro_Equip) then
		self:PlaceBlizzEquipSet(self.data.macro_Equip)
	end
end


function ACTIONBUTTON:PLAYER_EQUIPMENT_CHANGED(...)
	if (self.data.macro_Equip) then
		self:UpdateIcon()
	end
end


function ACTIONBUTTON:UPDATE_VEHICLE_ACTIONBAR(...)

	if (self.actionID) then
		self:UpdateAll()
	end
end

ACTIONBUTTON.UPDATE_POSSESS_BAR = ACTIONBUTTON.UPDATE_VEHICLE_ACTIONBAR
ACTIONBUTTON.UPDATE_OVERRIDE_ACTIONBAR = ACTIONBUTTON.UPDATE_VEHICLE_ACTIONBAR

--for 4.x compatibility
ACTIONBUTTON.UPDATE_BONUS_ACTIONBAR = ACTIONBUTTON.UPDATE_VEHICLE_ACTIONBAR


function ACTIONBUTTON:SPELL_UPDATE_CHARGES(...)

	local spell = self.macrospell

	self:UpdateSpellCount(spell)

end


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------





function ACTIONBUTTON:SetSpellTooltip(spell)

	if (NeuronSpellCache[spell]) then

		local spell_id = NeuronSpellCache[spell].spellID

		if (self.UberTooltips) then
			GameTooltip:SetSpellByID(spell_id)
		else
			GameTooltip:SetText(NeuronSpellCache[spell:lower()].spellName, 1, 1, 1)
		end


	elseif (NeuronCollectionCache[spell]) then

		if (self.UberTooltips and NeuronCollectionCache[spell].creatureType =="MOUNT") then
			GameTooltip:SetHyperlink("spell:"..NeuronCollectionCache[spell].spellID)
		else
			GameTooltip:SetText(NeuronCollectionCache[spell].creatureName, 1, 1, 1)
		end

		self.UpdateTooltip = nil
	else
		local spell_id, spellName

		spellName,_,_,_,_,_,spell_id = GetSpellInfo(spell)

		if spellName and spell_id then --add safety check in case spellName and spell_id come back as nil
			if (self.UberTooltips ) then
				GameTooltip:SetSpellByID(spell_id)
			else
				GameTooltip:SetText(spellName, 1, 1, 1)
			end

		else
			GameTooltip:SetText(UNKNOWN, 1, 1, 1)
		end

	end
end


function ACTIONBUTTON:SetItemTooltip(item)
	local name, link = GetItemInfo(item)

	if (NeuronToyCache[item]) then
		if (self.UberTooltips) then
			local itemID = NeuronToyCache[item]
			GameTooltip:ClearLines()
			GameTooltip:SetToyByItemID(itemID)
		else
			GameTooltip:SetText(name, 1, 1, 1)
		end

	elseif (link) then
		if (self.UberTooltips) then
			GameTooltip:SetHyperlink(link)
		else
			GameTooltip:SetText(name, 1, 1, 1)
		end

	elseif (NeuronItemCache[item]) then
		if (self.UberTooltips) then
			GameTooltip:SetHyperlink("item:"..NeuronItemCache[item]..":0:0:0:0:0:0:0")
		else
			GameTooltip:SetText(NeuronItemCache[item], 1, 1, 1)
		end
	end
end


function ACTIONBUTTON:SetTooltip()
	self.UpdateTooltip = nil

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.actionID) then
		self:ACTION_SetTooltip(self.actionID)

	elseif (show and #show>0) then
		if(NeuronItemCache[show]) then
			self:SetItemTooltip(show:lower())
		else
			self:SetSpellTooltip(show:lower())
		end

	elseif (spell and #spell>0) then
		self:SetSpellTooltip(spell:lower())

	elseif (item and #item>0) then
		self:SetItemTooltip(item:lower())

	elseif (self.data.macro_Text and #self.data.macro_Text > 0) then --condition in case the item is an equipment set. Should probably make this cleaner
		local equipset = self.data.macro_Text:match("/equipset%s+(%C+)")

		if (equipset) then
			equipset = equipset:gsub("%pnobtn:2%p ", "")
			GameTooltip:SetEquipmentSet(equipset)
		elseif (self.data.macro_Name and #self.data.macro_Name>0) then
			GameTooltip:SetText(self.data.macro_Name)
		end
	end
end


function ACTIONBUTTON:OnEnter(...)
	if (self.bar) then
		if (self.tooltipsCombat and InCombatLockdown()) then
			return
		end

		if (self.tooltips) then
			if (self.tooltipsEnhanced) then
				self.UberTooltips = true
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			else
				self.UberTooltips = false
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			end

			self:SetTooltip()

			GameTooltip:Show()
		end

		if (self.flyout and self.flyout.arrow) then
			self.flyout.arrow:SetPoint(self.flyout.arrowPoint, self.flyout.arrowX/0.625, self.flyout.arrowY/0.625)
		end

	end
end


function ACTIONBUTTON:OnLeave(...)
	self.UpdateTooltip = nil

	GameTooltip:Hide()

	if (self.flyout and self.flyout.arrow) then
		self.flyout.arrow:SetPoint(self.flyout.arrowPoint, self.flyout.arrowX, self.flyout.arrowY)
	end
end


function ACTIONBUTTON:OnAttributeChanged(name, value)

	if (value and self.data) then
		if (name == "activestate") then

			--Part 1 of Druid Prowl overwrite fix
			-----------------------------------------------------
			--breaks out of the loop due to flag set below
			if (Neuron.class == "DRUID" and self.ignoreNextOverrideStance == true and value == "homestate") then
				self.ignoreNextOverrideStance = nil
				self.bar:SetState("stealth") --have to add this in otherwise the button icons change but still retain the homestate ability actions
				return
			else
				self.ignoreNextOverrideStance = nil
			end
			-----------------------------------------------------
			-----------------------------------------------------

			if (self:GetAttribute("HasActionID")) then
				self.actionID = self:GetAttribute("*action*")
			else

				if (not self.statedata[value]) then
					self.statedata[value] = {}
				end

				--Part 2 of Druid Prowl overwrite fix
				---------------------------------------------------
				--druids have an issue where once stance will get immediately overwritten by another. I.E. stealth immediately getting overwritten by homestate if they go immediately into prowl from caster form
				--this conditional sets a flag to ignore the next most stance flag, as that one is most likely in error and should be ignored
				if(Neuron.class == "DRUID" and value == "stealth1") then
					self.ignoreNextOverrideStance = true
				end
				------------------------------------------------------
				------------------------------------------------------


				self.data = self.statedata[value]

				self:UpdateParse()

				self:MACRO_Reset()

				self.actionID = false
			end

			--This will remove any old button state data from the saved varabiels/memory
			--for id,data in pairs(self.bar.data) do
			for id,data in pairs(self.statedata) do
				if (self.bar.data[id:match("%a+")]) or (id == "" and self.bar.data["custom"])  then
				elseif not self.bar.data[id:match("%a+")] then
					self.statedata[id]= nil
				end
			end

			self.specAction = self:GetAttribute("SpecialAction") --?
			self:UpdateAll()
		end

		if (name == "update") then
			self:UpdateAll()
		end
	end


end


function ACTIONBUTTON:MACRO_Reset()
	self.macrospell = nil
	self.spellID = nil
	self.macroitem = nil
	self.macroshow = nil
	self.macroicon = nil
end


function ACTIONBUTTON:UpdateParse()
	self.macroparse = self.data.macro_Text

	if (#self.macroparse > 0) then
		self.macroparse = "\n"..self.macroparse.."\n"
		self.macroparse = (self.macroparse):gsub("(%c+)", " %1")
	else
		self.macroparse = nil
	end
end



function ACTIONBUTTON:UpdateButtonSpec(bar)

	local spec

	if (bar.data.multiSpec) then
		spec = Neuron.activeSpec
	else
		spec = 1
	end

	self:SetData(bar)
	self:LoadData(spec, bar.handler:GetAttribute("activestate"))
	self:UpdateFlyout()
	self:SetType()
	self:SetObjectVisibility()

end



function ACTIONBUTTON:BuildStateData()
	for state, data in pairs(self.statedata) do
		self:SetAttribute(state.."-macro_Text", data.macro_Text)
		self:SetAttribute(state.."-actionID", data.actionID)
	end
end


function ACTIONBUTTON:Reset()
	self:SetAttribute("unit", nil)
	self:SetAttribute("type", nil)
	self:SetAttribute("type1", nil)
	self:SetAttribute("type2", nil)
	self:SetAttribute("*action*", nil)
	self:SetAttribute("*macrotext*", nil)
	self:SetAttribute("*action1", nil)
	self:SetAttribute("*macrotext2", nil)

	self:UnregisterEvent("ITEM_LOCK_CHANGED")
	self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:UnregisterEvent("ACTIONBAR_SHOWGRID")
	self:UnregisterEvent("ACTIONBAR_HIDEGRID")
	self:UnregisterEvent("PET_BAR_SHOWGRID")
	self:UnregisterEvent("PET_BAR_HIDEGRID")
	self:UnregisterEvent("PET_BAR_UPDATE")
	self:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN")
	self:UnregisterEvent("UNIT_FLAGS")

	self:UnregisterEvent("UPDATE_MACROS")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")

	if not Neuron.isWoWClassic then
		self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		self:UnregisterEvent("EQUIPMENT_SETS_CHANGED")
	end

	self:MACRO_Reset()
end

---This function is used to "fake" a state change in the button editor so you can see what each state will look like
function ACTIONBUTTON:SetFauxState(state)
	if (state) then

		local msg = (":"):split(state)

		if (msg:find("vehicle")) then

			if (not self:GetAttribute(msg.."-actionID")) then

				self:SetAttribute("type", "action")
				self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))

			end

			self:SetAttribute("SpecialAction", "vehicle")
			self:SetAttribute("HasActionID", true)
			self:Show()

		elseif (msg:find("possess")) then
			if (not self:GetAttribute(msg.."-actionID")) then

				self:SetAttribute("type", "action")
				self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))
			end

			self:SetAttribute("SpecialAction", "possess")
			self:SetAttribute("HasActionID", true)
			self:Show()

		elseif (msg:find("override")) then
			if (not self:GetAttribute(msg.."-actionID")) then

				self:SetAttribute("type", "action")
				self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("overrideID_Offset"))
				self:SetAttribute("HasActionID", true)

			end

			self:SetAttribute("SpecialAction", "override")

			self:SetAttribute("HasActionID", true)

			self:Show()

		else
			if (not self:GetAttribute(msg.."-actionID")) then

				self:SetAttribute("type", "macro")
				self:SetAttribute("*self*", self:GetAttribute(msg.."-macro_Text"))

				if (self:GetAttribute("*macrotext*") and #self:GetAttribute("*macrotext*") > 0) or self:GetAttribute("isshown") then
					self:Show()
				elseif (not self:GetAttribute("showGrid")) then
					self:Hide()
				end

				self:SetAttribute("HasActionID", false)
			else
				self:SetAttribute("HasActionID", true)
			end

			self:SetAttribute("SpecialAction", nil)
		end

		self:SetAttribute("activestate", msg)

	end
end


--this will generate a spell macro
--spell: name of spell to use
--subname: subname of spell to use (optional)
--return: macro text
function ACTIONBUTTON:AutoWriteMacro(spell)

	local DB = Neuron.db.profile

	local spellName
	local spellID

	local altName
	local altSpellID


	--if there is an alt name associated with a given ability, and the alt name is known (i.e. the base spell) use the alt name instead
	--This is important because a macro written with the base name "/cast Roll()" will work for talented abilities, but "/cast Chi Torpedo" won't work for base abilities
	if NeuronSpellCache[spell:lower()] then
		spellName = NeuronSpellCache[spell:lower()].spellName
		spellID = NeuronSpellCache[spell:lower()].spellID

		altName = NeuronSpellCache[spell:lower()].altName
		altSpellID = NeuronSpellCache[spell:lower()].altSpellID

		if altSpellID and IsSpellKnown(altSpellID) then
			spell = altName
		else
			spell = spellName
		end
	else
		_,_,_,_,_,_,spellID = GetSpellInfo(spell)
	end

	local modifier, modKey = " ", nil
	local bar = Neuron.CurrentBar or self.bar

	if (bar.data.mouseOverCast and DB.mouseOverMod ~= "NONE" ) then
		modKey = DB.mouseOverMod
		modifier = modifier.."[@mouseover,mod:"..modKey.."]"
	elseif (bar.data.mouseOverCast and DB.mouseOverMod == "NONE" ) then
		modifier = modifier.."[@mouseover,exists]"
	end

	if (bar.data.selfCast and GetModifiedClick("SELFCAST") ~= "NONE" ) then
		modKey = GetModifiedClick("SELFCAST")
		modifier = modifier.."[@player,mod:"..modKey.."]"
	end

	if (bar.data.focusCast and GetModifiedClick("FOCUSCAST") ~= "NONE" ) then
		modKey = GetModifiedClick("FOCUSCAST")
		modifier = modifier.."[@focus,exists,mod:"..modKey.."]"
	end

	if (bar.data.rightClickTarget) then
		modKey = ""
		modifier = modifier.."[@player"..modKey..",btn:2]"
	end

	if (modifier ~= " " ) then --(modKey) then
		modifier = modifier.."[] "
	end

	return "#autowrite\n/cast"..modifier..spell.."()"
end


--This will update the modifier value in a macro when a bar is set with a target conditional
--@spell:  this is hte macro text to be updated
--return: updated macro text
function ACTIONBUTTON:AutoUpdateMacro(macro)

	local DB = Neuron.db.profile

	if (GetModifiedClick("SELFCAST") ~= "NONE" ) then
		macro = macro:gsub("%[@player,mod:%u+%]", "[@player,mod:"..GetModifiedClick("SELFCAST").."]")
	else
		macro = macro:gsub("%[@player,mod:%u+%]", "")
	end

	if (GetModifiedClick("FOCUSCAST") ~= "NONE" ) then
		macro = macro:gsub("%[@focus,mod:%u+%]", "[@focus,exists,mod:"..GetModifiedClick("FOCUSCAST").."]")
	else
		macro = macro:gsub("%[@focus,mod:%u+%]", "")
	end

	if (DB.mouseOverMod ~= "NONE" ) then
		macro = macro:gsub("%[@mouseover,mod:%u+%]", "[@mouseover,mod:"..DB.mouseOverMod .."]")
		macro = macro:gsub("%[@mouseover,exists]", "[@mouseover,mod:"..DB.mouseOverMod .."]")
	else
		macro = macro:gsub("%[@mouseover,mod:%u+%]", "[@mouseover,exists]")
	end

	--macro = info.macro_Text:gsub("%[.*%]", "")
	return macro
end



function ACTIONBUTTON:GetPosition(oFrame)
	local relFrame, point

	if (oFrame) then
		relFrame = oFrame
	else
		relFrame = self:GetParent()
	end

	local s = self:GetScale()
	local w, h = relFrame:GetWidth()/s, relFrame:GetHeight()/s
	local x, y = self:GetCenter()
	local vert = (y>h/1.5) and "TOP" or (y>h/3) and "CENTER" or "BOTTOM"
	local horz = (x>w/1.5) and "RIGHT" or (x>w/3) and "CENTER" or "LEFT"

	if (vert == "CENTER") then
		point = horz
	elseif (horz == "CENTER") then
		point = vert
	else
		point = vert..horz
	end

	if (vert:find("CENTER")) then y = y - h/2 end
	if (horz:find("CENTER")) then x = x - w/2 end
	if (point:find("RIGHT")) then x = x - w end
	if (point:find("TOP")) then y = y - h end

	return point, x, y
end



----ACTION functions
--this is used in things like the possess/vehicle/override bars

function ACTIONBUTTON:ACTION_SetIcon(action)
	local actionID = tonumber(action)

	if (actionID) then

		self.macroname:SetText(GetActionText(actionID))
		if (HasAction(actionID)) then
			self.iconframeicon:SetTexture(GetActionTexture(actionID))
		else
			self.iconframeicon:SetTexture(0,0,0)
		end

		self.iconframeicon:Show()
	else
		self.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
	end

	return self.iconframeicon:GetTexture()
end



function ACTIONBUTTON:ACTION_UpdateState(action)
	local actionID = tonumber(action)

	self.count:SetText("")

	if (actionID) then
		self.macroname:SetText("")

		if (IsCurrentAction(actionID) or IsAutoRepeatAction(actionID)) then
			self:SetChecked(1)
		else
			self:SetChecked(nil)
		end
	else
		self:SetChecked(nil)
	end
end


function ACTIONBUTTON:ACTION_UpdateUsable(action)
	local actionID = tonumber(action)

	if (actionID) then
		if (actionID == 0) then
			self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		else
			local isUsable, notEnoughMana = IsUsableAction(actionID)

			if (isUsable) then
				if (IsActionInRange(action, self.unit) == 0) then
					self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
				else
					self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
				end

			elseif (notEnoughMana and self.manacolor) then
				self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])
			else
				self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end

	else
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end


function ACTIONBUTTON:ACTION_SetTooltip(action)
	local actionID = tonumber(action)

	if (actionID) then

		self.UpdateTooltip = nil

		if (HasAction(actionID)) then
			GameTooltip:SetAction(actionID)
		end
	end
end


--- This will itterate through a set of buttons. For any buttons that have the #autowrite flag in its macro, that
-- macro will then be updated to via AutoWriteMacro to include selected target macro option, or via AutoUpdateMacro
-- to update a current target macro's toggle mofifier.
-- @param global(boolean): if true will go though all buttons, else it will just update the button set for the current bar
function ACTIONBUTTON:UpdateMacroCastTargets(global_update)

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
							info.macro_Text = button:AutoUpdateMacro(info.macro_Text)
						else
							info.macro_Text = button:AutoWriteMacro(spell)
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

function ACTIONBUTTON:UpdateButton(...)

	if (self.editmode) then

		self.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)

	elseif (self.actionID) then

		self:ACTION_UpdateUsable(self.actionID)

	elseif (self.macroshow and #self.macroshow>0) then

		if(NeuronItemCache[self.macroshow]) then
			self:UpdateUsableItem(self.macroshow)
		else
			self:UpdateUsableSpell(self.macroshow)
		end

	elseif (self.macrospell and #self.macrospell>0) then

		self:UpdateUsableSpell(self.macrospell)

	elseif (self.macroitem and #self.macroitem>0) then

		self:UpdateUsableItem(self.macroitem)

	else
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end

function ACTIONBUTTON:UpdateIcon()
	self.updateMacroIcon = nil

	local spell, item, show, texture = self.macrospell, self.macroitem, self.macroshow, self.macroicon

	if (self.actionID) then
		texture = self:ACTION_SetIcon(self.actionID)
	elseif (show and #show>0) then
		if(NeuronItemCache[show]) then
			texture = self:SetItemIcon(show)
		else
			texture = self:SetSpellIcon(show)
			self:SetSpellState(show)
		end
	elseif (spell and #spell>0) then
		texture = self:SetSpellIcon(spell)
		self:SetSpellState(spell)
	elseif (item and #item>0) then
		texture = self:SetItemIcon(item)
	elseif (self.data.macro_Icon) then
		self.iconframeicon:SetTexture(self.data.macro_Icon)
		self.iconframeicon:Show()
	else
		self.macroname:SetText("")
		self.iconframeicon:SetTexture("")
		self.iconframeicon:Hide()
		self.border:Hide()
	end
end

function ACTIONBUTTON:UpdateState()

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.actionID) then
		self:ACTION_UpdateState(self.actionID)

	elseif (show and #show>0) then

		if (NeuronItemCache[show]) then
			self:SetItemState(show)
		else
			self:SetSpellState(show)
		end

	elseif (spell and #spell>0) then

		self:SetSpellState(spell)

	elseif (item and #item>0) then

		self:SetItemState(item)

	else
		self:SetChecked(nil)
		self.count:SetText("")
	end
end
