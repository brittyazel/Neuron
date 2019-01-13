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

---@class ACTIONBUTTON : BUTTON @define class ACTIONBUTTON inherits from class BUTTON
local ACTIONBUTTON = setmetatable({}, {__index = Neuron.BUTTON}) --this is the metatable for our button object
Neuron.ACTIONBUTTON = ACTIONBUTTON


local SKIN = LibStub("Masque", true)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

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

local macroCache = {}


--Spells that need their primary spell name overwritten
local AlternateSpellNameList = {
	[883]   = true, --CallPet1
	[83242] = true, --CallPet2
	[83243] = true, --CallPet3
	[83244] = true, --CallPet4
	[83245] = true, --CallPet5
}


---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return ACTIONBUTTON @ A newly created ACTIONBUTTON object
function ACTIONBUTTON:new(name)
	local object = CreateFrame("CheckButton", name, UIParent, "NeuronActionButtonTemplate")
	setmetatable(object, {__index = ACTIONBUTTON})
	return object
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

	if InCombatLockdown() then return end

	self:SetAttribute("showGrid", self.showGrid) --this is important because in our state switching code, we can't querry self.showGrid directly
	self:SetAttribute("isshown", show)

	if (show or self.showGrid) then
		self:Show()
	elseif not self:HasAction() and (not Neuron.buttonEditMode or not Neuron.barEditMode or not Neuron.bindingMode) then
		self:Hide()
	end
end



function ACTIONBUTTON:SetAux()
	self:SetSkinned()
	self:UpdateFlyout(true)
end


function ACTIONBUTTON:LoadAux()

	if Neuron.NeuronGUI then
		Neuron.NeuronGUI:ObjEditor_CreateEditFrame(self)
	end
	Neuron.NeuronBinder:CreateBindFrame(self)

end

function ACTIONBUTTON:SetUpEvents()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:RegisterEvent("ACTIONBAR_SHOWGRID")
	self:RegisterEvent("ACTIONBAR_HIDEGRID")

	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:RegisterEvent("UPDATE_MACROS")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("EQUIPMENT_SETS_CHANGED")

	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")

	self:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	self:RegisterEvent("ACTIONBAR_UPDATE_USABLE")

	self:RegisterEvent("SPELL_UPDATE_CHARGES")

	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_ENTERING_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")

	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("BAG_UPDATE")

	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	self:RegisterEvent("UPDATE_POSSESS_BAR")
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")


	self:RegisterEvent("PLAYER_STARTED_MOVING")
	self:RegisterEvent("PLAYER_STOPPED_MOVING")




	--when changing states or going in or out of range, this bucket is meant to catch all of these events
	--[[self:RegisterBucketEvent({"ACTIONBAR_UPDATE_STATE", "SPELL_UPDATE_COOLDOWN", "UPDATE_SHAPESHIFT_COOLDOWN",
	                          "BAG_UPDATE_COOLDOWN", "UPDATE_SHAPESHIFT_FORM", "CURRENT_SPELL_CAST_CHANGED",
	                          "ACTIONBAR_UPDATE_COOLDOWN", "UNIT_AURA", "UPDATE_UI_WIDGET",
	                          "PLAYER_STARTED_MOVING", "PLAYER_STOPPED_MOVING", "BAG_UPDATE"}, 0.1, "UpdateState")]]

	--this is meant to catch all the events when switching targets
	--self:RegisterBucketEvent({"PLAYER_TARGET_CHANGED", "UNIT_TARGET", "UPDATE_MOUSEOVER_UNIT"}, 0.1, "UpdateAll")
end


function ACTIONBUTTON:SetType(save, kill, init)
	--local state = self:GetParent():GetAttribute("activestate")

	self:Reset()

	SecureHandler_OnLoad(self)

	if self.class ~= "flyout" then
		self:SetUpEvents() 
	end

	self:UpdateParse()

	self:SetAttribute("type", "macro")
	self:SetAttribute("*macrotext*", self.macroparse)

	self:SetScript("PreClick", function(self, mousebutton) self:PreClick(mousebutton) end)
	self:SetScript("PostClick", function(self, mousebutton) self:PostClick(mousebutton) end)
	self:SetScript("OnReceiveDrag", function(self, preclick) self:OnReceiveDrag(preclick) end)
	self:SetScript("OnDragStart", function(self, mousebutton) self:OnDragStart(mousebutton) end)
	self:SetScript("OnDragStop", function(self) self:OnDragStop() end)
	self:SetScript("OnAttributeChanged", function(self, name, value) self:OnAttributeChanged(name, value) end)
	self:SetScript("OnEnter", function(self, ...) self:OnEnter(...) end)
	self:SetScript("OnLeave", function(self, ...) self:OnLeave(...) end)

	--self:SetScript("OnShow", function(self) if self.class ~= "flyout" then self:SetUpEvents() end end)
	--self:SetScript("OnHide", function(self) self:UnregisterAllEvents(); end)

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

					self:SetAttribute("useparent-unit", nil)
					self:SetAttribute("activestate", msg)

				end

			]=])


	--this is our rangecheck timer for each button. Every 0.5 seconds it queries if the button is usable
	--this doubles our CPU usage, but it really helps usability quite a bit
	--this is a direct replacement to the old "onUpdate" code that did this job

	if self:TimeLeft(self.rangeTimer) == 0 then
		self.rangeTimer = self:ScheduleRepeatingTimer("UpdateButton", 0.5)
	end

	self:UpdateAll(true)

end



------------------------------------------------------------
--------------General Button Methods------------------------
------------------------------------------------------------


function ACTIONBUTTON:HasAction()
	local hasAction = self.data.macro_Text

	if (self.actionID) then
		if (self.actionID == 0) then
			return true
		else
			return HasAction(self.actionID)
		end

	elseif (hasAction and #hasAction>0) then
		return true
	else
		return false
	end
end


function ACTIONBUTTON:GetDragAction()
	return "macro"
end


function ACTIONBUTTON:UpdateData(...)

	local ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_cd, ud_cdcmd, ud_aura, ud_auracmd, ud_item, ud_target, ud__


	if (self.macroparse) then
		ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_cd, ud_cdcmd, ud_aura, ud_auracmd, ud_item, ud_target, ud__ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil

		for cmd, options in gmatch(self.macroparse, "(%c%p%a+)(%C+)") do
			--after gmatch, remove unneeded characters
			if (cmd) then cmd = cmd:gsub("^%c+", "") end
			if (options) then options = options:gsub("^%s+", "") end

			--find #ud_show option!
			if (not ud_show and cmd:find("^#show")) then
				ud_show = SecureCmdOptionParse(options)
				ud_showcmd = cmd
				--sometimes SecureCmdOptionParse will return "" since that is not what we want, keep looking
			elseif (ud_show and #ud_show < 1 and cmd:find("^#show")) then
				ud_show = SecureCmdOptionParse(options)
				ud_showcmd = cmd
			end

			--find #cdwatch option!
			if (not ud_cd and cmd:find("^#cdwatch")) then
				ud_cd = SecureCmdOptionParse(options); ud_cdcmd = cmd
			elseif (ud_cd and #ud_cd < 1 and cmd:find("^#cdwatch")) then
				ud_cd = SecureCmdOptionParse(options); ud_cdcmd = cmd
			end

			--find #aurawatch option!
			if (not ud_aura and cmd:find("^#aurawatch")) then
				ud_aura = SecureCmdOptionParse(options); ud_auracmd = cmd
			elseif (ud_aura and #ud_aura < 1 and cmd:find("^#aurawatch")) then
				ud_aura = SecureCmdOptionParse(options); ud_auracmd = cmd
			end

			--find the ud_spell!
			if (not ud_spell and cmdSlash[cmd]) then
				ud_spell, ud_target = SecureCmdOptionParse(options); ud_spellcmd = cmd
			elseif (ud_spell and #ud_spell < 1) then
				ud_spell, ud_target = SecureCmdOptionParse(options); ud_spellcmd = cmd
			end
		end

		if (ud_spell and ud_spellcmd:find("/castsequence")) then

			ud__, ud_item, ud_spell = QueryCastSequence(ud_spell)

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

		if (ud_cd) then
			if (ud_cd ~= self.macrocd) then
				if(tonumber(ud_aura) and GetInventoryItemLink("player", ud_cd)) then
					ud_aura = GetInventoryItemLink("player", ud_cd)
				end
				self.macrocd = ud_aura
			end
		else
			self.macrocd = nil
		end

		if (ud_aura) then
			if (ud_aura ~= self.macroaura) then
				if(tonumber(ud_aura) and GetInventoryItemLink("player", ud_aura)) then
					ud_aura = GetInventoryItemLink("player", ud_aura)
				end
				self.macroaura = ud_aura
			end
		else
			self.macroaura = nil
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


function ACTIONBUTTON:UpdateIcon(...)
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

	--druid fix for thrash glow not showing for feral druids.
	--Thrash Guardian: 77758
	--Thrash Feral: 106832
	--But the joint thrash is 106830 (this is the one that results true when the ability is procced)

	--Swipe(Bear): 213771
	--Swipe(Cat): 106785
	--Swipe(NoForm): 213764

	if (self.spellID and IsSpellOverlayed(self.spellID)) then
		self:StartGlow()
	elseif (spell == "Thrash()" and IsSpellOverlayed(106830)) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
		self:StartGlow()
	elseif (spell == "Swipe()" and IsSpellOverlayed(106785)) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
		self:StartGlow()
	elseif (self.glowing) then
		self:StopGlow()
	end

	return texture
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

	self.glowing = true
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

	self.glowing = nil
end


function ACTIONBUTTON:SetSpellState(spell)
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spell)
	if (maxCharges and maxCharges > 1) then
		self.count:SetText(charges)
	else
		self.count:SetText("")
	end

	local count = GetSpellCount(spell)
	if (count and count > 0) then
		self.count:SetText(count)
	end

	if (NeuronCollectionCache[spell:lower()]) then
		spell = NeuronCollectionCache[spell:lower()].spellID

		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell)) then
			self:SetChecked(1)
		else
			self:SetChecked(nil)
		end
	else
		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell)) then
			self:SetChecked(1)
		else
			self:SetChecked(nil)
		end
	end

	self.macroname:SetText(self.data.macro_Name)

	self:UpdateButton()

end


function ACTIONBUTTON:SetItemState(item)

	if (GetItemCount(item,nil,true) and  GetItemCount(item,nil,true) > 1) then
		self.count:SetText(GetItemCount(item,nil,true))
	else
		self.count:SetText("")
	end

	if(IsCurrentItem(item)) then
		self:SetChecked(1)
	else
		self:SetChecked(nil)
	end
	self.macroname:SetText(self.data.macro_Name)
end



function ACTIONBUTTON:UpdateState(...)

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

	elseif (self:GetAttribute("macroShow")) then

		show = self:GetAttribute("macroShow")

		if (NeuronItemCache[show]) then
			self:SetItemState(show)
		else
			self:SetSpellState(show)
		end
	else
		self:SetChecked(nil)
		self.count:SetText("")
	end
end

-----------------------

function ACTIONBUTTON:SetSpellCooldown(spell)

	spell = (spell):lower()

	local start, duration, enable, modrate = GetSpellCooldown(spell)
	local charges, maxCharges, chStart, chDuration, chargemodrate = GetSpellCharges(spell)

	if (charges and maxCharges and maxCharges > 0 and charges < maxCharges) then
		self:SetCooldownTimer(chStart, chDuration, enable, self.cdText, modrate, self.cdcolor1, self.cdcolor2, self.cdAlpha, charges)
	else
		self:SetCooldownTimer(start, duration, enable, self.cdText, chargemodrate, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end

end



function ACTIONBUTTON:SetItemCooldown(item)

	local id = NeuronItemCache[item]

	if (id) then

		local start, duration, enable, modrate = GetItemCooldown(id)

		self:SetCooldownTimer(start, duration, enable, self.cdText, modrate, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end
end


function ACTIONBUTTON:UpdateTexture(force)
	local hasAction = self:HasAction()

	if (not self:GetSkinned()) then
		if (hasAction or force) then
			self:SetNormalTexture(self.hasAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,1)
		else
			self:SetNormalTexture(self.noAction or "")
			self:GetNormalTexture():SetVertexColor(1,1,1,0.5)
		end
	end
end


function ACTIONBUTTON:UpdateAll(updateTexture)
	self:UpdateData()
	self:UpdateButton()
	self:UpdateIcon()
	self:UpdateState()
	self:UpdateTimers()

	if (updateTexture) then
		self:UpdateTexture()
	end
end


function ACTIONBUTTON:UpdateUsableSpell(spell)
	local isUsable, notEnoughMana, alt_Name
	local spellName = spell:lower()

	if (NeuronSpellCache[spellName]) and (NeuronSpellCache[spellName].spellID ~= NeuronSpellCache[spellName].spellID_Alt) and NeuronSpellCache[spellName].spellID_Alt then
		alt_Name = NeuronSpellCache[spellName].altName
		isUsable, notEnoughMana = IsUsableSpell(alt_Name)
		spellName = alt_Name
	else
		isUsable, notEnoughMana = IsUsableSpell(spellName)
	end

	if (notEnoughMana) then
		self.iconframeicon:SetVertexColor(self.manacolor[1], self.manacolor[2], self.manacolor[3])
	elseif (isUsable) then
		if (self.rangeInd and IsSpellInRange(spellName, self.unit) == 0) then
			self.iconframeicon:SetVertexColor(self.rangecolor[1], self.rangecolor[2], self.rangecolor[3])
		elseif NeuronSpellCache[spellName] and (self.rangeInd and IsSpellInRange(NeuronSpellCache[spellName].index,"spell", self.unit) == 0) then
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
	local isUsable, notEnoughMana = IsUsableItem(item)-- or PlayerHasToy(NeuronItemCache[item])
	--local isToy = NeuronToyCache[item]
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


function ACTIONBUTTON:ShowGrid()
	self:SetObjectVisibility(true)
end


function ACTIONBUTTON:HideGrid()
	self:SetObjectVisibility()
end



------------------------------------------------------------------------------
---------------------Event Functions------------------------------------------
------------------------------------------------------------------------------

function ACTIONBUTTON:ACTIONBAR_UPDATE_COOLDOWN(...)
	self:UpdateTimers(...)
end


function ACTIONBUTTON:ACTIONBAR_UPDATE_STATE(...)
	self:UpdateState(...)
end

ACTIONBUTTON.ACTIONBAR_UPDATE_USABLE = ACTIONBUTTON.ACTIONBAR_UPDATE_STATE


--this is mostly for range checking to get super accurate info when starting or stopping if an ability is in range
function ACTIONBUTTON:PLAYER_STARTED_MOVING()
	self:UpdateButton()
end
ACTIONBUTTON.PLAYER_STOPPED_MOVING = ACTIONBUTTON.PLAYER_STARTED_MOVING


function ACTIONBUTTON:BAG_UPDATE_COOLDOWN(...)

	if (self.macroitem) then
		self:UpdateState(...)
	end
end


ACTIONBUTTON.BAG_UPDATE = ACTIONBUTTON.BAG_UPDATE_COOLDOWN


function ACTIONBUTTON:UNIT_AURA(...)
	local unit = select(1, ...)

	if (Neuron.unitAuras[unit]) then
		self:UpdateAuraWatch(self, unit, self.macrospell)

		if (unit == "player") then
			self:UpdateData(...)
			self:UpdateTimers()
		end
	end
end


ACTIONBUTTON.UPDATE_MOUSEOVER_UNIT = ACTIONBUTTON.UNIT_AURA



function ACTIONBUTTON:UNIT_SPELLCAST_INTERRUPTED(...)

	local unit = select(1, ...)

	if ((unit == "player" or unit == "pet") and self.macrospell) then

		self:UpdateTimers(...)
	end

end


ACTIONBUTTON.UNIT_SPELLCAST_FAILED = ACTIONBUTTON.UNIT_SPELLCAST_INTERRUPTED
ACTIONBUTTON.UNIT_PET = ACTIONBUTTON.UNIT_SPELLCAST_INTERRUPTED
ACTIONBUTTON.UNIT_ENTERED_VEHICLE = ACTIONBUTTON.UNIT_SPELLCAST_INTERRUPTED
ACTIONBUTTON.UNIT_ENTERING_VEHICLE = ACTIONBUTTON.UNIT_SPELLCAST_INTERRUPTED
ACTIONBUTTON.UNIT_EXITED_VEHICLE = ACTIONBUTTON.UNIT_SPELLCAST_INTERRUPTED


function ACTIONBUTTON:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(...)
	local spellID = select(2, ...)

	if (self.spellGlow and self.spellID and spellID == self.spellID) then

		self:UpdateTimers(...)

		self:StartGlow()
	end
end

function ACTIONBUTTON:PLAYER_TARGET_CHANGED(...)
	self:UpdateTimers()
end


ACTIONBUTTON.PLAYER_FOCUS_CHANGED = ACTIONBUTTON.PLAYER_TARGET_CHANGED



function ACTIONBUTTON:SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(...)
	local spellID = select(2, ...)

	if ((self.overlay or self.spellGlow) and self.spellID and spellID == self.spellID) then

		self:StopGlow()
	end
end


function ACTIONBUTTON:ACTIVE_TALENT_GROUP_CHANGED(...)

	if(InCombatLockdown()) then
		return
	end

	local spec

	if (self.multiSpec) then
		spec = GetSpecialization()
	else
		spec = 1
	end

	self:LoadData(spec, self:GetParent():GetAttribute("activestate") or "homestate")
	self:UpdateFlyout()
	self:SetType()
	self:UpdateAll(true)
	self:SetObjectVisibility()

end


function ACTIONBUTTON:PLAYER_ENTERING_WORLD(...)

	WorldFrame:SetScript("OnMouseDown", function() self:OnMouseDown() end)

	self:MACRO_Reset()
	self:UpdateAll(true)

	self:SetObjectVisibility()

	Neuron.NeuronBinder:ApplyBindings(self)

end


function ACTIONBUTTON:MODIFIER_STATE_CHANGED(...)
	self:UpdateAll(true)
end



function ACTIONBUTTON:ACTIONBAR_SLOT_CHANGED(...)
	if (self.data.macro_Watch or self.data.macro_Equip) then
		self:UpdateIcon()
	end
end


function ACTIONBUTTON:ACTIONBAR_SHOWGRID(...)
	self:ShowGrid()
end


function ACTIONBUTTON:ACTIONBAR_HIDEGRID(...)
	self:HideGrid()
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
		self:UpdateAll(true)
	end
end

ACTIONBUTTON.UPDATE_POSSESS_BAR = ACTIONBUTTON.UPDATE_VEHICLE_ACTIONBAR
ACTIONBUTTON.UPDATE_OVERRIDE_ACTIONBAR = ACTIONBUTTON.UPDATE_VEHICLE_ACTIONBAR

--for 4.x compatibility
ACTIONBUTTON.UPDATE_BONUS_ACTIONBAR = ACTIONBUTTON.UPDATE_VEHICLE_ACTIONBAR


function ACTIONBUTTON:SPELL_UPDATE_CHARGES(...)

	local spell = self.macrospell
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spell)

	if (maxCharges and maxCharges > 1) then
		self.count:SetText(charges)
	else
		self.count:SetText("")
	end
end


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------


function ACTIONBUTTON:PlaceSpell(action1, action2, spellID)
	local spell

	if (action1 == 0) then
		-- I am unsure under what conditions (if any) we wouldn't have a spell ID
		if not spellID or spellID == 0 then
			return
		end
	else
		spell,_= GetSpellBookItemName(action1, action2):lower()
		_,spellID = GetSpellBookItemInfo(action1, action2)
	end


	local spellInfoName, icon

	if (NeuronSpellCache[spell]) then
		spellInfoName = NeuronSpellCache[spell].spellName
		icon = GetSpellTexture(spell) --try getting a new texture first (this is important for things like Wild Charge that has different icons per spec
		if not icon then --if you don't find a new icon (meaning the spell isn't currently learned) default to icon in the database
			icon = NeuronSpellCache[spell].icon
		end
	else
		spellInfoName , _, icon = GetSpellInfo(spellID)
	end

	if AlternateSpellNameList[spellID] or not spell then
		self.data.macro_Text = self:AutoWriteMacro(spellInfoName)
		self.data.macro_Auto = spellInfoName..";"
	else
		self.data.macro_Text = self:AutoWriteMacro(spell)

		self.data.macro_Auto = spell
	end

	self.data.macro_Icon = icon  --also set later in SetSpellIcon
	self.data.macro_Name = spellInfoName
	self.data.macro_Watch = false
	self.data.macro_Equip = false
	self.data.macro_Note = ""
	self.data.macro_UseNote = false

	if (not self.cursor) then
		self:SetType(true)
	end

	Neuron.macroDrag[1] = false

	ClearCursor()
	SetCursor(nil)

end

function ACTIONBUTTON:PlacePetAbility(action1, action2)

	local spellID = action1
	local spellIndex = action2

	if spellIndex then --if the ability doesn't have a spellIndex, i.e (passive, follow, defensive, etc, print a warning)
		local spellInfoName , _, icon, castTime, minRange, maxRange= GetSpellInfo(spellID)

		self.data.macro_Text = self:AutoWriteMacro(spellInfoName)

		self.data.macro_Auto = spellInfoName


		self.data.macro_Icon = icon --also set later in SetSpellIcon
		self.data.macro_Name = spellInfoName
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end
	else
		Neuron:Print("Sorry, you cannot place that ability at this time.")
	end

	Neuron.macroDrag[1] = false

	ClearCursor()
	SetCursor(nil)

end


function ACTIONBUTTON:PlaceItem(action1, action2, hasAction)
	local item, link = GetItemInfo(action2)

	if link and not NeuronItemCache[item] then --add the item to the itemcache if it isn't otherwise in it
		local _, itemID = link:match("(item:)(%d+)")
		NeuronItemCache[item] = itemID
	end

	if (IsEquippableItem(item)) then
		self.data.macro_Text = "/equip "..item.."\n/use "..item
	else
		self.data.macro_Text = "/use "..item
	end

	self.data.macro_Icon = false
	self.data.macro_Name = item
	self.data.macro_Auto = false
	self.data.macro_Watch = false
	self.data.macro_Equip = false
	self.data.macro_Note = ""
	self.data.macro_UseNote = false

	if (not self.cursor) then
		self:SetType(true)
	end

	Neuron.macroDrag[1] = false

	ClearCursor()
	SetCursor(nil)
end


function ACTIONBUTTON:PlaceBlizzMacro(action1)
	if (action1 == 0) then
		return
	else

		local name, icon, body = GetMacroInfo(action1)

		if (body) then

			self.data.macro_Text = body
			self.data.macro_Name = name
			self.data.macro_Watch = name
			self.data.macro_Icon = icon
		else
			self.data.macro_Text = ""
			self.data.macro_Name = ""
			self.data.macro_Watch = false
			self.data.macro_Icon = false
		end

		self.data.macro_Equip = false
		self.data.macro_Auto = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function ACTIONBUTTON:PlaceBlizzEquipSet(equipmentSetName)
	if (equipmentSetName == 0) then
		return
	else

		local equipsetNameIndex = 0 ---cycle through the equipment sets to find the index of the one with the right name

		for i = 1,C_EquipmentSet.GetNumEquipmentSets() do
			if equipmentSetName == C_EquipmentSet.GetEquipmentSetInfo(i) then
				equipsetNameIndex = i
			end
		end


		local name, icon = C_EquipmentSet.GetEquipmentSetInfo(equipsetNameIndex)
		if (texture) then
			self.data.macro_Text = "/equipset "..equipmentSetName
			self.data.macro_Equip = equipmentSetName
			self.data.macro_Name = name
			self.data.macro_Icon = icon
		else
			self.data.macro_Text = ""
			self.data.macro_Equip = false
			self.data.macro_Name = ""
			self.data.macro_Icon = false
		end

		self.data.macro_Name = ""
		self.data.macro_Watch = false
		self.data.macro_Auto = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


--Hooks mount journal mount buttons on enter to pull spellid from tooltip--
--Based on discusion thread http://www.wowinterface.com/forums/showthread.php?t=49599&page=2
--More dynamic than the manual list that was originally implemente




function ACTIONBUTTON:PlaceMount(action1, action2, hasAction)


	local mountName, mountSpellID, mountIcon = C_MountJournal.GetMountInfoByID(action1)

	if (action1 == 0) then
		return
	else
		--The Summon Random Mount from the Mount Journal
		if action1 == 268435455 then
			self.data.macro_Text = "#autowrite\n/run C_MountJournal.SummonByID(0);"
			self.data.macro_Auto = "Random Mount;"
			self.data.macro_Icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_MOUNTUP"
			self.data.macro_Name = "Random Mount"
			--Any other mount from the Journal
		else

			self.data.macro_Text = "#autowrite\n/cast "..mountName..";"
			self.data.macro_Auto = mountName..";"
			self.data.macro_Icon = mountIcon
			self.data.macro_Name = mountName
		end

		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function ACTIONBUTTON:PlaceCompanion(action1, action2, hasAction)

	if (action1 == 0) then
		return

	else
		local _, _, spellID, icon = GetCompanionInfo(action2, action1)
		local name = GetSpellInfo(spellID)

		if (name) then
			self.data.macro_Name = name
			self.data.macro_Text = self:AutoWriteMacro(name)
			self.data.macro_Auto = name
		else
			self.data.macro_Name = ""
			self.data.macro_Text = ""
			self.data.macro_Auto = false
		end

		self.data.macro_Icon = icon
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end

function ACTIONBUTTON:PlaceBattlePet(action1, action2, hasAction)
	local petName, petIcon

	if (action1 == 0) then
		return
	else
		_, _, _, _, _, _, _,petName, petIcon= C_PetJournal.GetPetInfoByPetID(action1)

		self.data.macro_Text = "#autowrite\n/summonpet "..petName
		self.data.macro_Auto = petName..";"
		self.data.macro_Icon = petIcon
		self.data.macro_Name = petName
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false


		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function ACTIONBUTTON:PlaceFlyout(action1, action2, hasAction)
	if (action1 == 0) then
		return
	else
		local count = #self.bar.buttons
		local columns = self.bar.data.columns or count
		local rows = count/columns

		local point = self:GetPosition(UIParent)

		if (columns/rows > 1) then

			if ((point):find("BOTTOM")) then
				point = "b:t:1"
			elseif ((point):find("TOP")) then
				point = "t:b:1"
			elseif ((point):find("RIGHT")) then
				point = "r:l:12"
			elseif ((point):find("LEFT")) then
				point = "l:r:12"
			else
				point = "r:l:12"
			end
		else
			if ((point):find("RIGHT")) then
				point = "r:l:12"
			elseif ((point):find("LEFT")) then
				point = "l:r:12"
			elseif ((point):find("BOTTOM")) then
				point = "b:t:1"
			elseif ((point):find("TOP")) then
				point = "t:b:1"
			else
				point = "r:l:12"
			end
		end

		self.data.macro_Text = "/flyout blizz:"..action1..":l:"..point..":c"
		self.data.macro_Icon = false
		self.data.macro_Name = ""
		self.data.macro_Auto = false
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		self:UpdateFlyout(true)

		if (not self.cursor) then
			self:SetType(true)
		end

		Neuron.macroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function ACTIONBUTTON:PlaceMacro()
	self.data.macro_Text = Neuron.macroDrag[3]
	self.data.macro_Icon = Neuron.macroDrag[4]
	self.data.macro_Name = Neuron.macroDrag[5]
	self.data.macro_Auto = Neuron.macroDrag[6]
	self.data.macro_Watch = Neuron.macroDrag[7]
	self.data.macro_Equip = Neuron.macroDrag[8]
	self.data.macro_Note = Neuron.macroDrag[9]
	self.data.macro_UseNote = Neuron.macroDrag[10]

	if (not self.cursor) then
		self:SetType(true)
	end

	PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)

	wipe(Neuron.macroDrag);
	ClearCursor();
	SetCursor(nil);

	self:UpdateFlyout()
	Neuron:ToggleButtonGrid(false)

end


function ACTIONBUTTON:PickUpMacro()
	local pickup

	if (not self.barLock) then
		pickup = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		pickup = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		pickup = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		pickup = true
	end

	if (pickup) then
		local texture, move = self.iconframeicon:GetTexture()

		if (macroCache[1]) then  ---triggers when picking up an existing button with a button in the cursor

			wipe(Neuron.macroDrag)

			for k,v in pairs(macroCache) do
				Neuron.macroDrag[k] = v
			end

			wipe(macroCache)

			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")


		elseif (self:HasAction()) then
			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")

			Neuron.macroDrag[1] = self:GetDragAction()
			Neuron.macroDrag[2] = self
			Neuron.macroDrag[3] = self.data.macro_Text
			Neuron.macroDrag[4] = self.data.macro_Icon
			Neuron.macroDrag[5] = self.data.macro_Name
			Neuron.macroDrag[6] = self.data.macro_Auto
			Neuron.macroDrag[7] = self.data.macro_Watch
			Neuron.macroDrag[8] = self.data.macro_Equip
			Neuron.macroDrag[9] = self.data.macro_Note
			Neuron.macroDrag[10] = self.data.macro_UseNote
			Neuron.macroDrag.texture = texture

			self.data.macro_Text = ""
			self.data.macro_Icon = false
			self.data.macro_Name = ""
			self.data.macro_Auto = false
			self.data.macro_Watch = false
			self.data.macro_Equip = false
			self.data.macro_Note = ""
			self.data.macro_UseNote = false

			self.macrospell = nil
			self.spellID = nil
			self.macroitem = nil
			self.macroshow = nil
			self.macroicon = nil

			self:UpdateFlyout()

			self:SetType(true)

		end

	end
end

---This is the function that fires when a button is receiving a dragged item
function ACTIONBUTTON:OnReceiveDrag(preclick)
	if (InCombatLockdown()) then
		return
	end

	local cursorType, action1, action2, spellID = GetCursorInfo()

	local texture = self.iconframeicon:GetTexture()

	if (self:HasAction()) then
		wipe(macroCache)

		---macroCache holds on to the previos macro's info if you are dropping a new macro on top of an existing macro
		macroCache[1] = self:GetDragAction()
		macroCache[2] = self
		macroCache[3] = self.data.macro_Text
		macroCache[4] = self.data.macro_Icon
		macroCache[5] = self.data.macro_Name
		macroCache[6] = self.data.macro_Auto
		macroCache[7] = self.data.macro_Watch
		macroCache[8] = self.data.macro_Equip
		macroCache[9] = self.data.macro_Note
		macroCache[10] = self.data.macro_UseNote

		macroCache.texture = texture
	end


	if (Neuron.macroDrag[1]) then
		self:PlaceMacro()
	elseif (cursorType == "spell") then
		self:PlaceSpell(action1, action2, spellID, self:HasAction())

	elseif (cursorType == "item") then
		self:PlaceItem(action1, action2, self:HasAction())

	elseif (cursorType == "macro") then
		self:PlaceBlizzMacro(action1)

	elseif (cursorType == "equipmentset") then
		self:PlaceBlizzEquipSet(action1)

	elseif (cursorType == "mount") then
		self:PlaceMount(action1, action2, self:HasAction())

	elseif (cursorType == "flyout") then
		self:PlaceFlyout(action1, action2, self:HasAction())

	elseif (cursorType == "battlepet") then
		self:PlaceBattlePet(action1, action2, self:HasAction())
	elseif(cursorType == "companion") then
		self:PlaceCompanion(action1, action2, self:HasAction())
	elseif (cursorType == "petaction") then
		self:PlacePetAbility(action1, action2)
	end


	if (Neuron.startDrag and macroCache[1]) then
		self:PickUpMacro()
		Neuron:ToggleButtonGrid(true)
	end

	self:UpdateAll(true)

	Neuron.startDrag = false

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		Neuron.NeuronGUI:UpdateObjectGUI()
	end
end

---this is the function that fires when you begin dragging an item
function ACTIONBUTTON:OnDragStart(mousebutton)

	if (InCombatLockdown() or not self.bar or self.vehicle_edit or self.actionID) then
		Neuron.startDrag = false
		return
	end

	self.drag = nil

	if (not self.barLock) then
		self.drag = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		self.drag = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		self.drag = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		self.drag = true
	end

	if (self.drag) then
		Neuron.startDrag = self:GetParent():GetAttribute("activestate")

		self.dragbutton = mousebutton
		self:PickUpMacro()

		if (Neuron.macroDrag[1]) then
			--PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)

			if (Neuron.macroDrag[2] ~= self) then
				self.dragbutton = nil
			end

			Neuron:ToggleButtonGrid(true)
		else
			self.dragbutton = nil
		end

		self:UpdateAll()

		self.iconframecooldown.timer:SetText("")

		self.macroname:SetText("")
		self.count:SetText("")

		self.macrospell = nil
		self.spellID = nil
		self.actionID = nil
		self.macroitem = nil
		self.macroshow = nil
		self.macroicon = nil

		self.border:Hide()

		---shows all action bar buttons in the case you have show grid turned off


	else
		Neuron.startDrag = false
	end

end


function ACTIONBUTTON:OnDragStop()
	self.drag = nil
end


---This function will be used to check if we should release the cursor
function ACTIONBUTTON:OnMouseDown()
	if Neuron.macroDrag[1] then
		PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)
		wipe(Neuron.macroDrag)

		for index, bar in pairs(Neuron.BARIndex) do
			bar:UpdateObjectVisibility()
		end
	end
end



function ACTIONBUTTON:PreClick(mousebutton)
	self.cursor = nil

	if (not InCombatLockdown() and MouseIsOver(self)) then
		local cursorType = GetCursorInfo()

		if (cursorType or Neuron.macroDrag[1]) then
			self.cursor = true

			Neuron.startDrag = self:GetParent():GetAttribute("activestate")

			self:SetType(true)

			Neuron:ToggleButtonGrid(true)

			self:OnReceiveDrag(true)

		elseif (mousebutton == "MiddleButton") then
			self.middleclick = self:GetAttribute("type")

			self:SetAttribute("type", "")

		end
	end

	Neuron.ClickedButton = self
end


function ACTIONBUTTON:PostClick(mousebutton)
	if (not InCombatLockdown() and MouseIsOver(self)) then

		if (self.cursor) then
			self:SetType(true)

			self.cursor = nil

		elseif (self.middleclick) then
			self:SetAttribute("type", self.middleclick)

			self.middleclick = nil
		end
	end
	self:UpdateState()
end


function ACTIONBUTTON:SetSpellTooltip(spell)

	if (NeuronSpellCache[spell]) then

		local spell_id = NeuronSpellCache[spell].spellID


		local zoneability_id = ZoneAbilityFrame.SpellButton.currentSpellID

		if spell_id == 161691 and zoneability_id then
			spell_id = zoneability_id
		end


		if (self.UberTooltips) then
			GameTooltip:SetSpellByID(spell_id)
		else
			spell = NeuronSpellCache[spell].spellName
			GameTooltip:SetText(spell, 1, 1, 1)
		end


	elseif (NeuronCollectionCache[spell]) then

		if (self.UberTooltips and NeuronCollectionCache[spell].creatureType =="MOUNT") then
			GameTooltip:SetHyperlink("spell:"..NeuronCollectionCache[spell].spellID)
		else
			GameTooltip:SetText(NeuronCollectionCache[spell].creatureName, 1, 1, 1)
		end

		self.UpdateTooltip = nil
	end
end


function ACTIONBUTTON:SetItemTooltip(item)
	local name, link = GetItemInfo(item)

	if (NeuronToyCache[item:lower()]) then
		if (self.UberTooltips) then
			local itemID = NeuronToyCache[item:lower()]
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


function ACTIONBUTTON:SetTooltip(edit)
	self.UpdateTooltip = nil

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.actionID) then
		self:ACTION_SetTooltip(self.actionID)

	elseif (show and #show>0) then
		if(NeuronItemCache[show]) then
			self:SetItemTooltip(show)
		else
			self:SetSpellTooltip(show:lower())
		end

	elseif (spell and #spell>0) then
		self:SetSpellTooltip(spell:lower())

	elseif (item and #item>0) then
		self:SetItemTooltip(item)

	elseif (self:GetAttribute("macroShow")) then
		show = self:GetAttribute("macroShow")

		if(NeuronItemCache[show]) then
			self:SetItemTooltip(show)
		else
			self:SetSpellTooltip(show:lower())
		end

	elseif (self.data.macro_Text and #self.data.macro_Text > 0) then
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

		if(Neuron.macroDrag[1]) then ---puts the icon back to the interact icon when moving abilities around and the mouse enteres the WorldFrame
		SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")
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

			---Part 1 of Druid Prowl overwrite fix
			-----------------------------------------------------
			---breaks out of the loop due to flag set below
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

				---Part 2 of Druid Prowl overwrite fix
				---------------------------------------------------
				---druids have an issue where once stance will get immediately overwritten by another. I.E. stealth immediately getting overwritten by homestate if they go immediately into prowl from caster form
				---this conditional sets a flag to ignore the next most stance flag, as that one is most likely in error and should be ignored
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
			self:UpdateAll(true)
		end

		if (name == "update") then
			self:UpdateAll(true)
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
		spec = GetSpecialization()
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
	self:SetAttribute("useparent-unit", nil)
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
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:UnregisterEvent("UPDATE_MACROS")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("EQUIPMENT_SETS_CHANGED")

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

		self:SetAttribute("useparent-unit", nil)
		self:SetAttribute("activestate", msg)

	end
end


--this will generate a spell macro
--spell: name of spell to use
--subname: subname of spell to use (optional)
--return: macro text
function ACTIONBUTTON:AutoWriteMacro(spell)

	local DB = Neuron.db.profile

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
		if (actionID == 0) then
			if (self.specAction and Neuron.SPECIALACTIONS[self.specAction]) then
				self.iconframeicon:SetTexture(Neuron.SPECIALACTIONS[self.specAction])
			else
				self.iconframeicon:SetTexture(0,0,0)
			end

		else
			self.macroname:SetText(GetActionText(actionID))
			if (HasAction(actionID)) then
				self.iconframeicon:SetTexture(GetActionTexture(actionID))
			else
				self.iconframeicon:SetTexture(0,0,0)
			end
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