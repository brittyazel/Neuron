--Neuron, a World of Warcraft® user interface addon.

---@class BAR
local BAR = setmetatable({}, {__index = CreateFrame("CheckButton")}) --this is the metatable for our button object
Neuron.BAR = BAR


local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


local MAS = Neuron.MANAGED_ACTION_STATES
local MBS = Neuron.MANAGED_BAR_STATES

local alphaDir, alphaTimer = 0, 0

local autoHideIndex, alphaupIndex = {}, {}

Neuron.AlphaUps = {
	L["Off"],
	L["Mouseover"],
	L["Combat"],
	L["Combat + Mouseover"],
	L["Retreat"],
	L["Retreat + Mouseover"],
}
local alphaUps = Neuron.AlphaUps


Neuron.BarShapes = {
	L["Linear"],
	L["Circle"],
	L["Circle + One"],
}


local statetable = {}

local barShapes = Neuron.BarShapes

local handlerMT = setmetatable({}, { __index = CreateFrame("Frame") })

local TRASHCAN = CreateFrame("Frame", nil, UIParent)
TRASHCAN:Hide()



---Constructor: Create a new Neuron BAR object
---@param name string @ Name given to the new bar frame
---@return BAR @ A newly created BUTTON object
function BAR:new(name)
	local object = CreateFrame("CheckButton", name, UIParent, "NeuronBarTemplate")
	setmetatable(object, {__index = BAR})
	return object
end





------------------------------------------------------------
--------------------Helper Functions------------------------
------------------------------------------------------------

local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function tFind(table, value)
	local index = 1;
	while table[index] do
		if ( value == table[index] ) then
			return index;
		end
		index = index + 1;
	end
	return 0;
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------



function BAR.IsMouseOverSelfOrWatchFrame(frame)
	if (frame:IsMouseOver()) then
		return true
	end

	if (frame.watchframes) then
		for handler in pairs(frame.watchframes) do
			if (handler:IsMouseOver() and handler:IsVisible()) then
				return true
			end
		end
	end

	return false
end


--this function gets called via controlOnUpdate in the main Neuron.lua
function BAR.controlOnUpdate(elapsed)
	for k,v in pairs(autoHideIndex) do
		if (v~=nil) then

			if not Neuron.buttonEditMode and not Neuron.barEditMode and not Neuron.bindingMode then

				if (k:IsShown()) then
					v:SetAlpha(1)
				else

					if (BAR.IsMouseOverSelfOrWatchFrame(k)) then
						if (v:GetAlpha() < k.alpha) then
							if (v:GetAlpha()+v.fadeSpeed <= 1) then
								v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
							else
								v:SetAlpha(1)
							end
						else
							k.seen = 1;
						end

					end

					if (not BAR.IsMouseOverSelfOrWatchFrame(k)) then
						if (v:GetAlpha() > 0) then
							if (v:GetAlpha()-v.fadeSpeed >= 0) then
								v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
							else
								v:SetAlpha(0)
							end
						else
							k.seen = 0;
						end
					end
				end
			end
		end
	end

	for k,v in pairs(alphaupIndex) do
		if (v~=nil) then

			if (k:IsShown()) then
				v:SetAlpha(1)
			else

				if (k.alphaUp == alphaUps[3] or k.alphaUp == alphaUps[4]) then

					if (InCombatLockdown()) then

						if (v:GetAlpha() < 1) then
							if (v:GetAlpha()+v.fadeSpeed <= 1) then
								v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
							else
								v:SetAlpha(1)
							end
						else
							k.seen = 1;
						end

					else
						if (k.alphaUp == alphaUps[4]) then

							if (BAR.IsMouseOverSelfOrWatchFrame(k)) then
								if (v:GetAlpha() < 1) then
									if (v:GetAlpha()+v.fadeSpeed <= 1) then
										v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
									else
										v:SetAlpha(1)
									end
								else
									k.seen = 1;
								end
							else
								if (v:GetAlpha() > k.alpha) then
									if (v:GetAlpha()-v.fadeSpeed >= k.alpha) then
										v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
									else
										v:SetAlpha(k.alpha)
									end
								else
									k.seen = 0;
								end
							end
						else
							if (v:GetAlpha() > k.alpha) then
								if (v:GetAlpha()-v.fadeSpeed >= k.alpha) then
									v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
								else
									v:SetAlpha(k.alpha)
								end
							else
								k.seen = 0;
							end
						end
					end

				elseif (k.alphaUp == alphaUps[5] or k.alphaUp == alphaUps[6]) then

					if (not InCombatLockdown()) then

						if (v:GetAlpha() < 1) then
							if (v:GetAlpha()+v.fadeSpeed <= 1) then
								v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
							else
								v:SetAlpha(1)
							end
						else
							k.seen = 1;
						end

					else
						if (k.alphaUp == alphaUps[6]) then

							if (BAR.IsMouseOverSelfOrWatchFrame(k)) then
								if (v:GetAlpha() < 1) then
									if (v:GetAlpha()+v.fadeSpeed <= 1) then
										v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
									else
										v:SetAlpha(1)
									end
								else
									k.seen = 1;
								end
							else
								if (v:GetAlpha() > k.alpha) then
									if (v:GetAlpha()-v.fadeSpeed >= k.alpha) then
										v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
									else
										v:SetAlpha(k.alpha)
									end
								else
									k.seen = 0;
								end
							end
						else
							if (v:GetAlpha() > k.alpha) then
								if (v:GetAlpha()-v.fadeSpeed >= k.alpha) then
									v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
								else
									v:SetAlpha(k.alpha)
								end
							else
								k.seen = 0;
							end
						end
					end

				elseif (k.alphaUp == alphaUps[2]) then

					if (BAR.IsMouseOverSelfOrWatchFrame(k)) then
						if (v:GetAlpha() < 1) then
							if (v:GetAlpha()+v.fadeSpeed <= 1) then
								v:SetAlpha(v:GetAlpha()+v.fadeSpeed)
							else
								v:SetAlpha(1)
							end
						else
							k.seen = 1;
						end
					else
						if (v:GetAlpha() > k.alpha) then
							if (v:GetAlpha()-v.fadeSpeed >= k.alpha) then
								v:SetAlpha(v:GetAlpha()-v.fadeSpeed)
							else
								v:SetAlpha(k.alpha)
							end
						else
							k.seen = 0;
						end
					end
				end
			end
		end
	end
end


function BAR:SetHidden(handler, show, hide)

	for k,v in pairs(self.vis) do
		if (v.registered) then
			return
		end
	end

	local isAnchorChild = handler:GetAttribute("isAnchorChild")

	if (not hide and not isAnchorChild and (show or self:IsVisible())) then

		handler:Show()
	else
		if (self.data.conceal) then
			handler:SetAttribute("concealed", true)
			handler:Hide()
		elseif (not self.data.barLink and not isAnchorChild) then
			handler:SetAttribute("concealed", nil)
			handler:Show()
		end
	end
end

function BAR:SetAutoHide(handler)

	if (self.data.autoHide) then
		autoHideIndex[self] = handler
		handler.fadeSpeed = (self.data.fadeSpeed*self.data.fadeSpeed)
	else
		autoHideIndex[self] = nil
	end

	if (self.data.alphaUp == L["Off"]) then
		alphaupIndex[self] = nil
	else
		alphaupIndex[self] = handler
		handler.fadeSpeed = (self.data.fadeSpeed*self.data.fadeSpeed)
	end
end


function BAR:AddVisibilityDriver(handler, state, conditions)

	if (MBS[state]) then

		RegisterStateDriver(handler, state, conditions)

		if (handler:GetAttribute("activestates"):find(state)) then
			handler:SetAttribute("activestates", handler:GetAttribute("activestates"):gsub(state.."%d+;", handler:GetAttribute("state-"..state)..";"))
		elseif (handler:GetAttribute("activestates") and handler:GetAttribute("state-"..state)) then
			handler:SetAttribute("activestates", handler:GetAttribute("activestates")..handler:GetAttribute("state-"..state)..";")
		end

		if (handler:GetAttribute("state-"..state)) then
			handler:SetAttribute("state-"..state, handler:GetAttribute("state-"..state))
		end

		self.vis[state].registered = true
	end
end


function BAR:ClearVisibilityDriver(handler, state)

	UnregisterStateDriver(handler, state)

	handler:SetAttribute("activestates", handler:GetAttribute("activestates"):gsub(state.."%d+;", ""))
	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")

	self.vis[state].registered = false
end


function BAR:UpdateVisibility(driver)

	for state, values in pairs(MBS) do

		if (self.data.hidestates:find(":"..state)) then

			if (not self.vis[state] or not self.vis[state].registered) then

				if (not self.vis[state]) then
					self.vis[state] = {}
				end

				if (state == "stance" and self.data.hidestates:find(":stance8")) then
					self:AddVisibilityDriver(driver,state, "[stance:2/3,stealth] stance8; "..values.states)
				else
					self:AddVisibilityDriver(driver, state, values.states)
				end
			end

		elseif (self.vis[state] and self.vis[state].registered) then

			self:ClearVisibilityDriver(driver, state)

		end
	end
end

function BAR:BuildStateMap(remapState)

	local statemap, state, map, remap, homestate = "", remapState:gsub("paged", "bar")

	for states in gmatch(self.data.remap, "[^;]+") do

		map, remap = (":"):split(states)

		if (remapState == "stance" and Neuron.class == "ROGUE" and map == "1") then
			--map = "2"
		end

		if (not homestate) then
			statemap = statemap.."["..state..":"..map.."] homestate; "; homestate = true
		else
			local newstate = remapState..remap

			if (MAS[remapState] and
					MAS[remapState].homestate and
					MAS[remapState].homestate == newstate) then
				statemap = statemap.."["..state..":"..map.."] homestate; "
			else
				statemap = statemap.."["..state..":"..map.."] "..newstate.."; "
			end
		end
	end

	statemap = gsub(statemap, "; $", "")

	return statemap
end


function BAR:AddStates(handler, state, conditions)

	if (state) then

		if (MAS[state]) then
			RegisterStateDriver(handler, state, conditions)
		end

		if (MAS[state].homestate) then
			handler:SetAttribute("handler-homestate", MAS[state].homestate)
		end

		self[state].registered = true
	end

end

function BAR:ClearStates(handler, state)

	if (state ~= "homestate") then

		if (MAS[state].homestate) then
			handler:SetAttribute("handler-homestate", nil)
		end

		handler:SetAttribute("state-"..state, nil)

		UnregisterStateDriver(handler, state)

		self[state].registered = false
	end

	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")
end


function BAR:UpdateStates(handler)
	for state, values in pairs(MAS) do

		if (self.data[state]) then

			if (not self[state] or not self[state].registered) then

				local statemap

				if (not self[state]) then
					self[state] = {}
				end

				if (self.data.remap and (state == "paged" or state == "stance")) then
					statemap = self:BuildStateMap(state)
				end


				if (state == "custom" and self.data.custom) then

					self:AddStates(handler, state, self.data.custom)

				elseif (statemap) then

					self:AddStates(handler, state, statemap)

				else
					self:AddStates(handler, state, values.states)

				end
			end

		elseif (self[state] and self[state].registered) then

			self:ClearStates(handler, state)

		end
	end
end


function BAR:CreateDriver()

	--This is the macro base that will be used to set state
	local DRIVER_BASE_ACTION = [[
	local state = self:GetAttribute("state-<MODIFIER>"):match("%a+")

	if (state) then

		if (self:GetAttribute("activestates"):find(state)) then
			self:SetAttribute("activestates", self:GetAttribute("activestates"):gsub(state.."%d+;", self:GetAttribute("state-<MODIFIER>")..";"))
		else
			self:SetAttribute("activestates", self:GetAttribute("activestates")..self:GetAttribute("state-<MODIFIER>")..";")
		end

		control:ChildUpdate("<MODIFIER>", self:GetAttribute("activestates"))
	end
	]]

	local driver = CreateFrame("Frame", "NeuronBarDriver"..self:GetID(), UIParent, "SecureHandlerStateTemplate")

	setmetatable(driver, { __index = handlerMT })

	driver:SetID(self:GetID())
	--Dynamicly builds driver attributes based on stated in Neuron.STATEINDEX using localized attribute text from a above
	for _, modifier in pairs(Neuron.STATEINDEX) do
		local action = DRIVER_BASE_ACTION:gsub("<MODIFIER>", modifier)
		driver:SetAttribute("_onstate-"..modifier, action)
	end

	driver:SetAttribute("activestates", "")

	driver:HookScript("OnAttributeChanged", function() end)

	driver:SetAllPoints(self)

	self.driver = driver
	driver.bar = self
end


function BAR:CreateHandler()

	local HANDLER_BASE_ACTION = [[
	if (self:GetAttribute("state-<MODIFIER>") == "laststate") then

		if (self:GetAttribute("statestack")) then

			if (self:GetAttribute("statestack"):find("<MODIFIER>")) then
				self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("<MODIFIER>%d+;", ""))
			end

			local laststate = (";"):split(self:GetAttribute("statestack"))

			self:SetAttribute("state-last", laststate)

		end

		self:SetAttribute("state-current", self:GetAttribute("state-last") or "homestate")

		if (self:GetAttribute("state-last")) then
			self:SetAttribute("assertstate", self:GetAttribute("state-last"):gsub("%d+", ""))
		else
			self:SetAttribute("assertstate", "homestate")
		end

		if (self:GetAttribute("state-priority")) then
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-priority"))
		else
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-last") or "homestate")
		end

	elseif (self:GetAttribute("state-<MODIFIER>")) then

		if (self:GetAttribute("statestack")) then
			if (self:GetAttribute("statestack"):find("<MODIFIER>")) then
				self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("<MODIFIER>%d+", self:GetAttribute("state-<MODIFIER>")))
			else
				self:SetAttribute("statestack", self:GetAttribute("state-<MODIFIER>")..";"..self:GetAttribute("statestack"))
			end
		else
			self:SetAttribute("statestack", self:GetAttribute("state-<MODIFIER>"))
		end

		self:SetAttribute("state-current", self:GetAttribute("state-<MODIFIER>"))

		self:SetAttribute("assertstate", "<MODIFIER>")

		if (self:GetAttribute("state-priority")) then
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-priority"))
		else
			control:ChildUpdate("<MODIFIER>", self:GetAttribute("state-<MODIFIER>"))
		end
	end
	]]

	local handler = CreateFrame("Frame", "NeuronBarHandler"..self:GetID(), self.driver, "SecureHandlerStateTemplate")

	setmetatable(handler, { __index = handlerMT })

	handler:SetID(self:GetID())

	--Dynamicly builds handler actions based on states in Neuron.STATEINDEX using Global text
	for _, modifier in pairs(Neuron.STATEINDEX) do
		local action = HANDLER_BASE_ACTION:gsub("<MODIFIER>", modifier)
		handler:SetAttribute("_onstate-"..modifier, action)
	end

	handler:SetAttribute("_onstate-paged", [[

						if (self:GetAttribute("statestack")) then
							if (self:GetAttribute("statestack"):find("paged")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("paged%d+", self:GetAttribute("state-paged") or "homestate"))
							elseif (self:GetAttribute("statestack"):find("homestate")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("homestate", self:GetAttribute("state-paged") or "homestate"))
							elseif (self:GetAttribute("state-paged")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack")..";"..self:GetAttribute("state-paged"))
							end
						else
							self:SetAttribute("statestack", self:GetAttribute("state-paged"))
						end

						if (self:GetAttribute("statestack"):find("^paged") or self:GetAttribute("statestack"):find("^homestate")) then

							self:SetAttribute("assertstate", "paged")

							self:SetAttribute("state-last", self:GetAttribute("state-paged"))

							self:SetAttribute("state-current", self:GetAttribute("state-paged"))

							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("paged", self:GetAttribute("state-priority"))
							elseif (self:GetAttribute("state-paged") and self:GetAttribute("state-paged") == self:GetAttribute("handler-homestate")) then
								control:ChildUpdate("paged", "homestate:"..self:GetAttribute("state-paged"))
							else
								control:ChildUpdate("paged", self:GetAttribute("state-paged"))
							end
						else
							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("homestate", self:GetAttribute("state-priority"))
							else
								control:ChildUpdate("homestate", "homestate")
							end
						end

						]])

	handler:SetAttribute("_onstate-stance", [[

						if (self:GetAttribute("statestack")) then
							if (self:GetAttribute("statestack"):find("stance")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("stance%d+", self:GetAttribute("state-stance") or "homestate"))
							elseif (self:GetAttribute("statestack"):find("homestate")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("homestate", self:GetAttribute("state-stance") or "homestate"))
							elseif (self:GetAttribute("state-stance")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack")..";"..self:GetAttribute("state-stance"))
							end
						else
							self:SetAttribute("statestack", self:GetAttribute("state-stance"))
						end

						if (self:GetAttribute("statestack"):find("^stance") or self:GetAttribute("statestack"):find("^homestate")) then

							self:SetAttribute("assertstate", "stance")

							self:SetAttribute("state-last", self:GetAttribute("state-stance"))

							self:SetAttribute("state-current", self:GetAttribute("state-stance"))

							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("stance", self:GetAttribute("state-priority"))
							elseif (self:GetAttribute("state-stance") and self:GetAttribute("state-stance") == self:GetAttribute("handler-homestate")) then
								control:ChildUpdate("stance", "homestate:"..self:GetAttribute("state-stance"))
							else
								control:ChildUpdate("stance", self:GetAttribute("state-stance"))
							end
						else
							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("homestate", self:GetAttribute("state-priority"))
							else
								control:ChildUpdate("homestate", "homestate")
							end
						end

						]])

	handler:SetAttribute("_onstate-pet", [[

						if (self:GetAttribute("statestack")) then
							if (self:GetAttribute("statestack"):find("pet")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("pet%d+", self:GetAttribute("state-pet") or "homestate"))
							elseif (self:GetAttribute("statestack"):find("homestate")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack"):gsub("homestate", self:GetAttribute("state-pet" or "homestate")))
							elseif (self:GetAttribute("state-pet")) then
								self:SetAttribute("statestack", self:GetAttribute("statestack")..";"..self:GetAttribute("state-pet"))
							end
						else
							self:SetAttribute("statestack", self:GetAttribute("state-pet"))
						end

						if (self:GetAttribute("statestack"):find("^pet") or self:GetAttribute("statestack"):find("^homestate")) then

							self:SetAttribute("assertstate", "pet")

							self:SetAttribute("state-last", self:GetAttribute("state-pet"))

							self:SetAttribute("state-current", self:GetAttribute("state-pet"))

							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("stance", self:GetAttribute("state-priority"))
							elseif (self:GetAttribute("state-pet") and self:GetAttribute("state-pet") == self:GetAttribute("handler-homestate")) then
								control:ChildUpdate("pet", "homestate:"..self:GetAttribute("state-pet"))
							else
								control:ChildUpdate("pet", self:GetAttribute("state-pet"))
							end
						else
							if (self:GetAttribute("state-priority")) then
								control:ChildUpdate("homestate", self:GetAttribute("state-priority"))
							else
								control:ChildUpdate("homestate", "homestate")
							end
						end

						]])

	handler:SetAttribute("_onstate-custom", [[

						self:SetAttribute("assertstate", "custom")

						self:SetAttribute("state-last", self:GetAttribute("state-custom"))

						self:SetAttribute("state-current", self:GetAttribute("state-custom"))

						control:ChildUpdate("alt", self:GetAttribute("state-custom"))

						]])

	handler:SetAttribute("_onstate-current", [[ self:SetAttribute("activestate", self:GetAttribute("state-current") or "homestate") ]])

	handler:SetAttribute("statestack", "homestate")

	handler:SetAttribute("activestate", "homestate")

	handler:SetAttribute("state-last", "homestate")

	handler:HookScript("OnAttributeChanged", function() end)


	handler:SetAttribute("_childupdate", [[

			if (not self:GetAttribute("editmode")) then

				self:SetAttribute("vishide", false)

				if (self:GetAttribute("hidestates")) then
					for state in gmatch(message, "[^;]+") do
						for hidestate in gmatch(self:GetAttribute("hidestates"), "[^:]+") do
							if (state == hidestate) then
								self:Hide()
								self:SetAttribute("vishide", true)
							end
						end
					end
				end

				if (not self:IsShown() and not self:GetAttribute("vishide")) then
					self:Show()
				end
			end

	]] )

	handler:SetAllPoints(self)

	self.handler = handler;
	handler.bar = self

end


function BAR:CreateWatcher()
	local watcher = CreateFrame("Frame", "NeuronBarWatcher"..self:GetID(), self.handler, "SecureHandlerStateTemplate")

	setmetatable(watcher, { __index = handlerMT })

	watcher:SetID(self:GetID())

	watcher:SetAttribute("_onattributechanged", [[ ]])

	watcher:SetAttribute("_onstate-petbattle", [[

            if (self:GetAttribute("state-petbattle") == "hide") then
                self:GetParent():Hide()
            else
                if (not self:GetParent():IsShown()) then
                    if (not self:GetParent():GetAttribute("vishide") and not self:GetParent():GetAttribute("concealed")) then
                        self:GetParent():Show()
                    end
                end
            end
    ]])

	RegisterStateDriver(watcher, "petbattle", "[petbattle] hide; [nopetbattle] show")

end


function BAR:Update(show, hide)

	if(InCombatLockdown()) then
		return
	end

	local handler, driver = self.handler, self.driver

	self.elapsed = 0;
	self.alpha = self.data.alpha;
	self.alphaUp = self.data.alphaUp

	if (self.stateschanged) then

		self:UpdateStates(handler)

		self.stateschanged = nil
	end

	if (self.vischanged) then

		handler:SetAttribute("hidestates", self.data.hidestates)

		self:UpdateVisibility(driver)

		self.vischanged = nil
	end

	if (self.countChanged) then

		self:UpdateObjectData()

		self.countChanged = nil

	end

	self:SetHidden(handler, show, hide)
	self:SetAutoHide(handler)
	self.text:SetText(self.data.name)
	handler:SetAlpha(self.data.alpha)

	if (not hide and NeuronBarEditor and NeuronBarEditor:IsVisible()) then
		Neuron.NeuronGUI:UpdateBarGUI()
	end
end


function BAR:GetPosition(oFrame)
	local relFrame, point

	if (oFrame) then
		relFrame = oFrame
	else
		relFrame = self:GetParent()
	end

	local s = self:GetScale()
	local w, h = relFrame:GetWidth()/s, relFrame:GetHeight()/s
	local x, y = self:GetCenter()
	local vert = (y>h/1.5) and "TOP" or (y>h/3) and "CENTER" or "BOTTOM"
	local horz = (x>w/1.5) and "RIGHT" or (x>w/3) and "CENTER" or "LEFT"

	if (vert == "CENTER") then
		point = horz
	elseif (horz == "CENTER") then
		point = vert
	else
		point = vert..horz
	end

	if (vert:find("CENTER")) then y = y - h/2 end
	if (horz:find("CENTER")) then x = x - w/2 end
	if (point:find("RIGHT")) then x = x - w end
	if (point:find("TOP")) then y = y - h end

	return point, x, y
end


function BAR:SetPosition()
	if (self.data.snapToPoint and self.data.snapToFrame) then
		self:StickToPoint(_G[self.data.snapToFrame], self.data.snapToPoint, self.data.padH, self.data.padV)
	else

		local point, x, y = self.data.point, self.data.x, self.data.y

		if (point:find("SnapTo")) then
			self.data.point = "CENTER"; point = "CENTER"
		end

		self:SetUserPlaced(false)
		self:ClearAllPoints()
		self:SetPoint("CENTER", "UIParent", point, x, y)
		self:SetUserPlaced(true)
		self:SetFrameStrata(self.data.barStrata)

		if (self.message) then
			self.message:SetText(point:lower().."     x: "..format("%0.2f", x).."     y: "..format("%0.2f", y))
			self.messagebg:SetWidth(self.message:GetWidth()*1.05)
			self.messagebg:SetHeight(self.message:GetHeight()*1.1)
		end

		self.posSet = true
	end
end


---Fakes a state change for a given bar, calls up the counterpart function in NeuronButton
function BAR:SetFauxState(state)
	self.handler:SetAttribute("fauxstate", state)

	for i, object in ipairs(self.buttons) do
		object:SetFauxState(state)
	end

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		Neuron.NeuronGUI:UpdateObjectGUI()
	end
end


---loads all the object stored for a given bar
function BAR:LoadObjects(init)
	local spec

	if (self.data.multiSpec) then
		spec = GetSpecialization()
	else
		spec = 1
	end

	for i, object in ipairs(self.buttons) do
		---all of these objects need to stay as "object:****" because which SetData/LoadData/etc is bar dependent. Symlinks are made to the asociated bar objects to these class functions
		object:SetData(self)
		object:LoadData(spec, self.handler:GetAttribute("activestate"))
		object:SetType()
		object:SetAux()

		object:SetObjectVisibility()

	end
end


function BAR:SetObjectLoc()
	local width, height, num, origCol = 0, 0, 0, self.data.columns
	local x, y, lastObj, placed
	local shape, padH, padV, arcStart, arcLength = self.data.shape, self.data.padH, self.data.padV, self.data.arcStart, self.data.arcLength
	local cAdjust, rAdjust = 0.5, 1
	local columns, rows


	---This is just for the flyout bar, it should be cleaned in the future
	local count
	if self.class ~= "FlyoutBar" then
		count = #self.buttons
	else
		count = #self.data.objectList
	end

	local buttons = {}
	if self.class ~= "FlyoutBar" then
		buttons = self.buttons
	else
		for k,v in pairs (self.data.objectList) do
			table.insert(buttons, Neuron.FOBTNIndex[v])
		end
	end
	--------------------------------------------------------------------------

	if (not origCol) then
		origCol = count; rows = 1
	else
		rows = (round(ceil(count/self.data.columns), 1)/2)+0.5
	end

	for i, object in ipairs(buttons) do --once the flyout bars are fixed, this can be changed to ipairs(self.buttons)

		if (num < count) then
			object:ClearAllPoints()
			object:SetParent(self.handler)
			object:SetAttribute("lastPos", nil)
			width = object:GetWidth(); height = object:GetHeight()

			if (count > origCol and mod(count, origCol)~=0 and rAdjust == 1) then
				columns = (mod(count, origCol))/2
			elseif (origCol >= count) then
				columns = count/2
			else
				columns = origCol/2
			end

			if (shape == 2) then
				if (not placed) then
					placed = arcStart
				end

				x = ((width+padH)*(count/math.pi))*(cos(placed))
				y = ((width+padV)*(count/math.pi))*(sin(placed))

				object:SetPoint("CENTER", self, "CENTER", x, y)

				placed = placed - (arcLength/count)

			elseif (shape == 3) then
				if (not placed) then
					placed = arcStart
					object:SetPoint("CENTER", self, "CENTER", 0, 0)
					placed = placed - (arcLength/count)

				else
					x = ((width+padH)*(count/math.pi))*(cos(placed))
					y = ((width+padV)*(count/math.pi))*(sin(placed))

					object:SetPoint("CENTER", self, "CENTER", x, y)
					placed = placed - (arcLength/(count-1))
				end
			else
				if (not placed) then
					placed = 0
				end

				x = -(width + padH) * (columns-cAdjust)
				y = (height + padV) * (rows-rAdjust)

				object:SetPoint("CENTER", self, "CENTER", x, y)
				placed = placed + 1; cAdjust = cAdjust + 1

				if (placed >= columns*2) then
					placed = 0
					cAdjust = 0.5
					rAdjust = rAdjust + 1
				end
			end

			lastObj = object
			num = num + 1
			object:SetAttribute("barPos", num)
			object:SetData(self)
			object:SetData(self)
		end
	end

	if (lastObj) then
		lastObj:SetAttribute("lastPos", true)
	end
end


function BAR:SetPerimeter()
	local num = 0

	---This is just for the flyout bar, it should be cleaned in the future
	local count
	if self.class ~= "FlyoutBar" then
		count = #self.buttons
	else
		count = #self.data.objectList
	end

	local buttons = {}
	if self.class ~= "FlyoutBar" then
		buttons = self.buttons
	else
		for k,v in pairs (self.data.objectList) do
			table.insert(buttons, Neuron.FOBTNIndex[v])
		end
	end
	-----------------------------------------------

	self.top = nil; self.bottom = nil; self.left = nil; self.right = nil

	for i, object in ipairs(buttons) do --once the flyout bars are fixed, this can be changed to ipairs(self.buttons)

		if (num < count) then
			local objTop, objBottom, objLeft, objRight = object:GetTop(), object:GetBottom(), object:GetLeft(), object:GetRight()
			local scale = 1
			--See if this fixes the ranom position error that happens
			if not objTop then return end

			if (self.top) then
				if (objTop*scale > self.top) then self.top = objTop*scale end
			else self.top = objTop*scale end

			if (self.bottom) then
				if (objBottom*scale < self.bottom) then self.bottom = objBottom*scale end
			else self.bottom = objBottom*scale end

			if (self.left) then
				if (objLeft*scale < self.left) then self.left = objLeft*scale end
			else self.left = objLeft*scale end

			if (self.right) then
				if (objRight*scale > self.right) then self.right = objRight*scale end
			else self.right = objRight*scale end

			num = num + 1
		end
	end
end


function BAR:SetDefaults(defaults)
	for k,v in pairs(defaults) do
		if k ~= "buttons" then --ignore this value because it's just used to tell how many buttons should be placed on a bar by default on the first load
			self.data[k] = v
		end
	end
end


function BAR:SetRemap_Paged()
	self.data.remap = ""

	for i=1,6 do
		self.data.remap = self.data.remap..i..":"..i..";"
	end

	self.data.remap = gsub(self.data.remap, ";$", "")
end


function BAR:SetRemap_Stance()
	local start = tonumber(MAS.stance.homestate:match("%d+"))

	if (start) then
		self.data.remap = ""

		for i=start,GetNumShapeshiftForms() do
			self.data.remap = self.data.remap..i..":"..i..";"
		end

		self.data.remap = gsub(self.data.remap, ";$", "")


		if (Neuron.class == "ROGUE") then
			self.data.remap = self.data.remap..";2:2"
		end
	end
end


function BAR:SetSize()
	if (self.right) then
		self:SetWidth(((self.right-self.left)+5)*(self.data.scale))
		self:SetHeight(((self.top-self.bottom)+5)*(self.data.scale))
	else
		self:SetWidth(195)
		self:SetHeight(36*(self.data.scale))
	end
end

----------------------------------------------------------------------
----------------------------------------------------------------------
------------------------Event Handlers __-----------------------------
---TODO:I need to figure out what to do with this

--[[function NeuronBar:ACTIVE_TALENT_GROUP_CHANGED(bar, ...)
	if (Neuron.enteredWorld) then
		bar.stateschanged = true
		bar.vischanged = true
		bar:Update()
	end
end]]
----------------------------------------------------------------------
----------------------------------------------------------------------




----------------------------------------------------------------------
----------------------------------------------------------------------
------------------------OnEvent Functions-----------------------------
---this function brokers the on event call to the correct bar
function BAR:OnEvent(event, ...)
	if (self[event]) then
		self[event](self, self, ...)
	end
end


function BAR:OnClick(...)
	local click, down, newBar = select(1, ...), select(2, ...)

	if (not down) then
		newBar = self:ChangeBar()
	end

	self.click = click
	self.dragged = false
	self.elapsed = 0
	self.pushed = 0

	if (IsShiftKeyDown() and not down) then

		if (self.microAdjust) then
			self.microAdjust = false
			self:EnableKeyboard(false)
			self.message:Hide()
			self.messagebg:Hide()
		else
			self.data.snapTo = false
			self.data.snapToPoint = false
			self.data.snapToFrame = false
			self.microAdjust = 1
			self:EnableKeyboard(true)
			self.message:Show()
			self.message:SetText(self.data.point:lower().."     x: "..format("%0.2f", self.data.x).."     y: "..format("%0.2f", self.data.y))
			self.messagebg:Show()
			self.messagebg:SetWidth(self.message:GetWidth()*1.05)
			self.messagebg:SetHeight(self.message:GetHeight()*1.1)
		end

	elseif (click == "MiddleButton") then
		if (GetMouseFocus() ~= Neuron.CurrentBar) then
			newBar = self:ChangeBar()
		end

		if (down) then
			--Neuron:ConcealBar(nil, true)
		end

	elseif (click == "RightButton" and not self.action and not down) then
		self.mousewheelfunc = nil

		if (NeuronBarEditor) then
			if (not newBar and NeuronBarEditor:IsVisible()) then
				NeuronBarEditor:Hide()
			else
				NeuronBarEditor:Show()
			end
		end

	elseif (not down) then
		if (not newBar) then
			--updateState(bar, 1)
		end
	end

	if (not down and NeuronBarEditor and NeuronBarEditor:IsVisible()) then
		Neuron.NeuronGUI:UpdateBarGUI(newBar)
	end
end


function BAR:OnEnter(...)
	if (self.data.conceal) then
		self:SetBackdropColor(1,0,0,0.6)
	else
		self:SetBackdropColor(0,0,1,0.5)
	end

	self.text:Show()
end


function BAR:OnLeave(...)
	if (self ~= Neuron.CurrentBar) then
		if (self.data.conceal) then
			self:SetBackdropColor(1,0,0,0.4)
		else
			self:SetBackdropColor(0,0,0,0.4)
		end
	end

	if (self ~= Neuron.CurrentBar) then
		self.text:Hide()
	end
end


function BAR:OnDragStart(...)
	self:ChangeBar()

	self:SetFrameStrata(self.data.barStrata)
	self:EnableKeyboard(false)

	self.adjusting = true
	self.selected = true
	self.isMoving = true

	self.data.snapToPoint = false
	self.data.snapToFrame = false

	self:StartMoving()
end


function BAR:OnDragStop(...)

	local point
	self:StopMovingOrSizing()

	for _,v in pairs(Neuron.BARIndex) do
		if (not point and self.data.snapTo and v.data.snapTo and self ~= v) then
			point = self:Stick(v, Neuron.SNAPTO_TOLLERANCE, self.data.padH, self.data.padV)

			if (point) then
				self.data.snapToPoint = point
				self.data.snapToFrame = v:GetName()
				self.data.point = "SnapTo: "..point
				self.data.x = 0
				self.data.y = 0
			end
		end
	end

	if (not point) then
		self.data.snapToPoint = false
		self.data.snapToFrame = false
		self.data.point, self.data.x, self.data.y = self:GetPosition()
		self:SetPosition()
	end

	if (self.data.snapTo and not self.data.snapToPoint) then
		self:StickToEdge()
	end

	self.isMoving = false
	self.dragged = true
	self.elapsed = 0
	self:Update()
end

function BAR:OnKeyDown(key, onupdate)
	if (self.microAdjust) then
		self.keydown = key

		if (not onupdate) then
			self.elapsed = 0
		end

		self.data.point, self.data.x, self.data.y = self:GetPosition()
		self:SetUserPlaced(false)
		self:ClearAllPoints()

		if (key == "UP") then
			self.data.y = self.data.y + .1 * self.microAdjust
		elseif (key == "DOWN") then
			self.data.y = self.data.y - .1 * self.microAdjust
		elseif (key == "LEFT") then
			self.data.x = self.data.x - .1 * self.microAdjust
		elseif (key == "RIGHT") then
			self.data.x = self.data.x + .1 * self.microAdjust
		elseif (not key:find("SHIFT")) then
			self.microAdjust = false
			self:EnableKeyboard(false)
		end

		self:SetPosition()
	end
end


function BAR:OnKeyUp(key)
	if (self.microAdjust and not key:find("SHIFT")) then
		self.microAdjust = 1
		self.keydown = nil
		self.elapsed = 0
	end
end


function BAR:OnShow()
	if (self == Neuron.CurrentBar) then

		if (self.data.conceal) then
			self:SetBackdropColor(1,0,0,0.6)
		else
			self:SetBackdropColor(0,0,1,0.5)
		end

	else
		if (self.data.conceal) then
			self:SetBackdropColor(1,0,0,0.4)
		else
			self:SetBackdropColor(0,0,0,0.4)
		end
	end

	self.handler:SetAttribute("editmode", true)
	self.handler:Show()
	self:UpdateObjectVisibility()
	self:EnableKeyboard(false)
end


function BAR:OnHide()
	self.handler:SetAttribute("editmode", nil)

	if (self.handler:GetAttribute("vishide")) then
		self.handler:Hide()
	end

	self:UpdateObjectVisibility()
	self:EnableKeyboard(false)
end


function BAR:Pulse(elapsed)
	alphaTimer = alphaTimer + elapsed * 1.5

	if (alphaDir == 1) then
		if (1-alphaTimer <= 0) then
			alphaDir = 0; alphaTimer = 0
		end
	else
		if (alphaTimer >= 1) then
			alphaDir = 1; alphaTimer = 0
		end
	end

	if (alphaDir == 1) then
		if ((1-(alphaTimer)) >= 0) then
			self:SetAlpha(1-(alphaTimer))
		end
	else
		if ((alphaTimer) <= 1) then
			self:SetAlpha((alphaTimer))
		end
	end

	self.pulse = true
end

---TODO: This is probably a source of inefficiency
function BAR:OnUpdate(elapsed)
	if (Neuron.enteredWorld) then

		if (self.elapsed) then
			self.elapsed = self.elapsed + elapsed

			if (self.elapsed > 10) then
				self.elapsed = 0.75
			end

			if (self.microAdjust and not self.action) then
				self:Pulse(elapsed)

				if (self.keydown and self.elapsed >= 0.5) then
					self.microAdjust = self.microAdjust + 1
					self:OnKeyDown(self.keydown, self.microAdjust)
				end

			elseif (self.pulse) then
				self:SetAlpha(1)
				self.pulse = nil
			end

			if (self.hover) then
				self.elapsed = 0
			end
		end

		if (GetMouseFocus() == self) then
			if (not self.wheel) then
				self:EnableMouseWheel(true)
				self.wheel = true
			end
		elseif (self.wheel) then
			self:EnableMouseWheel(false)
			self.wheel = nil
		end

	end
end


---------------------------------------------------------------------------
---------------------------------------------------------------------------


function BAR:LoadData()

	self.data = self.DB

	if (not self.data.name or self.data.name == ":") then
		self.data.name = self.barLabel.." "..self:GetID()
	end
end


function BAR:UpdateObjectData()
	for _, object in pairs(self.buttons) do

		if (object) then
			object:SetData(self)
		end
	end
end


function BAR:UpdateObjectVisibility(show)
	for _, object in pairs(self.buttons) do
		if (object) then
			object:SetObjectVisibility(show)
		end
	end
end



function BAR:ChangeBar()
	local newBar = false

	if (Neuron.enteredWorld) then

		if (self and Neuron.CurrentBar ~= self) then
			Neuron.CurrentBar = self

			self.selected = true
			self.action = nil

			self:SetFrameLevel(3)

			if (self.data.hidden) then
				self:SetBackdropColor(1,0,0,0.6)
			else
				self:SetBackdropColor(0,0,1,0.5)
			end

			newBar = true
		end

		if (not self) then
			Neuron.CurrentBar = nil
		elseif (self.text) then
			self.text:Show()
		end

		for k,v in pairs(Neuron.BARIndex) do
			if (v ~= self) then

				if (v.data.conceal) then
					v:SetBackdropColor(1,0,0,0.4)
				else
					v:SetBackdropColor(0,0,0,0.4)
				end

				v:SetFrameLevel(2)
				v.selected = false
				v.microAdjust = false
				v:EnableKeyboard(false)
				v.text:Hide()
				v.message:Hide()
				v.messagebg:Hide()
				v.mousewheelfunc = nil
				v.action = nil
			end
		end

		if (Neuron.CurrentBar) then
			self:OnEnter(Neuron.CurrentBar)
		end
	end

	return newBar
end

function BAR:DeleteBar()
	local handler = self.handler

	handler:SetAttribute("state-current", "homestate")
	handler:SetAttribute("state-last", "homestate")
	handler:SetAttribute("showstates", "homestate")
	self:ClearStates(handler, "homestate")

	for state, values in pairs(MAS) do
		if (self.data[state] and self[state] and self[state].registered) then
			if (state == "custom" and self.data.customRange) then
				local start = tonumber(string.match(self.data.customRange, "^%d+"))
				local stop = tonumber(string.match(self.data.customRange, "%d+$"))

				if (start and stop) then
					self:ClearStates(handler, state)--, start, stop)
				end
			else
				self:ClearStates(handler, state)--, values.rangeStart, values.rangeStop)
			end
		end
	end

	self:RemoveObjectsFromBar(#self.buttons)

	self:SetScript("OnClick", function() end)
	self:SetScript("OnDragStart", function() end)
	self:SetScript("OnDragStop", function() end)
	self:SetScript("OnEnter", function() end)
	self:SetScript("OnLeave", function() end)
	self:SetScript("OnEvent", function() end)
	self:SetScript("OnKeyDown", function() end)
	self:SetScript("OnKeyUp", function() end)
	self:SetScript("OnShow", function() end)
	self:SetScript("OnHide", function() end)
	self:SetScript("OnUpdate", function() end)

	--self:UnregisterEvent("ACTIONBAR_SHOWGRID")
	--self:UnregisterEvent("ACTIONBAR_HIDEGRID")
	--self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

	self:SetWidth(36)
	self:SetHeight(36)
	self:ClearAllPoints()
	self:SetPoint("CENTER")
	self:Hide()

	table.remove(self.barDB, self:GetID()) --removes the bar from the database, along with all of its buttons
	table.remove(Neuron.BARIndex, self.index)

	if (NeuronBarEditor and NeuronBarEditor:IsVisible()) then
		Neuron.NeuronGUI:UpdateBarGUI()
	end
end


function BAR:AddObjectsToBar(num)

	num = tonumber(num)

	if (not num) then
		num = 1
	end

	for i=1,num do

		local object
		local id = #self.buttons + 1

		if (#self.buttons < self.objMax) then
			object = Neuron:CreateNewObject(self.class, id, self)
		end

	end

	self:LoadObjects()
	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:Update()
	self:UpdateObjectVisibility()

end


function BAR:RemoveObjectsFromBar(num)

	if (not num) then
		num = 1
	end


	for i=1,num do

		local id = #self.buttons --always the last button

		local object = self.buttons[id]

		if (object) then

			object:ClearAllPoints()


			table.remove(self.DB.buttons, id) --this is somewhat redundant if deleting a bar, but it doesn't hurt and is important for individual button deletions
			table.remove(self.buttons, id)


			if (object.binder) then
				Neuron.NeuronBinder:ClearBindings(object)
			end

			object:SetParent(TRASHCAN)


		end

		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()
		self:Update()
	end

end


function BAR:SetState(msg, gui, checked, query)
	if (msg) then
		local state = msg:match("^%S+")
		local command = msg:gsub(state, "");
		command = command:gsub("^%s+", "")

		if (not MAS[state]) then
			if (not gui) then
				Neuron:PrintStateList()
			else
				Neuron:Print("GUI option error")
			end

			return
		end

		if (gui) then
			if (checked) then
				self.data[state] = true
			else
				self.data[state] = false
			end
		else
			local toggle = self.data[state]

			if (toggle) then
				self.data[state] = false
			else
				self.data[state] = true
			end
		end

		if (state == "paged") then
			self.data.stance = false
			self.data.pet = false

			if (self.data.paged) then
				self:SetRemap_Paged()
			else
				self.data.remap = false
			end
		end

		if (state == "stance") then
			self.data.paged = false
			self.data.pet = false


			if (Neuron.class == "ROGUE" and self.data.stealth) then
				self.data.stealth = false
			end

			if (self.data.stance) then
				self:SetRemap_Stance()
			else
				self.data.remap = false
			end
		end

		if (state == "custom") then
			if (self.data.custom) then
				local count, newstates = 0, ""

				self.data.customNames = {}

				for states in gmatch(command, "[^;]+") do
					if string.find(states, "%[(.+)%]") then
						self.data.customRange = "1;"..count

						if (count == 0) then
							newstates = states.." homestate;"
							self.data.customNames["homestate"] = states
						else
							newstates = newstates..states.." custom"..count..";"
							self.data.customNames["custom"..count] = states
						end

						count = count + 1
					else
						Neuron:Print(states.." not formated properly and skipped")
					end
				end

				if (newstates ~= "" ) then
					self.data.custom = newstates
				else
					self.data.custom = false
					self.data.customNames = false
					self.data.customRange = false
				end

			else
				self.data.customNames = false
				self.data.customRange = false
			end

			--Clears any previous set cusom vis settings
			for states in gmatch(self.data.hidestates, "custom%d+") do
				self.data.hidestates = self.data.hidestates:gsub(states..":", "")
			end
			if not self.data.hidestates then Neuron:Print("OOPS")
			end
		end

		if (state == "pet") then
			self.data.paged = false
			self.data.stance = false
		end

		self.stateschanged = true
		self:Update()

	elseif (not gui) then
		wipe(statetable)

		for k,v in pairs(Neuron.STATEINDEX) do

			if (self.data[k]) then
				table.insert(statetable, k..": on")
			else
				table.insert(statetable, k..": off")
			end
		end

		table.sort(statetable)

		for k,v in ipairs(statetable) do
			Neuron:Print(v)
		end
	end

end


--I have no clue what or how any of this works. I took out the annoying print statements, but for now I'll just leave it. -Soyier

function BAR:SetVisibility(msg, gui, checked, query)
	if (msg) then
		wipe(statetable)
		local toggle, index, num = (" "):split(msg)
		toggle = toggle:lower()

		if (toggle and Neuron.STATEINDEX[toggle]) then
			if (index) then
				num = index:match("%d+")

				if (num) then
					local hidestate = Neuron.STATEINDEX[toggle]..num
					if (Neuron.STATES[hidestate]) or (toggle == "custom" and self.data.customNames) then
						if (self.data.hidestates:find(hidestate)) then
							self.data.hidestates = self.data.hidestates:gsub(hidestate..":", "")
						else
							self.data.hidestates = self.data.hidestates..hidestate..":"
						end
					else
						Neuron:Print(L["Invalid index"]); return
					end

				elseif (index == L["Show"]) then
					local hidestate = Neuron.STATEINDEX[toggle].."%d+"
					self.data.hidestates = self.data.hidestates:gsub(hidestate..":", "")
				elseif (index == L["Hide"]) then
					local hidestate = Neuron.STATEINDEX[toggle]

					for state in pairs(Neuron.STATES) do
						if (state:find("^"..hidestate) and not self.data.hidestates:find(state)) then
							self.data.hidestates = self.data.hidestates..state..":"
						end
					end
				end
			end


			local hidestates = self.data.hidestates
			local showhide

			local highindex = 0

			for state,desc in pairs(Neuron.STATES) do
				index = state:match("%d+$")

				if (index) then
					index = tonumber(index)

					if (index and state:find("^"..toggle)) then
						if (hidestates:find(state)) then
							statetable[index] = desc..":".."Hide:"..state
						else
							statetable[index] = desc..":".."Show:"..state
						end

						if (index > highindex) then
							highindex = index
						end
					end
				end
			end

			for i=1,highindex do
				if (not statetable[i]) then
					statetable[i] = "ignore"
				end
			end

			if (#statetable > 0) then
				--[[if (statetable[0]) then
					desc, showhide = (":"):split(statetable[0])
				end]]

				for k,v in ipairs(statetable) do
					if (v ~= "ignore") then
						desc, showhide = (":"):split(v)
					end
				end
			end


			self.vischanged = true
			self:Update()
		else
			Neuron:PrintStateList()
		end
	else
	end
end


function BAR:AutoHideBar(msg, gui, checked, query)
	if (query) then
		return self.data.autoHide
	end

	if (gui) then
		if (checked) then
			self.data.autoHide = true
		else
			self.data.autoHide = false
		end

	else
		local toggle = self.data.autoHide

		if (toggle) then
			self.data.autoHide = false
		else
			self.data.autoHide = true
		end
	end

	self:Update()
end


function BAR:ShowGridSet(msg, gui, checked, query)
	if (query) then
		return self.data.showGrid
	end

	if (gui) then
		if (checked) then
			self.data.showGrid = true
		else
			self.data.showGrid = false
		end
	else
		if (self.data.showGrid) then
			self.data.showGrid = false
		else
			self.data.showGrid = true
		end
	end

	self:UpdateObjectData()
	self:UpdateObjectVisibility()
	self:Update()
end


function BAR:spellGlowMod(msg, gui)
	if (msg:lower() == "default") then
		if (self.data.spellGlowDef) then
			self.data.spellGlowDef = false
		else
			self.data.spellGlowDef = true
			self.data.spellGlowAlt = false
		end

		if (not self.data.spellGlowDef and not self.data.spellGlowAlt) then
			self.data.spellGlowDef = true
		end

	elseif (msg:lower() == "alt") then
		if (self.data.spellGlowAlt) then
			self.data.spellGlowAlt = false
		else
			self.data.spellGlowAlt = true
			self.data.spellGlowDef = false
		end

		if (not self.data.spellGlowDef and not self.data.spellGlowAlt) then
			self.data.spellGlowDef = true
		end

	elseif (not gui) then
		Neuron:Print(L["Spellglow_Instructions"])
	end
end


function BAR:SpellGlowSet(msg, gui, checked, query)
	if (query) then
		if (msg == "default") then
			return self.data.spellGlowDef
		elseif(msg == "alt") then
			return self.data.spellGlowAlt
		else
			return self.data.spellGlow
		end
	end

	if (gui) then
		if (msg) then
			self:spellGlowMod(msg, gui)
		elseif (checked) then
			self.data.spellGlow = true
		else
			self.data.spellGlow = false
		end

	else
		if (msg) then
			self:spellGlowMod(msg, gui)
		elseif (self.data.spellGlow) then
			self.data.spellGlow = false
		else
			self.data.spellGlow = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:SnapToBar(msg, gui, checked, query)
	if (query) then
		return self.data.snapTo
	end

	if (gui) then
		if (checked) then
			self.data.snapTo = true
		else
			self.data.snapTo = false
		end
	else
		local toggle = self.data.snapTo

		if (toggle) then
			self.data.snapTo = false
			self.data.snapToPoint = false
			self.data.snapToFrame = false

			self:SetUserPlaced(true)
			self.data.point, self.data.x, self.data.y = self:GetPosition()
			self:SetPosition()
		else
			self.data.snapTo = true
		end
	end

	self:Update()
end

function BAR:UpClicksSet(msg, gui, checked, query)
	if (query) then
		return self.data.upClicks
	end

	if (gui) then
		if (checked) then
			self.data.upClicks = true
		else
			self.data.upClicks = false
		end

	else
		if (self.data.upClicks) then
			self.data.upClicks = false
		else
			self.data.upClicks = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:DownClicksSet(msg, gui, checked, query)
	if (query) then
		return self.data.downClicks
	end

	if (gui) then
		if (checked) then
			self.data.downClicks = true
		else
			self.data.downClicks = false
		end

	else
		if (self.data.downClicks) then
			self.data.downClicks = false
		else
			self.data.downClicks = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:MultiSpecSet(msg, gui, checked, query)
	if (query) then
		return self.data.multiSpec
	end

	if (gui) then
		if (checked) then
			self.data.multiSpec = true
		else
			self.data.multiSpec = false
		end
	else
		local toggle = self.data.multiSpec

		if (toggle) then
			self.data.multiSpec = false
		else
			self.data.multiSpec = true
		end
	end

	for i, object in ipairs(self.buttons) do

		if object then
			object:UpdateButtonSpec(self)
		end

	end

	self:Update()
end


function BAR:ConcealBar(msg, gui, checked, query)
	if (InCombatLockdown()) then
		return
	end

	if (query) then
		return self.data.conceal
	end

	if (gui) then
		if (checked) then
			self.data.conceal = true
		else
			self.data.conceal = false
		end

	else
		local toggle = self.data.conceal

		if (toggle) then
			self.data.conceal = false
		else
			self.data.conceal = true
		end
	end

	if (self.data.conceal) then
		if (self.selected) then
			self:SetBackdropColor(1,0,0,0.6)
		else
			self:SetBackdropColor(1,0,0,0.4)
		end
	else
		if (self.selected) then
			self:SetBackdropColor(0,0,1,0.5)
		else
			self:SetBackdropColor(0,0,0,0.4)
		end
	end

	self:Update()
end


function BAR:barLockMod(msg, gui)
	if (msg:lower() == "alt") then
		if (self.data.barLockAlt) then
			self.data.barLockAlt = false
		else
			self.data.barLockAlt = true
		end

	elseif (msg:lower() == "ctrl") then
		if (self.data.barLockCtrl) then
			self.data.barLockCtrl = false
		else
			self.data.barLockCtrl = true
		end

	elseif (msg:lower() == "shift") then
		if (self.data.barLockShift) then
			self.data.barLockShift = false
		else
			self.data.barLockShift = true
		end

	elseif (not gui) then
		Neuron:Print(L["Bar_Lock_Modifier_Instructions"])
	end
end

function BAR:LockSet(msg, gui, checked, query)
	if (query) then
		if (msg == "shift") then
			return self.data.barLockShift
		elseif(msg == "ctrl") then
			return self.data.barLockCtrl
		elseif(msg == "alt") then
			return self.data.barLockAlt
		else
			return self.data.barLock
		end
	end

	if (gui) then
		if (msg) then
			self:barLockMod(msg, gui)
		elseif (checked) then
			self.data.barLock = true
		else
			self.data.barLock = false
		end

	else
		if (msg) then
			self:barLockMod(msg, gui)
		else
			if (self.data.barLock) then
				self.data.barLock = false
			else
				self.data.barLock = true
			end
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:toolTipMod(msg, gui)
	if (msg:lower() == "enhanced") then
		if (self.data.tooltipsEnhanced) then
			self.data.tooltipsEnhanced = false
		else
			self.data.tooltipsEnhanced = true
		end

	elseif (msg:lower() == "combat") then
		if (self.data.tooltipsCombat) then
			self.data.tooltipsCombat = false
		else
			self.data.tooltipsCombat = true
		end

	elseif (not gui) then
		Neuron:Print(L["Tooltip_Instructions"])
	end
end


function BAR:ToolTipSet(msg, gui, checked, query)
	if (query) then
		if (msg == "enhanced") then
			return self.data.tooltipsEnhanced
		elseif(msg == "combat") then
			return self.data.tooltipsCombat
		else
			return self.data.tooltips
		end
	end

	if (gui) then
		if (msg) then
			self:toolTipMod(msg, gui)
		elseif (checked) then
			self.data.tooltips = true
		else
			self.data.tooltips = false
		end

	else
		if (msg) then
			self:toolTipMod(msg, gui)
		else
			if (self.data.tooltips) then
				self.data.tooltips = false
			else
				self.data.tooltips = true
			end
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:NameBar(name, gui)
	if (name) then
		self.data.name = name
		self:Update()
	end
end


function BAR:ShapeBar(shape, gui, query)
	if (query) then
		return barShapes[self.data.shape]
	end

	shape = tonumber(shape)

	if (shape and barShapes[shape]) then
		self.data.shape = shape
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()
		self:Update()
	elseif (not gui) then
		Neuron:Print(L["Bar_Shapes_List"])
	end
end


function BAR:ColumnsSet(command, gui, query, skipupdate)
	if (query) then
		if (self.data.columns) then
			return self.data.columns
		else
			return L["Off"]
		end
	end

	local columns = tonumber(command)

	if (columns and columns > 0) then
		self.data.columns = round(columns, 0)
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not columns or columns <= 0) then
		self.data.columns = false
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Bar_Column_Instructions"])
	end
end


function BAR:ArcStartSet(command, gui, query, skipupdate)
	if (query) then
		return self.data.arcStart
	end

	local start = tonumber(command)

	if (start and start>=0 and start<=359) then
		self.data.arcStart = start
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Bar_ArcStart_Instructions"])
	end
end


function BAR:ArcLengthSet(command, gui, query, skipupdate)
	if (query) then
		return self.data.arcLength
	end

	local length = tonumber(command)

	if (length and length>=0 and length<=359) then
		self.data.arcLength = length
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Bar_ArcLength_Instructions"])
	end
end


function BAR:PadHSet(command, gui, query, skipupdate)
	if (query) then
		return self.data.padH
	end

	local padh = tonumber(command)

	if (padh) then
		self.data.padH = round(padh, 1)
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Horozontal_Padding_Instructions"])
	end
end


function BAR:PadVSet(command, gui, query, skipupdate)
	if (query) then
		return self.data.padV
	end

	local padv = tonumber(command)

	if (padv) then
		self.data.padV = round(padv, 1)
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Vertical_Padding_Instructions"])
	end
end


function BAR:PadHVSet(command, gui, query, skipupdate)
	if (query) then
		return "---"
	end

	local padhv = tonumber(command)

	if (padhv) then
		self.data.padH = round(self.data.padH + padhv, 1)
		self.data.padV = round(self.data.padV + padhv, 1)

		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Horozontal_and_Vertical_Padding_Instructions"])
	end
end


function BAR:ScaleBar(scale, gui, query, skipupdate)
	if (query) then
		return self.data.scale
	end

	scale = tonumber(scale)

	if (scale) then
		self.data.scale = round(scale, 2)
		self:SetObjectLoc()
		self:SetPerimeter()
		self:SetSize()

		if (not skipupdate) then
			self:Update()
		end
	end
end


function BAR:StrataSet(command, gui, query)
	if (query) then
		return self.data.objectStrata
	end

	local strata = tonumber(command)

	if (strata and Neuron.STRATAS[strata] and Neuron.STRATAS[strata+1]) then
		self.data.barStrata = Neuron.STRATAS[strata+1]
		self.data.objectStrata = Neuron.STRATAS[strata]

		self:SetPosition()
		self:UpdateObjectData()
		self:Update()

	elseif (not gui) then
		Neuron:Print(L["Bar_Strata_List"])
	end
end


function BAR:AlphaSet(command, gui, query, skipupdate)
	if (query) then
		return self.data.alpha
	end

	local alpha = tonumber(command)

	if (alpha and alpha>=0 and alpha<=1) then
		self.data.alpha = round(alpha, 2)
		self.handler:SetAlpha(self.data.alpha)

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["Bar_Alpha_Instructions"])
	end
end

function BAR:AlphaUpSet(command, gui, query)
	if (query) then
		--temp fix
		if (self.data.alphaUp == "none" or self.data.alphaUp == 1) then
			self.data.alphaUp = alphaUps[1]
		end

		return self.data.alphaUp
	end

	local alphaUp = tonumber(command)

	if (alphaUp and alphaUps[alphaUp]) then
		self.data.alphaUp = alphaUps[alphaUp]
		self:Update()
	elseif (not gui) then
		local text = ""

		for k,v in ipairs(alphaUps) do
			text = text.."\n"..k.."="..v
			Neuron:Print(text)
		end
	end
end


function BAR:AlphaUpSpeedSet(command, gui, query, skipupdate)
	if (query) then
		return self.data.fadeSpeed
	end

	local speed = tonumber(command)

	if (speed) then
		self.data.fadeSpeed = round(speed, 2)

		if (self.data.fadeSpeed > 1) then
			self.data.fadeSpeed = 1
		end

		if (self.data.fadeSpeed < 0.01) then
			self.data.fadeSpeed = 0.01
		end

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
	end
end

function BAR:XAxisSet(command, gui, query, skipupdate)
	if (query) then
		return self.data.x
	end

	local x = tonumber(command)

	if (x) then
		self.data.x = round(x, 2)
		self.data.snapTo = false
		self.data.snapToPoint = false
		self.data.snapToFrame = false
		self:SetPosition()
		self.data.point, self.data.x, self.data.y = self:GetPosition()

		if (not gui) then
			self.message:Show()
			self.messagebg:Show()
		end

		if (not skipupdate) then
			self:Update()
		end

	elseif (not gui) then
		Neuron:Print(L["X_Position_Instructions"])
	end
end


function BAR:YAxisSet(command, gui, query, skipupdate)
	if (query) then
		return self.data.y
	end

	local y = tonumber(command)

	if (y) then
		self.data.y = round(y, 2)
		self.data.snapTo = false
		self.data.snapToPoint = false
		self.data.snapToFrame = false
		self:SetPosition()
		self.data.point, self.data.x, self.data.y = self:GetPosition()

		if (not gui) then
			self.message:Show()
			self.messagebg:Show()
		end

		if (not skipupdate) then
			self:Update()
		end
	elseif (not gui) then
		Neuron:Print(L["Y_Position_Instructions"])
	end
end


function BAR:BindTextSet(msg, gui, checked, query)
	if (query) then
		return self.data.bindText, self.data.bindColor
	end

	if (gui) then
		if (checked) then
			self.data.bindText = true
		else
			self.data.bindText = false
		end

	else
		if (self.data.bindText) then
			self.data.bindText = false
		else
			self.data.bindText = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:MacroTextSet(msg, gui, checked, query)
	if (query) then
		return self.data.macroText, self.data.macroColor
	end

	if (gui) then
		if (checked) then
			self.data.macroText = true
		else
			self.data.macroText = false
		end

	else
		if (self.data.macroText) then
			self.data.macroText = false
		else
			self.data.macroText = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:CountTextSet(msg, gui, checked, query)
	if (query) then
		return self.data.countText, self.data.countColor
	end

	if (gui) then
		if (checked) then
			self.data.countText = true
		else
			self.data.countText = false
		end

	else
		if (self.data.countText) then
			self.data.countText = false
		else
			self.data.countText = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:RangeIndSet(msg, gui, checked, query)
	if (query) then
		return self.data.rangeInd, self.data.rangecolor
	end

	if (gui) then
		if (checked) then
			self.data.rangeInd = true
		else
			self.data.rangeInd = false
		end

	else
		if (self.data.rangeInd) then
			self.data.rangeInd = false
		else
			self.data.rangeInd = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:CDTextSet(msg, gui, checked, query)
	if (query) then
		return self.data.cdText, self.data.cdcolor1, self.data.cdcolor2
	end

	if (gui) then
		if (checked) then
			self.data.cdText = true
		else
			self.data.cdText = false
		end

	else
		if (self.data.cdText) then
			self.data.cdText = false
		else
			self.data.cdText = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:CDAlphaSet(msg, gui, checked, query)
	if (query) then
		return self.data.cdAlpha
	end

	if (gui) then
		if (checked) then
			self.data.cdAlpha = true
		else
			self.data.cdAlpha = false
		end

	else
		if (self.data.cdAlpha) then
			self.data.cdAlpha = false
		else
			self.data.cdAlpha = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:AuraTextSet(msg, gui, checked, query)
	if (query) then
		return self.data.auraText, self.data.auracolor1, self.data.auracolor2
	end

	if (gui) then
		if (checked) then
			self.data.auraText = true
		else
			self.data.auraText = false
		end

	else
		if (self.data.auraText) then
			self.data.auraText = false
		else
			self.data.auraText = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:AuraIndSet(msg, gui, checked, query)
	if (query) then
		return self.data.auraInd, self.data.buffcolor, self.data.debuffcolor
	end

	if (gui) then
		if (checked) then
			self.data.auraInd = true
		else
			self.data.auraInd = false
		end

	else
		if (self.data.auraInd) then
			self.data.auraInd = false
		else
			self.data.auraInd = true
		end
	end

	self:UpdateObjectData()
	self:Update()
end


function BAR:Load()
	self:SetPosition()
	self:LoadObjects(true)
	self:SetObjectLoc()
	self:SetPerimeter()
	self:SetSize()
	self:EnableKeyboard(false)
	self:Update()
end




--- Sets a Target Casting state for a bar
-- @param value(string): Database refrence value to be set
-- @param gui(Bool): Toggle to determine if call was from the GUI
-- @param checked(Bool) : Used when using a GUI checkbox - It is the box's current state
-- @param query: N/A
function BAR:SetCastingTarget(value, gui, checked, query)
	if (value) then
		if (gui) then

			if (checked) then
				self.data[value] = true
			else
				self.data[value] = false
			end

		else

			local toggle = self.data[value]

			if (toggle) then
				self.data[value] = false
			else
				self.data[value] = true
			end
		end

		Neuron:UpdateMacroCastTargets()
		self:Update()
	end
end