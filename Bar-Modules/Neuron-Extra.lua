--Neuron , a World of Warcraft® user interface addon.


local NEURON = Neuron
local CDB

NEURON.NeuronExtraBar = NEURON:NewModule("ExtraBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronExtraBar = NEURON.NeuronExtraBar


local EXTRABTN = setmetatable({}, { __index = CreateFrame("CheckButton") })

local extrabarDB
local extrabtnDB

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local SKIN = LibStub("Masque", true)

local gDef = {
	hidestates = ":extrabar0:",
	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOM",
	x = 0,
	y = 205,
}

local configData = {
	stored = false,
}

local keyData = {
	hotKeys = ":",
	hotKeyText = ":",
	hotKeyLock = false,
	hotKeyPri = true,
}


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronExtraBar:OnInitialize()

	CDB = NeuronCDB

	extrabarDB = CDB.extrabar
	extrabtnDB = CDB.extrabtn

	----------------------------------------------------------------
	EXTRABTN.SetData = NeuronExtraBar.SetData
	EXTRABTN.LoadData = NeuronExtraBar.LoadData
	EXTRABTN.SaveData = NeuronExtraBar.SaveData
	EXTRABTN.SetAux = NeuronExtraBar.SetAux
	EXTRABTN.LoadAux = NeuronExtraBar.LoadAux
	EXTRABTN.SetDefaults = NeuronExtraBar.SetDefaults
	EXTRABTN.GetDefaults = NeuronExtraBar.GetDefaults
	EXTRABTN.GetSkinned = NeuronExtraBar.GetSkinned
	EXTRABTN.SetSkinned = NeuronExtraBar.SetSkinned
	EXTRABTN.SetObjectVisibility = NeuronExtraBar.SetObjectVisibility
	EXTRABTN.SetType = NeuronExtraBar.SetType
	----------------------------------------------------------------

	NEURON:RegisterBarClass("extrabar", "ExtraActionBar", L["Extra Action Bar"], "Extra Action Button", extrabarDB, extrabarDB, NeuronExtraBar, extrabtnDB, "CheckButton", "NeuronActionButtonTemplate", { __index = EXTRABTN }, 1, gDef, nil, false)

	NEURON:RegisterGUIOptions("extrabar", { AUTOHIDE = true,
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

	if (CDB.extrabarFirstRun) then

		local bar = NEURON.NeuronBar:CreateNewBar("extrabar", 1, true)
		local object = NEURON.NeuronButton:CreateNewObject("extrabar", 1)

		NEURON.NeuronBar:AddObjectToList(bar, object)

		CDB.extrabarFirstRun = false

	else

		for id,data in pairs(extrabarDB) do
			if (data ~= nil) then
				NEURON.NeuronBar:CreateNewBar("extrabar", id)
			end
		end

		for id,data in pairs(extrabtnDB) do
			if (data ~= nil) then
				NEURON.NeuronButton:CreateNewObject("extrabar", id)
			end
		end
	end

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

function NeuronExtraBar:DisableDefault()

	local disableExtraButton = false

	for i,v in ipairs(NEURON.NeuronExtraBar) do

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


function NeuronExtraBar:GetSkinned(button)
	--empty
end

function NeuronExtraBar:SetSkinned(button)

	if (SKIN) then

		local bar = button.bar

		if (bar) then

			local btnData = {
				Icon = button.icontexture,
				Normal = button.normaltexture,
			}

			SKIN:Group("Neuron", bar.gdata.name):AddButton(button, btnData)

		end

	end
end

function NeuronExtraBar:SaveData(button)

	-- empty

end

function NeuronExtraBar:LoadData(button, spec, state)

	local id = button.id

	button.CDB = extrabtnDB

	if (button.CDB) then

		if (not button.CDB[id]) then
			button.CDB[id] = {}
		end

		if (not button.CDB[id].config) then
			button.CDB[id].config = CopyTable(configData)
		end

		if (not button.CDB[id].keys) then
			button.CDB[id].keys = CopyTable(keyData)
		end

		if (not button.CDB[id]) then
			button.CDB[id] = {}
		end

		if (not button.CDB[id].keys) then
			button.CDB[id].keys = CopyTable(keyData)
		end

		if (not button.CDB[id].data) then
			button.CDB[id].data = {}
		end

		NEURON:UpdateData(button.CDB[id].config, configData)
		NEURON:UpdateData(button.CDB[id].keys, keyData)

		button.config = button.CDB [id].config

		if (CDB.perCharBinds) then
			button.keys = button.CDB[id].keys
		else
			button.keys = button.CDB[id].keys
		end

		button.data = button.CDB[id].data
	end
end

function NeuronExtraBar:SetObjectVisibility(button, show)

	if HasExtraActionBar() or show then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat
		button:SetAlpha(1)

	elseif not NEURON.ButtonEditMode and not NEURON.BarEditMode and not NEURON.BindingMode then
		button:SetAlpha(0)
	end

end

function NeuronExtraBar:SetAux(button)


end

function NeuronExtraBar:SetExtraButtonTex(button)

	if button.actionID then
		button.iconframeicon:SetTexture(GetActionTexture(button.actionID))
	end

	local texture = GetOverrideBarSkin() or "Interface\\ExtraButton\\Default"
	button.style:SetTexture(texture)
end


function NeuronExtraBar:LoadAux(button)

	NEURON.NeuronBinder:CreateBindFrame(button, button.objTIndex)

	button.style = button:CreateTexture(nil, "OVERLAY")
	button.style:SetPoint("CENTER", -2, 1)
	button.style:SetWidth(190)
	button.style:SetHeight(95)

	NeuronExtraBar:SetExtraButtonTex(button)

	button.hotkey:SetPoint("TOPLEFT", -4, -6)
end

function NeuronExtraBar:SetDefaults(button)

	-- empty

end

function NeuronExtraBar:GetDefaults(button)

	--empty

end

function NeuronExtraBar:SetData(button, bar)
	NEURON.NeuronButton:SetData(button, bar)
end


function NeuronExtraBar:ExtraButton_Update(button)

	NeuronExtraBar:SetExtraButtonTex(button)

	--This conditional is to show/hide the border of the button, but it ins't fully implemented yet
	--Some people were hitting a bit be because this option didn't exist it seems

	--[[if extrabarDB[1].border then
		button.style:Show()
	else
		button.style:Hide()
	end]]

	button.style:Show()

	local start, duration, enable = GetActionCooldown(button.actionID);

	if (start) then
		NEURON.NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
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

function NeuronExtraBar:SetType(button, save)

	button:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
	button:RegisterEvent("ZONE_CHANGED")
	button:RegisterEvent("SPELLS_CHANGED")

	button.actionID = 169

	button:SetAttribute("type", "action")
	button:SetAttribute("*action1", self.actionID)

	button:SetAttribute("useparent-unit", false)
	button:SetAttribute("unit", ATTRIBUTE_NOOP)

	button:SetScript("OnEvent", function(self, event, ...) NeuronExtraBar:OnEvent(self, event, ...) end)
	button:SetScript("OnEnter", function(self, ...) NeuronExtraBar:OnEnter(self, ...) end)
	button:SetScript("OnLeave", function(self) NeuronExtraBar:OnLeave(self) end)
	button:HookScript("OnShow", function(self) NeuronExtraBar:ExtraButton_Update(self) end)

	button:WrapScript(button, "OnShow", [[
					for i=1,select('#',(":"):split(self:GetAttribute("hotkeys"))) do
						self:SetBindingClick(self:GetAttribute("hotkeypri"), select(i,(":"):split(self:GetAttribute("hotkeys"))), self:GetName())
					end
					]])

	button:WrapScript(button, "OnHide", [[
					if (not self:GetParent():GetAttribute("concealed")) then
						for key in gmatch(self:GetAttribute("hotkeys"), "[^:]+") do
							self:ClearBinding(key)
						end
					end
					]])

	button:SetSkinned(button)

end


function NeuronExtraBar:OnEvent(button, event, ...)

	NeuronExtraBar:ExtraButton_Update(button)
	button:SetObjectVisibility(button)

end