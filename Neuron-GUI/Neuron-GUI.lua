--Neuron GUI, a World of Warcraft® user interface addon.
--Copyright© 2006-2014 Connor H. Chenoweth, aka Maul - All rights reserved.

local NEURON = Neuron
local GDB, CDB, NMM, NBE, NOE, NBTNE, MAS, PEW

local width, height = 775, 490

local barNames = {}

local numShown = 15

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local GUIData = NEURON.RegisteredGUIData

local ICONS = NEURON.iIndex


local sIndex = NEURON.sIndex  --Spell index
local cIndex = NEURON.cIndex  --Battle pet & Mount index
local iIndex = NEURON.iIndex  --Items Index
local ItemCache = NeuronItemCache

NeuronGUIGDB = {
	firstRun = true,
}

NeuronGUICDB = {

}

local defGDB, defCDB = CopyTable(NeuronGUIGDB), CopyTable(NeuronGUICDB)

local barOpt = { chk = {}, adj = {}, pri = {}, sec = {}, swatch = {}, vis = {} }

local popupData = {}

local chkOptions = {
	[1] = { "AUTOHIDE", L.AUTOHIDE, 1, "AutoHideBar" },
	[2] = { "SHOWGRID", L.SHOWGRID, 1, "ShowGridSet" },
	[3] = { "SNAPTO", L.SNAPTO, 1, "SnapToBar" },
	[4] = { "UPCLICKS", L.UPCLICKS, 1, "UpClicksSet" },
	[5] = { "DOWNCLICKS", L.DOWNCLICKS, 1, "DownClicksSet" },
	[6] = { "DUALSPEC", L.DUALSPEC, 1, "DualSpecSet" },
	[7] = { "HIDDEN", L.HIDDEN, 1, "ConcealBar" },
	[8] = { "SPELLGLOW", L.SPELLGLOW, 1, "SpellGlowSet" },
	[9] = { "SPELLGLOW", L.SPELLGLOW_DEFAULT, 1, "SpellGlowSet", "default" },
	[10] = { "SPELLGLOW", L.SPELLGLOW_ALT, 1, "SpellGlowSet", "alt" },
	[11] = { "LOCKBAR", L.LOCKBAR, 1, "LockSet" },
	[12] = { "LOCKBAR", L.LOCKBAR_SHIFT, 0.9, "LockSet", "shift" },
	[13] = { "LOCKBAR", L.LOCKBAR_CTRL, 0.9, "LockSet", "ctrl" },
	[14] = { "LOCKBAR", L.LOCKBAR_ALT, 0.9, "LockSet", "alt" },
	[15] = { "TOOLTIPS", L.TOOLTIPS_OPT, 1, "ToolTipSet" },
	[16] = { "TOOLTIPS", L.TOOLTIPS_ENH, 0.9, "ToolTipSet", "enhanced" },
	[17] = { "TOOLTIPS", L.TOOLTIPS_COMBAT, 0.9, "ToolTipSet", "combat" },
	[18] = { "ZONEABILITY", L.ZONEABILITY_BAR_BORDER, 1, "HideZoneAbilityBorder"},
}

local adjOptions = {
	[1] = { "SCALE", L.SCALE, 1, "ScaleBar", 0.01, 0.1, 4 },
	[2] = { "SHAPE", L.SHAPE, 2, "ShapeBar", nil, nil, nil, NEURON.BarShapes },
	[3] = { "COLUMNS", L.COLUMNS, 1, "ColumnsSet", 1 , 0},
	[4] = { "ARCSTART", L.ARCSTART, 1, "ArcStartSet", 1, 0, 359 },
	[5] = { "ARCLENGTH", L.ARCLENGTH, 1, "ArcLengthSet", 1, 0, 359 },
	[6] = { "HPAD", L.HPAD, 1, "PadHSet", 0.1 },
	[7] = { "VPAD", L.VPAD, 1, "PadVSet", 0.1 },
	[8] = { "HVPAD", L.HVPAD, 1, "PadHVSet", 0.1 },
	[9] = { "STRATA", L.STRATA, 2, "StrataSet", nil, nil, nil, NEURON.Stratas },
	[10] = { "ALPHA", L.ALPHA, 1, "AlphaSet", 0.01, 0, 1 },
	[11] = { "ALPHAUP", L.ALPHAUP, 2, "AlphaUpSet", nil, nil, nil, NEURON.AlphaUps },
	[12] = { "ALPHAUP", L.ALPHAUP_SPEED, 1, "AlphaUpSpeedSet", 0.01, 0.01, 1, nil, "%0.0f", 100, "%" },
	[13] = { "XPOS", L.XPOS, 1, "XAxisSet", 0.05, nil, nil, nil, "%0.2f", 1, "" },
	[14] = { "YPOS", L.YPOS, 1, "YAxisSet", 0.05, nil, nil, nil, "%0.2f", 1, "" },
}

local swatchOptions = {
	[1] = { "BINDTEXT", L.BINDTEXT, 1, "BindTextSet", true, nil, "bindColor" },
	[2] = { "MACROTEXT", L.MACROTEXT, 1, "MacroTextSet", true, nil, "macroColor" },
	[3] = { "COUNTTEXT", L.COUNTTEXT, 1, "CountTextSet", true, nil, "countColor" },
	[4] = { "RANGEIND", L.RANGEIND, 1, "RangeIndSet", true, nil, "rangecolor" },
	[5] = { "CDTEXT", L.CDTEXT, 1, "CDTextSet", true, true, "cdcolor1", "cdcolor2" },
	[6] = { "CDALPHA", L.CDALPHA, 1, "CDAlphaSet", nil, nil },
	[7] = { "AURATEXT", L.AURATEXT, 1, "AuraTextSet", true, true, "auracolor1", "auracolor2" },
	[8] = { "AURAIND", L.AURAIND, 1, "AuraIndSet", true, true, "buffcolor", "debuffcolor" },
}

local specoveride = GetActiveSpecGroup() or 1

local addonName = ...


local AceGUI = LibStub("AceGUI-3.0")

local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end


local function insertLink(text)

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

local function modifiedSpellClick(button)

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
					insertLink(spell.."("..subName..")")
				else
					insertLink(spell.."()")
				end
			end
			return
		end
	end

	if (IsModifiedClick("PICKUPACTION")) then

		PickupSpell(id, SpellBookFrame.bookType)

	end
end

local function modifiedItemClick(link)

	if (IsModifiedClick("CHATLINK")) then

		if (NBTNE:IsVisible()) then

			local itemName = GetItemInfo(link)

			if (itemName) then
				insertLink(itemName)
			end

			return true
		end
	end
end

local function modifiedMountClick(self, button)

	local id = self:GetParent().spellID

	if (CursorHasSpell() and NBTNE:IsVisible()) then
		ClearCursor()
	end

	if (IsModifiedClick("CHATLINK")) then

		if (NBTNE:IsVisible()) then

			local mount = GetSpellInfo(id)

			if (mount) then
				insertLink(mount.."()")
			end

			return
		end
	end
end

local function modifiedPetJournalClick(self, button)

	local id = self:GetParent().petID

	if (NBTNE:IsVisible()) then
		ClearCursor()
	end

	if (IsModifiedClick("CHATLINK")) then

		if (NBTNE:IsVisible()) then

			local _, _, _, _, _, _, petName = C_PetJournal.GetPetInfoByPetID(id)

			if (petName) then
				insertLink(petName.."()")
			end

			return
		end
	end
end

local function openStackSplitFrame(...)

	if (NBTNE:IsVisible()) then
		StackSplitFrame:Hide()
	end
end

local function NeuronPanelTemplates_DeselectTab(tab)

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

local function NeuronPanelTemplates_SelectTab(tab)

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

local function NeuronPanelTemplates_TabResize(tab, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)

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
local function generateCustomStateList(bar)
	local start = tonumber(string.match(bar.cdata.customRange, "^%d+"))
	local stop = tonumber(string.match(bar.cdata.customRange, "%d+$"))
	local customStateList = bar.cdata.customNames["homestate"]..";"

	for index = start, stop, 1 do
		customStateList = customStateList..bar.cdata.customNames["custom"..index]..";"
	end

	return customStateList
end

function NEURON:UpdateBarGUI(newBar)

	NEURON.BarListScrollFrameUpdate()

	local bar = Neuron.CurrentBar

	if (bar and GUIData[bar.class]) then

		if (NBE:IsVisible()) then
			NBE.count.text:SetText(bar.objType.." "..L.COUNT..": |cffffffff"..bar.objCount.."|r")
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

					if (bar[f.func]) then
						if (f.primary) then
							if (f.primary:GetChecked()) then
								f:Enable()
								f:SetChecked(bar[f.func](bar, f.modtext, true, nil, true))
								f.text:SetTextColor(1,0.82,0)
								f.disabled = nil
							else
								f:SetChecked(nil)
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

					if (shape ~= L.BAR_SHAPE1) then
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

					if (shape == L.BAR_SHAPE1) then

						f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
						f:Show()

						yoff = yoff-yoff1
					end

				elseif (f.option == "ARCSTART" or f.option == "ARCLENGTH") then

					if (shape ~= L.BAR_SHAPE1) then

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

			customStateList = generateCustomStateList(bar)
			--[[
            for index,state in pairs(bar.cdata.customNames) do
                            if (index == "homestate") then
                                customStateList = state..";"
                            else
                                customStateList = customStateList..state..";"
                            end
                        end
                        --]]
		end

		barOpt.customstate:SetText(customStateList)
	end
	--Set visisbility buttons
	NEURON.VisEditorScrollFrameUpdate()
	Neuron.SecondaryPresetsScrollFrameUpdate()
	LibStub("AceConfigDialog-3.0"):Open(addonName, NBE.ACEmenu , "moreoptions")

end


function NEURON:UpdateObjectGUI(reset)

	for editor, data in pairs(NEURON.Editors) do
		if (data[1]:IsVisible()) then
			data[4](reset)
		end
	end
end


local function updateBarName(frame)

	local bar = NEURON.CurrentBar

	if (bar) then

		bar.gdata.name = frame:GetText()

		bar.text:SetText(bar.gdata.name)

		bar:SaveData()

		frame:ClearFocus()

		NEURON.BarListScrollFrameUpdate()
	end
end


local function resetBarName(frame)
	local bar = NEURON.CurrentBar

	if (bar) then
		frame:SetText(bar.gdata.name)
		frame:ClearFocus()
	end
end

local function resetMacroText(frame)
	local bar = NEURON.CurrentBar

	if (bar) then
		frame:SetText(bar.gdata.name)
		frame:ClearFocus()
	end
end

local function updateCustomState(frame)
	local bar = NEURON.CurrentBar
	local state = frame:GetText()
	local customStateList = ""

	bar:SetState("custom", true, false)  --turns off custom state to clear any previous stored items
	if (bar and state ~= "") then
		bar:SetState("custom "..state, true, true)
	end

	if (bar and bar.cdata.customNames) then
		customStateList = generateCustomStateList(bar)
	end

	barOpt.customstate:SetText(customStateList)
	NEURON.VisEditorScrollFrameUpdate()
	frame:ClearFocus()
end

local function countOnMouseWheel(frame, delta)

	local bar = NEURON.CurrentBar

	if (bar) then

		if (delta > 0) then
			bar:AddObjects()
		else
			bar:RemoveObjects()
		end
	end
end

function NEURON:BarEditor_OnLoad(frame)

	NEURON.SubFramePlainBackdrop_OnLoad(frame)


	frame:SetWidth(width)
	frame:SetHeight(height)

	frame:RegisterEvent("ADDON_LOADED")
	frame:RegisterForDrag("LeftButton", "RightButton")
	frame.bottom = 0

	frame.tabs = {}

	local function TabsOnClick(cTab, silent)

		for tab, panel in pairs(frame.tabs) do

			if (tab == cTab) then

				tab:SetChecked(1)

				if (MouseIsOver(cTab)) then
					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
				end

				panel:Show()

				NEURON:UpdateBarGUI()
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
	f.text:SetText(L.SPELL_TARGETING_OPTIONS)
	frame.tab3 = f; frame.tabs[f] = frame.targetoptions

	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab3, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText(L.BAR_STATES)
	frame.tab2 = f; frame.tabs[f] = frame.barstates

	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab2, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(1)
	f.text:SetText(L.GENERAL)
	frame.tab1 = f; frame.tabs[f] = frame.baropt

	f = CreateFrame("EditBox", nil, frame, "NeuronEditBoxTemplateSmall")
	f:SetWidth(160)
	f:SetHeight(26)
	f:SetPoint("RIGHT", frame.tab1, "LEFT", -3.5, 0)
	f:SetPoint("TOPLEFT", frame.barlist, "TOPRIGHT", 3.5, 0)
	f:SetScript("OnEnterPressed", updateBarName)
	f:SetScript("OnTabPressed", updateBarName)
	f:SetScript("OnEscapePressed", resetBarName)
	frame.barname = f

	NEURON.SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("Frame", nil, frame)
	f:SetWidth(250)
	f:SetHeight(30)
	f:SetPoint("BOTTOM", 0, 10)
	f:SetScript("OnMouseWheel", function(self, delta) countOnMouseWheel(self, delta) end)
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
	f:SetScript("OnClick", function(self) if (NEURON.CurrentBar) then NEURON.CurrentBar:AddObjects() end end)

	f = CreateFrame("Button", nil, frame.count)
	f:SetWidth(32)
	f:SetHeight(40)
	f:SetPoint("RIGHT", text, "LEFT", -10, -1)
	f:SetNormalTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionLeft-Up")
	f:SetPushedTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionLeft-Down")
	f:SetHighlightTexture("Interface\\AddOns\\Neuron\\Images\\AdjustOptionLeft-Highlight")
	f:SetScript("OnClick", function(self) if (NEURON.CurrentBar) then NEURON.CurrentBar:RemoveObjects() end end)

end

function NEURON:BarList_OnLoad()

	NEURON.SubFrameHoneycombBackdrop_OnLoad(self)

	self:SetHeight(height-55)

end

function NEURON.BarListScrollFrame_OnLoad(self)

	self.offset = 0
	self.scrollChild = _G[self:GetName().."ScrollChildFrame"]

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)

	local button, lastButton, rowButton, count = false, false, false, 0

	for i=1,numShown do

		button = CreateFrame("CheckButton", self:GetName().."Button"..i, self:GetParent(), "NeuronScrollFrameButtonTemplate")

		button.frame = self:GetParent()
		button.numShown = numShown

		button:SetScript("OnClick",

			function(self)

				local button

				for i=1,numShown do

					button = _G["NeuronBarEditorBarListScrollFrameButton"..i]

					if (i == self:GetID()) then

						if (self.alt) then

							if (self.bar) then

								NEURON:CreateNewBar(self.bar)

								NeuronBarEditorCreate:Click()
							end

							self.alt = nil

						elseif (self.bar) then

							NEURON:ChangeBar(self.bar)

							if (NBE and NBE:IsVisible()) then
								NEURON:UpdateBarGUI()
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
		button:SetFrameLevel(self:GetFrameLevel()+2)
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

	NEURON.BarListScrollFrameUpdate()
end

function NEURON.BarListScrollFrameUpdate(frame, tableList, alt)

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

			if (alt) then
				if (i>1) then
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

function NEURON:CreateButton_OnLoad(button)

	button.type = "create"
	button.text:SetText(L.CREATE_BAR)

end


--- Checks to see if a one only bar type has been deleted.  If so it will allow the bar
-- to be created
-- @param bar: type of bar being checked
-- @return allow : (boolean)
local function MissingBarCheck(bar)
	local allow = true
	if (bar == "stancebar" and NeuronCDB.sbars[1]) or (bar == "extrabar" and NeuronCDB.xbars[1]) or (bar == "zoneabilitybar" and NeuronCDB.zoneabilitybars[1]) then
		allow = false
	end
	return allow
end


function NEURON:BarEditor_CreateNewBar(button)
	if (button.type == "create") then

		local data = { [L.SELECT_BAR_TYPE] = "none" }

		for class,info in pairs(NEURON.RegisteredBarData) do

			if (info.barCreateMore or MissingBarCheck(class)) then
				data[info.barLabel] = class
			end
		end

		NEURON.BarListScrollFrameUpdate(nil, data, true)

		button.type = "cancel"

		button.text:SetText(L.CANCEL)
	else

		NEURON.BarListScrollFrameUpdate()

		button.type = "create"

		button.text:SetText(L.CREATE_BAR)

	end
end

function NEURON:DeleteButton_OnLoad(button)

	button.parent = button:GetParent()
	button.parent.delete = button
	button.type = "delete"
	button.text:SetText(L.DELETE_BAR)

end

function NEURON:BarEditor_DeleteBar(button)

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

function NEURON:Confirm_OnLoad(button)

	button.parent = button:GetParent()
	button.parent.confirm = button
	button.title:SetText(L.CONFIRM)

end

function NEURON:ConfirmYes_OnLoad(button)

	button.parent = button:GetParent()
	button.type = "yes"
	_G[button:GetName().."Text"]:SetText(L.CONFIRM_YES)

end

function NEURON:BarEditor_ConfirmYes(button)

	local bar = NEURON.CurrentBar

	if (bar) then
		bar:DeleteBar()
	end

	NeuronBarEditorDelete:Click()

end

function NEURON:ConfirmNo_OnLoad(button)

	button.parent = button:GetParent()
	button.type = "no"
	_G[button:GetName().."Text"]:SetText(L.CONFIRM_NO)
end

function NEURON:BarEditor_ConfirmNo(button)
	NeuronBarEditorDelete:Click()
end

local function chkOptionOnClick(button)

	local bar = NEURON.CurrentBar

	if (bar and button.func) then
		bar[button.func](bar, button.modtext, true, button:GetChecked())
	end
end

function NEURON.BarOptions_OnLoad(frame)

	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

	local f, primary

	for index, options in ipairs(chkOptions) do

		f = CreateFrame("CheckButton", nil, frame, "NeuronOptionsCheckButtonTemplate")
		f:SetID(index)
		f:SetWidth(18)
		f:SetHeight(18)
		f:SetScript("OnClick", chkOptionOnClick)
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

local function adjOptionOnTextChanged(edit, frame)

	local bar = NEURON.CurrentBar

	if (bar) then

		if (frame.method == 1) then

		elseif (frame.method == 2 and edit.value) then

			bar[frame.func](bar, edit.value, true)

			edit.value = nil
		end
	end
end

local function adjOptionOnEditFocusLost(edit, frame)

	edit.hasfocus = nil

	local bar = NEURON.CurrentBar

	if (bar) then

		if (frame.method == 1) then

			bar[frame.func](bar, edit:GetText(), true)

		elseif (frame.method == 2) then

		end
	end
end

local function adjOptionAdd(frame, onupdate)

	local bar = NEURON.CurrentBar

	if (bar) then

		local num = bar[frame.func](bar, nil, true, true)

		if (num == L.OFF or num == "---") then
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

local function adjOptionSub(frame, onupdate)

	local bar = NEURON.CurrentBar

	if (bar) then

		local num = bar[frame.func](bar, nil, true, true)

		if (num == L.OFF or num == "---") then
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

local function adjOptionOnMouseWheel(frame, delta)

	if (delta > 0) then
		adjOptionAdd(frame)
	else
		adjOptionSub(frame)
	end

end

function NEURON.AdjustableOptions_OnLoad(frame)

	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

	local f

	for index, options in ipairs(adjOptions) do

		f = CreateFrame("Frame", "NeuronGUIAdjOpt"..index, frame, "NeuronAdjustOptionTemplate")
		f:SetID(index)
		f:SetWidth(200)
		f:SetHeight(24)
		f:SetScript("OnShow", function() end)
		f:SetScript("OnMouseWheel", function(self, delta) adjOptionOnMouseWheel(self, delta) end)
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

		f.edit:SetScript("OnTextChanged", function(self) adjOptionOnTextChanged(self, self.frame) end)
		f.edit:SetScript("OnEditFocusLost", function(self) adjOptionOnEditFocusLost(self, self.frame) end)

		f.addfunc = adjOptionAdd
		f.subfunc = adjOptionSub

		tinsert(barOpt.adj, f)
	end
end

local function visOptionOnClick(button)

	local bar = NEURON.CurrentBar

	if (bar and button.func) then
		bar[button.func](bar, nil, true, button:GetChecked())
	end

end

local function colorPickerShow(self)

	if (self.color) then

		local frame  = NBE.baropt.colorpicker

		frame.updateFunc = function()

			local bar = NEURON.CurrentBar

			if (bar) then

				local r,g,b = NeuronColorPicker:GetColorRGB()
				local a = NeuronColorPicker.alpha:GetValue()

				r = round(r,2); g = round(g,2); b = round(b,2); a = 1-round(a,2)

				if (r and g and b and a) then

					local value = r..";"..g..";"..b..";"..a

					bar.gdata[self.option] = value

					bar:UpdateObjectData()

					bar:Update()
				end
			end
		end

		local r,g,b,a = (";"):split(self.color)

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

function NEURON.VisiualOptions_OnLoad(frame)

	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

	local f, primary

	for index, options in ipairs(swatchOptions) do

		f = CreateFrame("CheckButton", nil, frame, "NeuronOptionsCheckButtonSwatchTemplate")
		f:SetID(index)
		f:SetWidth(18)
		f:SetHeight(18)
		f:SetScript("OnClick", visOptionOnClick)
		f:SetScale(1)

		f.text:SetText(options[2]..":")
		f.option = options[1]
		f.func = options[4]
		f.parent = frame

		if (options[5]) then
			f.swatch1:Show()
			f.swatch1:SetScript("OnClick", colorPickerShow)
			f.swatch1.option = options[7]
		end

		if (options[6]) then
			f.swatch2:Show()
			f.swatch2:SetScript("OnClick", colorPickerShow)
			f.swatch2.option = options[8]
		end

		tinsert(barOpt.swatch, f)
	end
end

function NEURON.BarEditorColorPicker_OnLoad(frame)

	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

end

function NEURON.BarEditorColorPicker_OnShow(frame)

	NeuronColorPicker.frame = frame

	NeuronColorPicker:ClearAllPoints()
	NeuronColorPicker:SetParent(frame)
	NeuronColorPicker:SetPoint("TOPLEFT", 0, -20)
	NeuronColorPicker:SetPoint("BOTTOMRIGHT")
	NeuronColorPicker:Show()

end

local function setBarActionState(frame)

	local bar = NEURON.CurrentBar

	if (bar) then
		bar:SetState(frame.option, true, frame:GetChecked())
	end
end

local function setBarVisability(button)
	local bar = NEURON.CurrentBar
	if (bar) then
		bar:SetVisibility(button.msg, true)
	end
end


local function remapOnTextChanged(frame)

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

local function remapToOnTextChanged(frame)

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

		bar:Update()
	end
end

local IsDruid = false

function NEURON:ActionEditor_OnLoad(frame)

	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

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
	f.text:SetText(L.PRESET_STATES)
	f.selected = true
	frame.tab1 = f; frame.tabs[f] = frame.presets

	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTabTemplate")
	f:SetWidth(160)
	f:SetHeight(28)
	f:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT",-5,4)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel())
	f.text:SetText(L.CUSTOM_STATES)
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
	local anchor, last, count, prowl

	local MAS = NEURON.MANAGED_ACTION_STATES

	for state, values in pairs(MAS) do
		states[values.order] = state
	end

	for index,state in ipairs(states) do
		if (MAS[state].homestate) then

			f = CreateFrame("CheckButton", nil, frame.presets.primary, "NeuronOptionsCheckButtonTemplate")
			f:SetID(index)
			f:SetWidth(18)
			f:SetHeight(18)
			f:SetScript("OnClick", setBarActionState)
			--Renames Stance for rogues to Stealth as that is what shoudl really be used
			if state == "stance" and (NEURON.class == "ROGUE") then
				f.text:SetText(L["STEALTH1"])
			else
				f.text:SetText(L["GUI_"..state:upper()])
			end
			f.option = state

			if (not anchor) then
				f:SetPoint("TOPLEFT", frame.presets.primary, "TOPLEFT", 10, -10)
				anchor = f; last = f
			else
				f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -18)
				last = f
			end

			if (state == "stance" and NEURON.class == "DRUID") then
				prowl = f
				IsDruid = f
			end

			tinsert(barOpt.pri, f)
		end
	end

	anchor, last, count = nil, nil, 1
	--[[
        for index,state in ipairs(states) do

            if (not MAS[state].homestate and state ~= "custom" and state ~= "extrabar" and state ~= "prowl") then

                f = CreateFrame("CheckButton", nil, frame.presets.secondary, "NeuronOptionsCheckButtonTemplate")
                f:SetID(index)
                f:SetWidth(18)
                f:SetHeight(18)
                f:SetScript("OnClick", setBarActionState)
                f.text:SetText(L["GUI_"..state:upper()])
                f.option = state

                if (not anchor) then
                    f:SetPoint("TOPLEFT", frame.presets.secondary, "TOPLEFT", 10, -8)
                    anchor = f; last = f
                elseif (count == 5) then
                    f:SetPoint("LEFT", anchor, "RIGHT", 90, 0)
                    anchor = f; last = f; count = 1
                else
                    f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -8)
                    last = f
                end

                count = count + 1

                tinsert(barOpt.sec, f)

            elseif state == "custom" then
                f = CreateFrame("CheckButton", nil, frame.custom, "NeuronOptionsCheckButtonTemplate")
                f:SetID(index)
                f:SetWidth(18)
                f:SetHeight(18)
                f:SetScript("OnClick", setBarActionState)
                f.text:SetText(L["GUI_"..state:upper()])
                f.option = state
                f:SetPoint("TOPLEFT", frame.custom, "TOPLEFT", 10, -10)
                tinsert(barOpt.sec, f)
            end
        end

        if (prowl) then

            f = CreateFrame("CheckButton", nil, frame.presets.secondary, "NeuronOptionsCheckButtonTemplate")
            f:SetID(#states+1)
            f:SetWidth(18)
            f:SetHeight(18)
            f:SetScript("OnClick", setBarActionState)
            f.text:SetText(L.GUI_PROWL)
            f.option = "prowl"
            f.stance = prowl
            f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -8)

            tinsert(barOpt.sec, f)
        end
    ]]--

	f = CreateFrame("CheckButton", nil, frame.custom, "NeuronOptionsCheckButtonTemplate")
	--f:SetID(index)
	f:SetWidth(18)
	f:SetHeight(18)
	f:SetScript("OnClick", setBarActionState)
	f.text:SetText(L["GUI_CUSTOM"])
	f.option = "custom"
	f:SetPoint("TOPLEFT", frame.custom, "TOPLEFT", 10, -10)
	tinsert(barOpt.sec, f)


	f = CreateFrame("EditBox", "$parentRemap", frame.presets, "NeuronDropDownOptionFull")
	f:SetWidth(165)
	f:SetHeight(25)
	f:SetTextInsets(7,3,0,0)
	f.text:SetText(L.REMAP)
	f:SetPoint("BOTTOMLEFT", frame.presets, "BOTTOMLEFT", 7, 8)
	f:SetPoint("BOTTOMRIGHT", frame.presets.secondary, "BOTTOM", -70, -35)
	f:SetScript("OnTextChanged", remapOnTextChanged)
	f:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	f.popup:ClearAllPoints()
	f.popup:SetPoint("BOTTOMLEFT")
	f.popup:SetPoint("BOTTOMRIGHT")
	barOpt.remap = f

	NEURON.SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("EditBox", "$parentRemapTo", frame.presets, "NeuronDropDownOptionFull")
	f:SetWidth(160)
	f:SetHeight(25)
	f:SetTextInsets(7,3,0,0)
	f.text:SetText(L.REMAPTO)
	f:SetPoint("BOTTOMLEFT", barOpt.remap, "BOTTOMRIGHT", 25, 0)
	f:SetPoint("BOTTOMRIGHT", frame.presets.secondary, "BOTTOMRIGHT", -23, -35)
	f:SetScript("OnTextChanged", remapToOnTextChanged)
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
	f.text:SetText(L.CUSTOM_OPTION)
	f.text:SetWordWrap(true)

	f = CreateFrame("EditBox", "$parentCostomStateEdit", frame.custom, "NeuronEditBoxTemplateSmall")
	--f:SetWidth(550)
	f:SetHeight(26)
	f:SetPoint("TOPLEFT", frame.custom, "TOPLEFT", 10, -30)
	f:SetPoint("TOPRIGHT", frame.custom, "TOPRIGHT", -10, -30)
	f:SetJustifyH("LEFT")
	f:SetTextInsets(10, 0, 0, 0)
	f:SetMaxLetters(0)

	f:SetScript("OnEnterPressed", updateCustomState)
	f:SetScript("OnTabPressed", updateCustomState)
	f:SetScript("OnEscapePressed", updateCustomState)
	frame.search = f

	barOpt.customstate = f

	NEURON.SubFrameBlackBackdrop_OnLoad(f)
end

--	paged = 	paged1;	paged2;	paged3;	paged4;	paged5;	paged6;

--	stance =	stance0;	stance1;	stance2;	stance3;	stance4;	stance5;	stance6;

--	modkey =	alt0;		alt1;		ctrl0;	ctrl1;	shift0;	shift1;

--	sit1 =	reaction0;	reaction1;	combat0;	combat1;	group0;	group1;	group2;

--	sit2 = 	stealth0;	stealth1;	fishing0;	fishing1;	pet0;		pet1;

--	control = 	vehicle0;	vehicle1;	possess0;	possess1;	override0;	override1;	extrabar0;	extrabar1;

function NEURON:VisEditor_OnLoad(frame)
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
	f.text:SetText(L.BAR_VISABLE_STATES)
	f.selected = true

	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)
end


local numVisShown = 21

function NEURON.VisEditorScrollFrame_OnLoad(self)

	self.offset = 0
	self.scrollChild = _G[self:GetName().."ScrollChildFrame"]

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)

	local anchor, button, lastButton, rowButton, count = false, false, false, false, 1

	for i=1,numVisShown do

		button = CreateFrame("CheckButton", self:GetName().."Button"..i, self:GetParent(), "NeuronOptionsCheckButtonTemplate")

		button.frame = self:GetParent()
		button.numShown = numVisShown
		button:SetCheckedTexture("Interface\\Addons\\Neuron\\Images\\RoundCheckGreen.tga")
		button:SetScript("OnClick", setBarVisability)


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
		button:SetFrameLevel(self:GetFrameLevel()+2)

		if (not anchor) then
			button:SetPoint("TOPLEFT", 10, -8)
			anchor = button; lastButton = button
		elseif (count == 8) then
			button:SetPoint("LEFT", anchor, "RIGHT", 125, 0)
			anchor = button; lastButton = button; count = 1
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -6)
			lastButton = button
		end
		count = count + 1
	end

	NEURON.VisEditorScrollFrameUpdate()
end

local VisSTateList = {}

function NEURON.VisEditorScrollFrameUpdate(frame, tableList, alt)

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
				text = L.STEALTH0
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


function NEURON:StateList_OnLoad(frame)

	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

end


local numStatesShown = 12

function NEURON.SecondaryPresetsScrollFrame_OnLoad(self)
	--NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)
	self.offset = 0
	self.scrollChild = _G[self:GetName().."ScrollChildFrame"]

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)

	local anchor, button, lastButton, rowButton, count = false, false, false, false, 1

	for i=1,numStatesShown do
		button = CreateFrame("CheckButton", "PresetsScrollFrameButton"..i, self:GetParent(), "NeuronOptionsCheckButtonTemplate")

		button.frame = self:GetParent()
		button.numShown = numStatesShown
		--button:SetCheckedTexture("Interface\\Addons\\Neuron\\Images\\RoundCheckGreen.tga")
		button:SetScript("OnClick", setBarActionState)


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
		button:SetFrameLevel(self:GetFrameLevel()+2)

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

	NEURON.SecondaryPresetsScrollFrameUpdate()
end

local SecondaryPresetsList = {}

function NEURON.SecondaryPresetsScrollFrameUpdate(frame, tableList, alt)

	if (not NeuronBarEditorBarStatesActionEditor:IsVisible()) then return end
	local bar = Neuron.CurrentBar

	if (not tableList) then

		wipe(SecondaryPresetsList)

		tableList = NEURON.MANAGED_ACTION_STATES
	end

	if (not frame) then
		frame = NeuronBarEditorBarStatesActionEditorPresetsSecondaryScrollFrame
	end

	local dataOffset, count, data = FauxScrollFrame_GetOffset(frame), 1, {}
	local button, text

	for k in pairs(tableList) do

		if (not MAS[k].homestate and (k ~= "prowl") and (k ~= "extrabar") and (k ~= "custom") or ((NEURON.class == "ROGUE") and k ~= "stealth")) then
			data[count] = k; count = count + 1

		end
	end

	if(IsDruid ) then
		data[count] = "prowl"; count = count + 1
	end

	table.sort(data)

	frame:Show()

	for i=1,numStatesShown do

		button = _G["PresetsScrollFrameButton"..i] --"NeuronBarEditorBarStatesSecondaryPresetsScrollFrameButton"..i]
		button:SetChecked(nil)

		count = dataOffset + i

		if (data[count]) then
			text = (L["GUI_"..data[count]:upper()])

			button.option = data[count]
			button:SetChecked(bar.cdata[button.option ])
			button.text:SetText(text)

			button:Enable()
			button:Show()
			button:SetWidth(18)
			button:SetHeight(18)

			if(data[count] == "prowl" and IsDruid ) then
				f.option = "prowl"
				f.stance = IsDruid
			end
			--else
		else

			button:Hide()
		end
	end

	FauxScrollFrame_Update(frame, #data, numStatesShown, 18)
end

function NEURON:BarStates_OnLoad(frame)

	--NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

end

--- OnLoad event for Bar editor Spell Target Options frame
function NEURON:TargetOptions_OnLoad(frame)
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
	AceGUI:RegisterAsContainer(widget)
	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)
end

-- OnLoad event for Bar editor Spell Target Options frame
function NEURON:FlyoutOptions_OnLoad(frame)
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
	AceGUI:RegisterAsContainer(widget)
	--NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

end

function NEURON:ObjectEditor_OnLoad(frame)

	NEURON.SubFramePlainBackdrop_OnLoad(frame)

	frame:RegisterForDrag("LeftButton", "RightButton")
	frame.bottom = 0

	frame:SetHeight(height)
end

function NEURON:ObjectEditor_OnShow(frame)

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

function NEURON:ObjectEditor_OnHide(frame)

end

function NEURON:ActionList_OnLoad(frame)

	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

end

function NEURON:ActionListScrollFrame_OnLoad(frame)

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
							self.bar:SetFauxState(self.state)
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

	NEURON.ActionListScrollFrameUpdate()
end

local stateList = {}

function NEURON.ActionListScrollFrameUpdate(frame)
	if (not NeuronButtonEditorActionList:IsVisible()) then return end

	local bar, i

	if (NEURON.CurrentObject and NEURON.CurrentObject.bar) then

		wipe(stateList)

		bar = NEURON.CurrentObject.bar

		stateList["00"..L.HOMESTATE] = "homestate"

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
							stateList["00"..name] = "homestate"; stateList["00"..L.HOMESTATE] = nil
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
local function specUpdateIcon(button,state)
	--data = button.specdata[buttonSpec][state]
	--specUpdateIcon(button, data))--button.iconframeicon:GetTexture())
	--((button.bar.cdata.dualSpec and specoveride) or 1)
	--data.macro_Icon
	local texture = "" --"INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	local buttonSpec = button:GetSpec()
	local data = button.specdata[specoveride][state]

	if (button.bar.cdata.dualSpec and specoveride ~= buttonSpec) then
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


function NEURON:MacroEditorUpdate()
	if (NEURON.CurrentObject and NEURON.CurrentObject.objType == "ACTIONBUTTON") then
		local button, NBTNE = NEURON.CurrentObject, NeuronButtonEditor
		local state = button.bar.handler:GetAttribute("fauxstate")
		local buttonSpec = button:GetSpec()

		if (button.bar.cdata.dualSpec) then
			buttonSpec = specoveride--button:GetSpec()

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
			button.specdata[buttonSpec][state] = NEURON.BUTTON:MACRO_build()

			data = button.specdata[buttonSpec][state]
			button:UpdateFlyout()
			button:BuildStateData()
			button:SetType()
		end

		if (data) then
			NBTNE.macroedit.edit:SetText(data.macro_Text)
			if (not data.macro_Icon) then
				NBTNE.macroicon.icon:SetTexture(specUpdateIcon(button, state))--button.iconframeicon:GetTexture())
			elseif (data.macro_Icon == "BLANK") then
				NBTNE.macroicon.icon:SetTexture("")
			else
				NBTNE.macroicon.icon:SetTexture(data.macro_Icon)
			end
			--print(data.macro_Name)
			NBTNE.nameedit:SetText(data.macro_Name)
			NBTNE.noteedit:SetText(data.macro_Note)
			NBTNE.usenote:SetChecked(data.macro_UseNote)

		else
			--print("notinghere")
			--button.specdata[buttonSpec][state] = NEURON.BUTTON:MACRO_build()
			--NEURON.BUTTON:MACRO_build(button.specdata[buttonSpec][state])
			---print(button.specdata[buttonSpec][state])
			--end
		end
	end
end

function NEURON.ButtonEditorUpdate(reset)

	if (reset and NEURON.CurrentObject) then

		local bar = NEURON.CurrentObject.bar

		bar.handler:SetAttribute("fauxstate", bar.handler:GetAttribute("activestate"))

		NeuronButtonEditor.macroicon.icon:SetTexture("")

		specoveride = GetSpecialization() or 1 --GetActiveSpecGroup()
	end

	NEURON.ActionListScrollFrameUpdate()

	NEURON:MacroEditorUpdate()

end

function NEURON:ButtonEditor_OnShow(frame)

	NEURON.ButtonEditorUpdate(true)

end

function NEURON:ButtonEditor_OnHide(frame)


end


--- Triggers when macro editor's text box loses focus
-- @param self: macro editor frame
local function macroText_OnEditFocusLost(self)

	self.hasfocus = nil

	local button = NEURON.CurrentObject

	if (button) then

		button:UpdateFlyout()
		button:BuildStateData()
		button:SetType()

		NEURON:MacroEditorUpdate()
	end
end


--- Triggers when text in the  macro editor changes
-- @param self: macro editor frame
local function macroText_OnTextChanged(self)

	if (self.hasfocus) then
		local button = NEURON.CurrentObject
		local buttonSpec = ((button.bar.cdata.dualSpec and specoveride) or 1) --specoveride --button:GetSpec()
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and buttonSpec and state) then
			if button.specdata[buttonSpec][state] then
				button.specdata[buttonSpec][state].macro_Text = self:GetText()
				button.specdata[buttonSpec][state].macro_Watch = false
			else
				--print("notinghere")
				--button.specdata[buttonSpec][state] = NEURON.BUTTON:MACRO_build()
				--NEURON.BUTTON:MACRO_build(button.specdata[buttonSpec][state])
				--print(button.specdata[buttonSpec][state])
			end

		end
	end
end

--- Triggers when text in the  macro editor changes
-- @param self: macro editor frame
local function macroButton_Changed(self, button, down)

	local object = NEURON.CurrentObject

	local data = object.data
	local buttonSpec = ((object.bar.cdata.dualSpec and specoveride) or 1)
	local state = object.bar.handler:GetAttribute("fauxstate")

	--handler to check if viewing non current spec button settings
	if (specoveride ~= object:GetSpec()) then
		data = object.specdata[buttonSpec][state]
	end

	if (object and data) then

		if (self.texture == "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") then
			data.macro_Icon = false
		else
			data.macro_Icon = self.texture
		end
		object:MACRO_UpdateIcon()

		NEURON:UpdateObjectGUI()
	end

	self:SetFrameLevel(self.fl-1)
	self.click = true
	self.elapsed = 0
	self:GetParent():Hide()
	self:SetChecked(nil)

end


--- Triggers when the text in the macro editor's name text box changes
-- @param self: macro editor name edit box frame
local function macroNameEdit_OnTextChanged(self)

	if (strlen(self:GetText()) > 0) then
		self.text:Hide()
	end

	if (self.hasfocus) then

		local button = NEURON.CurrentObject
		local buttonSpec = ((button.bar.cdata.dualSpec and specoveride) or 1) --specoveride --button:GetSpec()
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and buttonSpec and state) then
			button.specdata[buttonSpec][state].macro_Name = self:GetText()
		end

	elseif (strlen(self:GetText()) <= 0) then
		self.text:Show()
	end
end


--- Triggers when the text in the macro editor's note text box changes
-- @param self: macro editor note edit box frame
local function macroNoteEdit_OnTextChanged(self)

	if (strlen(self:GetText()) > 0) then
		self.text:Hide()
		self.cb:Show()
	else
		self.cb:Hide()
	end

	if (self.hasfocus) then

		local button = NEURON.CurrentObject
		local buttonSpec = ((button.bar.cdata.dualSpec and specoveride) or 1) --specoveride --button:GetSpec()
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and buttonSpec and state) then
			button.specdata[buttonSpec][state].macro_Note = self:GetText()
		end
	end
end


--TODO Revisit & Check description
--- Triggers when macro editor loses focus
-- @param self: macro editor frame
local function macroOnEditFocusLost(self)
	self.hasfocus = nil

	local button = NEURON.CurrentObject

	if (button) then
		button:MACRO_UpdateAll(true)
	end

	if (self.text and strlen(self:GetText()) <= 0) then
		self.text:Show()
	end
end

local function macroIconOnClick(frame)

	if (frame.iconlist:IsVisible()) then
		frame.iconlist:Hide()
	else
		frame.iconlist:Show()
	end

	frame:SetChecked(nil)

end



local IconList = {}

function updateIconList()

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


function NEURON.MacroIconListUpdate(frame)

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

	FauxScrollFrame_Update(frame, ceil(numIcons/14), 1, 1, nil, nil, nil, nil, nil, nil, true)

end


local function customPathOnShow(self)

	local button = NEURON.CurrentObject

	if (button) then

		if (button.data.macro_Icon) then
			--Needs fixing
			local text = button.data.macro_Icon:gsub("INTERFACE\\", "")

			self:SetText(text)

		else
			self:SetText("")
		end
	else
		self:SetText("")
	end

	self:SetCursorPosition(0)
end

local function customDoneOnClick(self)

	local button = NEURON.CurrentObject

	if (button) then

		local text = self.frame.custompath:GetText()

		if (#text > 0) then

			text = "INTERFACE\\"..text:gsub("\\", "\\")

			button.data.macro_Icon = text

			button:MACRO_UpdateIcon()

			NEURON:UpdateObjectGUI()
		end
	end

	self:GetParent():Hide()
end

--Resets all the fields in the editor for the curently selected buttton
local function ResetButtonFields()
	local button, NBTNE = NEURON.CurrentObject, NeuronButtonEditor
	local state = button.bar.handler:GetAttribute("fauxstate")
	local buttonSpec = ((button.bar.cdata.dualSpec and specoveride) or 1) --specoveride --button:GetSpec()
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


function NEURON:ButtonEditor_OnLoad(frame)

	frame:RegisterForDrag("LeftButton", "RightButton")

	NEURON.Editors.ACTIONBUTTON[1] = frame
	NEURON.Editors.ACTIONBUTTON[4] = NEURON.ButtonEditorUpdate

	frame.tabs = {}
	frame.specs = {}

	local f

	f = CreateFrame("Frame", nil, frame)
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -10)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then NEURON:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f.elapsed = 0
	frame.macro = f

	f = CreateFrame("ScrollFrame", "$parentMacroEditor", frame.macro, "NeuronScrollFrameTemplate2")
	f:SetPoint("TOPLEFT", frame.macro, "TOPLEFT", 2, -95)
	f:SetPoint("BOTTOMRIGHT", -2, 20)
	f.edit:SetWidth(350)
	f.edit:SetHeight(200)
	f.edit:SetScript("OnTextChanged", macroText_OnTextChanged)
	f.edit:SetScript("OnEditFocusGained", function(self) self.hasfocus = true self:SetText(self:GetText():gsub("#autowrite\n", "")) end)
	f.edit:SetScript("OnEditFocusLost", macroText_OnEditFocusLost)
	frame.macroedit = f

	f = CreateFrame("Button", "focus", frame.macro)
	f:SetPoint("TOPLEFT", frame.macroedit, "TOPLEFT", -10, 10)
	f:SetPoint("BOTTOMRIGHT", -18, 0)
	f:SetWidth(350)
	f:SetHeight(200)
	f:SetScript("OnClick", function(self) self.macroedit.edit:SetFocus() end)
	f.macroedit = frame.macroedit
	frame.macrofocus = f

	f = CreateFrame("Frame", nil, frame.macroedit)
	f:SetPoint("TOPLEFT", -10, 10)
	f:SetPoint("BOTTOMRIGHT", 4, -20)
	f:SetFrameLevel(frame.macroedit.edit:GetFrameLevel()-1)
	frame.macroeditBG = f

	NEURON.SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronMacroIconButtonTemplate")
	f:SetID(0)
	f:SetPoint("BOTTOMLEFT", frame.macroedit, "TOPLEFT", -6, 15)
	f:SetWidth(54)
	f:SetHeight(54)
	f:SetScript("OnEnter", function() end)
	f:SetScript("OnLeave", function() end)
	f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	f.slot:SetVertexColor(0.5,0.5,0.5,1)
	f.onclick_func = macroIconOnClick
	f.onupdate_func = function() end
	f.elapsed = 0
	f.click = false
	f.parent = frame
	f.iconlist = frame.iconlist
	f.iconlist:SetScript("OnShow", function(self) self.scrollbar.scrollStep = 1 NeuronObjectEditor.done:Hide() updateIconList() NEURON.MacroIconListUpdate(self) end)
	f.iconlist:SetScript("OnHide", function() NeuronObjectEditor.done:Show() end)
	frame.macroicon = f

	f = CreateFrame("Button", nil, frame.macro)
	f:SetPoint("BOTTOMLEFT", frame.macroicon, "BOTTOMRIGHT", 2, -7)
	f:SetWidth(34)
	f:SetHeight(34)
	--f:SetScript("OnClick", function(self) SetActiveSpecGroup(GetActiveSpecGroup() == 1 and 2 or 1);  end)
	f:SetScript("OnClick", ResetButtonFields)
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

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronCheckButtonTemplate1")
	f:SetWidth(68)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.reset_button, "RIGHT", -1, 1.25)
	f:SetScript("OnClick", function(self) SpecOnClick(self); specoveride = 1 ; NEURON.ButtonEditorUpdate() end)
	f:SetChecked(nil)
	f.text:SetText("Spec1")
	f.tooltipText = L.GUI_SPEC1
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
	f:SetScript("OnClick", function(self) SpecOnClick(self); specoveride = 2 ; NEURON.ButtonEditorUpdate() end)
	f:SetChecked(nil)
	f.text:SetText("Spec2")
	f.tooltipText = L.GUI_SPEC2
	frame.spec2 = f; frame.specs[f] = frame.spec2

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronCheckButtonTemplate1")
	f:SetWidth(68)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.spec2, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) SpecOnClick(self); specoveride = 3 ; NEURON.ButtonEditorUpdate() end)
	f:SetChecked(nil)
	f.text:SetText("Spec3")
	f.tooltipText = L.GUI_SPEC3
	frame.spec3 = f; frame.specs[f] = frame.spec3

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronCheckButtonTemplate1")
	f:SetWidth(68)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.spec3, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) SpecOnClick(self); specoveride = 4 ; NEURON.ButtonEditorUpdate() end)
	f:SetChecked(nil)
	f.text:SetText("Spec4")
	f.tooltipText = L.GUI_SPEC4
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
	f:SetScript("OnTextChanged", macroNameEdit_OnTextChanged)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() end macroOnEditFocusLost(self) end)
	f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame.nameedit = f

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	f.text:SetPoint("CENTER")
	f.text:SetJustifyH("CENTER")
	f.text:SetText(L.MACRO_NAME)

	f = CreateFrame("Frame", nil, frame.nameedit)
	f:SetPoint("TOPLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", 0, 0)
	f:SetFrameLevel(frame.nameedit:GetFrameLevel()-1)

	NEURON.SubFrameBlackBackdrop_OnLoad(f)

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
	f:SetScript("OnTextChanged", macroNoteEdit_OnTextChanged)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() end macroOnEditFocusLost(self) end)
	f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame.noteedit = f

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	f.text:SetPoint("CENTER", 10, 0)
	f.text:SetJustifyH("CENTER")
	f.text:SetText(L.MACRO_EDITNOTE)

	f = CreateFrame("Frame", nil, frame.noteedit)
	f:SetPoint("TOPLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", 15, 0)
	f:SetFrameLevel(frame.noteedit:GetFrameLevel()-1)

	NEURON.SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("CheckButton", nil, frame.macro, "NeuronOptionsCheckButtonTemplate")
	f:SetID(0)
	f:SetWidth(16)
	f:SetHeight(16)
	f:SetScript("OnShow", function() end)
	f:SetScript("OnClick", function() end)
	f:SetPoint("RIGHT", frame.noteedit, "RIGHT", 12, 0)
	f:SetFrameLevel(frame.noteedit:GetFrameLevel()+1)
	f:Hide()
	f.tooltipText = L.MACRO_USENOTE
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
			macroButton_Changed(self, button, down)
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
	f:SetScript("OnEnterPressed", function(self) updateIconList() NEURON.MacroIconListUpdate() self:ClearFocus() self.hasfocus = nil end)
	f:SetScript("OnTabPressed", function(self) updateIconList() NEURON.MacroIconListUpdate() self:ClearFocus() self.hasfocus = nil end)
	f:SetScript("OnEscapePressed", function(self) self:SetText("") updateIconList() NEURON.MacroIconListUpdate()  self:ClearFocus() self.hasfocus = nil end)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.cancel:Show() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() self.cancel:Hide() end self.hasfocus = nil end)
	f:SetScript("OnTextChanged", function(self) if (strlen(self:GetText()) < 1 and not self.hasfocus) then self.text:Show() self.cancel:Hide() end end)
	frame.search = f

	NEURON.SubFrameBlackBackdrop_OnLoad(f)

	f.cancel = CreateFrame("Button", nil, f)
	f.cancel:SetWidth(20)
	f.cancel:SetHeight(20)
	f.cancel:SetPoint("RIGHT", -3, 0)
	f.cancel:SetScript("OnClick", function(self) self.parent:SetText("") updateIconList() NEURON.MacroIconListUpdate()  self.parent:ClearFocus() self.parent.hasfocus = nil end)
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
	f.text:SetText(L.SEARCH)

	f = CreateFrame("Button", nil, frame.iconlist, "NeuronCheckButtonTemplate1")
	f:SetWidth(122)
	f:SetHeight(35)
	f:SetPoint("TOPLEFT", frame.search, "TOPRIGHT", -1, 4)
	f:SetScript("OnClick", function(self) self:Hide() self.frame.search:Hide() self.frame.customdone:Show() self.frame.customcancel:Show() self.frame.custompath:Show() end)
	f.text:SetText(L.CUSTOM_ICON)
	f.frame = frame
	frame.customicon = f

	f = CreateFrame("Button", nil, frame.iconlist, "NeuronCheckButtonTemplate1")
	f:SetWidth(60)
	f:SetHeight(35)
	f:SetPoint("TOPLEFT", frame.search, "TOPRIGHT", -1, 4)
	f:SetScript("OnClick", function(self) self:Hide()  self.frame.customcancel:Hide() self.frame.custompath:Hide() self.frame.customicon:Show() self.frame.search:Show() customDoneOnClick(self) end)
	f:SetFrameLevel(frame.customicon:GetFrameLevel()+1)
	f:Hide()
	f.text:SetText(L.DONE)
	f.frame = frame
	frame.customdone = f

	f = CreateFrame("Button", nil, frame.iconlist, "NeuronCheckButtonTemplate1")
	f:SetWidth(60)
	f:SetHeight(35)
	f:SetPoint("LEFT", frame.customdone, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) self:Hide() self.frame.customdone:Hide() self.frame.custompath:Hide() self.frame.customicon:Show() self.frame.search:Show() end)
	f:SetFrameLevel(frame.customicon:GetFrameLevel()+1)
	f:Hide()
	f.text:SetText(L.CANCEL)
	f.frame = frame
	frame.customcancel = f

	f = CreateFrame("EditBox", nil, frame.iconlist, "NeuronEditBoxTemplateSmall")
	f:SetWidth(378)
	f:SetHeight(30)
	f:SetJustifyH("LEFT")
	f:SetPoint("TOPLEFT",  frame.search, "TOPLEFT", 0, 0)
	f:SetScript("OnShow", customPathOnShow)
	--f:SetFrameLevel(frame.search:GetFrameLevel()+1)
	f:Hide()
	f:SetScript("OnEscapePressed", function(self) NEURON:ButtonEditorIconList_ResetCustom(self.frame) end)
	f:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	--f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.cancel:Show() self.hasfocus = true end)
	--f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() self.cancel:Hide() end self.hasfocus = nil end)
	f:SetScript("OnTextChanged", function(self) self:SetText(self:GetText():upper()) end)
	f.frame = frame
	frame.custompath = f

	NEURON.SubFrameBlackBackdrop_OnLoad(f)

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	f.text:SetPoint("LEFT", 8, 0)
	f.text:SetJustifyH("LEFT")
	f.text:SetText(L.PATH..": INTERFACE\\")

	f:SetTextInsets(f.text:GetWidth()+5, 0, 0, 0)


	f = CreateFrame("Frame", nil, frame)
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -10)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then NEURON:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f:Hide()
	f.elapsed = 0
	frame.action = f

	f = CreateFrame("Frame", nil, frame)
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -25)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then NEURON:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f:SetScript("OnShow", function(self) LibStub("AceConfigDialog-3.0"):Open(addonName, NBTNE.ACEmenu , "flyoutoptions") end)
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

	local f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(125)
	f:SetHeight(28)
	f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -28, -8.5)
	f:SetScript("OnClick", function(self) TabsOnClick(self, true) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText(L.OPTIONS)
	frame.tab3 = f; frame.tabs[f] = frame.options

	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(125)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab3, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText(L.ACTION)
	frame.tab2 = f; frame.tabs[f] = frame.action

	f = CreateFrame("CheckButton", nil, frame, "NeuronCheckButtonTemplate1")
	f:SetWidth(125)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab2, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(1)
	f.text:SetText(L.MACRO)
	frame.tab1 = f; frame.tabs[f] = frame.macro



end

function NEURON:ButtonEditorIconList_ResetCustom(frame)

	frame.customdone:Hide()
	frame.customcancel:Hide()
	frame.custompath:Hide()

	--frame.search:Show()
	frame.customicon:Show()

end


function NEURON.ColorPicker_OnLoad(self)

	self:SetFrameStrata("TOOLTIP")
	self.apply.text:SetText(L.APPLY)
	self.cancel.text:SetText(L.CANCEL)
end


function NEURON.ColorPicker_OnShow(self)
	local r,g,b = self:GetColorRGB()
	self.redvalue:SetText(r); self.redvalue:SetCursorPosition(0)
	self.greenvalue:SetText(g); self.greenvalue:SetCursorPosition(0)
	self.bluevalue:SetText(b); self.bluevalue:SetCursorPosition(0)
	self.hexvalue:SetText(string.upper(string.format("%02x%02x%02x", math.ceil((r*255)), math.ceil((g*255)), math.ceil((b*255))))); self.hexvalue:SetCursorPosition(0)
end

function NEURON.ColorPicker_OnColorSelect(self, r, g, b)
	self.redvalue:SetText(r)
	self.greenvalue:SetText(g)
	self.bluevalue:SetText(b)
	self.hexvalue:SetText(string.upper(string.format("%02x%02x%02x", math.ceil((r*255)), math.ceil((g*255)), math.ceil((b*255)))))
end

function NEURON:MainMenu_OnLoad(frame)

	NEURON.SubFrameHoneycombBackdrop_OnLoad(frame)

	frame:SetWidth(width)
	frame:SetHeight(height)

	frame:RegisterEvent("ADDON_LOADED")
	frame:RegisterForDrag("LeftButton", "RightButton")

end

--not an optimal solution, but it works for now
local function hookHandler(handler)

	handler:HookScript("OnAttributeChanged", function(self,name,value)

		if (NeuronObjectEditor:IsVisible() and self == NEURON.CurrentObject.bar.handler and name == "activestate" and not NeuronButtonEditor.macroedit.edit.hasfocus) then
			NeuronButtonEditor.macro.elapsed = 0
		end

	end)
end

local function runUpdater(self, elapsed)

	self.elapsed = elapsed

	if (self.elapsed > 0) then

		NEURON:UpdateBarGUI()
		NEURON:UpdateObjectGUI()

		self:Hide()
	end
end

local updater = CreateFrame("Frame", nil, UIParent)
updater:SetScript("OnUpdate", runUpdater)
updater.elapsed = 0
updater:Hide()

local function hookMountButtons()

	if (MountJournal.ListScrollFrame.buttons) then

		for i,btn in pairs(MountJournal.ListScrollFrame.buttons) do
			btn.DragButton:HookScript("OnClick", modifiedMountClick)
		end
	end
end

local function hookPetJournalButtons()

	if (PetJournal.listScroll.buttons) then

		for i,btn in pairs(PetJournal.listScroll.buttons) do
			btn.dragButton:HookScript("OnClick", modifiedPetJournalClick)
		end
	end
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Neuron-GUI") then

		NMM = NeuronMainMenu
		NBE = NeuronBarEditor
		NOE = NeuronObjectEditor
		NBTNE = NeuronButtonEditor

		MAS = NEURON.MANAGED_ACTION_STATES

		for _,bar in pairs(NEURON.BARIndex) do
			hookHandler(bar.handler)
		end

		hooksecurefunc("SpellButton_OnModifiedClick", modifiedSpellClick)
		hooksecurefunc("HandleModifiedItemClick", modifiedItemClick)
		hooksecurefunc("OpenStackSplitFrame", openStackSplitFrame)

		if (MountJournal) then
			hookMountButtons(); hookPetJournalButtons()
		end

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
		AceGUI:RegisterAsContainer(widget)

	elseif (event == "ADDON_LOADED" and ... == "Blizzard_PetJournal") then

		hookMountButtons()
		hookPetJournalButtons()

	elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then

		updater.elapsed = 0
		updater:Show()

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
--frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")


--- ACE GUI OPTION GET & SET FUnctions
-- @param self: macro editor frame
local function settingGetter(info)
	if Neuron.CurrentBar then
		return Neuron.CurrentBar.cdata[ info[#info]]
	end
end


local function SetBarCastTarget(value, toggle)
	if Neuron.CurrentBar then
		Neuron.CurrentBar:SetCastingTarget(value, true, toggle)
	end
end

--/flyout s+,i+:teleport,!drake:linear:top:bottom:1:click
local FLYOUTMACRO = {
	["types"] = {
		["item"] = "item"},
	["keys"] = "",
	["shape"] = "LINEAR",
	["attach"] = "TOP",
	["relative"] = "BOTTOM",
	["columns"] = 3,
	["mouse"] = "CLICK",
}

local flyouttypes = {}
local function flyoutsetter(info, value)
	FLYOUTMACRO[info[#info]]= value
end

local function flyouttypesetter(info, value)
	if value then
		FLYOUTMACRO["types"][info[#info]]= value
	else
		FLYOUTMACRO["types"][info[#info]] = nil
	end
end

local function flyouttypegitter(info)
	return FLYOUTMACRO["types"][info[#info]]
end


local function flyoutgetter(info)
	return FLYOUTMACRO[info[#info]]
end


local finalmacro = ""


local function createflyoutmacro()
	local macrotypes = ""
	for name,value in pairs(FLYOUTMACRO["types"]) do
		macrotypes = macrotypes..","..name
	end

	finalmacro = "/flyout "..macrotypes..":"..FLYOUTMACRO["keys"]..":"..FLYOUTMACRO["shape"]..":"..FLYOUTMACRO["attach"]..":"..FLYOUTMACRO["relative"]..":"..FLYOUTMACRO["columns"]..":"..FLYOUTMACRO["mouse"]
end


--ACE GUI OPTION TABLE for Bar Targeting
local target_options = {
	name = "Neuron",
	type = 'group',
	args = {
		moreoptions={
			name = "Options",
			type = "group",
			args={
				selfCast = {
					order = 10,
					type = "toggle",
					name = L.SPELL_TARGETING_SELF_CAST_MODIFIER,
					desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return settingGetter(info) end, --getFunc,
					set = function(info, value) SetBarCastTarget("selfCast", value) end,
				},
				setselfcastmod = {
					order = 20,
					type = "select",
					name = L.SPELL_TARGETING_SELF_CAST_MODIFIER,
					desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_SELECT,
					get = function(info) return GetModifiedClick("SELFCAST") end,
					set = function(info, value) SetModifiedClick("SELFCAST", value); SaveBindings(GetCurrentBindingSet() or 1); NEURON.BUTTON:UpdateMacroCastTargets(true) end,
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
					name = L.SPELL_TARGETING_FOCUS_CAST_MODIFIER,
					desc = L.SPELL_TARGETING_FOCUS_CAST_MODIFIER_TOGGLE,
					get = function(info)  return settingGetter(info) end, --getFunc,
					set = function(info, value) SetBarCastTarget("focusCast", value) end,
				},
				setfocuscastmod = {
					order = 60,
					type = "select",
					name = L.SPELL_TARGETING_FOCUS_CAST_MODIFIER,
					desc = L.SPELL_TARGETING_FOCUS_CAST_MODIFIER_SELECT,
					get = function(info) return GetModifiedClick("FOCUSCAST") end,
					set = function(info, value) SetModifiedClick("FOCUSCAST", value); SaveBindings(GetCurrentBindingSet() or 1); NEURON.BUTTON:UpdateMacroCastTargets(true) end,
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
					name = L.SPELL_TARGETING_SELF_CAST_RIGHTCLICK,
					desc = L.SPELL_TARGETING_SELF_CAST_RIGHTCLICK_TOGGLE,
					get = function(info)  return settingGetter(info) end, --getFunc,
					set = function(info, value) SetBarCastTarget("rightClickTarget", value) end,
				},
				rightclickselfcast_nl = {
					order = 90,
					type = "description",
					name = "",
				},
				mouseOverCast = {
					order = 180,
					type = "toggle",
					name = L.SPELL_TARGETING_MOUSEOVER_CAST,
					desc = L.SPELL_TARGETING_MOUSEOVER_CAST_MODIFIER_TOGGLE,
					get = function(info)  return settingGetter(info) end, --getFunc,
					set = function(info, value) SetBarCastTarget("mouseOverCast", value) end,
				},
				mouseovermod = {
					order = 301,
					type = "select",
					name = L.SPELL_TARGETING_MOUSEOVER_CAST_MODIFIER,
					desc = L.SPELL_TARGETING_MOUSEOVER_CAST_MODIFIER_SELECT,
					get = function() return NeuronCDB.mouseOverMod end, --getFunc,
					set = function(info, value) NeuronCDB.mouseOverMod = value; NEURON.BUTTON:UpdateMacroCastTargets(true) end,
					values = { NONE = _G.NONE, ALT = _G.ALT_KEY_TEXT, SHIFT = _G.SHIFT_KEY_TEXT, CTRL = _G.CTRL_KEY_TEXT },
				},
				mouseovermod_desc = {
					order = 302,
					type = "description",
					name = "\n" .. L.SPELL_TARGETING_MODIFIER_NONE_REMINDER,
				},
			},
		},

		flyoutoptions={
			name = "Options",
			type = "group",
			args={
				item = {
					order = 10,
					type = "toggle",
					name = "Item",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyouttypegitter(info) end, --getFunc,
					set = function(info, value) flyouttypesetter(info, value) end,
					--values = { ITEM = "Item", SPELL = "Spell", MOUNT = "Mount", COMPANION="Companion", TYPE = "Type", PROFESSION= "Profession", FUN = "Fun", FAVORITE = "Favorite" },
				},
				spell = {
					order = 10,
					type = "toggle",
					name = "Spell",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyouttypegitter(info) end, --getFunc,
					set = function(info, value) flyouttypesetter(info, value) end,
				},
				mount = {
					order = 10,
					type = "toggle",
					name = "Mount",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyouttypegitter(info) end, --getFunc,
					set = function(info, value) flyouttypesetter(info, value) end,
				},
				companion = {
					order = 10,
					type = "toggle",
					name = " Companion",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyouttypegitter(info) end, --getFunc,
					set = function(info, value) flyouttypesetter(info, value) end,
				},
				types = {
					order = 10,
					type = "toggle",
					name = "Type",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyouttypegitter(info) end, --getFunc,
					set = function(info, value) flyouttypesetter(info, value) end,
				},
				profession = {
					order = 10,
					type = "toggle",
					name = "Profession",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyouttypegitter(info) end, --getFunc,
					set = function(info, value) flyouttypesetter(info, value) end,
				},
				fun = {
					order = 10,
					type = "toggle",
					name = "Fun",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyouttypegitter(info) end, --getFunc,
					set = function(info, value) flyouttypesetter(info, value) end,
				},
				favoriate = {
					order = 10,
					type = "toggle",
					name = "Favoriates",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyouttypegitter(info) end, --getFunc,
					set = function(info, value) flyouttypesetter(info, value) end,
				},
				--types = {
				--order = 10,
				--type = "multiselect",
				--name = "Flyout Types",
				--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
				--get = function(info)  return settingGetter(info) end, --getFunc,
				--set = function(info, value) print(value) end,
				--values = { ITEM = "Item", SPELL = "Spell", MOUNT = "Mount", COMPANION="Companion", TYPE = "Type", PROFESSION= "Profession", FUN = "Fun", FAVORITE = "Favorite" },
				--},
				keys = {
					order = 11,
					type = "input",
					name = "Keys",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyoutgetter(info) end, --getFunc,
					set = function(info, value) flyoutsetter(info, value) end,
				},
				shape = {
					order = 12,
					type = "select",
					name = "Shape",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyoutgetter(info) end, --getFunc,
					set = function(info, value) flyoutsetter(info, value) end,
					values = { LINEAR = "Linear", CIRCULAR = "Circular" },
				},
				attach = {
					order = 13,
					type = "select",
					name = "Attach Point",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyoutgetter(info) end, --getFunc,
					set = function(info, value) flyoutsetter(info, value) end,
					values = { LEFT = "left", RIGHT = "right",TOP = "top", BOTTOM = "bottom",TOPLEFT = "topleft", TOPRIGHT = "topright",BOTTOMLEFT = "bottomleft", BOTTOMRIGHT = "BottomRight", CENTER = "Center" },
				},
				relative = {
					order = 14,
					type = "select",
					name = "Relative to",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyoutgetter(info) end, --getFunc,
					set = function(info, value) flyoutsetter(info, value) end,
					values = { LEFT = "left", RIGHT = "right",TOP = "top", BOTTOM = "bottom",TOPLEFT = "topleft", TOPRIGHT = "topright",BOTTOMLEFT = "bottomleft", BOTTOMRIGHT = "BottomRight", CENTER = "Center" },
				},
				columns = {
					order = 15,
					type = "range",
					name = "Columns/Radius",
					min = -25,
					max = 25,
					step = 1,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info) return flyoutgetter(info) end, --getFunc,
					set = function(info, value) flyoutsetter(info, value) end,
				},
				mouse = {
					order = 16,
					type = "select",
					name = "Show on Click",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info)  return flyoutgetter(info) end, --getFunc,
					set = function(info, value) flyoutsetter(info, value) end,
					values = { CLICK = "Click", MOUSE = "Mouse" },

				},
				generate = {
					order = 17,
					type = "execute",
					name = "Save",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					func = function() createflyoutmacro() end,
				},
				output = {
					order = 18,
					type = "input",
					name = "output",
					--desc = L.SPELL_TARGETING_SELF_CAST_MODIFIER_TOGGLE,
					get = function(info) return finalmacro end,
					width = "full"
				},
			},
		},
	} ,
}
LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, target_options)
