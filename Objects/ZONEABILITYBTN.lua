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

---@class ZONEABILITYBTN : BUTTON @define class ZONEABILITYBTN inherits from class BUTTON
local ZONEABILITYBTN = setmetatable({}, {__index = Neuron.BUTTON}) --this is the metatable for our button object
Neuron.ZONEABILITYBTN = ZONEABILITYBTN


local SKIN = LibStub("Masque", true)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")



local ZoneAbilitySpellID



---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return ZONEABILITYBTN @ A newly created ZONEABILITYBTN object
function ZONEABILITYBTN:new(name)
	local object = CreateFrame("CheckButton", name, UIParent, "NeuronActionButtonTemplate")
	setmetatable(object, {__index = ZONEABILITYBTN})
	return object
end



function ZONEABILITYBTN:UpdateButton()
	if (self.editmode) then
		self.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)
	elseif (self.spellName) then
		self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	else
		self.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)

	end
	self.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)

end

function ZONEABILITYBTN:OnUpdate(elapsed)

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > Neuron.THROTTLE) then

		self:UpdateButton()

		self.elapsed = 0
	end

end

function ZONEABILITYBTN:SetNeuronButtonTex()

	local _, _, _, _, _, _, spellID = GetSpellInfo(self.baseName);

	local texture = ZONE_SPELL_ABILITY_TEXTURES_BASE[spellID] or ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK
	self.style:SetTexture(texture)

	self.style:Show() --this actually show/hide the fancy button theme surrounding the bar. If you wanted to do a toggle for the style, it should be here.
end


function ZONEABILITYBTN:ZoneAbilityFrame_Update()

	if (not self.baseName) then
		return;
	end

	local name, _, tex, _, _, _, spellID = GetSpellInfo(self.baseName);

	self.CurrentTexture = tex;
	self.CurrentSpell = name;
	self.iconframeicon:SetTexture(tex);
	self:SetNeuronButtonTex()


	local start, duration, enable, modrate = GetSpellCooldown(name);


	if (start) then
		self:SetCooldownTimer(start, duration, enable, self.cdText, modrate, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end

	self.spellName = self.CurrentSpell;
	self.spellID = spellID;

	if (self.spellName and not InCombatLockdown()) then
		self:SetAttribute("*macrotext1", "/cast " .. self.spellName .. "();")
	end
end



function ZONEABILITYBTN:PLAYER_ENTERING_WORLD( event, ...)
	if InCombatLockdown() then return end
	Neuron.NeuronBinder:ApplyBindings(self)
end



---TODO: This should get roped into AceEvent
function ZONEABILITYBTN:OnEvent(event, ...)

	local spellID, spellType = GetZoneAbilitySpellInfo();

	self.baseName = GetSpellInfo(spellID);
	ZoneAbilitySpellID = spellID

	if event == "PLAYER_ENTERING_WORLD" then
		self:PLAYER_ENTERING_WORLD(event, ...)
	end


	if (spellID) then

		if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY) and garrisonType == LE_GARRISON_TYPE_6_0 ) then
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY, true );
		end

		self:ZoneAbilityFrame_Update();

		if (not InCombatLockdown()) then
			self:Show();
		end
	end

	self.spellID = spellID;
	self:SetObjectVisibility()
end


function ZONEABILITYBTN:SetTooltip()
	if (GetSpellInfo(ZoneAbilitySpellID)) then
		if (self.UberTooltips) then
			GameTooltip:SetSpellByID(self.spellID)
		else
			GameTooltip:SetText(self.tooltipName)
		end
	end

end


function ZONEABILITYBTN:OnEnter(...)

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
	end
end


function ZONEABILITYBTN:SetObjectVisibility(show)

	if (GetZoneAbilitySpellInfo() or show) then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		self:SetAlpha(1)
	elseif not Neuron.buttonEditMode and not Neuron.barEditMode and not Neuron.bindingMode then
		self:SetAlpha(0)
	end
end

function ZONEABILITYBTN:LoadAux()
	self.spellID = ZoneAbilitySpellID;
	Neuron.NeuronBinder:CreateBindFrame(self)
	self.style = self:CreateTexture(nil, "OVERLAY")
	self.style:SetPoint("CENTER", -2, 1)
	self.style:SetWidth(190)
	self.style:SetHeight(95)
	self.hotkey:SetPoint("TOPLEFT", -4, -6)
	self.style:SetTexture("Interface\\ExtraButton\\GarrZoneAbility-Armory")
end



function ZONEABILITYBTN:OnLoad()
	-- empty
end

function ZONEABILITYBTN:OnShow()
	self:ZoneAbilityFrame_Update();
end

function ZONEABILITYBTN:OnHide()

end


function ZONEABILITYBTN:UpdateFrame()

	local DB = Neuron.db.profile

	if DB.zoneabilitybar[1].border then

		NeuronZoneActionButton1.style:Show()
	else
		NeuronZoneActionButton1.style:Hide()
	end

end

function ZONEABILITYBTN:OnDragStart()
	PickupSpell(ZoneAbilitySpellID)
end


function ZONEABILITYBTN:SetType(save)

	self:RegisterUnitEvent("UNIT_AURA", "player")
	self:RegisterEvent("SPELLS_CHANGED", "OnEvent")
	self:RegisterEvent("ZONE_CHANGED", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "OnEvent")


	self.actionID = self.id

	self:SetAttribute("type1", "macro")
	self:SetAttribute("*action1", self.actionID)

	self:SetAttribute("useparent-unit", false)
	self:SetAttribute("unit", ATTRIBUTE_NOOP)

	self:SetScript("OnDragStart", function(self) self:OnDragStart() end)
	self:SetScript("OnLoad", function(self) self:OnLoad() end)
	self:SetScript("OnShow", function(self) self:OnShow() end)
	self:SetScript("OnHide", function(self) self:OnHide() end)
	self:SetScript("OnEnter", function(self, ...) self:OnEnter(...) end)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:SetScript("OnUpdate", function(self, elapsed) self:OnUpdate(elapsed) end)
	self:SetScript("OnAttributeChanged", nil)

	self:SetObjectVisibility()
end