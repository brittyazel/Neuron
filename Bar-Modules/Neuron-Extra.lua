--Neuron , a World of Warcraft® user interface addon.


local NEURON = Neuron
local CDB

NEURON.NeuronExtraBar = NEURON:NewModule("ExtraBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronExtraBar = NEURON.NeuronExtraBar


local BUTTON = NEURON.BUTTON

NEURON.XBTN = setmetatable({}, { __index = BUTTON })
local XBTN = NEURON.XBTN



local SKINIndex = NEURON.SKINIndex

local xbarsCDB
local xbtnsCDB

local STORAGE = CreateFrame("Frame", nil, UIParent)

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

	xbarsCDB = CDB.xbars
	xbtnsCDB = CDB.xbtns

	----------------------------------------------------------------
	XBTN.SetData = NeuronExtraBar.SetData
	XBTN.LoadData = NeuronExtraBar.LoadData
	XBTN.SaveData = NeuronExtraBar.SaveData
	XBTN.SetAux = NeuronExtraBar.SetAux
	XBTN.LoadAux = NeuronExtraBar.LoadAux
	XBTN.SetGrid = NeuronExtraBar.SetGrid
	XBTN.SetDefaults = NeuronExtraBar.SetDefaults
	XBTN.GetDefaults = NeuronExtraBar.GetDefaults
	XBTN.SetType = NeuronExtraBar.SetType
	XBTN.GetSkinned = NeuronExtraBar.GetSkinned
	XBTN.SetSkinned = NeuronExtraBar.SetSkinned
	----------------------------------------------------------------

	NEURON:RegisterBarClass("extrabar", "ExtraActionBar", L["Extra Action Bar"], "Extra Action Button", xbarsCDB, xbarsCDB, NeuronExtraBar, xbtnsCDB, "CheckButton", "NeuronActionButtonTemplate", { __index = XBTN }, 1, STORAGE, gDef, nil, false)

	NEURON:RegisterGUIOptions("extrabar", { AUTOHIDE = true,
		SHOWGRID = true,
		SNAPTO = true,
		UPCLICKS = true,
		DOWNCLICKS = true,
		HIDDEN = true,
		LOCKBAR = true,
		TOOLTIPS = true,
		BINDTEXT = true,
		RANGEIND = true,
		CDTEXT = true,
		CDALPHA = true }, false, 65)

	if (CDB.xbarFirstRun) then

		local bar = NEURON.NeuronBar:CreateNewBar("extrabar", 1, true)
		local object = NEURON.NeuronButton:CreateNewObject("extrabar", 1)

		NEURON.NeuronBar:AddObjectToList(bar, object)

		CDB.xbarFirstRun = false

	else

		for id,data in pairs(xbarsCDB) do
			if (data ~= nil) then
				NEURON.NeuronBar:CreateNewBar("extrabar", id)
			end
		end

		for id,data in pairs(xbtnsCDB) do
			if (data ~= nil) then
				NEURON.NeuronButton:CreateNewObject("extrabar", id)
			end
		end
	end


	STORAGE:Hide()
end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronExtraBar:OnEnable()

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronExtraBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------




function NeuronExtraBar:GetSkinned(button)
	button.hasAction = ""
	button.noAction = ""

	return false
end

function NeuronExtraBar:SetSkinned(button)

	NEURON.NeuronButton:SetSkinned(button)

end

function NeuronExtraBar:SaveData(button)

	-- empty

end

function NeuronExtraBar:LoadData(button, spec, state)

	local id = button.id

	button.CDB = xbtnsCDB

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

function NeuronExtraBar:SetGrid(button, show, hide)

	if (true) then return end

	if (not InCombatLockdown()) then

		button:SetAttribute("isshown", button.showGrid)
		button:SetAttribute("showgrid", show)

		if (show or button.showGrid) then
			button:Show()
		elseif (not (button:IsMouseOver() and button:IsVisible()) and not HasPetAction(button.actionID)) then
			button:Hide()
		end
	end
end

function NeuronExtraBar:SetAux(button)

	button:SetSkinned(button)

	if (button.vlbtn) then

		if (SKIN) then

			local btnData = {
				Normal = button.vlbtn.normaltexture,
				Icon = button.vlbtn.iconframeicon,
				Cooldown = button.vlbtn.iconframecooldown,
				HotKey = button.vlbtn.hotkey,
				Count = button.vlbtn.count,
				Name = button.vlbtn.name,
				Border = button.vlbtn.border,
				AutoCast = false,
			}

			SKIN:Group("Neuron", "Vehicle Leave"):AddButton(button.vlbtn, btnData)

			button.vlbtn.skinned = true

			SKINIndex[button.vlbtn] = true
		end
	end
end

function XBTN:SetExtraButtonTex()
	if (GetOverrideBarSkin) then
		local texture = GetOverrideBarSkin() or "Interface\\ExtraButton\\Default"
		self.style:SetTexture(texture)
	end
end

---TODO: This should get roped into Ace Event
local function VehicleLeave_OnEvent(self, event, ...)
	if (event == "UPDATE_EXTRA_ACTIONBAR") then
		self:Hide(); return
	end

	if (ActionBarController_GetCurrentActionBarState) then
		if (CanExitVehicle() and ActionBarController_GetCurrentActionBarState() == 1) then
			self:Show()
			self:Enable();
			if UnitOnTaxi("player") then
				self.iconframeicon:SetTexture(NEURON.SpecialActions.taxi)
			else
				self.iconframeicon:SetTexture(NEURON.SpecialActions.vehicle)
			end
		else
			self:Hide()
		end
	end
end



function VehicleLeave_OnEnter(self)
	if ( UnitOnTaxi("player") ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(TAXI_CANCEL, 1, 1, 1);
		GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
end

function VehicleLeave_OnClicked(self)
	if ( UnitOnTaxi("player") ) then
		TaxiRequestEarlyLanding();

		-- Show that the request for landing has been received.
		self:Disable();
		self:SetHighlightTexture([[Interface\Buttons\CheckButtonHilight]], "ADD");
		self:LockHighlight();
	else
		VehicleExit();
	end
end


function XBTN:CreateVehicleLeave(index)
	self.vlbtn = CreateFrame("Button", self:GetName().."VLeave", UIParent, "NeuronNonSecureButtonTemplate")

	self.vlbtn:SetAllPoints(self)

	self.vlbtn:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self.vlbtn:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	self.vlbtn:RegisterEvent("UPDATE_POSSESS_BAR");
	self.vlbtn:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
	self.vlbtn:RegisterEvent("UPDATE_EXTRA_ACTIONBAR");
	self.vlbtn:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	self.vlbtn:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self.vlbtn:RegisterEvent("UNIT_EXITED_VEHICLE")
	self.vlbtn:RegisterEvent("VEHICLE_UPDATE")

	self.vlbtn:SetScript("OnEvent", VehicleLeave_OnEvent)
	self.vlbtn:SetScript("OnClick",VehicleLeave_OnClicked)
	self.vlbtn:SetScript("OnEnter",VehicleLeave_OnEnter)
	self.vlbtn:SetScript("OnLeave", GameTooltip_Hide)

	local objects = NEURON:GetParentKeys(self.vlbtn)

	for k,v in pairs(objects) do
		local name = (v):gsub(self.vlbtn:GetName(), "")
		self.vlbtn[name:lower()] = _G[v]
	end

	self.vlbtn.iconframeicon:SetTexture(NEURON.SpecialActions.vehicle)

	self.vlbtn:SetFrameLevel(4)
	self.vlbtn.iconframe:SetFrameLevel(2)
	self.vlbtn.iconframecooldown:SetFrameLevel(3)

	self.vlbtn:Hide()
end





function NeuronExtraBar:LoadAux(button)

	NEURON.NeuronBinder:CreateBindFrame(button, button.objTIndex)
	button:CreateVehicleLeave(button.objTIndex)

	button.style = button:CreateTexture(nil, "OVERLAY")
	button.style:SetPoint("CENTER", -2, 1)
	button.style:SetWidth(190)
	button.style:SetHeight(95)

	button:SetExtraButtonTex()

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

function NeuronExtraBar:SetType(button, save)

	button:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	button.actionID = 169

	button:SetAttribute("type", "action")
	button:SetAttribute("*action1", self.actionID)

	button:SetAttribute("useparent-unit", false)
	button:SetAttribute("unit", ATTRIBUTE_NOOP)

	button:SetScript("OnEvent", function(self, event, ...) NEURON.NeuronButton:MACRO_OnEvent(self, event, ...) end)
	button:SetScript("PostClick", function(self) NEURON.NeuronButton:MACRO_UpdateState(self) end)
	button:SetScript("OnShow", function(self, ...) NEURON.NeuronButton:MACRO_OnShow(self, ...) end)
	button:SetScript("OnHide", function(self, ...) NEURON.NeuronButton:MACRO_OnHide(self, ...) end)

	button:HookScript("OnEnter", function(self, ...) NEURON.NeuronButton:MACRO_OnEnter(self, ...)end)
	button:HookScript("OnLeave", function(self, ...) NEURON.NeuronButton:MACRO_OnLeave(self, ...) end)
	button:HookScript("OnShow", XBTN.SetExtraButtonTex)

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

end
