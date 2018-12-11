--Neuron, a World of Warcraft® user interface addon.


local DB

Neuron.NeuronBar = Neuron:NewModule("Bar", "AceEvent-3.0", "AceHook-3.0")
local NeuronBar = Neuron.NeuronBar

local BARIndex = Neuron.BARIndex
local BARNameIndex = Neuron.BARNameIndex
local BTNIndex = Neuron.BTNIndex


local defaultBarOptions = {
	[1] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 55,
		showGrid = true,
		multiSpec = true,
		vehicle = true,
		possess = true,
		override = true,
	},

	[2] = {
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 100,
		showGrid = true,
	},
}


-----------------------

-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronBar:OnInitialize()

	DB = Neuron.db.profile

	if Neuron.NeuronZoneAbilityBar then
		NeuronBar.HideZoneAbilityBorder = Neuron.NeuronZoneAbilityBar.HideZoneAbilityBorder --this is so the slash function has access to this function
	end
	Neuron.CreateNewBar = NeuronBar.CreateNewBar --temp just so slash functions still work

	NeuronBar:CreateBarsAndButtons()
end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronBar:OnEnable()


end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronBar:OnDisable()

end


------------------------------------------------------------------------------




------------------------------------------------------------
--------------------Intermediate Functions------------------
------------------------------------------------------------

function NeuronBar:CreateBarsAndButtons()

	---TODO: clean up the onload part of this addon. This way of creating all the objects is terribly clunky
	if (DB.firstRun) then
		local offset = 0

		for id, defaults in ipairs(defaultBarOptions) do

			local bar = NeuronBar:CreateNewBar("bar", id, true) --this calls the bar constructor

			for	k,v in pairs(defaults) do
				bar.data[k] = v
			end

			local object

			for i=1+offset, 12+offset do
				object = Neuron:CreateNewObject("bar", i, true) --this calls the object (button) constructor
				bar:AddObjectToList(object)
			end

			offset = offset + 12
		end

	else
		for id,data in pairs(DB.bars) do
			if (data ~= nil) then
				NeuronBar:CreateNewBar("bar", id) --this calls the bar constructor
			end

		end

		for id,data in pairs(DB.buttons) do
			if (data ~= nil) then
				Neuron:CreateNewObject("bar", id) --this calls the object (button) constructor
			end
		end
	end

end



function NeuronBar:CreateNewBar(class, id, firstRun)
	if (class and Neuron.RegisteredBarData[class]) then
		local index = 1

		for _ in ipairs(BARIndex) do
			index = index + 1
		end

		local bar, newBar = NeuronBar:CreateBar(index, class, id)

		if (firstRun) then
			bar:SetDefaults(bar.Def)
		end

		if (newBar) then
			bar:Load()
			bar:ChangeBar()

			---------------------------------
			if (class == "extrabar") then --this is a hack to get around an issue where the extrabar wasn't autohiding due to bar visibility states. There most likely a way better way to do this in the future. FIX THIS!
				bar.data.hidestates = ":extrabar0:"
				bar.vischanged = true
				bar:Update()
			end
			if (class == "pet") then --this is a hack to get around an issue where the extrabar wasn't autohiding due to bar visibility states. There most likely a way better way to do this in the future. FIX THIS!
				bar.data.hidestates = ":pet0:"
				bar.vischanged = true
				bar:Update()
			end
			-----------------------------------
		end

		return bar
	else
		Neuron.PrintBarTypes()
	end
end

function NeuronBar:CreateBar(index, class, id)
	local data = Neuron.RegisteredBarData[class]
	local newBar

	if (data) then
		if (not id) then
			id = 1

			for _ in ipairs(data.barDB) do
				id = id + 1
			end

			newBar = true
		end

		local bar

		if (_G["Neuron"..data.barType..id]) then
			bar = _G["Neuron"..data.barType..id]
		else
			---this is the create of our bar object frame
			bar = Neuron.BAR:new("Neuron"..data.barType..id)

		end

		for key,value in pairs(data) do
			bar[key] = value
		end

		bar.index = index
		bar.class = class
		bar.stateschanged = true
		bar.vischanged =true
		bar.elapsed = 0
		bar.click = nil
		bar.dragged = false
		bar.selected = false
		bar.toggleframe = bar
		bar.microAdjust = false
		bar.vis = {}
		bar.text:Hide()
		bar.message:Hide()
		bar.messagebg:Hide()

		bar:SetID(id)
		bar:SetWidth(375)
		bar:SetHeight(40)
		bar:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		                 edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		                 tile = true, tileSize = 16, edgeSize = 12,
		                 insets = {left = 4, right = 4, top = 4, bottom = 4}})
		bar:SetBackdropColor(0,0,0,0.4)
		bar:SetBackdropBorderColor(0,0,0,0)
		bar:SetFrameLevel(2)
		bar:RegisterForClicks("AnyDown", "AnyUp")
		bar:RegisterForDrag("LeftButton")
		bar:SetMovable(true)
		bar:EnableKeyboard(false)
		bar:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

		bar:SetScript("OnClick", function(self, ...) self:OnClick(...) end)
		bar:SetScript("OnDragStart", function(self, ...) self:OnDragStart(...) end)
		bar:SetScript("OnDragStop", function(self, ...) self:OnDragStop(...) end)
		bar:SetScript("OnEnter", function(self, ...) self:OnEnter(...) end)
		bar:SetScript("OnLeave", function(self, ...) self:OnLeave(...) end)
		bar:SetScript("OnEvent", function(self, event, ...) self:OnEvent(event, ...) end)
		bar:SetScript("OnKeyDown", function(self, key, onupdate) self:OnKeyDown(key, onupdate) end)
		bar:SetScript("OnKeyUp", function(self, key) self:OnKeyUp(key) end)
		bar:SetScript("OnShow", function(self) self:OnShow() end)
		bar:SetScript("OnHide", function(self) self:OnHide() end)
		bar:SetScript("OnUpdate", function(self, elapsed) self:OnUpdate(elapsed) end)

		--bar:RegisterEvent("ACTIONBAR_SHOWGRID")
		--bar:RegisterEvent("ACTIONBAR_HIDEGRID")
		--bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")


		bar:CreateDriver()
		bar:CreateHandler()
		bar:CreateWatcher()

		bar:LoadData()

		if (not newBar) then
			bar:Hide()
		end

		BARIndex[index] = bar

		BARNameIndex[bar:GetName()] = bar

		return bar, newBar
	end
end
