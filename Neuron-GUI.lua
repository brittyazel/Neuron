--Neuron GUI, a World of Warcraft® user interface addon.

local addonName = ...

local NEURON = Neuron


local GDB, CDB, NMM, NBE, NOE, NBTNE, MAS

local width, height = 1000, 600

local barNames = {}

local numShown = 15


NEURON.NeuronGUI = Neuron:NewModule("GUI", "AceEvent-3.0", "AceHook-3.0")
local NeuronGUI = NEURON.NeuronGUI
local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local NeuronAceGUI = LibStub("AceGUI-3.0")

local GUIData = NEURON.RegisteredGUIData

local ICONS = NEURON.iIndex

local sIndex = NEURON.sIndex  --Spell index
local cIndex = NEURON.cIndex  --Battle pet & Mount index
local iIndex = NEURON.iIndex  --Items Inde -- x
local ItemCache = NeuronItemCache

local EDITIndex, OBJEDITOR = NEURON.EDITIndex, NEURON.OBJEDITOR

local barOpt = { chk = {}, adj = {}, pri = {}, sec = {}, swatch = {}, vis = {} }

local popupData = {}

local chkOptions = {
	[1] = { "AUTOHIDE", L["AutoHide"], 1, "AutoHideBar" },
	[2] = { "SHOWGRID", L["Show Grid"], 1, "ShowGridSet" },
	[3] = { "SNAPTO", L["SnapTo"], 1, "SnapToBar" },
	[4] = { "UPCLICKS", L["Up Clicks"], 1, "UpClicksSet" },
	[5] = { "DOWNCLICKS", L["Down Clicks"], 1, "DownClicksSet" },
	[6] = { "MULTISPEC", L["Multi Spec"], 1, "MultiSpecSet" },
	[7] = { "HIDDEN", L["Hidden"], 1, "ConcealBar" },
	[8] = { "SPELLGLOW", L["Spell Alerts"], 1, "SpellGlowSet" },
	[9] = { "SPELLGLOW", L["Default Alert"], 1, "SpellGlowSet", "default" },
	[10] = { "SPELLGLOW", L["Subdued Alert"], 1, "SpellGlowSet", "alt" },
	[11] = { "LOCKBAR", L["Lock Actions"], 1, "LockSet" },
	[12] = { "LOCKBAR", L["Unlock on SHIFT"], 0.9, "LockSet", "shift" },
	[13] = { "LOCKBAR", L["Unlock on CTRL"], 0.9, "LockSet", "ctrl" },
	[14] = { "LOCKBAR", L["Unlock on ALT"], 0.9, "LockSet", "alt" },
	[15] = { "TOOLTIPS", L["Enable Tooltips"], 1, "ToolTipSet" },
	[16] = { "TOOLTIPS", L["Enhanced"], 0.9, "ToolTipSet", "enhanced" },
	[17] = { "TOOLTIPS", L["Hide in Combat"], 0.9, "ToolTipSet", "combat" },
	[18] = { "ZONEABILITY", L["Show Bar Border"], 1, "HideZoneAbilityBorder"},
}

local adjOptions = {
	[1] = { "SCALE", L["Scale"], 1, "ScaleBar", 0.01, 0.1, 4 },
	[2] = { "SHAPE", L["Shape"], 2, "ShapeBar", nil, nil, nil, NEURON.BarShapes },
	[3] = { "COLUMNS", L["Columns"], 1, "ColumnsSet", 1 , 0},
	[4] = { "ARCSTART", L["Arc Start"], 1, "ArcStartSet", 1, 0, 359 },
	[5] = { "ARCLENGTH", L["Arc Length"], 1, "ArcLengthSet", 1, 0, 359 },
	[6] = { "HPAD",L["Horiz Padding"], 1, "PadHSet", 0.1 },
	[7] = { "VPAD", L["Vert Padding"], 1, "PadVSet", 0.1 },
	[8] = { "HVPAD", L["H+V Padding"], 1, "PadHVSet", 0.1 },
	[9] = { "STRATA", L["Strata"], 2, "StrataSet", nil, nil, nil, NEURON.Stratas },
	[10] = { "ALPHA", L["Alpha"], 1, "AlphaSet", 0.01, 0, 1 },
	[11] = { "ALPHAUP", L["AlphaUp"], 2, "AlphaUpSet", nil, nil, nil, NEURON.AlphaUps },
	[12] = { "ALPHAUP", L["AlphaUp Speed"], 1, "AlphaUpSpeedSet", 0.01, 0.01, 1, nil, "%0.0f", 100, "%" },
	[13] = { "XPOS", L["X Position"], 1, "XAxisSet", 0.05, nil, nil, nil, "%0.2f", 1, "" },
	[14] = { "YPOS", L["Y Position"], 1, "YAxisSet", 0.05, nil, nil, nil, "%0.2f", 1, "" },
}

local swatchOptions = {
	[1] = { "BINDTEXT", L["Keybind Label"], 1, "BindTextSet", true, nil, "bindColor" },
	[2] = { "MACROTEXT", L["Macro Name"], 1, "MacroTextSet", true, nil, "macroColor" },
	[3] = { "COUNTTEXT", L["Stack/Charge Count Label"], 1, "CountTextSet", true, nil, "countColor" },
	[4] = { "RANGEIND", L["Out-of-Range Indicator"], 1, "RangeIndSet", true, nil, "rangecolor" },
	[5] = { "CDTEXT", L["Cooldown Countdown"], 1, "CDTextSet", true, true, "cdcolor1", "cdcolor2" },
	[6] = { "CDALPHA", L["Cooldown Transparency"], 1, "CDAlphaSet", nil, nil },
	[7] = { "AURATEXT", L["Buff/Debuff Aura Countdown"], 1, "AuraTextSet", true, true, "auracolor1", "auracolor2" },
	[8] = { "AURAIND", L["Buff/Debuff Aura Border"], 1, "AuraIndSet", true, true, "buffcolor", "debuffcolor" },
}

local specoveride = GetActiveSpecGroup() or 1

local updater


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronGUI:OnInitialize()

	NMM = NeuronMainMenu
	NBE = NeuronBarEditor
	NOE = NeuronObjectEditor
	NBTNE = NeuronButtonEditor

	MAS = NEURON.MANAGED_ACTION_STATES

	---This loads the Neuron interface panel
	LibStub("AceConfigRegistry-3.0"):ValidateOptionsTable(NeuronGUI.interfaceOptions, addonName)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, NeuronGUI.interfaceOptions)
	NeuronGUI.interfaceOptions.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(NEURON.db)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)


	--for the object editor
	NEURON.Editors.ACTIONBUTTON = { nil, 550, 350, nil }

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronGUI:OnEnable()

	for _,bar in pairs(NEURON.BARIndex) do
		self:hookHandler(bar.handler)
	end

	NeuronGUI:SecureHook("SpellButton_OnModifiedClick", "modifiedSpellClick")
	NeuronGUI:SecureHook("HandleModifiedItemClick", "modifiedItemClick")
	NeuronGUI:SecureHook("OpenStackSplitFrame", "openStackSplitFrame")

	C_Timer.After(1, function() NeuronGUI:DelayedOnUpdate() end)

	updater = CreateFrame("Frame", nil, UIParent)
	updater:SetScript("OnUpdate", runUpdater)
	updater.elapsed = 0
	updater:Hide()


	if(MountJournal)then
		self.hookMountButtons()
		self.hookPetJournalButtons()
	end

	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	self:RegisterEvent("ADDON_LOADED")

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Neuron-GUI", NeuronGUI.target_options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Neuron-Flyout", NeuronGUI.flyout_options)

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronGUI:OnDisable()

end


function NeuronGUI:DelayedOnUpdate()
	local content = CreateFrame("Frame",nil, NBTNE.options)
	content:SetPoint("TOPLEFT",10,-5 )
	content:SetPoint("BOTTOMRIGHT",-10,5)
	--This creats a cusomt AceGUI container which lets us imbed a AceGUI menu into our frame.
	local widget = {
		frame     = NBTNE.options,
		content   = content,
		type      = "NeuronContainer"
	}
	widget["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end

	NeuronButtonEditor.ACEmenu = widget
	NeuronAceGUI:RegisterAsContainer(widget)
end
-------------------------------------------------


function NeuronGUI:PLAYER_SPECIALIZATION_CHANGED()

	updater.elapsed = 0
	updater:Show()

end

function NeuronGUI:ADDON_LOADED(name)
	if name == "Blizzard_PetJournal" then
		self:hookMountButtons()
		self:hookPetJournalButtons()
	end
end







local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end


function NeuronGUI:SubFramePlainBackdrop_OnLoad(frame)
	frame:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\AddOns\\Neuron\\Images\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 22,
		insets = {left = 5, right = 5, top = 5, bottom = 5},})
	frame:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
	frame:SetBackdropColor(0,0,0,0)
	frame:GetParent().backdrop = frame

	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetTexture("Interface\\FriendsFrame\\UI-Toast-Background", true)
	frame.bg:SetVertexColor(0.65,0.65,0.65,0.85)
	frame.bg:SetPoint("TOPLEFT", 3, -3)
	frame.bg:SetPoint("BOTTOMRIGHT", -3, 3)
	frame.bg:SetHorizTile(true)
	frame.bg:SetVertTile(true)
end


function NeuronGUI:SubFrameBlackBackdrop_OnLoad(frame)
	frame:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\AddOns\\Neuron\\Images\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 18,
		insets = {left = 5, right = 5, top = 5, bottom = 5},})
	frame:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
	frame:SetBackdropColor(0,0,0,0)
	frame:GetParent().backdrop = frame

	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetTexture("Interface\\FriendsFrame\\UI-Toast-Background", true)
	frame.bg:SetVertexColor(0.65,0.65,0.65,1)
	frame.bg:SetPoint("TOPLEFT", 3, -3)
	frame.bg:SetPoint("BOTTOMRIGHT", -3, 3)
	frame.bg:SetHorizTile(true)
	frame.bg:SetVertTile(true)
end


function NeuronGUI:SubFrameBlankBackdrop_OnLoad(frame)
	frame:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\AddOns\\Neuron\\Images\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 12,
		insets = {left = 5, right = 5, top = 5, bottom = 5},})
	frame:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
	frame:SetBackdropColor(0,0,0,0)
	frame:GetParent().backdrop = frame
end


function NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)
	frame:SetBackdrop({
		bgFile = "",
		edgeFile = "Interface\\AddOns\\Neuron\\Images\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 18,
		insets = {left = 5, right = 5, top = 5, bottom = 5},})
	frame:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
	frame:SetBackdropColor(0,0,0,0)
	frame:GetParent().backdrop = frame

	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetTexture("Interface\\AddOns\\Neuron\\Images\\honeycomb_small", true)
	frame.bg:SetVertexColor(0.65,0.65,0.65,1)
	frame.bg:SetPoint("TOPLEFT", 3, -3)
	frame.bg:SetPoint("BOTTOMRIGHT", -3, 3)
	frame.bg:SetHorizTile(true)
	frame.bg:SetVertTile(true)
end




function NeuronGUI:insertLink(text)

	local item = GetItemInfo(text)

	--if (NBTNE.flyoutedit and NBTNE.flyoutedit.keyedit.edit:IsVisible()) then

	--	NBTNE.flyoutedit.keyedit.edit:Insert(item or text)

	--	return

	--end

	if (NBTNE.macroedit.edit:IsVisible()) then

		NBTNE.macroedit.edit:SetFocus()

		if (NBTNE.macroedit.edit:GetText() == "") then

			if (item) then

				if (GetItemSpell(text)) then
					NBTNE.macroedit.edit:Insert(SLASH_USE1.." "..item)
				else
					NBTNE.macroedit.edit:Insert(SLASH_EQUIP1.." "..item)
				end

			else
				NBTNE.macroedit.edit:Insert(SLASH_CAST1.." "..text)
			end
		else
			NBTNE.macroedit.edit:Insert(item or text)
		end
	end
end

function NeuronGUI:modifiedSpellClick(button)

	local id = SpellBook_GetSpellBookSlot(GetMouseFocus())

	if (id > MAX_SPELLS) then
		return
	end

	if (CursorHasSpell() and NBTNE:IsVisible()) then
		ClearCursor()
	end

	if (IsModifiedClick("CHATLINK")) then

		if (NBTNE:IsVisible()) then

			local spell, subName = GetSpellBookItemName(id, SpellBookFrame.bookType)

			if (spell and not IsPassiveSpell(id, SpellBookFrame.bookType)) then

				if (subName and #subName > 0) then
					self:insertLink(spell.."("..subName..")")
				else
					self:insertLink(spell.."()")
				end
			end
			return
		end
	end

	if (IsModifiedClick("PICKUPACTION")) then

		PickupSpell(id, SpellBookFrame.bookType)

	end
end

function NeuronGUI:modifiedItemClick(link)

	if (IsModifiedClick("CHATLINK")) then

		if (NBTNE:IsVisible()) then

			local itemName = GetItemInfo(link)

			if (itemName) then
				self:insertLink(itemName)
			end

			return true
		end
	end
end

function NeuronGUI:modifiedMountClick(button)

	local id = button:GetParent().spellID

	if (CursorHasSpell() and NBTNE:IsVisible()) then
		ClearCursor()
	end

	if (IsModifiedClick("CHATLINK")) then

		if (NBTNE:IsVisible()) then

			local mount = GetSpellInfo(id)

			if (mount) then
				self:insertLink(mount.."()")
			end

			return
		end
	end
end

function NeuronGUI:modifiedPetJournalClick(button)

	local id = button:GetParent().petID

	if (NBTNE:IsVisible()) then
		ClearCursor()
	end

	if (IsModifiedClick("CHATLINK")) then

		if (NBTNE:IsVisible()) then

			local _, _, _, _, _, _, petName = C_PetJournal.GetPetInfoByPetID(id)

			if (petName) then
				self:insertLink(petName.."()")
			end

			return
		end
	end
end

function NeuronGUI:openStackSplitFrame(...)

	if (NBTNE:IsVisible()) then
		StackSplitFrame:Hide()
	end
end

function NeuronGUI:NeuronPanelTemplates_DeselectTab(tab)

	tab.left:Show()
	tab.middle:Show()
	tab.right:Show()

	tab.leftdisabled:Hide()
	tab.middledisabled:Hide()
	tab.rightdisabled:Hide()

	tab:Enable()
	tab:SetDisabledFontObject(GameFontDisableSmall)
	tab.text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 4))


end

function NeuronGUI:NeuronPanelTemplates_SelectTab(tab)

	tab.left:Hide()
	tab.middle:Hide()
	tab.right:Hide()

	tab.leftdisabled:Show()
	tab.middledisabled:Show()
	tab.rightdisabled:Show()

	tab:Disable()
	tab:SetDisabledFontObject(GameFontHighlightSmall)
	tab.text:SetPoint("CENTER", tab, "CENTER", (tab.selectedTextX or 0), (tab.selectedTextY or 7))

	if (GameTooltip:IsOwned(tab)) then
		GameTooltip:Hide()
	end
end

function NeuronGUI:NeuronPanelTemplates_TabResize(tab, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)

	local sideWidths= 2 * tab.left:GetWidth()
	local  width, tabWidth, textWidth


	if ( absoluteTextSize ) then
		textWidth = absoluteTextSize
	else
		tab.text:SetWidth(0)
		textWidth = tab.text:GetWidth()
	end

	if ( absoluteSize ) then

		if ( absoluteSize < sideWidths) then
			width = 1
			tabWidth = sideWidths
		else
			width = absoluteSize - sideWidths
			tabWidth = absoluteSize
		end

		tab.text:SetWidth(width)
	else

		if ( padding ) then
			width = textWidth + padding
		else
			width = textWidth + 24
		end

		if ( maxWidth and width > maxWidth ) then
			if ( padding ) then
				width = maxWidth + padding
			else
				width = maxWidth + 24
			end
			tab.text:SetWidth(width)
		else
			tab.text:SetWidth(0)
		end

		if (minWidth and width < minWidth) then
			width = minWidth
		end

		tabWidth = width + sideWidths
	end

	tab.middle:SetWidth(width)
	tab.middledisabled:SetWidth(width)

	tab:SetWidth(tabWidth)
	tab.highlighttexture:SetWidth(tabWidth)

end

-- This builds the string of any custom states in the order that they were originaly entered.
function NeuronGUI:generateCustomStateList(bar)
	local start = tonumber(string.match(bar.cdata.customRange, "^%d+"))
	local stop = tonumber(string.match(bar.cdata.customRange, "%d+$"))
	local customStateList = bar.cdata.customNames["homestate"]..";"

	for index = start, stop, 1 do
		customStateList = customStateList..bar.cdata.customNames["custom"..index]..";"
	end

	return customStateList
end

function NeuronGUI:UpdateBarGUI(newBar)

	NeuronGUI:BarListScrollFrameUpdate()

	local bar = NEURON.CurrentBar

	if (bar and GUIData[bar.class]) then

		if (NBE:IsVisible()) then
			NBE.count.text:SetText(L["Number of Buttons"]..": |cffffffff"..bar.objCount.."|r")
			NBE.barname:SetText(bar.gdata.name)
		end

		if (NBE.baropt:IsVisible()) then

			local yoff = -10
			local adjHeight, anchor, last

			if (NBE.baropt.colorpicker:IsShown()) then
				NBE.baropt.colorpicker:Hide()
			end

			if (GUIData[bar.class].adjOpt) then
				NBE.baropt.adjoptions:SetPoint("BOTTOMLEFT", NBE.baropt.chkoptions, "BOTTOMRIGHT", 0, GUIData[bar.class].adjOpt)

				adjHeight = (height-85) - (GUIData[bar.class].adjOpt - 10)
			else
				NBE.baropt.adjoptions:SetPoint("BOTTOMLEFT", NBE.baropt.chkoptions, "BOTTOMRIGHT", 0, 30)

				adjHeight = (height-85) - 20
			end

			for i,f in ipairs(barOpt.chk) do
				f:ClearAllPoints(); f:Hide()
			end

			for i,f in ipairs(barOpt.chk) do

				if (GUIData[bar.class].chkOpt[f.option]) then

					if (NEURON.NeuronBar[f.func]) then
						if (f.primary) then
							if (f.primary:GetChecked()) then
								f:Enable()
								f:SetChecked(NEURON.NeuronBar[f.func](NEURON.NeuronBar, bar, f.modtext, true, nil, true))
								f.text:SetTextColor(1,0.82,0)
								f.disabled = nil
							else
								f:SetChecked(nil)
								f:Disable()
								f.text:SetTextColor(0.5,0.5,0.5)
								f.disabled = true
							end
						else
							f:SetChecked(NEURON.NeuronBar[f.func](NEURON.NeuronBar, bar, f.modtext, true, nil, true))
						end
					end

					if (not f.disabled) then

						if (f.primary) then
							f:SetPoint("TOPRIGHT", f.parent, "TOPRIGHT", -10, yoff)
							yoff = yoff-f:GetHeight()-5
						else
							f:SetPoint("TOPRIGHT", f.parent, "TOPRIGHT", -10, yoff)
							yoff = yoff-f:GetHeight()-5
						end

						f:Show()


					end
				end
			end

			local yoff1, yoff2= (adjHeight)/7, (adjHeight)/7
			local shape

			for i,f in ipairs(barOpt.adj) do

				f:ClearAllPoints(); f:Hide()

				if (NEURON.NeuronBar[f.func] and f.option == "SHAPE") then

					shape = NEURON.NeuronBar[f.func](NEURON.NeuronBar, bar, nil, true, true)

					if (shape ~= L["Linear"]) then
						yoff1 = (adjHeight)/8
					end
				end

				if (f.optData) then

					wipe(popupData)

					for k,v in pairs(f.optData) do
						popupData[k.."_"..v] = tostring(k)
					end

					NEURON.EditBox_PopUpInitialize(f.edit.popup, popupData)
				end
			end

			yoff = -(yoff1/2)

			for i,f in ipairs(barOpt.adj) do

				if (f.option == "COLUMNS") then

					if (shape == L["Linear"]) then

						f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
						f:Show()

						yoff = yoff-yoff1
					end

				elseif (f.option == "ARCSTART" or f.option == "ARCLENGTH") then

					if (shape ~= L["Linear"]) then

						f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
						f:Show()

						yoff = yoff-yoff1
					end

				elseif (i >= 9) then

					if (i==9) then
						yoff = -(yoff2/2)
					end

					f:SetPoint("TOPLEFT", f.parent, "TOP", 10, yoff)
					f:Show()

					yoff = yoff-yoff2
				else

					f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
					f:Show()

					yoff = yoff-yoff1
				end

				if (NEURON.NeuronBar[f.func]) then

					f.edit.value = nil

					if (f.format) then
						f.edit:SetText(format(f.format, NEURON.NeuronBar[f.func](NEURON.NeuronBar, bar, nil, true, true)*f.mult)..f.endtext)
					else
						f.edit:SetText(NEURON.NeuronBar[f.func](NEURON.NeuronBar, bar, nil, true, true))
					end
					f.edit:SetCursorPosition(0)
				end
			end

			for i,f in ipairs(barOpt.swatch) do
				f:ClearAllPoints(); f:Hide()
			end

			yoff = -10

			for i,f in ipairs(barOpt.swatch) do

				if (GUIData[bar.class].chkOpt[f.option]) then

					if (NEURON.NeuronBar[f.func]) then

						local checked, color1, color2 = NEURON.NeuronBar[f.func](NEURON.NeuronBar, bar, f.modtext, true, nil, true)

						f:SetChecked(checked)

						if (color1) then
							f.swatch1:GetNormalTexture():SetVertexColor((";"):split(color1))
							f.swatch1.color = color1
						else
							f.swatch1:GetNormalTexture():SetVertexColor(0,0,0)
							f.swatch1.color = "0;0;0;0"
						end

						if (color2) then
							f.swatch2:GetNormalTexture():SetVertexColor((";"):split(color2))
							f.swatch2.color = color2
						else
							f.swatch2:GetNormalTexture():SetVertexColor(0,0,0)
							f.swatch2.color = "0;0;0;0"
						end
					end

					if (i >= 5) then

						if (i == 5) then
							yoff = -10
						end

						f:SetPoint("TOPRIGHT", f.parent, "TOPRIGHT", -95, yoff)
					else

						f:SetPoint("TOPRIGHT", f.parent, "TOP", -95, yoff)
					end

					f:Show()

					yoff = yoff-f:GetHeight()-6
				end
			end
		end

		if (NBE.barstates:IsVisible()) then

			local editor = NBE.barstates.actionedit

			if (NBE.baropt.colorpicker:IsShown()) then
				NBE.baropt.colorpicker:Hide()
			end

			if (editor:IsVisible()) then

				if (GUIData[bar.class].stateOpt) then

					editor.tab1:Enable()
					editor.tab2:Enable()
					editor.tab1.text:SetTextColor(0.85, 0.85, 0.85)
					editor.tab2.text:SetTextColor(0.85, 0.85, 0.85)

					editor.tab1:Click()

					editor:SetPoint("BOTTOMRIGHT", NBE.barstates, "TOPRIGHT", 0, -170)

				else
					editor.tab3:Click()

					editor.tab1:Disable()
					editor.tab2:Disable()
					editor.tab1.text:SetTextColor(0.4, 0.4, 0.4)
					editor.tab2.text:SetTextColor(0.4, 0.4, 0.4)

					editor:SetPoint("BOTTOMRIGHT", NBE.barstates, "TOPRIGHT", 0, -30)

				end
			end

			--Sets bar primaary options
			for i,f in ipairs(barOpt.pri) do
				if (f.option == "stance" and (GetNumShapeshiftForms() < 1 or NEURON.class == "DEATHKNIGHT" or NEURON.class == "PALADIN" or NEURON.class == "HUNTER")) then
					f:SetChecked(nil)
					f:Disable()
					f.text:SetTextColor(0.5,0.5,0.5)
				else
					f:SetChecked(bar.cdata[f.option])
					f:Enable()
					f.text:SetTextColor(1,0.82,0)
				end
			end

			--Sets bar secondary options
			for i,f in ipairs(barOpt.sec) do

				if (f.stance ) then
					if (f.stance:GetChecked()) then
						f:SetChecked(bar.cdata[f.option])
						f:Enable()
						f.text:SetTextColor(1,0.82,0)
					else
						f:SetChecked(nil)
						f:Disable()
						f.text:SetTextColor(0.5,0.5,0.5)
					end
				else
					f:SetChecked(bar.cdata[f.option])
				end
			end

			wipe(popupData)

			for state, value in pairs(NEURON.STATES) do

				if (bar.cdata.paged and state:find("paged")) then

					popupData[value] = state:match("%d+")

				elseif (bar.cdata.stance and state:find("stance")) then

					popupData[value] = state:match("%d+")

				end
			end

			NEURON.EditBox_PopUpInitialize(barOpt.remap.popup, popupData)
			NEURON.EditBox_PopUpInitialize(barOpt.remapto.popup, popupData)

			if (newBar) then
				barOpt.remap:SetText("")
				barOpt.remapto:SetText("")
			end
		end

		--Sets bar custom state options
		local customStateList = ""
		if (bar and bar.cdata.customNames) then

			customStateList = NeuronGUI:generateCustomStateList(bar)

		end

		barOpt.customstate:SetText(customStateList)
	end
	--Set visisbility buttons
	NeuronGUI:VisEditorScrollFrameUpdate()
	NeuronGUI:SecondaryPresetsScrollFrameUpdate()

	LibStub("AceConfigDialog-3.0"):Open("Neuron-GUI", NBE.ACEmenu)

end


function NeuronGUI:UpdateObjectGUI(reset)

	for editor, data in pairs(NEURON.Editors) do
		if (data[1]:IsVisible()) then
			data[4](reset)
		end
	end
end


function NeuronGUI:updateBarName(frame)

	local bar = NEURON.CurrentBar

	if (bar) then

		bar.gdata.name = frame:GetText()

		bar.text:SetText(bar.gdata.name)

		NEURON.NeuronBar:SaveData(bar)

		frame:ClearFocus()

		NeuronGUI:BarListScrollFrameUpdate()
	end
end


function NeuronGUI:resetBarName(frame)
	local bar = NEURON.CurrentBar

	if (bar) then
		frame:SetText(bar.gdata.name)
		frame:ClearFocus()
	end
end

function NeuronGUI:resetMacroText(frame)
	local bar = NEURON.CurrentBar

	if (bar) then
		frame:SetText(bar.gdata.name)
		frame:ClearFocus()
	end
end

function NeuronGUI:updateCustomState(frame)
	local bar = NEURON.CurrentBar
	local state = frame:GetText()
	local customStateList = ""

	NEURON.NeuronBar:SetState(bar, "custom", true, false)  --turns off custom state to clear any previous stored items
	if (bar and state ~= "") then
		NEURON.NeuronBar:SetState(bar, "custom "..state, true, true)
	end

	if (bar and bar.cdata.customNames) then
		customStateList = NeuronGUI:generateCustomStateList(bar)
	end

	barOpt.customstate:SetText(customStateList)
	NeuronGUI.VisEditorScrollFrameUpdate()
	frame:ClearFocus()
end

function NeuronGUI:countOnMouseWheel(delta)

	local bar = NEURON.CurrentBar

	if (bar) then

		if (delta > 0) then
			NEURON.NeuronBar:AddObjects(bar)
		else
			NEURON.NeuronBar:RemoveObjects(bar)
		end
	end
end

function NeuronGUI:BarEditor_OnLoad(frame)

	NeuronGUI:SubFramePlainBackdrop_OnLoad(frame)


	frame:SetWidth(width)
	frame:SetHeight(height)

	--frame:RegisterEvent("ADDON_LOADED")
	frame:RegisterForDrag("LeftButton", "RightButton")
	frame.bottom = 0

	frame.tabs = {}

	---helper function that depends on parents "frame"
	local function TabsOnClick(cTab, silent)

		for tab, panel in pairs(frame.tabs) do

			if (tab == cTab) then

				tab:SetChecked(1)

				if (MouseIsOver(cTab)) then
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
				end

				panel:Show()

				NeuronGUI:UpdateBarGUI()
			else
				tab:SetChecked(nil)
				panel:Hide()
			end

		end
	end

	local f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -28, -8.5)
	f:SetScript("OnClick", function(self) TabsOnClick(self, true) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText(L["Spell Target Options"])
	frame.tab3 = f; frame.tabs[f] = frame.targetoptions

	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab3, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText(L["Bar States"])
	frame.tab2 = f; frame.tabs[f] = frame.barstates

	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab2, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(1)
	f.text:SetText(L["General Options"])
	frame.tab1 = f; frame.tabs[f] = frame.baropt


	f = CreateFrame("EditBox", nil,frame, "NeuronEditBoxTemplateSmall")
	f:SetWidth(160)
	f:SetHeight(26)
	f:SetPoint("LEFT", frame.tab1, "LEFT", -3.5, 0) --weirdly I had to change the first "RIGHT" to a "LEFT" when I switched to Ace3-Addon
	f:SetPoint("TOPLEFT", frame.barlist, "TOPRIGHT", 3.5, 0)
	f:SetScript("OnEnterPressed", function(self) NeuronGUI:updateBarName(self) end)
	f:SetScript("OnTabPressed", function(self) NeuronGUI:updateBarName(self) end)
	f:SetScript("OnEscapePressed", function(self) NeuronGUI:resetBarName(self) end)
	frame.barname = f

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("Frame", nil, frame)
	f:SetWidth(250)
	f:SetHeight(30)
	f:SetPoint("BOTTOM", 0, 10)
	f:SetScript("OnMouseWheel", function(self, delta) NeuronGUI.countOnMouseWheel(self, delta) end)
	f:EnableMouseWheel(true)
	frame.count = f

	local text = f:CreateFontString(nil, "ARTWORK", "DialogButtonNormalText")
	text:SetPoint("CENTER")
	text:SetJustifyH("CENTER")
	text:SetText("Test Object Count: 12")
	frame.count.text = text

	f = CreateFrame("Button", nil, frame.count)
	f:SetWidth(32)
	f:SetHeight(40)
	f:SetPoint("LEFT", text, "RIGHT", 10, -1)
	f:SetNormalTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionRight-Up")
	f:SetPushedTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionRight-Down")
	f:SetHighlightTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionRight-Highlight")
	f:SetScript("OnClick", function() if (NEURON.CurrentBar) then NEURON.NeuronBar:AddObjects(NEURON.CurrentBar) end end)

	f = CreateFrame("Button", nil, frame.count)
	f:SetWidth(32)
	f:SetHeight(40)
	f:SetPoint("RIGHT", text, "LEFT", -10, -1)
	f:SetNormalTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionLeft-Up")
	f:SetPushedTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionLeft-Down")
	f:SetHighlightTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionLeft-Highlight")
	f:SetScript("OnClick", function() if (NEURON.CurrentBar) then NEURON.NeuronBar:RemoveObjects(NEURON.CurrentBar) end end)

end

function NeuronGUI:BarList_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

	frame:SetHeight(height-55)

end

function NeuronGUI:BarListScrollFrame_OnLoad(frame)

	frame.offset = 0
	frame.scrollChild = _G[frame:GetName().."ScrollChildFrame"]

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	local button, lastButton, rowButton, count = false, false, false, 0

	for i=1,numShown do

		button = CreateFrame("CheckButton", frame:GetName().."Button"..i, frame:GetParent(), "NeuronScrollFrameButtonTemplate")

		button.frame = frame:GetParent()
		button.numShown = numShown

		button:SetScript("OnClick",

			function(self)

				local button

				for i=1,numShown do

					button = _G["NeuronBarEditorBarListScrollFrameButton"..i]

					if (i == self:GetID()) then

						if (self.alt) then

							if (self.bar) then

								NEURON.NeuronBar:CreateNewBar(self.bar)

								NeuronBarEditorCreate:Click()
							end

							self.alt = nil

						elseif (self.bar) then

							NEURON.NeuronBar:ChangeBar(self.bar)

							if (NBE and NBE:IsVisible()) then
								NeuronGUI:UpdateBarGUI()
							end

						end
					else
						button:SetChecked(nil)
					end

				end

			end)

		button:SetScript("OnEnter",
			function(self)
				if (self.alt) then

				elseif (self.bar) then
					NEURON.NeuronBar:OnEnter(self.bar)
				end
			end)

		button:SetScript("OnLeave",
			function(self)
				if (self.alt) then

				elseif (self.bar) then
					NEURON.NeuronBar:OnLeave(self.bar)
				end
			end)

		button:SetScript("OnShow",
			function(self)
				self:SetHeight((self.frame:GetHeight()-10)/self.numShown)
			end)

		button.name = button:CreateFontString(button:GetName().."Index", "ARTWORK", "GameFontNormalSmall")
		button.name:SetPoint("TOPLEFT", button, "TOPLEFT", 5, 0)
		button.name:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 0)
		button.name:SetJustifyH("LEFT")

		button:SetID(i)
		button:SetFrameLevel(frame:GetFrameLevel()+2)
		button:SetNormalTexture("")

		if (not lastButton) then
			button:SetPoint("TOPLEFT", 8, -5)
			button:SetPoint("TOPRIGHT", -15, -5)
			lastButton = button
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 0)
			button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", 0, 0)
			lastButton = button
		end

	end

	NeuronGUI:BarListScrollFrameUpdate()
end

function NeuronGUI:BarListScrollFrameUpdate(frame, tableList, alt)

	if (not NeuronBarEditorBarList:IsVisible()) then return end

	if (not tableList) then

		wipe(barNames)

		for _,bar in pairs(NEURON.BARIndex) do
			if (bar.gdata.name) then
				barNames[bar.gdata.name] = bar
			end
		end

		tableList = barNames
	end

	if (not frame) then
		frame = NeuronBarEditorBarListScrollFrame
	end

	local dataOffset, count, data = FauxScrollFrame_GetOffset(frame), 1, {}
	local  button, text

	for k in pairs(tableList) do
		data[count] = k; count = count + 1
	end

	table.sort(data)

	frame:Show()

	frame.buttonH = frame:GetHeight()/numShown

	for i=1,numShown do

		button = _G["NeuronBarEditorBarListScrollFrameButton"..i]
		button:SetChecked(nil)

		count = dataOffset + i

		if (data[count]) then

			text = data[count]

			if (tableList[text] == NEURON.CurrentBar) then
				button:SetChecked(1)
			end

			button.alt = alt
			button.bar = tableList[text]
			button.name:SetText(text)
			button:Enable()
			button:Show()

			if (alt) then --this is for the create bar menu list
				if (i>0) then
					button.name:SetTextColor(0,1,0)
					button.name:SetJustifyH("CENTER")
				else
					button.name:SetJustifyH("CENTER")
					button:Disable()
				end
			else
				button.name:SetTextColor(1,0.82,0)
				button.name:SetJustifyH("LEFT")
			end
		else

			button:Hide()
		end
	end

	FauxScrollFrame_Update(frame, #data, numShown, 2)
end

function NeuronGUI:CreateButton_OnLoad(button)

	button.type = "create"
	button.text:SetText(L["Create New Bar"])

end


--- Checks to see if a one only bar type has been deleted.  If so it will allow the bar
-- to be created
-- @param bar: type of bar being checked
-- @return allow : (boolean)
function NeuronGUI:MissingBarCheck(bar)
	local allow = true
	if ((bar == "extrabar" and NeuronCDB.xbars[1]) or (bar == "zoneabilitybar" and NeuronCDB.zoneabilitybars[1]))then
		allow = false
	end
	return allow
end


function NeuronGUI:BarEditor_CreateNewBar(button)
	if (button.type == "create") then

		local data = {} --{ [L["Select Bar Type"]] = "none" }

		for class,info in pairs(NEURON.RegisteredBarData) do

			if (info.barCreateMore or NeuronGUI:MissingBarCheck(class)) then
				data[info.barLabel] = class
			end
		end

		NeuronGUI:BarListScrollFrameUpdate(nil, data, true)

		button.type = "cancel"

		button.text:SetText(L["Cancel"])
	else

		NeuronGUI:BarListScrollFrameUpdate()

		button.type = "create"

		button.text:SetText(L["Create New Bar"])

	end
end

function NeuronGUI:DeleteButton_OnLoad(button)

	button.parent = button:GetParent()
	button.parent.delete = button
	button.type = "delete"
	button.text:SetText(L["Delete Current Bar"])

end

function NeuronGUI:BarEditor_DeleteBar(button)

	local bar = NEURON.CurrentBar

	if (bar and button.type == "delete") then

		button:Hide()
		button.parent.confirm:Show()
		button.type = "confirm"
	else
		button:Show()
		button.parent.confirm:Hide()
		button.type = "delete"
	end

end

function NeuronGUI:Confirm_OnLoad(button)

	button.parent = button:GetParent()
	button.parent.confirm = button
	button.title:SetText(L["Confirm"])

end

function NeuronGUI:ConfirmYes_OnLoad(button)

	button.parent = button:GetParent()
	button.type = "yes"
	_G[button:GetName().."Text"]:SetText(L["Yes"])

end

function NeuronGUI:BarEditor_ConfirmYes(button)

	local bar = NEURON.CurrentBar

	if (bar) then
		NEURON.NeuronBar:DeleteBar(bar)
	end

	NeuronBarEditorDelete:Click()

end

function NeuronGUI:ConfirmNo_OnLoad(button)

	button.parent = button:GetParent()
	button.type = "no"
	_G[button:GetName().."Text"]:SetText(L["No"])
end

function NeuronGUI:BarEditor_ConfirmNo(button)
	NeuronBarEditorDelete:Click()
end

function NeuronGUI:chkOptionOnClick(button)

	local bar = NEURON.CurrentBar

	if (bar and button.func) then
		NEURON.NeuronBar[button.func](NEURON.NeuronBar, bar, button.modtext, true, button:GetChecked())
	end
end

function NeuronGUI:BarOptions_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

	local f, primary

	for index, options in ipairs(chkOptions) do

		f = CreateFrame("CheckButton", nil, frame, "NeuronOptionsCheckButtonTemplate")
		f:SetID(index)
		f:SetWidth(18)
		f:SetHeight(18)
		f:SetScript("OnClick", function(self) NeuronGUI:chkOptionOnClick(self) end)
		--f:SetScale(options[2])
		f:SetScale(1)
		f:SetHitRectInsets(-100, 0, 0, 0)
		f:SetCheckedTexture("Interface\\Addons\\Neuron\\Images\\RoundCheckGreen.tga")

		f.option = options[1]
		f.func = options[4]
		f.modtext = options[5]
		f.parent = frame

		if (f.modtext) then
			f.text:SetFontObject("GameFontNormalSmall")
		end

		f.text:ClearAllPoints()
		f.text:SetPoint("LEFT", -120, 0)
		f.text:SetText(options[2])

		if (f.modtext) then
			f.primary = primary
		else
			primary = f
		end

		tinsert(barOpt.chk, f)
	end
end

function NeuronGUI:adjOptionOnTextChanged(edit, frame)

	local bar = NEURON.CurrentBar

	if (bar) then

		if (frame.method == 1) then

		elseif (frame.method == 2 and edit.value) then

			NEURON.NeuronBar[frame.func](NEURON.NeuronBar, bar, edit.value, true)

			edit.value = nil
		end
	end
end

function NeuronGUI:adjOptionOnEditFocusLost(edit, frame)

	edit.hasfocus = nil

	local bar = NEURON.CurrentBar

	if (bar) then

		if (frame.method == 1) then

			NEURON.NeuronBar[frame.func](NEURON.NeuronBar, bar, edit:GetText(), true)

		elseif (frame.method == 2) then

		end
	end
end

function NeuronGUI:adjOptionAdd(frame, onupdate)

	local bar = NEURON.CurrentBar

	if (bar) then

		local num = NEURON.NeuronBar[frame.func](NEURON.NeuronBar, bar, nil, true, true)

		if (num == L["Off"] or num == "---") then
			num = 0
		else
			num = tonumber(num)
		end

		if (num and frame.inc) then

			if (frame.max and num >= frame.max) then

				NEURON.NeuronBar[frame.func](NEURON.NeuronBar, bar, frame.max, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(format(frame.format, frame.max*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(frame.max)
					end
				end
			else
				NEURON.NeuronBar[frame.func](NEURON.NeuronBar, bar, num+frame.inc, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(format(frame.format, (num+frame.inc)*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(num+frame.inc)
					end
				end
			end
		end
	end
end

function NeuronGUI:adjOptionSub(frame, onupdate)

	local bar = NEURON.CurrentBar

	if (bar) then

		local num = NEURON.NeuronBar[frame.func](NEURON.NeuronBar, bar, nil, true, true)

		if (num == L["Off"] or num == "---") then
			num = 0
		else
			num = tonumber(num)
		end

		if (num and frame.inc) then

			if (frame.min and num <= frame.min) then

				NEURON.NeuronBar[frame.func](NEURON.NeuronBar, bar, frame.min, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(format(frame.format, frame.min*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(frame.min)
					end
				end
			else
				NEURON.NeuronBar[frame.func](NEURON.NeuronBar, bar, num-frame.inc, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(format(frame.format, (num-frame.inc)*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(num-frame.inc)
					end
				end
			end
		end
	end
end

function NeuronGUI:adjOptionOnMouseWheel(frame, delta)

	if (delta > 0) then
		NeuronGUI:adjOptionAdd(frame)
	else
		NeuronGUI:adjOptionSub(frame)
	end

end

function NeuronGUI:AdjustableOptions_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

	local f

	for index, options in ipairs(adjOptions) do

		f = CreateFrame("Frame", "NeuronGUIAdjOpt"..index, frame, "NeuronAdjustOptionTemplate")
		f:SetID(index)
		f:SetWidth(200)
		f:SetHeight(24)
		f:SetScript("OnShow", function() end)
		f:SetScript("OnMouseWheel", function(self, delta) NeuronGUI:adjOptionOnMouseWheel(self, delta) end)
		f:EnableMouseWheel(true)

		f.text:SetText(options[2]..":")
		f.method = options[3]
		f["method"..options[3]]:Show()
		f.edit = f["method"..options[3]].edit
		f.edit.frame = f
		f.option = options[1]
		f.func = options[4]
		f.inc = options[5]
		f.min = options[6]
		f.max = options[7]
		f.optData = options[8]
		f.format = options[9]
		f.mult = options[10]
		f.endtext = options[11]
		f.parent = frame

		f.edit:SetScript("OnTextChanged", function(self) NeuronGUI:adjOptionOnTextChanged(self, self.frame) end)
		f.edit:SetScript("OnEditFocusLost", function(self) NeuronGUI:adjOptionOnEditFocusLost(self, self.frame) end)

		f.addfunc = (function(self) NeuronGUI:adjOptionAdd(self) end)
		f.subfunc = (function(self) NeuronGUI:adjOptionSub(self) end)

		tinsert(barOpt.adj, f)
	end
end

function NeuronGUI:visOptionOnClick(button)

	local bar = NEURON.CurrentBar

	if (bar and button.func) then
		NEURON.NeuronBar[button.func](NEURON.NeuronBar, bar, nil, true, button:GetChecked())
	end

end

function NeuronGUI:colorPickerShow(button)

	if (button.color) then

		local frame  = NBE.baropt.colorpicker

		frame.updateFunc = function()

			local bar = NEURON.CurrentBar

			if (bar) then

				local r,g,b = NeuronColorPicker:GetColorRGB()
				local a = NeuronColorPicker.alpha:GetValue()

				r = round(r,2); g = round(g,2); b = round(b,2); a = 1-round(a,2)

				if (r and g and b and a) then

					local value = r..";"..g..";"..b..";"..a

					bar.gdata[button.option] = value

					NEURON.NeuronBar:UpdateObjectData(bar)

					NEURON.NeuronBar:Update(bar)
				end
			end
		end

		local r,g,b,a = (";"):split(button.color)

		if (r and g and b) then
			NeuronColorPicker:SetColorRGB(r,g,b)
		end

		a = tonumber(a)

		if (a) then
			NeuronColorPicker.alpha:SetValue(1-a)
			NeuronColorPicker.alphavalue:SetText(a)
		end

		frame:Show()

	end
end

function NeuronGUI:VisiualOptions_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

	local f, primary

	for index, options in ipairs(swatchOptions) do

		f = CreateFrame("CheckButton", nil, frame, "NeuronOptionsCheckButtonSwatchTemplate")
		f:SetID(index)
		f:SetWidth(18)
		f:SetHeight(18)
		f:SetScript("OnClick", function(self) NeuronGUI:visOptionOnClick(self) end)
		f:SetScale(1)

		f.text:SetText(options[2]..":")
		f.option = options[1]
		f.func = options[4]
		f.parent = frame

		if (options[5]) then
			f.swatch1:Show()
			f.swatch1:SetScript("OnClick", function(self) NeuronGUI:colorPickerShow(self) end)
			f.swatch1.option = options[7]
		end

		if (options[6]) then
			f.swatch2:Show()
			f.swatch2:SetScript("OnClick", function(self) NeuronGUI:colorPickerShow(self) end)
			f.swatch2.option = options[8]
		end

		tinsert(barOpt.swatch, f)
	end
end

function NeuronGUI:BarEditorColorPicker_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

end

function NeuronGUI:BarEditorColorPicker_OnShow(frame)

	NeuronColorPicker.frame = frame

	NeuronColorPicker:ClearAllPoints()
	NeuronColorPicker:SetParent(frame)
	NeuronColorPicker:SetPoint("TOPLEFT", 0, -20)
	NeuronColorPicker:SetPoint("BOTTOMRIGHT")
	NeuronColorPicker:Show()

end

function NeuronGUI:setBarActionState(frame)

	local bar = NEURON.CurrentBar

	if (bar) then
		NEURON.NeuronBar:SetState(bar, frame.option, true, frame:GetChecked())
	end
end

function NeuronGUI:setBarVisability(button)
	local bar = NEURON.CurrentBar
	if (bar) then
		NEURON.NeuronBar:SetVisibility(bar, button.msg, true)
	end
end


function NeuronGUI:remapOnTextChanged(frame)

	local bar = NEURON.CurrentBar

	if (bar and bar.cdata.remap and frame.value) then

		local map, remap

		for states in gmatch(bar.cdata.remap, "[^;]+") do

			map, remap = (":"):split(states)

			if (map == frame.value) then

				barOpt.remapto.value = remap

				if (bar.cdata.paged) then
					barOpt.remapto:SetText(NEURON.STATES["paged"..remap])
				elseif (bar.cdata.stance) then
					barOpt.remapto:SetText(NEURON.STATES["stance"..remap])
				end
			end
		end
	else
		barOpt.remapto:SetText("")
	end
end

function NeuronGUI:remapToOnTextChanged(frame)

	local bar = NEURON.CurrentBar

	if (bar and bar.cdata.remap and frame.value and #frame.value > 0) then

		local value = barOpt.remap.value

		bar.cdata.remap = bar.cdata.remap:gsub(value..":%d+", value..":"..frame.value)

		if (bar.cdata.paged) then
			bar.paged.registered = false
		elseif (bar.cdata.stance) then
			bar.stance.registered = false
		end

		bar.stateschanged = true

		NEURON.NeuronBar:Update(bar)
	end
end


function NeuronGUI:ActionEditor_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

	frame.tabs = {}

	local function TabsOnClick(cTab, silent)

		for tab, panel in pairs(frame.tabs) do

			if (tab == cTab) then
				if (MouseIsOver(cTab) and not tab.selected) then
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
				end
				panel:Show()
				tab:SetHeight(33)
				tab:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
				tab:SetBackdropColor(1,1,1,1)
				tab.text:SetTextColor(1,0.82,0)

				tab.selected = true
			else
				panel:Hide()
				tab:SetHeight(28)
				tab:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
				tab:SetBackdropColor(0.7,0.7,0.7,1)
				tab.text:SetTextColor(0.85, 0.85, 0.85)

				tab.selected = nil
			end

		end
	end

	local f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTabTemplate")
	f:SetWidth(160)
	f:SetHeight(33)
	f:SetPoint("TOPLEFT", frame, "BOTTOMLEFT",5,4)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel())
	f:SetBackdropColor(0.3,0.3,0.3,1)
	f.text:SetText(L["Preset Action States"])
	f.selected = true
	frame.tab1 = f; frame.tabs[f] = frame.presets

	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTabTemplate")
	f:SetWidth(160)
	f:SetHeight(28)
	f:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT",-5,4)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel())
	f.text:SetText(L["Custom Action States"])
	frame.tab2 = f; frame.tabs[f] = frame.custom

	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTabTemplate")
	f:SetWidth(160)
	f:SetHeight(28)
	f:SetPoint("TOP", frame, "BOTTOM",0,0)
	f:SetScript("OnClick", function(self) TabsOnClick(self, true) end)
	f:SetFrameLevel(frame:GetFrameLevel())
	f:Hide()
	frame.tab3 = f; frame.tabs[f] = frame.hidden

	local states = {}
	local anchor, last, count

	local MAS = NEURON.MANAGED_ACTION_STATES

	--this is confusing, but states comes out to just be a list of the names of the states
	for state, values in pairs(MAS) do
		states[values.order] = state
	end

	for index,state in ipairs(states) do
		if (MAS[state].homestate) then

			f = CreateFrame("CheckButton", nil, frame.presets.primary, "NeuronOptionsCheckButtonTemplate")
			f:SetID(index)
			f:SetWidth(18)
			f:SetHeight(18)
			f:SetScript("OnClick", function(self) NeuronGUI:setBarActionState(self) end)
			--Renames Stance for rogues to Stealth as that is what should really be used
			if state == "stance" and (NEURON.class == "ROGUE") then
				f.text:SetText(L["Stealth"])--:upper())
			else
				f.text:SetText(MAS[state].localizedName)--:upper())
			end
			f.option = state

			if (not anchor) then
				f:SetPoint("TOPLEFT", frame.presets.primary, "TOPLEFT", 10, -10)
				anchor = f; last = f
			else
				f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -18)
				last = f
			end

			tinsert(barOpt.pri, f)
		end
	end

	anchor, last, count = nil, nil, 1


	f = CreateFrame("CheckButton", nil, frame.custom, "NeuronOptionsCheckButtonTemplate")
	--f:SetID(index)
	f:SetWidth(18)
	f:SetHeight(18)
	f:SetScript("OnClick", function(self) NeuronGUI:setBarActionState(self) end)
	f.text:SetText(L["Custom"])
	f.option = "custom"
	f:SetPoint("TOPLEFT", frame.custom, "TOPLEFT", 10, -10)
	tinsert(barOpt.sec, f)


	f = CreateFrame("EditBox", "$parentRemap", frame.presets, "NeuronDropDownOptionFull")
	f:SetWidth(165)
	f:SetHeight(25)
	f:SetTextInsets(7,3,0,0)
	f.text:SetText(L["Select a stance to remap:"])
	f:SetPoint("BOTTOMLEFT",frame.presets, "BOTTOMLEFT", 7, 8)
	f:SetPoint("BOTTOMRIGHT", frame.presets.secondary, "BOTTOM", -70, -35)
	f:SetScript("OnTextChanged", function(self) NeuronGUI:remapOnTextChanged(self) end)
	f:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	f.popup:ClearAllPoints()
	f.popup:SetPoint("BOTTOMLEFT")
	f.popup:SetPoint("BOTTOMRIGHT")
	barOpt.remap = f

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("EditBox", "$parentRemapTo", frame.presets, "NeuronDropDownOptionFull")
	f:SetWidth(160)
	f:SetHeight(25)
	f:SetTextInsets(7,3,0,0)
	f.text:SetText(L["Remap selected stance to:"])
	f:SetPoint("BOTTOMLEFT", barOpt.remap, "BOTTOMRIGHT", 25, 0)
	f:SetPoint("BOTTOMRIGHT", frame.presets.secondary, "BOTTOMRIGHT", -23, -35)
	f:SetScript("OnTextChanged", function(self) NeuronGUI:remapToOnTextChanged(self) end)
	f:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	f.popup:ClearAllPoints()
	f.popup:SetPoint("BOTTOMLEFT")
	f.popup:SetPoint("BOTTOMRIGHT")
	barOpt.remapto = f

	--Custom State Tabs
	f = frame.custom
	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	f.text:SetPoint("TOPLEFT", frame.custom, "TOPLEFT", 10, -60)
	f.text:SetPoint("TOPRIGHT", frame.custom, "TOPRIGHT", -10, -60)
	f.text:SetJustifyH("CENTER")
	f.text:SetText(L["Custom_Option"])
	f.text:SetWordWrap(true)

	f = CreateFrame("EditBox", "$parentCostomStateEdit", frame.custom, "NeuronEditBoxTemplateSmall")
	--f:SetWidth(550)
	f:SetHeight(26)
	f:SetPoint("TOPLEFT", frame.custom, "TOPLEFT", 10, -30)
	f:SetPoint("TOPRIGHT", frame.custom, "TOPRIGHT", -10, -30)
	f:SetJustifyH("LEFT")
	f:SetTextInsets(10, 0, 0, 0)
	f:SetMaxLetters(0)

	f:SetScript("OnEnterPressed", frame.updateCustomState)
	f:SetScript("OnTabPressed", frame.updateCustomState)
	f:SetScript("OnEscapePressed", frame.updateCustomState)
	frame.search = f

	barOpt.customstate = f

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)
end


function NeuronGUI:VisEditor_OnLoad(frame)
	local f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTabTemplate")
	f:SetWidth(160)
	f:SetHeight(25)
	f:SetPoint("BOTTOMLEFT", frame, "TOPLEFT",5,-5)
	f:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT",-5,-5)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetBackdrop({
		bgFile = "Interface\\AddOns\\Neuron\\Images\\UI-Panel-Tab-Background",
		edgeFile = "Interface\\AddOns\\Neuron\\Images\\UI-Tooltip-Border",
		tile = false,
		tileSize = 24,
		edgeSize = 16,
		insets = {left = 5, right = 5, top = 5, bottom = 5},})

	f:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
	--f:SetBackdropColor(0.7,0.7,0.7,1)
	f:SetBackdropColor(1,1,1,1)
	--f:SetBackdropColor(0.3,0.3,0.3,1)
	f.text:SetText(L["Bar Visibility Toggles"])
	f.selected = true

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(f)
end


local numVisShown = 50

function NeuronGUI:VisEditorScrollFrame_OnLoad(frame)

	frame.offset = 0
	frame.scrollChild = _G[frame:GetName().."ScrollChildFrame"]

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	local anchor, button, lastButton, rowButton, count = false, false, false, false, 1

	for i=1,numVisShown do

		button = CreateFrame("CheckButton", frame:GetName().."Button"..i, frame:GetParent(), "NeuronOptionsCheckButtonTemplate")

		button.frame = frame:GetParent()
		button.numShown = numVisShown
		button:SetCheckedTexture("Interface\\Addons\\Neuron\\Images\\RoundCheckGreen.tga")
		button:SetScript("OnClick", function(self) NeuronGUI:setBarVisability(self) end)


		button:SetScript("OnShow",
			function(self)
				self:SetHeight((self.frame:GetHeight()-10)/self.numShown)
			end)


		button:SetWidth(18)
		button:SetHeight(18)
		button:SetHitRectInsets(0, 0, 0, 0)

		button:SetFrameLevel(frame:GetFrameLevel()+2)

		if (not anchor) then
			button:SetPoint("TOPLEFT", 10, -8)
			anchor = button; lastButton = button
		elseif (count == 11) then
			button:SetPoint("LEFT", anchor, "RIGHT", 125, 0)
			anchor = button; lastButton = button; count = 1
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -6)
			lastButton = button
		end
		count = count + 1
	end

	NeuronGUI.VisEditorScrollFrameUpdate()
end

local VisSTateList = {}

function NeuronGUI:VisEditorScrollFrameUpdate(frame, tableList, alt)

	if (not NeuronBarEditorBarStatesVisEditor:IsVisible()) then return end
	local bar = Neuron.CurrentBar

	if (not tableList) then

		wipe(VisSTateList)

		tableList = NEURON.STATES
	end

	if (not frame) then
		frame = NeuronBarEditorBarStatesVisEditorScrollFrame
	end

	local dataOffset, count, data = FauxScrollFrame_GetOffset(frame), 1, {}
	local button, text

	for k in pairs(tableList) do
		local val = k:match("%d+$")

		if (val and (k ~= "custom0"))then
			--Messy workaround to not have 2 stealths for rogues
			if ((k == "stealth0" or k == "stealth1") and (NEURON.class == "ROGUE")) then

			else
				data[count] = k; count = count + 1
			end
		end
	end

	table.sort(data)


	local customStateData = {}
	--This adds cusom states to the visability menu,  currently disabled untill I get custom state visability to work
	--[[

        if (bar and bar.cdata.customNames) then
                local i = 0
                for index,state in pairs(bar.cdata.customNames) do
                data[count] = state; count = count + 1
                customStateData[state] = i; i=i+1
                end
            end
    ]]--
	frame:Show()

	for i=1,numVisShown do

		button = _G["NeuronBarEditorBarStatesVisEditorScrollFrameButton"..i]
		button:SetChecked(nil)

		count = dataOffset + i

		if (data[count]) then

			text = NEURON.STATES[data[count]] or data[count]

			if customStateData[data[count]] then
				button.msg ="custom "..customStateData[data[count]]
				button:SetChecked(not bar.gdata.hidestates:find("custom"..customStateData[data[count]]))
			else
				button.msg = data[count]:match("%a+").." "..data[count]:match("%d+$")
				button:SetChecked(not bar.gdata.hidestates:find(data[count]))
			end

			--Renames rogues stance0 from Melee to No stealth for the view states list
			if (data[count] == "stance0"  and NEURON.class == "ROGUE") then
				text = L["No Stealth"]
			end

			button.text:SetText(text)

			button:Enable()
			button:Show()
			button:SetWidth(18)
			button:SetHeight(18)
		else

			button:Hide()
		end
	end

	FauxScrollFrame_Update(frame, #data, numVisShown, 18)
end


function NeuronGUI:StateList_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

end


local numStatesShown = 20

function NeuronGUI:SecondaryPresetsScrollFrame_OnLoad(frame)

	frame.offset = 0
	frame.scrollChild = _G[frame:GetName().."ScrollChildFrame"]

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	local anchor, button, lastButton, rowButton, count = false, false, false, false, 1

	for i=1,numStatesShown do
		button = CreateFrame("CheckButton", "PresetsScrollFrameButton"..i, frame:GetParent(), "NeuronOptionsCheckButtonTemplate")

		button.frame = frame:GetParent()
		button.numShown = numStatesShown
		button:SetScript("OnClick", function(self) NeuronGUI:setBarActionState(self) end)


		button:SetScript("OnShow",
			function(self)
				self:SetHeight((self.frame:GetHeight()-10)/self.numShown)
			end)

		--f = CreateFrame("CheckButton", nil, frame.visscroll, "NeuronOptionsCheckButtonTemplate")
		--f:SetID(index)
		button:SetWidth(18)
		button:SetHeight(18)
		button:SetHitRectInsets(0, 0, 0, 0)

		--button:SetID(i)
		button:SetFrameLevel(frame:GetFrameLevel()+2)

		if (not anchor) then
			button:SetPoint("TOPLEFT", 10, -8)
			anchor = button; lastButton = button
		elseif (count == 5) then
			button:SetPoint("LEFT", anchor, "RIGHT", 90, 0)
			anchor = button; lastButton = button; count = 1
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -8)
			lastButton = button
		end
		count = count + 1
	end

	NeuronGUI.SecondaryPresetsScrollFrameUpdate()
end

local SecondaryPresetsList = {}

function NeuronGUI:SecondaryPresetsScrollFrameUpdate(frame, stateList, alt)

	if (not NeuronBarEditorBarStatesActionEditor:IsVisible()) then return end
	local bar = Neuron.CurrentBar

	if (not stateList) then

		wipe(SecondaryPresetsList)

		stateList = NEURON.MANAGED_ACTION_STATES
	end

	if (not frame) then
		frame = NeuronBarEditorBarStatesActionEditorPresetsSecondaryScrollFrame
	end

	local statesOffset, states = FauxScrollFrame_GetOffset(frame), {}
	local button, text

	local count = 1

	for k,v in pairs(stateList) do

		if (not MAS[k].homestate and (k ~= "extrabar") and (k ~= "custom") ) then --or ((NEURON.class == "ROGUE") and k ~= "stealth")
			states[count] = k
			count = count + 1
		end
	end

	--Might want to add some checks for states like stealth for classes that don't have stealth. But for now it doesn't break anything to have it show generically

	table.sort(states)

	frame:Show()

	for i=1,numStatesShown do

		button = _G["PresetsScrollFrameButton"..i] --"NeuronBarEditorBarStatesSecondaryPresetsScrollFrameButton"..i]
		button:SetChecked(nil)

		count = statesOffset + i

		if (states[count]) then
			text = MAS[states[count]].localizedName --:upper()

			button.option = states[count]
			button:SetChecked(bar.cdata[button.option ])
			button.text:SetText(text)

			button:Enable()
			button:Show()
			button:SetWidth(18)
			button:SetHeight(18)

		else

			button:Hide()
		end
	end

	FauxScrollFrame_Update(frame, #states, numStatesShown, 18)
end

function NeuronGUI:BarStates_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

end

--- OnLoad event for Bar editor Spell Target Options frame
function NeuronGUI:TargetOptions_OnLoad(frame)
	--Container Support
	local content = CreateFrame("Frame",nil, frame)
	content:SetPoint("TOPLEFT",10,-5 )
	content:SetPoint("BOTTOMRIGHT",-10,5)
	--This creats a cusomt AceGUI container which lets us imbed a AceGUI menu into our frame.
	local widget = {
		frame     = frame,
		content   = content,
		type      = "NeuronContainer"
	}
	widget["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end

	NeuronBarEditor.ACEmenu = widget
	NeuronAceGUI:RegisterAsContainer(widget)
	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)
end




-- OnLoad event for Bar editor Spell Target Options frame
-- This need a lot of work
function NeuronGUI:FlyoutOptions_OnLoad(frame)
	--NeuronButtonEditor.options
	--Container Support
	local content = CreateFrame("Frame",nil, NeuronButtonEditor.options)
	content:SetPoint("TOPLEFT",10,-5 )
	content:SetPoint("BOTTOMRIGHT",-10,5)
	--This creats a cusomt AceGUI container which lets us imbed a AceGUI menu into our frame.
	local widget = {
		frame     = NeuronButtonEditor.options,
		content   = content,
		type      = "NeuronContainer"
	}
	widget["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end

	NeuronButtonEditor.ACEmenu = widget
	NeuronAceGUI:RegisterAsContainer(widget)
	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

end



function NeuronGUI:ObjectEditor_OnLoad(frame)

	NeuronGUI:SubFramePlainBackdrop_OnLoad(frame)

	frame:RegisterForDrag("LeftButton", "RightButton")
	frame.bottom = 0

	frame:SetHeight(height)
end

function NeuronGUI:ObjectEditor_OnShow(frame)

	for k,v in pairs(NEURON.Editors) do
		v[1]:Hide()
	end

	if (NEURON.CurrentObject) then

		local objType = NEURON.CurrentObject.objType

		if (NEURON.Editors[objType]) then

			local editor = NEURON.Editors[objType][1]

			editor:SetParent(frame)
			editor:SetAllPoints(frame)
			editor:Show()

			NOE:SetWidth(NEURON.Editors[objType][2])
			NOE:SetHeight(NEURON.Editors[objType][3])
		end
	end
end

function NeuronGUI:ObjectEditor_OnHide(frame)

end

function NeuronGUI:ActionList_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

end

function NeuronGUI:ActionListScrollFrame_OnLoad(frame)

	frame.offset = 0
	frame.scrollChild = _G[frame:GetName().."ScrollChildFrame"]

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	local button, lastButton, rowButton, count = false, false, false, 0

	for i=1,numShown do

		button = CreateFrame("CheckButton", frame:GetName().."Button"..i, frame:GetParent(), "NeuronScrollFrameButtonTemplate")

		button.frame = frame:GetParent()
		button.numShown = numShown
		button.elapsed = 0

		button:SetScript("OnClick",

			function(self)

				NeuronButtonEditor.macroedit.edit:ClearFocus()

				local button

				for i=1,numShown do

					button = _G["NeuronBarEditorBarListScrollFrameButton"..i]

					if (i == self:GetID()) then

						if (self.bar) then
							NEURON.NeuronBar:SetFauxState(self.bar, self.state)
						end

					else
						button:SetChecked(nil)
					end

				end

			end)

		button:SetScript("OnEnter",
			function(self)

			end)

		button:SetScript("OnLeave",
			function(self)

			end)

		button:SetScript("OnShow",
			function(self)
				self.elapsed = 0; self.setheight = true
			end)

		button:SetScript("OnUpdate",

			function(self,elapsed)

				self.elapsed = self.elapsed + elapsed

				if (self.setheight and self.elapsed > 0.03) then
					self:SetHeight((self.frame:GetHeight()-10)/self.numShown)
					self.setheight = nil
				end
			end)

		button.name = button:CreateFontString(button:GetName().."Index", "ARTWORK", "GameFontNormalSmall")
		button.name:SetPoint("TOPLEFT", button, "TOPLEFT", 5, 0)
		button.name:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 0)
		button.name:SetJustifyH("LEFT")

		button:SetID(i)
		button:SetFrameLevel(frame:GetFrameLevel()+2)
		button:SetNormalTexture("")

		if (not lastButton) then
			button:SetPoint("TOPLEFT", 8, -5)
			button:SetPoint("TOPRIGHT", -15, -5)
			lastButton = button
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 0)
			button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", 0, 0)
			lastButton = button
		end

	end

	NeuronGUI:ActionListScrollFrameUpdate()
end

local stateList = {}

function NeuronGUI:ActionListScrollFrameUpdate(frame)
	if (not NeuronButtonEditorActionList:IsVisible()) then return end

	local bar, i

	if (NEURON.CurrentObject and NEURON.CurrentObject.bar) then

		wipe(stateList)

		bar = NEURON.CurrentObject.bar

		stateList["00"..L["Home State"]] = "homestate"

		for state, values in pairs(MAS) do
			if (bar.cdata[state]) then
				for index, name in pairs(NEURON.STATES) do
					if (index ~= "laststate" and name ~= ATTRIBUTE_NOOP and values.states:find(index)) then

						i = index:match("%d+")

						if (i) then
							i = values.order..i
						else
							i = values.order
						end

						if (values.homestate and index == values.homestate) then
							stateList["00"..name] = "homestate"; stateList["00"..L["Home State"]] = nil
						elseif (values.order < 10) then
							stateList["0"..i..name] = index
						else
							stateList[i..name] = index
						end
					end
				end
			end
		end

	else
		wipe(stateList)
	end

	if (not frame) then
		frame = NeuronButtonEditorActionListScrollFrame
	end

	local dataOffset, count, data = FauxScrollFrame_GetOffset(frame), 1, {}
	local button, text

	for k in pairs(stateList) do
		data[count] = k; count = count + 1
	end

	table.sort(data)

	if (bar and bar.cdata.customNames) then
		local i = 0
		for index,state in pairs(bar.cdata.customNames) do
			stateList[state] = index
			data[count] = state; count = count + 1
		end
	end

	frame:Show()

	frame.buttonH = frame:GetHeight()/numShown

	for i=1,numShown do

		button = _G["NeuronButtonEditorActionListScrollFrameButton"..i]
		button:SetChecked(nil)

		count = dataOffset + i

		if (data[count]) then

			text = data[count]

			if (bar and stateList[text] == bar.handler:GetAttribute("fauxstate")) then
				button:SetChecked(1)
			end

			button.bar = bar
			button.state = stateList[text]
			button.name:SetText(text:gsub("^%d+",""))
			button:Enable()
			button:Show()

			button.name:SetTextColor(1,0.82,0)
			button.name:SetJustifyH("CENTER")

		else

			button:Hide()
		end
	end

	FauxScrollFrame_Update(frame, #data, numShown, 2)
end

--TODO REVISIT & CLEAN
--- Sets button icon based on current specoveride setting
-- @param button
-- @param data:
-- @returns: Button texture
function NeuronGUI:specUpdateIcon(button,state)
	--data = button.specdata[buttonSpec][state]
	--specUpdateIcon(button, data))--button.iconframeicon:GetTexture())
	--((button.bar.cdata.multiSpec and specoveride) or 1)
	--data.macro_Icon
	local texture = "" --"INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	local buttonSpec = GetSpecialization()
	local data = button.specdata[specoveride][state]

	if (button.bar.cdata.multiSpec and specoveride ~= buttonSpec) then
		local spell = data.macro_Text:match("/cast%s+(%C+)") or
				data.macro_Text:match("/use%s+(%C+)") or
				data.macro_Text:match("/summonpet%s+(%C+)") or
				data.macro_Text:match("/equipset%s+(%C+)")
				or data.macro_Text

		if (data.macro_Text:match("/cast%s+(%C+)")) then
			spell = (spell):lower()
			if (sIndex[spell]) then
				local spell_id = sIndex[spell].spellID
				texture = GetSpellTexture(spell_id)
			elseif (cIndex[spell]) then
				texture = cIndex[spell].icon
			elseif (spell) then
				texture = GetSpellTexture(spell)
			end

		elseif ItemCache[spell] then
			texture = GetItemIcon("item:"..ItemCache[spell]..":0:0:0:0:0:0:0")
		end

	else
		texture = button.iconframeicon:GetTexture()
	end
	return texture
end


function NeuronGUI:MacroEditorUpdate()
	if (NEURON.CurrentObject and NEURON.CurrentObject.objType == "ACTIONBUTTON") then
		local button, NBTNE = NEURON.CurrentObject, NeuronButtonEditor
		local state = button.bar.handler:GetAttribute("fauxstate")
		local buttonSpec = GetSpecialization()

		if (button.bar.cdata.multiSpec) then
			buttonSpec = specoveride

			--Sets spec tab to current spec
			NBTNE.spec1:SetChecked(nil)
			NBTNE.spec2:SetChecked(nil)
			NBTNE["spec"..buttonSpec]:SetChecked(true)

			--Sets current spec marker to proper tab
			NBTNE.activespc:SetParent(NBTNE["spec"..GetSpecialization()])
			NBTNE.activespc:SetPoint("LEFT")
			NBTNE.spec1:Show()
			NBTNE.spec2:Show()
			NBTNE.spec3:Show()
			local player_Class = select(2, UnitClass("player"))

			if (player_Class == "DEMONHUNTER") then
				NBTNE.spec1:SetWidth(104)
				NBTNE.spec2:SetWidth(104)
				NBTNE.savestate:SetPoint("LEFT", NBTNE.spec2, "RIGHT", 0, 0)
				NBTNE.spec3:Hide()
				NBTNE.spec4:Hide()
			elseif (player_Class == "DRUID") then
				NBTNE.spec1:SetWidth(62)
				NBTNE.spec2:SetWidth(62)
				NBTNE.spec3:SetWidth(62)
				NBTNE.spec4:SetWidth(62)
				NBTNE.spec4:Show()
				NBTNE.savestate:SetPoint("LEFT", NBTNE.spec4, "RIGHT", 0, 0)
				NBTNE.savestate:SetWidth(62)
			else
				NBTNE.spec4:Hide()
			end
		else
			buttonSpec = 1
			NBTNE.spec1:Hide()
			NBTNE.spec2:Hide()
			NBTNE.spec3:Hide()
			NBTNE.spec4:Hide()
		end

		local data = button.specdata[buttonSpec][state]

		if not data then
			button.specdata[buttonSpec][state] = NEURON.NeuronButton:MACRO_build()

			data = button.specdata[buttonSpec][state]
			NEURON.NeuronFlyouts:UpdateFlyout(button)
			NEURON.NeuronButton:BuildStateData(button)
			button:SetType()
		end

		if (data) then
			NBTNE.macroedit.edit:SetText(data.macro_Text)
			if (not data.macro_Icon) then
				NBTNE.macroicon.icon:SetTexture(NeuronGUI:specUpdateIcon(button, state))--button.iconframeicon:GetTexture())
			elseif (data.macro_Icon == "BLANK") then
				NBTNE.macroicon.icon:SetTexture("")
			else
				NBTNE.macroicon.icon:SetTexture(data.macro_Icon)
			end
			--NEURON:Print(data.macro_Name)
			NBTNE.nameedit:SetText(data.macro_Name)
			NBTNE.noteedit:SetText(data.macro_Note)
			NBTNE.usenote:SetChecked(data.macro_UseNote)

		else
			--NEURON:Print("notinghere")
			--button.specdata[buttonSpec][state] = NEURON.NeuronButton:MACRO_build()
			--NEURON.NeuronButton:MACRO_build(button.specdata[buttonSpec][state])
			---NEURON:Print(button.specdata[buttonSpec][state])
			--end
		end
	end
end

function NeuronGUI:ButtonEditorUpdate(reset)

	if (reset and NEURON.CurrentObject) then

		local bar = NEURON.CurrentObject.bar

		bar.handler:SetAttribute("fauxstate", bar.handler:GetAttribute("activestate"))

		NeuronButtonEditor.macroicon.icon:SetTexture("")

		specoveride = GetSpecialization() or 1 --GetActiveSpecGroup()
	end

	NeuronGUI:ActionListScrollFrameUpdate()

	NeuronGUI:MacroEditorUpdate()

end

function NeuronGUI:ButtonEditor_OnShow(frame)

	NeuronGUI:ButtonEditorUpdate(true)

end

function NeuronGUI:ButtonEditor_OnHide(frame)


end


--- Triggers when macro editor's text box loses focus
-- @param self: macro editor frame
function NeuronGUI:macroText_OnEditFocusLost()

	self.hasfocus = nil

	local button = NEURON.CurrentObject

	if (button) then

		NEURON.NeuronFlyouts:UpdateFlyout(button)
		NEURON.NeuronButton:BuildStateData(button)
		button:SetType()

		NeuronGUI:MacroEditorUpdate()
	end
end


--- Triggers when text in the  macro editor changes
-- @param self: macro editor frame
function NeuronGUI:macroText_OnTextChanged(frame)

	if (frame.hasfocus) then
		local button = NEURON.CurrentObject
		local buttonSpec = ((button.bar.cdata.multiSpec and specoveride) or 1)
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and buttonSpec and state) then
			if button.specdata[buttonSpec][state] then
				button.specdata[buttonSpec][state].macro_Text = frame:GetText()
				button.specdata[buttonSpec][state].macro_Watch = false
			else
				--NEURON:Print("notinghere")
				--button.specdata[buttonSpec][state] = NEURON.NeuronButton:MACRO_build()
				--NEURON.NeuronButton:MACRO_build(button.specdata[buttonSpec][state])
				--NEURON:Print(button.specdata[buttonSpec][state])
			end

		end
	end
end

--- Triggers when text in the  macro editor changes
-- @param self: macro editor frame
function NeuronGUI:macroButton_Changed(frame, button, down)

	local object = NEURON.CurrentObject

	local data = object.data
	local buttonSpec = ((object.bar.cdata.multiSpec and specoveride) or 1)
	local state = object.bar.handler:GetAttribute("fauxstate")

	--handler to check if viewing non current spec button settings
	if (specoveride ~= GetSpecialization()) then
		data = object.specdata[buttonSpec][state]
	end

	if (object and data) then

		if (frame.texture == "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") then
			data.macro_Icon = false
		else
			data.macro_Icon = frame.texture
		end
		NEURON.NeuronButton:MACRO_UpdateIcon(object)

		NeuronGUI:UpdateObjectGUI()
	end

	frame:SetFrameLevel(frame.fl-1)
	frame.click = true
	frame.elapsed = 0
	frame:GetParent():Hide()
	frame:SetChecked(nil)

end


--- Triggers when the text in the macro editor's name text box changes
-- @param self: macro editor name edit box frame
function NeuronGUI:macroNameEdit_OnTextChanged(frame)

	if (strlen(frame:GetText()) > 0) then
		frame.text:Hide()
	end

	if (frame.hasfocus) then

		local button = NEURON.CurrentObject
		local buttonSpec = ((button.bar.cdata.multiSpec and specoveride) or 1)
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and buttonSpec and state) then
			button.specdata[buttonSpec][state].macro_Name = frame:GetText()
		end

	elseif (strlen(frame:GetText()) <= 0) then
		frame.text:Show()
	end
end


--- Triggers when the text in the macro editor's note text box changes
-- @param self: macro editor note edit box frame
function NeuronGUI:macroNoteEdit_OnTextChanged(frame)

	if (strlen(frame:GetText()) > 0) then
		frame.text:Hide()
		frame.cb:Show()
	else
		frame.cb:Hide()
	end

	if (frame.hasfocus) then

		local button = NEURON.CurrentObject
		local buttonSpec = ((button.bar.cdata.multiSpec and specoveride) or 1)
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and buttonSpec and state) then
			button.specdata[buttonSpec][state].macro_Note = frame:GetText()
		end
	end
end


--TODO Revisit & Check description
--- Triggers when macro editor loses focus
-- @param self: macro editor frame
function NeuronGUI:macroOnEditFocusLost(frame)
	frame.hasfocus = nil

	local button = NEURON.CurrentObject

	if (button) then
		NEURON.NeuronButton:MACRO_UpdateAll(button, true)
	end

	if (frame.text and strlen(frame:GetText()) <= 0) then
		frame.text:Show()
	end
end

function NeuronGUI:macroIconOnClick(frame)

	if (frame.iconlist:IsVisible()) then
		frame.iconlist:Hide()
	else
		frame.iconlist:Show()
	end

	if frame.SetChecked then
		frame:SetChecked(nil)
	end


end



local IconList = {}

function NeuronGUI:updateIconList()

	wipe(IconList)
	-- We need to avoid adding duplicate spellIDs from the spellbook tabs for your other specs.
	local activeIcons = {};

	for i = 1, GetNumSpellTabs() do
		local tab, tabTex, offset, numSpells, _ = GetSpellTabInfo(i);
		offset = offset + 1;
		local tabEnd = offset + numSpells;
		for j = offset, tabEnd - 1 do
			--to get spell info by slot, you have to pass in a pet argument
			local spellType, ID = GetSpellBookItemInfo(j, "player");
			if (spellType ~= "FUTURESPELL") then
				local fileID = GetSpellBookItemTexture(j, "player");
				if (fileID) then
					activeIcons[fileID] = true;
				end
			end
			if (spellType == "FLYOUT") then
				local _, _, numSlots, isKnown = GetFlyoutInfo(ID);
				if (isKnown and numSlots > 0) then
					for k = 1, numSlots do
						local spellID, overrideSpellID, isKnown = GetFlyoutSlotInfo(ID, k)
						if (isKnown) then
							local fileID = GetSpellTexture(spellID);
							if (fileID) then
								activeIcons[fileID] = true;
							end
						end
					end
				end
			end
		end
	end

	local iconListTemp = {};
	for fileDataID in pairs(activeIcons) do
		iconListTemp[#iconListTemp + 1] = fileDataID;
	end

	local search
	if (NeuronButtonEditor.search) then
		search = NeuronButtonEditor.search:GetText()
		if (strlen(search) < 1) then
			search = nil
		end
	end


	GetLooseMacroIcons( iconListTemp );
	GetLooseMacroItemIcons( iconListTemp );
	GetMacroIcons( iconListTemp );
	GetMacroItemIcons( iconListTemp );

	for index, icon in ipairs(iconListTemp) do
		if (search) then

			--I don't know what this does or why it is important, but we want to avoid GetFileName at all costs, and this doesn't appear to break anything.
			local icon_path
			local x = GetItemInfo(icon)
			local y = GetSpellInfo(icon)


			if (x) then
				icon_path = x
			elseif(y) then
				icon_path = y
			else
				icon_path = icon
			end
			if (icon_path and type(icon_path)~="number" and icon_path:lower():find(search:lower())) then
				--if (icon_path:lower():find(search:lower()) or index == 1) then
				tinsert(IconList, icon)
			end
		else
			tinsert(IconList, icon)
		end
	end

end


function NeuronGUI:MacroIconListUpdate(frame)

	if (not frame) then
		frame = NeuronButtonEditor.iconlist
	end

	local numIcons, offset, index, texture, blankSet = #IconList+1, FauxScrollFrame_GetOffset(frame)

	for i,btn in ipairs(frame.buttons) do

		index = (offset * 14) + i

		texture = IconList[index]

		if (index < numIcons) then

			btn.icon:SetTexture(texture)
			btn:Show()
			btn.texture = texture

		elseif (not blankSet) then

			btn.icon:SetTexture("")
			btn:Show()
			btn.texture = "BLANK"
			blankSet = true

		else
			btn.icon:SetTexture("")
			btn:Hide()
			btn.texture = ICONS[1]
		end

	end

	FauxScrollFrame_Update(frame, math.ceil(numIcons/14), 1, 1, nil, nil, nil, nil, nil, nil, true)

end


function NeuronGUI:customPathOnShow(frame)

	local button = NEURON.CurrentObject

	if (button) then

		if (button.data.macro_Icon) then
			--Needs fixing
			local text = button.data.macro_Icon:gsub("INTERFACE\\", "")

			frame:SetText(text)

		else
			frame:SetText("")
		end
	else
		frame:SetText("")
	end

	frame:SetCursorPosition(0)
end

function NeuronGUI:customDoneOnClick(frame)

	local button = NEURON.CurrentObject

	if (button) then

		local text = frame.frame.custompath:GetText()

		if (#text > 0) then

			text = "INTERFACE\\"..text:gsub("\\", "\\")

			button.data.macro_Icon = text

			NEURON.NeuronButton:MACRO_UpdateIcon(button)

			NeuronGUI:UpdateObjectGUI()
		end
	end

	frame:GetParent():Hide()
end

--Resets all the fields in the editor for the curently selected buttton
function NeuronGUI:ResetButtonFields()
	local button, NBTNE = NEURON.CurrentObject, NeuronButtonEditor
	local state = button.bar.handler:GetAttribute("fauxstate")
	local buttonSpec = ((button.bar.cdata.multiSpec and specoveride) or 1)
	local data = button.specdata[buttonSpec][state]

	data.actionID = false
	data.macro_Text = ""
	data.macro_Icon = false
	data.macro_Name = ""
	data.macro_Auto = false
	data.macro_Watch = false
	data.macro_Equip = false
	data.macro_Note = ""

	NBTNE.nameedit:SetText("")
	NBTNE.noteedit:SetFocus()
	NBTNE.noteedit:SetText("")
	NBTNE.macroedit.edit:SetFocus()
	NBTNE.macroedit.edit:SetText("")
	NBTNE.macroedit.edit:ClearFocus()
end


function NeuronGUI:ButtonEditor_OnLoad(frame)

	---Helper functions that depend on the parent's "frame"
	local function SpecOnClick(cTab, silent)

		for tab, panel in pairs(frame.specs) do

			if (tab == cTab) then
				tab:SetChecked(1)
				if (MouseIsOver(cTab)) then
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
				end
			else
				tab:SetChecked(nil)
			end
			tab:SetBackdropBorderColor(.5, .5, .5 , .5)

		end
	end

	local function TabsOnClick(cTab, silent)

		for tab, panel in pairs(frame.tabs) do

			if (tab == cTab) then
				tab:SetChecked(1)
				if (MouseIsOver(cTab)) then
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
				end
				panel:Show()
			else
				tab:SetChecked(nil)
				panel:Hide()
			end

		end
	end
	frame:RegisterForDrag("LeftButton", "RightButton")

	NEURON.Editors.ACTIONBUTTON[1] = frame
	NEURON.Editors.ACTIONBUTTON[4] = self.ButtonEditorUpdate

	frame.tabs = {}
	frame.specs = {}

	local f

	f = CreateFrame("Frame", nil, frame)
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -10)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then NeuronGUI:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f.elapsed = 0
	frame.macro = f

	f = CreateFrame("ScrollFrame", "$parentMacroEditor", frame.macro, "NeuronScrollFrameTemplate2")
	f:SetPoint("TOPLEFT", frame.macro, "TOPLEFT", 2, -95)
	f:SetPoint("BOTTOMRIGHT", -2, 20)
	f.edit:SetWidth(350)
	f.edit:SetHeight(300)
	f.edit:SetScript("OnTextChanged", function(self) NeuronGUI:macroText_OnTextChanged(self) end)
	f.edit:SetScript("OnEditFocusGained", function(self) self.hasfocus = true self:SetText(self:GetText():gsub("#autowrite\n", "")) end)
	f.edit:SetScript("OnEditFocusLost", function(self)NeuronGUI:macroText_OnEditFocusLost(self) end)
	frame.macroedit = f

	f = CreateFrame("Button", "focus", frame.macro)
	f:SetPoint("TOPLEFT", frame.macroedit, "TOPLEFT", -10, 10)
	f:SetPoint("BOTTOMRIGHT", -18, 0)
	f:SetWidth(350)
	f:SetHeight(300)
	f:SetScript("OnClick", function(self) self.macroedit.edit:SetFocus() end)
	f.macroedit = frame.macroedit
	frame.macrofocus = f

	f = CreateFrame("Frame", nil, frame.macroedit)
	f:SetPoint("TOPLEFT", -10, 10)
	f:SetPoint("BOTTOMRIGHT", 4, -20)
	f:SetFrameLevel(frame.macroedit.edit:GetFrameLevel()-1)
	frame.macroeditBG = f

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronMacroIconButtonTemplate")
	f:SetID(0)
	f:SetPoint("BOTTOMLEFT", frame.macroedit, "TOPLEFT", -6, 15)
	f:SetWidth(54)
	f:SetHeight(54)
	f:SetScript("OnEnter", function() end)
	f:SetScript("OnLeave", function() end)
	f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	f.slot:SetVertexColor(0.5,0.5,0.5,1)
	f.onclick_func = function(self) NeuronGUI:macroIconOnClick(self) end
	f.onupdate_func = function() end
	f.elapsed = 0
	f.click = false
	f.parent = frame
	f.iconlist = frame.iconlist
	f.iconlist:SetScript("OnShow", function(self) self.scrollbar.scrollStep = 1 NeuronObjectEditor.done:Hide() NeuronGUI:updateIconList() NeuronGUI:MacroIconListUpdate(self) end)
	f.iconlist:SetScript("OnHide", function() NeuronObjectEditor.done:Show() end)
	frame.macroicon = f

	f = CreateFrame("Button", nil, frame.macro)
	f:SetPoint("BOTTOMLEFT", frame.macroicon, "BOTTOMRIGHT", 2, -7)
	f:SetWidth(34)
	f:SetHeight(34)
	--f:SetScript("OnClick", function(self) SetActiveSpecGroup(GetActiveSpecGroup() == 1 and 2 or 1);  end)
	f:SetScript("OnClick", function(self) NeuronGUI:ResetButtonFields(self) end)
	f:SetScript("OnEnter", function(self)
		if ( self.tooltipText ) then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tooltipText)
		end
		GameTooltip:Show();
	end)
	f:SetScript("OnLeave", function(self)
		GameTooltip:Hide();
	end)
	f:SetNormalTexture("Interface\\AddOns\\Neuron\\Images\\UI-RotationRight-Button-Up")
	f:SetPushedTexture("Interface\\AddOns\\Neuron\\Images\\UI-RotationRight-Button-Down")
	f:SetHighlightTexture("Interface\\AddOns\\Neuron\\Images\\UI-Common-MouseHilight")
	f.tooltipText = _G.RESET
	frame.reset_button = f


	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronCheckButtonTemplate1")
	f:SetWidth(68)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.reset_button, "RIGHT", -1, 1.25)
	f:SetScript("OnClick", function(self) SpecOnClick(self); specoveride = 1 ; NeuronGUI:ButtonEditorUpdate() end)
	f:SetChecked(nil)
	f.text:SetText("Spec1")
	f.tooltipText = L["Display button for specialization 1"]
	frame.spec1 = f; frame.specs[f] = frame.spec1

	f = CreateFrame("frame", nil, frame.spec1)
	f:SetWidth(20)
	f:SetHeight(20)
	f:SetPoint("LEFT",10)
	f.texture = f:CreateTexture(nil, "OVERLAY")
	f.texture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	f.texture:SetAlpha(1)
	f.texture:SetAllPoints()
	f:Show()
	frame.activespc = f

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronCheckButtonTemplate1")
	f:SetWidth(68)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.spec1, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) SpecOnClick(self); specoveride = 2 ; NeuronGUI:ButtonEditorUpdate() end)
	f:SetChecked(nil)
	f.text:SetText("Spec2")
	f.tooltipText = L["Display button for specialization 2"]
	frame.spec2 = f; frame.specs[f] = frame.spec2

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronCheckButtonTemplate1")
	f:SetWidth(68)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.spec2, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) SpecOnClick(self); specoveride = 3 ; NeuronGUI:ButtonEditorUpdate() end)
	f:SetChecked(nil)
	f.text:SetText("Spec3")
	f.tooltipText = L["Display button for specialization 3"]
	frame.spec3 = f; frame.specs[f] = frame.spec3

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronCheckButtonTemplate1")
	f:SetWidth(68)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.spec3, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) SpecOnClick(self); specoveride = 4 ; NeuronGUI:ButtonEditorUpdate() end)
	f:SetChecked(nil)
	f.text:SetText("Spec4")
	f.tooltipText = L["Display button for specialization 4"]
	frame.spec4 = f; frame.specs[f] = frame.spec4

	f = CreateFrame("Button", nil, frame.macro, "UIPanelButtonTemplate")--"NeuronCheckButtonTemplate1")
	f:SetWidth(104)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.spec3, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self)
		frame.macroedit.edit:ClearFocus()
		frame.nameedit:ClearFocus()
		frame.noteedit:ClearFocus()
	end)
	f:SetText(_G.SAVE)
	f.tooltipText = _G.SAVE
	frame.savestate = f

	f = CreateFrame("EditBox", nil, frame.macro)
	f:SetMultiLine(false)
	f:SetNumeric(false)
	f:SetAutoFocus(false)
	f:SetTextInsets(5,5,5,5)
	f:SetFontObject("GameFontHighlight")
	f:SetJustifyH("CENTER")
	f:SetPoint("TOPLEFT", frame.macroicon, "TOPRIGHT", 5, 3.5)
	f:SetPoint("BOTTOMRIGHT", frame.macroeditBG, "TOP", -18, 32)
	f:SetScript("OnTextChanged", function(self) NeuronGUI:macroNameEdit_OnTextChanged(self) end)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() end NeuronGUI:macroOnEditFocusLost(self) end)
	f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame.nameedit = f

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	f.text:SetPoint("CENTER")
	f.text:SetJustifyH("CENTER")
	f.text:SetText(L["Macro Name"])

	f = CreateFrame("Frame", nil, frame.nameedit)
	f:SetPoint("TOPLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", 0, 0)
	f:SetFrameLevel(frame.nameedit:GetFrameLevel()-1)

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("EditBox", nil, frame.macro)
	f:SetMultiLine(false)
	f:SetMaxLetters(50)
	f:SetNumeric(false)
	f:SetAutoFocus(false)
	f:SetJustifyH("CENTER")
	f:SetJustifyV("CENTER")
	f:SetTextInsets(5,5,5,5)
	f:SetFontObject("GameFontHighlightSmall")
	f:SetPoint("TOPLEFT", frame.nameedit, "TOPRIGHT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", frame.macroeditBG, "TOPRIGHT",-16, 32)
	f:SetScript("OnTextChanged", function(self) NeuronGUI:macroNoteEdit_OnTextChanged(self) end)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() end NeuronGUI:macroOnEditFocusLost(self) end)
	f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame.noteedit = f

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	f.text:SetPoint("CENTER", 10, 0)
	f.text:SetJustifyH("CENTER")
	f.text:SetText(L["Click here to edit macro note"])

	f = CreateFrame("Frame", nil, frame.noteedit)
	f:SetPoint("TOPLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", 15, 0)
	f:SetFrameLevel(frame.noteedit:GetFrameLevel()-1)

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronOptionsCheckButtonTemplate")
	f:SetID(0)
	f:SetWidth(16)
	f:SetHeight(16)
	f:SetScript("OnShow", function() end)
	f:SetScript("OnClick", function() end)
	f:SetPoint("RIGHT", frame.noteedit, "RIGHT", 12, 0)
	f:SetFrameLevel(frame.noteedit:GetFrameLevel()+1)
	f:Hide()
	f.tooltipText = L["Use macro note as button tooltip"]
	frame.usenote = f
	frame.noteedit.cb = f

	frame.iconlist.buttons = {}

	local count, x, y = 0, 28, -16

	for i=1,112 do

		f = CreateFrame("CheckButton", nil, frame.iconlist, "NeuronMacroIconButtonTemplate")
		f:SetID(i)
		f:SetFrameLevel(frame.iconlist:GetFrameLevel()+2)
		f.slot:SetVertexColor(0.5,0.5,0.5,1)
		f:SetScript("OnEnter", function(self)
			self.fl = self:GetFrameLevel()
			self:SetFrameLevel(self.fl+1)
			self:GetNormalTexture():SetPoint("TOPLEFT", -7, 7)
			self:GetNormalTexture():SetPoint("BOTTOMRIGHT", 7, -7)
			self.slot:SetPoint("TOPLEFT", -10, 10)
			self.slot:SetPoint("BOTTOMRIGHT", 10, -10)
		end)
		f:SetScript("OnLeave", function(self)
			self:SetFrameLevel(self.fl)
			self:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
			self:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
			self.slot:SetPoint("TOPLEFT", -2, 2)
			self.slot:SetPoint("BOTTOMRIGHT", 2, -2)
		end)
		f.onclick_func = function(self, button, down)
			NeuronGUI:macroButton_Changed(self, button, down)
		end

		count = count + 1

		f:SetPoint("CENTER", frame.iconlist, "TOPLEFT", x, y)

		if (count == 14) then
			x = 28; y = y - 35; count = 0
		else
			x = x + 35.5
		end

		tinsert(frame.iconlist.buttons, f)

	end

	f = CreateFrame("EditBox", nil, frame.iconlist, "NeuronEditBoxTemplateSmall")
	f:SetWidth(378)
	f:SetHeight(30)
	f:SetJustifyH("LEFT")
	f:SetTextInsets(22, 0, 0, 0)
	f:SetPoint("TOPLEFT", 8, 36)
	f:SetScript("OnShow", function(self) self:SetText("") end)
	f:SetScript("OnEnterPressed", function(self) NeuronGUI:updateIconList(); NeuronGUI:MacroIconListUpdate(); self:ClearFocus(); self.hasfocus = nil; end)
	f:SetScript("OnTabPressed", function(self) NeuronGUI:updateIconList(); NeuronGUI:MacroIconListUpdate(); self:ClearFocus(); self.hasfocus = nil; end)
	f:SetScript("OnEscapePressed", function(self) self:SetText(""); NeuronGUI:updateIconList(); NeuronGUI:MacroIconListUpdate(); self:ClearFocus(); self.hasfocus = nil; end)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.cancel:Show() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() self.cancel:Hide() end self.hasfocus = nil end)
	f:SetScript("OnTextChanged", function(self) if (strlen(self:GetText()) < 1 and not self.hasfocus) then self.text:Show() self.cancel:Hide() end end)
	frame.search = f

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)

	f.cancel = CreateFrame("Button", nil, f)
	f.cancel:SetWidth(20)
	f.cancel:SetHeight(20)
	f.cancel:SetPoint("RIGHT", -3, 0)
	f.cancel:SetScript("OnClick", function(self) self.parent:SetText("") NeuronGUI:updateIconList() NeuronGUI:MacroIconListUpdate()  self.parent:ClearFocus() self.parent.hasfocus = nil end)
	f.cancel:Hide()
	f.cancel.tex = f.cancel:CreateTexture(nil, "OVERLAY")
	f.cancel.tex:SetTexture("Interface\\FriendsFrame\\ClearBroadcastIcon")
	f.cancel.tex:SetAlpha(0.7)
	f.cancel.tex:SetAllPoints()
	f.cancel.parent = f

	f.searchicon = f:CreateTexture(nil, "OVERLAY")
	f.searchicon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
	f.searchicon:SetPoint("LEFT", 6, -2)

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontDisable");
	f.text:SetPoint("LEFT", 22, 0)
	f.text:SetJustifyH("LEFT")
	f.text:SetText(L["Search"])

	f = CreateFrame("Button", nil, frame.iconlist, "NeuronCheckButtonTemplate1")
	f:SetWidth(122)
	f:SetHeight(35)
	f:SetPoint("TOPLEFT", frame.search, "TOPRIGHT", -1, 4)
	f:SetScript("OnClick", function(self) self:Hide() self.frame.search:Hide() self.frame.customdone:Show() self.frame.customcancel:Show() self.frame.custompath:Show() end)
	f.text:SetText(L["Custom Icon"])
	f.frame = frame
	frame.customicon = f

	f = CreateFrame("Button", nil, frame.iconlist, "NeuronCheckButtonTemplate1")
	f:SetWidth(60)
	f:SetHeight(35)
	f:SetPoint("TOPLEFT", frame.search, "TOPRIGHT", -1, 4)
	f:SetScript("OnClick", function(self) self:Hide()  self.frame.customcancel:Hide() self.frame.custompath:Hide() self.frame.customicon:Show() self.frame.search:Show() NeuronGUI:customDoneOnClick(self) end)
	f:SetFrameLevel(frame.customicon:GetFrameLevel()+1)
	f:Hide()
	f.text:SetText(L["Done"])
	f.frame = frame
	frame.customdone = f

	f = CreateFrame("Button", nil, frame.iconlist, "NeuronCheckButtonTemplate1")
	f:SetWidth(60)
	f:SetHeight(35)
	f:SetPoint("LEFT", frame.customdone, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) self:Hide() self.frame.customdone:Hide() self.frame.custompath:Hide() self.frame.customicon:Show() self.frame.search:Show() end)
	f:SetFrameLevel(frame.customicon:GetFrameLevel()+1)
	f:Hide()
	f.text:SetText(L["Cancel"])
	f.frame = frame
	frame.customcancel = f

	f = CreateFrame("EditBox", nil, frame.iconlist, "NeuronEditBoxTemplateSmall")
	f:SetWidth(378)
	f:SetHeight(30)
	f:SetJustifyH("LEFT")
	f:SetPoint("TOPLEFT",  frame.search, "TOPLEFT", 0, 0)
	f:SetScript("OnShow", function(self) NeuronGUI:customPathOnShow(self) end)
	--f:SetFrameLevel(frame.search:GetFrameLevel()+1)
	f:Hide()
	f:SetScript("OnEscapePressed", function(self) NeuronGUI:ButtonEditorIconList_ResetCustom(self.frame) end)
	f:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	--f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.cancel:Show() self.hasfocus = true end)
	--f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() self.cancel:Hide() end self.hasfocus = nil end)
	f:SetScript("OnTextChanged", function(self) self:SetText(self:GetText():upper()) end)
	f.frame = frame
	frame.custompath = f

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	f.text:SetPoint("LEFT", 8, 0)
	f.text:SetJustifyH("LEFT")
	f.text:SetText(L["Path"]..": INTERFACE\\")

	f:SetTextInsets(f.text:GetWidth()+5, 0, 0, 0)


	f = CreateFrame("Frame", nil, frame)
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -10)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then NeuronGUI:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f:Hide()
	f.elapsed = 0
	frame.action = f

	f = CreateFrame("Frame", nil, frame)
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -25)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then NeuronGUI:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f:SetScript("OnShow", function(self) LibStub("AceConfigDialog-3.0"):Open("Neuron-Flyout", NBTNE.ACEmenu) end)
	f:Hide()
	f.elapsed = 0
	frame.options = f

	---  /flyout <types>:<keys>:<shape>:<attach point>:<relative point>:<columns|radius>:<click|mouse>
	--[[
        f = CreateFrame("EditBox", nil, frame.options)
        f:SetMultiLine(false)
        f:SetNumeric(false)
        f:SetAutoFocus(false)
        f:SetTextInsets(5,5,5,5)
        f:SetFontObject("GameFontHighlight")
        f:SetJustifyH("CENTER")
        f:SetPoint("TOPLEFT", frame.options, "TOPRIGHT", 5, 3.5)
        f:SetPoint("BOTTOMRIGHT", frame.options, "TOP", -18, 32)
        --f:SetScript("OnTextChanged", macroNameEdit_OnTextChanged)
        f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.hasfocus = true end)
        ---f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() end macroOnEditFocusLost(self) end)
        f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
        frame.flyoutKey = f

        f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
        f.text:SetPoint("CENTER")
        f.text:SetJustifyH("CENTER")
        f.text:SetText("dsfgdfgsdf")

        f = CreateFrame("Frame", nil, frame.flyoutkey)
        f:SetPoint("TOPLEFT", 0, 0)
        f:SetPoint("BOTTOMRIGHT", 0, 0)
        f:SetFrameLevel(frame.flyoutKey:GetFrameLevel()-1)

        NEURON.SubFrameBlackBackdrop_OnLoad(f)
    ]]--


	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(150)
	f:SetHeight(28)
	f:SetPoint("TOPRIGHT", frame, "TOPLEFT", 287, -10)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(1)
	f.text:SetText(L["Macro Data"])
	frame.tab1 = f; frame.tabs[f] = frame.macro


	local f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(150)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab1, "RIGHT", 150, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText(L["Flyout Options"])
	frame.tab2 = f; frame.tabs[f] = frame.options

	--[[f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(125)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab3, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText(L["Action Data"])
	frame.tab2 = f; frame.tabs[f] = frame.action]]



end

function NeuronGUI:ButtonEditorIconList_ResetCustom(frame)

	frame.customdone:Hide()
	frame.customcancel:Hide()
	frame.custompath:Hide()

	--frame.search:Show()
	frame.customicon:Show()

end


function NeuronGUI:ColorPicker_OnLoad(frame)

	frame:SetFrameStrata("TOOLTIP")
	frame.apply.text:SetText(L["Apply"])
	frame.cancel.text:SetText(L["Cancel"])
end


function NeuronGUI:ColorPicker_OnShow(frame)

	local r,g,b = frame:GetColorRGB()
	frame.redvalue:SetText(r); frame.redvalue:SetCursorPosition(0)
	frame.greenvalue:SetText(g); frame.greenvalue:SetCursorPosition(0)
	frame.bluevalue:SetText(b); frame.bluevalue:SetCursorPosition(0)
	frame.hexvalue:SetText(string.upper(string.format("%02x%02x%02x", math.ceil((r*255)), math.ceil((g*255)), math.ceil((b*255))))); frame.hexvalue:SetCursorPosition(0)
end

function NeuronGUI:ColorPicker_OnColorSelect(frame, r, g, b)
	frame.redvalue:SetText(r)
	frame.greenvalue:SetText(g)
	frame.bluevalue:SetText(b)
	frame.hexvalue:SetText(string.upper(string.format("%02x%02x%02x", math.ceil((r*255)), math.ceil((g*255)), math.ceil((b*255)))))
end

function NeuronGUI:MainMenu_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

	frame:SetWidth(width)
	frame:SetHeight(height)

	--frame:RegisterEvent("ADDON_LOADED")
	frame:RegisterForDrag("LeftButton", "RightButton")

end

--not an optimal solution, but it works for now
function NeuronGUI:hookHandler(handler)

	handler:HookScript("OnAttributeChanged", function(self,name,value)

		if(NEURON.CurrentObject) then
			if (NeuronObjectEditor:IsVisible() and self == NEURON.CurrentObject.bar.handler and name == "activestate" and not NeuronButtonEditor.macroedit.edit.hasfocus) then
				NeuronButtonEditor.macro.elapsed = 0
			end
		end

	end)
end

function NeuronGUI:runUpdater(elapsed)

	self.elapsed = elapsed

	if (self.elapsed > 0) then

		NeuronGUI:UpdateBarGUI()
		NeuronGUI:UpdateObjectGUI()

		self:Hide()
	end
end



function NeuronGUI:hookMountButtons()

	if (MountJournal.ListScrollFrame.buttons) then

		for i,btn in pairs(MountJournal.ListScrollFrame.buttons) do
			btn.DragButton:HookScript("OnClick", NeuronGUI:modifiedMountClick())
		end
	end
end

function NeuronGUI:hookPetJournalButtons()

	if (PetJournal.listScroll.buttons) then

		for i,btn in pairs(PetJournal.listScroll.buttons) do
			btn.dragButton:HookScript("OnClick", NeuronGUI:modifiedPetJournalClick())
		end
	end
end







--- ACE GUI OPTION GET & SET FUnctions
-- @param self: macro editor frame
function NeuronGUI:settingGetter(info)
	if NEURON.CurrentBar then
		return NEURON.CurrentBar.cdata[ info[#info]]
	end
end


function NeuronGUI:SetBarCastTarget(value, toggle)
	if NEURON.CurrentBar then
		NEURON.NeuronBar:SetCastingTarget(NEURON.CurrentBar, value, true, toggle)
	end
end

--/flyout s+,i+:teleport,!drake:linear:top:bottom:1:click
local FLYOUTMACRO = {
	["types"] = { ["item"] = "item"},
	["keys"] = "",
	["shape"] = "LINEAR",
	["attach"] = "TOP",
	["relative"] = "BOTTOM",
	["columns"] = 3,
	["mouse"] = "CLICK",
}

local flyouttypes = {}
function NeuronGUI:flyoutSetter(info, value)
	FLYOUTMACRO[info[#info]]= value
end

function NeuronGUI:flyoutTypeSetter(info, value)
	if value then
		FLYOUTMACRO["types"][info[#info]]= value
	else
		FLYOUTMACRO["types"][info[#info]] = nil
	end
end

function NeuronGUI:flyoutTypeGetter(info)
	return FLYOUTMACRO["types"][info[#info]]
end


function NeuronGUI:flyoutGetter(info)
	return FLYOUTMACRO[info[#info]]
end


local finalmacro = ""


function NeuronGUI:createflyoutmacro()
	local macrotypes = ""
	for name,value in pairs(FLYOUTMACRO["types"]) do
		macrotypes = macrotypes..","..name
	end

	finalmacro = "/flyout "..macrotypes..":"..FLYOUTMACRO["keys"]..":"..FLYOUTMACRO["shape"]..":"..FLYOUTMACRO["attach"]..":"..FLYOUTMACRO["relative"]..":"..FLYOUTMACRO["columns"]..":"..FLYOUTMACRO["mouse"]
end


--ACE GUI OPTION TABLE for Bar Targeting
NeuronGUI.target_options = {
	name = "Neuron-GUI",
	type = 'group',
	args = {
		selfCast = {
			order = 10,
			type = "toggle",
			name = L["Self-Cast by modifier"],
			desc = L["Toggle the use of the modifier-based self-cast functionality."],
			get = function(info)  return NeuronGUI:settingGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:SetBarCastTarget("selfCast", value) end,
		},
		setselfcastmod = {
			order = 20,
			type = "select",
			name = L["Self-Cast by modifier"],
			desc = L["Select the Self-Cast Modifier"],
			get = function(info) return GetModifiedClick("SELFCAST") end,
			set = function(info, value) SetModifiedClick("SELFCAST", value); SaveBindings(GetCurrentBindingSet() or 1); NEURON.NeuronButton:UpdateMacroCastTargets(true) end,
			values = { NONE = _G.NONE, ALT = _G.ALT_KEY_TEXT, SHIFT = _G.SHIFT_KEY_TEXT, CTRL = _G.CTRL_KEY_TEXT },
		},
		selfcast_nl = {
			order = 30,
			type = "description",
			name = "",
		},
		focusCast = {
			order = 50,
			type = "toggle",
			name = L["Focus-Cast by modifier"],
			desc = L["Toggle the use of the modifier-based focus-cast functionality."],
			get = function(info)  return NeuronGUI:settingGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:SetBarCastTarget("focusCast", value) end,
		},
		setfocuscastmod = {
			order = 60,
			type = "select",
			name = L["Focus-Cast by modifier"],
			desc = L["Select the Focus-Cast Modifier"],
			get = function(info) return GetModifiedClick("FOCUSCAST") end,
			set = function(info, value) SetModifiedClick("FOCUSCAST", value); SaveBindings(GetCurrentBindingSet() or 1); NEURON.NeuronButton:UpdateMacroCastTargets(true) end,
			values = { NONE = _G.NONE, ALT = _G.ALT_KEY_TEXT, SHIFT = _G.SHIFT_KEY_TEXT, CTRL = _G.CTRL_KEY_TEXT },
		},
		focuscast_nl = {
			order = 70,
			type = "description",
			name = "",
		},
		rightClickTarget = {
			order = 80,
			type = "toggle",
			name = L["Right-click Self-Cast"],
			desc = L["Toggle the use of the right-click self-cast functionality."],
			get = function(info)  return NeuronGUI:settingGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:SetBarCastTarget("rightClickTarget", value) end,
		},
		rightclickselfcast_nl = {
			order = 90,
			type = "description",
			name = "",
		},
		mouseOverCast = {
			order = 180,
			type = "toggle",
			name = L["Mouse-Over Casting"],
			desc = L["Toggle the use of the modifier-based mouse-over cast functionality."],
			get = function(info)  return NeuronGUI:settingGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:SetBarCastTarget("mouseOverCast", value) end,
		},
		mouseovermod = {
			order = 301,
			type = "select",
			name = L["Mouse-Over Casting Modifier"],
			desc = L["Select a modifier for Mouse-Over Casting"],
			get = function() return NeuronCDB.mouseOverMod end, --getFunc,
			set = function(info, value) NeuronCDB.mouseOverMod = value; NEURON.NeuronButton:UpdateMacroCastTargets(true) end,
			values = { NONE = _G.NONE, ALT = _G.ALT_KEY_TEXT, SHIFT = _G.SHIFT_KEY_TEXT, CTRL = _G.CTRL_KEY_TEXT },
		},
		mouseovermod_desc = {
			order = 302,
			type = "description",
			name = "\n" .. L["Spell_Targeting_Modifier_None_Reminder"],
		},
	} ,
}

NeuronGUI.flyout_options = {
	name = "Flyout-Options",
	type = 'group',
	args = {

		item = {
			order = 10,
			type = "toggle",
			name = L["Item"],
			get = function(info)  return NeuronGUI:flyoutTypeGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutTypeSetter(info, value) end,
		},
		spell = {
			order = 10,
			type = "toggle",
			name = L["Spell"],
			get = function(info)  return NeuronGUI:flyoutTypeGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutTypeSetter(info, value) end,
		},
		mount = {
			order = 10,
			type = "toggle",
			name = L["Mount"],
			get = function(info)  return NeuronGUI:flyoutTypeGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutTypeSetter(info, value) end,
		},
		companion = {
			order = 10,
			type = "toggle",
			name = L["Companion"],
			get = function(info)  return NeuronGUI:flyoutTypeGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutTypeSetter(info, value) end,
		},
		types = {
			order = 10,
			type = "toggle",
			name = L["Type"],
			get = function(info)  return NeuronGUI:flyoutTypeGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutTypeSetter(info, value) end,
		},
		profession = {
			order = 10,
			type = "toggle",
			name = L["Profession"],
			get = function(info)  return NeuronGUI:flyoutTypeGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutTypeSetter(info, value) end,
		},
		fun = {
			order = 10,
			type = "toggle",
			name = L["Fun"],
			get = function(info)  return NeuronGUI:flyoutTypeGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutTypeSetter(info, value) end,
		},
		favorite = {
			order = 10,
			type = "toggle",
			name = L["Favorite"],
			get = function(info)  return NeuronGUI:flyoutTypeGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutTypeSetter(info, value) end,
		},

		keys = {
			order = 11,
			type = "input",
			name = L["Keys"],
			get = function(info)  return NeuronGUI:flyoutGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutSetter(info, value) end,
		},
		shape = {
			order = 12,
			type = "select",
			name = L["Shape"],
			get = function(info)  return NeuronGUI:flyoutGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutSetter(info, value) end,
			values = { LINEAR = "Linear", CIRCULAR = "Circular" },
		},
		attach = {
			order = 13,
			type = "select",
			name = L["Attach Point"],
			get = function(info)  return NeuronGUI:flyoutGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutSetter(info, value) end,
			values = { LEFT = L["Left"], RIGHT = L["Right"],TOP = L["Top"], BOTTOM = L["Bottom"],TOPLEFT = L["Top-Left"], TOPRIGHT = L["Top-Right"], BOTTOMLEFT = L["Bottom-Left"], BOTTOMRIGHT = L["Bottom-Right"], CENTER = L["Center"] },
		},
		relative = {
			order = 14,
			type = "select",
			name = L["Relative To"]..":",
			get = function(info)  return NeuronGUI:flyoutGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutSetter(info, value) end,
			values = { LEFT = L["Left"], RIGHT = L["Right"],TOP = L["Top"], BOTTOM = L["Bottom"],TOPLEFT = L["Top-Left"], TOPRIGHT = L["Top-Right"], BOTTOMLEFT = L["Bottom-Left"], BOTTOMRIGHT = L["Bottom-Right"], CENTER = L["Center"] },
		},
		columns = {
			order = 15,
			type = "range",
			name = L["Columns"].."/"..L["Radius"],
			min = -25,
			max = 25,
			step = 1,
			get = function(info) return NeuronGUI:flyoutGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutSetter(info, value) end,
		},
		mouse = {
			order = 16,
			type = "select",
			name = L["Show On"]..":",
			get = function(info)  return NeuronGUI:flyoutGetter(info) end, --getFunc,
			set = function(info, value) NeuronGUI:flyoutSetter(info, value) end,
			values = { CLICK = L["Click"], MOUSE = L["Mouseover"] },

		},
		generate = {
			order = 17,
			type = "execute",
			name = L["Generate Macro"],
			func = function() NeuronGUI:createflyoutmacro() end,
		},
		output = {
			order = 18,
			type = "input",
			name = L["Copy and Paste the text below"]..":",
			get = function(info) return finalmacro end,
			width = "full"
		},
	},


}




--ACE GUI OPTION TABLE
NeuronGUI.interfaceOptions = {
	name = "Neuron",
	type = 'group',
	args = {
		moreoptions={
			name = L["Options"],
			type = "group",
			order = 0,
			args={
				BlizzardBar = {
					order = 1,
					name = L["Display the Blizzard Bar"],
					desc = L["Shows / Hides the Default Blizzard Bar"],
					type = "toggle",
					set = function() NEURON:BlizzBar() end,
					get = function() return NeuronGDB.mainbar end,
					width = "full",
				},
				NeuronMinimapButton = {
					order = 2,
					name = L["Display Minimap Button"],
					desc = L["Toggles the minimap button."],
					type = "toggle",
					set =  function() NEURON.NeuronMinimapIcon:ToggleIcon() end,
					get = function() return not NeuronGDB.NeuronIcon.hide end,
					width = "full"
				},
			},
		},

		changelog = {
			name = L["Changelog"],
			type = "group",
			order = 1000,
			args = {
				line1 = {
					type = "description",
					name = L["Changelog_Latest_Version"],
				},
			},
		},

		faq = {
			name = L["F.A.Q."],
			desc = L["Frequently Asked Questions"],
			type = "group",
			order = 1001,
			args = {

				line1 = {
					type = "description",
					name = L["FAQ_Intro"],
				},

				g1 = {
					type = "group",
					name = L["Bar Configuration"],
					order = 1,
					args = {

						line1 = {
							type = "description",
							name = L["Bar_Configuration_FAQ"],
							order = 1,
						},

						g1 = {
							type = "group",
							name = L["General Options"],
							order = 1,
							args = {
								line1 = {
									type = "description",
									name = L["General_Bar_Configuration_Option_FAQ"] ,
									order = 1,
								},
							},
						},

						g2 = {
							type = "group",
							name = L["Bar States"],
							order = 2,
							args = {
								line1 = {
									type = "description",
									name = L["Bar_State_Configuration_FAQ"],
									order = 1,
								},
							},
						},

						g3 = {
							type = "group",
							name = L["Spell Target Options"],
							order = 3,
							args = {
								line1 = {
									type = "description",
									name = L["Spell_Target_Options_FAQ"],
									order = 1,
								},
							},
						},
					},
				},

				g2 = {
					type = "group",
					name = L["Flyout"],
					order = 3,
					args = {
						line1a = {
							type = "description",
							name = L["Flyout_FAQ"],
							order = 1,
						},
					},
				},

			},
		},
	},
}






NEURON.Editors = {}

----------------------------------------------------------------------------
--------------------------Object Editor-------------------------------------
----------------------------------------------------------------------------

function NeuronGUI:ObjEditor_OnShow(editor)

	local object = editor.object

	if (object) then

		if (object.bar) then
			editor:SetFrameLevel(object.bar:GetFrameLevel()+1)
		end
	end
end

function NeuronGUI:ObjEditor_OnHide(editor)


end

function NeuronGUI:ObjEditor_OnEnter(editor)

	editor.select:Show()

	GameTooltip:SetOwner(editor, "ANCHOR_RIGHT")

	GameTooltip:Show()

end

function NeuronGUI:ObjEditor_OnLeave(editor)

	if (editor.object ~= NEURON.CurrentObject) then
		editor.select:Hide()
	end

	GameTooltip:Hide()

end

function NeuronGUI:ObjEditor_OnClick(editor, button)

	local newObj, newEditor = NEURON.NeuronButton:ChangeObject(editor.object)

	if (button == "RightButton") then

		if (NeuronObjectEditor) then
			if (not newObj and NeuronObjectEditor:IsVisible()) then
				NeuronObjectEditor:Hide()
			elseif (newObj and newEditor) then
				NEURON.NeuronGUI:ObjectEditor_OnShow(NeuronObjectEditor); NeuronObjectEditor:Show()
			else
				NeuronObjectEditor:Show()
			end
		end

	elseif (newObj and newEditor and NeuronObjectEditor:IsVisible()) then
		NEURON.NeuronGUI:ObjectEditor_OnShow(NeuronObjectEditor); NeuronObjectEditor:Show()
	end

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		NEURON.NeuronGUI:UpdateObjectGUI()
	end
end

function NeuronGUI:ObjEditor_ACTIONBAR_SHOWGRID(editor)

	if (not InCombatLockdown() and editor:IsVisible()) then
		editor:Hide()
		editor.showgrid = true
	end

end

function NeuronGUI:ObjEditor_ACTIONBAR_HIDEGRID(editor)

	if (not InCombatLockdown() and editor.showgrid) then
		editor:Show()
		editor.showgrid = nil
	end

end

function NeuronGUI:ObjEditor_OnEvent(editor, eventName, ...)

	local event = "ObjEditor_".. eventName

	if (NeuronGUI[event]) then
		NeuronGUI[event](NeuronGUI, editor, ...)
	end

end



function NeuronGUI:ObjEditor_CreateEditFrame(button, index)

	local EDITOR = CreateFrame("Button", button:GetName().."EditFrame", button, "NeuronEditFrameTemplate")

	setmetatable(EDITOR, { __index = CreateFrame("Button") })

	EDITOR:EnableMouseWheel(true)
	EDITOR:RegisterForClicks("AnyDown")
	EDITOR:SetAllPoints(button)
	EDITOR:SetScript("OnShow", function(self) NeuronGUI:ObjEditor_OnShow(self) end)
	EDITOR:SetScript("OnHide", function(self) NeuronGUI:ObjEditor_OnHide(self) end)
	EDITOR:SetScript("OnEnter", function(self) NeuronGUI:ObjEditor_OnEnter(self) end)
	EDITOR:SetScript("OnLeave", function(self) NeuronGUI:ObjEditor_OnLeave(self) end)
	EDITOR:SetScript("OnClick", function(self, button) NeuronGUI:ObjEditor_OnClick(self, button) end)
	EDITOR:SetScript("OnEvent", function(self, event, ...) NeuronGUI:ObjEditor_OnEvent(self, event, ...) end)
	EDITOR:RegisterEvent("ACTIONBAR_SHOWGRID")
	EDITOR:RegisterEvent("ACTIONBAR_HIDEGRID")

	EDITOR.type:SetText(L["Edit"])
	EDITOR.object = button
	EDITOR.editType = "button"

	button.OBJEDITOR = EDITOR

	EDITIndex["BUTTON"..index] = EDITOR

	EDITOR:Hide()

end