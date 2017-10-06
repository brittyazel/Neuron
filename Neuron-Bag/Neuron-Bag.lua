--Neuron Bag Bar, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local NEURON = Neuron
local GDB, CDB, PEW

NEURON.BAGIndex = {}

local BAGIndex = NEURON.BAGIndex

local bagbarsGDB, bagbarsCDB, bagbtnsGDB, bagbtnsCDB

local ANCHOR = setmetatable({}, { __index = CreateFrame("Frame") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local	SKIN = LibStub("Masque", true)

NeuronBagGDB = {
	bagbars = {},
	bagbtns = {},
	freeSlots = 16,
	firstRun = true,
}

NeuronBagCDB = {
	bagbars = {},
	bagbtns = {},
}

local gDef = {

	padH = -1,
	scale = 1.25,
	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOMRIGHT",
	x = -110,
	y = 77,
}

local bagElements = {}

local format = string.format

local GetParentKeys = NEURON.GetParentKeys

local defGDB, defCDB = CopyTable(NeuronBagGDB), CopyTable(NeuronBagCDB)

local configData = {

	stored = false,
}

local function toggleBag(id)

	if (not InCombatLockdown() and IsOptionFrameOpen()) then

		local size = GetContainerNumSlots(id)
		if (size > 0 or id == KEYRING_CONTAINER) then
			local containerShowing;
			for i=1, NUM_CONTAINER_FRAMES, 1 do
				local frame = _G["ContainerFrame"..i]
				if (frame:IsShown() and frame:GetID() == id) then
					containerShowing = i
					frame:Hide()
				end
			end
			if (not containerShowing) then
				ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), size, id)
			end
		end
	end
end

local function toggleBackpack()

	if (not InCombatLockdown() and IsOptionFrameOpen()) then

		if (IsBagOpen(0)) then
			for i=1, NUM_CONTAINER_FRAMES, 1 do
				local frame = _G["ContainerFrame"..i]
				if (frame:IsShown()) then
					frame:Hide()
				end
				-- Hide the token bar if closing the backpack
				if (BackpackTokenFrame) then
					BackpackTokenFrame:Hide()
				end
			end
		else
			ToggleBag(0)
			-- If there are tokens watched then show the bar
			if (ManageBackpackTokenFrame) then
				BackpackTokenFrame_Update()
				ManageBackpackTokenFrame()
			end
		end
	end
end

local function containerFrame_OnShow(self)

	local index = self:GetID() + 1

	if (bagElements[index]) then
		bagElements[index]:SetChecked(1)
	end
end

local function containerFrame_OnHide(self)

	local index = abs(self:GetID()-5)

	if (bagElements[index]) then
		bagElements[index]:SetChecked(0)
	end
end

local function updateFreeSlots(self)

	local totalSlots, totalFree  = 0, 0
	local freeSlots, bagFamily

	for i=BACKPACK_CONTAINER, NUM_BAG_SLOTS do

		freeSlots, bagFamily = GetContainerNumFreeSlots(i)

		if (bagFamily == 0) then

			totalSlots = totalSlots + GetContainerNumSlots(i)
			totalFree = totalFree + freeSlots
		end
	end

	local rgbValue, r, g = math.floor((totalFree/GDB.freeSlots)*100)

	if (rgbValue > 49) then
		r=(1-(rgbValue/100))+(1-(rgbValue/100))
		g=(rgbValue/100)+((1-(rgbValue/100))/2)
	else
		r=1; g=(rgbValue/100)*1.5
	end

	self.freeSlots = totalFree

	self.count:SetText(format("%s", totalFree))
	self.count:SetTextColor(r, g, 0)
end

function NEURON.NeuronBackpackButton_OnLoad(self)

	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CVAR_UPDATE")
	self:RegisterEvent("BAG_UPDATE")

	self.icon:SetTexture("Interface\\Buttons\\Button-Backpack-Up")
	--self.BlizzBP = MainMenuBarBackpackButton

	self.count = _G[self:GetName().."Count2"]
	self.icon = _G[self:GetName().."IconTexture"]
end

function NEURON.NeuronBackpackButton_OnReceiveDrag(self, button)

	if (not PutItemInBackpack()) then
		ToggleBackpack()
	end

	local isVisible

	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i]

		if (frame:GetID()==0 and frame:IsShown()) then
			isVisible = 1; break
		end
	end

	self:SetChecked(isVisible)
end

function NEURON.NeuronBackpackButton_OnEnter(self)

	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0)

	local keyBinding = GetBindingKey("TOGGLEBACKPACK")

	if (keyBinding) then
		GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..keyBinding..")"..FONT_COLOR_CODE_CLOSE)
	end

	GameTooltip:AddLine(format(NUM_FREE_SLOTS, (self.freeSlots or 0)))

	GameTooltip:Show()
end

function NEURON.NeuronBackpackButton_OnLeave(self)
	GameTooltip:Hide()
end

function NEURON.NeuronBackpackButton_OnEvent(self, event, ...)

	if (event == "BAG_UPDATE") then

		if (... >= BACKPACK_CONTAINER and ... <= NUM_BAG_SLOTS) then
			updateFreeSlots(self)
		end

	elseif (event == "PLAYER_ENTERING_WORLD") then

		updateFreeSlots(self)

		self.icon:SetTexture([[Interface\Buttons\Button-Backpack-Up]])

	elseif (event == "CVAR_UPDATE") then

	end
end

function ANCHOR:SetSkinned()

	if (SKIN) then

		local bar = self.bar

		if (bar) then

			local btnData = { Icon = self.element.icon }

			SKIN:Group("Neuron", bar.gdata.name):AddButton(self.element, btnData)

		end
	end
end

function ANCHOR:SetData(bar)

	if (bar) then

		self.bar = bar

		self:SetFrameStrata(bar.gdata.objectStrata)
		self:SetScale(bar.gdata.scale)

		if (self.element == NeuronBackpackButton) then

			if (bar.objCount == 1) then
				self.element:SetScript("OnClick", function() if (ContainerFrame1:IsVisible()) then CloseAllBags() else OpenAllBags() end end)
			else
				self.element:SetScript("OnClick", function() if (IsModifiedClick()) then if (ContainerFrame1:IsVisible()) then CloseAllBags() else OpenAllBags() end else ToggleBackpack() end end)
			end
		end
	end

	self:SetFrameLevel(4)
end

function ANCHOR:SaveData()

	-- empty

end

function ANCHOR:LoadData(spec, state)

	local id = self.id

	self.GDB = bagbtnsGDB
	self.CDB = bagbtnsCDB

	if (self.GDB and self.CDB) then

		if (not self.GDB[id]) then
			self.GDB[id] = {}
		end

		if (not self.GDB[id].config) then
			self.GDB[id].config = CopyTable(configData)
		end

		if (not self.CDB[id]) then
			self.CDB[id] = {}
		end

		if (not self.CDB[id].data) then
			self.CDB[id].data = {}
		end

		self.config = self.GDB [id].config

		self.data = self.CDB[id].data
	end
end

function ANCHOR:SetGrid(show, hide)

	--empty

end

function ANCHOR:SetAux()

	-- empty

end

function ANCHOR:LoadAux()

	-- empty

end

function ANCHOR:SetDefaults()

	-- empty

end

function ANCHOR:GetDefaults()

	--empty

end

function ANCHOR:SetType(save)

	if (bagElements[self.id]) then

		self:SetWidth(bagElements[self.id]:GetWidth()+3)
		self:SetHeight(bagElements[self.id]:GetHeight()+3)
		self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

		self.element = bagElements[self.id]

		local objects = NEURON:GetParentKeys(self.element)

		for k,v in pairs(objects) do
			local name = v:gsub(self.element:GetName(), "")
			self[name:lower()] = _G[v]
		end

		self.element:ClearAllPoints()
		self.element:SetParent(self)
		self.element:Show()
		self.element:SetPoint("CENTER", self, "CENTER")
		self.element:SetScale(1)

		if (self.element == NeuronBackpackButton) then
			self.element:SetScript("OnClick", function() if (IsModifiedClick()) then if (ContainerFrame1:IsVisible()) then CloseAllBags() else OpenAllBags() end else ToggleBackpack() end end)
		else
			self.element:SetScript("OnClick", BagSlotButton_OnClick)
		end

		self:SetSkinned()
	end
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Neuron-Bag") then

		bagElements[1] = NeuronBackpackButton
		bagElements[2] = Neuron___Bag0Slot
		bagElements[3] = Neuron___Bag1Slot
		bagElements[4] = Neuron___Bag2Slot
		bagElements[5] = Neuron___Bag3Slot

		for k,v in pairs(bagElements) do
			v:SetWidth(32)
			v:SetHeight(32)
			v:GetNormalTexture():SetWidth(55)
			v:GetNormalTexture():SetHeight(55)
			v:GetNormalTexture():SetPoint("CENTER",0,0)
			_G[v:GetName().."IconTexture"]:ClearAllPoints()
			_G[v:GetName().."IconTexture"]:SetPoint("TOPLEFT", -1, 1)
			_G[v:GetName().."IconTexture"]:SetPoint("BOTTOMRIGHT")
		end

		hooksecurefunc("ContainerFrame_OnShow", containerFrame_OnShow)
		hooksecurefunc("ContainerFrame_OnHide", containerFrame_OnHide)
		hooksecurefunc("ToggleBag", toggleBag)
		hooksecurefunc("ToggleBackpack", toggleBackpack)

		for i=1,13 do
			local frame = _G["ContainerFrame"..i]
			frame:HookScript("OnShow", containerFrame_OnShow)
			frame:HookScript("OnHide", containerFrame_OnHide)
		end

		GDB = NeuronBagGDB; CDB = NeuronBagCDB

		for k,v in pairs(defGDB) do
			if (GDB[k] == nil) then
				GDB[k] = v
			end
		end

		for k,v in pairs(defCDB) do
			if (CDB[k] == nil) then
				CDB[k] = v
			end
		end

		bagbarsGDB = GDB.bagbars
		bagbarsCDB = CDB.bagbars

		bagbtnsGDB = GDB.bagbtns
		bagbtnsCDB = CDB.bagbtns

		NEURON:RegisterBarClass("bag", "Bag Bar", "Bag Button", bagbarsGDB, bagbarsCDB, BAGIndex, bagbtnsGDB, "CheckButton", "NeuronAnchorButtonTemplate", { __index = ANCHOR }, #bagElements, true, STORAGE, gDef, nil, true)

		NEURON:RegisterGUIOptions("bag", { AUTOHIDE = true, SHOWGRID = false, SPELLGLOW = false, SNAPTO = true, DUALSPEC = false, HIDDEN = true, LOCKBAR = false, TOOLTIPS = true }, false, false)

		if (GDB.firstRun) then

			local bar, object = NEURON:CreateNewBar("bag", 1, true)

			for i=1,#bagElements do
				object = NEURON:CreateNewObject("bag", i)
				bar:AddObjectToList(object)
			end

			GDB.firstRun = false

		else

			for id,data in pairs(bagbarsGDB) do
				if (data ~= nil) then
					NEURON:CreateNewBar("bag", id)
				end
			end

			for id,data in pairs(bagbtnsGDB) do
				if (data ~= nil) then
					NEURON:CreateNewObject("bag", id)
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
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")