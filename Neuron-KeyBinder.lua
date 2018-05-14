--Neuron , a World of Warcraft® user interface addon.


local NEURON = Neuron
--local DB

NEURON.BINDER = setmetatable({}, { __index = CreateFrame("Button") })

local BUTTON, BINDER = NEURON.BUTTON, NEURON.BINDER

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

--local BTNIndex = NEURON.BTNIndex
local BINDIndex = NEURON.BINDIndex

--local sIndex = NEURON.sIndex
--local cIndex = NEURON.cIndex


--- Returns a list of the available spell icon filenames for use in macros
-- @param N/A
-- @return text field of the key modifiers currently being pressed
function BINDER:GetModifier()
	local modifier

	if (IsAltKeyDown()) then
		modifier = "ALT-"
	end

	if (IsControlKeyDown()) then
		if (modifier) then
			modifier = modifier.."CTRL-";
		else
			modifier = "CTRL-";
		end
	end

	if (IsShiftKeyDown()) then
		if (modifier) then
			modifier = modifier.."SHIFT-";
		else
			modifier = "SHIFT-";
		end
	end

	return modifier
end


--- Returns the keybind for a given button
-- @param Button: The button to keybindings to look up
-- @return bindkeys: The current key that is bound to the selected button
function BINDER:GetBindkeyList(button)

	if (not button.data) then return L["None"] end

	local bindkeys = button.keys.hotKeyText:gsub(":", ", ")

	bindkeys = bindkeys:gsub("^, ", "")
	bindkeys = bindkeys:gsub(", $", "")

	if (strlen(bindkeys) < 1) then
		bindkeys = L["None"]
	end

	return bindkeys
end


--- Returns the text value of a keybind 
-- @param key: The key to look up
-- @return keytext: The text value for the key
function BINDER:GetKeyText(key)
	local keytext

	if (key:find("Button")) then
		keytext = key:gsub("([Bb][Uu][Tt][Tt][Oo][Nn])(%d+)","m%2")
	elseif (key:find("NUMPAD")) then
		keytext = key:gsub("NUMPAD","n")
		keytext = keytext:gsub("DIVIDE","/")
		keytext = keytext:gsub("MULTIPLY","*")
		keytext = keytext:gsub("MINUS","-")
		keytext = keytext:gsub("PLUS","+")
		keytext = keytext:gsub("DECIMAL",".")
	elseif (key:find("MOUSEWHEEL")) then
		keytext = key:gsub("MOUSEWHEEL","mw")
		keytext = keytext:gsub("UP","U")
		keytext = keytext:gsub("DOWN","D")
	else
		keytext = key
	end

	keytext = keytext:gsub("ALT%-","a")
	keytext = keytext:gsub("CTRL%-","c")
	keytext = keytext:gsub("SHIFT%-","s")
	keytext = keytext:gsub("INSERT","Ins")
	keytext = keytext:gsub("DELETE","Del")
	keytext = keytext:gsub("HOME","Home")
	keytext = keytext:gsub("END","End")
	keytext = keytext:gsub("PAGEUP","PgUp")
	keytext = keytext:gsub("PAGEDOWN","PgDn")
	keytext = keytext:gsub("BACKSPACE","Bksp")
	keytext = keytext:gsub("SPACE","Spc")

	return keytext
end


--- Clears the bindings of a given button
-- @param button: The button to clear
-- @param key: ?
function BINDER:ClearBindings(button, key)
	if (key) then
		SetOverrideBinding(button, true, key, nil)

		local newkey = key:gsub("%-", "%%-")
		button.keys.hotKeys = button.keys.hotKeys:gsub(newkey..":", "")

		local keytext = self:GetKeyText(key)
		button.keys.hotKeyText = button.keys.hotKeyText:gsub(keytext..":", "")
	else
		local bindkey = "CLICK "..button:GetName()..":LeftButton"

		while (GetBindingKey(bindkey)) do
			SetBinding(GetBindingKey(bindkey), nil)
		end

		ClearOverrideBindings(button)
		button.keys.hotKeys = ":"
		button.keys.hotKeyText = ":"
	end

	self:ApplyBindings(button)
end


--- Sets a keybinding to a button
-- @param button: The button to set keybinding for
-- @param key: The key to be used
function BINDER:SetNeuronBinding(button, key)
	local found

	gsub(button.keys.hotKeys, "[^:]+", function(binding) if(binding == key) then found = true end end)

	if (not found) then
		local keytext = self:GetKeyText(key)

		button.keys.hotKeys = button.keys.hotKeys..key..":"
		button.keys.hotKeyText = button.keys.hotKeyText..keytext..":"
	end

	self:ApplyBindings(button)
end


--- Applys binding to button
-- @param button: The button to apply settings go
function BINDER:ApplyBindings(button)
	button:SetAttribute("hotkeypri", button.keys.hotKeyPri)

	if (button:IsVisible() or button:GetParent():GetAttribute("concealed")) then
		gsub(button.keys.hotKeys, "[^:]+", function(key) SetOverrideBindingClick(button, button.keys.hotKeyPri, key, button:GetName()) end)
	end

	button:SetAttribute("hotkeys", button.keys.hotKeys)

	button.hotkey:SetText(button.keys.hotKeyText:match("^:([^:]+)") or "")

	if (button.bindText) then
		button.hotkey:Show()
	else
		button.hotkey:Hide()
	end

	if (GetCurrentBindingSet() > 0 and GetCurrentBindingSet() < 3) then SaveBindings(GetCurrentBindingSet()) end
end

--- Processes the change to a key bind  (i think)
-- @param button: The button to set keybinding for
-- @param key: The key to be used
function BINDER:ProcessBinding(key, button)
	if (button and button.keys and button.keys.hotKeyLock) then
		UIErrorsFrame:AddMessage(L["Bindings_Locked_Notice"], 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	if (key == "ESCAPE") then
		self:ClearBindings(button)
	elseif (key) then
		for _,binder in pairs(BINDIndex) do
			if (button ~= binder.button and binder.button.keys and not binder.button.keys.hotKeyLock) then
				binder.button.keys.hotKeys:gsub("[^:]+", function(binding) if (key == binding) then self:ClearBindings(binder.button, binding) self:ApplyBindings(binder.button) end end)
			end
		end

		self:SetNeuronBinding(button, key)
	end

	if (self:IsVisible()) then
		self:OnEnter()
	end

	button:SaveData()
end


--- OnShow Event handler
function BINDER:OnShow()
	local button = self.button

	if (button) then

		if (button.bar) then
			self:SetFrameLevel(button.bar:GetFrameLevel()+1)
		end

		local priority = ""

		if (button.keys.hotKeyPri) then
			priority = "|cff00ff00"..L["Priority"].."|r\n"
		end

		if (button.keys.hotKeyLock) then
			self.type:SetText(priority.."|cfff00000"..L["Locked"].."|r")
		else
			self.type:SetText(priority.."|cffffffff"..L["Bind"].."|r")
		end
	end
end


--- OnHide Event handler
function BINDER:OnHide()
end


--- OnEnter Event handler
function BINDER:OnEnter()

    local button = self.button

	local name = self.bindType:gsub("^%l", string.upper).. " " .. button.id

	if self.button.spellID then
		name = GetSpellInfo(self.button.spellID)
	elseif self.button.macroitem then
		name = self.button.macroitem
	end

	self.select:Show()

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	GameTooltip:ClearLines()
    GameTooltip:SetText("Neuron")
	GameTooltip:AddLine(L["Keybind_Tooltip_1"] .. ": |cffffd100" .. name  .. "|r", 1.0, 1.0, 1.0)
	GameTooltip:AddLine(L["Keybind_Tooltip_2"] .. ": |cffffd100" .. self:GetBindkeyList(button) .. "|r", 1.0, 1.0, 1.0)
    GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["Keybind_Tooltip_3"], 1.0, 1.0, 1.0)
	GameTooltip:AddLine(L["Keybind_Tooltip_4"], 1.0, 1.0, 1.0)
	GameTooltip:AddLine(L["Keybind_Tooltip_5"], 1.0, 1.0, 1.0)

	GameTooltip:Show()
end


--- OnLeave Event handler
function BINDER:OnLeave()
	self.select:Hide()
    GameTooltip:Hide()
end


--- OnUpdate Event handler
function BINDER:OnUpdate()
	if(NEURON.PEW) then
		if (self:IsMouseOver()) then
			self:EnableKeyboard(true)
		else
			self:EnableKeyboard(false)
		end
	end
end


--- OnClick Event handler
-- @param button: The button that was clicked
function BINDER:OnClick(button)
	if (button == "LeftButton") then

		if (self.button.keys.hotKeyLock) then
			self.button.keys.hotKeyLock = false
		else
			self.button.keys.hotKeyLock = true
		end

		self:OnShow()

		return
	end

	if (button == "RightButton") then
		if (self.button.keys.hotKeyPri) then
			self.button.keys.hotKeyPri = false
		else
			self.button.keys.hotKeyPri = true
		end

		self:ApplyBindings(self.button)

		self:OnShow()

		return
	end

	local modifier, key = self:GetModifier()

	if (button == "MiddleButton") then
		key = "Button3"
	else
		key = button
	end

	if (modifier) then
		key = modifier..key
	end

	self:ProcessBinding(key, self.button)
end


--- OnKeyDown Event handler
-- @param key: The key that was pressed
function BINDER:OnKeyDown(key)
	if (key:find("ALT") or key:find("SHIFT") or key:find("CTRL") or key:find("PRINTSCREEN")) then
		return
	end

	local modifier = self:GetModifier()

	if (modifier) then
		key = modifier..key
	end

	self:ProcessBinding(key, self.button)
end


--- OnMouseWheel Event handler
-- @param delta: direction mouse wheel moved
function BINDER:OnMouseWheel(delta)
	local modifier, key, action = self:GetModifier()

	if (delta > 0) then
		key = "MOUSEWHEELUP"
		action = "MousewheelUp"
	else
		key = "MOUSEWHEELDOWN"
		action = "MousewheelDown"
	end

	if (modifier) then
		key = modifier..key
	end

	self:ProcessBinding(key, self.button)
end


local BINDER_MT = { __index = BINDER }


function BUTTON:CreateBindFrame(index)
	local binder = CreateFrame("Button", self:GetName().."BindFrame", self, "NeuronBindFrameTemplate")

	setmetatable(binder, BINDER_MT)

	binder:EnableMouseWheel(true)
	binder:RegisterForClicks("AnyDown")
	binder:SetAllPoints(self)
	binder:SetScript("OnShow", BINDER.OnShow)
	binder:SetScript("OnHide", BINDER.OnHide)
	binder:SetScript("OnEnter", BINDER.OnEnter)
	binder:SetScript("OnLeave", BINDER.OnLeave)
	binder:SetScript("OnClick", BINDER.OnClick)
	binder:SetScript("OnKeyDown", BINDER.OnKeyDown)
	binder:SetScript("OnMouseWheel", BINDER.OnMouseWheel)
	binder:SetScript("OnUpdate", BINDER.OnUpdate)

	binder.type:SetText(L["Bind"])
	binder.button = self
	binder.bindType = "button"

	self.binder = binder
	self:SetAttribute("hotkeypri", self.keys.hotKeyPri)
	self:SetAttribute("hotkeys", self.keys.hotKeys)

	BINDIndex[self.class..index] = binder

	binder:Hide()
end


--- Toggles the displaying of key bindings
-- @param show: True if to be displayed
-- @param hide: True if to be hidden
function NEURON:ToggleBindings(show, hide)
	if (NEURON.BindingMode or hide) then
		NEURON.BindingMode = false

		for _, binder in pairs(BINDIndex) do
			binder:Hide(); binder.button.editmode = NEURON.BindingMode
			binder:SetFrameStrata("LOW")
			if (not NEURON.BarsShown) then
				binder.button:SetGrid()
			end
		end

	else
		NEURON:ToggleEditFrames(nil, true)

		NEURON.BindingMode = true

		for _, binder in pairs(BINDIndex) do
			binder:Show(); binder.button.editmode = NEURON.BindingMode

			if (binder.button.bar) then
				binder:SetFrameStrata(binder.button.bar:GetFrameStrata())
				binder:SetFrameLevel(binder.button.bar:GetFrameLevel()+4)
				binder.button:SetGrid(true)
			end
		end

	end
end