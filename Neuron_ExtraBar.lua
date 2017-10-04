--Neuron , a World of Warcraft® user interface addon.
--Copyright© 2006-2014 Connor H. Chenoweth, aka Maul - All rights reserved.

local NEURON, GDB, CDB, PEW = Neuron

NEURON.XBTNIndex = {}

local XBTNIndex, SKINIndex = NEURON.XBTNIndex, NEURON.SKINIndex

local xbarsGDB, xbarsCDB, xbtnsGDB, xbtnsCDB

local BUTTON = NEURON.BUTTON

local XBTN = setmetatable({}, { __index = BUTTON })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local SKIN = LibStub("Masque", true)

local sIndex = NEURON.sIndex

local gDef = {
	hidestates = ":extrabar0:",
	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOM",
	x = 0,
	y = 226,
}

local GetParentKeys = NEURON.GetParentKeys

local AutoCastStart = NEURON.AutoCastStart
local AutoCastStop = NEURON.AutoCastStop

local configData = {
	stored = false,
}

local keyData = {
	hotKeys = ":",
	hotKeyText = ":",
	hotKeyLock = false,
	hotKeyPri = true,
}


function XBTN:GetSkinned()
	self.hasAction = ""
	self.noAction = ""

	return false
end


function XBTN:SetData(bar)
	if (bar) then
		self.bar = bar

		self.barLock = bar.cdata.barLock
		self.barLockAlt = bar.cdata.barLockAlt
		self.barLockCtrl = bar.cdata.barLockCtrl
		self.barLockShift = bar.cdata.barLockShift

		self.tooltips = bar.cdata.tooltips
		self.tooltipsEnhanced = bar.cdata.tooltipsEnhanced
		self.tooltipsCombat = bar.cdata.tooltipsCombat

		self.spellGlow = bar.cdata.spellGlow
		self.spellGlowDef = bar.cdata.spellGlowDef
		self.spellGlowAlt = bar.cdata.spellGlowAlt

		self.bindText = bar.cdata.bindText
		self.macroText = bar.cdata.macroText
		self.countText = bar.cdata.countText

		self.cdText = bar.cdata.cdText

		if (bar.cdata.cdAlpha) then
			self.cdAlpha = 0.2
		else
			self.cdAlpha = 1
		end

		self.auraText = bar.cdata.auraText
		self.auraInd = bar.cdata.auraInd

		self.rangeInd = bar.cdata.rangeInd

		self.upClicks = bar.cdata.upClicks
		self.downClicks = bar.cdata.downClicks

		self.showGrid = bar.gdata.showGrid

		self.bindColor = bar.gdata.bindColor
		self.macroColor = bar.gdata.macroColor
		self.countColor = bar.gdata.countColor

		if (not self.cdcolor1) then
			self.cdcolor1 = { (";"):split(bar.gdata.cdcolor1) }
		else
			self.cdcolor1[1], self.cdcolor1[2], self.cdcolor1[3], self.cdcolor1[4] = (";"):split(bar.gdata.cdcolor1)
		end

		if (not self.cdcolor2) then
			self.cdcolor2 = { (";"):split(bar.gdata.cdcolor2) }
		else
			self.cdcolor2[1], self.cdcolor2[2], self.cdcolor2[3], self.cdcolor2[4] = (";"):split(bar.gdata.cdcolor2)
		end

		if (not self.auracolor1) then
			self.auracolor1 = { (";"):split(bar.gdata.auracolor1) }
		else
			self.auracolor1[1], self.auracolor1[2], self.auracolor1[3], self.auracolor1[4] = (";"):split(bar.gdata.auracolor1)
		end

		if (not self.auracolor2) then
			self.auracolor2 = { (";"):split(bar.gdata.auracolor2) }
		else
			self.auracolor2[1], self.auracolor2[2], self.auracolor2[3], self.auracolor2[4] = (";"):split(bar.gdata.auracolor2)
		end

		if (not self.buffcolor) then
			self.buffcolor = { (";"):split(bar.gdata.buffcolor) }
		else
			self.buffcolor[1], self.buffcolor[2], self.buffcolor[3], self.buffcolor[4] = (";"):split(bar.gdata.buffcolor)
		end

		if (not self.debuffcolor) then
			self.debuffcolor = { (";"):split(bar.gdata.debuffcolor) }
		else
			self.debuffcolor[1], self.debuffcolor[2], self.debuffcolor[3], self.debuffcolor[4] = (";"):split(bar.gdata.debuffcolor)
		end

		if (not self.rangecolor) then
			self.rangecolor = { (";"):split(bar.gdata.rangecolor) }
		else
			self.rangecolor[1], self.rangecolor[2], self.rangecolor[3], self.rangecolor[4] = (";"):split(bar.gdata.rangecolor)
		end

		self:SetFrameStrata(bar.gdata.objectStrata)

		self:SetScale(bar.gdata.scale)

	end

	if (self.bindText) then
		self.hotkey:Show()
		if (self.bindColor) then
			self.hotkey:SetTextColor((";"):split(self.bindColor))
		end
	else
		self.hotkey:Hide()
	end

	if (self.macroText) then
		self.macroname:Show()
		if (self.macroColor) then
			self.macroname:SetTextColor((";"):split(self.macroColor))
		end
	else
		self.macroname:Hide()
	end

	if (self.countText) then
		self.count:Show()
		if (self.countColor) then
			self.count:SetTextColor((";"):split(self.countColor))
		end
	else
		self.count:Hide()
	end

	local down, up = "", ""

	if (self.upClicks) then up = up.."AnyUp" end
	if (self.downClicks) then down = down.."AnyDown" end

	self:RegisterForClicks(down, up)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	if (not self.equipcolor) then
		self.equipcolor = { 0.1, 1, 0.1, 1 }
	else
		self.equipcolor[1], self.equipcolor[2], self.equipcolor[3], self.equipcolor[4] = 0.1, 1, 0.1, 1
	end

	if (not self.manacolor) then
		self.manacolor = { 0.5, 0.5, 1.0, 1 }
	else
		self.manacolor[1], self.manacolor[2], self.manacolor[3], self.manacolor[4] = 0.5, 0.5, 1.0, 1
	end

	self:SetFrameLevel(4)
	self.iconframe:SetFrameLevel(2)
	self.iconframecooldown:SetFrameLevel(3)
	self.iconframeaurawatch:SetFrameLevel(3)

	--self:GetSkinned()

	self:MACRO_UpdateTimers()
end

function XBTN:SaveData()

	-- empty

end

function XBTN:LoadData(spec, state)

	local id = self.id

	self.GDB = xbtnsGDB
	self.CDB = xbtnsCDB

	if (self.GDB and self.CDB) then

		if (not self.GDB[id]) then
			self.GDB[id] = {}
		end

		if (not self.GDB[id].config) then
			self.GDB[id].config = CopyTable(configData)
		end

		if (not self.GDB[id].keys) then
			self.GDB[id].keys = CopyTable(keyData)
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

		NEURON:UpdateData(self.GDB[id].config, configData)
		NEURON:UpdateData(self.GDB[id].keys, keyData)

		self.config = self.GDB [id].config

		if (CDB.perCharBinds) then
			self.keys = self.CDB[id].keys
		else
			self.keys = self.GDB[id].keys
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

	self:CreateBindFrame(self.objTIndex)
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

function XBTN:SetType(save)

	self:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	self.actionID = 169

	self:SetAttribute("type", "action")
	self:SetAttribute("*action1", self.actionID)

	self:SetAttribute("useparent-unit", false)
	self:SetAttribute("unit", ATTRIBUTE_NOOP)

	self:SetScript("OnEvent", BUTTON.MACRO_OnEvent)
	self:SetScript("PostClick", BUTTON.MACRO_UpdateState)
	self:SetScript("OnUpdate", BUTTON.MACRO_OnUpdate)
	self:SetScript("OnShow", BUTTON.MACRO_OnShow)
	self:SetScript("OnHide", BUTTON.MACRO_OnHide)

	self:HookScript("OnEnter", BUTTON.MACRO_OnEnter)
	self:HookScript("OnLeave", BUTTON.MACRO_OnLeave)
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

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Neuron") then

		GDB = NeuronGDB; CDB = NeuronCDB

		xbarsGDB = GDB.xbars
		xbarsCDB = CDB.xbars

		xbtnsGDB = GDB.xbtns
		xbtnsCDB = CDB.xbtns

		NEURON:RegisterBarClass("extrabar", "Extra Action Bar", "Extra Action Button", xbarsGDB, xbarsCDB, XBTNIndex, xbtnsGDB, "CheckButton", "NeuronActionButtonTemplate", { __index = XBTN }, 1, false, STORAGE, gDef, nil, false)

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

		if (GDB.xbarFirstRun) then

			local bar = NEURON:CreateNewBar("extrabar", 1, true)
			local object = NEURON:CreateNewObject("extrabar", 1)

			bar:AddObjectToList(object)

			GDB.xbarFirstRun = false

		else

			for id,data in pairs(xbarsGDB) do
				if (data ~= nil) then
					NEURON:CreateNewBar("extrabar", id)
				end
			end

			for id,data in pairs(xbtnsGDB) do
				if (data ~= nil) then
					NEURON:CreateNewObject("extrabar", id)
				end
			end
		end


		STORAGE:Hide()

	elseif (event == "PLAYER_LOGIN") then

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
