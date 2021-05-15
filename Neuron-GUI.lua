-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local addonName = ...

local DB, NMM, NBE, NOE, NBTNE, MAS

local width, height = 1000, 600

local barNames = {}

Neuron.NeuronGUI = Neuron:NewModule("GUI", "AceEvent-3.0", "AceHook-3.0")
local NeuronGUI = Neuron.NeuronGUI
local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")
local NeuronAceGUI = LibStub("AceGUI-3.0")

local GUIData = Neuron.registeredGUIData

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
	[18] = { "BORDERSTYLE", L["Show Border Style"], 1, "SetBorderStyle"},
}

local adjOptions = {
	[1] = { "SCALE", L["Scale"], 1, "ScaleBar", 0.01, 0.1, 4 },
	[2] = { "SHAPE", L["Shape"], 2, "ShapeBar", nil, nil, nil, Neuron.BarShapes },
	[3] = { "COLUMNS", L["Columns"], 1, "ColumnsSet", 1 , 0},
	[4] = { "ARCSTART", L["Arc Start"], 1, "ArcStartSet", 1, 0, 359 },
	[5] = { "ARCLENGTH", L["Arc Length"], 1, "ArcLengthSet", 1, 0, 359 },
	[6] = { "HPAD",L["Horiz Padding"], 1, "PadHSet", 0.5 },
	[7] = { "VPAD", L["Vert Padding"], 1, "PadVSet", 0.5 },
	[8] = { "HVPAD", L["H+V Padding"], 1, "PadHVSet", 0.5 },
	[9] = { "STRATA", L["Strata"], 2, "StrataSet", nil, nil, nil, Neuron.STRATAS },
	[10] = { "ALPHA", L["Alpha"], 1, "AlphaSet", 0.01, 0, 1 },
	[11] = { "ALPHAUP", L["AlphaUp"], 2, "AlphaUpSet", nil, nil, nil, Neuron.AlphaUps },
	[12] = { "ALPHAUP", L["AlphaUp Speed"], 1, "AlphaUpSpeedSet", 0.01, 0.01, 1, nil, "%0.0f", 100, "%" },
	[13] = { "XPOS", L["X Position"], 1, "XAxisSet", 1, nil, nil, nil, "%0.2f", 1, "" },
	[14] = { "YPOS", L["Y Position"], 1, "YAxisSet", 1, nil, nil, nil, "%0.2f", 1, "" },
}

local swatchOptions = {
	[1] = { "BINDTEXT", L["Keybind Label"], 1, "BindTextSet", true, nil, "bindColor" },
	[2] = { "MACROTEXT", L["Macro Name"], 1, "MacroTextSet", true, nil, "macroColor" },
	[3] = { "COUNTTEXT", L["Stack/Charge Count Label"], 1, "CountTextSet", true, nil, "countColor" },
	[4] = { "RANGEIND", L["Out-of-Range Indicator"], 1, "RangeIndSet", true, nil, "rangecolor" },
	[5] = { "CDTEXT", L["Cooldown Countdown"], 1, "CDTextSet", true, true, "cdcolor1", "cdcolor2" },
	[6] = { "CDALPHA", L["Cooldown Transparency"], 1, "CDAlphaSet", nil, nil },
}

local specoveride = Neuron.activeSpec

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

	DB = Neuron.db.profile

	MAS = Neuron.MANAGED_ACTION_STATES

	---This loads the Neuron interface panel
	LibStub("AceConfigRegistry-3.0"):ValidateOptionsTable(NeuronGUI.interfaceOptions, addonName)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, NeuronGUI.interfaceOptions)
	NeuronGUI.interfaceOptions.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Neuron.db)

	-- Per spec profiles
	if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC then
		local LibDualSpec = LibStub('LibDualSpec-1.0')
		LibDualSpec:EnhanceDatabase(Neuron.db, addonName) --enhance the database object with per spec profile features
		LibDualSpec:EnhanceOptions(NeuronGUI.interfaceOptions.args.profile, Neuron.db) -- enhance the profiles config panel with per spec profile features
	end


	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)


	--for the object
	---- editor
	Neuron.Editors.ACTIONBUTTON = { nil, 550, 350, nil }

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronGUI:OnEnable()

	for _,bar in pairs(Neuron.BARIndex) do
		NeuronGUI:hookHandler(bar.handler)
	end

	updater = CreateFrame("Frame", nil, UIParent)
	updater:SetScript("OnUpdate", function(self, elapsed) NeuronGUI:runUpdater(self, elapsed) end)
	updater.elapsed = 0
	updater:Hide()

	NeuronGUI:RegisterEvent("ADDON_LOADED")

	if not Neuron.isWoWClassic and not Neuron.isWoWClassic_TBC then
		NeuronGUI:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	end


	--LibStub("AceConfig-3.0"):RegisterOptionsTable("Neuron-GUI", NeuronGUI.target_options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Neuron-Flyout", NeuronGUI.flyout_options)

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronGUI:OnDisable()

end

-------------------------------------------------


function NeuronGUI:PLAYER_SPECIALIZATION_CHANGED()

	updater.elapsed = 0
	updater:Show()

end

function NeuronGUI:ADDON_LOADED(name)
	if name == "Blizzard_PetJournal" then
		NeuronGUI:hookMountButtons()
		NeuronGUI:hookPetJournalButtons()
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

	--[[frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetTexture("Interface\\AddOns\\Neuron\\Images\\honeycomb_small", true)
	frame.bg:SetVertexColor(0.65,0.65,0.65,1)
	frame.bg:SetPoint("TOPLEFT", 3, -3)
	frame.bg:SetPoint("BOTTOMRIGHT", -3, 3)
	frame.bg:SetHorizTile(true)
	frame.bg:SetVertTile(true)]]
end




function NeuronGUI:insertLink(text)

	local item = GetItemInfo(text)

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

--TODO: This should be moved to Neuron-GUI
function NeuronGUI:EditBox_PopUpInitialize(popupFrame, data)
	popupFrame.func = NeuronGUI.PopUp_Update
	popupFrame.data = data

	NeuronGUI:PopUp_Update(popupFrame)
end



function NeuronGUI:PopUp_Update(popupFrame)
	local data, count, height, width = popupFrame.data, 1, 0, 0
	local option, anchor, last, text

	if (popupFrame.options) then
		for k,v in pairs(popupFrame.options) do
			v.text:SetText(""); v:Hide()
		end
	end

	if (not popupFrame.array) then
		popupFrame.array = {}
	else
		wipe(popupFrame.array)
	end

	if (not data) then
		return
	end

	for k,v in pairs(data) do
		if (type(v) == "string") then
			popupFrame.array[count] = k..","..v
		else
			popupFrame.array[count] = k
		end
		count = count + 1
	end

	table.sort(popupFrame.array)

	for i=1,#popupFrame.array do
		popupFrame.array[i] = gsub(popupFrame.array[i], "%s+", " ")
		popupFrame.array[i] = gsub(popupFrame.array[i], "^%s+", "")

		if (not popupFrame.options[i]) then
			option = CreateFrame("Button", popupFrame:GetName().."Option"..i, popupFrame, "NeuronPopupButtonTemplate")
			option:SetHeight(20)

			popupFrame.options[i] = option
		else
			option = _G[popupFrame:GetName().."Option"..i]
			popupFrame.options[i] = option
		end

		text = popupFrame.array[i]:match("^[^,]+") or ""
		option:SetText(text:gsub("^%d+_", ""))
		option.value = popupFrame.array[i]:match("[^,]+$")

		if (option:GetTextWidth() > width) then
			width = option:GetTextWidth()
		end

		option:ClearAllPoints()

		if (not anchor) then
			option:SetPoint("TOP", popupFrame, "TOP", 0, -5); anchor = option
		else
			option:SetPoint("TOP", last, "BOTTOM", 0, -1)
		end

		last = option
		height = height + 21
		option:Show()
	end

	if (popupFrame.options) then
		for k,v in pairs(popupFrame.options) do
			v:SetWidth(width+40)
		end
	end

	popupFrame:SetWidth(width+40)

	if (height < popupFrame:GetParent():GetHeight()) then
		popupFrame:SetHeight(popupFrame:GetParent():GetHeight())
	else
		popupFrame:SetHeight(height + 10)
	end
end


-- This builds the string of any custom states in the order that they were originaly entered.
function NeuronGUI:generateCustomStateList(bar)
	local start = tonumber(string.match(bar.data.customRange, "^%d+"))
	local stop = tonumber(string.match(bar.data.customRange, "%d+$"))
	local customStateList = bar.data.customNames["homestate"]..";"

	for index = start, stop, 1 do
		customStateList = customStateList..bar.data.customNames["custom"..index]..";"
	end

	return customStateList
end

function NeuronGUI:UpdateBarGUI(newBar)

	NeuronGUI:BarListScrollFrameUpdate()

	local bar = Neuron.CurrentBar

	if (bar and GUIData[bar.class]) then

		if (NBE:IsVisible()) then
			NBE.count.text:SetText(L["Number of Buttons"]..": |cffffffff"..#bar.buttons.."|r")
			NBE.barname:SetText(bar.data.name)
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

					if (bar[f.func]) then
						if (f.primary) then
							if (f.primary:GetChecked()) then
								f:Enable()
								f:SetChecked(bar[f.func](bar, f.modtext, true, nil, true))
								f.text:SetTextColor(1,0.82,0)
								f.disabled = nil
							else
								f:SetChecked(false)
								f:Disable()
								f.text:SetTextColor(0.5,0.5,0.5)
								f.disabled = true
							end
						else
							f:SetChecked(bar[f.func](bar, f.modtext, true, nil, true))
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

				if (bar[f.func] and f.option == "SHAPE") then

					shape = bar[f.func](bar, nil, true, true)

					if (shape ~= L["Linear"]) then
						yoff1 = (adjHeight)/8
					end
				end

				if (f.optData) then

					wipe(popupData)

					for k,v in pairs(f.optData) do
						popupData[k.."_"..v] = tostring(k)
					end

					NeuronGUI:EditBox_PopUpInitialize(f.edit.popup, popupData)
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

				if (bar[f.func]) then

					f.edit.value = nil

					if (f.format) then
						f.edit:SetText(format(f.format, bar[f.func](bar, nil, true, true)*f.mult)..f.endtext)
					else
						f.edit:SetText(bar[f.func](bar, nil, true, true))
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

					if (bar[f.func]) then

						local checked, color1, color2 = bar[f.func](bar, f.modtext, true, nil, true)

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
				if (f.option == "stance" and ((GetNumShapeshiftForms() < 1 or Neuron.class == "DEATHKNIGHT" or Neuron.class == "PALADIN" or Neuron.class == "HUNTER"))) and not Neuron.class=="SHAMAN" then
					f:SetChecked(false)
					f:Disable()
					f.text:SetTextColor(0.5,0.5,0.5)
				else
					f:SetChecked(bar.data[f.option])
					f:Enable()
					f.text:SetTextColor(1,0.82,0)
				end
			end

			--Sets bar secondary options
			for i,f in ipairs(barOpt.sec) do

				if (f.stance ) then
					if (f.stance:GetChecked()) then
						f:SetChecked(bar.data[f.option])
						f:Enable()
						f.text:SetTextColor(1,0.82,0)
					else
						f:SetChecked(false)
						f:Disable()
						f.text:SetTextColor(0.5,0.5,0.5)
					end
				else
					f:SetChecked(bar.data[f.option])
				end
			end

			wipe(popupData)

			for state, value in pairs(Neuron.STATES) do

				if (bar.data.paged and state:find("paged")) then

					popupData[value] = state:match("%d+")

				elseif (bar.data.stance and state:find("stance")) then

					popupData[value] = state:match("%d+")

				end
			end

			NeuronGUI:EditBox_PopUpInitialize(barOpt.remap.popup, popupData)
			NeuronGUI:EditBox_PopUpInitialize(barOpt.remapto.popup, popupData)

			if (newBar) then
				barOpt.remap:SetText("")
				barOpt.remapto:SetText("")
			end
		end

		--Sets bar custom state options
		local customStateList = ""
		if (bar and bar.data.customNames) then

			customStateList = NeuronGUI:generateCustomStateList(bar)

		end

		barOpt.customstate:SetText(customStateList)
	end
	--Set visisbility buttons
	NeuronGUI:VisEditorScrollFrameUpdate()
	NeuronGUI:SecondaryPresetsScrollFrameUpdate()

	--LibStub("AceConfigDialog-3.0"):Open("Neuron-GUI", NBE.ACEmenu)

end


function NeuronGUI:UpdateObjectGUI(reset)

	for editor, data in pairs(Neuron.Editors) do
		if (data[1]:IsVisible()) then
			data[4](reset)
		end
	end
end


function NeuronGUI:updateBarName(frame)

	local bar = Neuron.CurrentBar

	if (bar) then

		bar.data.name = frame:GetText()

		bar.text:SetText(bar.data.name)

		frame:ClearFocus()

		NeuronGUI:BarListScrollFrameUpdate()
	end
end


function NeuronGUI:resetBarName(frame)
	local bar = Neuron.CurrentBar

	if (bar) then
		frame:SetText(bar.data.name)
		frame:ClearFocus()
	end
end

function NeuronGUI:resetMacroText(frame)
	local bar = Neuron.CurrentBar

	if (bar) then
		frame:SetText(bar.data.name)
		frame:ClearFocus()
	end
end

function NeuronGUI:updateCustomState(frame)
	local bar = Neuron.CurrentBar
	local state = frame:GetText()
	local customStateList = ""

	bar:SetState("custom", true, false)  --turns off custom state to clear any previous stored items
	if (bar and state ~= "") then
		bar:SetState("custom "..state, true, true)
	end

	if (bar and bar.data.customNames) then
		customStateList = NeuronGUI:generateCustomStateList(bar)
	end

	barOpt.customstate:SetText(customStateList)
	NeuronGUI.VisEditorScrollFrameUpdate()
	frame:ClearFocus()
end

function NeuronGUI:countOnMouseWheel(delta)

	local bar = Neuron.CurrentBar

	if (bar) then
		if (delta > 0) then
			bar:AddObjectsToBar()
		else
			bar:RemoveObjectsFromBar()
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

				tab:SetChecked(true)

				if (MouseIsOver(cTab)) then
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
				end

				panel:Show()

				NeuronGUI:UpdateBarGUI()
			else
				tab:SetChecked(false)
				panel:Hide()
			end

		end
	end

	local f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -28, -8.5)
	--f:SetScript("OnClick", function(self) TabsOnClick(self, true) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(false)
	--f.text:SetText(L["Spell Target Options"])
	frame.tab3 = f; frame.tabs[f] = frame.targetoptions

	local f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab3, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(false)
	f.text:SetText(L["Bar States"])
	frame.tab2 = f; frame.tabs[f] = frame.barstates

	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab2, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(true)
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

	f = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
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

	f = CreateFrame("Button", nil, frame.count, BackdropTemplateMixin and "BackdropTemplate")
	f:SetWidth(32)
	f:SetHeight(40)
	f:SetPoint("LEFT", text, "RIGHT", 10, -1)
	f:SetNormalTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionRight-Up")
	f:SetPushedTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionRight-Down")
	f:SetHighlightTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionRight-Highlight")
	f:SetScript("OnClick", function() if (Neuron.CurrentBar) then Neuron.CurrentBar:AddObjectsToBar() end end)

	f = CreateFrame("Button", nil, frame.count, BackdropTemplateMixin and "BackdropTemplate")
	f:SetWidth(32)
	f:SetHeight(40)
	f:SetPoint("RIGHT", text, "LEFT", -10, -1)
	f:SetNormalTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionLeft-Up")
	f:SetPushedTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionLeft-Down")
	f:SetHighlightTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionLeft-Highlight")
	f:SetScript("OnClick", function() if (Neuron.CurrentBar) then Neuron.CurrentBar:RemoveObjectsFromBar() end end)

end

function NeuronGUI:BarList_OnLoad(frame)

	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)

	frame:SetHeight(height-55)

end


local numShown = 14

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

									Neuron.BAR:CreateNewBar(self.bar)

									NeuronBarEditorCreate:Click()
								end

								self.alt = nil

							elseif (self.bar) then

								self.bar:ChangeBar()

								if (NBE and NBE:IsVisible()) then
									NeuronGUI:UpdateBarGUI()
								end

							end
						else
							button:SetChecked(false)
						end

					end

				end)

		button:SetScript("OnEnter",
				function(self)
					if (self.alt) then

					elseif (self.bar) then
						self.bar:OnEnter()
					end
				end)

		button:SetScript("OnLeave",
				function(self)
					if (self.alt) then

					elseif (self.bar) then
						self.bar:OnLeave()
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

		for _,bar in pairs(Neuron.BARIndex) do
			if (bar.data.name) then
				barNames[bar.data.name] = bar
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
		button:SetChecked(false)

		count = dataOffset + i

		if (data[count]) then

			text = data[count]

			if (tableList[text] == Neuron.CurrentBar) then
				button:SetChecked(true)
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


function NeuronGUI:BarEditor_CreateNewBar(button)
	if (button.type == "create") then

		local data = {} --{ [L["Select Bar Type"]] = "none" }

		for class,info in pairs(Neuron.registeredBarData) do

			data[info.barLabel] = class

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

	local bar = Neuron.CurrentBar

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

	local bar = Neuron.CurrentBar

	if (bar) then
		bar:DeleteBar()
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

	local bar = Neuron.CurrentBar

	if (bar and button.func) then
		bar[button.func](bar, button.modtext, true, button:GetChecked())
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

		table.insert(barOpt.chk, f)
	end
end

function NeuronGUI:adjOptionOnTextChanged(edit, frame)

	local bar = Neuron.CurrentBar

	if (bar) then

		if (frame.method == 1) then

		elseif (frame.method == 2 and edit.value) then

			bar[frame.func](bar, edit.value, true)

			edit.value = nil
		end
	end
end

function NeuronGUI:adjOptionOnEditFocusLost(edit, frame)

	edit.hasfocus = nil

	local bar = Neuron.CurrentBar

	if (bar) then

		if (frame.method == 1) then

			bar[frame.func](bar, edit:GetText(), true)

		elseif (frame.method == 2) then

		end
	end
end

function NeuronGUI:adjOptionAdd(frame, onupdate)

	local bar = Neuron.CurrentBar

	if (bar) then

		local num = bar[frame.func](bar, nil, true, true)

		if (num == L["Off"] or num == "---") then
			num = 0
		else
			num = tonumber(num)
		end

		if (num and frame.inc) then

			if (frame.max and num >= frame.max) then

				bar[frame.func](bar, frame.max, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(format(frame.format, frame.max*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(frame.max)
					end
				end
			else
				bar[frame.func](bar, num+frame.inc, true, nil, onupdate)

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

	local bar = Neuron.CurrentBar

	if (bar) then

		local num = bar[frame.func](bar, nil, true, true)

		if (num == L["Off"] or num == "---") then
			num = 0
		else
			num = tonumber(num)
		end

		if (num and frame.inc) then

			if (frame.min and num <= frame.min) then

				bar[frame.func](bar, frame.min, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(format(frame.format, frame.min*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(frame.min)
					end
				end
			else
				bar[frame.func](bar, num-frame.inc, true, nil, onupdate)

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


function NeuronGUI:NeuronAdjustOption_AddOnClick(frame, button, down)
	frame.elapsed = 0
	frame.pushed = frame:GetButtonState()

	if (not down) then
		if (frame:GetParent():GetParent().addfunc) then
			frame:GetParent():GetParent().addfunc(frame:GetParent():GetParent())
		end
	end
end



function NeuronGUI:NeuronAdjustOption_SubOnClick(frame, button, down)
	frame.elapsed = 0
	frame.pushed = frame:GetButtonState()

	if (not down) then
		if (frame:GetParent():GetParent().subfunc) then
			frame:GetParent():GetParent().subfunc(frame:GetParent():GetParent())
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

		table.insert(barOpt.adj, f)
	end
end

function NeuronGUI:visOptionOnClick(button)

	local bar = Neuron.CurrentBar

	if (bar and button.func) then
		bar[button.func](bar, nil, true, button:GetChecked())
	end

end

function NeuronGUI:colorPickerShow(button)

	if (button.color) then

		local frame  = NBE.baropt.colorpicker

		frame.updateFunc = function()

			local bar = Neuron.CurrentBar

			if (bar) then

				local r,g,b = NeuronColorPicker:GetColorRGB()
				local a = NeuronColorPicker.alpha:GetValue()

				r = round(r,2); g = round(g,2); b = round(b,2); a = 1-round(a,2)

				if (r and g and b and a) then

					local value = r..";"..g..";"..b..";"..a

					bar.data[button.option] = value

					bar:UpdateObjectData()

					bar:Update()
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

		table.insert(barOpt.swatch, f)
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

	local bar = Neuron.CurrentBar

	if (bar) then
		bar:SetState(frame.option, true, frame:GetChecked())
	end
end

function NeuronGUI:SetBarVisibility(button)
	local bar = Neuron.CurrentBar
	if (bar) then
		bar:SetVisibility(button.msg, true)
	end
end


function NeuronGUI:remapOnTextChanged(frame)

	local bar = Neuron.CurrentBar

	if (bar and bar.data.remap and frame.value) then

		local map, remap

		for states in gmatch(bar.data.remap, "[^;]+") do

			map, remap = (":"):split(states)

			if (map == frame.value) then

				barOpt.remapto.value = remap

				if (bar.data.paged) then
					barOpt.remapto:SetText(Neuron.STATES["paged"..remap])
				elseif (bar.data.stance) then
					barOpt.remapto:SetText(Neuron.STATES["stance"..remap])
				end
			end
		end
	else
		barOpt.remapto:SetText("")
	end
end

function NeuronGUI:remapToOnTextChanged(frame)

	local bar = Neuron.CurrentBar

	if (bar and bar.data.remap and frame.value and #frame.value > 0) then

		local value = barOpt.remap.value

		bar.data.remap = bar.data.remap:gsub(value..":%d+", value..":"..frame.value)

		if (bar.data.paged) then
			bar.paged.registered = false
		elseif (bar.data.stance) then
			bar.stance.registered = false
		end

		bar.stateschanged = true

		bar:Update()
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

	local MAS = Neuron.MANAGED_ACTION_STATES

	--this is confusing, but states comes out to just be a list of the names of the states
	for state, values in pairs(MAS) do
		states[values.order] = state
	end

	local _, class = UnitClass("player")

	for index,state in ipairs(states) do
		if (MAS[state].homestate) then

			f = CreateFrame("CheckButton", nil, frame.presets.primary, "NeuronOptionsCheckButtonTemplate")
			f:SetID(index)
			f:SetWidth(18)
			f:SetHeight(18)
			f:SetScript("OnClick", function(self) NeuronGUI:setBarActionState(self) end)
			--Renames Stance for rogues to Stealth as that is what should really be used
			if state == "stance" and (class == "ROGUE") then
				f.text:SetText(L["Stealth"])--:upper())
			elseif state == "stance" and (class == "DRUID" or class=="SHAMAN") then
				f.text:SetText(L["Shapeshift"])--:upper())
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

			table.insert(barOpt.pri, f)
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
	table.insert(barOpt.sec, f)


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
		button:SetScript("OnClick", function(self) NeuronGUI:SetBarVisibility(self) end)


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

		tableList = Neuron.STATES
	end

	if (not frame) then
		frame = NeuronBarEditorBarStatesVisEditorScrollFrame
	end

	local dataOffset, count, data = FauxScrollFrame_GetOffset(frame), 1, {}
	local button, text

	local _, class = UnitClass("player")

	for k in pairs(tableList) do
		local val = k:match("%d+$")

		if (val and (k ~= "custom0"))then
			--Messy workaround to not have 2 stealths for rogues
			if ((k == "stealth0" or k == "stealth1") and (class == "ROGUE")) then

			else
				data[count] = k; count = count + 1
			end
		end
	end

	table.sort(data)


	local customStateData = {}
	--This adds cusom states to the visability menu,  currently disabled untill I get custom state visability to work
	--[[

        if (bar and bar.data.customNames) then
                local i = 0
                for index,state in pairs(bar.data.customNames) do
                data[count] = state; count = count + 1
                customStateData[state] = i; i=i+1
                end
            end
    ]]--
	frame:Show()

	for i=1,numVisShown do

		button = _G["NeuronBarEditorBarStatesVisEditorScrollFrameButton"..i]
		button:SetChecked(false)

		count = dataOffset + i

		local _, class = UnitClass("player")

		if (data[count]) then

			text = Neuron.STATES[data[count]] or data[count]

			if customStateData[data[count]] then
				button.msg ="custom "..customStateData[data[count]]
				button:SetChecked(not bar.data.hidestates:find("custom"..customStateData[data[count]]))
			else
				button.msg = data[count]:match("%a+").." "..data[count]:match("%d+$")
				button:SetChecked(not bar.data.hidestates:find(data[count]))
			end

			--Renames rogues stance0 from Melee to No stealth for the view states list
			if (data[count] == "stance0"  and class == "ROGUE") then
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

		stateList = Neuron.MANAGED_ACTION_STATES
	end

	if (not frame) then
		frame = NeuronBarEditorBarStatesActionEditorPresetsSecondaryScrollFrame
	end

	local statesOffset, states = FauxScrollFrame_GetOffset(frame), {}
	local button, text

	local count = 1

	local _, class = UnitClass("player")

	for k,v in pairs(stateList) do

		if (not MAS[k].homestate and (k ~= "extrabar") and (k ~= "custom")) then

			if ((class == "ROGUE") and k == "stealth") then

			else
				states[count] = k
				count = count + 1
			end
		end
	end

	--Might want to add some checks for states like stealth for classes that don't have stealth. But for now it doesn't break anything to have it show generically

	table.sort(states)

	frame:Show()

	for i=1,numStatesShown do

		button = _G["PresetsScrollFrameButton"..i] --"NeuronBarEditorBarStatesSecondaryPresetsScrollFrameButton"..i]
		button:SetChecked(false)

		count = statesOffset + i

		if (states[count]) then
			text = MAS[states[count]].localizedName --:upper()

			button.option = states[count]
			button:SetChecked(bar.data[button.option ])
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
	local content = CreateFrame("Frame",nil, frame, BackdropTemplateMixin and "BackdropTemplate")
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
	local content = CreateFrame("Frame",nil, frame.options, BackdropTemplateMixin and "BackdropTemplate")
	content:SetPoint("TOPLEFT",10,-5 )
	content:SetPoint("BOTTOMRIGHT",-10,5)
	--This creats a cusomt AceGUI container which lets us imbed a AceGUI menu into our frame.
	local widget = {
		frame     = frame.options,
		content   = content,
		type      = "NeuronContainer"
	}
	widget["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end

	NeuronButtonEditor.ACEmenu = widget
	NeuronAceGUI:RegisterAsContainer(widget)
	NeuronGUI:SubFrameHoneycombBackdrop_OnLoad(frame)
end



function NeuronGUI:ObjectEditor_OnLoad(frame)

	NeuronGUI:SubFramePlainBackdrop_OnLoad(frame)

	frame:RegisterForDrag("LeftButton", "RightButton")
	frame.bottom = 0

	frame:SetHeight(height)
end

function NeuronGUI:ObjectEditor_OnShow(frame)

	for k,v in pairs(Neuron.Editors) do
		v[1]:Hide()
	end

	if (Neuron.CurrentObject) then

		local objType = Neuron.CurrentObject.objType

		if (Neuron.Editors[objType]) then

			local editor = Neuron.Editors[objType][1]

			editor:SetParent(frame)
			editor:SetAllPoints(frame)
			editor:Show()

			NOE:SetWidth(Neuron.Editors[objType][2])
			NOE:SetHeight(Neuron.Editors[objType][3])
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
								self.bar:FakeStateChange(self.state)
							end

						else
							button:SetChecked(false)
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

	if (Neuron.CurrentObject and Neuron.CurrentObject.bar) then

		wipe(stateList)

		bar = Neuron.CurrentObject.bar

		stateList["00"..L["Home State"]] = "homestate"

		for state, values in pairs(MAS) do
			if (bar.data[state]) then
				for index, name in pairs(Neuron.STATES) do
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

	if (bar and bar.data.customNames) then
		local i = 0
		for index,state in pairs(bar.data.customNames) do
			stateList[state] = index
			data[count] = state; count = count + 1
		end
	end

	frame:Show()

	frame.buttonH = frame:GetHeight()/numShown

	for i=1,numShown do

		button = _G["NeuronButtonEditorActionListScrollFrameButton"..i]
		button:SetChecked(false)

		count = dataOffset + i

		if (data[count]) then

			text = data[count]

			if (bar and stateList[text] == bar.handler:GetAttribute("fauxstate")) then
				button:SetChecked(true)
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

	local texture = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	local buttonSpec = Neuron.activeSpec
	local data = button.DB[specoveride][state]

	if (button.bar.data.multiSpec and specoveride ~= buttonSpec) then
		local spell = data.macro_Text:match("/cast%s+(%C+)") or
				data.macro_Text:match("/use%s+(%C+)") or
				data.macro_Text:match("/summonpet%s+(%C+)") or
				data.macro_Text:match("/equipset%s+(%C+)")
				or data.macro_Text

		if (data.macro_Text:match("/cast%s+(%C+)")) then
			spell = (spell):lower()
			if (NeuronSpellCache[spell]) then
				local spell_id = NeuronSpellCache[spell].spellID
				texture = GetSpellTexture(spell_id)
			elseif (spell) then
				texture = GetSpellTexture(spell)
			end

		elseif NeuronItemCache[spell] then
			texture = GetItemIcon("item:"..NeuronItemCache[spell]..":0:0:0:0:0:0:0")
		end

	else
		texture = button.Icon:GetTexture()
	end
	return texture
end


function NeuronGUI:MacroEditorUpdate()
	if (Neuron.CurrentObject and Neuron.CurrentObject.objType == "ACTIONBUTTON") then
		local button, NBTNE = Neuron.CurrentObject, NeuronButtonEditor
		local state = button.bar.handler:GetAttribute("fauxstate")
		local buttonSpec = Neuron.activeSpec

		if (button.bar.data.multiSpec) then
			buttonSpec = specoveride

			if buttonSpec > 4 then
				buttonSpec = 1
			end

			--Sets spec tab to current spec
			NBTNE.spec1:SetChecked(false)
			NBTNE.spec2:SetChecked(false)
			NBTNE["spec"..buttonSpec]:SetChecked(true)

			--Sets current spec marker to proper tab
			NBTNE.activespc:SetParent(NBTNE["spec"..Neuron.activeSpec])
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

		local data = button.DB[buttonSpec][state]

		if not data then
			button.DB[buttonSpec][state] = button:build()

			data = button.DB[buttonSpec][state]
			button:UpdateFlyout()
			button:BuildStateData()
			button:SetType()
		end

		if (data) then
			NBTNE.macroedit.edit:SetText(data.macro_Text)
			if (not data.macro_Icon) then
				NBTNE.macroicon.icon:SetTexture(NeuronGUI:specUpdateIcon(button, state))--button.Icon:GetTexture())
			elseif (data.macro_Icon == "BLANK") then
				NBTNE.macroicon.icon:SetTexture("")
			else
				NBTNE.macroicon.icon:SetTexture(data.macro_Icon)
			end
			if data.macro_Name then
				NBTNE.nameedit:SetText(data.macro_Name)
			end
			if data.macro_Note then
				NBTNE.noteedit:SetText(data.macro_Note)
			end
			NBTNE.usenote:SetChecked(data.macro_UseNote)

		else
			--Neuron:Print("nothinghere")
			--button.DB[buttonSpec][state] = button:build()
			--button:build(button.DB[buttonSpec][state])
			--Neuron:Print(button.DB[buttonSpec][state])
			--end
		end
	end
end

function NeuronGUI:ButtonEditorUpdate(reset)

	if (reset and Neuron.CurrentObject) then

		local bar = Neuron.CurrentObject.bar

		bar.handler:SetAttribute("fauxstate", bar.handler:GetAttribute("activestate"))

		NeuronButtonEditor.macroicon.icon:SetTexture("")


		specoveride = Neuron.activeSpec

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

	local button = Neuron.CurrentObject

	if (button) then

		button:UpdateFlyout()
		button:BuildStateData()
		button:SetType()

		NeuronGUI:MacroEditorUpdate()
	end
end


--- Triggers when text in the  macro editor changes
-- @param self: macro editor frame
function NeuronGUI:macroText_OnTextChanged(frame)

	if (frame.hasfocus) then
		local button = Neuron.CurrentObject
		if(button) then
			local buttonSpec = ((button.bar.data.multiSpec and specoveride) or 1)
			local state = button.bar.handler:GetAttribute("fauxstate")

			if (button and buttonSpec and state) then
				if button.DB[buttonSpec][state] then
					button.DB[buttonSpec][state].macro_Text = frame:GetText()
					button.DB[buttonSpec][state].macro_BlizzMacro = false
				else
					--Neuron:Print("nothinghere")
					--button.DB[buttonSpec][state] = button:build()
					--button:build(button.DB[buttonSpec][state])
					--Neuron:Print(button.DB[buttonSpec][state])
				end
			end

		end
	end
end

--- Triggers when text in the  macro editor changes
-- @param self: macro editor frame
function NeuronGUI:macroButton_Changed(frame, button, down)

	local object = Neuron.CurrentObject

	if not object then
		return
	end

	local data = object.data
	local buttonSpec = ((object.bar.data.multiSpec and specoveride) or 1)
	local state = object.bar.handler:GetAttribute("fauxstate")

	--handler to check if viewing non current spec button settings
	if (specoveride ~= Neuron.activeSpec) then
		data = object.DB[buttonSpec][state]
	end

	if (object and data) then

		if (frame.texture == "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") then
			data.macro_Icon = false
		else
			data.macro_Icon = frame.texture
		end
		object:UpdateIcon()

		NeuronGUI:UpdateObjectGUI()
	end

	frame:SetFrameLevel(frame.fl-1)
	frame.click = true
	frame.elapsed = 0
	frame:GetParent():Hide()
	frame:SetChecked(false)

end


--- Triggers when the text in the macro editor's name text box changes
-- @param self: macro editor name edit box frame
function NeuronGUI:macroNameEdit_OnTextChanged(frame)

	if not Neuron.CurrentObject then
		return
	end

	if (string.len(frame:GetText()) > 0) then
		frame.text:Hide()
	end

	if (frame.hasfocus) then

		local button = Neuron.CurrentObject
		local buttonSpec = ((button.bar.data.multiSpec and specoveride) or 1)
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and buttonSpec and state) then
			button.DB[buttonSpec][state].macro_Name = frame:GetText()
		end

		button.bar:UpdateObjectData()

	elseif (string.len(frame:GetText()) <= 0) then
		frame.text:Show()
	end

end


--- Triggers when the text in the macro editor's note text box changes
-- @param self: macro editor note edit box frame
function NeuronGUI:macroNoteEdit_OnTextChanged(frame)


	if (string.len(frame:GetText()) > 0) then
		frame.text:Hide()
		frame.cb:Show()
	else
		frame.cb:Hide()
	end

	if (frame.hasfocus) then

		local button = Neuron.CurrentObject
		local buttonSpec = ((button.bar.data.multiSpec and specoveride) or 1)
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and buttonSpec and state) then
			button.DB[buttonSpec][state].macro_Note = frame:GetText()
		end
	end
end


--TODO Revisit & Check description
--- Triggers when macro editor loses focus
-- @param self: macro editor frame
function NeuronGUI:macroOnEditFocusLost(frame)
	frame.hasfocus = nil

	local button = Neuron.CurrentObject

	if (button) then
		button:UpdateAll()
	end

	if (frame.text and string.len(frame:GetText()) <= 0) then
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
		frame:SetChecked(false)
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
						local spellID, _, isKnown = GetFlyoutSlotInfo(ID, k)
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
		if (string.len(search) < 1) then
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
				table.insert(IconList, icon)
			end
		else
			table.insert(IconList, icon)
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
			btn.texture = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
		end

	end

	FauxScrollFrame_Update(frame, math.ceil(numIcons/14), 1, 1, nil, nil, nil, nil, nil, nil, true)

end


function NeuronGUI:customPathOnShow(frame)

	local button = Neuron.CurrentObject

	if (button) then

		if (button.data.macro_Icon) then
			--Needs fixing
			local text = button.data.macro_Icon

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

	local button = Neuron.CurrentObject

	if (button) then

		local text = frame.frame.custompath:GetText()

		if (#text > 0) then

			text = "INTERFACE\\"..text:gsub("\\", "\\")

			button.data.macro_Icon = text

			button:UpdateIcon()

			NeuronGUI:UpdateObjectGUI()
		end
	end

	frame:GetParent():Hide()
end

--Resets all the fields in the editor for the curently selected buttton
function NeuronGUI:ResetButtonFields()
	local button, NBTNE = Neuron.CurrentObject, NeuronButtonEditor
	local state = button.bar.handler:GetAttribute("fauxstate")
	local buttonSpec = ((button.bar.data.multiSpec and specoveride) or 1)
	local data = button.DB[buttonSpec][state]

	data.actionID = false
	data.macro_Text = ""
	data.macro_Icon = false
	data.macro_Name = ""
	data.macro_Note = ""
	data.macro_BlizzMacro = false
	data.macro_EquipmentSet = false

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
				tab:SetChecked(true)
				if (MouseIsOver(cTab)) then
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
				end
			else
				tab:SetChecked(false)
			end
			tab:SetBackdropBorderColor(.5, .5, .5 , .5)

		end
	end

	local function TabsOnClick(cTab, silent)

		for tab, panel in pairs(frame.tabs) do

			if (tab == cTab) then
				tab:SetChecked(true)
				if (MouseIsOver(cTab)) then
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
				end
				panel:Show()
			else
				tab:SetChecked(false)
				panel:Hide()
			end

		end
	end
	frame:RegisterForDrag("LeftButton", "RightButton")

	Neuron.Editors.ACTIONBUTTON[1] = frame
	Neuron.Editors.ACTIONBUTTON[4] = NeuronGUI.ButtonEditorUpdate

	frame.tabs = {}
	frame.specs = {}

	local f

	f = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
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

	f = CreateFrame("Button", "focus", frame.macro, BackdropTemplateMixin and "BackdropTemplate")
	f:SetPoint("TOPLEFT", frame.macroedit, "TOPLEFT", -10, 10)
	f:SetPoint("BOTTOMRIGHT", -18, 0)
	f:SetWidth(350)
	f:SetHeight(300)
	f:SetScript("OnClick", function(self) self.macroedit.edit:SetFocus() end)
	f.macroedit = frame.macroedit
	frame.macrofocus = f

	f = CreateFrame("Frame", nil, frame.macroedit, BackdropTemplateMixin and "BackdropTemplate")
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

	f = CreateFrame("Button", nil, frame.macro, BackdropTemplateMixin and "BackdropTemplate")
	f:SetPoint("BOTTOMLEFT", frame.macroicon, "BOTTOMRIGHT", 2, -7)
	f:SetWidth(34)
	f:SetHeight(34)
	--f:SetScript("OnClick", function(self) SetActiveSpecGroup(Neuron.activeSpec == 1 and 2 or 1);  end)
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
	f:SetChecked(false)
	f.text:SetText("Spec1")
	f.tooltipText = L["Display button for specialization 1"]
	frame.spec1 = f; frame.specs[f] = frame.spec1

	f = CreateFrame("frame", nil, frame.spec1, BackdropTemplateMixin and "BackdropTemplate")
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
	f:SetChecked(false)
	f.text:SetText("Spec2")
	f.tooltipText = L["Display button for specialization 2"]
	frame.spec2 = f; frame.specs[f] = frame.spec2

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronCheckButtonTemplate1")
	f:SetWidth(68)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.spec2, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) SpecOnClick(self); specoveride = 3 ; NeuronGUI:ButtonEditorUpdate() end)
	f:SetChecked(false)
	f.text:SetText("Spec3")
	f.tooltipText = L["Display button for specialization 3"]
	frame.spec3 = f; frame.specs[f] = frame.spec3

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronCheckButtonTemplate1")
	f:SetWidth(68)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.spec3, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) SpecOnClick(self); specoveride = 4 ; NeuronGUI:ButtonEditorUpdate() end)
	f:SetChecked(false)
	f.text:SetText("Spec4")
	f.tooltipText = L["Display button for specialization 4"]
	frame.spec4 = f; frame.specs[f] = frame.spec4

	f = CreateFrame("Button", nil, frame.macro, "UIPanelButtonTemplate")--"NeuronCheckButtonTemplate1")
	f:SetWidth(104)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.spec3, "RIGHT", 0, 0)
	f:SetScript("OnClick", function()
		frame.macroedit.edit:ClearFocus()
		frame.nameedit:ClearFocus()
		frame.noteedit:ClearFocus()
	end)
	f:SetText(_G.SAVE)
	f.tooltipText = _G.SAVE
	frame.savestate = f

	f = CreateFrame("EditBox", nil, frame.macro, BackdropTemplateMixin and "BackdropTemplate")
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
	f:SetScript("OnEditFocusLost", function(self) if (string.len(self:GetText()) < 1) then self.text:Show() end NeuronGUI:macroOnEditFocusLost(self) end)
	f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame.nameedit = f

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	f.text:SetPoint("CENTER")
	f.text:SetJustifyH("CENTER")
	f.text:SetText(L["Macro Name"])

	f = CreateFrame("Frame", nil, frame.nameedit, BackdropTemplateMixin and "BackdropTemplate")
	f:SetPoint("TOPLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", 0, 0)
	f:SetFrameLevel(frame.nameedit:GetFrameLevel()-1)

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("EditBox", nil, frame.macro, BackdropTemplateMixin and "BackdropTemplate")
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
	f:SetScript("OnEditFocusLost", function(self) if (string.len(self:GetText()) < 1) then self.text:Show() end NeuronGUI:macroOnEditFocusLost(self) end)
	f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame.noteedit = f

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	f.text:SetPoint("CENTER", 10, 0)
	f.text:SetJustifyH("CENTER")
	f.text:SetText(L["Click here to edit macro note"])

	f = CreateFrame("Frame", nil, frame.noteedit, BackdropTemplateMixin and "BackdropTemplate")
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

		table.insert(frame.iconlist.buttons, f)

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
	f:SetScript("OnEditFocusLost", function(self) if (string.len(self:GetText()) < 1) then self.text:Show() self.cancel:Hide() end self.hasfocus = nil end)
	f:SetScript("OnTextChanged", function(self) if (string.len(self:GetText()) < 1 and not self.hasfocus) then self.text:Show() self.cancel:Hide() end end)
	frame.search = f

	frame.search:Hide() --hide search frame because it is broken and returns nonesense

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)

	f.cancel = CreateFrame("Button", nil, f, BackdropTemplateMixin and "BackdropTemplate")
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
	--f:SetScript("OnEditFocusLost", function(self) if (string.len(self:GetText()) < 1) then self.text:Show() self.cancel:Hide() end self.hasfocus = nil end)
	f:SetScript("OnTextChanged", function(self) self:SetText(self:GetText():upper()) end)
	f.frame = frame
	frame.custompath = f

	NeuronGUI:SubFrameBlackBackdrop_OnLoad(f)

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	f.text:SetPoint("LEFT", 8, 0)
	f.text:SetJustifyH("LEFT")
	f.text:SetText(L["Path"]..": INTERFACE\\")

	f:SetTextInsets(f.text:GetWidth()+5, 0, 0, 0)


	f = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -10)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then NeuronGUI:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f:Hide()
	f.elapsed = 0
	frame.action = f

	f = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -25)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then NeuronGUI:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f:SetScript("OnShow", function(self) LibStub("AceConfigDialog-3.0"):Open("Neuron-Flyout", NBTNE.ACEmenu) end)
	f:Hide()
	f.elapsed = 0
	frame.options = f

	---  /flyout <types>:<keys>:<shape>:<attach point>:<relative point>:<columns|radius>:<click|mouse>


	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(150)
	f:SetHeight(28)
	f:SetPoint("TOPRIGHT", frame, "TOPLEFT", 287, -10)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(true)
	f.text:SetText(L["Macro Data"])
	frame.tab1 = f; frame.tabs[f] = frame.macro


	local f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(150)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab1, "RIGHT", 150, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(false)
	f.text:SetText(L["Flyout Options"])
	frame.tab2 = f; frame.tabs[f] = frame.options




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

	if not NeuronGUI:IsHooked("OnAttributeChanged") then

		NeuronGUI:SecureHookScript(handler, "OnAttributeChanged", function(self,name,value)

			if(Neuron.CurrentObject) then
				if (NeuronObjectEditor:IsVisible() and self == Neuron.CurrentObject.bar.handler and name == "activestate" and not NeuronButtonEditor.macroedit.edit.hasfocus) then
					NeuronButtonEditor.macro.elapsed = 0
				end
			end

		end)

	end
end

function NeuronGUI:runUpdater(frame, elapsed)

	frame.elapsed = elapsed

	if (frame.elapsed > 0) then

		NeuronGUI:UpdateBarGUI()
		NeuronGUI:UpdateObjectGUI()

		frame:Hide()
	end
end





--- ACE GUI OPTION GET & SET FUnctions
-- @param self: macro editor frame
function NeuronGUI:settingGetter(info)
	if Neuron.CurrentBar then
		return Neuron.CurrentBar.data[ info[#info]]
	end
end


function NeuronGUI:SetBarCastTarget(value, toggle)
	if Neuron.CurrentBar then
		Neuron.CurrentBar:SetCastingTarget(value, true, toggle)
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
			set = function(info, value)
				SetModifiedClick("SELFCAST", value)
				SaveBindings(GetCurrentBindingSet() or 1)
				Neuron.ACTIONBUTTON:UpdateMacroCastTargets(true)
			end,
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
			set = function(info, value)
				SetModifiedClick("FOCUSCAST", value)
				SaveBindings(GetCurrentBindingSet() or 1)
				Neuron.ACTIONBUTTON:UpdateMacroCastTargets(true)
			end,
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
			get = function() return DB.mouseOverMod end, --getFunc,
			set = function(info, value)
				DB.mouseOverMod = value
				Neuron.ACTIONBUTTON:UpdateMacroCastTargets(true)
			end,
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
					name = L["Display the Blizzard UI"],
					desc = L["Shows / Hides the Default Blizzard UI"],
					type = "toggle",
					set = function() Neuron:ToggleBlizzUI() end,
					get = function() return DB.blizzbar end,
					width = "full",
				},

				NeuronMinimapButton = {
					order = 2,
					name = L["Display Minimap Button"],
					desc = L["Toggles the minimap button."],
					type = "toggle",
					set =  function() Neuron:Minimap_ToggleIcon() end,
					get = function() return not DB.NeuronIcon.hide end,
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









Neuron.Editors = {}

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

	if (editor.object ~= Neuron.CurrentObject) then
		editor.select:Hide()
	end

	GameTooltip:Hide()

end

function NeuronGUI:ObjEditor_OnClick(editor, button)

	local newObj, newEditor = Neuron.BUTTON:ChangeObject(editor.object)

	if (button == "RightButton") then

		if (NeuronObjectEditor) then
			if (not newObj and NeuronObjectEditor:IsVisible()) then
				NeuronObjectEditor:Hide()
			elseif (newObj and newEditor) then
				Neuron.NeuronGUI:ObjectEditor_OnShow(NeuronObjectEditor); NeuronObjectEditor:Show()
			else
				NeuronObjectEditor:Show()
			end
		end

	elseif (newObj and newEditor and NeuronObjectEditor:IsVisible()) then
		Neuron.NeuronGUI:ObjectEditor_OnShow(NeuronObjectEditor); NeuronObjectEditor:Show()
	end

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		Neuron.NeuronGUI:UpdateObjectGUI()
	end
end



function NeuronGUI:ObjEditor_OnEvent(editor, eventName, ...)

	local event = "ObjEditor_".. eventName

	if (NeuronGUI[event]) then
		NeuronGUI[event](NeuronGUI, editor, ...)
	end

end



function NeuronGUI:ObjEditor_CreateEditFrame(button)

	local editor = CreateFrame("Button", button:GetName().."EditFrame", button, "NeuronEditFrameTemplate")

	setmetatable(editor, { __index = CreateFrame("Button") })

	editor:EnableMouseWheel(true)
	editor:RegisterForClicks("AnyDown")
	editor:SetAllPoints(button)
	editor:SetScript("OnShow", function(self) NeuronGUI:ObjEditor_OnShow(self) end)
	editor:SetScript("OnHide", function(self) NeuronGUI:ObjEditor_OnHide(self) end)
	editor:SetScript("OnEnter", function(self) NeuronGUI:ObjEditor_OnEnter(self) end)
	editor:SetScript("OnLeave", function(self) NeuronGUI:ObjEditor_OnLeave(self) end)
	editor:SetScript("OnClick", function(self, button) NeuronGUI:ObjEditor_OnClick(self, button) end)
	editor:SetScript("OnEvent", function(self, event, ...) NeuronGUI:ObjEditor_OnEvent(self, event, ...) end)

	editor.type:SetText(L["Edit"])
	editor.object = button
	editor.editType = "button"

	button.editor = editor

	Neuron.EDITIndex[button.class..button.bar.DB.id.."_"..button.id] = editor

	editor:Hide()

end




----------------------------------------------------------------------------
--------------------------Status Bar Editor---------------------------------
----------------------------------------------------------------------------
local sbOpt = { types = {}, chk = {}, adj = {} }

local sbTypes = { { "cast", L["Cast Bar"] }, { "xp", L["XP Bar"] }, { "rep", L["Rep Bar"] }, { "mirror", L["Mirror Bar"] } }

local sbchkOptions = { [1] = { "cast", L["Cast Icon"], "UpdateCastIcon", "showIcon" } }

local BarTexturesData = {}
for i,data in ipairs(Neuron.BarTextures) do
	BarTexturesData[i] = data[3]
end

local BarBordersData = {}
for i,data in ipairs(Neuron.BarBorders) do
	BarBordersData[i] = data[1]
end

local sbadjOptions = {

	[1] = { "WIDTH", L["Width"], 1, "UpdateWidth", 0.5, 1, nil, nil, "%0.1f", 1, "" },
	[2] = { "HEIGHT", L["Height"], 1, "UpdateHeight", 0.5, 1, nil, nil, "%0.1f", 1, "" },
	[3] = { "BARFILL", L["Bar Fill"], 2, "UpdateBarFill", nil, nil, nil, BarTexturesData },
	[4] = { "BORDER", L["Border"], 2, "UpdateBorder", nil, nil, nil, BarBordersData },
	[5] = { "ORIENT", L["Orientation"], 2, "UpdateOrientation", nil, nil, nil, Neuron.BarOrientations },
	[6] = { "UNIT_WATCH", L["Unit"], 2, "UpdateUnit", nil, nil, nil, Neuron.BarUnits },
	[7] = { "CENTER_TEXT", L["Center Text"], 2, "UpdateCenterText", nil, nil, nil, Neuron.sbStrings },
	[8] = { "LEFT_TEXT", L["Left Text"], 2, "UpdateLeftText", nil, nil, nil, Neuron.sbStrings  },
	[9] = { "RIGHT_TEXT", L["Right Text"], 2, "UpdateRightText", nil, nil, nil, Neuron.sbStrings  },
	[10] = { "MOUSE_TEXT", L["Mouseover Text"], 2, "UpdateMouseover", nil, nil, nil, Neuron.sbStrings  },
	[11] = { "TOOLTIP_TEXT", L["Tooltip Text"], 2, "UpdateTooltip", nil, nil, nil, Neuron.sbStrings  },
}






function NeuronGUI:Status_UpdateEditor()

	if (NeuronStatusBarEditor and NeuronStatusBarEditor:IsVisible()) then
		NeuronGUI:StatusBarEditorUpdate()
	end

end

function NeuronGUI:StatusBarEditorUpdate(reset)

	local sb = Neuron.CurrentObject

	if (sb) then

		if (NeuronStatusBarEditor:IsVisible()) then

			local yoff  = -10
			local anchor, last, adjHeight
			--local editor = NeuronBarEditor.baropt.editor

			adjHeight = 200

			for i,f in ipairs(sbOpt.types) do

				if (sb.config.sbType == f.sbType) then
					f:SetChecked(true)
				else
					f:SetChecked(false)
				end

			end

			for i,f in ipairs(sbOpt.chk) do
				f:ClearAllPoints()
				f:Hide()
			end

			for i,f in ipairs(sbOpt.chk) do

				if (sb.config.sbType == f.sbType) then
					f:SetPoint("BOTTOMLEFT", f.parent, "BOTTOMLEFT", 15, 25)
					f:SetChecked(sb.config[f.index])
					f:Show()
				end
			end

			local yoff1, yoff2= (adjHeight)/5, (adjHeight)/5
			--local shape

			if (sb.config.sbType == "cast") then
				yoff1 = (adjHeight)/6
			end

			for i,f in ipairs(sbOpt.adj) do

				f:ClearAllPoints(); f:Hide()

				if (f.optData and f.strTable) then

					wipe(popupData)

					for types, data in pairs(f.optData) do
						if (types == sb.config.sbType) then
							for k,v in pairs(data) do
								popupData[k.."_"..v[1]] = tostring(k)
							end
						end
					end

					NeuronGUI:EditBox_PopUpInitialize(f.edit.popup, popupData)

				elseif (f.optData) then

					wipe(popupData)

					for k,v in pairs(f.optData) do

						if (k < 10) then
							popupData["0"..k.."_"..v] = tostring(k)
						else
							popupData[k.."_"..v] = tostring(k)
						end
					end

					NeuronGUI:EditBox_PopUpInitialize(f.edit.popup, popupData)
				end
			end

			for i,f in ipairs(sbOpt.adj) do

				if (i == 6) then
					if (sb.config.sbType == "cast") then
						f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
						f:Show()
						yoff = yoff-yoff1
					end
				elseif (i > 6) then

					if (i == 7) then
						yoff = -10
					end

					f:SetPoint("TOPLEFT", f.parent, "TOP", 10, yoff)
					f:Show()
					yoff = yoff-yoff2
				else
					f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
					f:Show()
					yoff = yoff-yoff1
				end

				if (sb[f.func]) then
					if (f.format) then
						f.edit:SetText(string.format(f.format, sb[f.func](sb, nil, true, true)*f.mult)..f.endtext)
					else
						f.edit:SetText(sb[f.func](sb, nil, true, true) or "")
					end
					f.edit:SetCursorPosition(0)
				end
			end
		end
	end
end




function NeuronGUI:StatusBarEditor_OnLoad(frame)
	Neuron.Editors.STATUSBAR = { frame, 625, 250, NeuronGUI.StatusBarEditorUpdate }
end




function NeuronGUI:StatusBarEditor_OnShow(frame)

end




function NeuronGUI:StatusBarEditor_OnHide(frame)

end




function NeuronGUI:sbTypeOnClick(button, down)

	local sb = Neuron.CurrentObject

	if (sb) then

		if (button.sbType == "xp") then

			sb.config.sbType = button.sbType
			sb.config.cIndex = 2
			sb.config.lIndex = 1
			sb.config.rIndex = 1

		elseif (button.sbType == "rep") then

			sb.config.sbType = button.sbType
			sb.config.cIndex = 2
			sb.config.lIndex = 1
			sb.config.rIndex = 1


		elseif (button.sbType == "cast") then

			sb.config.sbType = button.sbType
			sb.config.cIndex = 1
			sb.config.lIndex = 2
			sb.config.rIndex = 3

		elseif (button.sbType == "mirror") then

			sb.config.sbType = button.sbType
			sb.config.cIndex = 1
			sb.config.lIndex = 2
			sb.config.rIndex = 3
		end

		sb:SetType()

		NeuronGUI:Status_UpdateEditor()
	end
end




function NeuronGUI:SB_chkOptionOnClick(frame)

	local sb = Neuron.CurrentObject

	if (sb) then
		sb[frame.func](sb, frame, frame:GetChecked())
	end

end




function NeuronGUI:SB_EditorTypes_OnLoad(frame)

	local f, anchor, last

	for index, types in ipairs(sbTypes) do

		f = CreateFrame("CheckButton", nil, frame, "NeuronOptionsCheckButtonTemplate")
		f:SetWidth(18)
		f:SetHeight(18)
		f:SetScript("OnClick", function(self, down) NeuronGUI:sbTypeOnClick(self, down) end)
		f.sbType = types[1]
		f.text:SetText(types[2])

		if (not anchor) then
			f:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -15)
			anchor = f; last = f
		else
			f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -15)
			last = f
		end

		table.insert(sbOpt.types, f)
	end

	frame.line = frame:CreateTexture(nil, "OVERLAY")
	frame.line:SetHeight(1)
	frame.line:SetPoint("LEFT", 8, -40)
	frame.line:SetPoint("RIGHT", -8, -40)
	frame.line:SetTexture(0.3, 0.3, 0.3)

	anchor, last = nil, nil

	for index, options in ipairs(sbchkOptions) do

		f = CreateFrame("CheckButton", nil, frame, "NeuronOptionsCheckButtonTemplate")
		f:SetWidth(18)
		f:SetHeight(18)
		f:SetScript("OnClick", function(self) NeuronGUI:SB_chkOptionOnClick(self) end)
		f.sbType = options[1]
		f.text:SetText(options[2])
		f.func = options[3]
		f.index = options[4]
		f.parent = frame

		table.insert(sbOpt.chk, f)
	end

end




function NeuronGUI:SB_adjOptionOnTextChanged(edit, frame)

	local sb = Neuron.CurrentObject

	if (sb) then

		if (frame.method == 1) then

		elseif (frame.method == 2) then

			sb[frame.func](sb, edit.value, true)

			edit:HighlightText(0,0)
		end
	end
end




function NeuronGUI:SB_adjOptionOnEditFocusLost(edit, frame)

	edit.hasfocus = nil

	local sb = Neuron.CurrentObject

	if (sb) then

		if (frame.method == 1) then

			sb[frame.func](sb, edit:GetText(), true)

		elseif (frame.method == 2) then

		end
	end
end




function NeuronGUI:SB_adjOptionAdd(frame, onupdate)

	local sb = Neuron.CurrentObject

	if (sb) then

		local num = sb[frame.func](sb, nil, true, true)

		if (num == L["Off"] or num == "---") then
			num = 0
		else
			num = tonumber(num)
		end

		if (num) then

			if (frame.max and num >= frame.max) then

				sb[frame.func](sb, frame.max, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(string.format(frame.format, frame.max*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(frame.max)
					end
				end
			else
				sb[frame.func](sb, num+frame.inc, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(string.format(frame.format, (num+frame.inc)*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(num+frame.inc)
					end
				end
			end
		end
	end
end




function NeuronGUI:SB_adjOptionSub(frame, onupdate)

	local sb = Neuron.CurrentObject

	if (sb) then

		local num = sb[frame.func](sb, nil, true, true)

		if (num == L["Off"] or num == "---") then
			num = 0
		else
			num = tonumber(num)
		end

		if (num) then

			if (frame.min and num <= frame.min) then

				sb[frame.func](sb, frame.min, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(string.format(frame.format, frame.min*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(frame.min)
					end
				end
			else
				sb[frame.func](sb, num-frame.inc, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(string.format(frame.format, (num-frame.inc)*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(num-frame.inc)
					end
				end
			end
		end
	end
end




function NeuronGUI:SB_adjOptionOnMouseWheel(frame, delta)

	if (delta > 0) then
		NeuronGUI:SB_adjOptionAdd(frame)
	else
		NeuronGUI:SB_adjOptionSub(frame)
	end

end



---this needs to be moved into an AceGUI window
function NeuronGUI:SB_AdjustableOptions_OnLoad(frame)

	frame:RegisterForDrag("LeftButton", "RightButton")

	local f

	for index, options in ipairs(sbadjOptions) do

		f = CreateFrame("Frame", "NeuronSB_GUIAdjOpt"..index, frame, "NeuronAdjustOptionTemplate")
		f:SetID(index)
		f:SetWidth(200)
		f:SetHeight(24)
		f:SetScript("OnShow", function() end)
		f:SetScript("OnMouseWheel", function(self, delta) NeuronGUI:SB_adjOptionOnMouseWheel(self, delta) end)
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

		if (f.optData == Neuron.sbStrings) then
			f.strTable = true
		end

		f.edit:SetScript("OnTextChanged", function(self) NeuronGUI:SB_adjOptionOnTextChanged(self, self.frame) end)
		f.edit:SetScript("OnEditFocusLost", function(self) NeuronGUI:SB_adjOptionOnEditFocusLost(self, self.frame) end)

		f.addfunc = function(self) NeuronGUI:SB_adjOptionAdd(self) end
		f.subfunc = function(self) NeuronGUI:SB_adjOptionSub(self) end

		table.insert(sbOpt.adj, f)
	end

end


function NeuronGUI:SB_CreateEditFrame(button)

	local editor = CreateFrame("Button", button:GetName().."EditFrame", button, "NeuronEditFrameTemplate")

	setmetatable(editor, { __index = CreateFrame("Button") })

	editor:EnableMouseWheel(true)
	editor:RegisterForClicks("AnyDown")
	editor:SetAllPoints(button)
	editor:SetScript("OnShow", function(self) NeuronGUI:ObjEditor_OnShow(self) end)
	editor:SetScript("OnHide", function(self) NeuronGUI:ObjEditor_OnHide(self) end)
	editor:SetScript("OnEnter", function(self) NeuronGUI:ObjEditor_OnEnter(self) end)
	editor:SetScript("OnLeave", function(self) NeuronGUI:ObjEditor_OnLeave(self) end)
	editor:SetScript("OnClick", function(self, button) NeuronGUI:ObjEditor_OnClick(self, button) end)

	editor.type:SetText("")
	editor.object = button
	editor.editType = "status"

	editor.select.TL:ClearAllPoints()
	editor.select.TL:SetPoint("RIGHT", editor.select, "LEFT", 4, 0)
	editor.select.TL:SetTexture("Interface\\AddOns\\Neuron\\Images\\flyout.tga")
	editor.select.TL:SetTexCoord(0.71875, 1, 0, 1)
	editor.select.TL:SetWidth(16)
	editor.select.TL:SetHeight(55)

	editor.select.TR:ClearAllPoints()
	editor.select.TR:SetPoint("LEFT", editor.select, "RIGHT", -4, 0)
	editor.select.TR:SetTexture("Interface\\AddOns\\Neuron\\Images\\flyout.tga")
	editor.select.TR:SetTexCoord(0, 0.28125, 0, 1)
	editor.select.TR:SetWidth(16)
	editor.select.TR:SetHeight(55)

	editor.select.BL:SetTexture("")
	editor.select.BR:SetTexture("")

	button.editor = editor

	Neuron.EDITIndex[button.class..button.bar.DB.id.."_"..button.id] = editor

	editor:Hide()

end
