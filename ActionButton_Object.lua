--Neuron, a World of Warcraft® user interface addon.



---@class ACTIONBUTTON : BUTTON
local ACTIONBUTTON = setmetatable({}, {__index = Neuron.BUTTON}) --this is the metatable for our button object
Neuron.ACTIONBUTTON = ACTIONBUTTON

local SKIN = LibStub("Masque", true)

local BTNIndex, SKINIndex = Neuron.BTNIndex, Neuron.SKINIndex


local keyDefaults = {
	[1] = { hotKeys = ":1:", hotKeyText = ":1:" },
	[2] = { hotKeys = ":2:", hotKeyText = ":2:" },
	[3] = { hotKeys = ":3:", hotKeyText = ":3:" },
	[4] = { hotKeys = ":4:", hotKeyText = ":4:" },
	[5] = { hotKeys = ":5:", hotKeyText = ":5:" },
	[6] = { hotKeys = ":6:", hotKeyText = ":6:" },
	[7] = { hotKeys = ":7:", hotKeyText = ":7:" },
	[8] = { hotKeys = ":8:", hotKeyText = ":8:" },
	[9] = { hotKeys = ":9:", hotKeyText = ":9:" },
	[10] = { hotKeys = ":0:", hotKeyText = ":0:" },
	[11] = { hotKeys = ":-:", hotKeyText = ":-:" },
	[12] = { hotKeys = ":=:", hotKeyText = ":=:" },
}


-------------------------------------------------
-----Base Methods that all buttons have----------
---These will often be overwritten per bar type--
-------------------------------------------------
function ACTIONBUTTON:SetData(bar)
	if (bar) then

		self.bar = bar

		self.barLock = bar.data.barLock
		self.barLockAlt = bar.data.barLockAlt
		self.barLockCtrl = bar.data.barLockCtrl
		self.barLockShift = bar.data.barLockShift

		self.tooltips = bar.data.tooltips
		self.tooltipsEnhanced = bar.data.tooltipsEnhanced
		self.tooltipsCombat = bar.data.tooltipsCombat

		self.spellGlow = bar.data.spellGlow
		self.spellGlowDef = bar.data.spellGlowDef
		self.spellGlowAlt = bar.data.spellGlowAlt

		self.bindText = bar.data.bindText
		self.macroText = bar.data.macroText
		self.countText = bar.data.countText

		self.cdText = bar.data.cdText

		if (bar.data.cdAlpha) then
			self.cdAlpha = 0.2
		else
			self.cdAlpha = 1
		end

		self.auraText = bar.data.auraText
		self.auraInd = bar.data.auraInd

		self.rangeInd = bar.data.rangeInd

		self.upClicks = bar.data.upClicks
		self.downClicks = bar.data.downClicks

		self.showGrid = bar.data.showGrid
		self.multiSpec = bar.data.multiSpec

		self.bindColor = bar.data.bindColor
		self.macroColor = bar.data.macroColor
		self.countColor = bar.data.countColor

		self.macroname:SetText(self.data.macro_Name) --custom macro's weren't showing the name

		if (not self.cdcolor1) then
			self.cdcolor1 = { (";"):split(bar.data.cdcolor1) }
		else
			self.cdcolor1[1], self.cdcolor1[2], self.cdcolor1[3], self.cdcolor1[4] = (";"):split(bar.data.cdcolor1)
		end

		if (not self.cdcolor2) then
			self.cdcolor2 = { (";"):split(bar.data.cdcolor2) }
		else
			self.cdcolor2[1], self.cdcolor2[2], self.cdcolor2[3], self.cdcolor2[4] = (";"):split(bar.data.cdcolor2)
		end

		if (not self.auracolor1) then
			self.auracolor1 = { (";"):split(bar.data.auracolor1) }
		else
			self.auracolor1[1], self.auracolor1[2], self.auracolor1[3], self.auracolor1[4] = (";"):split(bar.data.auracolor1)
		end

		if (not self.auracolor2) then
			self.auracolor2 = { (";"):split(bar.data.auracolor2) }
		else
			self.auracolor2[1], self.auracolor2[2], self.auracolor2[3], self.auracolor2[4] = (";"):split(bar.data.auracolor2)
		end

		if (not self.buffcolor) then
			self.buffcolor = { (";"):split(bar.data.buffcolor) }
		else
			self.buffcolor[1], self.buffcolor[2], self.buffcolor[3], self.buffcolor[4] = (";"):split(bar.data.buffcolor)
		end

		if (not self.debuffcolor) then
			self.debuffcolor = { (";"):split(bar.data.debuffcolor) }
		else
			self.debuffcolor[1], self.debuffcolor[2], self.debuffcolor[3], self.debuffcolor[4] = (";"):split(bar.data.debuffcolor)
		end

		if (not self.rangecolor) then
			self.rangecolor = { (";"):split(bar.data.rangecolor) }
		else
			self.rangecolor[1], self.rangecolor[2], self.rangecolor[3], self.rangecolor[4] = (";"):split(bar.data.rangecolor)
		end

		self:SetFrameStrata(bar.data.objectStrata)

		self:SetScale(bar.data.scale)
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
	self:RegisterForDrag("LeftButton", "RightButton")
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

	self:GetSkinned()

	Neuron.NeuronButton:MACRO_UpdateTimers(self)
end



function ACTIONBUTTON:LoadData(spec, state)

	local DB = Neuron.db.profile

	local id = self.id

	if (not DB.buttons[id]) then
		DB.buttons[id] = {}
	end

	self.DB = DB.buttons[id]

	self.config = self.DB.config
	self.keys = self.DB.keys
	self.statedata = self.DB[spec] --all of the states for a given spec
	self.data = self.statedata[state] --loads a single state of a single spec into button.data

	Neuron.NeuronButton:BuildStateData(self)
end




function ACTIONBUTTON:SetObjectVisibility(show)

	if not InCombatLockdown() then
		self:SetAttribute("showGrid", self.showGrid) --this is important because in our state switching code, we can't querry button.showGrid directly
		self:SetAttribute("isshown", show)
	end

	if (show or self.showGrid) then
		self:Show()
	elseif not Neuron.NeuronButton:MACRO_HasAction(self) and (not Neuron.ButtonEditMode or not Neuron.BarEditMode or not Neuron.BindingMode) then
		self:Hide()
	end
end



function ACTIONBUTTON:SetAux()
	self:SetSkinned()
	Neuron.NeuronFlyouts:UpdateFlyout(self, true)
end


function ACTIONBUTTON:LoadAux()

	if Neuron.NeuronGUI then
		Neuron.NeuronGUI:ObjEditor_CreateEditFrame(self, self.objTIndex)
	end
	Neuron.NeuronBinder:CreateBindFrame(self, self.objTIndex)

end


function ACTIONBUTTON:SetDefaults(config, keys)
	if (config) then
		for k,v in pairs(config) do
			self.config[k] = v
		end
	end

	if (keys) then
		for k,v in pairs(keys) do
			self.keys[k] = v
		end
	end
end


function ACTIONBUTTON:GetDefaults()
	return nil, keyDefaults[self.id]
end




function ACTIONBUTTON:SetType(save, kill, init)
	local state = self:GetParent():GetAttribute("activestate")

	Neuron.NeuronButton:Reset(self)

	if (kill) then

		self:SetScript("OnEvent", function() end)
		self:SetScript("OnUpdate", function() end)
		self:SetScript("OnAttributeChanged", function() end)

	else
		SecureHandler_OnLoad(self)

		self:RegisterEvent("ITEM_LOCK_CHANGED")
		self:RegisterEvent("ACTIONBAR_SHOWGRID")
		self:RegisterEvent("ACTIONBAR_HIDEGRID")

		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		self:RegisterEvent("UPDATE_MACROS")
		self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		self:RegisterEvent("EQUIPMENT_SETS_CHANGED")

		Neuron.NeuronButton:MACRO_UpdateParse(self)

		self:SetAttribute("type", "macro")
		self:SetAttribute("*macrotext*", self.macroparse)

		self:SetScript("OnEvent", function(self, event, ...) Neuron.NeuronButton:MACRO_OnEvent(self, event, ...) end)
		self:SetScript("PreClick", function(self, mousebutton) Neuron.NeuronButton:MACRO_PreClick(self, mousebutton) end)
		self:SetScript("PostClick", function(self, mousebutton) Neuron.NeuronButton:MACRO_PostClick(self, mousebutton) end)
		self:SetScript("OnReceiveDrag", function(self, preclick) Neuron.NeuronButton:MACRO_OnReceiveDrag(self, preclick) end)
		self:SetScript("OnDragStart", function(self, mousebutton) Neuron.NeuronButton:MACRO_OnDragStart(self, mousebutton) end)
		self:SetScript("OnDragStop", function(self) Neuron.NeuronButton:MACRO_OnDragStop(self) end)
		self:SetScript("OnUpdate", function(self, elapsed) Neuron.NeuronButton:MACRO_OnUpdate(self, elapsed) end)--this function uses A LOT of CPU resources
		self:SetScript("OnShow", function(self, ...) Neuron.NeuronButton:MACRO_OnShow(self, ...) end)
		self:SetScript("OnHide", function(self, ...) Neuron.NeuronButton:MACRO_OnHide(self, ...) end)
		self:SetScript("OnAttributeChanged", function(self, name, value) Neuron.NeuronButton:MACRO_OnAttributeChanged(self, name, value) end)

		self:HookScript("OnEnter", function(self, ...) Neuron.NeuronButton:MACRO_OnEnter(self, ...) end)
		self:HookScript("OnLeave", function(self, ...) Neuron.NeuronButton:MACRO_OnLeave(self, ...) end)

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

		if (not init) then
			Neuron.NeuronButton:MACRO_UpdateAll(self, true)
		end

		Neuron.NeuronButton:MACRO_OnShow(self)

	end

end


function ACTIONBUTTON:SetSkinned(flyout)
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

			if (flyout) then
				SKIN:Group("Neuron", self.anchor.bar.data.name):AddButton(self, btnData)
			else
				SKIN:Group("Neuron", bar.data.name):AddButton(self, btnData)
			end

			self.skinned = true

			SKINIndex[self] = true
		end
	end
end


function ACTIONBUTTON:GetSkinned()
	if (self.__MSQ_NormalTexture) then
		local Skin = self.__MSQ_NormalSkin

		if (Skin) then
			self.hasAction = Skin.Texture or false
			self.noAction = Skin.EmptyTexture or false

			if (self.__MSQ_Shape) then
				self.shape = self.__MSQ_Shape:lower()
			else
				self.shape = "square"
			end
		else
			self.hasAction = false
			self.noAction = false
			self.shape = "square"
		end

		self.shine.shape = self.shape

		return true
	else
		self.hasAction = "Interface\\Buttons\\UI-Quickslot2"
		self.noAction = "Interface\\Buttons\\UI-Quickslot"

		return false
	end
end

------------------------------------------------------------
--------------General Button Methods--------------------------
------------------------------------------------------------
