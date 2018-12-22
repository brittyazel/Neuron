--Neuron, a World of Warcraft® user interface addon.

---@class EXTRABTN : BUTTON @define class EXTRABTN inherits from class BUTTON
local EXTRABTN = setmetatable({}, { __index = Neuron.BUTTON })
Neuron.EXTRABTN = EXTRABTN




local SKIN = LibStub("Masque", true)
local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")



---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param name string @ Name given to the new button frame
---@return EXTRABTN @ A newly created EXTRABTN object
function EXTRABTN:new(name)
	local object = CreateFrame("CheckButton", name, UIParent, "NeuronActionButtonTemplate")
	setmetatable(object, {__index = EXTRABTN})
	return object
end


function EXTRABTN:SetObjectVisibility(show)

	if HasExtraActionBar() or show then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		self:SetAlpha(1)

	elseif not Neuron.buttonEditMode and not Neuron.barEditMode and not Neuron.bindingMode then
		self:SetAlpha(0)
	end

end


function EXTRABTN:SetExtraButtonTex()

	if self.actionID then
		self.iconframeicon:SetTexture(GetActionTexture(self.actionID))
	end

	local texture = GetOverrideBarSkin() or "Interface\\ExtraButton\\Default"
	self.style:SetTexture(texture)
end


function EXTRABTN:LoadAux()

	Neuron.NeuronBinder:CreateBindFrame(self)

	self.style = self:CreateTexture(nil, "OVERLAY")
	self.style:SetPoint("CENTER", -2, 1)
	self.style:SetWidth(190)
	self.style:SetHeight(95)

	self:SetExtraButtonTex()

	self.hotkey:SetPoint("TOPLEFT", -4, -6)
end


function EXTRABTN:ExtraButton_Update()

	self:SetExtraButtonTex()

	self.style:Show()

	local start, duration, enable = GetActionCooldown(self.actionID);

	if (start) then
		Neuron:SetTimer(self.iconframecooldown, start, duration, enable, self.cdText, self.cdcolor1, self.cdcolor2, self.cdAlpha)
	end


end


function EXTRABTN:OnEnter(...)

	if (self.bar) then

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

		if (GetActionInfo(self.actionID)) then

			GameTooltip:SetAction(self.actionID)

		end

		GameTooltip:Show()

	end
end


function EXTRABTN:SetType(save)

	self:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("SPELLS_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterUnitEvent("UNIT_AURA", "player")

	self.actionID = 169

	self:SetAttribute("type", "action")
	self:SetAttribute("*action1", self.actionID)

	self:SetAttribute("useparent-unit", false)
	self:SetAttribute("unit", ATTRIBUTE_NOOP)

	self:SetScript("OnEvent", function(self, event, ...) self:OnEvent(event, ...) end)
	self:SetScript("OnEnter", function(self, ...) self:OnEnter(...) end)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:SetScript("OnShow", function(self) self:ExtraButton_Update() end)

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


	self:SetSkinned()


end


function EXTRABTN:OnEvent(event, ...)

	self:ExtraButton_Update()
	self:SetObjectVisibility()

	if event == "PLAYER_ENTERING_WORLD" then
		Neuron.NeuronBinder:ApplyBindings(self)
	end

end