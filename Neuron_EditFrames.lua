--Neuron, a World of Warcraft® user interface addon.

local NEURON = Neuron
local PEW

NEURON.NeuronEditor = NEURON:NewModule("Editor", "AceEvent-3.0", "AceHook-3.0")
local NeuronEditor = NEURON.NeuronEditor

NEURON.OBJEDITOR = setmetatable({}, { __index = CreateFrame("Button") })
local OBJEDITOR = NEURON.OBJEDITOR

NEURON.Editors = {}

local BUTTON = NEURON.BUTTON
local BARIndex = NEURON.BARIndex
local BTNIndex = NEURON.BTNIndex
local EDITIndex = NEURON.EDITIndex

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")




-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronEditor:OnInitialize()

	NEURON.Editors.ACTIONBUTTON = { nil, 550, 350, nil }

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronEditor:OnEnable()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronEditor:OnDisable()

end


------------------------------------------------------------------------------
function NeuronEditor:PLAYER_ENTERING_WORLD()
	PEW = true
end

-------------------------------------------------------------------------------
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

	EDITOR.type:SetText(L["Edit"])
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

		--[[if (IsAddOnLoaded("Neuron-GUI")) then
			NeuronObjectEditor:Hide()
		end]]

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