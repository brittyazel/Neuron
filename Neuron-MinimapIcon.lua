--Neuron , a World of Warcraft® user interface addon.

--Neuron MinimapIcon makes use of LibDBIcon and LibDataBroker to make sure we play nicely with LDB addons and to simplify dramatically the minimap button

local DB

Neuron.NeuronMinimapIcon = Neuron:NewModule("NeuronMinimapIcon")
local NeuronMinimapIcon = Neuron.NeuronMinimapIcon

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local neuronIconLDB

local icon


-------------------------------------------------------------------------
--------------------Start of Functions-----------------------------------
-------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronMinimapIcon:OnInitialize()

    DB = Neuron.db.profile

    neuronIconLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Neuron", {
        type = "launcher",
        text = "Neuron",
        icon = "Interface\\AddOns\\Neuron\\Images\\static_icon",
        OnClick = function(frame, button) NeuronMinimapIcon:OnClickHandler(frame, button) end,
        OnTooltipShow = function(tooltip) NeuronMinimapIcon:TooltipHandler(tooltip) end,
    })

    icon = LibStub("LibDBIcon-1.0")
    icon:Register("Neuron", neuronIconLDB, DB.NeuronIcon)

end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function NeuronMinimapIcon:OnClickHandler(frame, button)

    if (InCombatLockdown()) then
        return
    end

    PlaySound(SOUNDKIT.IG_CHAT_SCROLL_DOWN)

    if (button == "LeftButton" and not IsShiftKeyDown()) then
        Neuron:ToggleBarEditMode(true)
    elseif (button == "RightButton" and not IsShiftKeyDown()) then
        Neuron:ToggleButtonEditMode(true)
    elseif (button == "LeftButton" and IsShiftKeyDown()) then
        Neuron:ToggleBindingMode(true)
    elseif (button == "RightButton" and IsShiftKeyDown()) then
        Neuron:ToggleMainMenu()
    end

end

function NeuronMinimapIcon:TooltipHandler(tooltip)

    tooltip:SetText("Neuron", 1, 1, 1)
    tooltip:AddLine(L["Left-Click to Configure Bars"])
    tooltip:AddLine(L["Right-Click to Configure Buttons"])
    tooltip:AddLine(L["Shift + Left-Click to Toggle Keybind Mode"])
    tooltip:AddLine(L["Shift + Right-Click to Toggle the Interface Menu"])

    tooltip:Show()

end

function NeuronMinimapIcon:ToggleIcon()

    if DB.NeuronIcon.hide == false then
        icon:Hide("Neuron")
        DB.NeuronIcon.hide = true
    elseif DB.NeuronIcon.hide == true then
        icon:Show("Neuron")
        DB.NeuronIcon.hide = false
    end

end