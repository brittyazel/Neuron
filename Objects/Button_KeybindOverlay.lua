-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
local Neuron = addonTable.Neuron

local Button = Neuron.Button

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local DEFAULT_VIRTUAL_KEY = "LeftButton"
local NEURON_VIRTUAL_KEY = "Hotkey"

----------------------------------------------------------

---Constructor: Create a new Neuron Button object (this is the base object for all Neuron button types)
---@return Button @ A newly created Button object
function Button:KeybindOverlay_CreateEditFrame()
	local keybindFrame = CreateFrame("Button", self:GetName().."BindFrame", self, "NeuronOverlayFrameTemplate")
	setmetatable(keybindFrame, { __index = CreateFrame("Button") })

	keybindFrame:EnableMouseWheel(true)
	keybindFrame:RegisterForClicks("AnyDown")
	keybindFrame:SetAllPoints(self)
	keybindFrame:SetScript("OnShow", function() self:KeybindOverlay_OnShow() end)
	keybindFrame:SetScript("OnHide", function() self:KeybindOverlay_OnHide() end)
	keybindFrame:SetScript("OnEnter", function() self:KeybindOverlay_OnEnter() end)
	keybindFrame:SetScript("OnLeave", function() self:KeybindOverlay_OnLeave() end)
	keybindFrame:SetScript("OnClick", function(_, mouseButton) self:KeybindOverlay_OnClick(mouseButton) end)
	keybindFrame:SetScript("OnKeyDown", function(_, key) self:KeybindOverlay_OnKeyDown(key) end)
	keybindFrame:SetScript("OnMouseWheel", function(_, delta) self:KeybindOverlay_OnMouseWheel(delta) end)

	self.keybindFrame = keybindFrame

	keybindFrame.label:SetText(L["Bind"])
	keybindFrame:Hide()

	return keybindFrame
end

----------------------------------------------------------
-------------------- Helper Functions --------------------
----------------------------------------------------------

--- Returns a string representation of the modifier that is currently being pressed down, if any
--- @return string @Field of the key modifiers currently being pressed
local function GetModifier()
	local modifier
	if IsAltKeyDown() then
		modifier = "ALT-"
	end
	if IsControlKeyDown() then
		if modifier then
			modifier = modifier.."CTRL-";
		else
			modifier = "CTRL-";
		end
	end
	if IsShiftKeyDown() then
		if modifier then
			modifier = modifier.."SHIFT-";
		else
			modifier = "SHIFT-";
		end
	end
	return modifier
end

--- Returns the text value of a keybind
--- @param key string @The key to look up
--- @return string @The text value for the key
local function hotKeyText(key)
	local keytext
	if key:find("Button") then
		keytext = key:gsub("([Bb][Uu][Tt][Tt][Oo][Nn])(%d+)","m%2")
	elseif key:find("NUMPAD") then
		keytext = key:gsub("NUMPAD","n")
		keytext = keytext:gsub("DIVIDE","/")
		keytext = keytext:gsub("MULTIPLY","*")
		keytext = keytext:gsub("MINUS","-")
		keytext = keytext:gsub("PLUS","+")
		keytext = keytext:gsub("DECIMAL",".")
	elseif key:find("MOUSEWHEEL") then
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

----------------------------------------------------------
----------------------------------------------------------

--- Returns the keybind for a given button
--- @return string @The current key that is bound to the selected button
function Button:KeybindOverlay_GetBindKeyList()
	if not self.data then
		return L["None"]
	end

	local bindkeys = self.keys.hotKeys:gsub("[^:]+", hotKeyText):gsub(":", ", ")

	bindkeys = bindkeys:gsub("^, ", "")
	bindkeys = bindkeys:gsub(", $", "")

	if string.len(bindkeys) < 1 then
		bindkeys = L["None"]
	end

	return bindkeys
end

--- Clears the bindings of a given button
--- @param key string @Which key was pressed
function Button:KeybindOverlay_ClearBindings(key)
	if key then
		local newkey = key:gsub("%-", "%%-")
		self.keys.hotKeys = self.keys.hotKeys:gsub(newkey..":", "")
	else
		ClearOverrideBindings(self)
		self.keys.hotKeys = ":"
	end

	self:KeybindOverlay_ApplyBindings()
end

--- Applies binding to button
function Button:KeybindOverlay_ApplyBindings()
	local virtualKey

	---checks if the button is a Neuron action or a special Blizzard action (such as a zone ability)
	---this is necessary because Blizzard buttons usually won't work and can give very weird results
	---if clicked with a virtual key other than the default "LeftButton"
	if self.class == "ActionBar" then
		virtualKey = NEURON_VIRTUAL_KEY
	else
		virtualKey = DEFAULT_VIRTUAL_KEY
	end

	if self:IsVisible() or self:GetParent():GetAttribute("concealed") then
		self.keys.hotKeys:gsub("[^:]+", function(key) SetOverrideBindingClick(self, self.keys.hotKeyPri, key, self:GetName(), virtualKey) end)
	end

	if not InCombatLockdown() then
		self:SetAttribute("hotkeypri", self.keys.hotKeyPri)
		self:SetAttribute("hotkeys", self.keys.hotKeys)
	end

	self.Hotkey:SetText(hotKeyText(self.keys.hotKeys:match("^:([^:]+)") or ""))

	if self.bar:GetShowBindText() then
		self.Hotkey:Show()
	else
		self.Hotkey:Hide()
	end
end

--- Processes the change to a key bind
--- @param key string @The key to be used
function Button:KeybindOverlay_ProcessBinding(key)
	--if the button is locked, warn the user as to the locked status
	if self.keys and self.keys.hotKeyLock then
		UIErrorsFrame:AddMessage(L["Bindings_Locked_Notice"], 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	--if the key being pressed is escape, clear the bindings on the button
	if key == "ESCAPE" then
		self:KeybindOverlay_ClearBindings()

		--if the key is anything else, keybind the button to this key
	elseif key then --checks to see if another keybind already has that key, and if so clears it from the other button
		--check to see if any other button has this key bound to it, ignoring locked buttons, and if so remove the key from the other button
		for _, bar in pairs(Neuron.bars) do
			for _, button in pairs(bar.buttons) do
				if button.keybindFrame then
					if self ~= button and not button.keys.hotKeyLock then
						button.keys.hotKeys:gsub("[^:]+", function(binding)
							if key == binding then
								button:KeybindOverlay_ClearBindings(binding)
								button:KeybindOverlay_ApplyBindings()
							end
						end)
					end
				end
			end
		end

		--search the current hotKeys to see if our new key is missing, and if so add it
		local found
		self.keys.hotKeys:gsub("[^:]+", function(binding)
			if binding == key then
				found = true
			end
		end)

		if not found then
			self.keys.hotKeys = self.keys.hotKeys..key..":"
		end

		self:KeybindOverlay_ApplyBindings()

	end

	--update the tooltip to reflect the changes to the keybinds
	if self:IsVisible() then
		self:KeybindOverlay_OnEnter()
	end

end

--- OnShow Event handler
function Button:KeybindOverlay_OnShow()
	local priority = ""

	if self.keys.hotKeyPri then
		priority = "|cff00ff00"..L["Priority"].."|r\n"
	end

	if self.keys.hotKeyLock then
		self.keybindFrame.label:SetText(priority.."|cfff00000"..L["Locked"].."|r")
	else
		self.keybindFrame.label:SetText(priority.."|cffffffff"..L["Bind"].."|r")
	end

	--set a repeating timer when the Button is shown to enable or disable Keyboard input on mouseover.
	self.keybindFrame.keybindUpdateTimer = self:ScheduleRepeatingTimer(function()
		if self.keybindFrame:IsMouseOver() then
			self.keybindFrame:EnableKeyboard(true)
		else
			self.keybindFrame:EnableKeyboard(false)
		end
	end, 0.1)
end

--- OnHide Event handler
function Button:KeybindOverlay_OnHide()
	--Cancel the repeating time when hiding the bar
	self:CancelTimer(self.keybindFrame.keybindUpdateTimer)
end

--- OnEnter Event handler
function Button:KeybindOverlay_OnEnter()
	local name

	---TODO:we should definitely added name strings for pets/companions as well. This was just to get it going
	if self.spellID then
		name = GetSpellInfo(self.spellID)
	elseif self.actionSpell then
		name = self.actionSpell
	elseif self.macroitem then
		name = self.macroitem
	elseif self.macrospell then
		name = self.macrospell --this is kind of a catch-all
	end

	if not name then
		name = "Button"
	end

	self.keybindFrame.select:Show()

	GameTooltip:SetOwner(self.keybindFrame, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:SetText("Neuron", 1.0, 1.0, 1.0)
	GameTooltip:AddLine(L["Keybind_Tooltip_1"] .. ": |cffffffff" .. name  .. "|r")
	GameTooltip:AddLine(L["Keybind_Tooltip_2"] .. ": |cffffffff" .. self:KeybindOverlay_GetBindKeyList() .. "|r")
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["Keybind_Tooltip_3"])
	GameTooltip:AddLine(L["Keybind_Tooltip_4"])
	GameTooltip:AddLine(L["Keybind_Tooltip_5"])
	GameTooltip:Show()
end

--- OnLeave Event handler
function Button:KeybindOverlay_OnLeave()
	self.keybindFrame.select:Hide()
	GameTooltip:Hide()
end

--- OnClick Event handler
--- @param mousebutton string @The button that was clicked
function Button:KeybindOverlay_OnClick(mousebutton)
	if mousebutton == "LeftButton" then
		if self.keys.hotKeyLock then
			self.keys.hotKeyLock = false
		else
			self.keys.hotKeyLock = true
		end
		self:KeybindOverlay_OnShow()
		return
	end

	if mousebutton== "RightButton" then
		if self.keys.hotKeyPri then
			self.keys.hotKeyPri = false
		else
			self.keys.hotKeyPri = true
		end
		self:KeybindOverlay_ApplyBindings()
		self:KeybindOverlay_OnShow()
		return
	end

	local modifier = GetModifier()
	local key
	if mousebutton == "MiddleButton" then
		key = "Button3"
	else
		key = mousebutton
	end

	if modifier then
		key = modifier..key
	end

	self:KeybindOverlay_ProcessBinding(key)
end

--- OnKeyDown Event handler
--- @param key string @The key that was pressed
function Button:KeybindOverlay_OnKeyDown(key)
	if key:find("ALT") or key:find("SHIFT") or key:find("CTRL") or key:find("PRINTSCREEN") then
		return
	end

	local modifier = GetModifier()

	if modifier then
		key = modifier..key
	end

	self:KeybindOverlay_ProcessBinding(key)
end

--- OnMouseWheel Event handler
--- @param delta number @direction mouse wheel moved
function Button:KeybindOverlay_OnMouseWheel(delta)
	local modifier = GetModifier()
	local key
	local action

	if delta > 0 then
		key = "MOUSEWHEELUP"
		action = "MousewheelUp"
	else
		key = "MOUSEWHEELDOWN"
		action = "MousewheelDown"
	end

	if modifier then
		key = modifier..key
	end

	self:KeybindOverlay_ProcessBinding(key)
end
