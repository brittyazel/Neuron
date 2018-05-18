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




function XBTN:GetSkinned()
	self.hasAction = ""
	self.noAction = ""

	return false
end



function XBTN:SaveData()

	-- empty

end

function XBTN:LoadData(spec, state)

	local id = self.id

	self.CDB = xbtnsCDB

	if (self.CDB) then

		if (not self.CDB[id]) then
			self.CDB[id] = {}
		end

		if (not self.CDB[id].config) then
			self.CDB[id].config = CopyTable(configData)
		end

		if (not self.CDB[id].keys) then
			self.CDB[id].keys = CopyTable(keyData)
		end

		if (not self.CDB[id]) then
			self.CDB[id] = {}
		end

		if (not self.CDB[id].keys) then
			self.CDB[id].keys = CopyTable(keyData)
		end

		if (not self.CDB[id].data) then
			self.CDB[id].data = {}
		end

		NEURON:UpdateData(self.CDB[id].config, configData)
		NEURON:UpdateData(self.CDB[id].keys, keyData)

		self.config = self.CDB [id].config

		if (CDB.perCharBinds) then
			self.keys = self.CDB[id].keys
		else
			self.keys = self.CDB[id].keys
		end

		self.data = self.CDB[id].data
	end
end

function XBTN:SetGrid(show, hide)

	if (true) then return end

	if (not InCombatLockdown()) then

		self:SetAttribute("isshown", self.showGrid)
		self:SetAttribute("showgrid", show)

		if (show or self.showGrid) then
			self:Show()
		elseif (not (self:IsMouseOver() and self:IsVisible()) and not HasPetAction(self.actionID)) then
			self:Hide()
		end
	end
end

function XBTN:SetAux()

	--self:SetSkinned()

	if (self.vlbtn) then

		if (SKIN) then

			local btnData = {
				Normal = self.vlbtn.normaltexture,
				Icon = self.vlbtn.iconframeicon,
				Cooldown = self.vlbtn.iconframecooldown,
				HotKey = self.vlbtn.hotkey,
				Count = self.vlbtn.count,
				Name = self.vlbtn.name,
				Border = self.vlbtn.border,
				AutoCast = false,
			}

			SKIN:Group("Neuron", "Vehicle Leave"):AddButton(self.vlbtn, btnData)

			self.vlbtn.skinned = true

			SKINIndex[self.vlbtn] = true
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

function XBTN:LoadAux()

	NEURON.NeuronBinder:CreateBindFrame(self, self.objTIndex)
	self:CreateVehicleLeave(self.objTIndex)

	self.style = self:CreateTexture(nil, "OVERLAY")
	self.style:SetPoint("CENTER", -2, 1)
	self.style:SetWidth(190)
	self.style:SetHeight(95)

	self:SetExtraButtonTex()

	self.hotkey:SetPoint("TOPLEFT", -4, -6)
end

function XBTN:SetDefaults()

	-- empty

end

function XBTN:GetDefaults()

	--empty

end

function NeuronExtraBar:SetData(button, bar)
	NEURON.NeuronButton:SetData(button, bar)
end

function XBTN:SetType(save)

	self:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	self.actionID = 169

	self:SetAttribute("type", "action")
	self:SetAttribute("*action1", self.actionID)

	self:SetAttribute("useparent-unit", false)
	self:SetAttribute("unit", ATTRIBUTE_NOOP)

	self:SetScript("OnEvent", function(self, event, ...) NEURON.NeuronButton:MACRO_OnEvent(self, event, ...) end)
	self:SetScript("PostClick", function(self) NEURON.NeuronButton:MACRO_UpdateState(self) end)
	self:SetScript("OnShow", function(self, ...) NEURON.NeuronButton:MACRO_OnShow(self, ...) end)
	self:SetScript("OnHide", function(self, ...) NEURON.NeuronButton:MACRO_OnHide(self, ...) end)

	self:HookScript("OnEnter", function(self, ...) NEURON.NeuronButton:MACRO_OnEnter(self, ...)end)
	self:HookScript("OnLeave", function(self, ...) NEURON.NeuronButton:MACRO_OnLeave(self, ...) end)
	self:HookScript("OnShow", XBTN.SetExtraButtonTex)

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

end
