--Neuron, a World of Warcraft® user interface addon.

local NEURON = Neuron
local PEW

NEURON.OBJEDITOR = setmetatable({}, { __index = CreateFrame("Button") })

NEURON.Editors = {}

local BUTTON = NEURON.BUTTON
local OBJEDITOR = NEURON.OBJEDITOR

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local BARIndex, BTNIndex, EDITIndex = NEURON.BARIndex, NEURON.BTNIndex, NEURON.EDITIndex

local sIndex = NEURON.sIndex
local cIndex = NEURON.cIndex

function OBJEDITOR:OnShow()

	local object = self.object

	if (object) then

		if (object.bar) then
			self:SetFrameLevel(object.bar:GetFrameLevel()+1)
		end
	end
end

function OBJEDITOR:OnHide()


end

function OBJEDITOR:OnEnter()

	self.select:Show()

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	GameTooltip:Show()

end

function OBJEDITOR:OnLeave()

	if (self.object ~= NEURON.CurrentObject) then
		self.select:Hide()
	end

	GameTooltip:Hide()

end

function OBJEDITOR:OnClick(button)

	local newObj, newEditor = NEURON:ChangeObject(self.object)

	if (button == "RightButton") then

		if (not IsAddOnLoaded("Neuron-GUI")) then
			LoadAddOn("Neuron-GUI")
		end

		if (NeuronObjectEditor) then
			if (not newObj and NeuronObjectEditor:IsVisible()) then
				NeuronObjectEditor:Hide()
			elseif (newObj and newEditor) then
				NEURON:ObjectEditor_OnShow(NeuronObjectEditor); NeuronObjectEditor:Show()
			else
				NeuronObjectEditor:Show()
			end
		end

	elseif (newObj and newEditor and NeuronObjectEditor:IsVisible()) then
		NEURON:ObjectEditor_OnShow(NeuronObjectEditor); NeuronObjectEditor:Show()
	end

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		NEURON:UpdateObjectGUI()
	end
end

function OBJEDITOR:ACTIONBAR_SHOWGRID()

	if (not InCombatLockdown() and self:IsVisible()) then
		self:Hide(); self.showgrid = true
	end

end

function OBJEDITOR:ACTIONBAR_HIDEGRID()

	if (not InCombatLockdown() and self.showgrid) then
		self:Show(); self.showgrid = nil
	end

end

function OBJEDITOR:OnEvent(event, ...)

	if (self[event]) then
		self[event](self, ...)
	end

end

local OBJEDITOR_MT = { __index = OBJEDITOR }

function BUTTON:CreateEditFrame(index)

	local EDITOR = CreateFrame("Button", self:GetName().."EditFrame", self, "NeuronEditFrameTemplate")

	setmetatable(EDITOR, OBJEDITOR_MT)

	EDITOR:EnableMouseWheel(true)
	EDITOR:RegisterForClicks("AnyDown")
	EDITOR:SetAllPoints(self)
	EDITOR:SetScript("OnShow", OBJEDITOR.OnShow)
	EDITOR:SetScript("OnHide", OBJEDITOR.OnHide)
	EDITOR:SetScript("OnEnter", OBJEDITOR.OnEnter)
	EDITOR:SetScript("OnLeave", OBJEDITOR.OnLeave)
	EDITOR:SetScript("OnClick", OBJEDITOR.OnClick)
	EDITOR:SetScript("OnEvent", OBJEDITOR.OnEvent)
	EDITOR:RegisterEvent("ACTIONBAR_SHOWGRID")
	EDITOR:RegisterEvent("ACTIONBAR_HIDEGRID")

	EDITOR.type:SetText(L.EDITFRAME_EDIT)
	EDITOR.object = self
	EDITOR.editType = "button"

	self.OBJEDITOR = EDITOR

	EDITIndex["BUTTON"..index] = EDITOR

	EDITOR:Hide()

end

function NEURON:ChangeObject(object)

	local newObj, newEditor = false, false

	if (PEW) then

		if (object and object ~= NEURON.CurrentObject) then

			if (NEURON.CurrentObject and NEURON.CurrentObject.OBJEDITOR.editType ~= object.OBJEDITOR.editType) then
				newEditor = true
			end

			if (NEURON.CurrentObject and NEURON.CurrentObject.bar ~= object.bar) then

				local bar = NEURON.CurrentObject.bar

				if (bar.handler:GetAttribute("assertstate")) then
					bar.handler:SetAttribute("state-"..bar.handler:GetAttribute("assertstate"), bar.handler:GetAttribute("activestate") or "homestate")
				end

				object.bar.handler:SetAttribute("fauxstate", bar.handler:GetAttribute("activestate"))

			end

			NEURON.CurrentObject = object

			object.OBJEDITOR.select:Show()

			object.selected = true
			object.action = nil

			newObj = true
		end

		if (not object) then
			NEURON.CurrentObject = nil
		end

		for k,v in pairs(EDITIndex) do
			if (not object or v ~= object.OBJEDITOR) then
				v.select:Hide()
			end
		end
	end

	return newObj, newEditor
end

function NEURON:ToggleEditFrames(show, hide)

	if (NEURON.EditFrameShown or hide) then

		NEURON.EditFrameShown = false

		for index, OBJEDITOR in pairs(EDITIndex) do
			OBJEDITOR:Hide(); OBJEDITOR.object.editmode = NEURON.EditFrameShown
			OBJEDITOR:SetFrameStrata("LOW")
		end

		for _,bar in pairs(BARIndex) do
			bar:UpdateObjectGrid(NEURON.EditFrameShown)
			if (bar.handler:GetAttribute("assertstate")) then
				bar.handler:SetAttribute("state-"..bar.handler:GetAttribute("assertstate"), bar.handler:GetAttribute("activestate") or "homestate")
			end
		end

		NEURON:ChangeObject()

		if (IsAddOnLoaded("Neuron-GUI")) then
			NeuronObjectEditor:Hide()
		end

	else

		--NEURON:ToggleMainMenu(nil, true)
		NEURON:ToggleBars(nil, true)
		NEURON:ToggleBindings(nil, true)

		NEURON.EditFrameShown = true

		for index, OBJEDITOR in pairs(EDITIndex) do
			OBJEDITOR:Show(); OBJEDITOR.object.editmode = NEURON.EditFrameShown

			if (OBJEDITOR.object.bar) then
				OBJEDITOR:SetFrameStrata(OBJEDITOR.object.bar:GetFrameStrata())
				OBJEDITOR:SetFrameLevel(OBJEDITOR.object.bar:GetFrameLevel()+4)
			end
		end

		for _,bar in pairs(BARIndex) do
			bar:UpdateObjectGrid(NEURON.EditFrameShown)
		end
	end
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Neuron") then

		NEURON.Editors.ACTIONBUTTON = { nil, 550, 350, nil }

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")