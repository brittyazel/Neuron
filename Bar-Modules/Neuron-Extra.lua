--Neuron , a World of Warcraft® user interface addon.

local DB

Neuron.NeuronExtraBar = Neuron:NewModule("ExtraBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronExtraBar = Neuron.NeuronExtraBar



local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local SKIN = LibStub("Masque", true)

local defaultBarOptions = {
	[1] = {
		hidestates = ":",
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 205,
	}
}



---@class EXTRABTN : BUTTON
local EXTRABTN = setmetatable({}, { __index = Neuron.BUTTON })


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronExtraBar:OnInitialize()

	DB = Neuron.db.profile

	Neuron:RegisterBarClass("extrabar", "ExtraActionBar", L["Extra Action Bar"], "Extra Action Button", DB.extrabar, NeuronExtraBar, DB.extrabtn, "CheckButton", "NeuronActionButtonTemplate", { __index = EXTRABTN }, 1)

	Neuron:RegisterGUIOptions("extrabar", { AUTOHIDE = true,
											SHOWGRID = false,
											SNAPTO = true,
											UPCLICKS = true,
											DOWNCLICKS = true,
											HIDDEN = true,
											LOCKBAR = true,
											BINDTEXT = true,
											RANGEIND = true,
											CDTEXT = true,
											CDALPHA = true }, false, 65)

	NeuronExtraBar:CreateBarsAndButtons()

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronExtraBar:OnEnable()

	NeuronExtraBar:DisableDefault()

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronExtraBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------

function NeuronExtraBar:CreateBarsAndButtons()

	if (DB.extrabarFirstRun) then

		for id, defaults in ipairs(defaultBarOptions) do

			local bar = Neuron.NeuronBar:CreateNewBar("extrabar", id, true) --this calls the bar constructor

			for	k,v in pairs(defaults) do
				bar.data[k] = v
			end

			local object

			object = Neuron.NeuronButton:CreateNewObject("extrabar", 1, true)
			Neuron.NeuronBar:AddObjectToList(bar, object)
		end

		DB.extrabarFirstRun = false

	else

		for id,data in pairs(DB.extrabar) do
			if (data ~= nil) then
				local extrabar = Neuron.NeuronBar:CreateNewBar("extrabar", id)


				--this is a fix for adding a hidestate to the extrabar that kept it hidden even in bind/edit modes
				if extrabar.barDB[id].hidestates == ":extrabar0:" then
					extrabar.barDB[id].hidestates = ":"
				end

			end
		end

		for id,data in pairs(DB.extrabtn) do
			if (data ~= nil) then
				Neuron.NeuronButton:CreateNewObject("extrabar", id)
			end
		end
	end

end


function NeuronExtraBar:DisableDefault()

	local disableExtraButton = false

	for i,v in ipairs(Neuron.NeuronExtraBar) do

		if (v["bar"]) then --only disable if a specific button has an associated bar
			disableExtraButton = true
		end
	end


	if disableExtraButton then
		------Hiding the default blizzard
		ExtraActionButton1:UnregisterAllEvents()
		ExtraActionButton1:SetPoint("BOTTOM", 0, -250)
	end

end

function EXTRABTN:SetSkinned()

	if (SKIN) then

		local bar = self.bar

		if (bar) then

			local btnData = {
				Normal = self.normaltexture,
				Icon = self.iconframeicon,
				Cooldown = self.iconframecooldown,
				HotKey = self.hotkey,
				Count = self.count,
				Name = self.name,
				Border = self.border,
				AutoCast = false,
			}

			SKIN:Group("Neuron", bar.data.name):AddButton(self, btnData)

		end

	end
end


function EXTRABTN:LoadData(spec, state)

	local id = self.id

	if not DB.extrabtn[id] then
		DB.extrabtn[id] = {}
	end

	self.DB = DB.extrabtn[id]

	self.config = self.DB.config
	self.keys = self.DB.keys
	self.data = self.DB.data

end

function EXTRABTN:SetObjectVisibility(show)

	if HasExtraActionBar() or show then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		self:SetAlpha(1)

	elseif not Neuron.ButtonEditMode and not Neuron.BarEditMode and not Neuron.BindingMode then
		self:SetAlpha(0)
	end

end

EXTRABTN.SetData = Neuron.ACTIONBUTTON.SetData

function NeuronExtraBar:SetExtraButtonTex(button)

	if button.actionID then
		button.iconframeicon:SetTexture(GetActionTexture(button.actionID))
	end

	local texture = GetOverrideBarSkin() or "Interface\\ExtraButton\\Default"
	button.style:SetTexture(texture)
end


function EXTRABTN:LoadAux()

	Neuron.NeuronBinder:CreateBindFrame(self, self.objTIndex)

	self.style = self:CreateTexture(nil, "OVERLAY")
	self.style:SetPoint("CENTER", -2, 1)
	self.style:SetWidth(190)
	self.style:SetHeight(95)

	NeuronExtraBar:SetExtraButtonTex(self)

	self.hotkey:SetPoint("TOPLEFT", -4, -6)
end


function NeuronExtraBar:ExtraButton_Update(button)

	NeuronExtraBar:SetExtraButtonTex(button)

	--This conditional is to show/hide the border of the button, but it ins't fully implemented yet
	--Some people were hitting a bit be because this option didn't exist it seems

	--[[if DB.extrabar[1].border then
		button.style:Show()
	else
		button.style:Hide()
	end]]

	--button.style:Show()

	local start, duration, enable = GetActionCooldown(button.actionID);

	if (start) then
		Neuron.NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
	end
end


function NeuronExtraBar:OnEnter(button, ...)

	if (button.bar) then

		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")

		if (GetActionInfo(button.actionID)) then

			GameTooltip:SetAction(button.actionID)

		end

		GameTooltip:Show()

	end
end


function NeuronExtraBar:OnLeave(button)
	GameTooltip:Hide()
end

function EXTRABTN:SetType(save)

	self:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("SPELLS_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self.actionID = 169

	self:SetAttribute("type", "action")
	self:SetAttribute("*action1", self.actionID)

	self:SetAttribute("useparent-unit", false)
	self:SetAttribute("unit", ATTRIBUTE_NOOP)

	self:SetScript("OnEvent", function(self, event, ...) NeuronExtraBar:OnEvent(self, event, ...) end)
	self:SetScript("OnEnter", function(self, ...) NeuronExtraBar:OnEnter(self, ...) end)
	self:SetScript("OnLeave", function(self) NeuronExtraBar:OnLeave(self) end)
	self:HookScript("OnShow", function(self) NeuronExtraBar:ExtraButton_Update(self) end)

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


function NeuronExtraBar:OnEvent(button, event, ...)

	NeuronExtraBar:ExtraButton_Update(button)
	button:SetObjectVisibility()

	if event == "PLAYER_ENTERING_WORLD" then
		NeuronExtraBar:PLAYER_ENTERING_WORLD(button, event, ...)
	end

end

function NeuronExtraBar:PLAYER_ENTERING_WORLD(button, event, ...)
	if InCombatLockdown() then return end
	Neuron.NeuronBinder:ApplyBindings(button)
end