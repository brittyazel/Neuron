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

---@class KEYBINDER @define class KEYBINDER is our keybinding object
local KEYBINDER = setmetatable({}, { __index = CreateFrame("Button") })
Neuron.KEYBINDER = KEYBINDER


local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


local DEFAULT_VIRTUAL_KEY = "LeftButton"
local NEURON_VIRTUAL_KEY = "Hotkey"

local VIRTUAL_KEY_LIST = {
	DEFAULT_VIRTUAL_KEY,
	NEURON_VIRTUAL_KEY
}


----------------------------------------------------------

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param button BUTTON @Parent BUTTON object for this given binder frame
---@return KEYBINDER @ A newly created KEYBINDER object
function KEYBINDER:new(button)
	local newKeyBinder = CreateFrame("Button", button:GetName().."BindFrame", button, "NeuronBindFrameTemplate")
	setmetatable(newKeyBinder, {__index = KEYBINDER})

	newKeyBinder:EnableMouseWheel(true)
	newKeyBinder:RegisterForClicks("AnyDown")
	newKeyBinder:SetAllPoints(button)
	newKeyBinder:SetScript("OnShow", function(self) self:OnShow() end)
	newKeyBinder:SetScript("OnHide", function(self) self:OnHide() end)
	newKeyBinder:SetScript("OnEnter", function(self) self:OnEnter() end)
	newKeyBinder:SetScript("OnLeave", function(self) self:OnLeave() end)
	newKeyBinder:SetScript("OnClick", function(self, mouseButton) self:OnClick(mouseButton) end)
	newKeyBinder:SetScript("OnKeyDown", function(self, key) self:OnKeyDown(key) end)
	newKeyBinder:SetScript("OnMouseWheel", function(self, delta) self:OnMouseWheel(delta) end)
	newKeyBinder:SetScript("OnUpdate", function(self) self:OnUpdate() end)

	newKeyBinder.type:SetText(L["Bind"])
	newKeyBinder.button = button
	newKeyBinder.bindType = "button"

	Neuron.BINDIndex[button.class..button.bar.DB.id.."_"..button.id] = newKeyBinder

	button:SetAttribute("hotkeypri", button.keys.hotKeyPri)
	button:SetAttribute("hotkeys", button.keys.hotKeys)

	newKeyBinder:Hide()

	return newKeyBinder
end

----------------------------------------------------------


--- Returns a list of the available spell icon filenames for use in macros
--- @return string @Field of the key modifiers currently being pressed
function KEYBINDER:GetModifier()
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
--- @param button BUTTON @The button to keybindings to look up
--- @return string @The current key that is bound to the selected button
function KEYBINDER:GetBindkeyList(button)

	if (not button.data) then return L["None"] end

	local bindkeys = button.keys.hotKeyText:gsub(":", ", ")

	bindkeys = bindkeys:gsub("^, ", "")
	bindkeys = bindkeys:gsub(", $", "")

	if (string.len(bindkeys) < 1) then
		bindkeys = L["None"]
	end

	return bindkeys
end

--- Returns the text value of a keybind
--- @param key string @The key to look up
--- @return string @The text value for the key
function KEYBINDER:GetKeyText(key)
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
--- @param button BUTTON @The button to clear
--- @param key string @Which key was pressed
function KEYBINDER:ClearBindings(button, key)
	if (key) then
		SetOverrideBinding(button, true, key, nil)

		local newkey = key:gsub("%-", "%%-")
		button.keys.hotKeys = button.keys.hotKeys:gsub(newkey..":", "")

		local keytext = self:GetKeyText(key)
		button.keys.hotKeyText = button.keys.hotKeyText:gsub(keytext..":", "")
	else
		local bindCmdPrefix = "CLICK " .. button:GetName()

		---clear bindings for all virtual keys (LeftButton, Hotkey, ...)
		---using the bindCmdPrefix and concatenating it with each virtual key
		for _, virtualKey in ipairs(VIRTUAL_KEY_LIST) do
			local bindCmd = bindCmdPrefix .. ":" .. virtualKey

			while (GetBindingKey(bindCmd)) do
				SetBinding(GetBindingKey(bindCmd), nil)
			end
		end

		ClearOverrideBindings(button)
		button.keys.hotKeys = ":"
		button.keys.hotKeyText = ":"
	end

	self:ApplyBindings(button)
end


--- Sets a keybinding to a button
--- @param button BUTTON @The button to set keybinding for
--- @param key string @The key to be used
function KEYBINDER:SetNeuronBinding(button, key)
	local found

	gsub(button.keys.hotKeys, "[^:]+", function(binding) if(binding == key) then found = true end end)

	if (not found) then
		local keytext = self:GetKeyText(key)

		button.keys.hotKeys = button.keys.hotKeys..key..":"
		button.keys.hotKeyText = button.keys.hotKeyText..keytext..":"
	end

	self:ApplyBindings(button)
end


--- Applies binding to button
--- @param button BUTTON @The button to apply settings go
function KEYBINDER:ApplyBindings(button)
	button:SetAttribute("hotkeypri", button.keys.hotKeyPri)

	local virtualKey

	---checks if the button is a Neuron action or a special Blizzard action (such as a zone ability)
	---this is necessary because Blizzard buttons usually won't work and can give very weird results
	---if clicked with a virtual key other than the default "LeftButton"
	if (button.class == "ActionBar") then
		virtualKey = NEURON_VIRTUAL_KEY
	else
		virtualKey = DEFAULT_VIRTUAL_KEY
	end

	if (button:IsVisible() or button:GetParent():GetAttribute("concealed")) then
		gsub(button.keys.hotKeys, "[^:]+", function(key) SetOverrideBindingClick(button, button.keys.hotKeyPri, key, button:GetName(), virtualKey) end)
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


--- Processes the change to a key bind
--- @param key string @The key to be used
--- @param button BUTTON @The button to set keybinding for
function KEYBINDER:ProcessBinding(key, button)
	if (button and button.keys and button.keys.hotKeyLock) then
		UIErrorsFrame:AddMessage(L["Bindings_Locked_Notice"], 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	if (key == "ESCAPE") then
		self:ClearBindings(button)
	elseif (key) then --checks to see if another keybind already has that key, and if so clears it from the other button
		for _,binder in pairs(Neuron.BINDIndex) do
			if (button ~= binder.button and binder.button.keys and not binder.button.keys.hotKeyLock) then
				binder.button.keys.hotKeys:gsub("[^:]+", function(binding) if (key == binding) then binder:ClearBindings(binder.button, binding) binder:ApplyBindings(binder.button) end end)
			end
		end

		self:SetNeuronBinding(button, key)
	end

	if (self:IsVisible()) then
		self:OnEnter()
	end

end


--- OnShow Event handler
function KEYBINDER:OnShow()
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
function KEYBINDER:OnHide()
end


--- OnEnter Event handler
function KEYBINDER:OnEnter()
	local name

	---TODO:we should definitely added name strings for pets/companions as well. This was just to get it going
	if self.button.spellID then
		name = GetSpellInfo(self.button.spellID)
	elseif self.button.actionSpell then
		name = self.button.actionSpell
	elseif self.button.macroitem then
		name = self.button.macroitem
	elseif self.button.macrospell then
		name = self.button.macrospell --this is kind of a catch-all
	end

	if not name then
		name = "Button"
	end

	self.select:Show()

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	GameTooltip:ClearLines()
	GameTooltip:SetText("Neuron", 1.0, 1.0, 1.0)
	GameTooltip:AddLine(L["Keybind_Tooltip_1"] .. ": |cffffffff" .. name  .. "|r")
	GameTooltip:AddLine(L["Keybind_Tooltip_2"] .. ": |cffffffff" .. self:GetBindkeyList(self.button) .. "|r")
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["Keybind_Tooltip_3"])
	GameTooltip:AddLine(L["Keybind_Tooltip_4"])
	GameTooltip:AddLine(L["Keybind_Tooltip_5"])

	GameTooltip:Show()
end


--- OnLeave Event handler
function KEYBINDER:OnLeave()
	self.select:Hide()
	GameTooltip:Hide()
end


--- OnUpdate Event handler
function KEYBINDER:OnUpdate()
	if(Neuron.enteredWorld) then
		if (self:IsMouseOver()) then
			self:EnableKeyboard(true)
		else
			self:EnableKeyboard(false)
		end
	end
end


--- OnClick Event handler
--- @param buttonpressed string @The button that was clicked
function KEYBINDER:OnClick(buttonpressed)

	if (buttonpressed == "LeftButton") then

		if (self.button.keys.hotKeyLock) then
			self.button.keys.hotKeyLock = false
		else
			self.button.keys.hotKeyLock = true
		end

		self:OnShow()

		return
	end

	if (buttonpressed == "RightButton") then
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

	if (buttonpressed == "MiddleButton") then
		key = "Button3"
	else
		key = buttonpressed
	end

	if (modifier) then
		key = modifier..key
	end

	self:ProcessBinding(key, self.button)
end


--- OnKeyDown Event handler
--- @param key string @The key that was pressed
function KEYBINDER:OnKeyDown(key)
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
--- @param delta number @direction mouse wheel moved
function KEYBINDER:OnMouseWheel(delta)
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
