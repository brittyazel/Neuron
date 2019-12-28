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
--along with this add-on.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2019.


---The functions in this file are part of the ACTIONBUTTON class.
---It was just easier to put them all in their own file for organization.

local BUTTON = Neuron.BUTTON

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


----------------------------------------------------------------------------
--------------------------Button Editor Overlay-----------------------------
----------------------------------------------------------------------------

function BUTTON:EditorOverlay_CreateEditFrame(button)

	local editor = CreateFrame("Button", button:GetName().."EditFrame", button, "NeuronEditFrameTemplate")

	setmetatable(editor, { __index = CreateFrame("Button") })

	editor:EnableMouseWheel(true)
	editor:RegisterForClicks("AnyDown")
	editor:SetAllPoints(button)
	editor:SetScript("OnShow", function(self) BUTTON:EditorOverlay_OnShow(self) end)
	editor:SetScript("OnEnter", function(self) BUTTON:EditorOverlay_OnEnter(self) end)
	editor:SetScript("OnLeave", function(self) BUTTON:EditorOverlay_OnLeave(self) end)
	editor:SetScript("OnClick", function(self, button) BUTTON:EditorOverlay_OnClick(self, button) end)


	if button.objType == "ACTIONBUTTON" then
		editor.type:SetText(L["Edit"])
		editor.editType = "button"
	else
		editor.type:SetText("")
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
	end

	button.editor = editor
	editor.object = button
	Neuron.EDITIndex[button.class..button.bar.DB.id.."_"..button.id] = editor

	editor:Hide()
end

function BUTTON:EditorOverlay_OnShow(editor)

	local object = editor.object

	if (object) then

		if (object.bar) then
			editor:SetFrameLevel(object.bar:GetFrameLevel()+1)
		end
	end
end

function BUTTON:EditorOverlay_OnEnter(editor)

	editor.select:Show()

	GameTooltip:SetOwner(editor, "ANCHOR_RIGHT")

	GameTooltip:Show()

end

function BUTTON:EditorOverlay_OnLeave(editor)

	if (editor.object ~= Neuron.CurrentObject) then
		editor.select:Hide()
	end

	GameTooltip:Hide()

end

function BUTTON:EditorOverlay_OnClick(editor, button)

	local newObj, newEditor = Neuron.BUTTON:ChangeObject(editor.object)

	if (button == "RightButton") then

	end

end